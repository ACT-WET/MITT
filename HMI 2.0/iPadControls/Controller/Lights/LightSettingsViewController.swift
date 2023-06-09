//
//  LightSettingsViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 5/10/23.
//  Copyright © 2023 WET. All rights reserved.
//

import UIKit

class LightSettingsViewController: UIViewController {
    //Timer Delay SP
    @IBOutlet weak var abovHSPDelay:    UITextField!
    @IBOutlet weak var belowLSPDelay:   UITextField!
    @IBOutlet weak var belowLLSPDelay:  UITextField!
    @IBOutlet weak var makeupTimeout:   UITextField!
    
    //No Connection View
    @IBOutlet weak var noConnectionView: UIView!
    @IBOutlet weak var noConnectionLbl:  UILabel!
    
    //Object References
    let logger = Logger()
    private var centralSystem = CentralSystem()
    var currentSetpoints = WATER_LEVEL_SENSOR_VALUES()
    var lt1001liveSensorValues  = WATER_LEVEL_SENSOR_VALUES()
    var LT1001SetPoints = [Double]()
    var readLT1001once = false
    var readLT1002once = false
    var readLT1003once = false
    var readCurrentSPOnce = false
    
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
     * Comment  :
     ***************************************************************************/
    
    override func viewWillAppear(_ animated: Bool) {
        constructSaveButton()
        readTimersFromPLC()
        
        //Add notification observer to get system stat
        NotificationCenter.default.addObserver(self, selector: #selector(checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
        
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
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
     * Function :  checkSystemStat
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    @objc func checkSystemStat(){
        let (plcConnection,_,_,_) = (CENTRAL_SYSTEM?.getConnectivityStat())!
        
        if plcConnection == CONNECTION_STATE_CONNECTED {
            //Change the connection stat indicator
            noConnectionView.alpha = 0
            noConnectionView.isUserInteractionEnabled = false
            if CENTRAL_SYSTEM == nil{
                       
               CENTRAL_SYSTEM = CentralSystem()
               
               //Initialize the central system so we can establish all the system config
               CENTRAL_SYSTEM?.initialize()
               CENTRAL_SYSTEM?.getNetworkParameters()
               CENTRAL_SYSTEM?.mittlagconnect()
                       
            }
            //Now that the connection is established, run functions
            
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
    

    
    /***************************************************************************
     * Function :  saveSetpoints
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    @objc private func saveSetpoints(){
       saveTimerSetpointDelaysToPLC()
    }
    
    /***************************************************************************
     * Function :  saveSetpointDelaysToPLC
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    private func saveTimerSetpointDelaysToPLC(){
        
        let aboveHiSPDelay = Int(abovHSPDelay.text!)
        let belowLDelay = Int(belowLSPDelay.text!)
        let belowLLDelay = Int(belowLLSPDelay.text!)
        let mkpTimeout = Int(makeupTimeout.text!)
        
        guard aboveHiSPDelay != nil && belowLSPDelay != nil && belowLLSPDelay != nil && makeupTimeout != nil else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.50) {
                self.readTimersFromPLC()
            }
            return
        }
        
        CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: WATER_LEVEL_ABOVE_H_DELAY_TIMER, value: aboveHiSPDelay!)
        CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: WATER_LEVEL_BELOW_L_TIMER, value: belowLDelay!)
        CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: WATER_LEVEL_BELOW_LL_TIMER, value: belowLLDelay!)
        CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: WATER_MAKEUP_TIMEROUT_TIMER, value: mkpTimeout!)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.50) {
            self.readTimersFromPLC()
        }
    }

    
    /***************************************************************************
     * Function :  readTimersFromPLC
     * Input    :  none
     * Output   :  none
     * Comment  :  Reads the timer values and passes to the settings page
     ***************************************************************************/
  
    
    private func readTimersFromPLC(){
        

            CENTRAL_SYSTEM?.readRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, length: Int32(WATER_LEVEL_TIMER_BITS.count), startingRegister: Int32(WATER_LEVEL_TIMER_BITS.startBit),  completion: { (success, response) in
                
                guard success == true else { return }
                
                CENTRAL_SYSTEM?.readRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, length:1, startingRegister: Int32(WATER_MAKEUP_TIMEROUT_TIMER), completion: { (success, resonse) in
                    
                    guard success == true else { return }
                    self.currentSetpoints.above_high_timer =  Int(truncating: response![0] as! NSNumber)
                    self.currentSetpoints.below_l_timer   =  Int(truncating: response![1] as! NSNumber)
                    self.currentSetpoints.below_ll_timer  =  Int(truncating: response![2] as! NSNumber)
                    self.currentSetpoints.makeup_timeout_timer = Int(truncating: resonse![0] as! NSNumber)

                    self.abovHSPDelay.text       = "\(self.currentSetpoints.above_high_timer)"
                    self.belowLSPDelay.text      = "\(self.currentSetpoints.below_l_timer)"
                    self.belowLLSPDelay.text     = "\(self.currentSetpoints.below_ll_timer)"
                    self.makeupTimeout.text      = "\(self.currentSetpoints.makeup_timeout_timer)"
                })
            })
   
    }
}
