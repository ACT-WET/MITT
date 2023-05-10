//
//  LogsViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 1/30/20.
//  Copyright © 2020 WET. All rights reserved.
//

import UIKit

class LogsViewController: UIViewController {
    @IBOutlet weak var scrollview: UIScrollView!
    private let showManager  = ShowManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool){
        self.scrollview.contentSize = CGSize(width: self.scrollview.frame.width, height: 890)
        super.viewWillAppear(true)
        //Add notification observer to get system stat
        NotificationCenter.default.addObserver(self, selector: #selector(checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
    }
    
    @objc func checkSystemStat(){
        let devicelogs = self.showManager.getStatusLogFromServer()
        
        //ShowStoppers
        let estopImg = self.scrollview.viewWithTag(1) as? UIImageView
        let waterLvlImg = self.scrollview.viewWithTag(2) as? UIImageView
        let windImg = self.scrollview.viewWithTag(3) as? UIImageView
        
        devicelogs.showStoppereStop == 1 ? (estopImg?.isHidden = false) : (estopImg?.isHidden = true)
        devicelogs.showStopperwater == 1 ? (waterLvlImg?.isHidden = false) : (waterLvlImg?.isHidden = true)
        devicelogs.showStopperwind == 1 ? (windImg?.isHidden = false) : (windImg?.isHidden = true)
        
        //Lights
    }
     

}
