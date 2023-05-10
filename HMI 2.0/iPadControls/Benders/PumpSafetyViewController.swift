//=================================== ABOUT ===================================

/*
 *  @FILE:          WaterLevelViewController.swift
 *  @AUTHOR:        Arpi Derm
 *  @RELEASE_DATE:  July 28, 2017, 4:13 PM
 *  @Description:   This Module reads all water level sensor values and
 *                  displays on the screen
 *  @VERSION:       2.0.0
 */

/***************************************************************************
 *
 * PROJECT SPECIFIC CONFIGURATION
 *
 * 1 : Water Level screen configuration parameters located in specs.swift file
 *     should be modified
 * 2 : readWaterLevelLiveValues function should be modified based on required
 *     value readings
 * 3 : Basin images should be replaced according to project drawings.
 *     Note: The image names should remain the same as what is provied in the
 *           project workspace image files
 * 4 : parseWaterLevelFaults() function should be modified based on required
 *     fault readings
 ***************************************************************************/


import UIKit


class PumpSafetyViewController: UIViewController{
    
    //MARK: - UI View Outlets
    
    @IBOutlet weak var waterLevelIcon:                      UIImageView!
    @IBOutlet weak var noConnectionView:                    UIView!
    @IBOutlet weak var noConnectionErrorLbl:                UILabel!
    private let showManager  = ShowManager()
    //MARK: - Class Reference Objects -- Dependencies
    
    private let logger          =          Logger()
    private let helper          =          Helper()
    private let utility         =         Utilits()
    private let operationManual = OperationManual()
    
    //MARK: - Data Structures
    
    private var langData          = Dictionary<String, String>()
    private var centralSystem = CentralSystem()
    private var acquiredTimersFromPLC = 0
    
