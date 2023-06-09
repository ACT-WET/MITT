//
//  LakeWaterLevelViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 12/23/22.
//  Copyright © 2022 WET. All rights reserved.
//

import UIKit

class LakeWaterLevelViewController: UIViewController {

//MARK: - UI View Outlets
 
 @IBOutlet weak var waterLevelIcon:                      UIImageView!
 @IBOutlet weak var noConnectionView:                    UIView!
 @IBOutlet weak var noConnectionErrorLbl:                UILabel!
 
 //MARK: - Water Level Sensors Faults
 @IBOutlet weak var lt1001View: UIView!
 
 @IBOutlet weak var lowWaterNoShow: UIImageView!
 @IBOutlet weak var fillTimeout:                         UIImageView!
 
 //MARK: - Class Reference Objects -- Dependencies
 
 private let logger          =          Logger()
 private let helper          =          Helper()
 private let utility         =         Utilits()
 private let operationManual = OperationManual()
 private var centralSystem = CentralSystem()
 //MARK: - Data Structures
 
 private var langData          = Dictionary<String, String>()
 private var lt1001liveSensorValues  = WATER_LEVEL_SENSOR_VALUES()
 private var lt1002liveSensorValues  = WATER_LEVEL_SENSOR_VALUES()
 
 private var acquiredTimersFromPLC = 0
 
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
  * Function :  viewDidAppear
  * Input    :  none
  * Output   :  none
  * Comment  :
  ***************************************************************************/
 
