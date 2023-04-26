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
    
    var showStoppereStop = 0
    var showStopperwind = 0
    var showStopperwater = 0
    
    var wf1lights = 0
    var wf2lights = 0
    var wf3lights = 0
    var wf4lights = 0
    var wf5lights = 0
    var wf6lights = 0
    var lights101 = 0
    var lights102A = 0
    var lights102B = 0
    
    var pumpFault1101 = 0
    var pumpFault1102 = 0
    var pumpFault1301 = 0
    var pumpFault1302 = 0
    var pumpFault1303 = 0
    var pumpFault1401 = 0
    var pumpFault1402 = 0
    var pumpFault1501 = 0
    var pumpFault1502 = 0
    var pumpFault1503 = 0
    var pumpFault1601 = 0
    var pumpFault1602 = 0
    var pressFault1101 = 0
    var pressFault1102 = 0
    var pressFault1301 = 0
    var pressFault1302 = 0
    var pressFault1303 = 0
    var pressFault1401 = 0
    var pressFault1402 = 0
    var pressFault1501 = 0
    var pressFault1502 = 0
    var pressFault1503 = 0
    var pressFault1601 = 0
    var pressFault1602 = 0
    
    var ls1101belowLL = 0
    var ls1201belowLL = 0
    var ls1301belowLL = 0
    var ls1401belowLL = 0
    var ls1501belowLL = 0
    var ls1601belowLL = 0
    var ls1201makeupOn = 0
    var ls1201makeupTimeout = 0
    var lt1001makeupTimeout = 0
    var lt1001makeupOn = 0
    
    var ph1ChFault = 0
    var ph1AbvHi = 0
    var ph1belowL = 0
    var orp1ChFault = 0
    var orp1AbvHi = 0
    var orp1belowL = 0
    var tds1ChFault = 0
    var tds1AbvHi = 0
    var tds1belowL = 0
    var ph2ChFault = 0
    var ph2AbvHi = 0
    var ph2belowL = 0
    var orp2ChFault = 0
    var orp2AbvHi = 0
    var orp2belowL = 0
    var tds2ChFault = 0
    var tds2AbvHi = 0
    var tds2belowL = 0
    var bw1Running = 0
    var bw2Running = 0
    var pressFault1001 = 0
    var pressFault1201 = 0
    var pumpFault1001 = 0
    var pumpFault1201 = 0

    var windAbvHi = 0
    var windbelowL = 0
    var windspeedFault = 0
    var windDirectionFault = 0
    
    var fs101pumpOverload = 0
    var fs101pumpFault = 0
    var fs101pressFault = 0
    var fs102pumpOverload = 0
    var fs102pumpFault = 0
    var fs102pressFault = 0
    
    var sysWarning = 0
    var sysFault = 0
    var spmRatmode = 0
    var dayMode = 0
    var winterizeMode = 0
    var playMode = 0
    

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
                    let deflate          = responseDictionary["deflate"] as? String,
                    let showremaining    = responseDictionary["show time remaining"] as? Int,
                    let nextShowTime     = responseDictionary["next Show Time"] as? Int,
                    let servReq          = responseDictionary["Service Required"] as? Int,
                    let playType         = responseDictionary["Show Type"] as? Int,
                    let deadMan          = responseDictionary["enableDeadman"] as? Int,
                    let nextShowNumber   = responseDictionary["next Show Num"] as? Int {
                    
                    
                    self.showPlayStat.currentShowNumber = currentShow
                    self.showPlayStat.currentShowName = currentShowName
                    self.showPlayStat.playType = playType
                    self.showPlayStat.deflate           = deflate
                    self.showPlayStat.nextShowTime      = nextShowTime
                    self.showPlayStat.nextShowNumber    = nextShowNumber
                    self.showPlayStat.playMode          = playMode
                    self.showPlayStat.enableDeadMan     = deadMan
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
                
                
                if  let playMode         = responseDictionary["Play Mode"] as? Int,
                    let playStatus       = responseDictionary["play status"] as? Int,
                    let currentShow      = responseDictionary["Current Show"] as? Int,
                    let currentShowName      = responseDictionary["Current Show Name"] as? String,
                    let currentShowDur      = responseDictionary["Current Show Duration"] as? Int,
                    let deflate          = responseDictionary["deflate"] as? String,
                    let showremaining    = responseDictionary["show time remaining"] as? Int,
                    let nextShowTime     = responseDictionary["next Show Time"] as? Int,
                    let servReq          = responseDictionary["Service Required"] as? Int,
                    let playType         = responseDictionary["Show Type"] as? Int,
                    let deadMan          = responseDictionary["enableDeadman"] as? Int,
                    let nextShowNumber   = responseDictionary["next Show Num"] as? Int {
                    
                    
                    self.lakeshowPlayStat.currentShowNumber = currentShow
                    self.lakeshowPlayStat.currentShowName = currentShowName
                    self.lakeshowPlayStat.playType = playType
                    self.lakeshowPlayStat.deflate           = deflate
                    self.lakeshowPlayStat.nextShowTime      = nextShowTime
                    self.lakeshowPlayStat.nextShowNumber    = nextShowNumber
                    self.lakeshowPlayStat.playMode          = playMode
                    self.lakeshowPlayStat.enableDeadMan     = deadMan
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
                            if  let showStoppereStop = responseDictionary!["ShowStopper :Estop"] as? Int,
                            let showStopperwind = responseDictionary!["ShowStopper :High Speed Wind Abort"] as? Int,
                            let showStopperwater = responseDictionary!["ShowStopper :WaterLevelLow"] as? Int,
                            
                            let wf1lights = responseDictionary!["WF-1 Lights Off"] as? Int,
                            let wf2lights = responseDictionary!["WF-2 Lights Off"] as? Int,
                            let wf3lights = responseDictionary!["WF-3 Lights Off"] as? Int,
                            let wf4lights = responseDictionary!["WF-4 Lights Off"] as? Int,
                            let wf5lights = responseDictionary!["WF-5 Lights Off"] as? Int,
                            let wf6lights = responseDictionary!["WF-6 Lights Off"] as? Int,
                            let lights101 = responseDictionary!["LCP 101 Relay OFF"] as? Int,
                            let lights102A = responseDictionary!["LCP 102A Relay OFF"] as? Int,
                            let lights102B = responseDictionary!["LCP 102B Relay OFF"] as? Int,
                            
                            let pumpFault1101 = responseDictionary!["VFD 1101 Pump Fault"] as? Int,
                            let pumpFault1102 = responseDictionary!["VFD 1102 Pump Fault"] as? Int,
                            let pumpFault1301 = responseDictionary!["VFD 1301 Pump Fault"] as? Int,
                            let pumpFault1302 = responseDictionary!["VFD 1302 Pump Fault"] as? Int,
                            let pumpFault1303 = responseDictionary!["VFD 1303 Pump Fault"] as? Int,
                            let pumpFault1401 = responseDictionary!["VFD 1401 Pump Fault"] as? Int,
                            let pumpFault1402 = responseDictionary!["VFD 1402 Pump Fault"] as? Int,
                            let pumpFault1501 = responseDictionary!["VFD 1501 Pump Fault"] as? Int,
                            let pumpFault1502 = responseDictionary!["VFD 1502 Pump Fault"] as? Int,
                            let pumpFault1503 = responseDictionary!["VFD 1503 Pump Fault"] as? Int,
                            let pumpFault1601 = responseDictionary!["VFD 1601 Pump Fault"] as? Int,
                            let pumpFault1602 = responseDictionary!["VFD 1602 Pump Fault"] as? Int,
                            let pressFault1101 = responseDictionary!["VFD 1101 Pressure Fault"] as? Int,
                            let pressFault1102 = responseDictionary!["VFD 1102 Pressure Fault"] as? Int,
                            let pressFault1301 = responseDictionary!["VFD 1301 Pressure Fault"] as? Int,
                            let pressFault1302 = responseDictionary!["VFD 1302 Pressure Fault"] as? Int,
                            let pressFault1303 = responseDictionary!["VFD 1303 Pressure Fault"] as? Int,
                            let pressFault1401 = responseDictionary!["VFD 1401 Pressure Fault"] as? Int,
                            let pressFault1402 = responseDictionary!["VFD 1402 Pressure Fault"] as? Int,
                            let pressFault1501 = responseDictionary!["VFD 1501 Pressure Fault"] as? Int,
                            let pressFault1502 = responseDictionary!["VFD 1502 Pressure Fault"] as? Int,
                            let pressFault1503 = responseDictionary!["VFD 1503 Pressure Fault"] as? Int,
                            let pressFault1601 = responseDictionary!["VFD 1601 Pressure Fault"] as? Int,
                            let pressFault1602 = responseDictionary!["VFD 1602 Pressure Fault"] as? Int,
                            
                            let ls1101belowLL = responseDictionary!["LS1101 Below_LL"] as? Int,
                            let ls1201belowLL = responseDictionary!["LS1201 Below_LL"] as? Int,
                            let ls1301belowLL = responseDictionary!["LS1301 Below_LL"] as? Int,
                            let ls1401belowLL = responseDictionary!["LS1401 Below_LL"] as? Int,
                            let ls1501belowLL = responseDictionary!["LS1501 Below_LL"] as? Int,
                            let ls1601belowLL = responseDictionary!["LS1601 Below_LL"] as? Int,
                            let ls1201makeupOn = responseDictionary!["LS1201 WaterMakeup On/Off"] as? Int,
                            let ls1201makeupTimeout = responseDictionary!["LS1201 WaterMakeup Timeout"] as? Int,
                            let lt1001makeupTimeout = responseDictionary!["LT1001 WaterMakeup Timeout"] as? Int,
                            let lt1001makeupOn = responseDictionary!["LT1001 WaterMakeup On/Off"] as? Int,
                            
                            let ph1ChFault = responseDictionary!["pH1: Channel_Fault"] as? Int,
                            let ph1AbvHi = responseDictionary!["pH1: AboveHi"] as? Int,
                            let ph1belowL = responseDictionary!["pH1: Below_Low"] as? Int,
                            let orp1ChFault = responseDictionary!["ORP1: Channel_Fault"] as? Int,
                            let orp1AbvHi = responseDictionary!["ORP1: AboveHi"] as? Int,
                            let orp1belowL = responseDictionary!["ORP1: Below_Low"] as? Int,
                            let tds1ChFault = responseDictionary!["TDS1: Channel_Fault"] as? Int,
                            let tds1AbvHi = responseDictionary!["TDS1: AboveHi"] as? Int,
                            let ph2ChFault = responseDictionary!["pH2: Channel_Fault"] as? Int,
                            let ph2AbvHi = responseDictionary!["pH2: AboveHi"] as? Int,
                            let ph2belowL = responseDictionary!["pH2: Below_Low"] as? Int,
                            let orp2ChFault = responseDictionary!["ORP2: Channel_Fault"] as? Int,
                            let orp2AbvHi = responseDictionary!["ORP2: AboveHi"] as? Int,
                            let orp2belowL = responseDictionary!["ORP2: Below_Low"] as? Int,
                            let tds2ChFault = responseDictionary!["TDS2: Channel_Fault"] as? Int,
                            let tds2AbvHi = responseDictionary!["TDS2: AboveHi"] as? Int,
                            let bw1Running = responseDictionary!["BackwashRunning WF-13456"] as? Int,
                            let bw2Running = responseDictionary!["BackwashRunning WF-2"] as? Int,
                            let pressFault1001 = responseDictionary!["VFD 1001 Pressure Fault"] as? Int,
                            let pressFault1201 = responseDictionary!["VFD 1201 Pressure Fault"] as? Int,
                            let pumpFault1001 = responseDictionary!["VFD 1001 Pump Fault"] as? Int,
                            let pumpFault1201 = responseDictionary!["VFD 1201 Pump Fault"] as? Int,

                            
                            
                            
                            let windAbvHi = responseDictionary!["Wind_AboveHi"] as? Int,
                            let windbelowL = responseDictionary!["Wind_BelowLow"] as? Int,
                            let windspeedFault = responseDictionary!["Wind: SpeedFault"] as? Int,
                            let windDirectionFault = responseDictionary!["Wind: DirectionFault"] as? Int,
                            
                            let fs101pumpOverload = responseDictionary!["FS101 PumpOverload"] as? Int,
                            let fs101pumpFault = responseDictionary!["FS101 Pump Fault"] as? Int,
                            let fs101pressFault = responseDictionary!["FS101 Pressure Fault"] as? Int,
                            let fs102pumpOverload = responseDictionary!["FS102 PumpOverload"] as? Int,
                            let fs102pumpFault = responseDictionary!["FS102 Pump Fault"] as? Int,
                            let fs102pressFault = responseDictionary!["FS102 Pressure Fault"] as? Int,
                            
                            let sysWarning = responseDictionary!["SYSTEM WARNINGS"] as? Int,
                            let sysFault = responseDictionary!["SYSTEM FAULTS"] as? Int,
                            let spmRatmode = responseDictionary!["SPM RAT MODE"] as? Int,
                            let dayMode = responseDictionary!["DayMode Status"] as? Int,
                            let winterizeMode = responseDictionary!["Winterize Mode"] as? Int,
                            let playMode = responseDictionary!["Show PlayMode"] as? Int{
                                
                                self.deviceStat.showStoppereStop = showStoppereStop
                                self.deviceStat.showStopperwater = showStopperwater
                                self.deviceStat.showStopperwind = showStopperwind
                                
                                self.deviceStat.wf1lights = wf1lights
                                self.deviceStat.wf2lights = wf2lights
                                self.deviceStat.wf3lights = wf3lights
                                self.deviceStat.wf4lights = wf4lights
                                self.deviceStat.wf5lights = wf5lights
                                self.deviceStat.wf6lights = wf6lights
                                self.deviceStat.lights101 = lights101
                                self.deviceStat.lights102A = lights102A
                                self.deviceStat.lights102B = lights102B
                                
                                self.deviceStat.pumpFault1101 = pumpFault1101
                                self.deviceStat.pumpFault1102 = pumpFault1102
                                self.deviceStat.pumpFault1301 = pumpFault1301
                                self.deviceStat.pumpFault1302 = pumpFault1302
                                self.deviceStat.pumpFault1303 = pumpFault1303
                                self.deviceStat.pumpFault1401 = pumpFault1401
                                self.deviceStat.pumpFault1402 = pumpFault1402
                                self.deviceStat.pumpFault1501 = pumpFault1501
                                self.deviceStat.pumpFault1502 = pumpFault1502
                                self.deviceStat.pumpFault1503 = pumpFault1503
                                self.deviceStat.pumpFault1601 = pumpFault1601
                                self.deviceStat.pumpFault1602 = pumpFault1602
                                self.deviceStat.pressFault1101 = pressFault1101
                                self.deviceStat.pressFault1102 = pressFault1102
                                self.deviceStat.pressFault1301 = pressFault1301
                                self.deviceStat.pressFault1302 = pressFault1302
                                self.deviceStat.pressFault1303 = pressFault1303
                                self.deviceStat.pressFault1401 = pressFault1401
                                self.deviceStat.pressFault1402 = pressFault1402
                                self.deviceStat.pressFault1501 = pressFault1501
                                self.deviceStat.pressFault1502 = pressFault1502
                                self.deviceStat.pressFault1503 = pressFault1503
                                self.deviceStat.pressFault1601 = pressFault1601
                                self.deviceStat.pressFault1602 = pressFault1602
                                
                                self.deviceStat.ls1101belowLL = ls1101belowLL
                                self.deviceStat.ls1201belowLL = ls1201belowLL
                                self.deviceStat.ls1301belowLL = ls1301belowLL
                                self.deviceStat.ls1401belowLL = ls1401belowLL
                                self.deviceStat.ls1501belowLL = ls1501belowLL
                                self.deviceStat.ls1601belowLL = ls1601belowLL
                                self.deviceStat.ls1201makeupOn = ls1201makeupOn
                                self.deviceStat.ls1201makeupTimeout = ls1201makeupTimeout
                                self.deviceStat.lt1001makeupOn = lt1001makeupOn
                                self.deviceStat.lt1001makeupTimeout = lt1001makeupTimeout
                                
                                self.deviceStat.ph1ChFault = ph1ChFault
                                self.deviceStat.ph1AbvHi = ph1AbvHi
                                self.deviceStat.ph1belowL = ph1belowL
                                self.deviceStat.orp1ChFault = orp1ChFault
                                self.deviceStat.orp1AbvHi = orp1AbvHi
                                self.deviceStat.orp1belowL = orp1belowL
                                self.deviceStat.tds1ChFault = tds1ChFault
                                self.deviceStat.tds1AbvHi = tds1AbvHi
                                self.deviceStat.ph2ChFault = ph2ChFault
                                self.deviceStat.ph2AbvHi = ph2AbvHi
                                self.deviceStat.ph2belowL = ph2belowL
                                self.deviceStat.orp2ChFault = orp2ChFault
                                self.deviceStat.orp2AbvHi = orp2AbvHi
                                self.deviceStat.orp2belowL = orp2belowL
                                self.deviceStat.tds2ChFault = tds2ChFault
                                self.deviceStat.tds2AbvHi = tds2AbvHi
                                self.deviceStat.bw1Running = bw1Running
                                self.deviceStat.bw2Running = bw2Running
                                self.deviceStat.pumpFault1001 = pumpFault1001
                                self.deviceStat.pumpFault1201 = pumpFault1201
                                self.deviceStat.pressFault1001 = pressFault1001
                                self.deviceStat.pressFault1201 = pressFault1201
                                
                                self.deviceStat.windAbvHi = windAbvHi
                                self.deviceStat.windbelowL = windbelowL
                                self.deviceStat.windspeedFault = windspeedFault
                                self.deviceStat.windDirectionFault = windDirectionFault

                                self.deviceStat.fs101pumpFault = fs101pumpFault
                                self.deviceStat.fs101pumpOverload = fs101pumpOverload
                                self.deviceStat.fs101pressFault = fs101pressFault
                                self.deviceStat.fs102pumpFault = fs102pumpFault
                                self.deviceStat.fs102pumpOverload = fs102pumpOverload
                                self.deviceStat.fs102pressFault = fs102pressFault
                                
                                self.deviceStat.sysFault = sysFault
                                self.deviceStat.sysWarning = sysWarning
                                self.deviceStat.spmRatmode = spmRatmode
                                self.deviceStat.dayMode = dayMode
                                self.deviceStat.playMode = playMode
                                self.deviceStat.winterizeMode = winterizeMode
                                
                                
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

