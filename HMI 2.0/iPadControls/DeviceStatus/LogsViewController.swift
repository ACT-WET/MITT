//
//  LogsViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 1/30/20.
//  Copyright © 2020 WET. All rights reserved.
//

import UIKit

class LogsViewController: UIViewController {
    @IBOutlet weak var scrollview: UIScrollView!
    private let showManager  = ShowManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool){
        self.scrollview.contentSize = CGSize(width: self.scrollview.frame.width, height: 890)
        super.viewWillAppear(true)
        //Add notification observer to get system stat
        NotificationCenter.default.addObserver(self, selector: #selector(checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
    }
    
    @objc func checkSystemStat(){
        let devicelogs = self.showManager.getStatusLogFromServer()
        
        //ShowStoppers
        let estopImg = self.scrollview.viewWithTag(1) as? UIImageView
        let waterLvlImg = self.scrollview.viewWithTag(2) as? UIImageView
        let windImg = self.scrollview.viewWithTag(3) as? UIImageView
        
        devicelogs.showStoppereStop == 1 ? (estopImg?.isHidden = false) : (estopImg?.isHidden = true)
        devicelogs.showStopperwater == 1 ? (waterLvlImg?.isHidden = false) : (waterLvlImg?.isHidden = true)
        devicelogs.showStopperwind == 1 ? (windImg?.isHidden = false) : (windImg?.isHidden = true)
        
        //Lights
        let wf1lights = self.scrollview.viewWithTag(11) as? UILabel
        let wf2lights = self.scrollview.viewWithTag(12) as? UILabel
        let wf3lights = self.scrollview.viewWithTag(13) as? UILabel
        let wf4lights = self.scrollview.viewWithTag(14) as? UILabel
        let wf5lights = self.scrollview.viewWithTag(15) as? UILabel
        let wf6lights = self.scrollview.viewWithTag(16) as? UILabel
        let lights101 = self.scrollview.viewWithTag(17) as? UILabel
        let lights102A = self.scrollview.viewWithTag(18) as? UILabel
        let lights102B = self.scrollview.viewWithTag(19) as? UILabel
        
        if devicelogs.wf1lights == 0{
            wf1lights?.text = "ON"
            wf1lights?.textColor = GREEN_COLOR
        } else {
            wf1lights?.text = "OFF"
            wf1lights?.textColor = DEFAULT_GRAY
        }
        
        if devicelogs.wf2lights == 0{
            wf2lights?.text = "ON"
            wf2lights?.textColor = GREEN_COLOR
        } else {
            wf2lights?.text = "OFF"
            wf2lights?.textColor = DEFAULT_GRAY
        }
        
        if devicelogs.wf3lights == 0{
            wf3lights?.text = "ON"
            wf3lights?.textColor = GREEN_COLOR
        } else {
            wf3lights?.text = "OFF"
            wf3lights?.textColor = DEFAULT_GRAY
        }
        
        if devicelogs.wf4lights == 0{
            wf4lights?.text = "ON"
            wf4lights?.textColor = GREEN_COLOR
        } else {
            wf4lights?.text = "OFF"
            wf4lights?.textColor = DEFAULT_GRAY
        }
        
        if devicelogs.wf5lights == 0{
            wf5lights?.text = "ON"
            wf5lights?.textColor = GREEN_COLOR
        } else {
            wf5lights?.text = "OFF"
            wf5lights?.textColor = DEFAULT_GRAY
        }
        
        if devicelogs.wf6lights == 0{
            wf6lights?.text = "ON"
            wf6lights?.textColor = GREEN_COLOR
        } else {
            wf6lights?.text = "OFF"
            wf6lights?.textColor = DEFAULT_GRAY
        }
        
        if devicelogs.lights101 == 0{
            lights101?.text = "ON"
            lights101?.textColor = GREEN_COLOR
        } else {
            lights101?.text = "OFF"
            lights101?.textColor = DEFAULT_GRAY
        }
        
        if devicelogs.lights102A == 0{
            lights102A?.text = "ON"
            lights102A?.textColor = GREEN_COLOR
        } else {
            lights102A?.text = "OFF"
            lights102A?.textColor = DEFAULT_GRAY
        }
        
        if devicelogs.lights102B == 0{
            lights102B?.text = "ON"
            lights102B?.textColor = GREEN_COLOR
        } else {
            lights102B?.text = "OFF"
            lights102B?.textColor = DEFAULT_GRAY
        }
        
        //Pumps
        let pump1101 = self.scrollview.viewWithTag(20) as? UIImageView
        let pump1102 = self.scrollview.viewWithTag(21) as? UIImageView
        let pump1301 = self.scrollview.viewWithTag(22) as? UIImageView
        let pump1302 = self.scrollview.viewWithTag(23) as? UIImageView
        let pump1303 = self.scrollview.viewWithTag(24) as? UIImageView
        let pump1401 = self.scrollview.viewWithTag(25) as? UIImageView
        let pump1402 = self.scrollview.viewWithTag(26) as? UIImageView
        let pump1501 = self.scrollview.viewWithTag(27) as? UIImageView
        let pump1502 = self.scrollview.viewWithTag(28) as? UIImageView
        let pump1503 = self.scrollview.viewWithTag(29) as? UIImageView
        let pump1601 = self.scrollview.viewWithTag(30) as? UIImageView
        let pump1602 = self.scrollview.viewWithTag(31) as? UIImageView
        let press1101 = self.scrollview.viewWithTag(32) as? UIImageView
        let press1102 = self.scrollview.viewWithTag(33) as? UIImageView
        let press1301 = self.scrollview.viewWithTag(34) as? UIImageView
        let press1302 = self.scrollview.viewWithTag(35) as? UIImageView
        let press1303 = self.scrollview.viewWithTag(36) as? UIImageView
        let press1401 = self.scrollview.viewWithTag(37) as? UIImageView
        let press1402 = self.scrollview.viewWithTag(38) as? UIImageView
        let press1501 = self.scrollview.viewWithTag(39) as? UIImageView
        let press1502 = self.scrollview.viewWithTag(40) as? UIImageView
        let press1503 = self.scrollview.viewWithTag(41) as? UIImageView
        let press1601 = self.scrollview.viewWithTag(42) as? UIImageView
        let press1602 = self.scrollview.viewWithTag(43) as? UIImageView
        
        devicelogs.pumpFault1101 == 1 ? ( pump1101?.image = #imageLiteral(resourceName: "red")) : (pump1101?.image = #imageLiteral(resourceName: "green"))
        devicelogs.pumpFault1102 == 1 ? ( pump1102?.image = #imageLiteral(resourceName: "red")) : (pump1102?.image = #imageLiteral(resourceName: "green"))
        devicelogs.pumpFault1301 == 1 ? ( pump1301?.image = #imageLiteral(resourceName: "red")) : (pump1301?.image = #imageLiteral(resourceName: "green"))
        devicelogs.pumpFault1302 == 1 ? ( pump1302?.image = #imageLiteral(resourceName: "red")) : (pump1302?.image = #imageLiteral(resourceName: "green"))
        devicelogs.pumpFault1303 == 1 ? ( pump1303?.image = #imageLiteral(resourceName: "red")) : (pump1303?.image = #imageLiteral(resourceName: "green"))
        devicelogs.pumpFault1401 == 1 ? ( pump1401?.image = #imageLiteral(resourceName: "red")) : (pump1401?.image = #imageLiteral(resourceName: "green"))
        devicelogs.pumpFault1402 == 1 ? ( pump1402?.image = #imageLiteral(resourceName: "red")) : (pump1402?.image = #imageLiteral(resourceName: "green"))
        devicelogs.pumpFault1501 == 1 ? ( pump1501?.image = #imageLiteral(resourceName: "red")) : (pump1501?.image = #imageLiteral(resourceName: "green"))
        devicelogs.pumpFault1502 == 1 ? ( pump1502?.image = #imageLiteral(resourceName: "red")) : (pump1502?.image = #imageLiteral(resourceName: "green"))
        devicelogs.pumpFault1503 == 1 ? ( pump1503?.image = #imageLiteral(resourceName: "red")) : (pump1503?.image = #imageLiteral(resourceName: "green"))
        devicelogs.pumpFault1601 == 1 ? ( pump1601?.image = #imageLiteral(resourceName: "red")) : (pump1601?.image = #imageLiteral(resourceName: "green"))
        devicelogs.pumpFault1602 == 1 ? ( pump1602?.image = #imageLiteral(resourceName: "red")) : (pump1602?.image = #imageLiteral(resourceName: "green"))
        devicelogs.pressFault1101 == 1 ? ( press1101?.image = #imageLiteral(resourceName: "red")) : (press1101?.image = #imageLiteral(resourceName: "green"))
        devicelogs.pressFault1102 == 1 ? ( press1102?.image = #imageLiteral(resourceName: "red")) : (press1102?.image = #imageLiteral(resourceName: "green"))
        devicelogs.pressFault1301 == 1 ? ( press1301?.image = #imageLiteral(resourceName: "red")) : (press1301?.image = #imageLiteral(resourceName: "green"))
        devicelogs.pressFault1302 == 1 ? ( press1302?.image = #imageLiteral(resourceName: "red")) : (press1302?.image = #imageLiteral(resourceName: "green"))
        devicelogs.pressFault1303 == 1 ? ( press1303?.image = #imageLiteral(resourceName: "red")) : (press1303?.image = #imageLiteral(resourceName: "green"))
        devicelogs.pressFault1401 == 1 ? ( press1401?.image = #imageLiteral(resourceName: "red")) : (press1401?.image = #imageLiteral(resourceName: "green"))
        devicelogs.pressFault1402 == 1 ? ( press1402?.image = #imageLiteral(resourceName: "red")) : (press1402?.image = #imageLiteral(resourceName: "green"))
        devicelogs.pressFault1501 == 1 ? ( press1501?.image = #imageLiteral(resourceName: "red")) : (press1501?.image = #imageLiteral(resourceName: "green"))
        devicelogs.pressFault1502 == 1 ? ( press1502?.image = #imageLiteral(resourceName: "red")) : (press1502?.image = #imageLiteral(resourceName: "green"))
        devicelogs.pressFault1503 == 1 ? ( press1503?.image = #imageLiteral(resourceName: "red")) : (press1503?.image = #imageLiteral(resourceName: "green"))
        devicelogs.pressFault1601 == 1 ? ( press1601?.image = #imageLiteral(resourceName: "red")) : (press1601?.image = #imageLiteral(resourceName: "green"))
        devicelogs.pressFault1602 == 1 ? ( press1602?.image = #imageLiteral(resourceName: "red")) : (press1602?.image = #imageLiteral(resourceName: "green"))
        
        //WaterLevel
        let ls1101 = self.scrollview.viewWithTag(51) as? UIImageView
        let ls1201 = self.scrollview.viewWithTag(52) as? UIImageView
        let ls1301 = self.scrollview.viewWithTag(53) as? UIImageView
        let ls1401 = self.scrollview.viewWithTag(54) as? UIImageView
        let ls1501 = self.scrollview.viewWithTag(55) as? UIImageView
        let ls1601 = self.scrollview.viewWithTag(56) as? UIImageView
        let makeup1 = self.scrollview.viewWithTag(57) as? UILabel
        let makeup1Timeout = self.scrollview.viewWithTag(58) as? UIImageView
        let makeup2 = self.scrollview.viewWithTag(59) as? UILabel
        let makeup2Timeout = self.scrollview.viewWithTag(60) as? UIImageView
        
        devicelogs.ls1101belowLL == 1 ? ( ls1101?.image = #imageLiteral(resourceName: "showStopperWaterLevel")) : (ls1101?.image = #imageLiteral(resourceName: "waterlevel_outline-gray"))
        devicelogs.ls1201belowLL == 1 ? ( ls1201?.image = #imageLiteral(resourceName: "showStopperWaterLevel")) : (ls1201?.image = #imageLiteral(resourceName: "waterlevel_outline-gray"))
        devicelogs.ls1301belowLL == 1 ? ( ls1301?.image = #imageLiteral(resourceName: "showStopperWaterLevel")) : (ls1301?.image = #imageLiteral(resourceName: "waterlevel_outline-gray"))
        devicelogs.ls1401belowLL == 1 ? ( ls1401?.image = #imageLiteral(resourceName: "showStopperWaterLevel")) : (ls1401?.image = #imageLiteral(resourceName: "waterlevel_outline-gray"))
        devicelogs.ls1501belowLL == 1 ? ( ls1501?.image = #imageLiteral(resourceName: "showStopperWaterLevel")) : (ls1501?.image = #imageLiteral(resourceName: "waterlevel_outline-gray"))
        devicelogs.ls1601belowLL == 1 ? ( ls1601?.image = #imageLiteral(resourceName: "showStopperWaterLevel")) : (ls1601?.image = #imageLiteral(resourceName: "waterlevel_outline-gray"))
        devicelogs.lt1001makeupTimeout == 1 ? ( makeup1Timeout?.image = #imageLiteral(resourceName: "red")) : (makeup1Timeout?.image = #imageLiteral(resourceName: "green"))
        devicelogs.ls1201makeupTimeout == 1 ? ( makeup2Timeout?.image = #imageLiteral(resourceName: "red")) : (makeup2Timeout?.image = #imageLiteral(resourceName: "green"))
        
        if devicelogs.lt1001makeupOn == 1{
            makeup1?.text = "ON"
            makeup1?.textColor = GREEN_COLOR
        } else {
            makeup1?.text = "OFF"
            makeup1?.textColor = DEFAULT_GRAY
        }
        
        if devicelogs.ls1201makeupOn == 1{
            makeup2?.text = "ON"
            makeup2?.textColor = GREEN_COLOR
        } else {
            makeup2?.text = "OFF"
            makeup2?.textColor = DEFAULT_GRAY
        }
        
        //WaterQuality
        let tds1_hi = self.scrollview.viewWithTag(61) as? UIImageView
        let tds1_ch = self.scrollview.viewWithTag(63) as? UIImageView
        let orp1_hi = self.scrollview.viewWithTag(64) as? UIImageView
        let orp1_bl = self.scrollview.viewWithTag(65) as? UIImageView
        let orp1_ch = self.scrollview.viewWithTag(66) as? UIImageView
        let pH1_hi = self.scrollview.viewWithTag(67) as? UIImageView
        let pH1_bl = self.scrollview.viewWithTag(68) as? UIImageView
        let pH1_ch = self.scrollview.viewWithTag(69) as? UIImageView
        let tds2_hi = self.scrollview.viewWithTag(70) as? UIImageView
        let tds2_ch = self.scrollview.viewWithTag(72) as? UIImageView
        let orp2_hi = self.scrollview.viewWithTag(73) as? UIImageView
        let orp2_bl = self.scrollview.viewWithTag(74) as? UIImageView
        let orp2_ch = self.scrollview.viewWithTag(75) as? UIImageView
        let pH2_hi = self.scrollview.viewWithTag(76) as? UIImageView
        let pH2_bl = self.scrollview.viewWithTag(77) as? UIImageView
        let pH2_ch = self.scrollview.viewWithTag(78) as? UIImageView
        let bWash1Running = self.scrollview.viewWithTag(80) as? UILabel
        let bWash2Running = self.scrollview.viewWithTag(81) as? UILabel
        let pump1001 = self.scrollview.viewWithTag(82) as? UIImageView
        let pump1201 = self.scrollview.viewWithTag(83) as? UIImageView
        let press1001 = self.scrollview.viewWithTag(84) as? UIImageView
        let press1201 = self.scrollview.viewWithTag(85) as? UIImageView
        
        devicelogs.tds1AbvHi == 1 ? ( tds1_hi?.image = #imageLiteral(resourceName: "red")) : (tds1_hi?.image = #imageLiteral(resourceName: "green"))
        devicelogs.tds1ChFault == 1 ? ( tds1_ch?.image = #imageLiteral(resourceName: "red")) : (tds1_ch?.image = #imageLiteral(resourceName: "green"))
        devicelogs.orp1AbvHi == 1 ? ( orp1_hi?.image = #imageLiteral(resourceName: "red")) : (orp1_hi?.image = #imageLiteral(resourceName: "green"))
        devicelogs.orp1belowL == 1 ? ( orp1_bl?.image = #imageLiteral(resourceName: "red")) : (orp1_bl?.image = #imageLiteral(resourceName: "green"))
        devicelogs.orp1ChFault == 1 ? ( orp1_ch?.image = #imageLiteral(resourceName: "red")) : (orp1_ch?.image = #imageLiteral(resourceName: "green"))
        devicelogs.ph1AbvHi == 1 ? ( pH1_hi?.image = #imageLiteral(resourceName: "red")) : (pH1_hi?.image = #imageLiteral(resourceName: "green"))
        devicelogs.ph1belowL == 1 ? ( pH1_bl?.image = #imageLiteral(resourceName: "red")) : (pH1_bl?.image = #imageLiteral(resourceName: "green"))
        devicelogs.ph1ChFault == 1 ? ( pH1_ch?.image = #imageLiteral(resourceName: "red")) : (pH1_ch?.image = #imageLiteral(resourceName: "green"))
        
        devicelogs.tds2AbvHi == 1 ? ( tds2_hi?.image = #imageLiteral(resourceName: "red")) : (tds2_hi?.image = #imageLiteral(resourceName: "green"))
        devicelogs.tds2ChFault == 1 ? ( tds2_ch?.image = #imageLiteral(resourceName: "red")) : (tds2_ch?.image = #imageLiteral(resourceName: "green"))
        devicelogs.orp2AbvHi == 1 ? ( orp2_hi?.image = #imageLiteral(resourceName: "red")) : (orp2_hi?.image = #imageLiteral(resourceName: "green"))
        devicelogs.orp2belowL == 1 ? ( orp2_bl?.image = #imageLiteral(resourceName: "red")) : (orp2_bl?.image = #imageLiteral(resourceName: "green"))
        devicelogs.orp2ChFault == 1 ? ( orp2_ch?.image = #imageLiteral(resourceName: "red")) : (orp2_ch?.image = #imageLiteral(resourceName: "green"))
        devicelogs.ph2AbvHi == 1 ? ( pH2_hi?.image = #imageLiteral(resourceName: "red")) : (pH2_hi?.image = #imageLiteral(resourceName: "green"))
        devicelogs.ph2belowL == 1 ? ( pH2_bl?.image = #imageLiteral(resourceName: "red")) : (pH2_bl?.image = #imageLiteral(resourceName: "green"))
        devicelogs.ph2ChFault == 1 ? ( pH2_ch?.image = #imageLiteral(resourceName: "red")) : (pH2_ch?.image = #imageLiteral(resourceName: "green"))
        
        devicelogs.pumpFault1001 == 1 ? ( pump1001?.image = #imageLiteral(resourceName: "red")) : (pump1001?.image = #imageLiteral(resourceName: "green"))
        devicelogs.pumpFault1201 == 1 ? ( pump1201?.image = #imageLiteral(resourceName: "red")) : (pump1201?.image = #imageLiteral(resourceName: "green"))
        devicelogs.pressFault1001 == 1 ? ( press1001?.image = #imageLiteral(resourceName: "red")) : (press1001?.image = #imageLiteral(resourceName: "green"))
        devicelogs.pressFault1201 == 1 ? ( press1201?.image = #imageLiteral(resourceName: "red")) : (press1201?.image = #imageLiteral(resourceName: "green"))
        
        if devicelogs.bw1Running == 1{
            bWash1Running?.text = "ON"
            bWash1Running?.textColor = GREEN_COLOR
        } else {
            bWash1Running?.text = "OFF"
            bWash1Running?.textColor = DEFAULT_GRAY
        }
        
        if devicelogs.bw2Running == 1{
            bWash2Running?.text = "ON"
            bWash2Running?.textColor = GREEN_COLOR
        } else {
            bWash2Running?.text = "OFF"
            bWash2Running?.textColor = DEFAULT_GRAY
        }
        
        //Wind
        let wind_hi = self.scrollview.viewWithTag(4) as? UIImageView
        let wind_bl = self.scrollview.viewWithTag(5) as? UIImageView
        let wind_speed = self.scrollview.viewWithTag(6) as? UIImageView
        let wind_direction = self.scrollview.viewWithTag(7) as? UIImageView
        
        devicelogs.windAbvHi == 1 ? ( wind_hi?.image = #imageLiteral(resourceName: "red")) : (wind_hi?.image = #imageLiteral(resourceName: "green"))
        devicelogs.windbelowL == 1 ? ( wind_bl?.image = #imageLiteral(resourceName: "green")) : (wind_bl?.image = #imageLiteral(resourceName: "blank_icon_on"))
        devicelogs.windspeedFault == 1 ? ( wind_speed?.image = #imageLiteral(resourceName: "red")) : (wind_speed?.image = #imageLiteral(resourceName: "green"))
        devicelogs.windDirectionFault == 1 ? ( wind_direction?.image = #imageLiteral(resourceName: "red")) : (wind_direction?.image = #imageLiteral(resourceName: "green"))
        
        //Fog
        let fs101pumpOverload = self.scrollview.viewWithTag(44) as? UIImageView
        let fs101pumpFault = self.scrollview.viewWithTag(45) as? UIImageView
        let fs101pressFault = self.scrollview.viewWithTag(46) as? UIImageView
        let fs102pumpOverload = self.scrollview.viewWithTag(47) as? UIImageView
        let fs102pumpFault = self.scrollview.viewWithTag(48) as? UIImageView
        let fs102pressFault = self.scrollview.viewWithTag(49) as? UIImageView
        
        devicelogs.fs101pumpOverload == 1 ? ( fs101pumpOverload?.image = #imageLiteral(resourceName: "red")) : (fs101pumpOverload?.image = #imageLiteral(resourceName: "green"))
        devicelogs.fs101pumpFault == 1 ? ( fs101pumpFault?.image = #imageLiteral(resourceName: "red")) : (fs101pumpFault?.image = #imageLiteral(resourceName: "green"))
        devicelogs.fs101pressFault == 1 ? ( fs101pressFault?.image = #imageLiteral(resourceName: "red")) : (fs101pressFault?.image = #imageLiteral(resourceName: "green"))
        
        devicelogs.fs102pumpOverload == 1 ? ( fs102pumpOverload?.image = #imageLiteral(resourceName: "red")) : (fs102pumpOverload?.image = #imageLiteral(resourceName: "green"))
        devicelogs.fs102pumpFault == 1 ? ( fs102pumpFault?.image = #imageLiteral(resourceName: "red")) : (fs102pumpFault?.image = #imageLiteral(resourceName: "green"))
        devicelogs.fs102pressFault == 1 ? ( fs102pressFault?.image = #imageLiteral(resourceName: "red")) : (fs102pressFault?.image = #imageLiteral(resourceName: "green"))
        
        //Show
        
        let sysWng = self.scrollview.viewWithTag(8) as? UIImageView
        let sysFlt = self.scrollview.viewWithTag(9) as? UIImageView
        let winterizeMode = self.scrollview.viewWithTag(10) as? UIImageView
        let playMode = self.scrollview.viewWithTag(50) as? UIImageView
        let spmRatMode = self.scrollview.viewWithTag(79) as? UIImageView
        let dayMode = self.scrollview.viewWithTag(86) as? UILabel
        
        devicelogs.sysWarning == 1 ? ( sysWng?.image = #imageLiteral(resourceName: "red")) : (sysWng?.image = #imageLiteral(resourceName: "green"))
        devicelogs.sysFault == 1 ? ( sysFlt?.image = #imageLiteral(resourceName: "red")) : (sysFlt?.image = #imageLiteral(resourceName: "green"))
        devicelogs.winterizeMode == 1 ? ( winterizeMode?.image = #imageLiteral(resourceName: "red")) : (winterizeMode?.image = #imageLiteral(resourceName: "green"))
        devicelogs.spmRatmode == 1 ? ( spmRatMode?.image = #imageLiteral(resourceName: "red")) : (spmRatMode?.image = #imageLiteral(resourceName: "green"))
        
        if devicelogs.dayMode == 1{
            dayMode?.text = "ON"
            dayMode?.textColor = GREEN_COLOR
        } else {
            dayMode?.text = "OFF"
            dayMode?.textColor = DEFAULT_GRAY
        }
        
        if devicelogs.playMode == 1{
            playMode?.image = #imageLiteral(resourceName: "handMode")
            playMode?.rotate360Degrees(animate: false)
        } else {
            playMode?.image = #imageLiteral(resourceName: "autoMode")
            playMode?.rotate360Degrees(animate: true)
        }
    }
     

}
