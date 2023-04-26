//
//  LogsViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 1/30/20.
//  Copyright © 2020 WET. All rights reserved.
//

import UIKit

class LogsViewController: UIViewController {
 private let showManager  = ShowManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool){
        
        super.viewWillAppear(true)
        //Add notification observer to get system stat
        NotificationCenter.default.addObserver(self, selector: #selector(checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
    }
    
    @objc func checkSystemStat(){
        let devicelogs = self.showManager.getStatusLogFromServer()
        
        //ShowStoppers
        let estopImg = self.view.viewWithTag(1) as? UIImageView
        let waterLvlImg = self.view.viewWithTag(2) as? UIImageView
        let windImg = self.view.viewWithTag(3) as? UIImageView
        
        devicelogs.showStoppereStop == 1 ? (estopImg?.isHidden = false) : (estopImg?.isHidden = true)
        devicelogs.showStopperwater == 1 ? (waterLvlImg?.isHidden = false) : (waterLvlImg?.isHidden = true)
        devicelogs.showStopperwind == 1 ? (windImg?.isHidden = false) : (windImg?.isHidden = true)
        
        //Lights
        let lightMode = self.view.viewWithTag(11) as? UIImageView
        let lightState = self.view.viewWithTag(12) as? UILabel
        
        if devicelogs.lightsMode == 1{
            lightMode?.image = #imageLiteral(resourceName: "handMode")
            lightMode?.rotate360Degrees(animate: false)
        } else {
            lightMode?.image = #imageLiteral(resourceName: "autoMode")
            lightMode?.rotate360Degrees(animate: true)
        }
        
        if devicelogs.lightsState == 1{
            lightState?.text = "ON"
            lightState?.textColor = GREEN_COLOR
        } else {
            lightState?.text = "OFF"
            lightState?.textColor = DEFAULT_GRAY
        }
        
        
        //Pumps
        let net101 = self.view.viewWithTag(21) as? UIImageView
        let net102 = self.view.viewWithTag(22) as? UIImageView
        let net103 = self.view.viewWithTag(23) as? UIImageView
        let net104 = self.view.viewWithTag(24) as? UIImageView
        let pump101 = self.view.viewWithTag(25) as? UIImageView
        let pump102 = self.view.viewWithTag(26) as? UIImageView
        let pump103 = self.view.viewWithTag(27) as? UIImageView
        let pump104 = self.view.viewWithTag(28) as? UIImageView
        let press101 = self.view.viewWithTag(29) as? UIImageView
        let press102 = self.view.viewWithTag(30) as? UIImageView
        let press103 = self.view.viewWithTag(31) as? UIImageView
        let press104 = self.view.viewWithTag(32) as? UIImageView
        
        devicelogs.networkFault101 == 1 ? ( net101?.image = #imageLiteral(resourceName: "red")) : (net101?.image = #imageLiteral(resourceName: "green"))
        devicelogs.networkFault102 == 1 ? ( net102?.image = #imageLiteral(resourceName: "red")) : (net102?.image = #imageLiteral(resourceName: "green"))
        devicelogs.networkFault103 == 1 ? ( net103?.image = #imageLiteral(resourceName: "red")) : (net103?.image = #imageLiteral(resourceName: "green"))
        devicelogs.networkFault104 == 1 ? ( net104?.image = #imageLiteral(resourceName: "red")) : (net104?.image = #imageLiteral(resourceName: "green"))
        
        devicelogs.pumpFault101 == 1 ? ( pump101?.image = #imageLiteral(resourceName: "red")) : (pump101?.image = #imageLiteral(resourceName: "green"))
        devicelogs.pumpFault102 == 1 ? ( pump102?.image = #imageLiteral(resourceName: "red")) : (pump102?.image = #imageLiteral(resourceName: "green"))
        devicelogs.pumpFault103 == 1 ? ( pump103?.image = #imageLiteral(resourceName: "red")) : (pump103?.image = #imageLiteral(resourceName: "green"))
        devicelogs.pumpFault104 == 1 ? ( pump104?.image = #imageLiteral(resourceName: "red")) : (pump104?.image = #imageLiteral(resourceName: "green"))
        
        devicelogs.pressFault101 == 1 ? ( press101?.image = #imageLiteral(resourceName: "red")) : (press101?.image = #imageLiteral(resourceName: "green"))
        devicelogs.pressFault102 == 1 ? ( press102?.image = #imageLiteral(resourceName: "red")) : (press102?.image = #imageLiteral(resourceName: "green"))
        devicelogs.pressFault103 == 1 ? ( press103?.image = #imageLiteral(resourceName: "red")) : (press103?.image = #imageLiteral(resourceName: "green"))
        devicelogs.pressFault104 == 1 ? ( press104?.image = #imageLiteral(resourceName: "red")) : (press104?.image = #imageLiteral(resourceName: "green"))
        
        
        //WaterLevel
        let ls1001 = self.view.viewWithTag(41) as? UIImageView
        let ls1002 = self.view.viewWithTag(42) as? UIImageView
        let ls1003 = self.view.viewWithTag(43) as? UIImageView
        let ls1004 = self.view.viewWithTag(44) as? UIImageView
        let ls1005 = self.view.viewWithTag(45) as? UIImageView
        let makeup = self.view.viewWithTag(46) as? UILabel
        let makeupTimeout = self.view.viewWithTag(47) as? UIImageView
        
        devicelogs.waterLs1001 == 1 ? ( ls1001?.image = #imageLiteral(resourceName: "showStopperWaterLevel")) : (ls1001?.image = #imageLiteral(resourceName: "waterlevel_outline-gray"))
        devicelogs.waterLs1002 == 1 ? ( ls1002?.image = #imageLiteral(resourceName: "showStopperWaterLevel")) : (ls1002?.image = #imageLiteral(resourceName: "waterlevel_outline-gray"))
        devicelogs.waterLs1003 == 1 ? ( ls1003?.image = #imageLiteral(resourceName: "showStopperWaterLevel")) : (ls1003?.image = #imageLiteral(resourceName: "waterlevel_outline-gray"))
        devicelogs.waterLs1004 == 1 ? ( ls1004?.image = #imageLiteral(resourceName: "showStopperWaterLevel")) : (ls1004?.image = #imageLiteral(resourceName: "waterlevel_outline-gray"))
        devicelogs.waterLs1005 == 1 ? ( ls1005?.image = #imageLiteral(resourceName: "showStopperWaterLevel")) : (ls1005?.image = #imageLiteral(resourceName: "waterlevel_outline-gray"))
        devicelogs.waterMakeupTimeout == 1 ? ( makeupTimeout?.image = #imageLiteral(resourceName: "red")) : (makeupTimeout?.image = #imageLiteral(resourceName: "green"))
        
        if devicelogs.waterMakeup == 1{
            makeup?.text = "ON"
            makeup?.textColor = GREEN_COLOR
        } else {
            makeup?.text = "OFF"
            makeup?.textColor = DEFAULT_GRAY
        }
        
        //WaterQuality
        let tds_hi = self.view.viewWithTag(51) as? UIImageView
        let tds_bl = self.view.viewWithTag(54) as? UIImageView
        let tds_ch = self.view.viewWithTag(57) as? UIImageView
        let orp_hi = self.view.viewWithTag(52) as? UIImageView
        let orp_bl = self.view.viewWithTag(55) as? UIImageView
        let orp_ch = self.view.viewWithTag(58) as? UIImageView
        let pH_hi = self.view.viewWithTag(53) as? UIImageView
        let pH_bl = self.view.viewWithTag(56) as? UIImageView
        let pH_ch = self.view.viewWithTag(59) as? UIImageView
        let brTimeout = self.view.viewWithTag(60) as? UIImageView
        let bWashRunning = self.view.viewWithTag(61) as? UILabel
        
        devicelogs.tds_abvHigh == 1 ? ( tds_hi?.image = #imageLiteral(resourceName: "red")) : (tds_hi?.image = #imageLiteral(resourceName: "green"))
        devicelogs.tds_belowLow == 1 ? ( tds_bl?.image = #imageLiteral(resourceName: "red")) : (tds_bl?.image = #imageLiteral(resourceName: "green"))
        devicelogs.tds_chFault == 1 ? ( tds_ch?.image = #imageLiteral(resourceName: "red")) : (tds_ch?.image = #imageLiteral(resourceName: "green"))
        
        devicelogs.orp_abvHigh == 1 ? ( orp_hi?.image = #imageLiteral(resourceName: "red")) : (orp_hi?.image = #imageLiteral(resourceName: "green"))
        devicelogs.orp_belowLow == 1 ? ( orp_bl?.image = #imageLiteral(resourceName: "red")) : (orp_bl?.image = #imageLiteral(resourceName: "green"))
        devicelogs.orp_chFault == 1 ? ( orp_ch?.image = #imageLiteral(resourceName: "red")) : (orp_ch?.image = #imageLiteral(resourceName: "green"))
        
        devicelogs.pH_abvHigh == 1 ? ( pH_hi?.image = #imageLiteral(resourceName: "red")) : (pH_hi?.image = #imageLiteral(resourceName: "green"))
        devicelogs.pH_belowLow == 1 ? ( pH_bl?.image = #imageLiteral(resourceName: "red")) : (pH_bl?.image = #imageLiteral(resourceName: "green"))
        devicelogs.pH_chFault == 1 ? ( pH_ch?.image = #imageLiteral(resourceName: "red")) : (pH_ch?.image = #imageLiteral(resourceName: "green"))
        devicelogs.br_Timeout == 1 ? ( brTimeout?.image = #imageLiteral(resourceName: "red")) : (brTimeout?.image = #imageLiteral(resourceName: "green"))
        
        if devicelogs.backwashRunning == 1{
            bWashRunning?.text = "ON"
            bWashRunning?.textColor = GREEN_COLOR
        } else {
            bWashRunning?.text = "OFF"
            bWashRunning?.textColor = DEFAULT_GRAY
        }
        
        //Wind
        let wind_hi = self.view.viewWithTag(71) as? UIImageView
        let wind_bl = self.view.viewWithTag(72) as? UIImageView
        let wind_speed = self.view.viewWithTag(73) as? UIImageView
        let wind_direction = self.view.viewWithTag(74) as? UIImageView
        
        devicelogs.wind_abvHigh == 1 ? ( wind_hi?.image = #imageLiteral(resourceName: "red")) : (wind_hi?.image = #imageLiteral(resourceName: "green"))
        devicelogs.wind_belowLow == 1 ? ( wind_bl?.image = #imageLiteral(resourceName: "red")) : (wind_bl?.image = #imageLiteral(resourceName: "green"))
        devicelogs.wind_speedFault == 1 ? ( wind_speed?.image = #imageLiteral(resourceName: "red")) : (wind_speed?.image = #imageLiteral(resourceName: "green"))
        devicelogs.wind_directionFault == 1 ? ( wind_direction?.image = #imageLiteral(resourceName: "red")) : (wind_direction?.image = #imageLiteral(resourceName: "green"))
        
        
    }
     

}
