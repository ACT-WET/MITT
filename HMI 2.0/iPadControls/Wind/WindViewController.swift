//=================================== ABOUT ===================================

/*
 *  @FILE:          WindViewController.swift
 *  @AUTHOR:        Arpi Derm
 *  @RELEASE_DATE:  July 28, 2017, 4:13 PM
 *  @Description:   This Module reads all wind sensor data and allows to set the 
 *                  wind sensor settings and setpoints
 *  @VERSION:       2.0.0
 */

 /***************************************************************************
 *
 * PROJECT SPECIFIC CONFIGURATION
 *
 * 1 : Wind Screen screen configuration parameters located in specs.swift file
 *     should be modified
 * 2 : If multiple wind sensors, the readings and data declerations need to be coppied
 ***************************************************************************/

import UIKit

class WindViewController: UIViewController{

    @IBOutlet weak var windStat: UIImageView!
    
    @IBOutlet weak var highWindMde: UIButton!
    @IBOutlet weak var medWindMde: UIButton!
    @IBOutlet weak var loWindMde: UIButton!
    @IBOutlet weak var noWindMde: UIButton!
    @IBOutlet weak var autoBtn: UIButton!
    @IBOutlet weak var windModeState: UILabel!
    @IBOutlet weak var handBtn: UIButton!
    @IBOutlet weak var noConnectionView: UIView!
    @IBOutlet weak var noConnectionErrorLbl: UILabel!

    //MARK: - Class Reference Objects -- Dependencies
    
    private let logger = Logger()
    private let helper = Helper()
    
    //MARK: - Data Structures
    
    private var langData = Dictionary<String, String>()
    private var windModel:Wind?
    private let wind_sensor_1   = WIND_SENSOR_1()  //If there are more wind sensors, this variable needs to be duplicated and number incremented
    private let wind_sensor_2   = WIND_SENSOR_2()
    
    private var wind_sensors:Array<Any>?
    private var wind_sensors2:Array<Any>?
    
    private var sensorNumber    = 0
    private var counter         = 0
    private var aboveHigh       = 0
    private var belowLow        = 0
    var windId = 0
    private var windChannelFaults: [Int] = []

    /***************************************************************************
     * Function :  viewDidLoad
     * Input    :  none
     * Output   :  none
     * Comment  :  
     ***************************************************************************/

    override func viewDidLoad(){
        
        super.viewDidLoad()
        
        wind_sensors  = [wind_sensor_1,wind_sensor_2]
   
    }
    
    /***************************************************************************
     * Function :  viewWillAppear
     * Input    :  none
     * Output   :  none
     * Comment  :  
     ***************************************************************************/

