//
//  AlightFiltrationViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 12/24/22.
//  Copyright © 2022 WET. All rights reserved.
//

import UIKit

class LakeFiltrationViewController:UIViewController,UIGestureRecognizerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet weak var noConnectionView: UIView!
    @IBOutlet weak var noConnectionErrorLbl: UILabel!
    
    //MARK: - Show Stoppers
    
    @IBOutlet weak var ptView: UIView!
    @IBOutlet weak var filtrationRunningIndicator: UIImageView!
    @IBOutlet weak var cleanStrainerIndicator: UILabel!
    
    @IBOutlet weak var manualBwashButton: UIButton!
    @IBOutlet weak var cannotRunBwashLbl: UILabel!
    
    @IBOutlet weak var dayPicker: UIPickerView!
    @IBOutlet weak var backwashDuration: UILabel!
    
    @IBOutlet weak var backWashScheduler: UIView!
    @IBOutlet weak var countDownTimerBG: UIView!
    @IBOutlet weak var countDownTimer: UILabel!
    
    @IBOutlet weak var playStopBtn: UIButton!
    @IBOutlet weak var autoModeImg: UIImageView!
    
    var manulPumpGesture: UIPanGestureRecognizer!
    var backWashGesture: UIPanGestureRecognizer!
    
    @IBOutlet weak var cleanStrainer: UILabel!
    @IBOutlet weak var presFault: UILabel!
    @IBOutlet weak var motorOverload: UILabel!
    @IBOutlet weak var waterLLFault: UILabel!
    @IBOutlet weak var pumpOff: UILabel!
    //MARK: - Class Reference Objects -- Dependencies
    
    private let logger = Logger()
    private let helper = Helper()
    private let utilities = Utilits()
    private let httpComm = HTTPComm()
    
    var p1101MotorLiveValues = FOG_MOTOR_LIVE_VALUES()
    
    //MARK: - Data Structures
    
    private var langData = [String : String]()
    private var iPadNumber = 0
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
        getMotorValues()
        checkAutoHandMode()
        loadedScheduler = 0
        
        //Load Backwash Duration for Backwash Scheduler
        setInitialParam()
        loadBWDuration()
        
        //Add notification observer to get system stat
        
        NotificationCenter.default.addObserver(self, selector: #selector(checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
    }

    override func viewWillDisappear(_ animated: Bool){
        
        NotificationCenter.default.removeObserver(self)
        
    }
    
    func setInitialParam(){
        self.navigationItem.title = "FILTRATION - 1101"
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
            getMotorValues()
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
        
            self.httpComm.httpGetResponseFromPath(url: "\(HTTP_PASS)\(SERVER_IP2_ADDRESS):8080/readABW"){ (response) in
                
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
     * Function :  Read Back Wash Running Bit
     * Input    :  none
     * Output   :  none
     * Comment  :  Check whether the back wash is running or not.
     If back wash is running we cannot play a show.
     ***************************************************************************/
    
    private func readBackWashRunning(){
        
        CENTRAL_SYSTEM?.readBits(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, length: 1, startingRegister: Int32(ALIGHTFILTRATION_BWASH_RUNNING_BIT), completion: { (success, response) in
            
            guard success == true else { return }
            
            let running = Int(truncating: response![0] as! NSNumber)
            self.bwashRunning = running
            
            if running == 1{
                self.manualBwashButton.setImage(#imageLiteral(resourceName: "bwashRunning"), for: .normal)
                UserDefaults.standard.set(1, forKey: "backWashRunningStat")
            } else {
                self.manualBwashButton.setImage(#imageLiteral(resourceName: "bwashIcon"), for: .normal)
                UserDefaults.standard.set(0, forKey: "backWashRunningStat")
            }
        })
    }
    /***************************************************************************
     * Function :  Read Manual Back Wash
     * Input    :  none
     * Output   :  none
     * Comment  :  It reads from the server. Show/hide label.
     ***************************************************************************/
    
    private func readManualBwash(){
        
        self.httpComm.httpGetResponseFromPath(url: READ_ALIGHTBACK_WASH1){ (response) in
            
            guard let responseDictionary = response as? NSDictionary else { return }
            
            let backwash = Int(truncating: responseDictionary.object(forKey: "manBWcanRun") as! NSNumber)
            
            if backwash == 1{
                
                self.manualBwashButton.isHidden = false
                self.cannotRunBwashLbl.isHidden = true
                
            }else{
                
                self.manualBwashButton.isHidden = true
                self.cannotRunBwashLbl.isHidden = false
                
            }
        }
    }
    
    
    /***************************************************************************
     * Function :  e Manual Back Wash Button
     * Input    :  none
     * Output   :  none
     * Comment  :  Pulsates the Filtration toggle backwash bit. Write 1 then write 0 after 1 sec.
     ***************************************************************************/
    
    @IBAction func toggleManualBackwash(_ sender: Any){
        CENTRAL_SYSTEM?.writeBit(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, bit: ALIGHTFILTRATION_TOGGLE_BWASH_BIT, value: 1)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            CENTRAL_SYSTEM?.writeBit(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, bit: ALIGHTFILTRATION_TOGGLE_BWASH_BIT, value: 0)
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
            UserDefaults.standard.set(selectedDay, forKey: "SelectedDay")
            component0AlreadySelected = true
        } else {
            if !component0AlreadySelected {
                let defaultDay = UserDefaults.standard.integer(forKey: "Day")
                UserDefaults.standard.set(defaultDay, forKey: "SelectedDay")
            }
        }
        
        if component == 1 {
            if is24hours {
                selectedHour = row
            } else {
                selectedHour = row + 1
            }
            
            UserDefaults.standard.set(selectedHour, forKey: "SelectedHour")
            component1AlreadySelected = true
        } else {
            if !component1AlreadySelected {
                let hour = UserDefaults.standard.integer(forKey: "Hour")
                
                if is24hours {
                    UserDefaults.standard.set(hour, forKey: "SelectedHour")
                } else {
                    UserDefaults.standard.set(hour + 1, forKey: "SelectedHour")
                }
            }
        }
        
        if component == 2 {
            
            selectedMinute = row
            UserDefaults.standard.set(selectedMinute, forKey: "SelectedMinute")
            component2AlreadySelected = true
        } else {
            if !component2AlreadySelected {
                let minute = UserDefaults.standard.integer(forKey: "Minute")
                UserDefaults.standard.set(minute, forKey: "SelectedMinute")
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
            
            UserDefaults.standard.set(selectedTimeOfDay, forKey: "SelectedTimeOfDay")
            component3AlreadySelected = true
        } else {
            if !component3AlreadySelected {
                let day = UserDefaults.standard.integer(forKey: "TimeOfDay")
                UserDefaults.standard.set(day, forKey: "SelectedTimeOfDay")
            }
        }
        
    }
    
    //MARK: - Set Backwash Scheduler
    
    @IBAction func setBackwashScheduler(_ sender: Any) {
        let hour = UserDefaults.standard.integer(forKey: "SelectedHour")
        let minute = UserDefaults.standard.integer(forKey: "SelectedMinute")
        let day = UserDefaults.standard.integer(forKey: "SelectedDay")
        let timeOfDay =  UserDefaults.standard.integer(forKey: "SelectedTimeOfDay")
        
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
        
        httpComm.httpGetResponseFromPath(url: "\(HTTP_PASS)\(SERVER_IP2_ADDRESS):8080/writeABW?[\(day),\(time)]"){ (response) in
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
    @IBAction func showAlerSettings(_ sender: UIButton) {
        self.addAlertAction(button: sender)
    }
    @IBAction func redirectToPumpScheduler(_ sender: UIButton) {
        let schedulerShowVC = UIStoryboard.init(name: "pumps", bundle: nil).instantiateViewController(withIdentifier: "pumpAlightSchedulerViewController") as! LakePumpsSchedulerViewController
        schedulerShowVC.schedulerTag = sender.tag
        navigationController?.pushViewController(schedulerShowVC, animated: true)
    }
    
    func checkAutoHandMode(){
        
        CENTRAL_SYSTEM?.readBits(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, length: 1, startingRegister: Int32(FILT1101_AUTO_HAND_BIT_ADDR), completion: { (success, response) in
            
            if response != nil{
                
                let autoHandMode = Int(truncating: response![0] as! NSNumber)
                
                if autoHandMode == 1{
                    //If is in manual mode on the ipad
                    self.changeAutManModeIndicatorRotation(autoMode: false)
                    self.autoModeImg.image = #imageLiteral(resourceName: "handMode")
                    self.playStopBtn.alpha = 1
                }else{
                    //If is in auto mode on the ipad
                    self.playStopBtn.alpha = 0
                    self.autoModeImg.image = #imageLiteral(resourceName: "autoMode")
                    self.changeAutManModeIndicatorRotation(autoMode: true)
                }
            }
            
        })
    }
    func getMotorValues(){
        let pt1001scaledValue = self.ptView.viewWithTag(2001) as? UILabel
        let pt1002scaledValue = self.ptView.viewWithTag(2002) as? UILabel
        let pt1003scaledValue = self.ptView.viewWithTag(2003) as? UILabel
        
        let pt1001chFImg = self.ptView.viewWithTag(4001) as? UIImageView
        let pt1002chFImg = self.ptView.viewWithTag(4002) as? UIImageView
        let pt1003chFImg = self.ptView.viewWithTag(4003) as? UIImageView
        
        CENTRAL_SYSTEM!.readRealRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register:Int(PT1001_SCALEDVAL), length: 2){ (success, response)  in
            
           guard success == true else{
               return
           }
            let val = Double(response)!
            pt1001scaledValue!.text = String(format: "%.1f", val)
        }
        CENTRAL_SYSTEM!.readRealRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register:Int(PT1002_SCALEDVAL), length: 2){ (success, response)  in
            
           guard success == true else{
               return
           }
            let val = Double(response)!
            pt1002scaledValue!.text = String(format: "%.1f", val)
        }
        CENTRAL_SYSTEM!.readRealRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register:Int(PT1003_SCALEDVAL), length: 2){ (success, response)  in
            
           guard success == true else{
               return
           }
            let val = Double(response)!
            pt1003scaledValue!.text = String(format: "%.1f", val)
        }
        CENTRAL_SYSTEM?.readBits(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, length: 13, startingRegister: Int32(PT1001_SCALEDVAL), completion: { (sucess, response) in
            
            if response != nil{
                let pt1001chFault = Int(truncating: response![0] as! NSNumber)
                let pt1002chFault = Int(truncating: response![6] as! NSNumber)
                let pt1003chFault = Int(truncating: response![12] as! NSNumber)
                
                pt1001chFault == 1 ? ( pt1001chFImg?.image = #imageLiteral(resourceName: "red")) : (pt1001chFImg?.image = #imageLiteral(resourceName: "green"))
                pt1002chFault == 1 ? ( pt1002chFImg?.image = #imageLiteral(resourceName: "red")) : (pt1002chFImg?.image = #imageLiteral(resourceName: "green"))
                pt1003chFault == 1 ? ( pt1003chFImg?.image = #imageLiteral(resourceName: "red")) : (pt1003chFImg?.image = #imageLiteral(resourceName: "green"))
            }
            
        })
        CENTRAL_SYSTEM?.readBits(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, length: Int32(FILT1101_FAULTS.count), startingRegister: Int32(FILT1101_FAULTS.startAddr), completion: { (sucess, response) in
            
            if response != nil{
                self.p1101MotorLiveValues.pumpFault     = Int(truncating: response![0] as! NSNumber)
                self.p1101MotorLiveValues.pumpRunning   = Int(truncating: response![1] as! NSNumber)
                self.p1101MotorLiveValues.pumpOverLoad  = Int(truncating: response![2] as! NSNumber)
                self.p1101MotorLiveValues.pumpShutdown  = Int(truncating: response![3] as! NSNumber)
                self.p1101MotorLiveValues.cleanStrainer = Int(truncating: response![4] as! NSNumber)
            }
            
        })
        CENTRAL_SYSTEM?.readBits(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, length: 1, startingRegister: Int32(FILT1101_AUTO_HAND_BIT_ADDR), completion: { (sucess, response) in
            
            if response != nil{
                self.p1101MotorLiveValues.pumpMode     = Int(truncating: response![0] as! NSNumber)
            }
            
        })
        if self.p1101MotorLiveValues.pumpFault == 1{
            self.waterLLFault.alpha = 1
        } else {
            self.waterLLFault.alpha = 0
        }
        if self.p1101MotorLiveValues.pumpRunning == 1{
            pumpOff.text = "PUMP RUNNING"
            pumpOff.textColor = GREEN_COLOR
            playStopBtn.setBackgroundImage(#imageLiteral(resourceName: "regularSched"), for: .normal)
        } else {
            pumpOff.text = "PUMP OFF"
            pumpOff.textColor = DEFAULT_GRAY
            playStopBtn.setBackgroundImage(#imageLiteral(resourceName: "playButton"), for: .normal)
        }
        if self.p1101MotorLiveValues.pumpOverLoad == 1{
            self.motorOverload.alpha = 1
        } else {
            self.motorOverload.alpha = 0
        }
        if self.p1101MotorLiveValues.pumpShutdown == 1{
            self.presFault.alpha = 1
        } else {
            self.presFault.alpha = 0
        }
        if self.p1101MotorLiveValues.cleanStrainer == 1{
            self.cleanStrainer.alpha = 1
        } else {
            self.cleanStrainer.alpha = 0
        }
    }
    func changeAutManModeIndicatorRotation(autoMode:Bool){
        /*
         NOTE: 2 Possible Options
         Option 1: Automode (animate) = True => Will result in any view object to rotate 360 degrees infinitly
         Option 2: Automode (animate) = False => Will result in any view object to stand still
         */
        if autoMode == true {
            autoModeImg.rotate360Degrees(animate: true)
        }else{
            autoModeImg.rotate360Degrees(animate: false)
        }
    }
    
    @IBAction func toggleAutoHandMode(_ sender: UIButton){
        
        //NOTE: The auto/hand mode value on PLC is opposite to autoModeValue
        //On PLC Auto Mode: 0 , Hand Mode: 1
        if self.p1101MotorLiveValues.pumpMode == 1{
            //In manual mode, change to auto mode
            CENTRAL_SYSTEM?.writeBit(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, bit: FILT1101_AUTO_HAND_BIT_ADDR, value: 0)
            
        } else if self.p1101MotorLiveValues.pumpMode == 0{
            //In auto mode, change it to manual mode
            CENTRAL_SYSTEM?.writeBit(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, bit: FILT1101_AUTO_HAND_BIT_ADDR, value: 1)
            
        }
        checkAutoHandMode()
    }
    

    
    
    /***************************************************************************
     * Function :  playStopFog
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    @IBAction func playStopFog(_ sender: UIButton){
        if self.p1101MotorLiveValues.pumpRunning == 1{
            CENTRAL_SYSTEM?.writeBit(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, bit: FILT1101_PLAY_STOP_BIT_ADDR, value: 0)
        } else if self.p1101MotorLiveValues.pumpRunning == 0{
            CENTRAL_SYSTEM?.writeBit(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, bit: FILT1101_PLAY_STOP_BIT_ADDR, value: 1)
        }
    }
}
