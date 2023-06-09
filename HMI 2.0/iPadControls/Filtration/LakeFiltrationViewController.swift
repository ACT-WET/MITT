//
//  LakeFiltrationViewController.swift
//  iPadControls
//
//  Created by Jan Manalo 7/16/18.
//  Copyright © 2018 WET. All rights reserved.
//

import UIKit

class LakeFiltrationViewController: UIViewController,UIGestureRecognizerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet weak var noConnectionView: UIView!
    @IBOutlet weak var noConnectionErrorLbl: UILabel!
    
    @IBOutlet weak var bWashRunning: UILabel!
    //MARK: - Show Stoppers
    
    @IBOutlet weak var pumpButton: UIButton!
    
    @IBOutlet weak var filterSchBtn: UIButton!
    @IBOutlet weak var filtrationRunningIndicator: UIImageView!
    @IBOutlet weak var cleanStrainerIndicator: UILabel!
    
    @IBOutlet weak var frequencyIndicator: UIView!
    @IBOutlet weak var frequencyIndicatorValue: UILabel!
    @IBOutlet weak var frequencySetpointBackground: UIView!
    
    @IBOutlet weak var bwashSpeedIndicator: UIView!
    @IBOutlet weak var bwashSpeedIndicatorValue: UILabel!
    
    @IBOutlet weak var cannotRunBwashLbl: UILabel!
    
    @IBOutlet weak var dayPicker: UIPickerView!
    @IBOutlet weak var backwashDuration: UILabel!
    
    @IBOutlet weak var backWashScheduler: UIView!
    @IBOutlet weak var countDownTimerBG: UIView!
    @IBOutlet weak var countDownTimer: UILabel!
    
    var manulPumpGesture: UIPanGestureRecognizer!
    var backWashGesture: UIPanGestureRecognizer!
    
    //MARK: - Class Reference Objects -- Dependencies
    
    private let logger = Logger()
    private let helper = Helper()
    private let utilities = Utilits()
    private let httpComm = HTTPComm()
    
    //MARK: - Data Structures
    
    private var langData = [String : String]()
    private var iPadNumber = 0
    var pumpNumber = 101
    private var bwashRunning = 0
    private var is24hours = true
    private var showStoppers = ShowStoppers()
    private var centralSystem = CentralSystem()
    
    
    //MARK: - Scheduled Backwash Info that has to be added to scheduler files on server
    //NOTE: The format is  [ShowNumber,ShowStartTime,ShowNumberm,ShowStartTime,.....] Show Start Time Format: HHMM
    private var component0AlreadySelected = false
    private var component1AlreadySelected = false
    private var component2AlreadySelected = false
    private var component3AlreadySelected = false
    private var selectedDay = 0
    private var selectedHour = 0
    private var selectedMinute = 0
    private var selectedTimeOfDay = 0
    private var duration = 0  //In Minutes
    private var backWashShowNumber = 999
    private var loadedScheduler = 0
    private var readBackWashSpeedOnce  = false
    private var frequency: Int?
    private var manualSpeed: Int?
    private var readManualSpeedPLC = false
    private var readManualSpeedOncePLC = false
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad(){
        
        super.viewDidLoad()
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool){
        centralSystem.getNetworkParameters()
        centralSystem.mittlaconnect()
        CENTRAL_SYSTEM = centralSystem
        checkAMPM()
                
        loadedScheduler = 0
        
        //Load Backwash Duration for Backwash Scheduler
        setInitialParam()
        loadBWDuration()
        
        
        initializePumpGestureRecognizer()
        initializeBackWashGestureRecognizer()
        getIpadNumber()
        
        setPumpNumber()
        
        //Add notification observer to get system stat
        
        NotificationCenter.default.addObserver(self, selector: #selector(checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
    }

    override func viewWillDisappear(_ animated: Bool){
        
        //Set pump number to
        let registersSET1 = PUMP_SETS[iPadNumber-1]
        let iPadNumberRegister = registersSET1[0]
        
        CENTRAL_SYSTEM!.writeRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: iPadNumberRegister.register, value: 0)
        
        //NOTE: We need to remove the notification observer so the PUMP stat check point will stop to avoid extra bandwith usage
        NotificationCenter.default.removeObserver(self)
        
    }
    
    func setInitialParam(){
        self.navigationItem.title = "FILTRATION - 101"
        self.pumpButton.setTitle("P - 301", for: .normal)
    }
    
    
    /***************************************************************************
     * Function :  Check System Stat
     * Input    :  none
     * Output   :  none
     * Comment  :  Checks the connection to the PLC and Server.
     Add the necessary functions that's needed to be called each time
     ***************************************************************************/
    
    @objc func checkSystemStat(){
        let (_,plcConnection,_,serverConnection) = CENTRAL_SYSTEM!.getConnectivityStat()
        
        if plcConnection == CONNECTION_STATE_CONNECTED && serverConnection == CONNECTION_STATE_CONNECTED  {
            
            //Change the connection stat indicator
            noConnectionView.alpha = 0
            
            readManualBwash()
            readBWFeedback()
            readCurrentFiltrationPumpDetails()
            readBackWashRunning()
            
        } else {
            noConnectionView.alpha = 1
            
            if plcConnection == CONNECTION_STATE_FAILED || serverConnection == CONNECTION_STATE_FAILED {
                if serverConnection == CONNECTION_STATE_CONNECTED {
                    noConnectionErrorLbl.text = "PLC CONNECTION FAILED, SERVER GOOD"
                } else if plcConnection == CONNECTION_STATE_CONNECTED{
                    noConnectionErrorLbl.text = "SERVER CONNECTION FAILED, PLC GOOD"
                } else {
                    noConnectionErrorLbl.text = "SERVER AND PLC CONNECTION FAILED"
                }
            }
            
            if plcConnection == CONNECTION_STATE_CONNECTING || serverConnection == CONNECTION_STATE_CONNECTING {
                if serverConnection == CONNECTION_STATE_CONNECTED {
                    noConnectionErrorLbl.text = "CONNECTING TO PLC, SERVER CONNECTED"
                } else if plcConnection == CONNECTION_STATE_CONNECTED{
                    noConnectionErrorLbl.text = "CONNECTING TO SERVER, PLC CONNECTED"
                } else {
                    noConnectionErrorLbl.text = "CONNECTING TO SERVER AND PLC.."
                }
            }
            
            if plcConnection == CONNECTION_STATE_POOR_CONNECTION && serverConnection == CONNECTION_STATE_POOR_CONNECTION {
                noConnectionErrorLbl.text = "SERVER AND PLC POOR CONNECTION"
            } else if plcConnection == CONNECTION_STATE_POOR_CONNECTION {
                noConnectionErrorLbl.text = "PLC POOR CONNECTION, SERVER CONNECTED"
            } else if serverConnection == CONNECTION_STATE_POOR_CONNECTION {
                noConnectionErrorLbl.text = "SERVER POOR CONNECTION, PLC CONNECTED"
            }
        }
    }
    
    /***************************************************************************
     * Function :  Set Pump Number to PLC
     * Input    :  none
     * Output   :  none
     * Comment  :  Write the pump number to the ipad register to get all the details for that pump number
     ***************************************************************************/
    
    private func setPumpNumber(){
        
        //Let the PLC know the current PUMP number
        
        let registersSET1 = PUMP_SETS[iPadNumber-1]
        let iPadNumberRegister = registersSET1[0]
        
        CENTRAL_SYSTEM!.writeRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: iPadNumberRegister.register, value: pumpNumber)
        
    }
    
    
    /***************************************************************************
     * Function :  Get Ipad Number
     * Input    :  none
     * Output   :  none
     * Comment  :  Based on the iPad Number ( 1 or 2 ) the registers will change
     ***************************************************************************/
    
    private func getIpadNumber(){
        
        let ipadNum = UserDefaults.standard.object(forKey: IPAD_NUMBER_USER_DEFAULTS_NAME) as? Int
        
        if ipadNum == nil || ipadNum == 0{
            iPadNumber = 1
        }else{
            iPadNumber = ipadNum!
        }
        
    }
    
    /***************************************************************************
     * Function :  Initialize Pump Gesture Recognizer
     * Input    :  none
     * Output   :  none
     * Comment  :  Create a gesture recogizer to ramp the freqeucny speed or the manual speed up or down
     ***************************************************************************/
    
    private func initializePumpGestureRecognizer(){
        
        //RME: Initiate PUMP Flow Control Gesture Handler
        
        manulPumpGesture = UIPanGestureRecognizer(target: self, action: #selector(changePumpSpeedFrequency(sender:)))
        //frequencyIndicator.isUserInteractionEnabled = true
        frequencyIndicator.addGestureRecognizer(self.manulPumpGesture)
        manulPumpGesture.delegate = self
        
    }
    
    
    private func initializeBackWashGestureRecognizer(){
        
        backWashGesture = UIPanGestureRecognizer(target: self, action: #selector(changeBackWashFrequency(sender:)))
        //bwashSpeedIndicator.isUserInteractionEnabled = true
        bwashSpeedIndicator.addGestureRecognizer(self.backWashGesture)
        backWashGesture.delegate = self
        
    }
    
    
    
    /***************************************************************************
     * Function :  Read Back Wash Feedback
     * Input    :  none
     * Output   :  none
     * Comment  :  We want to read the back wash status so we can decide whether user can run/schedule backwash or not
     
     RESPONSE STRUCTURE
     BWshowNumber = 999;
     "PDSH_req4BW" = 0;
     SchBWStatus = 2;
     duration = 2;
     manBWcanRun = 1;
     schDay = 6;
     schTime = 1545;
     timeLastBW = 154500;
     timeout = 86400;
     timeoutCountdown = 80917;
     trigBacklog = 0;
     
     ***************************************************************************/
    
    private func readBWFeedback(){
        
            self.httpComm.httpGetResponseFromPath(url: "\(HTTP_PASS)\(SERVER_IP2_ADDRESS):8080/readBW"){ (response) in
                
                guard let responseDictinary = response as? NSDictionary else { return }
                
                
                let backWashStatus = responseDictinary["SchBWStatus"] as? Int
                
                if self.loadedScheduler == 0 {
                    guard
                        let backWashScheduledDay = responseDictinary["schDay"] as? Int,
                        let backWashScheduledTime = responseDictinary["schTime"] as? Int else { return }
                    
                    
                    self.dayPicker.selectRow(backWashScheduledDay - 1, inComponent: 0, animated: true)
                    UserDefaults.standard.set(backWashScheduledDay, forKey: "Day")
                    
                    if self.is24hours {
                        
                        let hour = backWashScheduledTime / 100
                        let minute = backWashScheduledTime % 100
                        
                        self.dayPicker.selectRow(hour, inComponent: 1, animated: true)
                        self.dayPicker.selectRow(minute, inComponent: 2, animated: true)
                        
                        UserDefaults.standard.set(hour, forKey: "Hour")
                        UserDefaults.standard.set(minute, forKey: "Minute")
                        self.loadedScheduler = 1
                        
                        
                    } else {
                        var hour = backWashScheduledTime / 100
                        let minute = backWashScheduledTime % 100
                        let timeOfDay = hour - 12
                        
                        
                        // check if its 12 AM
                        if backWashScheduledTime < 60 {
                            self.dayPicker.selectRow(11, inComponent: 1, animated: true)
                            self.dayPicker.selectRow(minute, inComponent: 2, animated: true)
                            self.dayPicker.selectRow(0, inComponent: 3, animated: true)
                            
                            UserDefaults.standard.set(11, forKey: "Hour")
                            UserDefaults.standard.set(minute, forKey: "Minute")
                            UserDefaults.standard.set(0, forKey: "TimeOfDay")
                            
                        } else if timeOfDay == 0{
                            //check if it's 12 PM
                            self.dayPicker.selectRow(hour - 1, inComponent: 1, animated: true)
                            self.dayPicker.selectRow(minute, inComponent: 2, animated: true)
                            self.dayPicker.selectRow(1, inComponent: 3, animated: true)
                            
                            UserDefaults.standard.set(hour - 1, forKey: "Hour")
                            UserDefaults.standard.set(minute, forKey: "Minute")
                            UserDefaults.standard.set(12, forKey: "TimeOfDay")
                            
                        } else if timeOfDay < 0 {
                            //check if it's AM in general
                            self.dayPicker.selectRow(hour - 1, inComponent: 1, animated: true)
                            self.dayPicker.selectRow(minute, inComponent: 2, animated: true)
                            self.dayPicker.selectRow(0, inComponent: 3, animated: true)
                            
                            UserDefaults.standard.set(hour - 1, forKey: "Hour")
                            UserDefaults.standard.set(minute, forKey: "Minute")
                            UserDefaults.standard.set(0, forKey: "TimeOfDay")
                            
                            
                            
                        } else {
                            //check if it's PM
                            hour = timeOfDay
                            
                            self.dayPicker.selectRow(hour - 1, inComponent: 1, animated: true)
                            self.dayPicker.selectRow(minute, inComponent: 2, animated: true)
                            self.dayPicker.selectRow(1, inComponent: 3, animated: true)
                            
                            UserDefaults.standard.set(hour - 1, forKey: "Hour")
                            UserDefaults.standard.set(minute, forKey: "Minute")
                            UserDefaults.standard.set(12, forKey: "TimeOfDay")
                            
                        }
                        
                        self.loadedScheduler = 1
                        
                    }
                    
                }
                
                //If the back wash status is 2: show the count down timer
                
                if backWashStatus == 2{
                    self.backWashScheduler.isHidden = false
                    self.countDownTimerBG.isHidden = false
                    
                    if let countDownSeconds = responseDictinary["timeoutCountdown"] as? Int {
                        let hours = countDownSeconds / 3600
                        let minutes = (countDownSeconds % 3600) / 60
                        let seconds = (countDownSeconds % 3600) % 60
                        
                        self.countDownTimer.text = "\(hours):\(minutes):\(seconds)"
                    }
              
                    
                  
                    
                } else if backWashStatus == 0 {
                    self.backWashScheduler.isHidden = false
                    self.countDownTimerBG.isHidden = true
                } else {
                    self.backWashScheduler.isHidden = false
                    self.countDownTimerBG.isHidden = true
                }
                
            }
    }
    
    
    
    
    //====================================
    //                                     FILTRATION MONITOR
    //====================================
    
    
    /***************************************************************************
     * Function :  Read Filtration Pump Details
     * Input    :  none
     * Output   :  none
     * Comment  :  Get all the details from the PLC.
     ***************************************************************************/
    
    private func readCurrentFiltrationPumpDetails(){
        
        var pumpSet = 0
        
        if iPadNumber == 1{
            pumpSet = 0
        }else if iPadNumber == 2{
            pumpSet = 1
        }
        
        let registersSET1 = PUMP_SETS[pumpSet]
        let startRegister = registersSET1[1]
        
        
        
        CENTRAL_SYSTEM!.readRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, length: 14, startingRegister: Int32(startRegister.register), completion:{ (success, response) in
            
            guard response != nil else { return }
            
            self.readCurrentFiltrationSpeed(response: response)
            self.readCurrentManualSpeed(response: response)
            self.readCurrentBackwashSpeed(response: response)
        })
    }
    
    /***************************************************************************
     * Function :  Read Filtration Pump Speed
     * Input    :  none
     * Output   :  none
     * Comment  :  The frequency background frame will change its size according to the frequency value we got from the PLC
     ***************************************************************************/
    
    private func readCurrentFiltrationSpeed(response:[AnyObject]?) {
        self.frequency = Int(truncating: response![1] as! NSNumber)
        
        if let frequency = frequency {
            let integer = frequency / 10
            let frequencyLocation = (Double(integer) * PIXEL_PER_FREQUENCY)
            let indicatorLocation = 458 - frequencyLocation
            
            
            if integer > Int(MAX_FILTRATION_FREQUENCY){
                frequencySetpointBackground.frame =  CGRect(x: 499, y: 199, width: 25, height: 258)
            }else{
                frequencySetpointBackground.frame =  CGRect(x: 499, y: indicatorLocation, width: 25, height:frequencyLocation)
            }
        }
    }
    
    /***************************************************************************
     * Function :  Read Manual Pump Speed
     * Input    :  none
     * Output   :  none
     * Comment  :  The frequency indicator frame and frequency text will move its y coordinate according to the frequency value we got from the PLC
     ***************************************************************************/
    
    private func readCurrentManualSpeed(response:[AnyObject]?) {
        if  readManualSpeedPLC || !readManualSpeedOncePLC {
            readManualSpeedPLC = false
            
            frequencyIndicatorValue.textColor = GREEN_COLOR
            self.manualSpeed = Int(truncating: response![0] as! NSNumber)
            
            if let manualSpeed = manualSpeed {
                let integer = manualSpeed / 10
                let decimal = manualSpeed % 10
                let indicatorLocation = 445 - (Double(integer) * PIXEL_PER_FREQUENCY)
                
                if integer > Int(MAX_FILTRATION_FREQUENCY){
                    frequencyIndicator.frame = CGRect(x: 399, y: 190, width: 86, height: 23)
                    frequencyIndicatorValue.text = "\(MAX_FILTRATION_FREQUENCY)"
                    readManualSpeedOncePLC = true
                }else{
                    
                    frequencyIndicator.frame = CGRect(x: 399, y: indicatorLocation, width: 86, height: 23)
                    frequencyIndicatorValue.text = "\(integer).\(decimal)"
                    readManualSpeedOncePLC = true
                }
            }
        }
    }
    
    
    
    /***************************************************************************
     * Function :  Read Back Wash Speed
     * Input    :  none
     * Output   :  none
     * Comment  :  The back wash indicator frame and frequency label will move its y-coordinate according to the frequency value we got from the PLC.
     ***************************************************************************/
    
    private func readCurrentBackwashSpeed(response:[AnyObject]?){
        
        let backWash = Int(truncating: response![9] as! NSNumber)
        let integer = backWash / 10
        let decimal = backWash % 10
        let indicatorLocation = 445 - (Double(integer) * FILTRATION_PIXEL_PER_BACKWASH)
        
        if !readBackWashSpeedOnce {
            bwashSpeedIndicatorValue.textColor = BABY_BLUE_COLOR
            
            if integer > Int(MAX_FILTRATION_BACKWASH_SPEED) {
                readBackWashSpeedOnce = true
                bwashSpeedIndicator.frame = CGRect(x: 524, y: 190, width: 86, height: 23)
                bwashSpeedIndicatorValue.text = "\(MAX_FILTRATION_BACKWASH_SPEED)"
                
            }else{
                readBackWashSpeedOnce = true
                bwashSpeedIndicator.frame = CGRect(x: 524, y: Int(indicatorLocation), width: 86, height: 23)
                bwashSpeedIndicatorValue.text = "\(integer).\(decimal)"
            }
        }
        
    }
    
    
    /***************************************************************************
     * Function :  Read Back Wash Running Bit
     * Input    :  none
     * Output   :  none
     * Comment  :  Check whether the back wash is running or not.
     If back wash is running we cannot play a show.
     ***************************************************************************/
    
    private func readBackWashRunning(){
        CENTRAL_SYSTEM?.readBits(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, length: 1, startingRegister: Int32(FILTRATION_BWASH_RUNNING_BIT), completion: { (success, response) in
            
            guard success == true else { return }
            
            let running = Int(truncating: response![0] as! NSNumber)
            self.bwashRunning = running
            
            if running == 1{
                self.bWashRunning.isHidden = false
                UserDefaults.standard.set(1, forKey: "lakebackWashRunningStat")
            } else {
                self.bWashRunning.isHidden = true
                UserDefaults.standard.set(0, forKey: "lakebackWashRunningStat")
            }
        })
        
        CENTRAL_SYSTEM?.readBits(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, length: 1, startingRegister: Int32(FILTRATION_PUMP_SCH_BIT), completion: { (success, response) in
            
            guard success == true else { return }
            
            let filterSchOn = Int(truncating: response![0] as! NSNumber)
            
            if filterSchOn == 1{
                self.filterSchBtn.setTitleColor(GREEN_COLOR, for: .normal)
            } else {
                self.filterSchBtn.setTitleColor(DEFAULT_GRAY, for: .normal)
            }
        })
    }
    
    
    
    /***************************************************************************
     * Function :  Change Pump's Frequency
     * Input    :  none
     * Output   :  none
     * Comment  :  Check whether the back wash is running or not.
     ***************************************************************************/
    
    
    @objc func changePumpSpeedFrequency(sender: UIPanGestureRecognizer){
        frequencyIndicatorValue.textColor = DEFAULT_GRAY
        
        var touchLocation:CGPoint = sender.location(in: self.view)
        if touchLocation.y  < 196 {
            touchLocation.y = 196
        }
        if touchLocation.y  > 461 {
            touchLocation.y = 461
        }
        // This is set.
        if touchLocation.y >= 196 && touchLocation.y <= 461 {
            print(touchLocation.y)
            //Make sure that we don't go more than pump flow limit
           
            sender.view?.center.y = touchLocation.y
            
            let flowRange = 460.0 - touchLocation.y
            let hertz = Float(flowRange) * CONVERTED_FILTRATION_PIXEL_PER_FREQUENCY!
            
            
            var convertedFrequency = Int(hertz * 10)
            let frequencyValue = convertedFrequency / 10
            var frequencyRemainder = convertedFrequency % 10
            
            if frequencyValue == 50 && frequencyRemainder > 0 {
                frequencyRemainder = 0
            }
            
            if frequencyValue == 0 && frequencyRemainder < 0 {
                frequencyRemainder = 0
            }
            
            frequencyIndicatorValue.text = "\(frequencyValue).\(frequencyRemainder)"
            
            if convertedFrequency > CONVERTED_FREQUENCY_LIMIT {
                convertedFrequency = CONVERTED_FREQUENCY_LIMIT
            } else if convertedFrequency < 0 {
                convertedFrequency = 0
            }
            
            
            if sender.state == .ended {
                if iPadNumber == 1{
                    if convertedFrequency < 10{
                        CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: 2, value: 0)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.readManualSpeedPLC = true
                        }
                    }else{
                        CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: 2, value: convertedFrequency)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.readManualSpeedPLC = true
                        }
                    }
                    
                }else{
                    if convertedFrequency < 10{
                        CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: 22, value: 0)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.readManualSpeedPLC = true
                        }
                    }else{
                        CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: 22, value: convertedFrequency)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.readManualSpeedPLC = true
                        }
                    }
                    
                }
            }
       
        }
    }
    
    
    
    /***************************************************************************
     * Function :  Change Backwash Frequency
     * Input    :  none
     * Output   :  none
     * Comment  :  Calculations are set.
     Note: We multiply the hertz by 10 because PLC expects 3 digit number
     ***************************************************************************/
    
    @objc func changeBackWashFrequency(sender: UIPanGestureRecognizer){
        bwashSpeedIndicatorValue.textColor = DEFAULT_GRAY
        var touchLocation:CGPoint = sender.location(in: self.view)
        if touchLocation.y  < 196 {
            touchLocation.y = 196
        }
        if touchLocation.y  > 461 {
            touchLocation.y = 461
        }
        
        //This is set.
        if touchLocation.y >= 196 && touchLocation.y <= 461 {
            print(touchLocation.y)
            //Make sure that we don't go more than pump flow limit
            sender.view?.center.y = touchLocation.y
            
            
            let flowRange = 460.0 - touchLocation.y
            let hertz = Float(flowRange) * CONVERTED_FILTRATION_PIXEL_PER_BW!
            
            
            var convertedBWFrequency = Int(hertz * 10)
            let BWfrequencyValue = convertedBWFrequency / 10
            var BWfrequencyRemainder = convertedBWFrequency % 10
            
            if BWfrequencyValue == 50 && BWfrequencyRemainder > 0 {
                BWfrequencyRemainder = 0
            }
            
            if BWfrequencyValue == 0 && BWfrequencyRemainder < 0 {
                BWfrequencyRemainder = 0
            }
            
            bwashSpeedIndicatorValue.text = "\(BWfrequencyValue).\(BWfrequencyRemainder)"
            
            if convertedBWFrequency > CONVERTED_BW_SPEED_LIMIT {
                convertedBWFrequency = CONVERTED_BW_SPEED_LIMIT
            } else if convertedBWFrequency < 0 {
                convertedBWFrequency = 0
            }
            
            
            if sender.state == .ended {
                if iPadNumber == 1{
                    if convertedBWFrequency < 10{
                        CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: 11, value: 0)
                    }else{
                        CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: 11, value: convertedBWFrequency)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.readBackWashSpeedOnce = false
                    }
                }else{
                    
                    if convertedBWFrequency < 10{
                        CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: 31, value: 0)
                    }else{
                        CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: 31, value: convertedBWFrequency)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.readBackWashSpeedOnce = false
                    }
                }
            }
       
        }
    }
    
    
    /***************************************************************************
     * Function :  Read Manual Back Wash
     * Input    :  none
     * Output   :  none
     * Comment  :  It reads from the server. Show/hide label.
     ***************************************************************************/
    
    private func readManualBwash(){
        
        self.httpComm.httpGetResponseFromPath(url: READ_LAKEBACK_WASH1){ (response) in
            
            guard let responseDictionary = response as? NSDictionary else { return }
            
            let backwash = Int(truncating: responseDictionary.object(forKey: "manBWcanRun") as! NSNumber)
            
            if backwash == 1{
                self.cannotRunBwashLbl.isHidden = true
            }else{
                self.cannotRunBwashLbl.isHidden = false
            }
        }
    }
    
    /***************************************************************************
     * Function :  Construct Back Wash Scheduler
     * Input    :  none
     * Output   :  none
     * Comment  :  Construct Picker View. These are all set. No need to configure
     Change time to 12 or 24 hours according to the user's date and time setting
     ***************************************************************************/
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if is24hours {
            return 3
        } else {
            return 4
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        
        if component == 0{
            
            return 7
            
        } else if component == 1{
            
            if is24hours {
                return 24
            } else {
                return 12
            }
            
        } else if component == 2{
            
            return 60
            
        } else {
            
            return 2
            
        }
        
        
    }
    
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if is24hours {
            if component == 0 {
                return 175
            } else if component == 1 {
                return 50
            } else {
                return 80
            }
        } else if !is24hours {
            if component == 0 {
                return 150
            } else {
                return 50
            }
        } else {
            return 0
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.textColor = .white
            pickerLabel?.font = UIFont(name: ".SFUIDisplay", size: 20)
            pickerLabel?.textAlignment = .left
            
            
            switch component {
                
            case 0:
                pickerLabel?.text = DAY_PICKER_DATA_SOURCE[row]
                
            case 1:
                pickerLabel?.textAlignment = .right
                
                if is24hours {
                    let formattedHour = String(format: "%02i", row)
                    pickerLabel?.text = "\(formattedHour)"
                } else {
                    pickerLabel?.text = "\(row + 1)"
                }
                
            case 2:
                let formattedMinutes = String(format: "%02i", row)
                pickerLabel?.text = ": \(formattedMinutes)"
                
            case 3:
                pickerLabel?.text = AM_PM_PICKER_DATA_SOURCE[row]
                
            default:
                pickerLabel?.text = "Error"
            }
            
        }
        
        
        return pickerLabel!
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        
        //Selected Day
        if component == 0 {
            
            selectedDay = row + 1
            UserDefaults.standard.set(selectedDay, forKey: "LakeSelectedDay")
            component0AlreadySelected = true
        } else {
            if !component0AlreadySelected {
                let defaultDay = UserDefaults.standard.integer(forKey: "LakeDay")
                UserDefaults.standard.set(defaultDay, forKey: "LakeSelectedDay")
            }
        }
        
        if component == 1 {
            if is24hours {
                selectedHour = row
            } else {
                selectedHour = row + 1
            }
            
            UserDefaults.standard.set(selectedHour, forKey: "LakeSelectedHour")
            component1AlreadySelected = true
        } else {
            if !component1AlreadySelected {
                let hour = UserDefaults.standard.integer(forKey: "LakeHour")
                
                if is24hours {
                    UserDefaults.standard.set(hour, forKey: "LakeSelectedHour")
                } else {
                    UserDefaults.standard.set(hour + 1, forKey: "LakeSelectedHour")
                }
            }
        }
        
        if component == 2 {
            
            selectedMinute = row
            UserDefaults.standard.set(selectedMinute, forKey: "LakeSelectedMinute")
            component2AlreadySelected = true
        } else {
            if !component2AlreadySelected {
                let minute = UserDefaults.standard.integer(forKey: "LakeMinute")
                UserDefaults.standard.set(minute, forKey: "LakeSelectedMinute")
            }
        }
        
        if component == 3 {
            if !is24hours {
                if row == 0 {
                    selectedTimeOfDay = 0
                } else {
                    selectedTimeOfDay = 12
                }
            } else {
                selectedTimeOfDay = 0
            }
            
            UserDefaults.standard.set(selectedTimeOfDay, forKey: "LakeSelectedTimeOfDay")
            component3AlreadySelected = true
        } else {
            if !component3AlreadySelected {
                let day = UserDefaults.standard.integer(forKey: "LakeTimeOfDay")
                UserDefaults.standard.set(day, forKey: "LakeSelectedTimeOfDay")
            }
        }
        
    }
    
    //MARK: - Set Backwash Scheduler
    
    @IBAction func setBackwashScheduler(_ sender: Any) {
        let hour = UserDefaults.standard.integer(forKey: "LakeSelectedHour")
        let minute = UserDefaults.standard.integer(forKey: "LakeSelectedMinute")
        let day = UserDefaults.standard.integer(forKey: "LakeSelectedDay")
        let timeOfDay =  UserDefaults.standard.integer(forKey: "LakeSelectedTimeOfDay")
        
        var time = 0
        //Converting hour and minute to 4 digit
        
        if is24hours {
            time = (hour * 100) + minute
        } else {
            time = ((hour + timeOfDay) * 100)
            
            if time == 1200 {
                //12 AM
                time = (time * 0) + minute
            } else if time == 2400 {
                //12 PM
                time = (time - 1200) + minute
            } else {
                time += minute
            }
        }
        
        httpComm.httpGetResponseFromPath(url: "\(HTTP_PASS)\(SERVER_IP2_ADDRESS):8080/writeBW?[\(day),\(time)]"){ (response) in
            self.loadedScheduler = 0
        }
        
        //NOTE: The Data Structure be [DAY,TIME]
        
        
    }
    
    
    /***************************************************************************
     * Function :  Load Back Wash Duration
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    private func loadBWDuration(){
        CENTRAL_SYSTEM?.readRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, length: 1, startingRegister: Int32(FILTRATION_BW_DURATION_REGISTER), completion: { (success, response) in
            
            guard success == true else { return }
            
            let bwDuration = Int(truncating: response![0] as! NSNumber)
            self.backwashDuration.text = "\(bwDuration) m"
        })
    }
    
    @IBAction func redirectToPumpDetail(_ sender: UIButton) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "pumps", bundle:nil)
        
        let pumpDetail = storyBoard.instantiateViewController(withIdentifier: "pumpDetail") as! AutoPumpDetailViewController
        pumpDetail.pumpNumber = pumpNumber
        pumpDetail.featureId = 2
        self.navigationController?.pushViewController(pumpDetail, animated: true)

    }
    
    @IBAction func redirectToPumpScheduler(_ sender: UIButton) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "pumps", bundle:nil)
        let pumpDetail = storyBoard.instantiateViewController(withIdentifier: "pumpSchedulerViewController") as! PumpSchedulerViewController
        pumpDetail.schedulerTag = sender.tag
        self.navigationController?.pushViewController(pumpDetail, animated: true)

    }
    
    @IBAction func settingsButtonPressed(_ sender: UIButton) {
       self.addAlertAction(button: sender)
    }
    
    func checkAMPM(){
        if let formatString: String = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: Locale.current) {
            let checker24hrs = formatString.contains("H")
            let checker24hrs2 = formatString.contains("k")
            
            if checker24hrs || checker24hrs2 {
                is24hours = true
            } else {
                is24hours = false
            }
        } else {
            is24hours = true
        }
    }
}
