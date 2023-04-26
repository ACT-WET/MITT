//
//  AlightPumpsViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 12/23/22.
//  Copyright © 2022 WET. All rights reserved.
//

import UIKit

class LakePumpsViewController: UIViewController {

    @IBOutlet weak var noConnectionView: UIView!
    @IBOutlet weak var noConnectionErrorLbl: UILabel!
    //MARK: - Class Reference Objects -- Dependencies

    private let logger = Logger()
    private var centralSystem = CentralSystem()
    private let helper = Helper()
    private let httpComm = HTTPComm()
    private var selectedMonth = 0
    private var selectedDay   = 0
    private var selectedHour   = 0
    private var selectedMinute   = 0
    //MARK: - Data Structures

    private var langData = Dictionary<String, String>()
    private var pumpModel:Pump?
    private var is24hours = true
    private var iPadNumber = 0
    private var selectedPumpNumber = 0
    var startDate = 0
    var startMonth = 0
    var endDate = 0
    var endMonth = 0
    var startHour = 0
    var startMinute = 0
    var endHour = 0
    var endMinute = 0
    var drought_enable = 0
    var numOfdays = 0
    //MARK: - View Life Cycle
    override func viewDidLoad(){
        
        super.viewDidLoad()
       
    }

    //MARK: - View Will Appear

    override func viewWillAppear(_ animated: Bool){

        //Configure Pump Screen Text Content Based On Device Language
        configureScreenTextContent()
        centralSystem.getNetworkParameters()
        centralSystem.mittlaconnect()
        CENTRAL_SYSTEM = centralSystem
        //Add notification observer to get system stat
        NotificationCenter.default.addObserver(self, selector: #selector(checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
        
    }

    override func viewWillDisappear(_ animated: Bool){
        
        //NOTE: We need to remove the notification observer so the PUMP stat check point will stop to avoid extra bandwith usage
        NotificationCenter.default.removeObserver(self)
        
    }


    @objc func checkSystemStat(){
        let (_,plcConnection,_,_) = (CENTRAL_SYSTEM?.getConnectivityStat())!
        
        if plcConnection == CONNECTION_STATE_CONNECTED {
            //Change the connection stat indicator
            noConnectionView.alpha = 0
            noConnectionView.isUserInteractionEnabled = false
            getSchdeulerStatus()
            getPumpRunningStat()
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

    func getSchdeulerStatus(){
        
    }
    //MARK: - Configure Screen Text Content Based On Device Language

    private func configureScreenTextContent(){
        
        langData = self.helper.getLanguageSettigns(screenName: PUMPS_LANGUAGE_DATA_PARAM)
        
        guard pumpModel != nil else {
            
            self.logger.logData(data: "PUMPS: PUMP MODEL EMPTY")
            
            //If the pump model is empty, put default parameters to avoid system crash
            self.navigationItem.title = "PUMPS"
            self.noConnectionErrorLbl.text = "CHECK SETTINGS"
            
            return
            
        }
        
        //Get iPad Number Specified On User Side
        
        let ipadNum = UserDefaults.standard.object(forKey: IPAD_NUMBER_USER_DEFAULTS_NAME) as? Int
        
        if ipadNum == nil || ipadNum == 0{
            self.iPadNumber = 1
        }else{
            self.iPadNumber = ipadNum!
        }
        
        self.setDefaultSelectedPumpNumber()
        
        self.navigationItem.title = langData[pumpModel!.screenName!]!
        self.noConnectionErrorLbl.text = pumpModel!.outOfRangeMessage!
        
    }

    //MARK: - By Default Set the current selected pump to 0
    func getPumpRunningStat(){
        
        let offset = 14
        let tagNum = 201
        
        for index in 0..<6 {
            CENTRAL_SYSTEM?.readBits(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, length: 1, startingRegister: Int32(ALIGHTPUMPS_RUNNING_STATUS_START_REGISTER + (index*offset)), completion:{ (success, response) in
                if response != nil{
                    let runStat = Int(truncating: response![0] as! NSNumber)
                
                    CENTRAL_SYSTEM?.readBits(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, length: 1, startingRegister: Int32(ALIGHTPUMPS_FAULT_STATUS_START_REGISTER + (index*offset)), completion:{ (success, response) in
                        if response != nil{
                        let faultStat = Int(truncating: response![0] as! NSNumber)
                       
                        self.parsePumpStatus(tag: tagNum + index, faultStatus: faultStat, runStatus: runStat)
                        }
                    })
                }
            })
        }
    }

    func parsePumpStatus(tag: Int, faultStatus: Int, runStatus: Int) {
            let tempBtn = self.view.viewWithTag(tag) as! UIButton
            let tempLbl = self.view.viewWithTag(tag+10) as! UILabel
            if faultStatus == 1{
                tempLbl.textColor = RED_COLOR
            } else {
                tempLbl.textColor = DEFAULT_GRAY
            }
            if runStatus == 1 {
                tempBtn.setBackgroundImage(#imageLiteral(resourceName: "pumps_on"), for: .normal)
            } else {
                tempBtn.setBackgroundImage(#imageLiteral(resourceName: "pumps"), for: .normal)
            }
    }
    private func setDefaultSelectedPumpNumber(){
        
        let registersSET1 = PUMP_SETS[iPadNumber-1]
        let iPadNumberRegister = registersSET1[0]
        CENTRAL_SYSTEM!.writeRegister(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, register: iPadNumberRegister.register, value: 0)
        
        
    }

    @IBAction func redirectToPumpDetails(_ sender: UIButton) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "pumps", bundle:nil)
        let prjDetail = storyBoard.instantiateViewController(withIdentifier: "pumpDetail") as! AutoPumpDetailViewController
        prjDetail.pumpNumber = sender.tag
        prjDetail.featureId = 1
        self.navigationController?.pushViewController(prjDetail, animated: true)
    }

    @IBAction func redirectToPumpScheduler(_ sender: UIButton) {
        let schedulerShowVC = UIStoryboard.init(name: "pumps", bundle: nil).instantiateViewController(withIdentifier: "pumpAlightSchedulerViewController") as! LakePumpsSchedulerViewController
        schedulerShowVC.schedulerTag = sender.tag
        screen_Name = "pumps"
        navigationController?.pushViewController(schedulerShowVC, animated: true)
        
    }

    @IBAction func settingsButtonPressed(_ sender: UIButton) {
       self.addAlertAction(button: sender)
    }
    }
