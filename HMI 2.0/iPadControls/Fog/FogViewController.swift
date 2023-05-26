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
    @IBOutlet weak var fogOn101OffLbl:          UILabel!
    @IBOutlet weak var fogOn101ModeLbl:          UILabel!
    @IBOutlet weak var playStopBtn:          UIButton!
    
    private var centralSystem = CentralSystem()
    var fogMotorLiveValues = FOG_MOTOR_LIVE_VALUES()
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
     * Function :  getFogDataFromPLC
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    func getFogDataFromPLC(){
        
        CENTRAL_SYSTEM?.readBits(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, length: 1, startingRegister: Int32(FOG113_PUMP_RUNNING), completion:{ (success, response) in
            
            guard success == true else { return }
            
            self.fogMotorLiveValues.pumpRunning   = Int(truncating: response![0] as! NSNumber)
            if self.fogMotorLiveValues.pumpRunning == 1 {
                self.fogOn101OffLbl.text = "FOG ON"
                self.fogOn101OffLbl.textColor = GREEN_COLOR
                self.playStopBtn.setBackgroundImage(#imageLiteral(resourceName: "stopButton"), for: .normal)
            } else {
                self.fogOn101OffLbl.text = "FOG OFF"
                self.fogOn101OffLbl.textColor = DEFAULT_GRAY
                self.playStopBtn.setBackgroundImage(#imageLiteral(resourceName: "playButton"), for: .normal)
            }
           
        })
        CENTRAL_SYSTEM?.readBits(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, length: 1, startingRegister: Int32(FOG113_AUTO_HAND_BIT_ADDR), completion: { (success, response) in
            
            if response != nil{
                
                self.fogMotorLiveValues.pumpMode = Int(truncating: response![0] as! NSNumber)
                if self.fogMotorLiveValues.pumpMode == 1{
                    //If is in manual mode on the ipad
                    self.changeAutManModeIndicatorRotation(autoMode: false, tag: 1)
                    self.fogOn101ModeLbl.text = "FOG HAND MODE"
                    self.playStopBtn.alpha = 1
                }else{
                    //If is in auto mode on the ipad
                    self.playStopBtn.alpha = 0
                    self.fogOn101ModeLbl.text = "FOG AUTO MODE"
                    self.changeAutManModeIndicatorRotation(autoMode: true, tag: 1)
                }
            }
        })
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
        if tag == 1{
            if autoMode == true {
                
                self.autoMode101IImg.alpha = 1
                self.handMode101Img.alpha = 0
                
            }else{
                
                self.handMode101Img.alpha = 1
                self.autoMode101IImg.alpha = 0
                
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
                CENTRAL_SYSTEM?.writeBit(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, bit: FOG113_AUTO_HAND_BIT_ADDR, value: 0)
                
            } else if self.fogMotorLiveValues.pumpMode == 0{
                //In auto mode, change it to manual mode
                CENTRAL_SYSTEM?.writeBit(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, bit: FOG113_AUTO_HAND_BIT_ADDR, value: 1)
                
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
                CENTRAL_SYSTEM?.writeBit(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, bit: FOG113_PLAY_STOP_BIT_ADDR, value: 0)
            } else if self.fogMotorLiveValues.pumpRunning == 0{
                CENTRAL_SYSTEM?.writeBit(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, bit: FOG113_PLAY_STOP_BIT_ADDR, value: 1)
            }
        }
    }
}
