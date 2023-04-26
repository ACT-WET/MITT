//
//  PumpDetailViewController.swift
//  iPadControls
//
//  Created by Arpi Derm on 12/27/16.
//  Copyright © 2016 WET. All rights reserved.
//

import UIKit

class AutoPumpDetailViewController: UIViewController,UIGestureRecognizerDelegate{
    
    var pumpNumber = 0
    var featureId = 0
    
    private var pumpIndicatorLimit = 0
    
    @IBOutlet weak var noConnectionView: UIView!
    @IBOutlet weak var noConnectionErrorLbl: UILabel!
    
    //MARK: - Class Reference Objects -- Dependencies
    
    private let logger = Logger()
    private let helper = Helper()
    
    @IBOutlet weak var manualSpeedView: UIView!
    @IBOutlet weak var manualSpeedValue: UITextField!
    
    //MARK: - Frequency Label Indicators
    
    
    @IBOutlet weak var setFrequencyHandle: UIView!
    @IBOutlet weak var setPointer: UIImageView!
    @IBOutlet weak var frequencySetLabel: UILabel!
    
    
    @IBOutlet weak var frequencyLabel: UILabel!
    @IBOutlet weak var frequencyValueLabel: UILabel!
    @IBOutlet weak var frequencyIndicator: UIView!
    @IBOutlet weak var frequencyIndicatorValue: UILabel!
    @IBOutlet weak var frequencySetpointBackground: UIView!
    
    
    //MARK: - Voltage Label Indicators
    
    @IBOutlet weak var voltageLabel: UILabel!
    @IBOutlet weak var voltageValueLabel: UILabel!
    @IBOutlet weak var voltageIndicator: UIView!
    @IBOutlet weak var voltageIndicatorValue: UILabel!
    @IBOutlet weak var voltageSetpointBackground: UIView!
    @IBOutlet weak var voltageBackground: UIView!
    
    //MARK: - Current Label Indicators
    
    @IBOutlet weak var currentBackground: UIView!
    @IBOutlet weak var currentValueLabel: UILabel!
    @IBOutlet weak var currentLabel: UILabel!
    @IBOutlet weak var currentSetpointBackground: UIView!
    @IBOutlet weak var currentIndicator: UIView!
    @IBOutlet weak var currentIndicatorValues: UILabel!
    
    //MARK: - Temperature Label Indicators
    
    @IBOutlet weak var temperatureIndicator: UIView!
    @IBOutlet weak var temperatureIndicatorValue: UILabel!
    @IBOutlet weak var temperatureGreen: UIView!
    @IBOutlet weak var temperatureYellow: UIView!
    @IBOutlet weak var temperatureBackground: UIView!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    
    //MARK: - Auto or Manual
    @IBOutlet weak var autoModeIndicator: UIImageView!
    @IBOutlet weak var handModeIndicator: UIImageView!
    @IBOutlet weak var autoManualButton: UIButton!
    @IBOutlet weak var playStopButtonIcon: UIButton!
    private var isManualMode = false
    
    
    //MARK: - Data Structures
    
    private var langData = Dictionary<String, String>()
    private var pumpModel:Pump?
    private var iPadNumber = 0
    private var showStoppers = ShowStoppers()
    private var pumpState = 0 //POSSIBLE STATES: 0 (Auto) 1 (Hand) 2 (Off)
    private var localStat = 0
    private var readFrequencyCount = 0
    private var readOnce = 0
    private var readPumpDetailSpecsOnce = 0
    private var readManualFrequencySpeed = false
    private var readManualFrequencySpeedOnce = false
    private var HZMax = 0
    private var centralSystem = CentralSystem()
    private var voltageMaxRangeValue = 0
    private var voltageMinRangeValue = 0
    private var voltageLimit = 0
    private var pixelPerVoltage  = 0.0
    
    private var currentLimit = 0
    private var currentMaxRangeValue = 0
    private var pixelPerCurrent = 0.0
    
    private var temperatureMaxRangeValue = 0
    private var pixelPerTemperature = 0.0
    private var temperatureLimit = 100
    private var pumpFaulted = false
    
    var manualPumpGesture: UIPanGestureRecognizer!
    
    @IBOutlet weak var vfdNumber: UILabel!
    
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad(){
        
        super.viewDidLoad()
        
    }
    
    //MARK: - Memory Management
    
    
    //MARK: - View Will Appear
    
