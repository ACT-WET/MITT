//
//  LightsSelectViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 7/8/21.
//  Copyright © 2021 WET. All rights reserved.
//

import UIKit

class LightsSelectViewController: UIViewController {

    @IBOutlet weak var noConnectionView: UIView!
    @IBOutlet weak var noConnectionErrorLbl: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Add notification observer to get system stat
        NotificationCenter.default.addObserver(self, selector: #selector(checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func checkSystemStat(){
        CENTRAL_SYSTEM?.readBits(plcIpAddress:MITT_LAG_PLC_IP_ADDRESS, length: 5, startingRegister: Int32(LIGHTS_STATUS), completion: { (success, response) in
            
            guard response != nil else{
                return
            }
            let prismaLights = Int(truncating: response![0] as! NSNumber)
            let strobeLights = Int(truncating: response![4] as! NSNumber)
            
            let prismabtn =  self.view.viewWithTag(11) as! UIButton
            let strobebtn   =  self.view.viewWithTag(33) as! UIButton
            
            if prismaLights == 0 {
                prismabtn.setBackgroundImage(#imageLiteral(resourceName: "lights"), for: .normal)
            } else if prismaLights == 1 {
                prismabtn.setBackgroundImage(#imageLiteral(resourceName: "lights_on"), for: .normal)
            }
            
            if strobeLights == 0 {
                strobebtn.setBackgroundImage(#imageLiteral(resourceName: "lights"), for: .normal)
            } else if strobeLights == 1 {
               strobebtn.setBackgroundImage(#imageLiteral(resourceName: "lights_on"), for: .normal)
            }
        })
        
        
    }
    
    @IBAction func redirectToLights(_ sender: UIButton) {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "lights", bundle:nil)
        let lightDetail = storyBoard.instantiateViewController(withIdentifier: "lightSelect") as! LightsViewController
        lightDetail.lightType = sender.tag
        lightDetail.featureId = 4
        if lightDetail.lightType == 11{
            readServerPath = READ_LIGHT_SERVER_PATH
            writeServerPath = WRITE_LIGHT_SERVER_PATH
            screen_Name = "lights"
        } else if lightDetail.lightType == 33{
            readServerPath = READ_LIGHT_SERVER_PATH
            writeServerPath = WRITE_LIGHT_SERVER_PATH
            screen_Name = "lights"
        }
        self.navigationController?.pushViewController(lightDetail, animated: true)
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