    override func viewWillAppear(_ animated: Bool){
        //Get Wind Parameters From Local Storage
        getWindParameters()
        
        //Configure Wind  Screen
        constructWindSensorMeters()
        
        //Configure Wind Screen Text Content Based On Device Language
        configureScreenTextContent()
        NotificationCenter.default.addObserver(self, selector: #selector(checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
        //Add notification observer to get system stat

    }
    
    /***************************************************************************
     * Function :  viewWillDisappear
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
        let (plcConnection,_,_,_) = (CENTRAL_SYSTEM?.getConnectivityStat())!
        
        if plcConnection == CONNECTION_STATE_CONNECTED {
            //Change the connection stat indicator
            noConnectionView.alpha = 0
            noConnectionView.isUserInteractionEnabled = false
            
            //Now that the connection is established, run functions
            readWindSensorData()
            getChannelFaults()
            
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
     * Function :  getWindParameters
     * Input    :  none
     * Output   :  none
     * Comment  :  
     ***************************************************************************/
         
    private func getWindParameters(){
        
        //Fetch Wind Settings From Local Core Data Storage
        let wind = Wind.all() as! [Wind]
        
        self.logger.logData(data: "WIND - MODEL COUNT -> \(wind.count)")
        
        guard wind.count != 0 else{
            return
        }
        
        windModel = wind[0] as Wind
    
    }

    /***************************************************************************
     * Function :  configureScreenTextContent
     * Input    :  none
     * Output   :  none
     * Comment  :  
     ***************************************************************************/

    private func configureScreenTextContent(){
        
        langData = self.helper.getLanguageSettigns(screenName: WIND_SCREEN_LANGUAGE_DATA_PARAM)
        
        guard windModel != nil else{
            
            self.logger.logData(data: "WIND: WIND MODEL EMPTY")
            
            //If the wind model is empty, put default parameters to avoid system crash
            self.navigationItem.title = langData["WIND"]!
            
            return
            
        }
        
        self.navigationItem.title = langData["WIND"]!
    }

    /***************************************************************************
     * Function :  constructWindSensorMeters
     * Input    :  none
     * Output   :  none
     * Comment  :  
     ***************************************************************************/

    private func constructWindSensorMeters(){
        
        guard windModel != nil else{
            return
        }
    
        //Set Speed Unit Of Measure
        //self.setWindSpeedUnitOfMeasure(metric: windModel!.metric, labelTag: WIND_SPEED_MEASURE_UNIT_1_UI_TAG)

        //Enable Disable Setpoint Button
        //self.enableDisableSetPoints(setPointEnabled: self.windModel!.enableSetPoints, buttonTag: WIND_SET_POINT_ENABLE_BTN_1_UI_TAG)

    }
    
    /***************************************************************************
     * Function :  setWindSpeedUnitOfMeasure
     * Input    :  metric yes/no, ui label tag
     * Output   :  none
     * Comment  :  
     ***************************************************************************/

    private func setWindSpeedUnitOfMeasure(metric:Bool,labelTag:Int){
    
        let sensorMetricLbl = self.view.viewWithTag(labelTag) as! UILabel

        if metric == true{
            
            sensorMetricLbl.text = "KM/H"
            
        }else{
            
            sensorMetricLbl.text = "MPH"

        }
        
    }
    
    /***************************************************************************
     * Function :  enableDisableSetPoints
     * Input    :  none
     * Output   :  none
     * Comment  :  
     ***************************************************************************/

    private func enableDisableSetPoints(setPointEnabled:Bool,buttonTag:Int){
        
        let setPointButton = self.view.viewWithTag(buttonTag) as! UIButton
        
        if setPointEnabled == true{
            
            setPointButton.isHidden = false
            
        }else{
            
            setPointButton.isHidden = true
            
        }
        
    }
    
    /***************************************************************************
     * Function :  readWindSensorData
     * Input    :  none
     * Output   :  none
     * Comment  :  read all wind sensor speed data
     ***************************************************************************/
    
    private func readWindSensorData(){
        
            self.readWindSpeed(register: self.wind_sensor_1.SPEED_SCALED_VALUE.register, labelTag: WIND_SPEED_1_UI_TAG)
            //Read wind direction for all wind sensors
            self.readWindDirection(register: self.wind_sensor_1.DIRECTION_SCALED_VALUE.register, directionTag: WIND_DIRECTION_1_UI_TAG)
        
            self.readWindSpeed(register: self.wind_sensor_2.SPEED_SCALED_VALUE.register, labelTag: WIND_SPEED_2_UI_TAG)
            //Read wind direction for all wind sensors
            self.readWindDirection(register: self.wind_sensor_2.DIRECTION_SCALED_VALUE.register, directionTag: WIND_DIRECTION_2_UI_TAG)
            
            CENTRAL_SYSTEM?.readRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, length: 1, startingRegister: Int32(WIND_SPM_HAND_MODE), completion:{ (success, response) in
                
               guard success == true else { return }
               let nW = self.view.viewWithTag(891) as? UIButton
               let lW = self.view.viewWithTag(892) as? UIButton
               let mW = self.view.viewWithTag(893) as? UIButton
               let hW = self.view.viewWithTag(894) as? UIButton
                
               let frceWindState = Int(truncating: response![0] as! NSNumber)
                if frceWindState == 0{
                    nW?.setTitleColor(GREEN_COLOR, for: .normal)
                    lW?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    mW?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    hW?.setTitleColor(DEFAULT_GRAY, for: .normal)
                }
                if frceWindState == 1{
                    nW?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    lW?.setTitleColor(GREEN_COLOR, for: .normal)
                    mW?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    hW?.setTitleColor(DEFAULT_GRAY, for: .normal)
                }
                if frceWindState == 2{
                    nW?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    lW?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    mW?.setTitleColor(GREEN_COLOR, for: .normal)
                    hW?.setTitleColor(DEFAULT_GRAY, for: .normal)
                }
                if frceWindState == 3{
                    nW?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    lW?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    mW?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    hW?.setTitleColor(GREEN_COLOR, for: .normal)
                }
                if frceWindState == 5{
                    nW?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    lW?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    mW?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    hW?.setTitleColor(DEFAULT_GRAY, for: .normal)
                }
            })
        
    }
    
