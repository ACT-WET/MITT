//=================================== ABOUT ===================================

/*
 *  @FILE:          WaterQualitySettingsViewController.swift
 *  @AUTHOR:        Arpi Derm
 *  @RELEASE_DATE:  July 28, 2017, 4:13 PM
 *  @Description:   This Module sets all timer settings for water quality 
 *                  sensors
 *  @VERSION:       2.0.0
 */

 /***************************************************************************
 *
 * PROJECT SPECIFIC CONFIGURATION
 *
 * 1 : Water Quality screen configuration parameters located in specs.swift file
 *     should be modified
 *
 ***************************************************************************/

import UIKit

class WaterQualitySettingsViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var w1close: UITextField!
    @IBOutlet weak var w1dose: UITextField!
    @IBOutlet weak var w1open: UITextField!
    @IBOutlet weak var orpDelayTimerTxt: UITextField!
    @IBOutlet weak var phDelayTimerTxt: UITextField!
    @IBOutlet weak var tdsDelayTimerTxt: UITextField!
    @IBOutlet weak var brominatorTimeoutTxt: UITextField!
    @IBOutlet weak var noConnectionView: UIView!
    @IBOutlet weak var noConnectionErrorLabel: UILabel!
    var featureId = 0
    private var centralSystem = CentralSystem()
    /***************************************************************************
     * Function :  viewDidLoad
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    override func viewDidLoad(){
        
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        constructSaveButton()
        if featureId == 1{
            centralSystem.getNetworkParameters()
            centralSystem.mittlagconnect()
            CENTRAL_SYSTEM = centralSystem
             NotificationCenter.default.addObserver(self, selector: #selector(checkLagoonSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
            getLagoonSetpoints()
        } else if featureId == 2{
            centralSystem.getNetworkParameters()
            centralSystem.mittlaconnect()
            CENTRAL_SYSTEM = centralSystem
             NotificationCenter.default.addObserver(self, selector: #selector(checkLakeSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
            getLakeSetpoints()
        }
        //Get initial setpoints from PLC
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    @objc func checkLakeSystemStat(){
        let (_,plcConnection,_,_) = (CENTRAL_SYSTEM?.getConnectivityStat())!
        
        if plcConnection == CONNECTION_STATE_CONNECTED {
            //Change the connection stat indicator
            noConnectionView.alpha = 0
            noConnectionView.isUserInteractionEnabled = false
            
        } else {
            noConnectionView.alpha = 1
            if plcConnection == CONNECTION_STATE_FAILED {
                noConnectionErrorLabel.text = "PLC CONNECTION FAILED, SERVER GOOD"
            } else if plcConnection == CONNECTION_STATE_CONNECTING {
                noConnectionErrorLabel.text = "CONNECTING TO PLC, SERVER CONNECTED"
            } else if plcConnection == CONNECTION_STATE_POOR_CONNECTION {
                noConnectionErrorLabel.text = "PLC POOR CONNECTION, SERVER CONNECTED"
            }
        }
    }
    
    @objc func checkLagoonSystemStat(){
        let (plcConnection,_,_,_) = (CENTRAL_SYSTEM?.getConnectivityStat())!
        
        if plcConnection == CONNECTION_STATE_CONNECTED {
            //Change the connection stat indicator
            noConnectionView.alpha = 0
            noConnectionView.isUserInteractionEnabled = false
            
        } else {
            noConnectionView.alpha = 1
            if plcConnection == CONNECTION_STATE_FAILED {
                noConnectionErrorLabel.text = "PLC CONNECTION FAILED, SERVER GOOD"
            } else if plcConnection == CONNECTION_STATE_CONNECTING {
                noConnectionErrorLabel.text = "CONNECTING TO PLC, SERVER CONNECTED"
            } else if plcConnection == CONNECTION_STATE_POOR_CONNECTION {
                noConnectionErrorLabel.text = "PLC POOR CONNECTION, SERVER CONNECTED"
            }
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.endEditing(false)
    }
    
    

    /***************************************************************************
     * Function :  constructSaveButton
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    private func constructSaveButton(){
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "SAVE", style: .plain, target: self, action: #selector(saveSetpoints))
        
    }

    /***************************************************************************
     * Function :  getSetpoints
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    private func getLagoonSetpoints(){
        
        //Get all Sensor Scale MIN/MAX Values from PLC
        
        readScaleMinMaxSensorDataFromPLC()
        
        //Get WQ Delay Timer Setpoints
        
        CENTRAL_SYSTEM?.readRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, length: 3, startingRegister: Int32(WQ_PH_TIMER_REGISTER), completion:{ (success, response) in
            
            if success == true{
                
                let PHSetpoint  = Int(truncating: response![0] as! NSNumber)
                let ORPSetpoint = Int(truncating: response![1] as! NSNumber)
                let TDSSetpoint = Int(truncating: response![2] as! NSNumber)
                
                self.orpDelayTimerTxt.text = ORPSetpoint.description
                self.phDelayTimerTxt.text = PHSetpoint.description
                self.tdsDelayTimerTxt.text = TDSSetpoint.description
                
            }
        })
        
        CENTRAL_SYSTEM?.readRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, length: 3, startingRegister: Int32(WQ_BR_TIMER_REGISTER), completion:{ (success, response) in
            
            if success == true{
                
                let w1opnval = Int(truncating: response![0] as! NSNumber)
                let w1dseval = Int(truncating: response![1] as! NSNumber)
                let w1clsval = Int(truncating: response![2] as! NSNumber)
                
                self.w1open.text  = "\(w1opnval)"
                self.w1dose.text  = "\(w1dseval)"
                self.w1close.text = "\(w1clsval)"
            }
        })
        //Get Brominator Timeout Setpoints
        
        CENTRAL_SYSTEM?.readRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, length: 1, startingRegister: Int32(WQ_BROMINATOR_TIMEOUT_REGISTER), completion: { (success, response) in
            
            if success == true{
                let brominatorTimeout = Int(truncating: response![0] as! NSNumber)
                self.brominatorTimeoutTxt.text = brominatorTimeout.description
            }
        })
        
    }
    
    private func getLakeSetpoints(){
        
        //Get all Sensor Scale MIN/MAX Values from PLC
        
        readScaleMinMaxSensorDataFromPLC()
        
        //Get WQ Delay Timer Setpoints
        
        CENTRAL_SYSTEM?.readRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, length: 3, startingRegister: Int32(WQ_PH_TIMER_REGISTER), completion:{ (success, response) in
            
            if success == true{
                
                let PHSetpoint  = Int(truncating: response![0] as! NSNumber)
                let ORPSetpoint = Int(truncating: response![1] as! NSNumber)
                let TDSSetpoint = Int(truncating: response![2] as! NSNumber)
                
                self.orpDelayTimerTxt.text = ORPSetpoint.description
                self.phDelayTimerTxt.text = PHSetpoint.description
                self.tdsDelayTimerTxt.text = TDSSetpoint.description
                
            }
        })
        
        CENTRAL_SYSTEM?.readRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, length: 3, startingRegister: Int32(WQ_BR_TIMER_REGISTER), completion:{ (success, response) in
            
            if success == true{
                
                let w1opnval = Int(truncating: response![0] as! NSNumber)
                let w1dseval = Int(truncating: response![1] as! NSNumber)
                let w1clsval = Int(truncating: response![2] as! NSNumber)
                
                self.w1open.text  = "\(w1opnval)"
                self.w1dose.text  = "\(w1dseval)"
                self.w1close.text = "\(w1clsval)"
            }
        })
        //Get Brominator Timeout Setpoints
        
        CENTRAL_SYSTEM?.readRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, length: 1, startingRegister: Int32(WQ_BROMINATOR_TIMEOUT_REGISTER), completion: { (success, response) in
            
            if success == true{
                let brominatorTimeout = Int(truncating: response![0] as! NSNumber)
                self.brominatorTimeoutTxt.text = brominatorTimeout.description
            }
        })
        
    }
    
    
    /***************************************************************************
     * Function :  readScaleMinMaxSensorDataFromPLC
     * Input    :  none
     * Output   :  none
     * Comment  :  Reads all the scale min and max values from PLC for each sensor
     ***************************************************************************/
    
    private func readScaleMinMaxSensorDataFromPLC(){
        
        var sensorCount = 0
        
        while sensorCount < 3 {
            
            //We want to dynamically get the PLC addresses insread of calling the read function evey time one after another.
            //To get an idea of what are the PLC address we are trying to calculate here, please review WaterQualitySpecs.swift file
            //It will explain the pattern between individual scale values which justifies the following equation
            
            let PLCAddr_MIN = WQ_SCALE_MIN+(sensorCount*10)
            
            if featureId == 1{
                CENTRAL_SYSTEM?.readRealRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: PLCAddr_MIN, length: 2, completion: { (success, response) in
                    guard success == true else { return }
                    let sensorRawValue = self.view.viewWithTag(PLCAddr_MIN) as? UILabel
                    sensorRawValue?.text = response
                    
                })
                
                let PLCAddr_MAX = WQ_SCALE_MAX+(sensorCount*10)

                CENTRAL_SYSTEM?.readRealRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: PLCAddr_MAX, length: 2, completion: { (success, response) in
                    guard success == true else { return }
                    let sensorRawValue = self.view.viewWithTag(PLCAddr_MAX) as? UILabel
                    sensorRawValue?.text = response
                    
                })
                sensorCount = sensorCount+1;
            }
            
            if featureId == 2{
                CENTRAL_SYSTEM?.readRealRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: PLCAddr_MIN, length: 2, completion: { (success, response) in
                    guard success == true else { return }
                    let sensorRawValue = self.view.viewWithTag(PLCAddr_MIN) as? UILabel
                    sensorRawValue?.text = response
                    
                })
                
                let PLCAddr_MAX = WQ_SCALE_MAX+(sensorCount*10)

                CENTRAL_SYSTEM?.readRealRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: PLCAddr_MAX, length: 2, completion: { (success, response) in
                    guard success == true else { return }
                    let sensorRawValue = self.view.viewWithTag(PLCAddr_MAX) as? UILabel
                    sensorRawValue?.text = response
                    
                })
                sensorCount = sensorCount+1;
            }
        }
        
    }
    
    /***************************************************************************
     * Function :  saveSetpoints
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    @objc private func saveSetpoints(){
        
        saveSetpointDelaysToPLC()
        
    }
    
    /***************************************************************************
     * Function :  saveSetpointDelaysToPLC
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    private func saveSetpointDelaysToPLC(){
        
        let oprDelayTimerSP     = Int(orpDelayTimerTxt.text!)
        let phDelayTimerSP      = Int(phDelayTimerTxt.text!)
        let tdsDelayTimerSP     = Int(tdsDelayTimerTxt.text!)
        let brominatorTimeoutSP = Int(brominatorTimeoutTxt.text!)
        
       let w1openVal      = Int(w1open.text!)
       let w1doseVal      = Int(w1dose.text!)
       let w1closeVal     = Int(w1close.text!)
        
        //Checkpoints to make sure setpoint inputs are not empty
        guard oprDelayTimerSP != nil && phDelayTimerSP != nil && tdsDelayTimerSP != nil && brominatorTimeoutSP != nil && w1openVal != nil && w1closeVal != nil && w1doseVal != nil else { return }
        if featureId == 1{
           CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: WQ_ORP_TIMER_REGISTER, value: oprDelayTimerSP!)
           CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: WQ_PH_TIMER_REGISTER, value: phDelayTimerSP!)
           CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: WQ_TDS_TIMER_REGISTER, value: tdsDelayTimerSP!)
           CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: WQ_BROMINATOR_TIMEOUT_REGISTER, value: brominatorTimeoutSP!)
           
           CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: WQ_BR_TIMER_REGISTER, value: w1openVal!)
           CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: WQ_BR_TIMER_REGISTER+1, value: w1doseVal!)
           CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: WQ_BR_TIMER_REGISTER+2, value: w1closeVal!)
           
           DispatchQueue.main.asyncAfter(deadline: .now() + 0.50) {
               self.getLagoonSetpoints()
           }
        }
        if featureId == 2{
           CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: WQ_ORP_TIMER_REGISTER, value: oprDelayTimerSP!)
           CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: WQ_PH_TIMER_REGISTER, value: phDelayTimerSP!)
           CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: WQ_TDS_TIMER_REGISTER, value: tdsDelayTimerSP!)
           CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: WQ_BROMINATOR_TIMEOUT_REGISTER, value: brominatorTimeoutSP!)
           
           CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: WQ_BR_TIMER_REGISTER, value: w1openVal!)
           CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: WQ_BR_TIMER_REGISTER+1, value: w1doseVal!)
           CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: WQ_BR_TIMER_REGISTER+2, value: w1closeVal!)
           
           DispatchQueue.main.asyncAfter(deadline: .now() + 0.50) {
               self.getLakeSetpoints()
           }
        }

    }

}
