//
//  LakeWaterLevelSettingsViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 12/23/22.
//  Copyright © 2022 WET. All rights reserved.
//

import UIKit

class LakeWaterLevelSettingsViewController: UIViewController {
    
    //Timer Delay SP
    @IBOutlet weak var abovHSPDelay:    UITextField!
    @IBOutlet weak var belowLSPDelay:   UITextField!
    @IBOutlet weak var belowLLSPDelay:  UITextField!
    @IBOutlet weak var belowLLLSPDelay:  UITextField!
    @IBOutlet weak var makeupTimeout:   UITextField!
    
     @IBOutlet weak var lt1001ScaledVal:   UILabel!
     @IBOutlet weak var lt1001ScaledMin:   UITextField!
     @IBOutlet weak var lt1001ScaledMax:   UITextField!
     @IBOutlet weak var lt1001abvHSP:   UITextField!
     @IBOutlet weak var lt1001blwLSP:   UITextField!
     @IBOutlet weak var lt1001blwLLSP:   UITextField!
     @IBOutlet weak var lt1001blwLLLSP:   UITextField!
    
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
        let (_,plcConnection,_,_) = (CENTRAL_SYSTEM?.getConnectivityStat())!
        
        if plcConnection == CONNECTION_STATE_CONNECTED {
            //Change the connection stat indicator
            noConnectionView.alpha = 0
            noConnectionView.isUserInteractionEnabled = false
            if CENTRAL_SYSTEM == nil{
                       
               CENTRAL_SYSTEM = CentralSystem()
               
               //Initialize the central system so we can establish all the system config
               CENTRAL_SYSTEM?.initialize()
               CENTRAL_SYSTEM?.getNetworkParameters()
               CENTRAL_SYSTEM?.mittlaconnect()
                       
            }
            //Now that the connection is established, run functions
            //LT6201
            CENTRAL_SYSTEM?.readRealRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: Int(AL_WATER_LEVEL_LT1101_SCALED_VALUE_BIT), length: 2, completion: { (success, response) in
               guard success == true else { return }
               let scaledVal = Float(response)
               self.lt1001ScaledVal.text =  String(format: "%.2f", scaledVal!)
            })
            
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
        let belowLLLDelay = Int(belowLLLSPDelay.text!)
        let mkpTimeout = Int(makeupTimeout.text!)
        