    /***************************************************************************
     * Function :  viewDidLoad
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    override func viewDidLoad(){
        
        super.viewDidLoad()
        
    }
    
    /***************************************************************************
     * Function :  viewDidAppear
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    override func viewWillAppear(_ animated: Bool){
        centralSystem.getNetworkParameters()
        centralSystem.mittlagconnect()
        CENTRAL_SYSTEM = centralSystem
        readAlarmValues()
         //Add notification observer to get system stat
        NotificationCenter.default.addObserver(self, selector: #selector(PumpSafetyViewController.checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
        //Configure WaterLeveScreen Text Content Based On Device Language
        configureScreenTextContent()

        
    }
    
    /***************************************************************************
     * Function :  viewDidDisappear
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    override func viewWillDisappear(_ animated: Bool){
        
        NotificationCenter.default.removeObserver(self)
        
    }
    
    /***************************************************************************
     * Function :  checkSystemStat
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    @objc func checkSystemStat(){
        let (plcConnection,_,serverConnection,_) = CENTRAL_SYSTEM!.getConnectivityStat()
        
        if plcConnection == CONNECTION_STATE_CONNECTED && serverConnection == CONNECTION_STATE_CONNECTED  {
            
            //Change the connection stat indicator
            noConnectionView.alpha = 0
            readBenderValues()
            
        } else {
            noConnectionView.alpha = 1
            
            if plcConnection == CONNECTION_STATE_FAILED || serverConnection == CONNECTION_STATE_FAILED {
                if serverConnection == CONNECTION_STATE_CONNECTED {
                    noConnectionErrorLbl.text = "PLC CONNECTION FAILED, SERVER GOOD"
                } else if plcConnection == CONNECTION_STATE_CONNECTED{
                    noConnectionErrorLbl.text = "SERVER CONNECTION FAILED, PLC GOOD"
                } else {
                    noConnectionErrorLbl.text = "SERVER AND PLC CONNECTION FAILED"
                }
            }
            
            if plcConnection == CONNECTION_STATE_CONNECTING || serverConnection == CONNECTION_STATE_CONNECTING {
                if serverConnection == CONNECTION_STATE_CONNECTED {
                    noConnectionErrorLbl.text = "CONNECTING TO PLC, SERVER CONNECTED"
                } else if plcConnection == CONNECTION_STATE_CONNECTED{
                    noConnectionErrorLbl.text = "CONNECTING TO SERVER, PLC CONNECTED"
                } else {
                    noConnectionErrorLbl.text = "CONNECTING TO SERVER AND PLC.."
                }
            }
            
            if plcConnection == CONNECTION_STATE_POOR_CONNECTION && serverConnection == CONNECTION_STATE_POOR_CONNECTION {
                noConnectionErrorLbl.text = "SERVER AND PLC POOR CONNECTION"
            } else if plcConnection == CONNECTION_STATE_POOR_CONNECTION {
                noConnectionErrorLbl.text = "PLC POOR CONNECTION, SERVER CONNECTED"
            } else if serverConnection == CONNECTION_STATE_POOR_CONNECTION {
                noConnectionErrorLbl.text = "SERVER POOR CONNECTION, PLC CONNECTED"
            }
        }
    }
    
    /***************************************************************************
     * Function :  configureScreenTextContent
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    private func configureScreenTextContent(){
        
        self.navigationItem.title = "BENDER"
               
    }
        
    private func readAlarmValues(){
        CENTRAL_SYSTEM?.readBits(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, length: 12, startingRegister: Int32(CONTACTOR_EN), completion: { (success, response) in
            if response != nil{
                let cnt31 = Int(truncating: response![0] as! NSNumber)
                let cnt32 = Int(truncating: response![1] as! NSNumber)
                let cnt33 = Int(truncating: response![2] as! NSNumber)
                let cnt34 = Int(truncating: response![3] as! NSNumber)
                let cnt35 = Int(truncating: response![4] as! NSNumber)
                let cnt36 = Int(truncating: response![5] as! NSNumber)
                
                let cnt11 = Int(truncating: response![6] as! NSNumber)
                let cnt12 = Int(truncating: response![7] as! NSNumber)
                let cnt13 = Int(truncating: response![8] as! NSNumber)
                let cnt14 = Int(truncating: response![9] as! NSNumber)
                let cnt15 = Int(truncating: response![10] as! NSNumber)
                let cnt16 = Int(truncating: response![11] as! NSNumber)
                
                    
                let cnt11Swt = self.view.viewWithTag(51) as? UISwitch
                let cnt12Swt = self.view.viewWithTag(52) as? UISwitch
                let cnt13Swt = self.view.viewWithTag(53) as? UISwitch
                let cnt14Swt = self.view.viewWithTag(54) as? UISwitch
                let cnt15Swt = self.view.viewWithTag(55) as? UISwitch
                let cnt16Swt = self.view.viewWithTag(56) as? UISwitch
                
                let cnt31Swt = self.view.viewWithTag(57) as? UISwitch
                let cnt32Swt = self.view.viewWithTag(58) as? UISwitch
                let cnt33Swt = self.view.viewWithTag(59) as? UISwitch
                let cnt34Swt = self.view.viewWithTag(60) as? UISwitch
                let cnt35Swt = self.view.viewWithTag(61) as? UISwitch
                let cnt36Swt = self.view.viewWithTag(62) as? UISwitch
                
                cnt11 == 1 ? (cnt11Swt?.isOn = true) : (cnt11Swt?.isOn = false)
                cnt12 == 1 ? (cnt12Swt?.isOn = true) : (cnt12Swt?.isOn = false)
                cnt13 == 1 ? (cnt13Swt?.isOn = true) : (cnt13Swt?.isOn = false)
                cnt14 == 1 ? (cnt14Swt?.isOn = true) : (cnt14Swt?.isOn = false)
                cnt15 == 1 ? (cnt15Swt?.isOn = true) : (cnt15Swt?.isOn = false)
                cnt16 == 1 ? (cnt16Swt?.isOn = true) : (cnt16Swt?.isOn = false)
                
                cnt31 == 1 ? (cnt31Swt?.isOn = true) : (cnt31Swt?.isOn = false)
                cnt32 == 1 ? (cnt32Swt?.isOn = true) : (cnt32Swt?.isOn = false)
                cnt33 == 1 ? (cnt33Swt?.isOn = true) : (cnt33Swt?.isOn = false)
                cnt34 == 1 ? (cnt34Swt?.isOn = true) : (cnt34Swt?.isOn = false)
                cnt35 == 1 ? (cnt35Swt?.isOn = true) : (cnt35Swt?.isOn = false)
                cnt36 == 1 ? (cnt36Swt?.isOn = true) : (cnt36Swt?.isOn = false)
                
            }
        })
        
        CENTRAL_SYSTEM?.readBits(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, length: 12, startingRegister: Int32(GFCI_EN), completion:{ (success, response) in
            if response != nil{
                let gfci31 = Int(truncating: response![0] as! NSNumber)
                let gfci32 = Int(truncating: response![1] as! NSNumber)
                let gfci33 = Int(truncating: response![2] as! NSNumber)
                let gfci34 = Int(truncating: response![3] as! NSNumber)
                let gfci35 = Int(truncating: response![4] as! NSNumber)
                let gfci36 = Int(truncating: response![5] as! NSNumber)
                
                let gfci11 = Int(truncating: response![6] as! NSNumber)
                let gfci12 = Int(truncating: response![7] as! NSNumber)
                let gfci13 = Int(truncating: response![8] as! NSNumber)
                let gfci14 = Int(truncating: response![9] as! NSNumber)
                let gfci15 = Int(truncating: response![10] as! NSNumber)
                let gfci16 = Int(truncating: response![11] as! NSNumber)
                
                    
                let gfci11Swt = self.view.viewWithTag(71) as? UISwitch
                let gfci12Swt = self.view.viewWithTag(72) as? UISwitch
                let gfci13Swt = self.view.viewWithTag(73) as? UISwitch
                let gfci14Swt = self.view.viewWithTag(74) as? UISwitch
                let gfci15Swt = self.view.viewWithTag(75) as? UISwitch
                let gfci16Swt = self.view.viewWithTag(76) as? UISwitch
                
                let gfci31Swt = self.view.viewWithTag(77) as? UISwitch
                let gfci32Swt = self.view.viewWithTag(78) as? UISwitch
                let gfci33Swt = self.view.viewWithTag(79) as? UISwitch
                let gfci34Swt = self.view.viewWithTag(80) as? UISwitch
                let gfci35Swt = self.view.viewWithTag(81) as? UISwitch
                let gfci36Swt = self.view.viewWithTag(82) as? UISwitch
                
                gfci11 == 1 ? (gfci11Swt?.isOn = true) : (gfci11Swt?.isOn = false)
                gfci12 == 1 ? (gfci12Swt?.isOn = true) : (gfci12Swt?.isOn = false)
                gfci13 == 1 ? (gfci13Swt?.isOn = true) : (gfci13Swt?.isOn = false)
                gfci14 == 1 ? (gfci14Swt?.isOn = true) : (gfci14Swt?.isOn = false)
                gfci15 == 1 ? (gfci15Swt?.isOn = true) : (gfci15Swt?.isOn = false)
                gfci16 == 1 ? (gfci16Swt?.isOn = true) : (gfci16Swt?.isOn = false)
                
                gfci31 == 1 ? (gfci31Swt?.isOn = true) : (gfci31Swt?.isOn = false)
                gfci32 == 1 ? (gfci32Swt?.isOn = true) : (gfci32Swt?.isOn = false)
                gfci33 == 1 ? (gfci33Swt?.isOn = true) : (gfci33Swt?.isOn = false)
                gfci34 == 1 ? (gfci34Swt?.isOn = true) : (gfci34Swt?.isOn = false)
                gfci35 == 1 ? (gfci35Swt?.isOn = true) : (gfci35Swt?.isOn = false)
                gfci36 == 1 ? (gfci36Swt?.isOn = true) : (gfci36Swt?.isOn = false)
                
            }
        })
    }
    
    /***************************************************************************
     * Function :  readWaterLevelLiveValues
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    private func readBenderValues(){
        let devicelogs = self.showManager.getStatusLogFromServer()
        
        CENTRAL_SYSTEM?.readBits(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, length: 12, startingRegister: Int32(BENDER_ALARM_STATUS), completion:{ (success, response) in
            if response != nil{
                let b1ph3 = Int(truncating: response![0] as! NSNumber)
                let b2ph3 = Int(truncating: response![1] as! NSNumber)
                let b3ph3 = Int(truncating: response![2] as! NSNumber)
                let b4ph3 = Int(truncating: response![3] as! NSNumber)
                let b5ph3 = Int(truncating: response![4] as! NSNumber)
                let b6ph3 = Int(truncating: response![5] as! NSNumber)
                
                let b1ph1 = Int(truncating: response![6] as! NSNumber)
                let b2ph1 = Int(truncating: response![7] as! NSNumber)
                let b3ph1 = Int(truncating: response![8] as! NSNumber)
                let b4ph1 = Int(truncating: response![9] as! NSNumber)
                let b5ph1 = Int(truncating: response![10] as! NSNumber)
                let b6ph1 = Int(truncating: response![11] as! NSNumber)
                
                    
                let b11Img = self.view.viewWithTag(13) as? UIImageView
                let b21Img = self.view.viewWithTag(14) as? UIImageView
                let b31Img = self.view.viewWithTag(15) as? UIImageView
                let b41Img = self.view.viewWithTag(16) as? UIImageView
                let b51Img = self.view.viewWithTag(17) as? UIImageView
                let b61Img = self.view.viewWithTag(18) as? UIImageView
                
                let b13Img = self.view.viewWithTag(19) as? UIImageView
                let b23Img = self.view.viewWithTag(20) as? UIImageView
                let b33Img = self.view.viewWithTag(21) as? UIImageView
                let b43Img = self.view.viewWithTag(22) as? UIImageView
                let b53Img = self.view.viewWithTag(23) as? UIImageView
                let b63Img = self.view.viewWithTag(24) as? UIImageView
                
                b1ph1 == 1 ? ( b11Img?.image = #imageLiteral(resourceName: "blank_icon_on")) : (b11Img?.image = #imageLiteral(resourceName: "red"))
                b2ph1 == 1 ? ( b21Img?.image = #imageLiteral(resourceName: "blank_icon_on")) : (b21Img?.image = #imageLiteral(resourceName: "red"))
                b3ph1 == 1 ? ( b31Img?.image = #imageLiteral(resourceName: "blank_icon_on")) : (b31Img?.image = #imageLiteral(resourceName: "red"))
                b4ph1 == 1 ? ( b41Img?.image = #imageLiteral(resourceName: "blank_icon_on")) : (b41Img?.image = #imageLiteral(resourceName: "red"))
                b5ph1 == 1 ? ( b51Img?.image = #imageLiteral(resourceName: "blank_icon_on")) : (b51Img?.image = #imageLiteral(resourceName: "red"))
                b6ph1 == 1 ? ( b61Img?.image = #imageLiteral(resourceName: "blank_icon_on")) : (b61Img?.image = #imageLiteral(resourceName: "red"))
                
                b1ph3 == 1 ? ( b13Img?.image = #imageLiteral(resourceName: "blank_icon_on")) : (b13Img?.image = #imageLiteral(resourceName: "red"))
                b2ph3 == 1 ? ( b23Img?.image = #imageLiteral(resourceName: "blank_icon_on")) : (b23Img?.image = #imageLiteral(resourceName: "red"))
                b3ph3 == 1 ? ( b33Img?.image = #imageLiteral(resourceName: "blank_icon_on")) : (b33Img?.image = #imageLiteral(resourceName: "red"))
                b4ph3 == 1 ? ( b43Img?.image = #imageLiteral(resourceName: "blank_icon_on")) : (b43Img?.image = #imageLiteral(resourceName: "red"))
                b5ph3 == 1 ? ( b53Img?.image = #imageLiteral(resourceName: "blank_icon_on")) : (b53Img?.image = #imageLiteral(resourceName: "red"))
                b6ph3 == 1 ? ( b63Img?.image = #imageLiteral(resourceName: "blank_icon_on")) : (b63Img?.image = #imageLiteral(resourceName: "red"))
                
            }
        })
        let bndr11Lbl = self.view.viewWithTag(1) as? UILabel
        let bndr21Lbl = self.view.viewWithTag(2) as? UILabel
        let bndr31Lbl = self.view.viewWithTag(3) as? UILabel
        let bndr41Lbl = self.view.viewWithTag(4) as? UILabel
        let bndr51Lbl = self.view.viewWithTag(5) as? UILabel
        let bndr61Lbl = self.view.viewWithTag(6) as? UILabel
        let bndr13Lbl = self.view.viewWithTag(7) as? UILabel
        let bndr23Lbl = self.view.viewWithTag(8) as? UILabel
        let bndr33Lbl = self.view.viewWithTag(9) as? UILabel
        let bndr43Lbl = self.view.viewWithTag(10) as? UILabel
        let bndr53Lbl = self.view.viewWithTag(11) as? UILabel
        let bndr63Lbl = self.view.viewWithTag(12) as? UILabel
        
        bndr11Lbl!.text = String(format: "%.1f", devicelogs.bender13current * 1000)
        bndr13Lbl!.text = String(format: "%.1f", devicelogs.bender23current * 1000)
        bndr21Lbl!.text = String(format: "%.1f", devicelogs.bender33current * 1000)
        bndr23Lbl!.text = String(format: "%.1f", devicelogs.bender43current * 1000)
        bndr31Lbl!.text = String(format: "%.1f", devicelogs.bender53current * 1000)
        bndr33Lbl!.text = String(format: "%.1f", devicelogs.bender63current * 1000)
        bndr41Lbl!.text = String(format: "%.1f", devicelogs.bender73current * 1000)
        bndr43Lbl!.text = String(format: "%.1f", devicelogs.bender83current * 1000)
        bndr51Lbl!.text = String(format: "%.1f", devicelogs.bender93current * 1000)
        bndr53Lbl!.text = String(format: "%.1f", devicelogs.bender103current * 1000)
        bndr61Lbl!.text = String(format: "%.1f", devicelogs.bender113current * 1000)
        bndr63Lbl!.text = String(format: "%.1f", devicelogs.bender123current * 1000)
        
    }
    
    @IBAction func trigAlarmReset(_ sender: UIButton) {
        let btn = sender
        btn.isEnabled = false
        CENTRAL_SYSTEM?.writeBit(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, bit: BENDER_ALARM_TEST, value: 1)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            btn.isEnabled = true
            CENTRAL_SYSTEM?.writeBit(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, bit: BENDER_ALARM_TEST, value: 0)
        }
    }
    @IBAction func trigAlarmTestReset(_ sender: UIButton) {
        let btn = sender
        btn.isEnabled = false
        CENTRAL_SYSTEM?.writeBit(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, bit: BENDER_ALARM_TESET_RESET, value: 1)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            btn.isEnabled = true
            CENTRAL_SYSTEM?.writeBit(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, bit: BENDER_ALARM_TESET_RESET, value: 0)
        }
    }
    
    @IBAction func sendEnableDisableCmd(_ sender: UISwitch) {
        let switchTag = sender.tag
        print(switchTag)
        switch switchTag {
        case 51...62:
                if sender.isOn {
                   CENTRAL_SYSTEM?.writeBit(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, bit: CONTACTOR_EN + (switchTag-51), value: 1)
                   DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                    self.readAlarmValues()
                   }
                   
                } else {
                   CENTRAL_SYSTEM?.writeBit(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, bit: CONTACTOR_EN + (switchTag-51), value: 0)
                   DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                     self.readAlarmValues()
                   }
                }
        case 71...82:
                if sender.isOn {
                   CENTRAL_SYSTEM?.writeBit(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, bit: GFCI_EN + (switchTag-71), value: 1)
                   DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                     self.readAlarmValues()
                   }
                } else {
                   CENTRAL_SYSTEM?.writeBit(plcIpAddress: MITT_LAG_PLC_IP_ADDRESS, bit: GFCI_EN + (switchTag-71), value: 0)
                   DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                     self.readAlarmValues()
                   }
                }
        default:
            print("wrong Tag: Bender Screen")
        }
    }
    
}
