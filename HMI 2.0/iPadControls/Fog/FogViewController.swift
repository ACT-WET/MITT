//
//  FogViewController.swift
//  iPadControls
//
//  Created by Jan Manalo on 7/31/18.
//  Copyright © 2018 WET. All rights reserved.
//


import UIKit


class FogViewController: UIViewController{
    
    private let logger =  Logger()
    
    //No Connection View
    
    @IBOutlet weak var noConnectionView:     UIView!
    @IBOutlet weak var noConnectionErrorLbl: UILabel!
    
    @IBOutlet weak var handMode101Img: UIImageView!
    @IBOutlet weak var autoMode101IImg: UIImageView!
    @IBOutlet weak var autoHandBtn: UIButton!
    @IBOutlet weak var pumpFault: UILabel!
    @IBOutlet weak var motorOverload:        UILabel!
    @IBOutlet weak var pumpShutdown:            UILabel!
    @IBOutlet weak var fogOn101OffLbl:          UILabel!
    @IBOutlet weak var fogOn101ModeLbl:          UILabel!
    @IBOutlet weak var playStopBtn:          UIButton!
    
    @IBOutlet weak var handMode102Img: UIImageView!
    @IBOutlet weak var autoMode102IImg: UIImageView!
    @IBOutlet weak var autoHand102Btn: UIButton!
    @IBOutlet weak var pump102Fault: UILabel!
    @IBOutlet weak var motorOverload102:        UILabel!
    @IBOutlet weak var pump102Shutdown:            UILabel!
    @IBOutlet weak var fogOn102OffLbl:          UILabel!
    @IBOutlet weak var fogOn102ModeLbl:          UILabel!
    @IBOutlet weak var playStop102Btn:          UIButton!
    
    @IBOutlet weak var handMode103Img: UIImageView!
    @IBOutlet weak var autoMode103IImg: UIImageView!
    @IBOutlet weak var autoHand103Btn: UIButton!
    @IBOutlet weak var pump103Fault: UILabel!
    @IBOutlet weak var motorOverload103:        UILabel!
    @IBOutlet weak var pump103Shutdown:            UILabel!
    @IBOutlet weak var fogOn103OffLbl:          UILabel!
    @IBOutlet weak var fogOn103ModeLbl:          UILabel!
    @IBOutlet weak var playStop103Btn:          UIButton!
    
    @IBOutlet weak var handModeLiftImg: UIImageView!
    @IBOutlet weak var autoModeLiftImg: UIImageView!
    @IBOutlet weak var handModeView: UIView!
    @IBOutlet weak var liftOnOffSwtch: UISwitch!
    
    private var centralSystem = CentralSystem()
    var fogMotorLiveValues = FOG_MOTOR_LIVE_VALUES()
    var fogMotor602LiveValues = FOG_MOTOR_LIVE_VALUES()
    var fogMotor603LiveValues = FOG_MOTOR_LIVE_VALUES()
    var liftautoHand = 0
    var liftManSwtchOn = 0
    var readOnce = 0
    
    /***************************************************************************
     * Function :  viewDidLoad
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    override func viewDidLoad(){
        
        super.viewDidLoad()
    }

    
    /***************************************************************************
     * Function :  viewWillAppear
     * Input    :  none
     * Output   :  none
     * Comment  :  This function gets executed every time view appears
     ***************************************************************************/
    
