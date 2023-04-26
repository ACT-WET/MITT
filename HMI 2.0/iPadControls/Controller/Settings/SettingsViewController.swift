//
//  SettingsViewController.swift
//  iPadControls
//
//  Created by Jan Manalo on 1/08/19.
//  Copyright © 2019 WET. All rights reserved.
//

import UIKit
import NMSSH

class SettingsViewController: UIViewController{
    
    @IBOutlet weak var ipad1button:          UIButton!
    @IBOutlet weak var ipad2button:          UIButton!
    @IBOutlet weak var viewForWebView:       UIView!
    @IBOutlet weak var ipadDesignatedAs:     UILabel!
    @IBOutlet weak var ipadDateLbl:          UILabel!
    @IBOutlet weak var syncTimeStateLbl:     UILabel!
    @IBOutlet weak var rebootMsg: UILabel!
    @IBOutlet weak var warningbtn: UIButton!
    @IBOutlet weak var faultBtn: UIButton!
    @IBOutlet weak var resetBtn: UIButton!
    
    let helper      = Helper()
    var langData    = Dictionary<String, String>()
    var httpManager = HTTPComm()
    var centralsys  = CentralSystem()
    var session: NMSSHSession!
    var cameraViewLoaded = false
    
    /***************************************************************************
     * Function :  viewDidLoad
     * Input    :  none
     * Output   :  none
     * Comment  :  This function gets executed only when controller resources
     *             get loaded
     ***************************************************************************/
    
    override func viewDidLoad(){
        
        super.viewDidLoad()
        self.configureScreenTextContent()

        
    }
    
    /***************************************************************************
     * Function :  viewDidAppear
     * Input    :  none
     * Output   :  none
     * Comment  :  This function gets executed every time view appears
     ***************************************************************************/
    
