//
//  LakeLightsViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 6/7/23.
//  Copyright © 2023 WET. All rights reserved.
//

import UIKit

class LakeLightsViewController: UIViewController {
    
    @IBOutlet weak var noConnectionView: UIView!
    @IBOutlet weak var noConnectionErrorLbl: UILabel!
    @IBOutlet weak var autoHandBtn: UIButton!
    @IBOutlet weak var schedulerContainerView: UIView!
    @IBOutlet weak var lowWaterNoLights: UIImageView!
    
    private let logger = Logger()
    private let httpComm = HTTPComm()
    private var langData = Dictionary<String, String>()
    private let helper = Helper()
    private var dayModeStatus = 0
    var lightType = 0
    var featureId = 0
    private let showManager  = ShowManager()
    
    override func viewWillAppear(_ animated: Bool) {
        //Add notification observer to get system stat
        self.navigationItem.title = "LAGOON LIGHTS"
        NotificationCenter.default.addObserver(self, selector: #selector(checkLagoonSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
        if lightType == 11{
            readServerPath = READ_LAKE_LIGHT_SERVER_PATH
            writeServerPath = WRITE_LAKE_LIGHT_SERVER_PATH
            self.navigationItem.title = "FEATURE LIGHTS"
        } else if lightType == 12{
            readServerPath = READ_LAKEPOOL_LIGHT_SERVER_PATH
            writeServerPath = WRITE_LAKEPOOL_LIGHT_SERVER_PATH
            self.navigationItem.title = "POOL LIGHTS"
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    /***************************************************************************
     * Function :  checkSystemStat
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    @objc func checkLagoonSystemStat(){
        let (plcConnection,_,serverConnection,_) = CENTRAL_SYSTEM!.getConnectivityStat()
        
        if plcConnection == CONNECTION_STATE_CONNECTED && serverConnection == CONNECTION_STATE_CONNECTED  {
            
            //Change the connection stat indicator
            noConnectionView.alpha = 0
            readIndividualLightsOnOff()
            
        } else {
            noConnectionView.alpha = 1
            
            if plcConnection == CONNECTION_STATE_FAILED || serverConnection == CONNECTION_STATE_FAILED {
                if serverConnection == CONNECTION_STATE_CONNECTED {
                    noConnectionErrorLbl.text = "PLC CONNECTION FAILED, SERVER GOOD"
                } else if plcConnection == CONNECTION_STATE_CONNECTED{
                    noConnectionErrorLbl.text = "SERVER CONNECTION FAILED, PLC GOOD"
                } else {
                    noConnectionErrorLbl.text = "SERVER AND PLC CONNECTION FAILED"
                }
            }
            
            if plcConnection == CONNECTION_STATE_CONNECTING || serverConnection == CONNECTION_STATE_CONNECTING {
                if serverConnection == CONNECTION_STATE_CONNECTED {
                    noConnectionErrorLbl.text = "CONNECTING TO PLC, SERVER CONNECTED"
                } else if plcConnection == CONNECTION_STATE_CONNECTED{
                    noConnectionErrorLbl.text = "CONNECTING TO SERVER, PLC CONNECTED"
                } else {
                    noConnectionErrorLbl.text = "CONNECTING TO SERVER AND PLC.."
                }
            }
            
            if plcConnection == CONNECTION_STATE_POOR_CONNECTION && serverConnection == CONNECTION_STATE_POOR_CONNECTION {
                noConnectionErrorLbl.text = "SERVER AND PLC POOR CONNECTION"
            } else if plcConnection == CONNECTION_STATE_POOR_CONNECTION {
                noConnectionErrorLbl.text = "PLC POOR CONNECTION, SERVER CONNECTED"
            } else if serverConnection == CONNECTION_STATE_POOR_CONNECTION {
                noConnectionErrorLbl.text = "SERVER POOR CONNECTION, PLC CONNECTED"
            }
        }
    }
    
    //MARK: - Read Water Level Fault From PLC
    
    
    //MARK: - Read Lights On Off
    @objc private func readIndividualLightsOnOff(){
        
            CENTRAL_SYSTEM?.readBits(plcIpAddress:MITT_LA_PLC_IP_ADDRESS, length: 6, startingRegister: Int32(WATER_LEVE_LSH3001), completion: { (success, response) in
                
                guard response != nil else{
                    return
                }
                
                let abvH = self.view.viewWithTag(2002) as? UIImageView
                let blwL = self.view.viewWithTag(2003) as? UIImageView
                let blwLL = self.view.viewWithTag(2004) as? UIImageView
                let mkeup = self.view.viewWithTag(2009) as? UILabel
                let mkeupTmout = self.view.viewWithTag(2010) as? UIImageView
                let mlfunction = self.view.viewWithTag(2011) as? UIImageView
                
                let aboveH  = Int(truncating: response![0] as! NSNumber)
                let belowL  = Int(truncating: response![1] as! NSNumber)
                let belowLL = Int(truncating: response![2] as! NSNumber)
                let maekup = Int(truncating: response![3] as! NSNumber)
                let makeupTimeout = Int(truncating: response![4] as! NSNumber)
                let malfunction = Int(truncating: response![5] as! NSNumber)
                
                aboveH == 1 ? ( abvH?.image = #imageLiteral(resourceName: "red")) : (abvH?.image = #imageLiteral(resourceName: "blank_icon_on"))
                belowL == 1 ? ( blwL?.image = #imageLiteral(resourceName: "red")) : (blwL?.image = #imageLiteral(resourceName: "blank_icon_on"))
                belowLL == 1 ? ( blwLL?.image = #imageLiteral(resourceName: "red")) : (blwLL?.image = #imageLiteral(resourceName: "blank_icon_on"))
                makeupTimeout == 1 ? ( mkeupTmout?.image = #imageLiteral(resourceName: "red")) : (mkeupTmout?.image = #imageLiteral(resourceName: "blank_icon_on"))
                malfunction == 1 ? ( mlfunction?.image = #imageLiteral(resourceName: "red")) : (mlfunction?.image = #imageLiteral(resourceName: "blank_icon_on"))
                
                if maekup == 1 {
                    mkeup?.text = "ON"
                    mkeup?.textColor = GREEN_COLOR
                } else {
                    mkeup?.text = "OFF"
                    mkeup?.textColor = DEFAULT_GRAY
                }
                
                if belowL == 1 {
                    self.lowWaterNoLights.isHidden = false
                } else {
                    self.lowWaterNoLights.isHidden = true
                }
                
            })
            
            CENTRAL_SYSTEM?.readRegister(plcIpAddress:MITT_LA_PLC_IP_ADDRESS, length: 6, startingRegister: Int32(LAKE_LIGHTS_AUTO_HAND_PLC_REGISTER), completion: { (success, response) in
                
                guard response != nil else{
                    return
                }
                let lcp301Lbl = self.view.viewWithTag(2007) as? UILabel
                let lcp302Lbl = self.view.viewWithTag(2008) as? UILabel
                
                let lcp301 = Int(truncating: response![0] as! NSNumber)
                let lcp302 = Int(truncating: response![5] as! NSNumber)
                
                if lcp301 == 0 {
                    lcp301Lbl!.text = "OFF"
                } else if lcp301 == 1 {
                    lcp301Lbl!.text = "AUTO"
                } else if lcp301 == 2 {
                    lcp301Lbl!.text = "HAND"
                }
                
                if lcp302 == 0 {
                    lcp302Lbl!.text = "OFF"
                } else if lcp302 == 1 {
                    lcp302Lbl!.text = "AUTO"
                } else if lcp302 == 2 {
                    lcp302Lbl!.text = "HAND"
                }
            })
            CENTRAL_SYSTEM?.readBits(plcIpAddress:MITT_LA_PLC_IP_ADDRESS, length: 6, startingRegister: Int32(LAKE_LIGHTS_STATUS), completion: { (success, response) in
                
                guard response != nil else{
                    return
                }
                
                let lcp301Lbl = self.view.viewWithTag(2005) as? UILabel
                let lcp302Lbl = self.view.viewWithTag(2006) as? UILabel
                
                let lcp301 = Int(truncating: response![0] as! NSNumber)
                let lcp302 = Int(truncating: response![5] as! NSNumber)
                
                if lcp301 == 0 {
                    lcp301Lbl!.text = "OFF"
                } else if lcp301 == 1 {
                    lcp301Lbl!.text = "ON"
                }
                
                if lcp302 == 0 {
                    lcp302Lbl!.text = "OFF"
                } else if lcp302 == 1 {
                    lcp302Lbl!.text = "ON"
                }
            })
    }
    
    @IBAction func settingsButtonPressed(_ sender: UIButton) {
       self.addAlertAction(button: sender)
    }
}