    override func viewWillAppear(_ animated: Bool){
        centralSystem.getNetworkParameters()
        centralSystem.mittlagconnect()
        CENTRAL_SYSTEM = centralSystem
        //Add notification observer to get system stat
        NotificationCenter.default.addObserver(self, selector: #selector(checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
        
        //This line of code is an extension added to the view controller by showStoppers module
        //This is the only line needed to add show stopper
        
        
        
    }
    
    /***************************************************************************
     * Function :  viewWillDisappear
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    override func viewWillDisappear(_ animated: Bool){
        
        //NOTE: We need to remove the notification observer so the PUMP stat check point will stop to avoid extra bandwith usage
        
        NotificationCenter.default.removeObserver(self)
        self.logger.logData(data:"View Is Disappearing")
        
    }
    
    /***************************************************************************
     * Function :  checkSystemStat
     * Input    :  none
     * Output   :  none
     * Comment  :  Checks the network connection for all system components
     ***************************************************************************/
    
    @objc func checkSystemStat(){
        let (plcConnection,_,_,_) = (CENTRAL_SYSTEM?.getConnectivityStat())!
        
        if plcConnection == CONNECTION_STATE_CONNECTED {
            //Change the connection stat indicator
            noConnectionView.alpha = 0
            noConnectionView.isUserInteractionEnabled = false
            
            //Now that the connection is established, run functions
            checkAutoHandMode()
            getFogDataFromPLC()
            
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
    
    /***************************************************************************
     * Function :  checkAutoHandMode
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    func checkAutoHandMode(){
        
        CENTRAL_SYSTEM?.readBits(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, length: 1, startingRegister: Int32(FOG601_AUTO_HAND_BIT_ADDR), completion: { (success, response) in
            
            if response != nil{
                
                let autoHandMode = Int(truncating: response![0] as! NSNumber)
                
                if autoHandMode == 1{
                    //If is in manual mode on the ipad
                    self.changeAutManModeIndicatorRotation(autoMode: false, tag: 1)
                    self.playStopBtn.alpha = 1
                }else{
                    //If is in auto mode on the ipad
                    self.playStopBtn.alpha = 0
                    self.changeAutManModeIndicatorRotation(autoMode: true, tag: 1)
                    self.readFogPlayStopData()
                }
            }
            
        })
        CENTRAL_SYSTEM?.readBits(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, length: 1, startingRegister: Int32(FOG602_AUTO_HAND_BIT_ADDR), completion: { (success, response) in
            
            if response != nil{
                
                let autoHandMode = Int(truncating: response![0] as! NSNumber)
                
                if autoHandMode == 1{
                    //If is in manual mode on the ipad
                    self.changeAutManModeIndicatorRotation(autoMode: false, tag: 2)
                    self.playStop102Btn.alpha = 1
                }else{
                    //If is in auto mode on the ipad
                    self.playStop102Btn.alpha = 0
                    self.changeAutManModeIndicatorRotation(autoMode: true, tag: 2)
                    self.readFogPlayStopData()
                }
            }
            
        })
        CENTRAL_SYSTEM?.readBits(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, length: 1, startingRegister: Int32(FOG603_AUTO_HAND_BIT_ADDR), completion: { (success, response) in
            
            if response != nil{
                
                let autoHandMode = Int(truncating: response![0] as! NSNumber)
                
                if autoHandMode == 1{
                    //If is in manual mode on the ipad
                    self.changeAutManModeIndicatorRotation(autoMode: false, tag: 3)
                    self.playStop103Btn.alpha = 1
                }else{
                    //If is in auto mode on the ipad
                    self.playStop103Btn.alpha = 0
                    self.changeAutManModeIndicatorRotation(autoMode: true, tag: 3)
                    self.readFogPlayStopData()
                }
            }
            
        })
    }
    
    
    /***************************************************************************
     * Function :  readFogPlayStopData
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    func readFogPlayStopData(){
        CENTRAL_SYSTEM?.readBits(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, length: 1, startingRegister: Int32(FOG601_PLAY_STOP_BIT_ADDR), completion: { (success, response) in
            
            guard success == true else { return }
            
            let playStopValue = Int(truncating: response![0] as! NSNumber)
            
            if playStopValue == 1 {
                self.playStopBtn.setBackgroundImage(#imageLiteral(resourceName: "stopButton"), for: .normal)
            } else {
                self.playStopBtn.setBackgroundImage(#imageLiteral(resourceName: "playButton"), for: .normal)
            }
            
        })
        
    }
    
    
    /***************************************************************************
     * Function :  getFogDataFromPLC
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    func getFogDataFromPLC(){
        
        CENTRAL_SYSTEM?.readBits(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, length: Int32(FOG601_FAULTS.count), startingRegister: Int32(FOG601_FAULTS.startAddr), completion: { (sucess, response) in
            
            if response != nil{
                
                
                self.fogMotorLiveValues.pumpRunning   = Int(truncating: response![0] as! NSNumber)
                self.fogMotorLiveValues.pumpShutdown  = Int(truncating: response![1] as! NSNumber)
                self.fogMotorLiveValues.pumpOverLoad  = Int(truncating: response![2] as! NSNumber)
                self.fogMotorLiveValues.pumpFault      = Int(truncating: response![3] as! NSNumber)
                self.fogMotorLiveValues.pumpMode      = Int(truncating: response![5] as! NSNumber)
            }
            
        })
        CENTRAL_SYSTEM?.readBits(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, length: Int32(FOG602_FAULTS.count), startingRegister: Int32(FOG602_FAULTS.startAddr), completion: { (sucess, response) in
            
            if response != nil{
                
                
                self.fogMotor602LiveValues.pumpRunning   = Int(truncating: response![0] as! NSNumber)
                self.fogMotor602LiveValues.pumpShutdown  = Int(truncating: response![1] as! NSNumber)
                self.fogMotor602LiveValues.pumpOverLoad  = Int(truncating: response![2] as! NSNumber)
                self.fogMotor602LiveValues.pumpFault      = Int(truncating: response![3] as! NSNumber)
                self.fogMotor602LiveValues.pumpMode      = Int(truncating: response![5] as! NSNumber)
            }
            
        })
        CENTRAL_SYSTEM?.readBits(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, length: Int32(FOG603_FAULTS.count), startingRegister: Int32(FOG603_FAULTS.startAddr), completion: { (sucess, response) in
            
            if response != nil{
                
                
                self.fogMotor603LiveValues.pumpRunning   = Int(truncating: response![0] as! NSNumber)
                self.fogMotor603LiveValues.pumpShutdown  = Int(truncating: response![1] as! NSNumber)
                self.fogMotor603LiveValues.pumpOverLoad  = Int(truncating: response![2] as! NSNumber)
                self.fogMotor603LiveValues.pumpFault      = Int(truncating: response![3] as! NSNumber)
                self.fogMotor603LiveValues.pumpMode      = Int(truncating: response![5] as! NSNumber)
            }
            
        })
        CENTRAL_SYSTEM?.readRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, length: 1, startingRegister: Int32(FOG601_PUMPMODE_ADDR), completion:{ (success, response) in
            
            guard success == true else { return }
            
           let panelMode = Int(truncating: response![0] as! NSNumber)
           self.fogMotorLiveValues.panelMode = panelMode
        })
        CENTRAL_SYSTEM?.readRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, length: 1, startingRegister: Int32(FOG602_PUMPMODE_ADDR), completion:{ (success, response) in
            
            guard success == true else { return }
            
           let panelMode = Int(truncating: response![0] as! NSNumber)
           self.fogMotor602LiveValues.panelMode = panelMode
        })
        CENTRAL_SYSTEM?.readRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, length: 1, startingRegister: Int32(FOG603_PUMPMODE_ADDR), completion:{ (success, response) in
            
            guard success == true else { return }
            
           let panelMode = Int(truncating: response![0] as! NSNumber)
           self.fogMotor603LiveValues.panelMode = panelMode
        })
        CENTRAL_SYSTEM?.readBits(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, length: Int32(FOG_LIFTS.count), startingRegister: Int32(FOG_LIFTS.startAddr), completion: { (sucess, response) in
            
            if response != nil{
                self.liftautoHand   = Int(truncating: response![0] as! NSNumber)
                self.liftManSwtchOn = Int(truncating: response![1] as! NSNumber)
                
                if self.liftautoHand == 1{
                    self.changeAutManModeIndicatorRotation(autoMode: false, tag: 4)
                    self.handModeView.isHidden = false
                } else if self.liftautoHand == 0 {
                    self.changeAutManModeIndicatorRotation(autoMode: true, tag: 4)
                    self.handModeView.isHidden = true
                }
                if self.readOnce == 0{
                    if self.liftManSwtchOn == 1{
                        self.liftOnOffSwtch.isOn = true
                    } else if self.liftManSwtchOn == 0 {
                        self.liftOnOffSwtch.isOn = false
                    }
                    self.readOnce = 1
                }
            }
            
        })
         self.parseFogPumpData()
        
    }
    
    /***************************************************************************
     * Function :  parseFogPumpData
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    func parseFogPumpData(){
        
            if fogMotorLiveValues.pumpOverLoad == 1{
                motorOverload.alpha = 1
            } else {
                motorOverload.alpha = 0
            }
            
            if fogMotorLiveValues.pumpFault == 1{
                pumpFault.alpha = 1
            } else {
                pumpFault.alpha = 0
            }
        
            if fogMotorLiveValues.pumpShutdown == 1{
                pumpShutdown.alpha = 1
            } else {
                pumpShutdown.alpha = 0
            }
            
            if fogMotorLiveValues.pumpRunning == 1{
                   
                   fogOn101OffLbl.text = "FOG ON"
                   fogOn101OffLbl.textColor = GREEN_COLOR
                   playStopBtn.setBackgroundImage(#imageLiteral(resourceName: "stopButton"), for: .normal)
                  
                   
            } else if fogMotorLiveValues.pumpRunning == 0{
                   
                   fogOn101OffLbl.text = "FOG OFF"
                   fogOn101OffLbl.textColor = DEFAULT_GRAY
                   playStopBtn.setBackgroundImage(#imageLiteral(resourceName: "playButton"), for: .normal)
            
            }
            fogOn101ModeLbl.textColor = DEFAULT_GRAY
            if fogMotorLiveValues.panelMode == 0{
                fogOn101ModeLbl.text = "PANEL SWITCH IN AUTO"
                playStopBtn.isHidden = false
                autoHandBtn.isHidden = false
                autoMode101IImg.isHidden = false
                handMode101Img.isHidden = false
            } else {
                playStopBtn.isHidden = true
                autoHandBtn.isHidden = true
                autoMode101IImg.isHidden = true
                handMode101Img.isHidden = true
                if fogMotorLiveValues.panelMode == 1{
                    fogOn101ModeLbl.text = "PANEL SWITCH IN HAND"
                } else if fogMotorLiveValues.panelMode == 2{
                    fogOn101ModeLbl.text = "PANEL SWITCH IN OFF"
                }
            }
            
        
            if fogMotor602LiveValues.pumpOverLoad == 1{
                motorOverload102.alpha = 1
            } else {
                motorOverload102.alpha = 0
            }
            
            if fogMotor602LiveValues.pumpFault == 1{
                pump102Fault.alpha = 1
            } else {
                pump102Fault.alpha = 0
            }
        
            if fogMotor602LiveValues.pumpShutdown == 1{
                pump102Shutdown.alpha = 1
            } else {
                pump102Shutdown.alpha = 0
            }
            
            if fogMotor602LiveValues.pumpRunning == 1{
                   
                   fogOn102OffLbl.text = "FOG ON"
                   fogOn102OffLbl.textColor = GREEN_COLOR
                   playStop102Btn.setBackgroundImage(#imageLiteral(resourceName: "stopButton"), for: .normal)
                  
                   
            } else if fogMotor602LiveValues.pumpRunning == 0{
                   
                   fogOn102OffLbl.text = "FOG OFF"
                   fogOn102OffLbl.textColor = DEFAULT_GRAY
                   playStop102Btn.setBackgroundImage(#imageLiteral(resourceName: "playButton"), for: .normal)
            
            }
            fogOn102ModeLbl.textColor = DEFAULT_GRAY
            if fogMotor602LiveValues.panelMode == 0{
                fogOn102ModeLbl.text = "PANEL SWITCH IN AUTO"
                playStop102Btn.isHidden = false
                autoHand102Btn.isHidden = false
                autoMode102IImg.isHidden = false
                handMode102Img.isHidden = false
            } else {
                playStop102Btn.isHidden = true
                autoHand102Btn.isHidden = true
                autoMode102IImg.isHidden = true
                handMode102Img.isHidden = true
                if fogMotor602LiveValues.panelMode == 1{
                    fogOn102ModeLbl.text = "PANEL SWITCH IN HAND"
                } else if fogMotor602LiveValues.panelMode == 2{
                    fogOn102ModeLbl.text = "PANEL SWITCH IN OFF"
                }
            }
        
            if fogMotor603LiveValues.pumpOverLoad == 1{
                motorOverload103.alpha = 1
            } else {
                motorOverload103.alpha = 0
            }
            
            if fogMotor603LiveValues.pumpFault == 1{
                pump103Fault.alpha = 1
            } else {
                pump103Fault.alpha = 0
            }
        
            if fogMotor603LiveValues.pumpShutdown == 1{
                pump103Shutdown.alpha = 1
            } else {
                pump103Shutdown.alpha = 0
            }
            
            if fogMotor603LiveValues.pumpRunning == 1{
                   
                   fogOn103OffLbl.text = "FOG ON"
                   fogOn103OffLbl.textColor = GREEN_COLOR
                   playStop103Btn.setBackgroundImage(#imageLiteral(resourceName: "stopButton"), for: .normal)
                  
                   
            } else if fogMotor603LiveValues.pumpRunning == 0{
                   
                   fogOn103OffLbl.text = "FOG OFF"
                   fogOn103OffLbl.textColor = DEFAULT_GRAY
                   playStop103Btn.setBackgroundImage(#imageLiteral(resourceName: "playButton"), for: .normal)
            
            }
            fogOn103ModeLbl.textColor = DEFAULT_GRAY
            if fogMotor603LiveValues.panelMode == 0{
                fogOn103ModeLbl.text = "PANEL SWITCH IN AUTO"
                playStop103Btn.isHidden = false
                autoHand103Btn.isHidden = false
                autoMode103IImg.isHidden = false
                handMode103Img.isHidden = false
            } else {
                playStop103Btn.isHidden = true
                autoHand103Btn.isHidden = true
                autoMode103IImg.isHidden = true
                handMode103Img.isHidden = true
                if fogMotor603LiveValues.panelMode == 1{
                    fogOn103ModeLbl.text = "PANEL SWITCH IN HAND"
                } else if fogMotor603LiveValues.panelMode == 2{
                    fogOn103ModeLbl.text = "PANEL SWITCH IN OFF"
                }
            }
                
        }
    
    /***************************************************************************
     * Function :  changeAutManModeIndicatorRotation
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    func changeAutManModeIndicatorRotation(autoMode:Bool, tag:Int){
        
        /*
         NOTE: 2 Possible Options
         Option 1: Automode (animate) = True => Will result in any view object to rotate 360 degrees infinitly
         Option 2: Automode (animate) = False => Will result in any view object to stand still
         */
        autoMode101IImg.rotate360Degrees(animate: true)
        autoMode102IImg.rotate360Degrees(animate: true)
        autoMode103IImg.rotate360Degrees(animate: true)
        autoModeLiftImg.rotate360Degrees(animate: true)
        if tag == 1{
            if autoMode == true {
                
                self.autoMode101IImg.alpha = 1
                self.handMode101Img.alpha = 0
                
            }else{
                
                self.handMode101Img.alpha = 1
                self.autoMode101IImg.alpha = 0
                
            }
        }
        if tag == 2{
            if autoMode == true {
                
                self.autoMode102IImg.alpha = 1
                self.handMode102Img.alpha = 0
                
            }else{
                
                self.handMode102Img.alpha = 1
                self.autoMode102IImg.alpha = 0
                
            }
        }
        if tag == 3{
            if autoMode == true {
                
                self.autoMode103IImg.alpha = 1
                self.handMode103Img.alpha = 0
                
            }else{
                
                self.handMode103Img.alpha = 1
                self.autoMode103IImg.alpha = 0
                
            }
        }
        if tag == 4{
            if autoMode == true {
                
                self.autoModeLiftImg.alpha = 1
                self.handModeLiftImg.alpha = 0
                
            }else{
                
                self.handModeLiftImg.alpha = 1
                self.autoModeLiftImg.alpha = 0
                
            }
        }
    }
    
    /***************************************************************************
     * Function :  toggleAutoHandMode
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    @IBAction func toggleAutoHandMode(_ sender: UIButton){
        
        //NOTE: The auto/hand mode value on PLC is opposite to autoModeValue
        //On PLC Auto Mode: 0 , Hand Mode: 1
        if sender.tag == 1{
            if self.fogMotorLiveValues.pumpMode == 1{
                //In manual mode, change to auto mode
                CENTRAL_SYSTEM?.writeBit(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, bit: FOG601_AUTO_HAND_BIT_ADDR, value: 0)
                
            } else if self.fogMotorLiveValues.pumpMode == 0{
                //In auto mode, change it to manual mode
                CENTRAL_SYSTEM?.writeBit(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, bit: FOG601_AUTO_HAND_BIT_ADDR, value: 1)
                
            }
        }
        if sender.tag == 2{
            if self.fogMotor602LiveValues.pumpMode == 1{
                //In manual mode, change to auto mode
                CENTRAL_SYSTEM?.writeBit(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, bit: FOG602_AUTO_HAND_BIT_ADDR, value: 0)
                
            } else if self.fogMotor602LiveValues.pumpMode == 0{
                //In auto mode, change it to manual mode
                CENTRAL_SYSTEM?.writeBit(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, bit: FOG602_AUTO_HAND_BIT_ADDR, value: 1)
                
            }
        }
        if sender.tag == 3{
            if self.fogMotor603LiveValues.pumpMode == 1{
                //In manual mode, change to auto mode
                CENTRAL_SYSTEM?.writeBit(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, bit: FOG603_AUTO_HAND_BIT_ADDR, value: 0)
                
            } else if self.fogMotor603LiveValues.pumpMode == 0{
                //In auto mode, change it to manual mode
                CENTRAL_SYSTEM?.writeBit(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, bit: FOG603_AUTO_HAND_BIT_ADDR, value: 1)
                
            }
        }
    }
    

    
    
    /***************************************************************************
     * Function :  playStopFog
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    @IBAction func playStopFog(_ sender: UIButton){
        
        if sender.tag == 4{
            if self.fogMotorLiveValues.pumpRunning == 1{
                CENTRAL_SYSTEM?.writeBit(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, bit: 7000, value: 0)
            } else if self.fogMotorLiveValues.pumpRunning == 0{
                CENTRAL_SYSTEM?.writeBit(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, bit: 7000, value: 1)
            }
        }
        if sender.tag == 5{
            if self.fogMotor602LiveValues.pumpRunning == 1{
                CENTRAL_SYSTEM?.writeBit(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, bit: 7010, value: 0)
            } else if self.fogMotor602LiveValues.pumpRunning == 0{
                CENTRAL_SYSTEM?.writeBit(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, bit: 7010, value: 1)
            }
        }
        if sender.tag == 6{
            if self.fogMotor603LiveValues.pumpRunning == 1{
                CENTRAL_SYSTEM?.writeBit(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, bit: 7020, value: 0)
            } else if self.fogMotor603LiveValues.pumpRunning == 0{
                CENTRAL_SYSTEM?.writeBit(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, bit: 7020, value: 1)
            }
        }
    }
    
    @IBAction func toggleOnOffSwtch(_ sender: UISwitch) {
        if self.liftManSwtchOn == 0{
            CENTRAL_SYSTEM?.writeBit(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, bit: 7031, value: 1)
        } else if self.liftManSwtchOn == 1{
            CENTRAL_SYSTEM?.writeBit(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, bit: 7031, value: 0)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.3) {
            self.readOnce = 0
        }
    }
    
    @IBAction func toggleAutoHandLift(_ sender: UIButton) {
        if self.liftautoHand == 0{
            CENTRAL_SYSTEM?.writeBit(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, bit: 7030, value: 1)
        } else if self.liftautoHand == 1{
            CENTRAL_SYSTEM?.writeBit(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, bit: 7030, value: 0)
        }
    }
    
    @IBAction func showSettingsButton(_ sender: UIButton) {
         self.addAlertAction(button: sender)
    }
}
