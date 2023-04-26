//
//  FillerShowsAlightViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 1/10/23.
//  Copyright © 2023 WET. All rights reserved.
//

import UIKit

class FillerShowsLakeViewController: UIViewController,UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{
    
    @IBOutlet weak var pumpIconButton: UIButton!
    @IBOutlet weak var noConnectionView:       UIView!
    @IBOutlet weak var schedulerContainerView: UIView!
    @IBOutlet weak var noConnectionErrorLabel: UILabel!
    @IBOutlet weak var fillerShowNumberTxt: UITextField!
    @IBOutlet weak var fillerShowEnabledDisbaledLbl: UILabel!
    @IBOutlet weak var dropDown: UIPickerView!
   
    let FILLER_SHOW_STATUS_WRITE_REGISTER        = 5502
    let PERCIPITATION_TIME_DELAY                 = 6004
    let PERCIPITATION_SP                         = 6000
    let PERCIPITATION_LIVE                       = 6002
    
    private var shows: [Any]? = nil
    private var fillerShowStatus: Int = 0
    var currentFillerShowState  = 0
    var currentFillerShowNumber = 0
    var specialShowNumber       = 0
    var showNumberRead          = 0
    private let logger   = Logger()
    private let httpComm = HTTPComm()
    var list:[String] = []
    var speciallist:[String] = []
    var centralSystem:CentralSystem?
    var editingBegan = false
    
