//
//  AlightShowScheduleListViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 3/27/23.
//  Copyright © 2023 WET. All rights reserved.
//

import UIKit

class AlightShowScheduleListViewController: UIViewController,UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var noConnectionView:       UIView!
    @IBOutlet weak var noConnectionErrorLabel: UILabel!
    @IBOutlet weak var dropDown: UIPickerView!
    
    var selectedSch = 1
    var selectedDay = 1
    
    private let logger   = Logger()
    private let httpComm = HTTPComm()
    var list:[String] = []
    var centralSystem:CentralSystem?
    
    override func viewDidLoad(){
        super.viewDidLoad()
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
    
    @objc func checkSystemStat(){
        
        let (_,plcConnection,_,_) = CENTRAL_SYSTEM!.getConnectivityStat()
        
        if plcConnection == CONNECTION_STATE_CONNECTED{

            //Change the connection stat indicator
            self.noConnectionView.alpha = 0
            self.noConnectionView.isUserInteractionEnabled = false
           
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
    
    func readShowFile() {
        httpComm.httpGetResponseFromPath(url: "\(WRITE_LAKE_SHW_CMD)[\(selectedSch),\(selectedDay)]"){ (response) in
            guard response != nil else { return }
            guard let responseArray = response as? [Any] else { return }
            for val in responseArray{
                self.list.append(val as! String)
            }
            if self.list.isEmpty{
                self.dropDown.isHidden = true
            } else {
                self.dropDown.isHidden = false
            }
            self.dropDown.reloadAllComponents()
        }
    }
    
    override func viewWillAppear(_ animated: Bool){
        
        if CENTRAL_SYSTEM == nil{
            
            CENTRAL_SYSTEM = CentralSystem()
            
            //Initialize the central system so we can establish all the system config
            CENTRAL_SYSTEM?.initialize()
            CENTRAL_SYSTEM?.mittlaconnect()
        }
        highlightBtn()
        readShowFile()
        //Add notification observer to get system stat
        NotificationCenter.default.addObserver(self, selector: #selector(ShowScheduleListViewController.checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
        
    }
    
    func highlightBtn(){
        let sun = self.view.viewWithTag(1) as? UIButton
        let mon = self.view.viewWithTag(2) as? UIButton
        let tue = self.view.viewWithTag(3) as? UIButton
        let wed = self.view.viewWithTag(4) as? UIButton
        let thu = self.view.viewWithTag(5) as? UIButton
        let fri = self.view.viewWithTag(6) as? UIButton
        let sat = self.view.viewWithTag(7) as? UIButton
        
        let reg = self.view.viewWithTag(11) as? UIButton
        let sp1 = self.view.viewWithTag(12) as? UIButton
        let sp2 = self.view.viewWithTag(13) as? UIButton
        let sp3 = self.view.viewWithTag(14) as? UIButton
        
        switch selectedDay {
            case 1: sun?.setTitleColor(GREEN_COLOR, for: .normal)
                    mon?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    tue?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    wed?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    thu?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    fri?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    sat?.setTitleColor(DEFAULT_GRAY, for: .normal)
            
            case 2: sun?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    mon?.setTitleColor(GREEN_COLOR, for: .normal)
                    tue?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    wed?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    thu?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    fri?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    sat?.setTitleColor(DEFAULT_GRAY, for: .normal)
            
            case 3: sun?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    mon?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    tue?.setTitleColor(GREEN_COLOR, for: .normal)
                    wed?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    thu?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    fri?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    sat?.setTitleColor(DEFAULT_GRAY, for: .normal)
            
            case 4: sun?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    mon?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    tue?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    wed?.setTitleColor(GREEN_COLOR, for: .normal)
                    thu?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    fri?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    sat?.setTitleColor(DEFAULT_GRAY, for: .normal)
            
            case 5: sun?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    mon?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    tue?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    wed?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    thu?.setTitleColor(GREEN_COLOR, for: .normal)
                    fri?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    sat?.setTitleColor(DEFAULT_GRAY, for: .normal)
            
            case 6: sun?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    mon?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    tue?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    wed?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    thu?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    fri?.setTitleColor(GREEN_COLOR, for: .normal)
                    sat?.setTitleColor(DEFAULT_GRAY, for: .normal)
            
            case 7: sun?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    mon?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    tue?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    wed?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    thu?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    fri?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    sat?.setTitleColor(GREEN_COLOR, for: .normal)
            
        default:
            print("Invalid Tag")
        }
        
        switch selectedSch {
            case 1: reg?.setTitleColor(GREEN_COLOR, for: .normal)
                    sp1?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    sp2?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    sp3?.setTitleColor(DEFAULT_GRAY, for: .normal)
            case 2: reg?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    sp1?.setTitleColor(GREEN_COLOR, for: .normal)
                    sp2?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    sp3?.setTitleColor(DEFAULT_GRAY, for: .normal)
            case 3: reg?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    sp1?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    sp2?.setTitleColor(GREEN_COLOR, for: .normal)
                    sp3?.setTitleColor(DEFAULT_GRAY, for: .normal)
            case 4: reg?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    sp1?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    sp2?.setTitleColor(DEFAULT_GRAY, for: .normal)
                    sp3?.setTitleColor(GREEN_COLOR, for: .normal)
        default:
            print("Invalid Tag")
        }
    }
    override func viewWillDisappear(_ animated: Bool){
        
        //NOTE: We need to remove the notification observer so the PUMP stat check point will stop to avoid extra bandwith usage
        NotificationCenter.default.removeObserver(self)
        self.list.removeAll()
        
    }
    
    @IBAction func listShowSchedule(_ sender: UIButton) {
        
        switch sender.tag {
            case 1...7: selectedDay = sender.tag
            case 11...14: selectedSch = sender.tag - 10
            default:
                print("Invalid Tag")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.50) {
            self.list.removeAll()
            self.readShowFile()
            self.highlightBtn()
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