    override func viewWillAppear(_ animated: Bool){
        getIpadNumber()
        if featureId == 1{
            centralSystem.getNetworkParameters()
            centralSystem.mittlagconnect()
            CENTRAL_SYSTEM = centralSystem
            setupLagoonPumpLabel()
            setLagoonPumpNumber()
            readLagoonCurrentPumpDetailsSpecs()
            NotificationCenter.default.addObserver(self, selector: #selector(checkLagonSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
        }
        if featureId == 2{
            centralSystem.getNetworkParameters()
            centralSystem.mittlaconnect()
            CENTRAL_SYSTEM = centralSystem
            setupLakePumpLabel()
            setLakePumpNumber()
            readLakeCurrentPumpDetailsSpecs()
            NotificationCenter.default.addObserver(self, selector: #selector(checkLakeSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
        }
        
        pumpIndicatorLimit = 0
        initializePumpGestureRecognizer()
        //Configure Pump Screen Text Content Based On Device Language
        configureScreenTextContent()
       
        
        
    }
     
    func setupLagoonPumpLabel(){
        switch pumpNumber {
            case 601: vfdNumber.text = "VFD - 601"
            case 602: vfdNumber.text = "VFD - 602"
            case 603: vfdNumber.text = "VFD - 603"
            case 604: vfdNumber.text = "VFD - 604"
            case 605: vfdNumber.text = "VFD - 605"
            case 606: vfdNumber.text = "VFD - 606"
            case 607: vfdNumber.text = "VFD - 607"
            case 608: vfdNumber.text = "VFD - 608"
            case 609: vfdNumber.text = "VFD - 609"
            case 610: vfdNumber.text = "VFD - 610"
            case 611: vfdNumber.text = "VFD - 611"
            case 612: vfdNumber.text = "VFD - 612"
            case 613: vfdNumber.text = "VFD - 613"
            case 614: vfdNumber.text = "VFD - 614"
            case 615: vfdNumber.text = "VFD - 615"
            case 616: vfdNumber.text = "VFD - 616"
            case 617: vfdNumber.text = "VFD - 617"
            case 618: vfdNumber.text = "VFD - 618"
            case 619: vfdNumber.text = "VFD - 619"
            case 620: vfdNumber.text = "VFD - 620"
            case 621: vfdNumber.text = "VFD - 621"
            case 622: vfdNumber.text = "VFD - 622"
            case 623: vfdNumber.text = "VFD - 623"
            case 624: vfdNumber.text = "VFD - 624"
            
        default:
            print("FAULT TAG")
        }
    }
    
    func setupLakePumpLabel(){
        switch pumpNumber {
            case 901: vfdNumber.text = "VFD - 9101"
            case 902: vfdNumber.text = "VFD - 9201"
            case 903: vfdNumber.text = "VFD - 9202"
            case 904: vfdNumber.text = "VFD - 9203"
            case 905: vfdNumber.text = "VFD - 9204"
            case 906: vfdNumber.text = "VFD - 9205"
            case 907: vfdNumber.text = "VFD - 9206"
            
        default:
            print("FAULT TAG")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool){
        
        let registersSET1 = PUMP_SETS[iPadNumber-1]
        let iPadNumberRegister = registersSET1[0]
        if featureId == 1{
            CENTRAL_SYSTEM!.writeRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: iPadNumberRegister.register, value: 0)
        }
        if featureId == 2{
            CENTRAL_SYSTEM!.writeRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: iPadNumberRegister.register, value: 0)
        }
        
        
        
        //NOTE: We need to remove the notification observer so the PUMP stat check point will stop to avoid extra bandwith usage
        NotificationCenter.default.removeObserver(self)
        
    }
    
    
    
    //MARK: - Set Pump Number To PLC
    
    private func setLagoonPumpNumber(){
        
        //Let the PLC know the current PUMP number
        
        let registersSET1 = PUMP_SETS[iPadNumber-1]
        let iPadNumberRegister = registersSET1[0]
        
        CENTRAL_SYSTEM!.writeRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: iPadNumberRegister.register, value: pumpNumber)
        
    }
    
