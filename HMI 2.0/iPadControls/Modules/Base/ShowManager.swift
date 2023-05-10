//
//  ShowManager.swift
//  iPadControls
//
//  Created by Arpi Derm on 12/30/16.
//  Copyright © 2016 WET. All rights reserved.
//

import UIKit

public struct ShowPlayStat{
    
    var playMode = 0 //Options: 1 – manual , 0 – auto
    var playStatus = 0 //Options: 1 – is playing a show, 0- idle
    var currentShowNumber = 0 //Show number that is currently playing
    var deflate = "" //The moment the show started : Format :: HHMMSS
    var nextShowTime = 0 //Format :: HHMMSS
    var nextShowNumber = 0
    var showDuration = 0
    var playType = 0
    var nextShowName = ""
    var currentShowName = ""
    var showRemaining = 0
    var enableDeadMan = 0
    var servRequired = 0
    
}
public struct DeviceStat{
    
    var cp601estop = 0
    var sysWarning = 0
    var sysFault = 0
    var showStoppereStop = 0
    var showStopperwind = 0
    var showStopperwater = 0
    
    var playMode = 0
    var spmRatmode = 0
    var dayMode = 0
    
    var windAbvHi = 0
    var windAbvMed = 0
    var windbelowL = 0
    var windnW = 0
    var windspeedFault = 0
    var windDirectionFault = 0
    
    var lsAbvHi = 0
    var lsblwL = 0
    var lsblwLL = 0
    
    var bender13current  = 0.0
    var bender23current  = 0.0
    var bender33current  = 0.0
    var bender43current  = 0.0
    var bender53current  = 0.0
    var bender63current  = 0.0
    var bender73current  = 0.0
    var bender83current  = 0.0
    var bender93current  = 0.0
    var bender103current = 0.0
    var bender113current = 0.0
    var bender123current = 0.0
    
    var bw1Running = 0
    var tds1AbvHi = 0
    var tds1ChFault = 0
    var ph1AbvHi = 0
    var ph1belowL = 0
    var ph1ChFault = 0
    var orp1AbvHi = 0
    var orp1belowL = 0
    var orp1ChFault = 0
    var brDosing = 0
    var brTimeout = 0
    var wfBrEnable = 0
    
    var fsHAmode = 0
    var fsON = 0
    
    var lights201 = 0
    var lights202 = 0
    
    var ys201Tripped = 0
    var ys202Tripped = 0
    var ys203Tripped = 0
    var ys204Tripped = 0
    var ys205Tripped = 0
    var ys206Tripped = 0
    var ys207Tripped = 0
    var ys208Tripped = 0
    var ys209Tripped = 0
    var ys210Tripped = 0
    var ys211Tripped = 0
    var ys212Tripped = 0
}
public class ShowManager{
    
    private var shows: [Any]? = nil
    private var lakeshows: [Any]? = nil
    private var httpComm = HTTPComm()
    private var debug_mode = false
    private var showPlayStat = ShowPlayStat()
    private var lakeshowPlayStat = ShowPlayStat()
    private var deviceStat = DeviceStat()
    //MARK: - Get Shows From The Server
    
    public func getShowsFile(){
        
        httpComm.httpGetResponseFromPath(url: READ_SHOWS_PATH){ (response) in
            
            self.shows = response as? [Any]
            
            guard self.shows != nil else{ return }
            
            UserDefaults.standard.set(self.shows, forKey: "shows")
            
            //We want to delete all the shows from local storage before saving new ones
            self.deleteAllShowsFromLocalStorage()
            
            //Save Each Show To Local Storage
            self.saveShowsInLocalStorage()
         
        }
        
    }
    
    public func getLakeShowsFile(){
        
        httpComm.httpGetResponseFromPath(url: READ_LAKE_SHOWS_PATH){ (response) in
            
            self.lakeshows = response as? [Any]
            
            guard self.lakeshows != nil else{ return }
            
            UserDefaults.standard.set(self.lakeshows, forKey: "lakeshows")
            
            //We want to delete all the shows from local storage before saving new ones
            self.deleteAllLakeShowsFromLocalStorage()
            
            //Save Each Show To Local Storage
            self.saveLakeShowsInLocalStorage()
         
        }
        
    }
    
