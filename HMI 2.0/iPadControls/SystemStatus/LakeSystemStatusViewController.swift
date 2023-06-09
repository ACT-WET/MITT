//
//  LakeSystemStatusViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 12/24/22.
//  Copyright © 2022 WET. All rights reserved.
//

import UIKit

class LakeSystemStatusViewController: UIViewController {
    private var ethernetFaultIndex = [Int]()
    private var cleanStrainerFaultIndex = [Int]()
    
    @IBOutlet weak var faultsViewContainer: UIView!
    @IBOutlet weak var noConnectionView: UIView!
    @IBOutlet weak var noConnectionErrorLbl: UILabel!
    @IBOutlet weak var faultBtn: UIButton!
    @IBOutlet weak var warningbtn: UIButton!
    private var centralSystem = CentralSystem()
    var redStateResp    = 0
    var yellowStateResp = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        acquireDataFromPLC()
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        centralSystem.getNetworkParameters()
        centralSystem.mittlaconnect()
        CENTRAL_SYSTEM = centralSystem
        NotificationCenter.default.addObserver(self, selector: #selector(checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
    }
    override func viewWillDisappear(_ animated: Bool){
        //NOTE: We need to remove the notification observer so the PUMP stat check point will stop to avoid extra bandwith usage
        NotificationCenter.default.removeObserver(self)
        
    }
    
    @objc func checkSystemStat(){
        let (_,plcConnection,_,_) = (CENTRAL_SYSTEM?.getConnectivityStat())!
        
        if plcConnection == CONNECTION_STATE_CONNECTED {
            //Change the connection stat indicator
            noConnectionView.alpha = 0
            noConnectionView.isUserInteractionEnabled = false
            
            //Now that the connection is established, run functions
            acquireDataFromPLC()
            
        }  else {
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
    func pad(string : String, toSize: Int) -> String{
        
        var padded = string
        
        for _ in 0..<toSize - string.characters.count{
            padded = "0" + padded
        }
        
        return padded
        
    }
    
    private func acquireDataFromPLC(){
        CENTRAL_SYSTEM?.readRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, length: 1, startingRegister: Int32(SYSTEM_FAULT_YELLOW), completion:{ (success, response) in
                    
            if success == true{
                
                //Bitwise Operation
                //self.yellowStateResp = 15
                self.yellowStateResp = Int(truncating: response![0] as! NSNumber)
                let base_2_binary = String(self.yellowStateResp, radix: 2)
                let Bit_16:String = self.pad(string: base_2_binary, toSize: 16)  //Convert to 16 bit
                let bits =  Bit_16.characters.map { String($0) }
                self.parseYellowStates(bits: bits)
            }
            CENTRAL_SYSTEM?.readRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, length: 1, startingRegister: Int32(SYSTEM_FAULT_RED), completion:{ (success, response) in
                
                if success == true{
                    
                    //Bitwise Operation
                    self.redStateResp = Int(truncating: response![0] as! NSNumber)
                    //self.redStateResp = 0
                    let base_2_binary = String(self.redStateResp, radix: 2)
                    let Bit_16:String = self.pad(string: base_2_binary, toSize: 16)  //Convert to 16 bit
                    let bits =  Bit_16.characters.map { String($0) }
                    self.parseRedStates(bits: bits)
                }
            })
            
            if self.redStateResp == 0 {
                self.faultsViewContainer.isHidden = true
            } else {
                self.faultsViewContainer.isHidden = false
            }
        })
       
    }
    
    private func parseRedStates(bits:[String]){
        var yPosition = 121
        let offset    = 36
        for fault in LAKE_SYSTEM_RED_STATUS{
            
            let faultTag = fault.tag
            let state = Int(bits[15 - fault.bitwiseLocation])
            let indicator = view.viewWithTag(faultTag) as? UILabel
            
            switch faultTag {
            case 10...14:
                
                if state == 0 {
                    indicator?.isHidden = true
                } else {
                    indicator?.isHidden = false
                    indicator?.frame = CGRect(x: 474, y: yPosition, width: 280, height: 21)
                    yPosition += offset
                }
            default:
                print("FAULT TAG NOT FOUND \(faultTag)")
            }
        }
    }
    
    private func parseYellowStates(bits:[String]){
        var yPosition = 121
        let offset    = 36
        for fault in SYSTEM_YELLOW_STATUS{
            
            var faultTag = fault.tag
            let state = Int(bits[15 - fault.bitwiseLocation])
            var indicator = view.viewWithTag(faultTag) as? UILabel
            switch faultTag {
            case 1...4:
                
                if state == 0 {
                indicator?.isHidden = true
            } else {
                indicator?.isHidden = false
                indicator?.frame = CGRect(x: 45, y: yPosition, width: 280, height: 21)
                yPosition += offset
                    
            }
            default:
                print(" STRAINER FAULT TAG NOT FOUND")
            }
        }
    }
    
    @IBAction func faultResetBtnPushed(_ sender: Any) {
        
        CENTRAL_SYSTEM?.writeBit(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, bit: FAULT_RESET_REGISTER, value: 1)
        self.faultBtn.isUserInteractionEnabled = false
        self.faultBtn.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute:{
            CENTRAL_SYSTEM?.writeBit(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, bit: FAULT_RESET_REGISTER, value: 0)
            self.faultBtn.isUserInteractionEnabled = true
            self.faultBtn.isEnabled = true
        })
    }
    
    @IBAction func warningResetBtnPushed(_ sender: Any) {
        CENTRAL_SYSTEM?.writeBit(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, bit: WARNING_RESET_REGISTER, value: 1)
        self.warningbtn.isUserInteractionEnabled = false
        self.warningbtn.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute:{
            CENTRAL_SYSTEM?.writeBit(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, bit: WARNING_RESET_REGISTER, value: 0)
            self.warningbtn.isUserInteractionEnabled = true
            self.warningbtn.isEnabled = true
        })
    }
}
