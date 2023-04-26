//
//  SystemFaultViewController.swift
//  iPadControls
//
//  Created by Jan Manalo on 12/13/18.
//  Copyright © 2018 WET. All rights reserved.
//

import UIKit

class SystemFaultViewController: UIViewController {

    @IBOutlet weak var nameOfFaultLabel: UILabel!
    var faultIndex: [Int]?
    var strainerFaultIndex: [Int]?
    var glfaultIndex: [Int]?
    var glstrainerFaultIndex: [Int]?
    var alfaultIndex: [Int]?
    var alstrainerFaultIndex: [Int]?
    var defaultIndex: [Int]?
    var destrainerFaultIndex: [Int]?
    var faultTag = 0
    var faultLabel = UILabel()
    var strainerLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if faultTag == 200 || faultTag == 201 || faultTag == 202 || faultTag == 203{
            nameOfFaultLabel.text = "NETWORK FAULT"
            nameOfFaultLabel.textAlignment = .center
            readNetworkFaults()
        }
        if faultTag == 100 || faultTag == 101 || faultTag == 102 || faultTag == 103{
            nameOfFaultLabel.text = "CLEAN STRAINER"
            nameOfFaultLabel.textAlignment = .center
            readStarinerFaults()
        }
         NotificationCenter.default.addObserver(self, selector: #selector(checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
    }
    override func viewWillDisappear(_ animated: Bool){
        //NOTE: We need to remove the notification observer so the PUMP stat check point will stop to avoid extra bandwith usage
        NotificationCenter.default.removeObserver(self)
        faultLabel.removeFromSuperview()
        strainerLabel.removeFromSuperview()
        faultIndex?.removeAll()
        glfaultIndex?.removeAll()
        alfaultIndex?.removeAll()
        defaultIndex?.removeAll()
        strainerFaultIndex?.removeAll()
        alstrainerFaultIndex?.removeAll()
        destrainerFaultIndex?.removeAll()
        glstrainerFaultIndex?.removeAll()
        
    }
    @objc func checkSystemStat(){
        if faultTag == 200 || faultTag == 201 || faultTag == 202 || faultTag == 203{
            readNetworkFaults()
        }
        if faultTag == 100 || faultTag == 101 || faultTag == 102 || faultTag == 103{
            readStarinerFaults()
        }
    }
    
    private func readNetworkFaults() {
        let offset = 30
        if faultTag == 200 {
           for (index,value) in faultIndex!.enumerated() {
                
                switch index {
                case 0...6:
                    customizeFaultLabel(x: 62, y: (95 + (index * offset)), index: value)
                default:
                    print("Wrong index")
                }
                
            }
        }
        if faultTag == 201 {
            for (index,value) in glfaultIndex!.enumerated() {
                
                switch index {
                case 0...4:
                    customizeglFaultLabel(x: 62, y: (95 + (index * offset)), index: value)
                default:
                    print("Wrong index")
                }
                
            }
        }
        if faultTag == 202 {
            for (index,value) in alfaultIndex!.enumerated() {
                
                switch index {
                case 0...10:
                    customizealFaultLabel(x: 62, y: (95 + (index * offset)), index: value)
                default:
                    print("Wrong index")
                }
                
            }
        }
        if faultTag == 203 {
            for (index,value) in defaultIndex!.enumerated() {
                
                switch index {
                case 0...3:
                    customizedeFaultLabel(x: 62, y: (95 + (index * offset)), index: value)
                default:
                    print("Wrong index")
                }
                
            }
        }
        
    }
    
    private func readStarinerFaults() {
        let offset = 30
        if faultTag == 100 {
           for (index,value) in strainerFaultIndex!.enumerated() {
               switch index {
                   case 0...6:
                       customizeStrainerFaultLabel(x: 25, y: (95 + (index * offset)), index: value)
                   default:
                       print("Wrong index")
                   }
           }
        }
        if faultTag == 101 {
           for (index,value) in glstrainerFaultIndex!.enumerated() {
               switch index {
                   case 0...3:
                       customizeglStrainerFaultLabel(x: 25, y: (95 + (index * offset)), index: value)
                   default:
                       print("Wrong index")
                   }
           }
        }
        if faultTag == 102 {
           for (index,value) in alstrainerFaultIndex!.enumerated() {
               switch index {
                   case 0...6:
                       customizealStrainerFaultLabel(x: 25, y: (95 + (index * offset)), index: value)
                   default:
                       print("Wrong index")
                   }
           }
        }
        if faultTag == 103 {
           for (index,value) in destrainerFaultIndex!.enumerated() {
               switch index {
                   case 0...2:
                       customizedeStrainerFaultLabel(x: 25, y: (95 + (index * offset)), index: value)
                   default:
                       print("Wrong index")
                   }
           }
        }
    }
    
    private func customizeFaultLabel(x: Int, y: Int, index: Int) {
        faultLabel = UILabel(frame: CGRect(x: x, y: y, width: 100, height: 20))
        faultLabel.textAlignment = .center
        faultLabel.textColor = RED_COLOR
        switch index {
            case 0:   faultLabel.text = "VFD-9101"
            case 1:   faultLabel.text = "VFD-9201"
            case 2:   faultLabel.text = "VFD-9202"
            case 3:   faultLabel.text = "VFD-9203"
            case 4:   faultLabel.text = "VFD-9204"
            case 5:   faultLabel.text = "VFD-9205"
            case 6:   faultLabel.text = "VFD-9206"
            default:
                print("Wrong index")
        }
        self.view.addSubview(faultLabel)
    }
    
