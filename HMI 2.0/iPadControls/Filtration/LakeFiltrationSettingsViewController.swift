//
//  AlightFiltrationSettingsViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 12/24/22.
//  Copyright © 2022 WET. All rights reserved.
//

import UIKit

class LakeFiltrationSettingsViewController: UIViewController {

 
    @IBOutlet weak var bwDuration: UITextField!
    @IBOutlet weak var valveOpenClose: UITextField!
    @IBOutlet weak var noConnectionView: UIView!
    @IBOutlet weak var noConnectionErrorLbl: UILabel!
    
    @IBOutlet weak var pdshDelay: UITextField!
    @IBOutlet weak var fanDelay: UITextField!
    @IBOutlet weak var pt1001scalMax: UITextField!
    @IBOutlet weak var pt1002scalMax: UITextField!
    @IBOutlet weak var pt1003scalMax: UITextField!
    @IBOutlet weak var pt1001scalMin: UITextField!
    @IBOutlet weak var pt1002scalMin: UITextField!
    @IBOutlet weak var pt1003scalMin: UITextField!
    @IBOutlet weak var cleanStrSP: UITextField!
    @IBOutlet weak var pumpOFFSP: UITextField!
    @IBOutlet weak var bwPressSP: UITextField!
    private var readSettings = true
    private var centralSystem = CentralSystem()
    //MARK: - View Life Cycle
    