 override func viewWillAppear(_ animated: Bool){
     centralSystem.getNetworkParameters()
     centralSystem.mittlaconnect()
     CENTRAL_SYSTEM = centralSystem
     //Add notification observer to get system stat
     NotificationCenter.default.addObserver(self, selector: #selector(WaterLevelViewController.checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
     
     //Configure Water Level Screen
     configureWaterLevel()
     
     //Configure WaterLeveScreen Text Content Based On Device Language
     configureScreenTextContent()

     
 }
 
 /***************************************************************************
  * Function :  viewDidDisappear
  * Input    :  none
  * Output   :  none
  * Comment  :
  ***************************************************************************/
 
 override func viewWillDisappear(_ animated: Bool){
     
     NotificationCenter.default.removeObserver(self)
     
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
         
         //Now that the connection is established, run functions
         parseWaterLevelFaults()
         readWaterLevelLiveValues()
         
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
  * Function :  configureWaterLevel
  * Input    :  none
  * Output   :  none
  * Comment  :
  ***************************************************************************/
 
 private func configureWaterLevel(){
     
     acquiredTimersFromPLC = 0
     
 }
 
 /***************************************************************************
  * Function :  configureScreenTextContent
  * Input    :  none
  * Output   :  none
  * Comment  :
  ***************************************************************************/
 
 private func configureScreenTextContent(){
     
     langData = self.helper.getLanguageSettigns(screenName: WATER_LEVEL_LANGUAGE_DATA_PARAM)
     self.navigationItem.title = "WATER LEVEL"
            
 }
 

 
 /***************************************************************************
  * Function :  readWaterLevelLiveValues
  * Input    :  none
  * Output   :  none
  * Comment  :
  ***************************************************************************/
 
 private func readWaterLevelLiveValues(){
     
     CENTRAL_SYSTEM?.readBits(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, length: Int32(AL_WATER_LEVEL_SENSOR_BITS_1.count) , startingRegister: Int32(AL_WATER_LEVEL_SENSOR_BITS_1.startBit), completion: { (sucess, response) in
         
         //Check points to make sure the PLC Call was successful
         
         guard sucess == true else{
             self.logger.logData(data: "WATER LEVEL FAILED TO GET RESPONSE FROM ATHO PLC")
             return
         }
         self.lt1001liveSensorValues.channelFault           = Int(truncating: response![0] as! NSNumber)
         self.lt1001liveSensorValues.above_High            = Int(truncating: response![1] as! NSNumber)
         self.lt1001liveSensorValues.below_l               = Int(truncating: response![2] as! NSNumber)
         self.lt1001liveSensorValues.below_ll              = Int(truncating: response![3] as! NSNumber)
         self.lt1001liveSensorValues.below_lll              = Int(truncating: response![4] as! NSNumber)
         self.lt1001liveSensorValues.waterMakeupTimeout    = Int(truncating: response![5] as! NSNumber)
         self.lt1001liveSensorValues.waterMakeup           = Int(truncating: response![6] as! NSNumber)
         
         CENTRAL_SYSTEM!.readRealRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: AL_WATER_LEVEL_LT1101_SCALED_VALUE_BIT, length: 2){ (success, response)  in
                    
            guard success == true else{
                return
            }
            self.lt1001liveSensorValues.scaledValue = Double(response)!
             self.parseLT1001Data()
         }
         
     })
     
     CENTRAL_SYSTEM?.readBits(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, length: Int32(AL_WATER_LEVEL_SENSOR_BITS_2.count) , startingRegister: Int32(AL_WATER_LEVEL_SENSOR_BITS_2.startBit), completion: { (sucess, response) in
         
         //Check points to make sure the PLC Call was successful
         
         guard sucess == true else{
             self.logger.logData(data: "WATER LEVEL FAILED TO GET RESPONSE FROM ATHO PLC")
             return
         }
         self.lt1002liveSensorValues.channelFault           = Int(truncating: response![0] as! NSNumber)
         self.lt1002liveSensorValues.above_High            = Int(truncating: response![1] as! NSNumber)
         self.lt1002liveSensorValues.below_l               = Int(truncating: response![2] as! NSNumber)
         self.lt1002liveSensorValues.below_ll              = Int(truncating: response![3] as! NSNumber)
        self.lt1002liveSensorValues.below_lll              = Int(truncating: response![4] as! NSNumber)
         self.lt1002liveSensorValues.waterMakeupTimeout    = Int(truncating: response![5] as! NSNumber)
         self.lt1002liveSensorValues.waterMakeup           = Int(truncating: response![6] as! NSNumber)
         
         CENTRAL_SYSTEM!.readRealRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: AL_WATER_LEVEL_LT2101_SCALED_VALUE_BIT, length: 2){ (success, response)  in
                    
            guard success == true else{
                return
            }
            self.lt1002liveSensorValues.scaledValue = Double(response)!
             self.parseLT1002Data()
         }
         
     })
     
     CENTRAL_SYSTEM?.readBits(plcIpAddress:MITT_LA_PLC_IP_ADDRESS, length: 2, startingRegister: Int32(ALIGHTLSLL_LIGHTS), completion: { (success, response) in
         
         guard success == true else { return }
         
         let resp1 = Int(truncating: response![0] as! NSNumber)
         let resp2 = Int(truncating: response![1] as! NSNumber)
         let blwLL1 = self.lt1001View.viewWithTag(2021) as? UIImageView
         let blwLL2 = self.lt1001View.viewWithTag(2022) as? UIImageView
        
        if resp1 == 1
        {
            blwLL1?.image = #imageLiteral(resourceName: "red")
        } else {
            blwLL1?.image = #imageLiteral(resourceName: "green")
        }
        if resp2 == 1
        {
            blwLL2?.image = #imageLiteral(resourceName: "red")
        } else {
            blwLL2?.image = #imageLiteral(resourceName: "green")
        }
         
     })
     
 }
 
 
 /***************************************************************************
  * Function :  parseWaterLevelFaults
  * Input    :  none
  * Output   :  none
  * Comment  :
  ***************************************************************************/
 
 private func parseWaterLevelFaults(){
     
     if lt1001liveSensorValues.channelFault == 1 || lt1002liveSensorValues.channelFault == 1  {
         waterLevelIcon.image = #imageLiteral(resourceName: "waterlevel_outline-red")
     } else {
         waterLevelIcon.image = #imageLiteral(resourceName: "waterlevel_outline-gray")
     }
     
     if lt1001liveSensorValues.waterMakeupTimeout == 1 || lt1002liveSensorValues.waterMakeupTimeout == 1 {
         fillTimeout.alpha = 1
     } else {
         fillTimeout.alpha = 0
     }
 }
 
