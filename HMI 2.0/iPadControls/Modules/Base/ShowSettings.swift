//
//  ShowSettings.swift
//  iPadControls
//
//  Created by Jan Manalo on 6/14/18.
//  Copyright © 2018 WET. All rights reserved.
//

import UIKit

var settingsIcon: UIButton?

extension UIViewController {

    func addAlertAction(button: UIButton){
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressHappened))
        recognizer.minimumPressDuration = 1
        button.addGestureRecognizer(recognizer)
    }
    
    func addServerAlert(switch: UISwitch){
        let alertController = UIAlertController(title: "WARNING", message: "About to Switch Server Control. Press OK to Confirm", preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
            print("User Cancel")
        }
        let confirm = UIAlertAction(title: "OK", style: .default) { (alert) in
            CENTRAL_SYSTEM?.readBits(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, length: 1, startingRegister: Int32(SELECT_SERVER_BIT), completion: { (success, response) in
                
                guard success == true else { return }
                
                let status = Int(truncating: response![0] as! NSNumber)
                
                if status == 1{
                    CENTRAL_SYSTEM?.writeBit(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, bit: SELECT_SERVER_BIT, value: 0)
                } else {
                    CENTRAL_SYSTEM?.writeBit(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, bit: SELECT_SERVER_BIT, value: 1)
                }
            })
        }
        
        alertController.addAction(confirm)
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func addFireAlert(startregister:Int){
        let alertController = UIAlertController(title: "WARNING", message: "About to Trigger Fire Command. Press OK to Confirm", preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
            print("User Cancel")
        }
        let confirm = UIAlertAction(title: "OK", style: .default) { (alert) in
            CENTRAL_SYSTEM?.readBits(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, length: 1, startingRegister: Int32(startregister), completion: { (success, response) in
                
                guard success == true else { return }
                
                let status = Int(truncating: response![0] as! NSNumber)
                
                if status == 0{
                    CENTRAL_SYSTEM?.writeBit(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS,bit: startregister, value: 1)
                } 
            })
        }
        
        alertController.addAction(confirm)
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func longPressHappened(){
        var passwordField: UITextField?
        
        let alertController = UIAlertController(title: "Password", message: "Enter a password", preferredStyle: .alert)
        alertController.view.backgroundColor = .black
        alertController.addTextField { (textfield) in
            passwordField = textfield
            textfield.isSecureTextEntry = true
        }
        
        let login = UIAlertAction(title: "Login", style: .default) { (alert) in
            
            settingsIcon = self.view.viewWithTag(SETTINGS_ICON_TAG) as? UIButton
            
            guard settingsIcon != nil else{ return }
            
            if (passwordField?.text?.count)! > 0 {
                if let password = passwordField?.text {
                    if password == APP_PASSWORD {
                        if settingsIcon!.alpha == 1{
                            
                            settingsIcon!.alpha = 0
                            settingsIcon!.isUserInteractionEnabled = false
                            
                        }else{
                            
                            settingsIcon!.alpha = 1
                            settingsIcon!.isUserInteractionEnabled = true
                            
                        }
                    }else{
                        let wrongPasswordAlert = UIAlertController(title: "Wrong Password", message: "Please try again.", preferredStyle: .alert)
                        
                        let dismissAlert = UIAlertAction(title: "Okay", style: .cancel, handler: { (action) in
                            print("User dismiss")
                        })
                        
                        wrongPasswordAlert.addAction(dismissAlert)
                        self.present(wrongPasswordAlert, animated: true, completion: nil)
                    }
                }
                
            }else{
                return
            }
            
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
            print("User Cancel")
        }
        
        alertController.addAction(login)
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
    }
}