    override func viewWillAppear(_ animated: Bool){
        
        
        //Get Current iPad Number That Was Previously Selected
        getCurrentIpadNumber()
        
        //Add notification observer to get system stat
        NotificationCenter.default.addObserver(self, selector: #selector(checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
        
    }
    
    
    /***************************************************************************
     * Function :  checkSystemStat
     * Input    :  none
     * Output   :  none
     * Comment  :  Checks the network connection for all system components
     ***************************************************************************/
    
    @objc func checkSystemStat(){
      getDateTime()
    }
    
    /***************************************************************************
     * Function :  viewWillDisappear
     * Input    :  none
     * Output   :  none
     * Comment  :  This function gets executed every time view disappears
     ***************************************************************************/
    
    override func viewWillDisappear(_ animated: Bool){
        NotificationCenter.default.removeObserver(self)
        
        ipad1button          = nil
        ipad2button          = nil
        viewForWebView       = nil
        ipadDesignatedAs     = nil
        langData.removeAll(keepingCapacity: false)
        
    }
    
    /***************************************************************************
     * Function :  chooseNumber1
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    @IBAction func chooseNumber1(sender: AnyObject){
        
        self.highlighIpadNumber(button: ipad1button, number: 1)
        self.dehilightIpadNumber(button: ipad2button)
        
    }
    
    /***************************************************************************
     * Function :  chooseNumber2
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    @IBAction func chooseNumber2(sender: AnyObject){
        
        self.highlighIpadNumber(button: ipad2button, number: 2)
        self.dehilightIpadNumber(button: ipad1button)
        
    }
    
    /***************************************************************************
     * Function :  highlighIpadNumber
     * Input    :  none
     * Output   :  none
     * Comment  :  Helper Function To Highlight The Selected iPad Button and
     *             Change the Selected Device Number In The Device non volatile
     *             memeory
     ***************************************************************************/
    
    private func highlighIpadNumber(button:UIButton, number:Int){
        
        button.layer.cornerRadius = 60
        button.layer.borderWidth  = 3.0
        button.layer.borderColor  = HELP_SCREEN_GRAY.cgColor
        
        //We want to save the highlighted iPad number to iPad's Defaults Storage
        UserDefaults.standard.set(number, forKey: IPAD_NUMBER_USER_DEFAULTS_NAME)
        
    }
    
    /***************************************************************************
     * Function :  dehilightIpadNumber
     * Input    :  targeted UI button
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    private func dehilightIpadNumber(button:UIButton){
        
        button.layer.borderWidth = 0.0
        
    }
    
    /***************************************************************************
     * Function :  configureScreenTextContent
     * Input    :  none
     * Output   :  none
     * Comment  :  Configure Screen Text Content Based On Device Language
     ***************************************************************************/
    
    private func configureScreenTextContent(){
        
        langData = self.helper.getLanguageSettigns(screenName: "help")
        ipadDesignatedAs.text = langData["THIS IPAD IS DESIGNATED AS"]!
        ipad1button.setTitle(langData["iPad 1"]!, for: .normal)
        ipad2button.setTitle(langData["iPad 2"]!, for: .normal)
        self.navigationItem.title = "SETTINGS"
        
    }
    
    /***************************************************************************
     * Function :  getCurrentIpadNumber
     * Input    :  none
     * Output   :  none
     * Comment  :  Get The Current iPad Number
     ***************************************************************************/
    
    private func getCurrentIpadNumber(){
        
        var iPadNumber = UserDefaults.standard.object(forKey: IPAD_NUMBER_USER_DEFAULTS_NAME) as? Int
        
        //We wnat to make sure the iPad number parameter exists in the local defaults storage
        
        if iPadNumber == nil {
            iPadNumber = 1
        }
        
        if iPadNumber == 1{
            
            self.highlighIpadNumber(button: ipad1button, number: 1)
            self.dehilightIpadNumber(button: ipad2button)
            
        }else{
            
            self.highlighIpadNumber(button: ipad2button, number: 2)
            self.dehilightIpadNumber(button: ipad1button)
            
        }
        
    }
    
    
    /***************************************************************************
     * Function :  syncServerTimer
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    @IBAction func syncServerTimer(_ sender: Any){
      syncTimeToServer()

        
        self.httpManager.httpGetResponseFromPath(url:RESET_TIME_LAST_COMMAND){ (response) in
            
            print("SUCCESSS : \(String(describing: response))")
            
        }
        centralsys.reinitialize()
    }
    
    private func syncTimeToPLC() {
    }
    
    
    func syncTimeToServer(){
    
     self.syncTimeStateLbl.text = "SYNCING SERVER TIME..."
           self.syncTimeStateLbl.textColor = DEFAULT_GRAY
           
           //On the background global thread, execute the sync time process
           DispatchQueue.global(qos: .background).async{
               
               self.session = NMSSHSession.connect(toHost: "\(SERVER_IP_ADDRESS):22", withUsername: "root")
            
               if self.session.isConnected{
                   
                   self.session.authenticate(byPassword: "A3139gg1121")
                   
                   if self.session.isAuthorized{
                       
                       
                       let currentDate          = NSDate()
                       let dateFormatter        = DateFormatter()
                       dateFormatter.dateFormat = "dd MMM YYYY HH:mm:ss"
                       let localDateTimeString  = dateFormatter.string(from: currentDate as Date)
                       
                       
                       self.session.channel.execute("date --set \"\(localDateTimeString)\"", error: nil)
                     //self.session.channel.execute("exit", error: nil)
                       self.self.session.disconnect()
                       
                       
                       //Check if SSH Session is established. If it is, disconnect.
                       
                       if self.session.isConnected{
                           self.session.disconnect()
                       }
                       
                       DispatchQueue.main.async{
                           
                           self.syncTimeStateLbl.text = "SERVER TIME SYNCED"
                           self.syncTimeStateLbl.textColor = GREEN_COLOR
                           
                       }
                   }
               }
           }
       }
    
    /***************************************************************************
     * Function :  setTimeSyncFailure
     * Input    :  none
     * Output   :  none
     * Comment  :  Shows time sync failure indicator and stops the timer
     *
     *
     *
     ***************************************************************************/
    
    private func setTimeSyncFailure(){
        syncTimeStateLbl.isHidden = false
        syncTimeStateLbl.text = "SERVER TIME SYNCHED FAILED"
        syncTimeStateLbl.textColor = RED_COLOR
        
    }
    
    
    /***************************************************************************
     * Function :  getDateTime
     * Input    :  none
     * Output   :  none
     * Comment  :  Gets the system date and time and formats it to our desired
     *             timestamp
     ***************************************************************************/
    
    @objc func getDateTime(){
        
        ipadDateLbl.text = SERVER_TIME
        
    }
    
    @IBAction func serverReset(_ sender: UIButton) {
        self.rebootMsg.text = "REBOOTING SERVER IN 15 SEC"
        CENTRAL_SYSTEM?.writeBit(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, bit: SERVER_REBOOT_BIT, value: 1)
        self.resetBtn.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 15.0) {
            self.rebootMsg.text = "REBOOT SUCCESS"
            CENTRAL_SYSTEM?.writeBit(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, bit: SERVER_REBOOT_BIT, value: 0)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.rebootMsg.text = ""
                self.resetBtn.isUserInteractionEnabled = true
            }
        }
        
    }
    
    @IBAction func faultResetBtnPushed(_ sender: Any) {
        
        CENTRAL_SYSTEM?.writeBit(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, bit: FAULT_RESET_REGISTER, value: 1)
        self.faultBtn.isUserInteractionEnabled = false
        self.faultBtn.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute:{
            CENTRAL_SYSTEM?.writeBit(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, bit: FAULT_RESET_REGISTER, value: 0)
            self.faultBtn.isUserInteractionEnabled = true
            self.faultBtn.isEnabled = true
        })
    }
    
    @IBAction func warningResetBtnPushed(_ sender: Any) {
        CENTRAL_SYSTEM?.writeBit(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, bit: WARNING_RESET_REGISTER, value: 1)
        self.warningbtn.isUserInteractionEnabled = false
        self.warningbtn.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute:{
            CENTRAL_SYSTEM?.writeBit(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, bit: WARNING_RESET_REGISTER, value: 0)
            self.warningbtn.isUserInteractionEnabled = true
            self.warningbtn.isEnabled = true
        })
    }
}

