//
//  OzonePopupViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 4/9/19.
//  Copyright © 2019 WET. All rights reserved.
//

import UIKit

class OzonePopupViewController: UIViewController {
    
    
    @IBOutlet weak var pumpFault: UILabel!
    @IBOutlet weak var motorOverload: UILabel!
    @IBOutlet weak var pressureFault: UILabel!
    @IBOutlet weak var ozonePumpOnOffLbl: UILabel!
    @IBOutlet weak var ozonLabl: UILabel!

    var featureId = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pumpFault.isHidden = true
        self.motorOverload.isHidden = true
        self.pressureFault.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool){
        
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
        if featureId == 4{
           self.ozonLabl.text = "MS - 625 OZONE"
           readOzoneFaults(startRegister: WALL1_OZONE_FAULTS)
        }
        if featureId == 3{
            self.ozonLabl.text = "P - 504 OZONE"
            readGlimOzoneFaults(startRegister: WALL1_OZONE_FAULTS)
        }
        
    }
    
    func readOzoneFaults(startRegister: Int){
        CENTRAL_SYSTEM?.readBits(plcIpAddress:MITT_LAG_PLC_IP_ADDRESS, length: 3, startingRegister: Int32(startRegister), completion: { (sucess, response) in
            
            if response != nil{
                
                let pumpRunning = Int(truncating: response![0] as! NSNumber)
                let pumpFault = Int(truncating: response![1] as! NSNumber)
                let motorOverload = Int(truncating: response![2] as! NSNumber)
                
                if pumpRunning == 1{
                    
                    self.ozonePumpOnOffLbl.text = "PUMP CURRENTLY ON"
                    self.ozonePumpOnOffLbl.textColor = GREEN_COLOR
                    
                } else if pumpRunning == 0{
                    
                    self.ozonePumpOnOffLbl.text = "PUMP CURRENTLY OFF"
                    self.ozonePumpOnOffLbl.textColor = DEFAULT_GRAY
                }
                if pumpFault == 1{
                    self.pressureFault.isHidden = false
                } else {
                    self.pressureFault.isHidden = true
                }
                if motorOverload == 1{
                    self.motorOverload.isHidden = false
                } else {
                    self.motorOverload.isHidden = true
                }
            }
            
        })
    }
    
    func readGlimOzoneFaults(startRegister: Int){
        CENTRAL_SYSTEM?.readBits(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, length: 3, startingRegister: Int32(startRegister), completion: { (sucess, response) in
            
            if response != nil{
                
                let pumpRunning = Int(truncating: response![0] as! NSNumber)
                let pumpFault = Int(truncating: response![1] as! NSNumber)
                let motorOverload = Int(truncating: response![2] as! NSNumber)
                
                if pumpRunning == 1{
                    
                    self.ozonePumpOnOffLbl.text = "PUMP CURRENTLY ON"
                    self.ozonePumpOnOffLbl.textColor = GREEN_COLOR
                    
                } else if pumpRunning == 0{
                    
                    self.ozonePumpOnOffLbl.text = "PUMP CURRENTLY OFF"
                    self.ozonePumpOnOffLbl.textColor = DEFAULT_GRAY
                }
                if pumpFault == 1{
                    self.pressureFault.isHidden = false
                } else {
                    self.pressureFault.isHidden = true
                }
                if motorOverload == 1{
                    self.motorOverload.isHidden = false
                } else {
                    self.motorOverload.isHidden = true
                }
            }
            
        })
    }
    
    
    @objc func getData(){
        if featureId == 4{
           readOzoneFaults(startRegister: WALL1_OZONE_FAULTS)
        }
        if featureId == 3{
            readGlimOzoneFaults(startRegister: WALL1_OZONE_FAULTS)
        }
    }
}

