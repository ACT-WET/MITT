//
//  AlightSystemStatusViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 12/24/22.
//  Copyright © 2022 WET. All rights reserved.
//

import UIKit

class LakeSystemStatusViewController: UIViewController {

    private var ethernetFaultIndex = [Int]()
    private var cleanStrainerFaultIndex = [Int]()
    
    @IBOutlet weak var checkFaultButton: UIButton!
    @IBOutlet weak var faultsViewContainer: UIView!
    @IBOutlet weak var noConnectionView: UIView!
    @IBOutlet weak var noConnectionErrorLbl: UILabel!
    @IBOutlet weak var checkStrainerFault: UIButton!
    @IBOutlet weak var faultBtn: UIButton!
    @IBOutlet weak var warningbtn: UIButton!
    private var centralSystem = CentralSystem()
    var yellowStateResp = 0
    var redStateResp    = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        acquireDataFromPLC()
        checkFaultButton.isHidden = true
        checkStrainerFault.isHidden = true
        
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
//                self.yellowStateResp = 15
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
            
            if self.yellowStateResp + self.redStateResp == 0 {
                self.faultsViewContainer.isHidden = true
            } else {
                self.faultsViewContainer.isHidden = false
            }
        })
       
    }
    private func parseYellowStates(bits:[String]){
        var yPosition = 121
        let offset    = 36
        for fault in ALIGHT_SYSTEM_YELLOW_STATUS{
            
            var faultTag = fault.tag
            let state = Int(bits[15 - fault.bitwiseLocation])
            var indicator = view.viewWithTag(faultTag) as? UILabel
            switch faultTag {
            case 1...4:
                
                if state == 0 {
                indicator?.isHidden = true
            } else {
                indicator?.isHidden = false
                indicator?.frame = CGRect(x: 60, y: yPosition, width: 280, height: 21)
                yPosition += offset
                    if faultTag == 1{
                        checkStrainerFault.isHidden = false
                        checkStrainerFault.frame.origin.y = CGFloat(yPosition-offset-3)
                        
                        for index in 0...ALIGHT_STRAINER_STATUS.count - 1 {
                            CENTRAL_SYSTEM?.readBits(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, length: 1, startingRegister: Int32(ALIGHT_STRAINER_STATUS.startingregister+index), completion:{ (success, response) in
                                
                                guard success == true else { return }
                                
                                let fault = Int(truncating: response![0] as! NSNumber)
                                
                                
                                /*********FOR TESTING ONLY******
                                 
                                 var fault = 0
                                 switch index {
                                 case 0...2:
                                 fault = 0
                                 case 5...9:
                                 fault = 1
                                 case 12...16:
                                 fault = 1
                                 case 17...22:
                                 fault = 1
                                 case 23...29:
                                 fault = 1
                                 case 30...36:
                                 fault = 1
                                 default:
                                 print("This is for testing only")
                                 }
                                 
                                 
                                 */
                                
                                if fault == 1{
                                    if !self.cleanStrainerFaultIndex.contains(index) {
                                        self.cleanStrainerFaultIndex.append(index)
                                    }
                                }
                            })
                        }
                    }
                }
            default:
                print(" STRAINER FAULT TAG NOT FOUND")
            }
        }
    }
    
    private func parseRedStates(bits:[String]){
        var yPosition = 121
        let offset    = 36
        for fault in ALIGHT_SYSTEM_RED_STATUS{
            
            let faultTag = fault.tag
            let state = Int(bits[15 - fault.bitwiseLocation])
            let indicator = view.viewWithTag(faultTag) as? UILabel
            
            switch faultTag {
            case 10...15:
                
                if state == 0 {
                    indicator?.isHidden = true
                } else {
                    indicator?.isHidden = false
                    indicator?.frame = CGRect(x: 415, y: yPosition, width: 280, height: 21)
                    yPosition += offset
                    if faultTag == 14{
                        checkFaultButton.isHidden = false
                        checkFaultButton.frame.origin.y = CGFloat(yPosition-offset-3)
                        
                        for index in 0...ALIGHT_ETHERNET_STATUS.count - 1 {
                            CENTRAL_SYSTEM?.readBits(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, length: 1, startingRegister: Int32(ALIGHT_ETHERNET_STATUS.startingregister+index), completion:{ (success, response) in
                                
                                guard success == true else { return }
                       
                                    let fault = Int(truncating: response![0] as! NSNumber)
                                
                                
                            /*********FOR TESTING ONLY******
                                 
                                 var fault = 0
                                 switch index {
                                 case 0...2:
                                 fault = 0
                                 case 5...9:
                                 fault = 1
                                 case 12...16:
                                 fault = 1
                                 case 17...22:
                                 fault = 1
                                 case 23...29:
                                 fault = 1
                                 case 30...36:
                                 fault = 1
                                 default:
                                 print("This is for testing only")
                                 }
                                 
                                 
                            */
                                
                                    if fault == 0{
                                        if !self.ethernetFaultIndex.contains(index) {
                                            self.ethernetFaultIndex.append(index)
                                        }
                                        
                                    }
                            })
                        }
                        
                    }
                }
                
            default:
                print("FAULT TAG NOT FOUND \(faultTag)")
            }
        }
    }
    
    
    @IBAction func checkFaultButtonPressed(_ sender: UIButton) {
        let popoverContent = UIStoryboard(name: "systemstatus", bundle: nil).instantiateViewController(withIdentifier: "faultPopUpVC") as! SystemFaultViewController
        popoverContent.faultTag = sender.tag
        if sender.tag == 202 {
            popoverContent.alfaultIndex = ethernetFaultIndex
            let nav = UINavigationController(rootViewController: popoverContent)
            nav.modalPresentationStyle = .popover
            nav.isNavigationBarHidden = true
            let popover = nav.popoverPresentationController
            popoverContent.preferredContentSize = CGSize(width: 320, height: 505)
            popover?.sourceView = sender
            
            self.present(nav, animated: true, completion: nil)
        }
        if sender.tag == 102 {
            popoverContent.alstrainerFaultIndex = cleanStrainerFaultIndex
            let nav = UINavigationController(rootViewController: popoverContent)
            nav.modalPresentationStyle = .popover
            nav.isNavigationBarHidden = true
            let popover = nav.popoverPresentationController
            popoverContent.preferredContentSize = CGSize(width: 320, height: 505)
            popover?.sourceView = sender
            
            self.present(nav, animated: true, completion: nil)
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