 func parseLT1001Data(){
     
            let scaledValue = self.lt1001View.viewWithTag(2001) as? UILabel
            let abvH = self.lt1001View.viewWithTag(2002) as? UIImageView
            let blwL = self.lt1001View.viewWithTag(2003) as? UIImageView
            let blwLL = self.lt1001View.viewWithTag(2004) as? UIImageView
            let blwLLL = self.lt1001View.viewWithTag(2005) as? UIImageView
            let chFault = self.lt1001View.viewWithTag(2006) as? UIImageView
            let makeupOn = self.lt1001View.viewWithTag(2007) as? UILabel
            let makeupTimeout = self.lt1001View.viewWithTag(2008) as? UIImageView
     
            scaledValue?.text = String(format: "%.1f", self.lt1001liveSensorValues.scaledValue)
     
            if self.lt1001liveSensorValues.above_High == 1
            {
                abvH?.image = #imageLiteral(resourceName: "red")
            } else {
                abvH?.image = #imageLiteral(resourceName: "green")
            }
            
            if self.lt1001liveSensorValues.below_l == 1
            {
                blwL?.image = #imageLiteral(resourceName: "red")
            } else {
                blwL?.image = #imageLiteral(resourceName: "green")
            }
            
            if self.lt1001liveSensorValues.below_ll == 1
            {
                blwLL?.image = #imageLiteral(resourceName: "red")
            } else {
                blwLL?.image = #imageLiteral(resourceName: "green")
            }
    
            if self.lt1001liveSensorValues.below_lll == 1
            {
                blwLLL?.image = #imageLiteral(resourceName: "red")
            } else {
                blwLLL?.image = #imageLiteral(resourceName: "green")
            }
     
            if self.lt1001liveSensorValues.channelFault == 1
            {
                chFault?.image = #imageLiteral(resourceName: "red")
            } else {
                chFault?.image = #imageLiteral(resourceName: "green")
            }
    
            if self.lt1001liveSensorValues.waterMakeup == 1 {
                makeupOn?.text = "ON"
            } else {
                makeupOn?.text = "OFF"
            }
    
            if self.lt1001liveSensorValues.waterMakeupTimeout == 1 {
                makeupTimeout?.image = #imageLiteral(resourceName: "red")
            } else {
                makeupTimeout?.image = #imageLiteral(resourceName: "green")
            }
 }
 
 func parseLT1002Data(){
     
            let scaledValue = self.lt1001View.viewWithTag(2011) as? UILabel
            let abvH = self.lt1001View.viewWithTag(2012) as? UIImageView
            let blwL = self.lt1001View.viewWithTag(2013) as? UIImageView
            let blwLL = self.lt1001View.viewWithTag(2014) as? UIImageView
            let blwLLL = self.lt1001View.viewWithTag(2015) as? UIImageView
            let chFault = self.lt1001View.viewWithTag(2016) as? UIImageView
            let makeupOn = self.lt1001View.viewWithTag(2017) as? UILabel
            let makeupTimeout = self.lt1001View.viewWithTag(2018) as? UIImageView
     
            scaledValue?.text = String(format: "%.1f", self.lt1002liveSensorValues.scaledValue)
     
            if self.lt1002liveSensorValues.above_High == 1
            {
                abvH?.image = #imageLiteral(resourceName: "red")
            } else {
                abvH?.image = #imageLiteral(resourceName: "green")
            }
            
            if self.lt1002liveSensorValues.below_l == 1
            {
                blwL?.image = #imageLiteral(resourceName: "red")
            } else {
                blwL?.image = #imageLiteral(resourceName: "green")
            }
            
            if self.lt1002liveSensorValues.below_ll == 1
            {
                blwLL?.image = #imageLiteral(resourceName: "red")
            } else {
                blwLL?.image = #imageLiteral(resourceName: "green")
            }
            
            if self.lt1002liveSensorValues.below_lll == 1
            {
                blwLLL?.image = #imageLiteral(resourceName: "red")
            } else {
                blwLLL?.image = #imageLiteral(resourceName: "green")
            }
     
            if self.lt1002liveSensorValues.channelFault == 1
            {
                chFault?.image = #imageLiteral(resourceName: "red")
            } else {
                chFault?.image = #imageLiteral(resourceName: "green")
            }
     
            if self.lt1002liveSensorValues.waterMakeup == 1 {
                makeupOn?.text = "ON"
            } else {
                makeupOn?.text = "OFF"
            }
     
            if self.lt1002liveSensorValues.waterMakeupTimeout == 1 {
                makeupTimeout?.image = #imageLiteral(resourceName: "red")
            } else {
                makeupTimeout?.image = #imageLiteral(resourceName: "green")
            }
 }
 
 @IBAction func settingsButtonPressed(_ sender: UIButton) {
    self.addAlertAction(button: sender)
 }
}