        guard aboveHiSPDelay != nil && belowLSPDelay != nil && belowLLSPDelay != nil && makeupTimeout != nil && belowLLLSPDelay != nil  else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.50) {
                self.readTimersFromPLC()
            }
            return
        }
        
        CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: WATER_LEVEL_ABOVE_H_DELAY_TIMER, value: aboveHiSPDelay!)
        CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: WATER_LEVEL_BELOW_L_TIMER, value: belowLDelay!)
        CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: WATER_LEVEL_BELOW_LL_TIMER, value: belowLLDelay!)
        CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: WATER_LEVEL_BELOW_LLL_TIMER, value: belowLLLDelay!)
        CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: WATER_MAKEUP_TIMEROUT_TIMER, value: mkpTimeout!)
        
        //LT1101
        let scalMin = Float(lt1001ScaledMin.text!)
        let scalMax = Float(lt1001ScaledMax.text!)
        let aboveH = Float(lt1001abvHSP.text!)
        let belowL = Float(lt1001blwLSP.text!)
        let belowLL = Float(lt1001blwLLSP.text!)
        let belowLLL = Float(lt1001blwLLLSP.text!)
        
        guard scalMin != nil && scalMax != nil && aboveH != nil && belowL != nil && belowLL != nil && belowLLL != nil else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.50) {
                self.readTimersFromPLC()
            }
            return
        }
        //LT1101
        CENTRAL_SYSTEM!.writeRealValue(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: LT1001_WATER_LEVEL_SCALED_MIN, value: scalMin!)
        CENTRAL_SYSTEM!.writeRealValue(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: LT1001_WATER_LEVEL_SCALED_MAX, value: scalMax!)
        CENTRAL_SYSTEM!.writeRealValue(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: LT1001_WATER_ABOVE_HI, value: aboveH!)
        CENTRAL_SYSTEM!.writeRealValue(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: LT1001_WATER_LEVEL_BELOW_L, value: belowL!)
        CENTRAL_SYSTEM!.writeRealValue(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: LT1001_WATER_LEVEL_BELOW_LL, value: belowLL!)
        CENTRAL_SYSTEM!.writeRealValue(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: LT1001_WATER_LEVEL_BELOW_LLL, value: belowLLL!)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.50) {
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
        

            CENTRAL_SYSTEM?.readRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, length: Int32(WATER_LEVEL_TIMER_BITS.count), startingRegister: Int32(WATER_LEVEL_TIMER_BITS.startBit),  completion: { (success, response) in
                
                guard success == true else { return }
                
                CENTRAL_SYSTEM?.readRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, length:1, startingRegister: Int32(WATER_MAKEUP_TIMEROUT_TIMER), completion: { (success, resonse) in
                    
                    guard success == true else { return }
                    self.currentSetpoints.above_high_timer =  Int(truncating: response![0] as! NSNumber)
                    self.currentSetpoints.below_l_timer   =  Int(truncating: response![1] as! NSNumber)
                    self.currentSetpoints.below_ll_timer  =  Int(truncating: response![2] as! NSNumber)
                    self.currentSetpoints.below_lll_timer  =  Int(truncating: response![3] as! NSNumber)
                    self.currentSetpoints.makeup_timeout_timer = Int(truncating: resonse![0] as! NSNumber)

                    self.abovHSPDelay.text       = "\(self.currentSetpoints.above_high_timer)"
                    self.belowLSPDelay.text      = "\(self.currentSetpoints.below_l_timer)"
                    self.belowLLSPDelay.text     = "\(self.currentSetpoints.below_ll_timer)"
                    self.belowLLLSPDelay.text     = "\(self.currentSetpoints.below_lll_timer)"
                    self.makeupTimeout.text      = "\(self.currentSetpoints.makeup_timeout_timer)"
                })
            })
            
            
        
            //LT1101
            CENTRAL_SYSTEM?.readRealRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: Int(LT1001_WATER_ABOVE_HI), length: 2, completion: { (success, response) in
               guard success == true else { return }
               let abvH = Float(response)
               self.lt1001abvHSP.text =  String(format: "%.1f", abvH!)
            })
            CENTRAL_SYSTEM?.readRealRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: Int(LT1001_WATER_LEVEL_BELOW_L), length: 2, completion: { (success, response) in
               guard success == true else { return }
                let blwL = Float(response)
               self.lt1001blwLSP.text =  String(format: "%.1f", blwL!)
            })
            CENTRAL_SYSTEM?.readRealRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: Int(LT1001_WATER_LEVEL_BELOW_LL), length: 2, completion: { (success, response) in
               guard success == true else { return }
                let blwLL = Float(response)
               self.lt1001blwLLSP.text =  String(format: "%.1f", blwLL!)
            })
            CENTRAL_SYSTEM?.readRealRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: Int(LT1001_WATER_LEVEL_BELOW_LLL), length: 2, completion: { (success, response) in
                guard success == true else { return }
                let blwLLL = Float(response)
                self.lt1001blwLLLSP.text =  String(format: "%.1f", blwLLL!)
            })
            CENTRAL_SYSTEM?.readRealRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: Int(LT1001_WATER_LEVEL_SCALED_MIN), length: 2, completion: { (success, response) in
               guard success == true else { return }
               let minVal = Float(response)
               self.lt1001ScaledMin.text =  String(format: "%.1f", minVal!)
            })
            CENTRAL_SYSTEM?.readRealRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: Int(LT1001_WATER_LEVEL_SCALED_MAX), length: 2, completion: { (success, response) in
               guard success == true else { return }
               let maxVal = Float(response)
               self.lt1001ScaledMax.text =  String(format: "%.1f", maxVal!)
            })
   
    }
}
