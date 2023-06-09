//
//  LakeLightsSelectViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 6/7/23.
//  Copyright © 2023 WET. All rights reserved.
//

import UIKit

class LakeLightsSelectViewController: UIViewController {

    @IBOutlet weak var noConnectionView: UIView!
    @IBOutlet weak var noConnectionLbl: UILabel!
    
    private var centralSystem = CentralSystem()
    private let helper = Helper()
    private let httpComm = HTTPComm()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
  
    override func viewWillAppear(_ animated: Bool){

        //Configure Pump Screen Text Content Based On Device Language
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
            getLightsStat()
        } else {
            noConnectionView.alpha = 1
            if plcConnection == CONNECTION_STATE_FAILED {
                noConnectionLbl.text = "PLC CONNECTION FAILED, SERVER GOOD"
            } else if plcConnection == CONNECTION_STATE_CONNECTING {
                noConnectionLbl.text = "CONNECTING TO PLC, SERVER CONNECTED"
            } else if plcConnection == CONNECTION_STATE_POOR_CONNECTION {
                noConnectionLbl.text = "PLC POOR CONNECTION, SERVER CONNECTED"
            }
        }
    }
    //MARK: - By Default Set the current selected pump to 0
    func getLightsStat(){
        CENTRAL_SYSTEM?.readBits(plcIpAddress: MITT_LA_PLC_IP_ADDRESS, length: 6, startingRegister: Int32(LAKE_LIGHTS_STATUS), completion:{ (success, response) in
            if response != nil{
                let featureLights = Int(truncating: response![0] as! NSNumber)
                let poolLights = Int(truncating: response![5] as! NSNumber)
                
                let feature = self.view.viewWithTag(11) as? UIButton
                let pool = self.view.viewWithTag(12) as? UIButton
                
                if featureLights == 1{
                    feature?.setBackgroundImage(#imageLiteral(resourceName: "lights_on"), for: .normal)
                } else {
                    feature?.setBackgroundImage(#imageLiteral(resourceName: "lights"), for: .normal)
                }
                
                if poolLights == 1{
                    pool?.setBackgroundImage(#imageLiteral(resourceName: "lights_on"), for: .normal)
                } else {
                    pool?.setBackgroundImage(#imageLiteral(resourceName: "lights"), for: .normal)
                }
            }
        })
    }

    @IBAction func redirectToLightsDetails(_ sender: UIButton) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "lights", bundle:nil)
        let prjDetail = storyBoard.instantiateViewController(withIdentifier: "lakelights") as! LakeLightsViewController
        prjDetail.lightType = sender.tag
        prjDetail.featureId = 2
        self.navigationController?.pushViewController(prjDetail, animated: true)
    }

}