    /***************************************************************************
     * Function :  getChannelFaults
     * Input    :  none
     * Output   :  none
     * Comment  :  might include few wind sensor readings
     ***************************************************************************/

    private func getChannelFaults(){
        
        
            self.readChannelFault(register: self.wind_sensor_1.DIRECTION_CHANNEL_FAULT.register)
            self.readChannelFault(register: self.wind_sensor_1.SPEED_CHANNEL_FAULT.register)
        
           self.readChannelFault(register: self.wind_sensor_2.DIRECTION_CHANNEL_FAULT.register)
            self.readChannelFault(register: self.wind_sensor_2.SPEED_CHANNEL_FAULT.register)
    
        if windChannelFaults.contains(1) {
            windStat.image = #imageLiteral(resourceName: "windicon")
            
        } else {
            windStat.image = #imageLiteral(resourceName: "wind_icon")
        }
        
        CENTRAL_SYSTEM?.readBits(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, length: 1, startingRegister: Int32(WIND_MODE), completion:{ (success, response) in
        
            guard success == true else { return }
            
            let modeVal = Int(truncating: response![0] as! NSNumber)
            
            if modeVal == 1{
                self.handBtn.isEnabled = true
                self.autoBtn.isEnabled = false
                self.noWindMde.isHidden = false
                self.loWindMde.isHidden = false
                self.highWindMde.isHidden = false
                self.medWindMde.isHidden = false
                self.windModeState.text = "WIND MODE IN HAND"
            } else if modeVal == 0{
                self.handBtn.isEnabled = false
                self.autoBtn.isEnabled = true
                self.noWindMde.isHidden = true
                self.loWindMde.isHidden = true
                self.highWindMde.isHidden = true
                self.medWindMde.isHidden = true
                self.windModeState.text = "WIND MODE IN AUTO"
            }
            
        })

    }
    
    /***************************************************************************
     * Function :  readChannelFault
     * Input    :  channel fault PLC Address
     * Output   :  none
     * Comment  : 
     ***************************************************************************/

    private func readChannelFault(register: Int){
        
        CENTRAL_SYSTEM?.readBits(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, length: 1, startingRegister: Int32(register), completion:{ (success, response) in
        
            guard success == true else { return }
            
            if self.windChannelFaults.count == 2 {
                self.windChannelFaults.removeAll()
                
            }
            
            let channelFault = Int(truncating: response![0] as! NSNumber)
            
            self.windChannelFaults.append(channelFault)
            
        })
    }
    
    /***************************************************************************
     * Function :  readWindSpeed
     * Input    :  speed plc address, speed label ui tag
     * Output   :  none
     * Comment  : 
     ***************************************************************************/

