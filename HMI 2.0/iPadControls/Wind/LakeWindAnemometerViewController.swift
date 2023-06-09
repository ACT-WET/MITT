//
//  LakeWindAnemometerViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 6/8/23.
//  Copyright © 2023 WET. All rights reserved.
//

import UIKit

class LakeWindAnemometerViewController: UIViewController,UIGestureRecognizerDelegate {
   
    //MARK: - Class Reference Objects -- Dependencies
    private let logger = Logger()
    private let helper = Helper()
    
    var connection          = 0
    var sensorNumber        = 0
    var fetchedSetpoints    = 0
    var wind_sensors:  Array<Any>?
    var wind_sensors2: Array<Any>?
    var pixelsPerUnit       = 0.0
    var aboveHigh           = 0.0
    var aboveMed           = 0.0
    var belowLow            = 0.0
    var highSP              = 0
    var lowSP               = 0
    var medSP               = 0
    var abortSetPoint       = 0.0
    
    var belowylocation:CGFloat     = 0.0
    var mediumylocation:CGFloat     = 0.0
    var aboveylocation:CGFloat     = 0.0
    
    var currentAbortSetpointRegister = 0
    var aboveSetPoint: UIPanGestureRecognizer!
    var medumSetPoint: UIPanGestureRecognizer!
    var belowSetPoint: UIPanGestureRecognizer!

    @IBOutlet weak var abortSPView: UIView!
    @IBOutlet weak var belowLView: UIView!
    @IBOutlet weak var abortSetpointLbl:    UILabel!
    @IBOutlet weak var windSpeedIndicator:  UIView!
    @IBOutlet weak var windSpeedLbl:        UILabel!
    @IBOutlet weak var rangeBackground:     UIView!
    @IBOutlet weak var mediumrangeBackground: UIView!
    @IBOutlet weak var upperrangeBackground: UIView!
    @IBOutlet weak var lowerrangeBackground: UIView!
    @IBOutlet weak var aboveHView: UIView!
    @IBOutlet weak var abortSPTextField: UITextField!
    @IBOutlet weak var medView: UIView!
    
    @IBOutlet weak var aboveSP: UILabel!
    @IBOutlet weak var mediumSP: UILabel!
    @IBOutlet weak var belowSP: UILabel!
    private var centralSystem = CentralSystem()
    
    
    
    /***************************************************************************
     * Function :  viewDidLoad
     * Input    :  none
     * Output   :  none
     * Comment  :
     *
     ***************************************************************************/
    