    //MARK: - Delete All the Shows
    
    private func deleteAllShowsFromLocalStorage(){
        
        Show.deleteAll()
        
    }
    
    private func deleteAllLakeShowsFromLocalStorage(){
        
        LakeShow.deleteAll()
        
    }
    
    //MARK: - Save Shows In Local Storage
    
    private func saveShowsInLocalStorage(){
        
        for show in self.shows!{
            
            let dictionary  = show as! NSDictionary
            let duration    = dictionary.object(forKey: "duration") as? Int
            let name        = dictionary.object(forKey: "name") as? String
            let number      = dictionary.object(forKey: "number") as? Int
            
            guard duration != nil && name != nil && number != nil else{
                return
            }
            
            let show        = Show.create() as! Show
            show.duration   = Int32(duration!)
            show.number     = Int16(number!)
            show.name       = name!
            
            _ = show.save()
            
            self.logData(str:"DURATION: \(duration!) NAME: \(name!) NUMBER: \(number!)")
            
        }
    }
    
    private func saveLakeShowsInLocalStorage(){
        
        for show in self.lakeshows!{
            
            let dictionary  = show as! NSDictionary
            let duration    = dictionary.object(forKey: "duration") as? Int
            let name        = dictionary.object(forKey: "name") as? String
            let number      = dictionary.object(forKey: "number") as? Int
            
            guard duration != nil && name != nil && number != nil else{
                return
            }
            
            let show        = LakeShow.create() as! LakeShow
            show.duration   = Int32(duration!)
            show.number     = Int16(number!)
            show.name       = name!
            
            _ = show.save()
            
            self.logData(str:"DURATION: \(duration!) NAME: \(name!) NUMBER: \(number!)")
            
        }
    }
    
    //MARK: - Get Current and Next Playing Show
    
    public func getCurrentAndNextShowInfo() -> ShowPlayStat {
        
        httpComm.httpGetResponseFromPath(url: READ_SHOW_PLAY_STAT){ (response) in
            
            guard response != nil else { return }
            guard let responseArray = response as? [Any] else { return }
            
            if responseArray.isEmpty == false {
                guard let responseDictionary = responseArray[0] as? [String : Any] else { return }
                
                
                if  let playMode         = responseDictionary["Play Mode"] as? Int,
                    let playStatus       = responseDictionary["play status"] as? Int,
                    let currentShow      = responseDictionary["Current Show"] as? Int,
                    let currentShowName      = responseDictionary["Current Show Name"] as? String,
                    let currentShowDur      = responseDictionary["Current Show Duration"] as? Int,
                    let playType         = responseDictionary["Show Type"] as? Int,
                    let deflate          = responseDictionary["deflate"] as? String,
                    let showremaining    = responseDictionary["show time remaining"] as? Int,
                    let servReq          = responseDictionary["Service Required"] as? Int,
                    let nextShowTime     = responseDictionary["next Show Time"] as? Int,
                    let nextShowNumber   = responseDictionary["next Show Num"] as? Int {
                    
                    
                    self.showPlayStat.currentShowNumber = currentShow
                    self.showPlayStat.currentShowName = currentShowName
                    self.showPlayStat.playType = playType
                    self.showPlayStat.deflate           = deflate
                    self.showPlayStat.nextShowTime      = nextShowTime
                    self.showPlayStat.nextShowNumber    = nextShowNumber
                    self.showPlayStat.playMode          = playMode
                    self.showPlayStat.playStatus        = playStatus
                    self.showPlayStat.servRequired      = servReq
                    self.showPlayStat.showRemaining = showremaining
                    self.showPlayStat.showDuration = currentShowDur
                    
                    if let nextShows = Show.query(["number":self.showPlayStat.nextShowNumber]) as? [Show] {
                        if !nextShows.isEmpty{
                            self.showPlayStat.nextShowName = (nextShows[0].name!)
                        }
                    }
                }
            }
        }
        
        return self.showPlayStat
        
    }
    