    private func readWindSpeed(register:Int, labelTag:Int){
        
        guard windModel != nil else{
            return
        }
        
        
            CENTRAL_SYSTEM?.readBits(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, length: 1, startingRegister: Int32(self.wind_sensor_1.SPEED_ABOVE_HIGH.register), completion:{ (success, response) in
                
                guard success == true else{return}
                let aboveHighValue = Int(truncating: response![0] as! NSNumber)
                self.aboveHigh = aboveHighValue
                
            })
            
            CENTRAL_SYSTEM?.readBits(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, length: 1, startingRegister: Int32(self.wind_sensor_1.SPEED_BELOW_LOW.register), completion:{ (success, response) in
                
                guard success == true else{return}
                let belowLowValue = Int(truncating: response![0] as! NSNumber)
                self.belowLow = belowLowValue
                
            })
        
           CENTRAL_SYSTEM?.readBits(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, length: 1, startingRegister: Int32(self.wind_sensor_2.SPEED_ABOVE_HIGH.register), completion:{ (success, response) in
               
               guard success == true else{return}
               let aboveHighValue = Int(truncating: response![0] as! NSNumber)
               self.aboveHigh = aboveHighValue
               
           })
           
           CENTRAL_SYSTEM?.readBits(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, length: 1, startingRegister: Int32(self.wind_sensor_2.SPEED_BELOW_LOW.register), completion:{ (success, response) in
               
               guard success == true else{return}
               let belowLowValue = Int(truncating: response![0] as! NSNumber)
               self.belowLow = belowLowValue
               
           })
        
        
        CENTRAL_SYSTEM!.readRealRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: register, length: 2){ (success, response)  in
            
            //We want to make sure the PLC read was successfull and we did not get empty response
            
            guard success == true else{
                return
            }
            
            let windSpeedLbl = self.view.viewWithTag(labelTag) as! UILabel

            if self.windModel!.metric == true{

                let metricValue  = Float(response)! * 1.609344
                windSpeedLbl.text = "\(round(10 * metricValue)/10)"

            }else{

                windSpeedLbl.text = "\(round(10*(Float(response)!))/10)"

            }
            
            self.changeWindSpeedColor(labelTag: labelTag)
            
        }
        
        
    }
    
    /***************************************************************************
     * Function :  changeWindSpeedColor
     * Input    :  none
     * Output   :  none
     * Comment  :  Change the wind speed indicator color based on current value
     ***************************************************************************/
    
    private func changeWindSpeedColor(labelTag:Int){
        
        let windSpeedLbl = self.view.viewWithTag(labelTag) as! UILabel

        if self.aboveHigh == 1{
            windSpeedLbl.textColor = RED_COLOR
        }else if self.belowLow == 1 {
            windSpeedLbl.textColor = GREEN_COLOR
        }else if self.aboveHigh == 0 && self.belowLow == 0{
            windSpeedLbl.textColor = ORANGE_COLOR
        }
        
    }
    
    /***************************************************************************
     * Function :  readWindDirection
     * Input    :  direction plc address, direction ui tag
     * Output   :  none
     * Comment  : 
     ***************************************************************************/

    private func readWindDirection(register:Int, directionTag:Int){
        
        CENTRAL_SYSTEM!.readRealRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: register, length: 2){ (success, response)  in
            
            //We want to make sure the PLC read was successfull and we did not get empty response
            guard success == true else{
                return
            }
        
            self.logger.logData(data: "RECIEVING  DIRECTION : \(response)")
        
            //Calculate wind speed direction
            let rotationAngle = (Float(response)! * 0.0174533) 
        
            let directionImage = self.view.viewWithTag(directionTag) as! UIImageView
            directionImage.transform = CGAffineTransform(rotationAngle: CGFloat(rotationAngle))
            
        }
    }

    /***************************************************************************
     * Function :  showSetpoints
     * Input    :  none
     * Output   :  none
     * Comment  :  This function constructs the popup view for wind setpoins
     ***************************************************************************/

    @IBAction func showSetpoints(_ sender: UIButton){
            let storyboard = UIStoryboard(name: "wind", bundle: nil)
            let popoverContent = storyboard.instantiateViewController(withIdentifier: "windDetails") as! WindAnemometerViewController
            popoverContent.sensorNumber = sender.tag
            popoverContent.wind_sensors = wind_sensors
            let nav = UINavigationController(rootViewController: popoverContent)
            nav.modalPresentationStyle = .popover
            nav.isNavigationBarHidden = true
            let popover = nav.popoverPresentationController
            popover?.permittedArrowDirections = .up
            popoverContent.preferredContentSize = CGSize(width: 470, height: 550)
            popover?.sourceView = sender
            
            self.present(nav, animated: true, completion: nil)
    }
    @IBAction func showAlertSettings(_ sender: UIButton) {
        self.addAlertAction(button: sender)
    }
    
    @IBAction func frceSPMMode(_ sender: UIButton) {
        if sender.tag == 891{
            CENTRAL_SYSTEM!.writeRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: WIND_SPM_HAND_MODE, value: 0)
        }
        if sender.tag == 892{
            CENTRAL_SYSTEM!.writeRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: WIND_SPM_HAND_MODE, value: 1)
        }
        if sender.tag == 893{
            CENTRAL_SYSTEM!.writeRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: WIND_SPM_HAND_MODE, value: 2)
        }
        if sender.tag == 894{
            CENTRAL_SYSTEM!.writeRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: WIND_SPM_HAND_MODE, value: 3)
        }
    }
    
    
    @IBAction func changeMode(_ sender: UIButton) {
        if sender.tag == 1{
            CENTRAL_SYSTEM?.writeBit(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, bit: WIND_MODE, value: 0)
            CENTRAL_SYSTEM!.writeRegister(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, register: WIND_SPM_HAND_MODE, value: 5)
        }
        if sender.tag == 2{
            CENTRAL_SYSTEM?.writeBit(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, bit: WIND_MODE, value: 1)
        }
    }
}
