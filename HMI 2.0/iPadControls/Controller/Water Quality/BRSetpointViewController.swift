//
//  BRSetpointViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 12/20/18.
//  Copyright © 2018 WET. All rights reserved.
//

import UIKit

class BRSetpointViewController: UIViewController {
    @IBOutlet weak var lowLbl: UILabel!
    @IBOutlet weak var highLbl: UILabel!
    @IBOutlet weak var brSetpointHigh: UITextField!
    @IBOutlet weak var brSetpointLow: UITextField!
    var buttonID = 0
    var featureId = 0
    private var centralSystem = CentralSystem()
    override func viewDidLoad() {
        super.viewDidLoad()
        readSetPoints()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool){

        //Configure Pump Screen Text Content Based On Device Language
            if featureId == 1{
                centralSystem.getNetworkParameters()
                centralSystem.mittlagconnect()
                CENTRAL_SYSTEM = centralSystem
            } else if featureId == 2{
                centralSystem.getNetworkParameters()
                centralSystem.mittlaconnect()
                CENTRAL_SYSTEM = centralSystem
            }
//        centralSystem.getNetworkParameters()
//        centralSystem.mittlagconnect()
//        CENTRAL_SYSTEM = centralSystem
        switch buttonID {
        case 1,2,3:
            self.highLbl.text = "HIGH SP"
            self.lowLbl.text = "LOW SP"
        case 4:
            self.highLbl.text = "START SP"
            self.lowLbl.text = "STOP SP"
        default:
            print("NOT VALID")
        }
        //Add notification observer to get system stat
        
    }
    
    private func readSetPoints(){
        let offset = 10
        switch buttonID {
        case 1,2,3:
            if featureId == 1{
                CENTRAL_SYSTEM?.readRealRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: 306 + ((buttonID-1) * offset), length: 2, completion: { (success, response) in
                    guard success == true else { return }
                    let val = Float(response)!
                    self.brSetpointLow.text   = String(format: "%.1f", val)
                })
                
                CENTRAL_SYSTEM?.readRealRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: 308 + ((buttonID-1) * offset), length: 2, completion: { (success, response) in
                    guard success == true else { return }
                    let val = Float(response)!
                    self.brSetpointHigh.text   = String(format: "%.1f", val)
                })
            } else if featureId == 2{
                CENTRAL_SYSTEM?.readRealRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: 306 + ((buttonID-1) * offset), length: 2, completion: { (success, response) in
                    guard success == true else { return }
                    let val = Float(response)!
                    self.brSetpointLow.text   = String(format: "%.1f", val)
                })
                
                CENTRAL_SYSTEM?.readRealRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: 308 + ((buttonID-1) * offset), length: 2, completion: { (success, response) in
                    guard success == true else { return }
                    let val = Float(response)!
                    self.brSetpointHigh.text   = String(format: "%.1f", val)
                })
            }
            
        case 4:
            if featureId == 1{
                CENTRAL_SYSTEM?.readRealRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: 332, length: 2, completion: { (success, response) in
                    guard success == true else { return }
                    let val = Float(response)!
                    self.brSetpointHigh.text   = String(format: "%.1f", val)
                })
                
                CENTRAL_SYSTEM?.readRealRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: 334, length: 2, completion: { (success, response) in
                    guard success == true else { return }
                    let val = Float(response)!
                    self.brSetpointLow.text   = String(format: "%.1f", val)
                })
            } else if featureId == 2{
                CENTRAL_SYSTEM?.readRealRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: 332, length: 2, completion: { (success, response) in
                    guard success == true else { return }
                    let val = Float(response)!
                    self.brSetpointHigh.text   = String(format: "%.1f", val)
                })
                
                CENTRAL_SYSTEM?.readRealRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: 334, length: 2, completion: { (success, response) in
                    guard success == true else { return }
                    let val = Float(response)!
                    self.brSetpointLow.text   = String(format: "%.1f", val)
                })
            }
        default:
            print("NOT VALID")
        }
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool){
        
        //NOTE: We need to remove the notification observer so the PUMP stat check point will stop to avoid extra bandwith usage
        NotificationCenter.default.removeObserver(self)
        
    }
    
    
    
    @IBAction func writeSetpoints(_ sender: UIButton) {
        let setpointlow  = Float(self.brSetpointLow.text!)
        let setpointhigh  = Float(self.brSetpointHigh.text!)
        
        guard setpointlow != nil && setpointhigh != nil else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.50) {
                self.readSetPoints()
            }
            return
        }
        
        let offset = 10
        switch buttonID {
            
            case 1,2,3:
                if featureId == 1{
                    CENTRAL_SYSTEM!.writeRealValue(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: 306 + ((buttonID-1) * offset), value: setpointlow!)
                    CENTRAL_SYSTEM!.writeRealValue(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: 308 + ((buttonID-1) * offset), value: setpointhigh!)
                } else if featureId == 2{
                    CENTRAL_SYSTEM!.writeRealValue(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: 306 + ((buttonID-1) * offset), value: setpointlow!)
                    CENTRAL_SYSTEM!.writeRealValue(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: 308 + ((buttonID-1) * offset), value: setpointhigh!)
                }
            case 4:
               
                if featureId == 1{
                     CENTRAL_SYSTEM!.writeRealValue(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: 332, value: setpointhigh!)
                     CENTRAL_SYSTEM!.writeRealValue(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: 334, value: setpointlow!)
                } else if featureId == 2{
                     CENTRAL_SYSTEM!.writeRealValue(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: 332, value: setpointhigh!)
                     CENTRAL_SYSTEM!.writeRealValue(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: 334, value: setpointlow!)
                } 
            default:
                print("NOT VALID")
            }
        DispatchQueue.main.asyncAfter(deadline: .now() + 20.5) {
            self.readSetPoints()
        }
    }
    

}