    override func viewDidLoad(){
        
        super.viewDidLoad()
        
    
    }
    override func viewWillAppear(_ animated: Bool){
        //Get Wind Parameters From Local Storage
        if CENTRAL_SYSTEM == nil{
            CENTRAL_SYSTEM = CentralSystem()
            centralSystem.getNetworkParameters()
            centralSystem.mittlaconnect()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
        initializePumpGestureRecognizer()
    }
    
    private func initializePumpGestureRecognizer(){
        
        //RME: Initiate PUMP Flow Control Gesture Handler
        
        aboveSetPoint = UIPanGestureRecognizer(target: self, action: #selector(changeAboveSP(sender:)))
        belowSetPoint = UIPanGestureRecognizer(target: self, action: #selector(changeBelowSP(sender:)))
        medumSetPoint = UIPanGestureRecognizer(target: self, action: #selector(changeMediumSP(sender:)))
        aboveHView.isUserInteractionEnabled = true
        aboveHView.addGestureRecognizer(self.aboveSetPoint)
        aboveSetPoint.delegate = self
        medView.isUserInteractionEnabled = true
        medView.addGestureRecognizer(self.medumSetPoint)
        medumSetPoint.delegate = self
        belowLView.isUserInteractionEnabled = true
        belowLView.addGestureRecognizer(self.belowSetPoint)
        belowSetPoint.delegate = self
        
    }
    
    @objc func changeAboveSP(sender: UIPanGestureRecognizer){
        
        aboveHView.isUserInteractionEnabled = true
        aboveSP.textColor = GREEN_COLOR
        var touchLocation:CGPoint = sender.location(in: self.view)
        if touchLocation.y <= 35.8 {
            touchLocation.y = 35.8
        }
        if touchLocation.y > 35.7 && touchLocation.y <= mediumylocation - 8.62 {
            
            sender.view?.center.y = touchLocation.y
            
            let flowRange = 467 - Int(touchLocation.y)
            let herts = Double(flowRange)/(self.pixelsPerUnit)
            let formattedHerts = String(format: "%.1f", herts)
            //NOTE: We multiply the frequency by 10 because PLC expects 3 digit number
            
            aboveSP.text = formattedHerts
            
            if sender.state == .ended {
                aboveylocation = CGFloat(touchLocation.y)
                CENTRAL_SYSTEM?.writeRealValue(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: self.highSP, value: Float(formattedHerts)!)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.50) {
                    self.readSetpointAgain()
                }
            }
        } else {
            aboveSP.textColor = RED_COLOR
        }
    }
    
    @objc func changeMediumSP(sender: UIPanGestureRecognizer){
        
        medView.isUserInteractionEnabled = true
        mediumSP.textColor = GREEN_COLOR
        let touchLocation:CGPoint = sender.location(in: self.view)
        if touchLocation.y > aboveylocation + 42 && touchLocation.y <= belowylocation {
            
            sender.view?.center.y = touchLocation.y
            
            let flowRange = 467 - Int(touchLocation.y)
            let herts = Double(flowRange)/(self.pixelsPerUnit)
            let formattedHerts = String(format: "%.1f", herts)
            //NOTE: We multiply the frequency by 10 because PLC expects 3 digit number
            
            mediumSP.text = formattedHerts
            
            if sender.state == .ended {
                mediumylocation=touchLocation.y
                CENTRAL_SYSTEM?.writeRealValue(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: self.medSP, value: Float(formattedHerts)!)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.50) {
                    self.readSetpointAgain()
                }
            }
        } else {
            mediumSP.textColor = RED_COLOR
        }
    }
    
    @objc func changeBelowSP(sender: UIPanGestureRecognizer){
        
        belowLView.isUserInteractionEnabled = true
        belowSP.textColor = GREEN_COLOR
        var touchLocation:CGPoint = sender.location(in: self.view)
        print(touchLocation.y)
        if touchLocation.y >= 467 {
            touchLocation.y = 467
        }
        if touchLocation.y >= mediumylocation + 25.86 && touchLocation.y < 468 {
            
            sender.view?.center.y = touchLocation.y
            
            let flowRange = 467 - Int(touchLocation.y)
            let herts = Double(flowRange)/(self.pixelsPerUnit)
            let formattedHerts = String(format: "%.1f", herts)
            //NOTE: We multiply the frequency by 10 because PLC expects 3 digit number
            
            
            belowSP.text = formattedHerts
            
            if sender.state == .ended {
                belowylocation = CGFloat(touchLocation.y)
                CENTRAL_SYSTEM?.writeRealValue(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: self.lowSP, value: Float(formattedHerts)!)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.50) {
                    self.readSetpointAgain()
                }
            }
        } else {
            belowSP.textColor = RED_COLOR
        }
    }
    
    /***************************************************************************
     * Function :  viewWillDisappear
     * Input    :  none
     * Output   :  none
     * Comment  :
     *
     ***************************************************************************/
    
    override func viewWillDisappear(_ animated: Bool){
        
        NotificationCenter.default.removeObserver(self)
        
    }
    
    /***************************************************************************
     * Function :  checkSystemStat
     * Input    :  none
     * Output   :  none
     * Comment  :
     *
     ***************************************************************************/
    
    @objc private func checkSystemStat(){
        
        let (_,plcConnection,_,_) = CENTRAL_SYSTEM!.getConnectivityStat()
        
        self.connection = plcConnection
        
        if plcConnection == CONNECTION_STATE_CONNECTED{
            
            self.getCurrentWindSpeed()
            
        }
        
    }
    
    
    /***************************************************************************
     * Function :  getCurrentWindSpeed
     * Input    :  none
     * Output   :  none
     * Comment  :
     *
     ***************************************************************************/
    
    private func getCurrentWindSpeed(){
        
        //TODO: Find a way to not make PLC calls again. Just get it from previous page
        
        switch sensorNumber{
            
        case 101:
            let windSensor1 = wind_sensors?[0] as! WIND_SENSOR_1
            self.currentAbortSetpointRegister = windSensor1.SPEED_ABORT_SET_POINT.register
            self.highSP = windSensor1.SPEED_HIGH_SET_POINT.register
            self.medSP = windSensor1.SPEED_MED_SET_POINT.register
            self.lowSP = windSensor1.SPEED_LOW_SET_POINT.register
            self.getWindSpeedReading(windSpeedRegister: windSensor1.SPEED_SCALED_VALUE.register, windAbortSetpoint: windSensor1.SPEED_ABORT_SET_POINT.register, aboveHigh:windSensor1.SPEED_HIGH_SET_POINT.register,aboveMed:windSensor1.SPEED_MED_SET_POINT.register,belowLow: windSensor1.SPEED_LOW_SET_POINT.register)
        default:
            
            self.logger.logData(data: "WIND SENSOR NOT FOUND")
            
        }
        
        
        
    }
    
    /***************************************************************************
     * Function :  getWindSpeedReading
     * Input    :  none
     * Output   :  none
     * Comment  :
     *
     ***************************************************************************/
    
    private func getWindSpeedReading(windSpeedRegister:Int, windAbortSetpoint:Int, aboveHigh:Int, aboveMed:Int, belowLow:Int){
        
        if self.fetchedSetpoints != 1{
            self.readSetpoints(aboveHighSetPoint: aboveHigh, mediumSetpoint: aboveMed, belowLowSetpoint: belowLow, abortSP: windAbortSetpoint)
            
            self.fetchedSetpoints = 1
            
        }else{
            
            CENTRAL_SYSTEM!.readRealRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: windSpeedRegister, length: 2){ (success, response)  in
                
                guard success == true else{
                    return
                }
                
                let windSpeed = Double(response)!
                self.windSpeedLbl.text = String(format: "%.1f", windSpeed)
                let windSpeedYPosition = (windSpeed * self.pixelsPerUnit)
                
                if windSpeed >= self.abortSetPoint {
                    self.windSpeedIndicator.frame = CGRect(x: 20, y: 26, width: 102, height: 23)
                } else if windSpeed <= 0 {
                    self.windSpeedIndicator.frame = CGRect(x: 20, y: 455, width: 102, height: 23)
                } else {
                    self.windSpeedIndicator.frame = CGRect(x: 20, y: 455 - windSpeedYPosition, width: 102, height: 23)
                }
            }
        }
        
    }
    
    
    /***************************************************************************
     * Function :  readSetpoints
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    private func readSetpoints(aboveHighSetPoint: Int, mediumSetpoint:Int, belowLowSetpoint: Int, abortSP: Int){
        CENTRAL_SYSTEM!.readRealRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: abortSP, length: 2){ (success, response)  in
            
            guard success == true else{
                return
            }
            
            self.abortSetPoint = Double(response)!
            
            let abortSPValue = String(format: "%.1f", self.abortSetPoint)
            
            if self.abortSetpointLbl != nil {
                self.abortSetpointLbl.text =  abortSPValue
                print("current abort set point successful")
            }
            CENTRAL_SYSTEM!.readRealRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: aboveHighSetPoint, length: 2){ (success, response)  in
                
                guard success == true else{
                    return
                }
                
                self.aboveHigh = Double(response)!
                
                let aboveHigh = String(format: "%.1f", self.aboveHigh)
                self.aboveSP.text =  aboveHigh
                self.aboveSP.textColor = DEFAULT_GRAY
                
                print("above high set point successful. above high sp is \(aboveHighSetPoint)")
                
                CENTRAL_SYSTEM!.readRealRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: mediumSetpoint, length: 2){ (success, response)  in
                    
                    guard success == true else{
                        return
                    }
                    
                    self.aboveMed = Double(response)!
                    
                    let aboveMed = String(format: "%.1f", self.aboveMed)
                    self.mediumSP.text =  aboveMed
                    self.mediumSP.textColor = DEFAULT_GRAY
                    
                    print("above Medium set point successful. medium sp is \(mediumSetpoint)")
                    
                    CENTRAL_SYSTEM!.readRealRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: belowLowSetpoint, length: 2){ (success, response)  in
                        
                        guard success == true else{
                            return
                        }
                        
                        self.belowLow = Double(response)!
                        if self.belowLow <= 0.2{
                            self.belowLow = 0.0
                        }
                        let belowlow = String(format: "%.1f", self.belowLow)
                        self.belowSP.text = belowlow
                        self.belowSP.textColor = DEFAULT_GRAY
                        print("below lo set point successful. above high sp is \(belowLowSetpoint)")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.50) {
                            self.parseSetPoints(above_high: self.aboveHigh, medim:self.aboveMed, below_l: self.belowLow)
                        }
                    }
                }
            }
        }
        
        
        
        
        
        
        
        
        
        
        
    }
    
    /***************************************************************************
     * Function :  parseSetPoints
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    func parseSetPoints(above_high:Double, medim:Double, below_l:Double){
        if abortSetPoint != 0 {
            pixelsPerUnit = 431.0/abortSetPoint
//            print("high set point successful. above high sp is \(above_high)")
//            print("medium set point successful. above high sp is \(medim)")
//            print("below lo set point successful. above high sp is \(below_l)")
            let greenZoneRange = 467  - (above_high * self.pixelsPerUnit)
            let aboveHzone = greenZoneRange - 13
            let belowLzone = aboveHzone + (above_high - below_l) * self.pixelsPerUnit
            let medZone = belowLzone - (medim - below_l) * self.pixelsPerUnit
            rangeBackground.frame = CGRect(x: 130, y: greenZoneRange, width: 25, height: (above_high - medim) * self.pixelsPerUnit) //yellow
            lowerrangeBackground.frame = CGRect(x: 130, y: belowLzone+13, width: 25, height: (below_l) * self.pixelsPerUnit)        //green
            upperrangeBackground.frame = CGRect(x: 130, y: 36, width: 25, height: (abortSetPoint - above_high) * self.pixelsPerUnit)  //red
            aboveHView.frame = CGRect(x: 247, y: aboveHzone, width:86, height:26)
            medView.frame = CGRect(x: 247, y: medZone, width:86, height:26)
            belowLView.frame = CGRect(x: 247, y: belowLzone, width:86, height:26)
            
            aboveylocation = CGFloat(aboveHzone)
            belowylocation = CGFloat(belowLzone)
            mediumylocation = CGFloat(medZone)
        }
        
    }
    
    /***************************************************************************
     * Function :  simulateCoordinate
     * Input    :  none
     * Output   :  none
     * Comment  :  This is a fixd function. Simply returns the position of the indicator on the UI
     ***************************************************************************/
    
    func simulateCoordinate(setPoint:Double)->Double{
        
        let coordinate =  467 - (setPoint * self.pixelsPerUnit) - 20 // 20 is the offset from center of the indicator
        return coordinate
        
    }
    
    
    /***************************************************************************
     * Function :  readSetpointAgain
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    @objc private func readSetpointAgain(){
        
        fetchedSetpoints = 0
        
    }
    
    
    
    @IBAction func setNewAbortSPButtonPressed(_ sender: Any) {
        if let setpoint = abortSPTextField.text, !setpoint.isEmpty,
            let floatValue = Float(setpoint) {
            CENTRAL_SYSTEM?.writeRealValue(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: currentAbortSetpointRegister, value: floatValue)
            readSetpointAgain()
        } else {
            print("EMPTY FIELD")
        }
        
    }
}