    private func customizeStrainerFaultLabel(x: Int, y: Int, index: Int) {
        if y > 505 {
           strainerLabel = UILabel(frame: CGRect(x: 200, y: y - 420, width: 150, height: 20))
        } else {
           strainerLabel = UILabel(frame: CGRect(x: x, y: y, width: 150, height: 20))
        }
        
        strainerLabel.textAlignment = .center
        strainerLabel.textColor = RED_COLOR
        switch index {
               case 0:   strainerLabel.text = "VFD-9101"
               case 1:   strainerLabel.text = "VFD-9201"
               case 2:   strainerLabel.text = "VFD-9202"
               case 3:   strainerLabel.text = "VFD-9203"
               case 4:   strainerLabel.text = "VFD-9204"
               case 5:   strainerLabel.text = "VFD-9205"
               case 6:   strainerLabel.text = "VFD-9206"
            
        default:
            print("Wrong index")
        }
       
        self.view.addSubview(strainerLabel)
    }
    
    private func customizeglFaultLabel(x: Int, y: Int, index: Int) {
        faultLabel = UILabel(frame: CGRect(x: x, y: y, width: 100, height: 20))
        faultLabel.textAlignment = .center
        faultLabel.textColor = RED_COLOR
        switch index {
            case 0:   faultLabel.text = "VFD-501"
            case 1:   faultLabel.text = "VFD-502"
            case 2:   faultLabel.text = "VFD-503"
            case 3:   faultLabel.text = "VFD-504"
            case 4:   faultLabel.text = "FCP-501"
            default:
                print("Wrong index")
        }
        self.view.addSubview(faultLabel)
    }
    
    private func customizeglStrainerFaultLabel(x: Int, y: Int, index: Int) {
        if y > 505 {
           strainerLabel = UILabel(frame: CGRect(x: 200, y: y - 420, width: 150, height: 20))
        } else {
           strainerLabel = UILabel(frame: CGRect(x: x, y: y, width: 150, height: 20))
        }
        
        strainerLabel.textAlignment = .center
        strainerLabel.textColor = RED_COLOR
        switch index {
               case 0:   strainerLabel.text = "VFD-501"
               case 1:   strainerLabel.text = "VFD-502"
               case 2:   strainerLabel.text = "VFD-503"
               case 3:   strainerLabel.text = "VFD-504"
            
        default:
            print("Wrong index")
        }
       
        self.view.addSubview(strainerLabel)
    }
    
    private func customizealStrainerFaultLabel(x: Int, y: Int, index: Int) {
        if y > 505 {
           strainerLabel = UILabel(frame: CGRect(x: 200, y: y - 420, width: 150, height: 20))
        } else {
           strainerLabel = UILabel(frame: CGRect(x: x, y: y, width: 150, height: 20))
        }
        
        strainerLabel.textAlignment = .center
        strainerLabel.textColor = RED_COLOR
        switch index {
               case 0:   strainerLabel.text = "VFD-1201"
               case 1:   strainerLabel.text = "VFD-1202"
               case 2:   strainerLabel.text = "VFD-1203"
               case 3:   strainerLabel.text = "VFD-1204"
               case 4:   strainerLabel.text = "VFD-1205"
               case 5:   strainerLabel.text = "VFD-1206"
               case 6:   strainerLabel.text = "MS-1101"
            
        default:
            print("Wrong index")
        }
       
        self.view.addSubview(strainerLabel)
    }
    
    private func customizedeStrainerFaultLabel(x: Int, y: Int, index: Int) {
        if y > 505 {
           strainerLabel = UILabel(frame: CGRect(x: 200, y: y - 420, width: 150, height: 20))
        } else {
           strainerLabel = UILabel(frame: CGRect(x: x, y: y, width: 150, height: 20))
        }
        
        strainerLabel.textAlignment = .center
        strainerLabel.textColor = RED_COLOR
        switch index {
               case 0:   strainerLabel.text = "VFD-2101"
               case 1:   strainerLabel.text = "VFD-2201"
               case 2:   strainerLabel.text = "VFD-2202"
            
        default:
            print("Wrong index")
        }
       
        self.view.addSubview(strainerLabel)
    }
    
    private func customizealFaultLabel(x: Int, y: Int, index: Int) {
        faultLabel = UILabel(frame: CGRect(x: x, y: y, width: 120, height: 20))
        faultLabel.textAlignment = .center
        faultLabel.textColor = RED_COLOR
        switch index {
            case 0:   faultLabel.text = "VFD-201"
            case 1:   faultLabel.text = "VFD-202"
            case 2:   faultLabel.text = "VFD-203"
            case 3:   faultLabel.text = "VFD-204"
            case 4:   faultLabel.text = "VFD-205"
            case 5:   faultLabel.text = "VFD-206"
            case 6:   faultLabel.text = "FCP-101"
            case 7:   faultLabel.text = "FCP-102"
            case 8:   faultLabel.text = "CP-101"
            case 9:   faultLabel.text = "FS-101"
            case 10:   faultLabel.text = "ATGL CP-501"
            default:
                print("Wrong index")
        }
        self.view.addSubview(faultLabel)
    }
    
    private func customizedeFaultLabel(x: Int, y: Int, index: Int) {
        faultLabel = UILabel(frame: CGRect(x: x, y: y, width: 120, height: 20))
        faultLabel.textAlignment = .center
        faultLabel.textColor = RED_COLOR
        switch index {
            case 0:   faultLabel.text = "VFD-2101"
            case 1:   faultLabel.text = "VFD-2201"
            case 2:   faultLabel.text = "VFD-2202"
            case 3:   faultLabel.text = "MW-2101"
            default:
                print("Wrong index")
        }
        self.view.addSubview(faultLabel)
    }
    
}