    public func getLakeCurrentAndNextShowInfo() -> ShowPlayStat {
        
        httpComm.httpGetResponseFromPath(url: READ_LAKE_SHOW_PLAY_STAT){ (response) in
            
            guard response != nil else { return }
            guard let responseArray = response as? [Any] else { return }
            
            if responseArray.isEmpty == false {
                guard let responseDictionary = responseArray[0] as? [String : Any] else { return }
                
                
                if
                    let playMode         = responseDictionary["Play Mode"] as? Int,
                    let playStatus       = responseDictionary["play status"] as? Int,
                    let currentShow      = responseDictionary["Current Show"] as? Int,
                    let currentShowName      = responseDictionary["Current Show Name"] as? String,
                    let currentShowDur      = responseDictionary["Current Show Duration"] as? Int,
                    let playType         = responseDictionary["Show Type"] as? Int,
                    let deflate          = responseDictionary["deflate"] as? String,
                    let showremaining    = responseDictionary["show time remaining"] as? Int,
                    let servReq          = responseDictionary["Service Required"] as? Int,
                    let nextShowTime     = responseDictionary["next Show Time"] as? Int,
                    let nextShowNumber   = responseDictionary["next Show Num"] as? Int {
                    
                    
                    self.lakeshowPlayStat.currentShowNumber = currentShow
                    self.lakeshowPlayStat.currentShowName = currentShowName
                    self.lakeshowPlayStat.playType = playType
                    self.lakeshowPlayStat.deflate           = deflate
                    self.lakeshowPlayStat.nextShowTime      = nextShowTime
                    self.lakeshowPlayStat.nextShowNumber    = nextShowNumber
                    self.lakeshowPlayStat.playMode          = playMode
                    self.lakeshowPlayStat.playStatus        = playStatus
                    self.lakeshowPlayStat.servRequired      = servReq
                    self.lakeshowPlayStat.showRemaining = showremaining
                    self.lakeshowPlayStat.showDuration = currentShowDur
                    
                    if let nextShows = LakeShow.query(["number":self.lakeshowPlayStat.nextShowNumber]) as? [LakeShow] {
                        if !nextShows.isEmpty{
                            self.lakeshowPlayStat.nextShowName = (nextShows[0].name!)
                        }
                    }
                }
            }
        }
        
        return self.lakeshowPlayStat
        
    }
    /***************************************************************************
     * Function :  geStatusLogFromServer
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    public func getStatusLogFromServer() -> DeviceStat{
        
            self.httpComm.httpGetResponseFromPath(url: STATUS_LOG_FTP_PATH){ (response) in
                
                guard response != nil else { return }
                
                guard let responseArray = response as? [Any] else { return }
                if !responseArray.isEmpty{
                    let responseDictionary = responseArray[0] as? NSDictionary
                        
                        if responseDictionary != nil{
                            
                            if let estop = responseDictionary!["CP601 Estop"] as? Int,
                            let sysWarning = responseDictionary!["Out_BMS2001A"] as? Int,
                            let sysFault = responseDictionary!["Out_BMS2001B"] as? Int,
                            let showStoppereStop = responseDictionary!["ShowStopper :Estop"] as? Int,
                            let showStopperwind = responseDictionary!["ShowStopper :High Speed Wind Abort"] as? Int,
                            let showStopperwater = responseDictionary!["ShowStopper :WaterLevelLow"] as? Int,
                            
                            let playMode = responseDictionary!["Show PlayMode"] as? Int,
                            let spmRatmode = responseDictionary!["SPM_RAT_Mode"] as? Int,
                            let dayMode = responseDictionary!["SPM: DayMode Status"] as? Int,
                                
                            let windAbvHi = responseDictionary!["ST1001 Above_Hi"] as? Int,
                            let windAbvMed = responseDictionary!["ST1001 Above_Med"] as? Int,
                            let windbelowL = responseDictionary!["ST1001 Below_Low"] as? Int,
                            let windnW = responseDictionary!["ST1001 No_Wind"] as? Int,
                            let windspeedFault = responseDictionary!["ST1001 Speed_Channel_Fault"] as? Int,
                            let windDirectionFault = responseDictionary!["ST1001 Direction_Channel_Fault"] as? Int,
                            
                            let lsAbvHi = responseDictionary!["LS2001 Above_Hi"] as? Int,
                            let lsblwL = responseDictionary!["LS2001 Below_Low"] as? Int,
                            let lsblwLL = responseDictionary!["LS2001 Below_LowLow"] as? Int,
                            
                            let bender13current  = responseDictionary!["BENDER 1 3-PHASE CURRENT DATA"] as? Double,
                            let bender23current  = responseDictionary!["BENDER 2 3-PHASE CURRENT DATA"] as? Double,
                            let bender33current  = responseDictionary!["BENDER 3 3-PHASE CURRENT DATA"] as? Double,
                            let bender43current  = responseDictionary!["BENDER 4 3-PHASE CURRENT DATA"] as? Double,
                            let bender53current  = responseDictionary!["BENDER 5 3-PHASE CURRENT DATA"] as? Double,
                            let bender63current  = responseDictionary!["BENDER 6 3-PHASE CURRENT DATA"] as? Double,
                            let bender73current  = responseDictionary!["BENDER 7 3-PHASE CURRENT DATA"] as? Double,
                            let bender83current  = responseDictionary!["BENDER 8 3-PHASE CURRENT DATA"] as? Double,
                            let bender93current  = responseDictionary!["BENDER 9 3-PHASE CURRENT DATA"] as? Double,
                            let bender103current = responseDictionary!["BENDER 10 3-PHASE CURRENT DATA"] as? Double,
                            let bender113current = responseDictionary!["BENDER 11 3-PHASE CURRENT DATA"] as? Double,
                            let bender123current = responseDictionary!["BENDER 12 3-PHASE CURRENT DATA"] as? Double,
                            
                            let bw1Running = responseDictionary!["Backwash1 Run"] as? Int,
                            let tds1AbvHi = responseDictionary!["TDS Above Hi"] as? Int,
                            let tds1ChFault = responseDictionary!["TDS ChannelFault"] as? Int,
                            let ph1AbvHi = responseDictionary!["PH Above Hi"] as? Int,
                            let ph1belowL = responseDictionary!["PH Below Low"] as? Int,
                            let ph1ChFault = responseDictionary!["PH ChannelFault"] as? Int,
                            let orp1AbvHi = responseDictionary!["ORP Above Hi"] as? Int,
                            let orp1belowL = responseDictionary!["ORP Below Low"] as? Int,
                            let orp1ChFault = responseDictionary!["ORP ChannelFault"] as? Int,
                            let brDosing = responseDictionary!["Bromine Dosing"] as? Int,
                            let brTimeout = responseDictionary!["Bromine Timeout"] as? Int,
                            let wfBrEnable = responseDictionary!["WaterFlow Bromine Enabled"] as? Int,
                            
                            let fsHAmode = responseDictionary!["FS113 HA Mode"] as? Int,
                            let fsON = responseDictionary!["FS113 Hand On"] as? Int,
                            
                            let lights201 = responseDictionary!["MicroShooter Lights ON"] as? Int,
                            let lights202 = responseDictionary!["Oarsman Lights ON"] as? Int,
                            
                            let ys201Tripped = responseDictionary!["YS201 GFCI TRIPPED"] as? Int,
                            let ys202Tripped = responseDictionary!["YS202 GFCI TRIPPED"] as? Int,
                            let ys203Tripped = responseDictionary!["YS203 GFCI TRIPPED"] as? Int,
                            let ys204Tripped = responseDictionary!["YS204 GFCI TRIPPED"] as? Int,
                            let ys205Tripped = responseDictionary!["YS205 GFCI TRIPPED"] as? Int,
                            let ys206Tripped = responseDictionary!["YS206 GFCI TRIPPED"] as? Int,
                            let ys207Tripped = responseDictionary!["YS207 GFCI TRIPPED"] as? Int,
                            let ys208Tripped = responseDictionary!["YS208 GFCI TRIPPED"] as? Int,
                            let ys209Tripped = responseDictionary!["YS209 GFCI TRIPPED"] as? Int,
                            let ys210Tripped = responseDictionary!["YS210 GFCI TRIPPED"] as? Int,
                            let ys211Tripped = responseDictionary!["YS211 GFCI TRIPPED"] as? Int,
                            let ys212Tripped = responseDictionary!["YS212 GFCI TRIPPED"] as? Int{
                                
                                self.deviceStat.cp601estop = estop
                                self.deviceStat.sysWarning = sysWarning
                                self.deviceStat.sysFault = sysFault
                                self.deviceStat.showStoppereStop = showStoppereStop
                                self.deviceStat.showStopperwater = showStopperwater
                                self.deviceStat.showStopperwind = showStopperwind
                                
                                self.deviceStat.playMode = playMode
                                self.deviceStat.spmRatmode = spmRatmode
                                self.deviceStat.dayMode = dayMode
                                
                                self.deviceStat.windAbvHi = windAbvHi
                                self.deviceStat.windAbvMed = windAbvMed
                                self.deviceStat.windbelowL = windbelowL
                                self.deviceStat.windnW = windnW
                                self.deviceStat.windspeedFault = windspeedFault
                                self.deviceStat.windDirectionFault = windDirectionFault
                                
                                self.deviceStat.lsAbvHi = lsAbvHi
                                self.deviceStat.lsblwL = lsblwL
                                self.deviceStat.lsblwLL = lsblwLL
                                
                                self.deviceStat.bender13current = bender13current
                                self.deviceStat.bender23current = bender23current
                                self.deviceStat.bender33current = bender33current
                                self.deviceStat.bender43current = bender43current
                                self.deviceStat.bender53current = bender53current
                                self.deviceStat.bender63current = bender63current
                                self.deviceStat.bender73current = bender73current
                                self.deviceStat.bender83current = bender83current
                                self.deviceStat.bender93current = bender93current
                                self.deviceStat.bender103current = bender103current
                                self.deviceStat.bender113current = bender113current
                                self.deviceStat.bender123current = bender123current
                                
                                self.deviceStat.bw1Running = bw1Running
                                self.deviceStat.tds1AbvHi = tds1AbvHi
                                self.deviceStat.tds1ChFault = tds1ChFault
                                self.deviceStat.ph1AbvHi = ph1AbvHi
                                self.deviceStat.ph1belowL = ph1belowL
                                self.deviceStat.ph1ChFault = ph1ChFault
                                self.deviceStat.orp1AbvHi = orp1AbvHi
                                self.deviceStat.orp1belowL = orp1belowL
                                self.deviceStat.orp1ChFault = orp1ChFault
                                self.deviceStat.brDosing = brDosing
                                self.deviceStat.brTimeout = brTimeout
                                self.deviceStat.wfBrEnable = wfBrEnable
                                
                                self.deviceStat.fsHAmode = fsHAmode
                                self.deviceStat.fsON = fsON
                                
                                self.deviceStat.lights201 = lights201
                                self.deviceStat.lights202 = lights202
                                
                                self.deviceStat.ys201Tripped = ys201Tripped
                                self.deviceStat.ys202Tripped = ys202Tripped
                                self.deviceStat.ys203Tripped = ys203Tripped
                                self.deviceStat.ys204Tripped = ys204Tripped
                                self.deviceStat.ys205Tripped = ys205Tripped
                                self.deviceStat.ys206Tripped = ys206Tripped
                                self.deviceStat.ys207Tripped = ys207Tripped
                                self.deviceStat.ys208Tripped = ys208Tripped
                                self.deviceStat.ys209Tripped = ys209Tripped
                                self.deviceStat.ys210Tripped = ys210Tripped
                                self.deviceStat.ys211Tripped = ys211Tripped
                                self.deviceStat.ys212Tripped = ys212Tripped
                            }
                            
                        }
                        
                       
                    }
                }
                
        return self.deviceStat
    }
    //Data Logger
    
    private func logData(str:String){
        
        if debug_mode == true{
            
            print(str)
            
        }
        
    }
    
}

