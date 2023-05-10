//
//  LightsViewController.swift
//  iPadControls
//
//  Created by Jan Manalo on 7/31/18.
//  Copyright © 2018 WET. All rights reserved.
//

import UIKit

class LightsViewController: UIViewController {
    
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
        
            CENTRAL_SYSTEM?.readBits(plcIpAddress:MITT_LAG_PLC_IP_ADDRESS, length: 3, startingRegister: Int32(WATER_LEVE_LSH2001), completion: { (success, response) in
                
                guard response != nil else{
                    return
                }
                
                let abvH = self.view.viewWithTag(2002) as? UIImageView
                let blwL = self.view.viewWithTag(2003) as? UIImageView
                let blwLL = self.view.viewWithTag(2004) as? UIImageView
                
                let aboveH  = Int(truncating: response![0] as! NSNumber)
                let belowL  = Int(truncating: response![1] as! NSNumber)
                let belowLL = Int(truncating: response![2] as! NSNumber)
                
                aboveH == 1 ? ( abvH?.image = #imageLiteral(resourceName: "red")) : (abvH?.image = #imageLiteral(resourceName: "green"))
                belowL == 1 ? ( blwL?.image = #imageLiteral(resourceName: "red")) : (blwL?.image = #imageLiteral(resourceName: "green"))
                belowLL == 1 ? ( blwLL?.image = #imageLiteral(resourceName: "red")) : (blwLL?.image = #imageLiteral(resourceName: "green"))
                
                if belowL == 1 {
                    self.lowWaterNoLights.isHidden = false
                } else {
                    self.lowWaterNoLights.isHidden = true
                }
                
            })
            
            CENTRAL_SYSTEM?.readRegister(plcIpAddress:MITT_LAG_PLC_IP_ADDRESS, length: 6, startingRegister: Int32(LIGHTS_AUTO_HAND_PLC_REGISTER), completion: { (success, response) in
                
                guard response != nil else{
                    return
                }
                let lcp201Lbl = self.view.viewWithTag(2007) as? UILabel
                let lcp202Lbl = self.view.viewWithTag(2008) as? UILabel
                
                let lcp201 = Int(truncating: response![0] as! NSNumber)
                let lcp202 = Int(truncating: response![5] as! NSNumber)
                
                if lcp201 == 0 {
                    lcp201Lbl!.text = "OFF"
                } else if lcp201 == 1 {
                    lcp201Lbl!.text = "HAND"
                } else if lcp201 == 2 {
                    lcp201Lbl!.text = "AUTO"
                }
                
                if lcp202 == 0 {
                    lcp202Lbl!.text = "OFF"
                } else if lcp202 == 1 {
                    lcp202Lbl!.text = "HAND"
                } else if lcp202 == 2 {
                    lcp202Lbl!.text = "AUTO"
                }
            })
            CENTRAL_SYSTEM?.readBits(plcIpAddress:MITT_LAG_PLC_IP_ADDRESS, length: 6, startingRegister: Int32(LIGHTS_STATUS), completion: { (success, response) in
                
                guard response != nil else{
                    return
                }
                
                let lcp201Lbl = self.view.viewWithTag(2005) as? UILabel
                let lcp202Lbl = self.view.viewWithTag(2006) as? UILabel
                
                let lcp201 = Int(truncating: response![0] as! NSNumber)
                let lcp202 = Int(truncating: response![5] as! NSNumber)
                
                if lcp201 == 0 {
                    lcp201Lbl!.text = "OFF"
                } else if lcp201 == 1 {
                    lcp201Lbl!.text = "ON"
                }
                
                if lcp202 == 0 {
                    lcp202Lbl!.text = "OFF"
                } else if lcp202 == 1 {
                    lcp202Lbl!.text = "ON"
                }
            })
    }
    
    @IBAction func settingsButtonPressed(_ sender: UIButton) {
       self.addAlertAction(button: sender)
    }
}