    override func viewDidLoad(){
        
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        centralSystem.getNetworkParameters()
        centralSystem.mittlaconnect()
        CENTRAL_SYSTEM = centralSystem
        constructSaveButton()
        
        //Add notification observer to get system stat
        NotificationCenter.default.addObserver(self, selector: #selector(checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
        readValues()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @objc func checkSystemStat(){
        let (_,plcConnection,_,_) = CENTRAL_SYSTEM!.getConnectivityStat()
        
        if plcConnection == CONNECTION_STATE_CONNECTED {
            
            //Change the connection stat indicator
            noConnectionView.alpha = 0
            
        } else {
            noConnectionView.alpha = 1
            if plcConnection == CONNECTION_STATE_FAILED {
                noConnectionErrorLbl.text = "PLC CONNECTION FAILED, SERVER GOOD"
            } else if plcConnection == CONNECTION_STATE_CONNECTING {
                noConnectionErrorLbl.text = "CONNECTING TO PLC, SERVER CONNECTED"
            } else if plcConnection == CONNECTION_STATE_POOR_CONNECTION {
                noConnectionErrorLbl.text = "PLC POOR CONNECTION, SERVER CONNECTED"
            }
        }
    }
    //MARK: - Construct Save bar button item
    
    private func constructSaveButton(){
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "SAVE", style: .plain, target: self, action: #selector(saveSetpoints))
        
    }
    
    
    private func readValues() {
        CENTRAL_SYSTEM?.readRealRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: Int(PT1001_SCALEDMIN), length: 2, completion: { (success, response) in
           guard success == true else { return }
           let val = Double(response)
           self.pt1001scalMin.text =  String(format: "%.1f", val!)
        })
        CENTRAL_SYSTEM?.readRealRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: Int(PT1002_SCALEDMIN), length: 2, completion: { (success, response) in
           guard success == true else { return }
           let val = Double(response)
           self.pt1002scalMin.text =  String(format: "%.1f", val!)
        })
        CENTRAL_SYSTEM?.readRealRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: Int(PT1003_SCALEDMIN), length: 2, completion: { (success, response) in
           guard success == true else { return }
           let val = Double(response)
           self.pt1003scalMin.text =  String(format: "%.1f", val!)
        })
        CENTRAL_SYSTEM?.readRealRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: Int(PT1001_SCALEDMAX), length: 2, completion: { (success, response) in
           guard success == true else { return }
           let val = Double(response)
           self.pt1001scalMax.text =  String(format: "%.1f", val!)
        })
        CENTRAL_SYSTEM?.readRealRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: Int(PT1002_SCALEDMAX), length: 2, completion: { (success, response) in
           guard success == true else { return }
           let val = Double(response)
           self.pt1002scalMax.text =  String(format: "%.1f", val!)
        })
        CENTRAL_SYSTEM?.readRealRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: Int(PT1003_SCALEDMAX), length: 2, completion: { (success, response) in
           guard success == true else { return }
           let val = Double(response)
           self.pt1003scalMax.text =  String(format: "%.1f", val!)
        })
        CENTRAL_SYSTEM?.readRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, length: 3, startingRegister: Int32(FILTRATION_PDSH_DELAY), completion: { (success, response) in
            
            guard success == true else { return }
            
            CENTRAL_SYSTEM?.readRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, length: 1, startingRegister: Int32(FAN_HELD_DELAY), completion: { (success, reponse) in
                
                guard success == true else { return }
                
                let fanD = Int(truncating: reponse![0] as! NSNumber)
                let pdsh = Int(truncating: response![0] as! NSNumber)
                let bwDuration = Int(truncating: response![1] as! NSNumber)
                let valveOpenCloseValue = Int(truncating: response![2] as! NSNumber)
                
                self.pdshDelay.text = "\(pdsh)"
                self.bwDuration.text = "\(bwDuration)"
                self.valveOpenClose.text = "\(valveOpenCloseValue)"
                self.fanDelay.text = "\(fanD)"
            })
        })
        CENTRAL_SYSTEM?.readRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, length: 3, startingRegister: Int32(CLEANSTR_SP), completion: { (success, response) in
            
            guard success == true else { return }
            
            let cleanSP = Int(truncating: response![0] as! NSNumber)
            let pmpOFFSP = Int(truncating: response![1] as! NSNumber)
            let bwPressSP = Int(truncating: response![2] as! NSNumber)
            
            self.cleanStrSP.text = "\(cleanSP)"
            self.pumpOFFSP.text = "\(pmpOFFSP)"
            self.bwPressSP.text = "\(bwPressSP)"
        })
        
        
    }
    
    
    
    //MARK: - Save  Setpoints
    
    @objc private func saveSetpoints(){
        guard let backwashDurationText = bwDuration.text,
            let backWashValue = Int(backwashDurationText),
            let pdshText = pdshDelay.text,
            let pdshvalue = Int(pdshText),
            let valveOpenCloseText = valveOpenClose.text,
            let valveOpenCloseValue = Int(valveOpenCloseText),
            let fanText = fanDelay.text,
            let fanValue = Int(fanText),
            let bwPressTxt = bwPressSP.text,
            let bwPressVal = Int(bwPressTxt),
            let cleanSPTxt = cleanStrSP.text,
            let cleanSPVal = Int(cleanSPTxt),
            let pmpOFFTxt = pumpOFFSP.text,
            let pmpOFFVal = Int(pmpOFFTxt),
            let pt1001scalMin = Float(pt1001scalMin.text!),
            let pt1002scalMin = Float(pt1002scalMin.text!),
            let pt1003scalMin = Float(pt1003scalMin.text!),
            let pt1001scalMax = Float(pt1001scalMax.text!),
            let pt1002scalMax = Float(pt1002scalMax.text!),
            let pt1003scalMax = Float(pt1003scalMax.text!) else { return }
        
        CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: FILTRATION_BW_DURATION_REGISTER, value: backWashValue)
        CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: FILTRATION_PDSH_DELAY, value: pdshvalue)
        CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: FILTRATION_VALVE_OPEN_CLOSE_TIME_BIT, value: valveOpenCloseValue)
        CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: FAN_HELD_DELAY, value: fanValue)
        
        CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: CLEANSTR_SP, value: cleanSPVal)
        CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: FILTER_PUMPOFF_SP, value: pmpOFFVal)
        CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: BW_PRESS_SP, value: bwPressVal)
        
        CENTRAL_SYSTEM!.writeRealValue(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: PT1001_SCALEDMIN, value: pt1001scalMin)
        CENTRAL_SYSTEM!.writeRealValue(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: PT1002_SCALEDMIN, value: pt1002scalMin)
        CENTRAL_SYSTEM!.writeRealValue(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: PT1003_SCALEDMIN, value: pt1003scalMin)
        CENTRAL_SYSTEM!.writeRealValue(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: PT1001_SCALEDMAX, value: pt1001scalMax)
        CENTRAL_SYSTEM!.writeRealValue(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: PT1002_SCALEDMAX, value: pt1002scalMax)
        CENTRAL_SYSTEM!.writeRealValue(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: PT1003_SCALEDMAX, value: pt1003scalMax)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.readValues()
        }
    }
}
