//
//  PumpSettingsViewController.swift
//  iPadControls
//
//  Created by Arpi Derm on 12/28/16.
//  Copyright © 2016 WET. All rights reserved.
//

import UIKit

class PumpSettingsViewController: UIViewController{

    @IBOutlet weak var maxFrequency: UITextField!
    @IBOutlet weak var maxTemperature: UITextField!
    @IBOutlet weak var midTemperature: UITextField!
    @IBOutlet weak var maxVoltage: UITextField!
    @IBOutlet weak var minVoltage: UITextField!
    @IBOutlet weak var maxCurrent: UITextField!
    
    @IBOutlet weak var pressDelay: UITextField!
    @IBOutlet weak var noConnectionView: UIView!
    @IBOutlet weak var noConnectionLbl: UILabel!
    
    //Object References
    let logger = Logger()
    
    //Show stoppers tructure
    var showStopper = ShowStoppers()
    
    //Selected Pump Number and Details
    var pumpDetails:PumpDetail?

    
    //MARK: - View Life Cycle
    
    override func viewDidLoad(){
        
        super.viewDidLoad()
    
    }

    
    //MARK: - View Did Appear
    
    override func viewWillAppear(_ animated: Bool){
        
        var pumpDetail = PumpDetail.query(["pumpNumber":1]) as! [PumpDetail]
        
        guard pumpDetail.count != 0 else{
            return
        }
        
        pumpDetails = pumpDetail[0] as PumpDetail
        
        self.getCurrentSetpoints()
        self.constructSaveButton()
        
        //Add notification observer to get system stat
        NotificationCenter.default.addObserver(self, selector: #selector(checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Get Current Setpoints
    
    private func getCurrentSetpoints(){
         
       guard let maxFreq = UserDefaults.standard.object(forKey: "defaultmaxFreq") as? Float else { return }
       guard let maxCurrent = UserDefaults.standard.object(forKey: "defaultmaxCurrent") as? Float else { return }
       guard let maxVltg = UserDefaults.standard.object(forKey: "defaultmaxVoltage") as? Float else { return }
       guard let minVltg = UserDefaults.standard.object(forKey: "defaultminVoltage") as? Float else { return }
       guard let maxTemp = UserDefaults.standard.object(forKey: "defaultmaxTemp") as? Float else { return }
       guard let midTemp = UserDefaults.standard.object(forKey: "defaultmidTemp") as? Float else { return }
       
       self.maxFrequency.text = "\(maxFreq)"
       self.maxCurrent.text = "\(maxCurrent)"
       self.maxVoltage.text = "\(maxVltg)"
       self.minVoltage.text = "\(minVltg)"
       self.maxTemperature.text = "\(maxTemp)"
       self.midTemperature.text = "\(midTemp)"
        
        CENTRAL_SYSTEM?.readRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, length: 1, startingRegister: Int32(PRESSURE_DELAYTIMER), completion:{ (success, response) in
            
            guard success == true else { return }
            
            let pressValue = Int(truncating: response![0] as! NSNumber)
            self.pressDelay.text = "\(pressValue)"
            
        })
    }
    
    
    //MARK: - Construct Save bar button item
    
    private func constructSaveButton(){
    
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "SAVE", style: .plain, target: self, action: #selector(savePumpSettings))

    }

    @objc func checkSystemStat(){
        let (plcConnection,_,_,_) = (CENTRAL_SYSTEM?.getConnectivityStat())!
        
        if plcConnection == CONNECTION_STATE_CONNECTED {
            //Change the connection stat indicator
            noConnectionView.alpha = 0
            noConnectionView.isUserInteractionEnabled = false
            
        } else {
            noConnectionView.alpha = 1
            if plcConnection == CONNECTION_STATE_FAILED {
                noConnectionLbl.text = "PLC CONNECTION FAILED, SERVER GOOD"
            } else if plcConnection == CONNECTION_STATE_CONNECTING {
                noConnectionLbl.text = "CONNECTING TO PLC, SERVER CONNECTED"
            } else if plcConnection == CONNECTION_STATE_POOR_CONNECTION {
                noConnectionLbl.text = "PLC POOR CONNECTION, SERVER CONNECTED"
            }
        }
    }
    
    
    //MARK: - Pressure Delay Setpoint
    
    @objc private func savePumpSettings(){
       
          //MAX_FREQUENCY_SP = 2000
          //MAX_TEMPERATURE_SP = 2002
          //MID_TEMPERATURE_SP = 2004
          //MAX_VOLTAGE_SP = 2008
          //MIN_VOLTAGE_SP = 2010
          //MAX_CURRENT_SP = 2012

          let maxFrequency = Float(self.maxFrequency.text!)
          let maxTemperature = Float(self.maxTemperature.text!)
          let midTemperature = Float(self.midTemperature.text!)
          let maxVoltage = Float(self.maxVoltage.text!)
          let minVoltage = Float(self.minVoltage.text!)
          let maxCurrent = Float(self.maxCurrent.text!)
          let pressure = Int(self.pressDelay.text!)

          guard maxFrequency != nil && maxTemperature != nil && midTemperature != nil && maxVoltage != nil && minVoltage != nil && maxCurrent != nil && pressure != nil else{
              self.logger.logData(data: "INVALID OR NO INPUT IN ONE OR MORE SETPOINT FIELDS")
              return
          }
          
        CENTRAL_SYSTEM!.writeRealValue(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: MAX_FREQUENCY_SP, value: maxFrequency!)
          CENTRAL_SYSTEM!.writeRealValue(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: MAX_TEMPERATURE_SP, value: maxTemperature!)
          CENTRAL_SYSTEM!.writeRealValue(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: MID_TEMPERATURE_SP, value: midTemperature!)
          CENTRAL_SYSTEM!.writeRealValue(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: MAX_VOLTAGE_SP, value: maxVoltage!)
          CENTRAL_SYSTEM!.writeRealValue(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: MIN_VOLTAGE_SP, value: minVoltage!)
          CENTRAL_SYSTEM!.writeRealValue(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: MAX_CURRENT_SP, value: maxCurrent!)
          CENTRAL_SYSTEM!.writeRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: PRESSURE_DELAYTIMER, value: pressure!)
          UserDefaults.standard.set(maxCurrent!, forKey: "defaultmaxCurrent")
          UserDefaults.standard.set(maxFrequency!, forKey: "defaultmaxFreq")
          UserDefaults.standard.set(maxTemperature!, forKey: "defaultmaxTemp")
          UserDefaults.standard.set(midTemperature!, forKey: "defaultmidTemp")
          UserDefaults.standard.set(maxVoltage!, forKey: "defaultmaxVoltage")
          UserDefaults.standard.set(minVoltage!, forKey: "defaultminVoltage")
          UserDefaults.standard.synchronize()
    }

}