    private func setLakePumpNumber(){
        
        //Let the PLC know the current PUMP number
        
        let registersSET1 = PUMP_SETS[iPadNumber-1]
        let iPadNumberRegister = registersSET1[0]
        
        CENTRAL_SYSTEM!.writeRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: iPadNumberRegister.register, value: pumpNumber)
        
    }
    
    @objc func checkLagonSystemStat(){
        let (plcConnection,_,_,_) = (CENTRAL_SYSTEM?.getConnectivityStat())!
        
        if plcConnection == CONNECTION_STATE_CONNECTED {
            //Change the connection stat indicator
            noConnectionView.alpha = 0

            
            //Now that the connection is established, run functions
            readCurrentLagoonPumpSpeed()
            acquireLagoonDataFromPLC()
            
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
    
    @objc func checkLakeSystemStat(){
        let (_,plcConnection,_,_) = (CENTRAL_SYSTEM?.getConnectivityStat())!
        
        if plcConnection == CONNECTION_STATE_CONNECTED {
            //Change the connection stat indicator
            noConnectionView.alpha = 0

            
            //Now that the connection is established, run functions
            readCurrentLakePumpSpeed()
            acquireLakeDataFromPLC()
            
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
    
    //====================================
    //                                     GET PUMP DETAILS AND READINGS
    //====================================
    
    //MARK: - Configure Screen Text Content Based On Device Language
    
    private func configureScreenTextContent(){
        
        langData = helper.getLanguageSettigns(screenName: PUMPS_LANGUAGE_DATA_PARAM)
        
        frequencyLabel.text = langData["FREQUENCY"]!
        voltageLabel.text = langData["VOLTAGE"]!
        currentLabel.text = langData["CURRENT"]!
        temperatureLabel.text = langData["TEMPERATURE"]!
        
        
        guard pumpModel != nil else {
            
            logger.logData(data: "PUMPS: PUMP MODEL EMPTY")
            
            //If the pump model is empty, put default parameters to avoid system crash
            navigationItem.title = langData["PUMPS DETAILS"]!
            noConnectionErrorLbl.text = "CHECK SETTINGS"
            
            return
            
        }
        
        navigationItem.title = langData[pumpModel!.screenName!]!
        noConnectionErrorLbl.text = pumpModel!.outOfRangeMessage!
        
    }
    
    //MARK: - Get iPad Number
    
    private func getIpadNumber(){
        
        let ipadNum = UserDefaults.standard.object(forKey: IPAD_NUMBER_USER_DEFAULTS_NAME) as? Int
        
        if ipadNum == nil || ipadNum == 0{
            self.iPadNumber = 1
        } else {
            self.iPadNumber = ipadNum!
        }
        
    }
    
    //MARK: - Initialize Filtration Pump Gesture Recognizer
    
    private func initializePumpGestureRecognizer(){
        
        //RME: Initiate PUMP Flow Control Gesture Handler
        
        manualPumpGesture = UIPanGestureRecognizer(target: self, action: #selector(changePumpSpeedFrequency(sender:)))
        setFrequencyHandle.isUserInteractionEnabled = true
        setFrequencyHandle.addGestureRecognizer(self.manualPumpGesture)
        manualPumpGesture.delegate = self
        
    }
    
    @objc private func readLagoonCurrentPumpDetailsSpecs() {
        var pumpSet = 0
        
        if iPadNumber == 1 {
            pumpSet = 0
        } else {
            pumpSet = 1
        }
        
        
        let registersSET1 = PUMP_DETAILS_SETS[pumpSet]
        let startRegister = registersSET1[0]
        
        CENTRAL_SYSTEM!.readRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, length: 5, startingRegister: Int32(startRegister.register), completion:{ (success, response) in
            
            guard success == true else { return }
            
            if self.readPumpDetailSpecsOnce == 0 {
                self.readPumpDetailSpecsOnce = 1
                
                
                self.HZMax = Int(truncating: response![0] as! NSNumber) / 10
                self.voltageMaxRangeValue  = Int(truncating: response![1] as! NSNumber)
                self.voltageMinRangeValue = Int(truncating: response![2] as! NSNumber)
                self.currentMaxRangeValue = Int(truncating: response![3] as! NSNumber) / 10
                self.temperatureMaxRangeValue = Int(truncating: response![4] as! NSNumber)
                
                self.frequencyValueLabel.text = "\(self.HZMax)"
                
                // What we are getting is a range, not the maximum value. So to get the maximum volatage value just add 100.
                
                self.voltageLimit = self.voltageMaxRangeValue + 100
                self.voltageValueLabel.text   = "\(self.voltageLimit)"
                
                // What we are getting is a range, not the maximum value. So to get the maximum current value just add 10.
                self.currentLimit = self.currentMaxRangeValue + 10
                self.currentValueLabel.text = "\(self.currentLimit)"
                
                //Note temperature always stays at 100 limit.
                
                
                //Add necessary view elements to the view
                self.constructViewElements()
            }
            
        })
    }
    
    @objc private func readLakeCurrentPumpDetailsSpecs() {
        var pumpSet = 0
        
        if iPadNumber == 1 {
            pumpSet = 0
        } else {
            pumpSet = 1
        }
        
        
        let registersSET1 = PUMP_DETAILS_SETS[pumpSet]
        let startRegister = registersSET1[0]
        
        CENTRAL_SYSTEM!.readRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, length: 5, startingRegister: Int32(startRegister.register), completion:{ (success, response) in
            
            guard success == true else { return }
            
            if self.readPumpDetailSpecsOnce == 0 {
                self.readPumpDetailSpecsOnce = 1
                
                
                self.HZMax = Int(truncating: response![0] as! NSNumber) / 10
                self.voltageMaxRangeValue  = Int(truncating: response![1] as! NSNumber)
                self.voltageMinRangeValue = Int(truncating: response![2] as! NSNumber)
                self.currentMaxRangeValue = Int(truncating: response![3] as! NSNumber) / 10
                self.temperatureMaxRangeValue = Int(truncating: response![4] as! NSNumber)
                
                self.frequencyValueLabel.text = "\(self.HZMax)"
                
                // What we are getting is a range, not the maximum value. So to get the maximum volatage value just add 100.
                
                self.voltageLimit = self.voltageMaxRangeValue + 100
                self.voltageValueLabel.text   = "\(self.voltageLimit)"
                
                // What we are getting is a range, not the maximum value. So to get the maximum current value just add 10.
                self.currentLimit = self.currentMaxRangeValue + 10
                self.currentValueLabel.text = "\(self.currentLimit)"
                
                //Note temperature always stays at 100 limit.
                
                
                //Add necessary view elements to the view
                self.constructViewElements()
            }
            
        })
    }
    
    //MARK: - Construct View Elements
    
    private func constructViewElements(){
        constructVoltageSlider()
        constructCurrentSlider()
        constructTemperatureSlider()
        
        autoModeIndicator.alpha = 0
        handModeIndicator.alpha = 0
        
    }
    
    
    private func constructVoltageSlider(){
        let frame = 450.0
        pixelPerVoltage = frame / Double(voltageLimit)
        if pixelPerVoltage == Double.infinity {
            pixelPerVoltage = 0
        }
        
        
        let length = Double(voltageMaxRangeValue) * pixelPerVoltage
        let height = Double(voltageMaxRangeValue - voltageMinRangeValue) * pixelPerVoltage
        
        
        voltageSetpointBackground.backgroundColor = GREEN_COLOR
        voltageSetpointBackground.frame = CGRect(x: 0, y: (SLIDER_PIXEL_RANGE - length), width: 25, height: height)
        
    }
    
    private func constructCurrentSlider(){
        let frame = 450.0
        pixelPerCurrent = frame / Double(currentLimit)
        if pixelPerCurrent == Double.infinity {
            pixelPerCurrent = 0
        }
        
        var length = Double(currentMaxRangeValue) * pixelPerCurrent
        let height = Double(currentMaxRangeValue - 0) * pixelPerCurrent
        
        if length > 450{
            length = 450
        }
        
        
        currentSetpointBackground.backgroundColor = GREEN_COLOR
        currentSetpointBackground.frame = CGRect(x: 0, y: (SLIDER_PIXEL_RANGE - length), width: 25, height: height)
    }
    
    private func constructTemperatureSlider(){
        let frame = 450.0
        let temperatureMidRangeValue = 50.0
        pixelPerTemperature = frame / Double(temperatureLimit)
        if pixelPerTemperature == Double.infinity {
            pixelPerTemperature = 0
        }
        
        
        let temperatureRange = Double(temperatureMaxRangeValue) * pixelPerTemperature
        let temperatureFrameHeight = (Double(temperatureMaxRangeValue) - temperatureMidRangeValue) * pixelPerTemperature
        
        temperatureYellow.backgroundColor = .yellow
        temperatureGreen.backgroundColor = GREEN_COLOR
        
        temperatureYellow.frame = CGRect(x: 0, y: (SLIDER_PIXEL_RANGE - temperatureRange), width: 25, height: temperatureFrameHeight)
        temperatureGreen.frame = CGRect(x: 0, y: (SLIDER_PIXEL_RANGE - temperatureRange), width: 25, height: temperatureRange)
        
        
    }
    
    
    //====================================
    //                                     GET PUMP DETAILS AND READINGS
    //====================================
    
    private func readCurrentLagoonPumpSpeed() {
        pumpIndicatorLimit += 1
        
        var pumpSet = 0
        
        iPadNumber == 1 ? (pumpSet = 0) : (pumpSet = 1)
        
        let registersSET1 = PUMP_SETS[pumpSet]
        let startRegister = registersSET1[1]
        
        CENTRAL_SYSTEM!.readRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, length: 14, startingRegister: Int32(startRegister.register), completion:{ (success, response) in
            
            guard response != nil else { return }
            
            self.getVoltageReading(response: response)
            self.getCurrentReading(response: response)
            self.getTemperatureReading(response: response)
            self.getManualSpeedReading(response: response)
            self.getFrequencyReading(response: response)
            self.checkForAutoManMode(response: response)
            self.getManualSpeedReading(response: response)
            
            
            if self.readOnce == 0 {
                self.readOnce = 1
                let feedback = Int(truncating: response![8] as! NSNumber)
                let startStopMode = Int(truncating: response![7] as! NSNumber)
                
                if feedback == 0{
                    
                    //Pump is in auto mode
                    self.localStat = 0
                    self.changeAutManModeIndicatorRotation(autoMode: true)
                    self.autoModeIndicator.alpha = 1
                    self.handModeIndicator.alpha = 0
                    self.frequencyIndicator.isHidden = false
                    self.setFrequencyHandle.isHidden = true
                    self.autoManualButton.setImage(#imageLiteral(resourceName: "pumps_on"), for: .normal)
                    
                }else if feedback == 1 && startStopMode == 1{
                    
                    //Pump is in manual mode
                    self.localStat = 2
                    self.changeAutManModeIndicatorRotation(autoMode: false)
                    self.autoModeIndicator.alpha = 0
                    self.handModeIndicator.alpha = 1
                    self.frequencyIndicator.isHidden = false
                    self.setFrequencyHandle.isHidden = false
                    self.isManualMode = true
                    
                    self.autoManualButton.setImage(#imageLiteral(resourceName: "pumps_on"), for: .normal)
                    
                }else if feedback == 1 && startStopMode == 0{
                    
                    //Pump is in off mode
                    self.localStat = 1
                    self.changeAutManModeIndicatorRotation(autoMode: false)
                    self.autoModeIndicator.alpha = 0
                    self.handModeIndicator.alpha = 0
                    self.frequencyIndicator.isHidden = true
                    self.setFrequencyHandle.isHidden = false
                    self.autoManualButton.setImage(#imageLiteral(resourceName: "pumps"), for: .normal)
                    
                }
                
            }
            
        })
    }
    
    private func readCurrentLakePumpSpeed() {
           pumpIndicatorLimit += 1
           
           var pumpSet = 0
           
           iPadNumber == 1 ? (pumpSet = 0) : (pumpSet = 1)
           
           let registersSET1 = PUMP_SETS[pumpSet]
           let startRegister = registersSET1[1]
           
           CENTRAL_SYSTEM!.readRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, length: 14, startingRegister: Int32(startRegister.register), completion:{ (success, response) in
               
               guard response != nil else { return }
               
               self.getVoltageReading(response: response)
               self.getCurrentReading(response: response)
               self.getTemperatureReading(response: response)
               self.getManualSpeedReading(response: response)
               self.getFrequencyReading(response: response)
               self.checkForAutoManMode(response: response)
               self.getManualSpeedReading(response: response)
               
               
               if self.readOnce == 0 {
                   self.readOnce = 1
                   let feedback = Int(truncating: response![8] as! NSNumber)
                   let startStopMode = Int(truncating: response![7] as! NSNumber)
                   
                   if feedback == 0{
                       
                       //Pump is in auto mode
                       self.localStat = 0
                       self.changeAutManModeIndicatorRotation(autoMode: true)
                       self.autoModeIndicator.alpha = 1
                       self.handModeIndicator.alpha = 0
                       self.frequencyIndicator.isHidden = false
                       self.setFrequencyHandle.isHidden = true
                       self.autoManualButton.setImage(#imageLiteral(resourceName: "pumps_on"), for: .normal)
                       
                   }else if feedback == 1 && startStopMode == 1{
                       
                       //Pump is in manual mode
                       self.localStat = 2
                       self.changeAutManModeIndicatorRotation(autoMode: false)
                       self.autoModeIndicator.alpha = 0
                       self.handModeIndicator.alpha = 1
                       self.frequencyIndicator.isHidden = false
                       self.setFrequencyHandle.isHidden = false
                       self.isManualMode = true
                       
                       self.autoManualButton.setImage(#imageLiteral(resourceName: "pumps_on"), for: .normal)
                       
                   }else if feedback == 1 && startStopMode == 0{
                       
                       //Pump is in off mode
                       self.localStat = 1
                       self.changeAutManModeIndicatorRotation(autoMode: false)
                       self.autoModeIndicator.alpha = 0
                       self.handModeIndicator.alpha = 0
                       self.frequencyIndicator.isHidden = true
                       self.setFrequencyHandle.isHidden = false
                       self.autoManualButton.setImage(#imageLiteral(resourceName: "pumps"), for: .normal)
                       
                   }
                   
               }
               
           })
       }
    
    func pad(string : String, toSize: Int) -> String{
        
        var padded = string
        
        for _ in 0..<toSize - string.characters.count{
            padded = "0" + padded
        }
        
        return padded
        
    }
    
    
    //MARK: - Read Water On Fire Values
    
    private func acquireDataFromPLC(){
        var faultStates = 0
        
        if iPadNumber == 1 {
            faultStates = 12
        } else {
            faultStates = 32
        }
        
        CENTRAL_SYSTEM?.readRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, length: 1, startingRegister: Int32(faultStates), completion:{ (success, response) in
            
            guard success == true else { return }
                
                //Bitwise Operation
                let decimalRsp = Int(truncating: response![0] as! NSNumber)
                let base_2_binary = String(decimalRsp, radix: 2)
                let Bit_16:String = self.pad(string: base_2_binary, toSize: 16)  //Convert to 16 bit
                let bits =  Bit_16.characters.map { String($0) }
                self.parseStates(bits: bits)
                
            
        })
    }
    
    private func acquireLagoonDataFromPLC(){
        var faultStates = 0
        
        if iPadNumber == 1 {
            faultStates = 12
        } else {
            faultStates = 32
        }
        
        CENTRAL_SYSTEM?.readRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, length: 1, startingRegister: Int32(faultStates), completion:{ (success, response) in
            
            guard success == true else { return }
                
                //Bitwise Operation
                let decimalRsp = Int(truncating: response![0] as! NSNumber)
                let base_2_binary = String(decimalRsp, radix: 2)
                let Bit_16:String = self.pad(string: base_2_binary, toSize: 16)  //Convert to 16 bit
                let bits =  Bit_16.characters.map { String($0) }
                self.parseStates(bits: bits)
                
            
        })
    }
    
    private func acquireLakeDataFromPLC(){
        var faultStates = 0
        
        if iPadNumber == 1 {
            faultStates = 12
        } else {
            faultStates = 32
        }
        
        CENTRAL_SYSTEM?.readRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, length: 1, startingRegister: Int32(faultStates), completion:{ (success, response) in
            
            guard success == true else { return }
                
                //Bitwise Operation
                let decimalRsp = Int(truncating: response![0] as! NSNumber)
                let base_2_binary = String(decimalRsp, radix: 2)
                let Bit_16:String = self.pad(string: base_2_binary, toSize: 16)  //Convert to 16 bit
                let bits =  Bit_16.characters.map { String($0) }
                self.parseStates(bits: bits)
                
            
        })
    }
    
    private func parseStates(bits:[String]){
        
        
        for fault in PUMP_FAULT_SET {
            
            let faultTag = fault.tag
            let state = Int(bits[15 - fault.bitwiseLocation])
            let indicator = view.viewWithTag(faultTag) as? UILabel
            
            if faultTag != 204 && faultTag != 207 && faultTag != 209
            {
                if state == 1
                {
                    indicator?.isHidden = false
                }
                else
                {
                    indicator?.isHidden = true
                }
            }
            if faultTag == 209 {
                if state == 1 {
                    indicator?.isHidden = false
                } else {
                    indicator?.isHidden = true
                }
            }
            
            if faultTag == 204 {
                if state == 1 {
                    indicator?.isHidden = true
                } else {
                    indicator?.isHidden = false
                }
            }
            
            if faultTag == 207 {
                
                readPlayStopBit(startStopMode: state ?? 0)
            }
            
            
        }
        
    }
    
    
    
    
    //MARK: - Get Voltage Reading
    
    private func getVoltageReading(response:[AnyObject]?){
        let voltage = Int(truncating: response![3] as! NSNumber)
        let voltageValue = voltage / 10
        let voltageRemainder = voltage % 10
        let indicatorLocation = abs(735 - (Double(voltageValue) * pixelPerVoltage))
        
        if voltageValue >= voltageLimit {
            voltageIndicator.frame = CGRect(x: 459, y: 288, width: 92, height: 23)
        } else if voltageValue <= 0 {
            voltageIndicator.frame = CGRect(x: 459, y: 738, width: 92, height: 23)
        } else {
            voltageIndicator.frame = CGRect(x: 459, y: indicatorLocation, width: 92, height: 23)
        }
        
        voltageIndicatorValue.text = "\(voltageValue).\(voltageRemainder)"
        
        if voltageValue > voltageMaxRangeValue || voltageValue < voltageMinRangeValue {
            voltageIndicatorValue.textColor = RED_COLOR
        } else {
            voltageIndicatorValue.textColor = GREEN_COLOR
        }
    }
    
    //MARK: Get Current Reading
    
    let currentScalingFactorPump = 100  // was 100
    
    
    private func getCurrentReading(response:[AnyObject]?){
        let current = Int(truncating: response![2] as! NSNumber)
        let currentValue = current / currentScalingFactorPump
        let currentRemainder = current % currentScalingFactorPump
        let indicatorLocation = abs(735 - (Double(currentValue) * pixelPerCurrent))
        
        if currentValue >= currentLimit {
            currentIndicator.frame = CGRect(x: 640, y: 288, width: 92, height: 23)
        } else if currentValue <= 0 {
            currentIndicator.frame = CGRect(x: 640, y: 738, width: 92, height: 23)
        } else {
            currentIndicator.frame = CGRect(x: 640, y: indicatorLocation, width: 92, height: 23)
        }
        
        currentIndicatorValues.text = "\(currentValue).\(currentRemainder)"
        
        if currentValue > Int(currentMaxRangeValue){
            currentIndicatorValues.textColor = RED_COLOR
        } else {
            currentIndicatorValues.textColor = GREEN_COLOR
        }
    }
    
    //MARK: - Get Temperature Reading
    
    private func getTemperatureReading(response:[AnyObject]?){
        let temperature = Int(truncating: response![4] as! NSNumber)
        let temperatureMid = 50
        let indicatorLocation = 735 - (Double(temperature) * pixelPerTemperature)
        
        if temperature >= 100 {
            temperatureIndicator.frame = CGRect(x: 830, y: 288, width: 75, height: 23)
        } else if temperature <= 0 {
            temperatureIndicator.frame = CGRect(x: 830, y: 738, width: 75, height: 23)
        } else {
            temperatureIndicator.frame = CGRect(x: 830, y: indicatorLocation, width: 75, height: 23)
        }
        
        
        temperatureIndicatorValue.text = "\(temperature)"
        
        if temperature > temperatureMaxRangeValue {
            temperatureIndicatorValue.textColor = RED_COLOR
        }else if temperature > temperatureMid && temperature < temperatureMaxRangeValue {
            temperatureIndicatorValue.textColor = .yellow
        }else{
            temperatureIndicatorValue.textColor = GREEN_COLOR
        }
        
    }
    
    //MARK: - Get Frequency Reading
    
    private func getFrequencyReading(response:[AnyObject]?){
        // If pumpstate == 0 (Auto) then show the frequency indicator/background frame/indicator value. Note: the frequency indicator's user interaction is disabled.
        
        let frequency = Int(truncating: response![1] as! NSNumber)
        
        let frequencyValue = frequency / 10
        let frequencyRemainder = frequency % 10
        var pixelPerFrequency = 450.0 / Double(HZMax)
        if pixelPerFrequency == Double.infinity {
            pixelPerFrequency = 0
        }
        
        let length = Double(frequencyValue) * pixelPerFrequency
        
        if frequencyValue > Int(HZMax){
            frequencySetpointBackground.frame =  CGRect(x: 0, y: 0, width: 25, height: 450)
            frequencyIndicator.frame = CGRect(x: 252, y: 288, width: 86, height: 23)
            frequencyIndicatorValue.text = "\(HZMax)"
        } else {
            frequencySetpointBackground.frame =  CGRect(x: 0, y: (SLIDER_PIXEL_RANGE - length), width: 25, height: length)
            frequencyIndicator.frame = CGRect(x: 252, y: (738 - length), width: 86, height: 23)
            frequencyIndicatorValue.text = "\(frequencyValue).\(frequencyRemainder)"
            
            
        }
        
    }
    
    
    //====================================
    //                                      AUTO / MANUAL MODE
    //====================================
    
    
    //MARK: - Check For Auto/Man Mode
    
    private func checkForAutoManMode(response:[AnyObject]?){
        
        let feedback = Int(truncating: response![6] as! NSNumber)
        let startStopMode = Int(truncating: response![7] as! NSNumber)
        
        if feedback == 0 && self.localStat == 0{
            
            //Pump is in auto mode
            self.pumpState = 0
            self.changeAutManModeIndicatorRotation(autoMode: true)
            self.autoModeIndicator.alpha = 1
            self.handModeIndicator.alpha = 0
            self.manualSpeedView.alpha = 0
            self.frequencyIndicator.isHidden = false
            self.setFrequencyHandle.isHidden = true
            self.autoManualButton.setImage(#imageLiteral(resourceName: "pumps_on"), for: .normal)
            
        }else if feedback == 1 && startStopMode == 0 && self.localStat == 1{
            
            //Pump is in off mode
            self.pumpState = 1
            self.changeAutManModeIndicatorRotation(autoMode: false)
            self.autoModeIndicator.alpha = 0
            self.handModeIndicator.alpha = 0
            self.manualSpeedView.alpha = 0
            self.frequencyIndicator.isHidden = true
            self.setFrequencyHandle.isHidden = true
            self.autoManualButton.setImage(#imageLiteral(resourceName: "pumps"), for: .normal)
            
        }else if feedback == 1 && startStopMode == 0 && self.localStat == 2{
            
            //Pump is in manual mode
            self.pumpState = 2
            self.changeAutManModeIndicatorRotation(autoMode: false)
            self.autoModeIndicator.alpha = 0
            self.handModeIndicator.alpha = 1
            self.manualSpeedView.alpha = 1
            self.frequencyIndicator.isHidden = false
            self.setFrequencyHandle.isHidden = false
            self.autoManualButton.setImage(#imageLiteral(resourceName: "pumps_on"), for: .normal)
            
        }else if feedback == 1 && startStopMode == 0 && self.localStat == 3{
            
            //Pump is in off mode
            self.pumpState = 3
            self.changeAutManModeIndicatorRotation(autoMode: false)
            self.autoModeIndicator.alpha = 0
            self.handModeIndicator.alpha = 0
            self.manualSpeedView.alpha = 0
            self.frequencyIndicator.isHidden = true
            self.setFrequencyHandle.isHidden = true
            self.autoManualButton.setImage(#imageLiteral(resourceName: "pumps"), for: .normal)
            
        }
        
        
    }
    
    
    
    
    @IBAction func changeAutoManMode(_ sender: Any) {
        
        var manualBit = 0
        var autoBit = 0
        var startStopBit = 0
        
        
        if iPadNumber == 1{
            
            let registerSet = PUMP_SETS[0]
            
            autoBit = registerSet[6].register
            manualBit = registerSet[7].register
            startStopBit = registerSet[8].register
            
            
        }else{
            
            let registerSet = PUMP_SETS[1]
            
            
            autoBit = registerSet[6].register
            manualBit = registerSet[7].register
            startStopBit = registerSet[8].register
            
            
        }
        
        if featureId == 1{
            switch pumpState{
                
            case 0:
                
                //Switch to off mode
                self.localStat = 1
                CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: manualBit, value: 1)
                CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: autoBit, value: 0)
                CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: startStopBit, value: 0)
                isManualMode = false
                
                break
                
            case 1:
                
                //Switch to Manual Mode mode
                self.localStat = 2
                
                CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: manualBit, value: 1)
                CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: autoBit, value: 0)
                CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: startStopBit, value: 0)
                isManualMode = true
                
                
                break
                
            case 2:
                
                //Switch to off mode
                self.localStat = 3
                CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: manualBit, value: 1)
                CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: autoBit, value: 0)
                CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: startStopBit, value: 0)
                isManualMode = false
                
                
                break
                
            case 3:
                
                //Switch To Auto Mode
                self.localStat = 0
                CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: manualBit, value: 0)
                CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: autoBit, value: 1)
                CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: startStopBit, value: 0)
                isManualMode = false
                
                
                
                break
                
                
            default:
                
                print("PUMP STATE NOT FOUND")
                
            }
        }
        if featureId == 2{
            switch pumpState{
                
            case 0:
                
                //Switch to off mode
                self.localStat = 1
                CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: manualBit, value: 1)
                CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: autoBit, value: 0)
                CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: startStopBit, value: 0)
                isManualMode = false
                
                break
                
            case 1:
                
                //Switch to Manual Mode mode
                self.localStat = 2
                
                CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: manualBit, value: 1)
                CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: autoBit, value: 0)
                CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: startStopBit, value: 0)
                isManualMode = true
                
                
                break
                
            case 2:
                
                //Switch to off mode
                self.localStat = 3
                CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: manualBit, value: 1)
                CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: autoBit, value: 0)
                CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: startStopBit, value: 0)
                isManualMode = false
                
                
                break
                
            case 3:
                
                //Switch To Auto Mode
                self.localStat = 0
                CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: manualBit, value: 0)
                CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: autoBit, value: 1)
                CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: startStopBit, value: 0)
                isManualMode = false
                
                
                
                break
                
                
            default:
                
                print("PUMP STATE NOT FOUND")
                
            }
        }
        
    }
    
    
    private func readPlayStopBit(startStopMode: Int) {
        if isManualMode {
            playStopButtonIcon.isHidden = false
            
            if startStopMode == 1 {
                //stop
                playStopButtonIcon.setImage(#imageLiteral(resourceName: "stopButton"), for: .normal)
                
            } else {
                //play
                playStopButtonIcon.setImage(#imageLiteral(resourceName: "playButton"), for: .normal)
                
            }
        } else {
            playStopButtonIcon.isHidden = true
        }
    }
    
    @IBAction func playStopButtonPressed(_ sender: Any) {
        var startStopBit = 0
        
        if iPadNumber == 1 {
            startStopBit = 9
        } else {
            startStopBit = 29
        }
        
        if featureId == 1{
            if playStopButtonIcon.imageView?.image == #imageLiteral(resourceName: "playButton") {
                CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: startStopBit, value: 1)
            } else {
                CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: startStopBit, value: 0)
            }
        }
        if featureId == 2{
            if playStopButtonIcon.imageView?.image == #imageLiteral(resourceName: "playButton") {
                CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: startStopBit, value: 1)
            } else {
                CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: startStopBit, value: 0)
            }
        }
    }
    
    
    //MARK: - Change Auto/Man Mode Indicator Rotation
    
    func changeAutManModeIndicatorRotation(autoMode:Bool){
        
        /*
         NOTE: 2 Possible Options
         Option 1: Automode (animate) = True => Will result in any view object to rotate 360 degrees infinitly
         Option 2: Automode (animate) = False => Will result in any view object to stand still
         */
        
        
        
        if autoMode == true{  
            self.autoModeIndicator.alpha = 1
            self.handModeIndicator.alpha = 0
            autoModeIndicator.rotate360Degrees(animate: true)
            
        }else{
            
            self.autoModeIndicator.alpha = 1
            self.handModeIndicator.alpha = 0
            
        }
        
    }
    
    
    
    //====================================
    //                                      MANUAL PUMP CONTROL
    //====================================
    
    
    private func getManualSpeedReading(response: [AnyObject]?){
        if readManualFrequencySpeed || !readManualFrequencySpeedOnce {
            readManualFrequencySpeedOnce = true
            readManualFrequencySpeed = false
            
            let manualSpeed = Int(truncating: response![0] as! NSNumber)
            
            let manualSpeedValue = manualSpeed / 10
            let manualSpeedRemainder = manualSpeed % 10
            var pixelPerFrequency = 450.0 / Double(HZMax)
            
            if pixelPerFrequency == Double.infinity {
                pixelPerFrequency = 0
            }
            
            let length = Double(manualSpeedValue) * pixelPerFrequency
            
            
            if manualSpeedValue > Int(HZMax){
                setFrequencyHandle.frame = CGRect(x: 443, y: 285, width: 108, height: 26)
                frequencySetLabel.textColor = DEFAULT_GRAY
                frequencySetLabel.text = "\(HZMax)"
                self.manualSpeedValue.text  = "\(HZMax)"
            } else {
                setFrequencyHandle.frame = CGRect(x: 443, y: (735 - length), width: 108, height: 26)
                frequencySetLabel.textColor = DEFAULT_GRAY
                frequencySetLabel.text = "\(manualSpeedValue).\(manualSpeedRemainder)"
                 self.manualSpeedValue.text  = "\(manualSpeedValue).\(manualSpeedRemainder)"
            }
            
        }
        
    }
    
    
    
    @objc func changePumpSpeedFrequency(sender: UIPanGestureRecognizer){
        
        setFrequencyHandle.isUserInteractionEnabled = true
        frequencySetLabel.textColor = GREEN_COLOR
        var touchLocation:CGPoint = sender.location(in: self.view)
        print(touchLocation.y)
        //Make sure that we don't go more than pump flow limit
        if touchLocation.y  < 298 {
            touchLocation.y = 298
        }
        if touchLocation.y  > 748 {
            touchLocation.y = 748
        }
        
        //Make sure that we don't go more than pump flow limit
        if touchLocation.y >= 298 && touchLocation.y <= 748 {
            
            sender.view?.center.y = touchLocation.y
            
            let flowRange = 748 - Int(touchLocation.y)
            let pixelPerFrequency = 450.0 / Double(HZMax)
            let herts = Double(flowRange) / pixelPerFrequency
            let formattedHerts = String(format: "%.1f", herts)
            let convertedHerts = Int(herts * 10)
            
            print(convertedHerts)
            frequencySetLabel.text = formattedHerts
            
            if featureId == 1{
                if sender.state == .ended {
                    if iPadNumber == 1{
                        CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: 2, value: convertedHerts) //NOTE: We multiply the frequency by 10 becuase PLC expects 3 digit number
                        setReadManualSpeedBoolean()
                        
                    } else {
                        CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: 22, value: convertedHerts) //NOTE: We multiply the frequency by 10 becuase PLC expects 3 digit number
                        setReadManualSpeedBoolean()
                    }
                }
            }
        
            if featureId == 2{
               if sender.state == .ended {
                    if iPadNumber == 1{
                        CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: 2, value: convertedHerts) //NOTE: We multiply the frequency by 10 becuase PLC expects 3 digit number
                        setReadManualSpeedBoolean()
                        
                    } else {
                        CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: 22, value: convertedHerts) //NOTE: We multiply the frequency by 10 becuase PLC expects 3 digit number
                        setReadManualSpeedBoolean()
                    }
                }
            }
        }
        
        
    }
    
    @IBAction func setManualSpeed(_ sender: UIButton) {
        var manSpeed  = Float(self.manualSpeedValue.text!)
        self.manualSpeedValue.text = ""
        if manSpeed == nil{
            manSpeed = 0
        }
        if manSpeed! > 50 {
            manSpeed = 50
        }
        manSpeed = manSpeed! * 10
        if featureId == 1{
            if iPadNumber == 1{
                
                
                CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: 2, value: Int(manSpeed!))
                
                
            } else {
                
                
                CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: 22, value: Int(manSpeed!))
                
            }
        }
        
        if featureId == 2{
            if iPadNumber == 1{
                
                
                CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: 2, value: Int(manSpeed!))
                
                
            } else {
                
                
                CENTRAL_SYSTEM?.writeRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: 22, value: Int(manSpeed!))
                
            }
        }
        readManualFrequencySpeedOnce = false
    }
    private func setReadManualSpeedBoolean(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.50) {
            self.readManualFrequencySpeed = true
            self.frequencySetLabel.textColor = DEFAULT_GRAY
        }
    }
    
}