    /***************************************************************************
     * Function :  viewDidLoad
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    override func viewDidLoad(){
        
        super.viewDidLoad()
        self.readFillerShowState()
        readFillerShowOnOff()
    }
    
    /***************************************************************************
     * Function :  didReceiveMemoryWarning
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    override func didReceiveMemoryWarning(){
        
        super.didReceiveMemoryWarning()
        
    }
    func readShowFile() {
        
        let defaults = UserDefaults.standard
        
        if defaults.object(forKey: "lakeshows") != nil {
            
            if let object = defaults.object(forKey: "lakeshows") as? [Any] {
                shows = object
            }
            for show in self.shows!{
                
                let dictionary  = show as! NSDictionary
                let test       = dictionary.object(forKey: "test") as? Int
                let name        = dictionary.object(forKey: "name") as? String
                let number      = dictionary.object(forKey: "number") as? Int
                let duration      = dictionary.object(forKey: "duration") as? Int
                
                if number != 0 {
                    if duration != 0 {
                        if test != nil {
                            if test != 1 {
                                if !list.contains(name!){
                                    self.list.append(name!)
                                }
                            }
                        } else {
                            if !list.contains(name!){
                                self.list.append(name!)
                            }
                        }
                    }
                }
            }
            print(list)
            dropDown.reloadAllComponents()
            print(list.count)
        }
        
        
    }
    
    
    /***************************************************************************
     * Function :  viewWillAppear
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    override func viewWillAppear(_ animated: Bool){
        
        if CENTRAL_SYSTEM == nil{
            
            CENTRAL_SYSTEM = CentralSystem()
            
            //Initialize the central system so we can establish all the system config
            CENTRAL_SYSTEM?.initialize()
            CENTRAL_SYSTEM?.mittlaconnect()
            
        }
        readShowFile()
        //Add notification observer to get system stat
        NotificationCenter.default.addObserver(self, selector: #selector(FillerShowsLakeViewController.checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
        
    }
    
    /***************************************************************************
     * Function :  viewWillDisappear
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    override func viewWillDisappear(_ animated: Bool){
        
        //NOTE: We need to remove the notification observer so the PUMP stat check point will stop to avoid extra bandwith usage
        NotificationCenter.default.removeObserver(self)
        self.list.removeAll()
        self.speciallist.removeAll()
        
    }
    
    /***************************************************************************
     * Function :  checkSystemStat
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    @objc func checkSystemStat(){
        
        let (_,plcConnection,_,_) = CENTRAL_SYSTEM!.getConnectivityStat()
        
        if plcConnection == CONNECTION_STATE_CONNECTED{

            //Change the connection stat indicator
            self.noConnectionView.alpha = 0
            self.noConnectionView.isUserInteractionEnabled = false
            readFillerShowOnOff()
            self.readFillerShowState()
           
        } else {
            noConnectionView.alpha = 1
            if plcConnection == CONNECTION_STATE_FAILED {
                noConnectionErrorLabel.text = "PLC CONNECTION FAILED, SERVER GOOD"
            } else if plcConnection == CONNECTION_STATE_CONNECTING {
                noConnectionErrorLabel.text = "CONNECTING TO PLC, SERVER CONNECTED"
            } else if plcConnection == CONNECTION_STATE_POOR_CONNECTION {
                noConnectionErrorLabel.text = "PLC POOR CONNECTION, SERVER CONNECTED"
            }
        }
    }
    
    func readFillerShowOnOff(){
        CENTRAL_SYSTEM?.readBits(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, length: 1, startingRegister: Int32(FILLER_SHOW_STATUS_WRITE_REGISTER), completion: { (success, response) in
            guard success == true else { return }
            let status       = Int(truncating: response![0] as! NSNumber)
            self.fillerShowStatus = status
            if self.fillerShowStatus == 1 {
                self.pumpIconButton.setImage(UIImage.init(named: "fillerShowOn"), for: .normal)
            } else {
                 self.pumpIconButton.setImage(UIImage.init(named: "fillerShow"), for: .normal)
            }
        })
    }
    
    /***************************************************************************
     * Function :  enableDisableFillerShows
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    @IBAction func enableDisableFillerShows(_ sender: Any){
        
        var setState = 0
        
        if(currentFillerShowState == 1){
            setState = 0
        }else if(currentFillerShowState == 0){
            setState = 1
        }
        
        let sendData = [
            "FillerShow_Enable" : setState,
            "FillerShow_Number" : currentFillerShowNumber
        ]
        
        let jsonData: Data? = try? JSONSerialization.data(withJSONObject: sendData, options: .prettyPrinted)
        var jsonString: String? = nil
        
        if let aData = jsonData{
            jsonString = String(data: aData, encoding: .utf8)
        }
        
        let escapedString = jsonString!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let strURL = "\(SET_LAKE_FILLER_SHOW_STATE_HTTP_PATH)?\(String(describing: escapedString))"
        
        self.httpComm.httpGetResponseFromPath(url: strURL) { (response) in
            
        }

    }
    
    /***************************************************************************
     * Function :  enableDisableFillerShows
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    private func readFillerShowState(){
        
        httpComm.httpGetResponseFromPath(url: GET_LAKE_FILLER_SHOW_STATE_HTTP_PATH) { (response) in
            
            let dictionary  = response as! NSDictionary
            let enabledDisabled    = dictionary.object(forKey: "FillerShow_Enable") as? Int
            let fillerShowNumber   = dictionary.object(forKey: "FillerShow_Number") as? Int
            
           
            
            if fillerShowNumber != nil && self.showNumberRead == 0 {
                self.fillerShowNumberTxt.text = "\(fillerShowNumber!)"
                self.currentFillerShowNumber  = fillerShowNumber!
                self.showNumberRead = 1
                
            }

            self.currentFillerShowState = enabledDisabled!
            
            if(enabledDisabled == 0){
                
                self.fillerShowEnabledDisbaledLbl.text = "FILLER SHOW DISABLED"
                
            }else{
                
                self.fillerShowEnabledDisbaledLbl.text = "FILLER SHOW ENABLED"
                
            }
        }
    }
    
    /***************************************************************************
     * Function :  setFillerShowNumber
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    @IBAction func setFillerShowNumber(_ sender: Any){
       writeToServer()
    }
    
    
    func writeToServer(){
        let showNumber = Int(self.fillerShowNumberTxt.text!)
        
        guard showNumber != nil else{
            return
        }
        
        self.currentFillerShowNumber = showNumber!
        let sendData = [
            "FillerShow_Enable" : currentFillerShowState,
            "FillerShow_Number" : showNumber!
        ]
        
        let jsonData: Data? = try? JSONSerialization.data(withJSONObject: sendData, options: .prettyPrinted)
        var jsonString: String? = nil
        
        if let aData = jsonData{
            jsonString = String(data: aData, encoding: .utf8)
        }
        
        let escapedString = jsonString!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let strURL = "\(SET_LAKE_FILLER_SHOW_STATE_HTTP_PATH)?\(String(describing: escapedString))"
        
        self.httpComm.httpGetResponseFromPath(url: strURL) { (response) in
            
        }
    }
    /***************************************************************************
     * Function :  Text Field Delegate Handler
     * Input    :  none
     * Output   :  none
     * Comment  :  When user touches anywhere on the screen, text field resignes
     *             from being first responder and keyboard disappears
     ***************************************************************************/
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        
        self.fillerShowNumberTxt.resignFirstResponder()
    }
    
    @IBAction func settingsbtnPressed(_ sender: UIButton) {
        self.addAlertAction(button: sender)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if fillerShowNumberTxt.isEditing {
            self.dropDown.isHidden = false
            self.fillerShowNumberTxt.endEditing(true)
            if list.count == 0{
                self.view.endEditing(true)
                let alert = UIAlertController(title: "FillerShow", message: "FILLER SHOW NOT SET", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                self.dropDown.isHidden = true
                self.fillerShowNumberTxt.text = "0"
                return
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return list.count
    }
   
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        self.view.endEditing(true)
        return list[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
   
            let showName = self.list[row]
            let defaults = UserDefaults.standard
        
            if defaults.object(forKey: "alshows") != nil {
                
                if let object = defaults.object(forKey: "alshows") as? [Any] {
                    shows = object
                }
            }
             for show in self.shows!{
                let dictionary  = show as! NSDictionary
                let number      = dictionary.object(forKey: "number") as! Int
                
                let selectedShow = dictionary.object(forKey: "name") as? String
                if selectedShow == showName {
                    self.fillerShowNumberTxt.text = "\(number)"
                }
            }
        self.dropDown.isHidden = true
        writeToServer()
    }
    
    
}
