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
    @IBOutlet weak var autoHandIndicator: UIImageView!
    @IBOutlet weak var autoHandBtn: UIButton!
    @IBOutlet weak var manualControlLightsBtn: UIButton!
    @IBOutlet weak var manualControl2LightsBtn: UIButton!
    @IBOutlet weak var schedulerContainerView: UIView!
    @IBOutlet weak var lowWaterNoLights: UIImageView!
    @IBOutlet weak var manualLights1: UILabel!
    @IBOutlet weak var manualLights2: UILabel!
    
    private let logger = Logger()
    private let httpComm = HTTPComm()
    private var langData = Dictionary<String, String>()
    private let helper = Helper()
    private var dayModeStatus = 0
    var waterLevelBelowLFault = 0
    var lightType = 0
    var featureId = 0
    var lightState = 0
    var lightOnOff = 0
    var light2OnOff = 0
    private let showManager  = ShowManager()
    
    override func viewWillAppear(_ animated: Bool) {
        //Add notification observer to get system stat
        
        if featureId == 1{
            if lightType == 11{
                self.navigationItem.title = "PRISMA LIGHTS"
                self.manualLights1.text = "LCP PRSIMA"
            } else if lightType == 33{
                self.navigationItem.title = "STROBESTARS LIGHTS"
                self.manualLights1.text = "LCP STROBESTARS"
            }
            self.manualControl2LightsBtn.isHidden = true
            self.manualLights2.isHidden = true
            NotificationCenter.default.addObserver(self, selector: #selector(checkLagoonSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
        }
        if featureId == 2{
            if lightType == 11{
                self.navigationItem.title = "PICO BLANCO LIGHTS"
                self.manualLights1.text = "LCP - 901"
                self.manualLights2.text = "LCP - 902"
            }
            self.manualControl2LightsBtn.isHidden = false
            self.manualLights2.isHidden = false
            NotificationCenter.default.addObserver(self, selector: #selector(checkLakeSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
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
    
    @objc func checkLakeSystemStat(){
        let (_,plcConnection,_,serverConnection) = CENTRAL_SYSTEM!.getConnectivityStat()
        
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
        if featureId == 1 {
            CENTRAL_SYSTEM?.readBits(plcIpAddress:MITT_LAG_PLC_IP_ADDRESS, length: 1, startingRegister: Int32(WATER_LEVEL_BELOW_L), completion: { (success, response) in
                
                guard response != nil else{
                    return
                }
                self.waterLevelBelowLFault = Int(truncating: response![0] as! NSNumber)
                
                if self.waterLevelBelowLFault == 1 {
                    self.lowWaterNoLights.isHidden = false
                } else {
                    self.lowWaterNoLights.isHidden = true
                }
            })
            if lightType == 11{
                CENTRAL_SYSTEM?.readBits(plcIpAddress:MITT_LAG_PLC_IP_ADDRESS, length: 1, startingRegister: Int32(LIGHTS_AUTO_HAND_PLC_REGISTER), completion: { (success, response) in
                    
                    guard response != nil else{
                        return
                    }
                    self.lightState = Int(truncating: response![0] as! NSNumber)
                    
                    if self.lightState == 1 {
                        self.autoHandIndicator.image = #imageLiteral(resourceName: "handMode")
                        self.changeAutManModeIndicatorRotation(autoMode: false)
                        self.schedulerContainerView.isHidden = true
                    } else if self.lightState == 0 {
                        self.autoHandIndicator.image = #imageLiteral(resourceName: "autoMode")
                        self.changeAutManModeIndicatorRotation(autoMode: true)
                        self.schedulerContainerView.isHidden = false
                    }
                })
                CENTRAL_SYSTEM?.readBits(plcIpAddress:MITT_LAG_PLC_IP_ADDRESS, length: 1, startingRegister: Int32(LIGHTS_STATUS), completion: { (success, response) in
                    
                    guard response != nil else{
                        return
                    }
                    self.lightOnOff = Int(truncating: response![0] as! NSNumber)
                    
                    if self.lightOnOff == 0 {
                        self.autoHandBtn.setBackgroundImage(#imageLiteral(resourceName: "lights"), for: .normal)
                        self.manualControlLightsBtn.setBackgroundImage(#imageLiteral(resourceName: "lights"), for: .normal)
                    } else if self.lightOnOff == 1 {
                        self.autoHandBtn.setBackgroundImage(#imageLiteral(resourceName: "lights_on"), for: .normal)
                        self.manualControlLightsBtn.setBackgroundImage(#imageLiteral(resourceName: "lights_on"), for: .normal)
                    }
                })
            } else if lightType == 33{
               CENTRAL_SYSTEM?.readBits(plcIpAddress:MITT_LAG_PLC_IP_ADDRESS, length: 1, startingRegister: Int32(STROBE_LIGHTS_AUTO_HAND_PLC_REGISTER), completion: { (success, response) in
                    
                    guard response != nil else{
                        return
                    }
                    self.lightState = Int(truncating: response![0] as! NSNumber)
                    
                    if self.lightState == 1 {
                        self.autoHandIndicator.image = #imageLiteral(resourceName: "handMode")
                        self.changeAutManModeIndicatorRotation(autoMode: false)
                        self.schedulerContainerView.isHidden = true
                    } else if self.lightState == 0 {
                        self.autoHandIndicator.image = #imageLiteral(resourceName: "autoMode")
                        self.changeAutManModeIndicatorRotation(autoMode: true)
                        self.schedulerContainerView.isHidden = false
                    }
                })
                CENTRAL_SYSTEM?.readBits(plcIpAddress:MITT_LAG_PLC_IP_ADDRESS, length: 1, startingRegister: Int32(STROBE_LIGHTS_STATUS), completion: { (success, response) in
                    
                    guard response != nil else{
                        return
                    }
                    self.lightOnOff = Int(truncating: response![0] as! NSNumber)
                    
                    if self.lightOnOff == 0 {
                        self.autoHandBtn.setBackgroundImage(#imageLiteral(resourceName: "lights"), for: .normal)
                        self.manualControlLightsBtn.setBackgroundImage(#imageLiteral(resourceName: "lights"), for: .normal)
                    } else if self.lightOnOff == 1 {
                        self.autoHandBtn.setBackgroundImage(#imageLiteral(resourceName: "lights_on"), for: .normal)
                        self.manualControlLightsBtn.setBackgroundImage(#imageLiteral(resourceName: "lights_on"), for: .normal)
                    }
                })
            }
        }
        
        
        if featureId == 2 {
            CENTRAL_SYSTEM?.readBits(plcIpAddress:MITT_LA_PLC_IP_ADDRESS, length: 4, startingRegister: Int32(GLIMMER_WATER_LEVEL_BELOW_L), completion: { (success, response) in
                
                guard response != nil else{
                    return
                }
                
                let resp1 = Int(truncating: response![0] as! NSNumber)
                let resp2 = Int(truncating: response![1] as! NSNumber)
                let resp3 = Int(truncating: response![2] as! NSNumber)
                let resp4 = Int(truncating: response![3] as! NSNumber)
                
                self.waterLevelBelowLFault = resp1 + resp2 + resp3 + resp4
                
                if self.waterLevelBelowLFault > 0 {
                    self.lowWaterNoLights.isHidden = false
                } else {
                    self.lowWaterNoLights.isHidden = true
                }
            })
            CENTRAL_SYSTEM?.readBits(plcIpAddress:MITT_LA_PLC_IP_ADDRESS, length: 1, startingRegister: Int32(GLIMMER_AUTO_HAND_PLC_REGISTER), completion: { (success, response) in
                
                guard response != nil else{
                    return
                }
                self.lightState = Int(truncating: response![0] as! NSNumber)
                
                if self.lightState == 1 {
                    self.autoHandIndicator.image = #imageLiteral(resourceName: "handMode")
                    self.changeAutManModeIndicatorRotation(autoMode: false)
                    self.schedulerContainerView.isHidden = true
                } else if self.lightState == 0 {
                    self.autoHandIndicator.image = #imageLiteral(resourceName: "autoMode")
                    self.changeAutManModeIndicatorRotation(autoMode: true)
                    self.schedulerContainerView.isHidden = false
                }
            })
            CENTRAL_SYSTEM?.readBits(plcIpAddress:MITT_LA_PLC_IP_ADDRESS, length: 3, startingRegister: Int32(GLIMPICO_STATUS), completion: { (success, response) in
                
                guard response != nil else{
                    return
                }
                self.lightOnOff = Int(truncating: response![0] as! NSNumber)
                self.light2OnOff = Int(truncating: response![2] as! NSNumber)
                
                if self.lightOnOff == 0 && self.light2OnOff == 0 {
                    self.autoHandBtn.setBackgroundImage(#imageLiteral(resourceName: "lights"), for: .normal)
                } else {
                    self.autoHandBtn.setBackgroundImage(#imageLiteral(resourceName: "lights_on"), for: .normal)
                }
                
                if self.lightOnOff == 1 {
                    self.manualControlLightsBtn.setBackgroundImage(#imageLiteral(resourceName: "lights_on"), for: .normal)
                } else if self.lightOnOff == 0 {
                    self.manualControlLightsBtn.setBackgroundImage(#imageLiteral(resourceName: "lights"), for: .normal)
                }
                if self.light2OnOff == 1 {
                    self.manualControl2LightsBtn.setBackgroundImage(#imageLiteral(resourceName: "lights_on"), for: .normal)
                } else if self.light2OnOff == 0 {
                    self.manualControl2LightsBtn.setBackgroundImage(#imageLiteral(resourceName: "lights"), for: .normal)
                }
            })
        }
    }
    
    func changeAutManModeIndicatorRotation(autoMode:Bool){
        
        if autoMode == true{
             autoHandIndicator.rotate360Degrees(animate: true)
        }else{
             autoHandIndicator.rotate360Degrees(animate: false)
        }
        
    }
    
    @IBAction func toggleAutoHandMode(_ sender: UIButton) {
        if featureId == 1{
            if lightType == 11{
                if self.lightState == 1 {
                     CENTRAL_SYSTEM?.writeBit(plcIpAddress:MITT_LAG_PLC_IP_ADDRESS, bit: LIGHTS_AUTO_HAND_PLC_REGISTER, value: 0)
                } else if self.lightState == 0 {
                     CENTRAL_SYSTEM?.writeBit(plcIpAddress:MITT_LAG_PLC_IP_ADDRESS, bit: LIGHTS_AUTO_HAND_PLC_REGISTER, value: 1)
                }
            } else if lightType == 33{
                if self.lightState == 1 {
                     CENTRAL_SYSTEM?.writeBit(plcIpAddress:MITT_LAG_PLC_IP_ADDRESS, bit: STROBE_LIGHTS_AUTO_HAND_PLC_REGISTER, value: 0)
                } else if self.lightState == 0 {
                     CENTRAL_SYSTEM?.writeBit(plcIpAddress:MITT_LAG_PLC_IP_ADDRESS, bit: STROBE_LIGHTS_AUTO_HAND_PLC_REGISTER, value: 1)
                }
            }
        }
        if featureId == 2{
            if lightType == 11{
                if self.lightState == 1 {
                     CENTRAL_SYSTEM?.writeBit(plcIpAddress:MITT_LA_PLC_IP_ADDRESS, bit: GLIMMER_AUTO_HAND_PLC_REGISTER, value: 0)
                } else if self.lightState == 0 {
                     CENTRAL_SYSTEM?.writeBit(plcIpAddress:MITT_LA_PLC_IP_ADDRESS, bit: GLIMMER_AUTO_HAND_PLC_REGISTER, value: 1)
                }
            }
        }
    }
    //MARK: - Turn On/Off Lights Manually
    @IBAction func toggleLightsOnOff(_ sender: UIButton) {
        if featureId == 1{
            if waterLevelBelowLFault == 1 {
                    let alert = UIAlertController(title: "ALERT", message: "Lights Disabled due to Low Water Level ", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    if lightType == 11{
                        if self.lightOnOff == 1 {
                             CENTRAL_SYSTEM?.writeBit(plcIpAddress:MITT_LAG_PLC_IP_ADDRESS, bit: LIGHTS_ON_OFF_WRITE_REGISTERS, value: 0)
                        } else if self.lightOnOff == 0 {
                             CENTRAL_SYSTEM?.writeBit(plcIpAddress:MITT_LAG_PLC_IP_ADDRESS, bit: LIGHTS_ON_OFF_WRITE_REGISTERS, value: 1)
                        }
                    } else if lightType == 33{
                        if self.lightOnOff == 1 {
                             CENTRAL_SYSTEM?.writeBit(plcIpAddress:MITT_LAG_PLC_IP_ADDRESS, bit: STROBE_LIGHTS_ON_OFF_WRITE_REGISTERS, value: 0)
                        } else if self.lightOnOff == 0 {
                             CENTRAL_SYSTEM?.writeBit(plcIpAddress:MITT_LAG_PLC_IP_ADDRESS, bit: STROBE_LIGHTS_ON_OFF_WRITE_REGISTERS, value: 1)
                        }
                    }
                }
            }
        if featureId == 2{
            if waterLevelBelowLFault == 1 {
                    let alert = UIAlertController(title: "ALERT", message: "Lights Disabled due to Low Water Level ", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                if sender.tag == 11{
                        if self.lightOnOff == 1 {
                             CENTRAL_SYSTEM?.writeBit(plcIpAddress:MITT_LA_PLC_IP_ADDRESS, bit: GLIMPICO_ON_OFF_WRITE_REGISTERS, value: 0)
                        } else if self.lightOnOff == 0 {
                             CENTRAL_SYSTEM?.writeBit(plcIpAddress:MITT_LA_PLC_IP_ADDRESS, bit: GLIMPICO_ON_OFF_WRITE_REGISTERS, value: 1)
                        }
                    }
                if sender.tag == 33{
                    if self.light2OnOff == 1 {
                         CENTRAL_SYSTEM?.writeBit(plcIpAddress:MITT_LA_PLC_IP_ADDRESS, bit: GLIMZEPTO_ON_OFF_WRITE_REGISTERS, value: 0)
                    } else if self.light2OnOff == 0 {
                         CENTRAL_SYSTEM?.writeBit(plcIpAddress:MITT_LA_PLC_IP_ADDRESS, bit: GLIMZEPTO_ON_OFF_WRITE_REGISTERS, value: 1)
                    }
                }
            }
        }
    }
}
