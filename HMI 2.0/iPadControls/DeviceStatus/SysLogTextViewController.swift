//
//  SysLogTextViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 2/27/20.
//  Copyright © 2020 WET. All rights reserved.
//

import UIKit

class SysLogTextViewController: UIViewController {
    
    @IBOutlet weak var logData: UITextView!
    
    @IBOutlet weak var clearLogBtn: UIButton!
    private var httpComm = HTTPComm()
    var logCount = 0
    var tempCount = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool){
        readSysLog()
        super.viewWillAppear(true)
        //Add notification observer to get system stat
        NotificationCenter.default.addObserver(self, selector: #selector(readSysLog), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
    }
    
    @objc func readSysLog(){
        
        self.httpComm.httpGetResponseFromPath(url: SYS_STATUS_LOGPATH){ (response) in
        
            guard response != nil else { return }
            
            //Split the response of type String by character
            let responseString = response as? String
            let stringofArr = responseString?.components(separatedBy: "\n")
            
            //Count the number of logs read from the endpoint
            self.logCount = stringofArr!.count
            
            //check if you're only appending newest logs
            //print in the order of most recent
            //convert each string to Dictionary objects
            //based of date and data key append their values to 2 sub strings
            //Insert the logs into textView
            
            if self.logCount != self.tempCount {
                self.logData.text = ""
                for word in stringofArr!.reversed(){
                    if !word.isEmpty{
                        guard let data = self.convertToDictionary(text: word) else { return }
                        let logdata = data.value(forKey: "data") as! String
                        let timestamp = data.value(forKey: "date") as! String
                            self.logData.insertText(timestamp + "       ---->       " + logdata)
                            self.logData.insertText("\n")
                    }
                }
                self.tempCount = self.logCount
            }
        }
    }
    
    func convertToDictionary(text: String) -> NSDictionary? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] as NSDictionary?
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    @IBAction func clearLogBtnPushed(_ sender: UIButton) {
       self.clearLogBtn.isEnabled = false
       self.httpComm.httpGetResponseFromPath(url: SYS_CLEAR_LOGPATH){ (response) in
            if response != nil {
                self.clearLogBtn.isEnabled = true
                self.tempCount = 0
                self.logData.text = ""
                self.readSysLog()
                print("success")
            }
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
