//
//  CentralSystem.swift
//  iPadControls
//
//  Created by Jan Manalo on 12/27/18.
//  Copyright © 2018 WET. All rights reserved.
//

import UIKit
import PlainPing

var IPAddressIsChanged = false
var SERVER_TIME = ""
var SERVER2_TIME = ""
var newIPAddressConnectedSuccessfully = true

public class CentralSystem: NSObject, SimplePingDelegate{
    private var modubus:    ObjectiveLibModbus?
    private var lagmodubus:    ObjectiveLibModbus?
    private var lamodubus:    ObjectiveLibModbus?
    private var timer:      Timer?
    private let operation = OperationQueue()

    //State Variables
    
    private var mittlagplcConnectionState         = 2
    private var mittlaplcConnectionState          = 2
    private var numberOfFailedMITTLAGPlcConnections    = 0
    private var numberOfFailedMITTLAPlcConnections    = 0
    private var serverConnectionState           = 2
    private var serverConnection2State          = 2
    private var numberOfFailedServerConnections = 0
    private var numberOfFailed2ServerConnections = 0
    
    //Dipendencies
    
    private let localStorage = LocalStorage()
    private let logger       = Logger()
    private let showManager  = ShowManager()
    private let httpComm     = HTTPComm()
    private let lightControl = LightsViewController()
    
    private var fireMITTLAGOnce    = false
    private var fireMITTLAOnce    = false
    private var failedToPingMITTLAGPLC = false
    private var failedToPingMITTLAPLC = false
    private var failedToPingserver = false
    private var failedToPing2server = false
    //Data Variables
    
    private var network:Network?

    //Lights Global Values
        
    public var DAY_MODE = 0

    
    /***************************************************************************
     * Function :  initialize
     * Input    :  none
     * Output   :  none
     * Comment  :  Construct the modbus library class reference with desired PLC
     *             config parameters
     ***************************************************************************/
    
    public func initialize(){
        
        //Initial Setpoints
        saveInitialParameters()
        getNetworkParameters()

        //Start The Status Check
        timer = Timer.scheduledTimer(timeInterval: 0.9, target: self, selector: #selector(sendPing), userInfo: nil, repeats: true)

    }
    
    public func reinitialize() {
        self.timer?.invalidate()
        self.timer = nil
        self.initialize()
    }
    
    /***************************************************************************
     * Function :  getNetworkParameters
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
        func getNetworkParameters(){
    
        let networks = Network.all() as! [Network]
        
        guard networks.count == 1 else{
            return
        }
        
        network = networks[0]
        
        //Save parameters to user defaults so legacy screens with objective c code will be able to get this info
        
        UserDefaults.standard.set("\(network!.serverIpAddress!)", forKey: "serverIpAddress")
        UserDefaults.standard.set("\(network!.server2IpAddress!)", forKey: "server2IpAddress")
        UserDefaults.standard.set("\(network!.mittlagplcIpAddress!)", forKey: "lagoonplcIpAddress")
        UserDefaults.standard.set("\(network!.mittlaplcIpAddress!)", forKey: "lakeplcIpAddress")
        UserDefaults.standard.set("\(network!.spmIpAddress!)", forKey: "spmIpAddress")
        
    }

    /***************************************************************************
     * Function :  saveInitialParameters
     * Input    :  none
     * Output   :  none
     * Comment  :  Save the initial DataAcquisition System Prototypes
     *             To The Local Storage
     ***************************************************************************/
    
    public func saveInitialParameters(){
        
        //Save Data Acquisition Prototype To Local Device Storage
        self.localStorage.saveInitialDataAcquisitionSystemParams()
        
    }
    
    
    /***************************************************************************
     * Function :  getServerTime
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    func getServerTime(){
        
        self.httpComm.httpGetResponseFromPath(url: SERVER_TIME_PATH){ (reponse) in
            
            if reponse != nil{
                
                if let stringResponse = reponse as? String {
                    let dateFormatter = DateFormatter()
                    let tempLocale = dateFormatter.locale // save locale temporarily
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sssZ"
                    let date = dateFormatter.date(from: stringResponse)
                    dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
                    dateFormatter.locale = tempLocale // reset the locale
                    
                    if let date = date {
                        let dateString = dateFormatter.string(from: date)
                        SERVER_TIME = dateString
                    } else {
                        SERVER_TIME = reponse as! String
                        
                    }

                }

            }
            
        }
        
    }
    func getServer2Time(){
        
        self.httpComm.httpGetResponseFromPath(url: SERVER2_TIME_PATH){ (reponse) in
            
            if reponse != nil{
                
                if let stringResponse = reponse as? String {
                    let dateFormatter = DateFormatter()
                    let tempLocale = dateFormatter.locale // save locale temporarily
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sssZ"
                    let date = dateFormatter.date(from: stringResponse)
                    dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
                    dateFormatter.locale = tempLocale // reset the locale
                    
                    if let date = date {
                        let dateString = dateFormatter.string(from: date)
                        SERVER2_TIME = dateString
                    } else {
                        SERVER2_TIME = reponse as! String
                        
                    }

                }

            }
            
        }
        
    }
    /***************************************************************************
      * Function :  mittlagconnect
      * Input    :  none
      * Output   :  none
      * Comment  :
      ***************************************************************************/
     
     public func mittlagconnect(){
         
         self.logger.logData(data: "CENTRAL SYSTEM: GOING TO ESTABLISH COMMUNICATION WITH  LAGOON PLC")
         UserDefaults.standard.set("0", forKey: "scanningShows")
         //Before Connecting to the enclosure, we want to reset all the temporarly parameters
         
         self.mittlagdisconnect()
         
         //Establish Modbus Connection
         lagmodubus = ObjectiveLibModbus(tcp: network!.mittlagplcIpAddress!, port: Int32(PLC_PORT), device: 1)
         
         
         if lagmodubus != nil{
             
             lagmodubus!.connect({
                 
                 //Established Connection With PLC
                 self.logger.logData(data: "CENTRAL SYSTEM: ESTABLISHED CONNECTION WITH LAGOON PLC")
                 
                 self.readRegister(plcIpAddress:MITT_LAG_PLC_IP_ADDRESS, length: 1, startingRegister: Int32(LIGHTS_AUTO_HAND_PLC_REGISTER), completion: { (success, response) in
                     
                     guard success == true else { return }
                     self.fireMITTLAGOnce = true
                     UserDefaults.standard.set("MITTLAGPLCConnected", forKey: "MITTLAGPLCConnectionStatus")
                    self.mittlagplcConnectionState = CONNECTION_STATE_CONNECTED
                     
                 })
                 
             },failure:{ (error) in
                 
                 
                 
             })
             
             self.logger.logData(data: "CENTRAL SYSTEM: ESTABLISHING CONNECTION WITH LAGOON PLC")
             self.logger.logData(data: "CENTRAL SYSTEM: LAGOON PLC CONNECTION STATE -> \(mittlagplcConnectionState)")
             
         } else {
             mittlagplcConnectionState = CONNECTION_STATE_FAILED
         }
     }
    
    
    /***************************************************************************
     * Function :  mittlaconnect
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    public func mittlaconnect(){
        
        self.logger.logData(data: "CENTRAL SYSTEM: GOING TO ESTABLISH COMMUNICATION WITH LAKE PLC")
        UserDefaults.standard.set("0", forKey: "lakescanningShows")
        //Before Connecting to the enclosure, we want to reset all the temporarly parameters
        
        self.mittladisconnect()
        
        //Establish Modbus Connection
        lamodubus = ObjectiveLibModbus(tcp: network!.mittlaplcIpAddress!, port: Int32(PLC_PORT), device: 1)
        
        if lamodubus != nil{
                   
           lamodubus!.connect({
               
               //Established Connection With PLC
               self.logger.logData(data: "CENTRAL SYSTEM: ESTABLISHED CONNECTION WITH LAKE PLC")
               
               self.readRegister(plcIpAddress:MITT_LA_PLC_IP_ADDRESS, length: 1, startingRegister: Int32(LIGHTS_AUTO_HAND_PLC_REGISTER), completion: { (success, response) in
                   
                   guard success == true else { return }
                   self.fireMITTLAOnce = true
                   UserDefaults.standard.set("MITTLAPLCConnected", forKey: "MITTLAPLCConnectionStatus")
                   self.mittlaplcConnectionState = CONNECTION_STATE_CONNECTED
                   
               })
               
           },failure:{ (error) in
               
               
               
           })
           
           self.logger.logData(data: "CENTRAL SYSTEM: ESTABLISHING CONNECTION WITH LAKE PLC")
           self.logger.logData(data: "CENTRAL SYSTEM: LAKE PLC CONNECTION STATE -> \(mittlaplcConnectionState)")
           
           } else {
               mittlaplcConnectionState = CONNECTION_STATE_FAILED
           }
    }
    
    /***************************************************************************
     * Function :  disconnect
     * Input    :  none
     * Output   :  none
     * Comment  :  Invalidate and disconnect all the timers and connections
     ***************************************************************************/
    
    private func mittlagdisconnect(){

        //Check if modbus connection object is not empty then disconnect it
        guard lagmodubus != nil  else { return }
        
        self.lagmodubus!.disconnect()
       
    }
    
    private func mittladisconnect(){

        //Check if modbus connection object is not empty then disconnect it
        guard lamodubus != nil  else { return }
        
        self.lamodubus!.disconnect()
       
    }
    
    /***************************************************************************
     * Function :  sendPing
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    @objc func sendPing(){
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.pingServer()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.pinglagoonPLC()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.pinglakePLC()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.ping2Server()
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
    }
    
    /***************************************************************************
     * Function :  pingPLC
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    private func pinglagoonPLC(){
        
        guard network != nil else { return }
            PlainPing.ping(network!.mittlagplcIpAddress!, withTimeout: 1.0, completionBlock:{ (timeElapsed:Double?, error:Error?) in
                
                self.failedToPingMITTLAGPLC = false
                
                if let latency = timeElapsed {
    //                print("PLC pinged successfully")
                    self.logger.logData(data:latency.description)
                    
                    //After pinging the plc, you wanted to make sure that you are actually getting a data. If pinging fails then there's something wrong with the plc itself, else you are just waiting for the plc to give you a data. NOTE: any register number will do.
                    
                    
                    // NOTE: Plain ping can only ping one address at a time. So, when PLC is already connected -- ping the server next or vice versa.
                    if !self.fireMITTLAGOnce {
                       self.mittlagconnect()
                    }

                    UserDefaults.standard.set("MITTLAGPLCConnected", forKey: "MITTLAGPLCConnectionStatus")
                    if self.numberOfFailedMITTLAGPlcConnections > 0 {
                        self.numberOfFailedMITTLAGPlcConnections = 0
    //                    print("RESETTING FAILED PLC COUNTER TO \(self.numberOfFailedPlcConnections)")
                        self.fireMITTLAGOnce = false
                    }
                }
                
                if error != nil {
                    self.failedToPingMITTLAPLC = true
                    self.numberOfFailedMITTLAPlcConnections += 1
    //                print("PLC CONNECTION FAILED \(self.numberOfFailedPlcConnections)")
                    
                    if self.numberOfFailedMITTLAGPlcConnections >= MAX_CONNECTION_FAULTS && self.numberOfFailedMITTLAGPlcConnections < MAX_CONNECTION_FAILED {
    //                            UserDefaults.standard.set("connectingATDEPLC", forKey: "MITTLAPLCConnectionStatus")
    //                            self.mittlaplcConnectionState = CONNECTION_STATE_CONNECTING
    //                    print("PLC CONNECTION FAILED \(self.numberOfFailedPlcConnections).. RECONNECTING")
                        self.reinitialize()
                    } else if self.numberOfFailedMITTLAGPlcConnections >= MAX_CONNECTION_FAILED {
                        self.mittlaplcConnectionState = CONNECTION_STATE_FAILED
    //                    print("PLC CONNECTION FAILED: \(self.numberOfFailedPlcConnections). MAX AMOUNT OF FAIL REACHED")
                        UserDefaults.standard.set("MITTLAGplcFailed", forKey: "MITTLAGPLCConnectionStatus")
                        self.reinitialize()
                    }
                }
                
            })
            
        
            if failedToPingMITTLAPLC {
                self.numberOfFailedMITTLAPlcConnections += 1
    //            print("PLC CONNECTION FAILED \(self.numberOfFailedPlcConnections)")
                
                if self.numberOfFailedMITTLAPlcConnections >= MAX_CONNECTION_FAULTS && self.numberOfFailedMITTLAPlcConnections < MAX_CONNECTION_FAILED {
    //                        UserDefaults.standard.set("connectingATDEPLC", forKey: "MITTLAPLCConnectionStatus")
    //                        self.mittlaplcConnectionState = CONNECTION_STATE_CONNECTING
    //                print("PLC CONNECTION FAILED \(self.numberOfFailedPlcConnections).. RECONNECTING")
                    self.reinitialize()
                } else if self.numberOfFailedMITTLAPlcConnections >= MAX_CONNECTION_FAILED {
                    self.mittlaplcConnectionState = CONNECTION_STATE_FAILED
    //                print("PLC CONNECTION FAILED: \(self.numberOfFailedPlcConnections). MAX AMOUNT OF FAIL REACHED")
                    UserDefaults.standard.set("MITTLAplcFailed", forKey: "MITTLAPLCConnectionStatus")
                    self.reinitialize()
                    
                }
                
            }
            
            guard self.mittlaplcConnectionState == CONNECTION_STATE_CONNECTED else{
                return
            }
            getCurrentLakeShowAlInfo()
            readLakeBackWashRunning()
                        
    }
    
    private func pinglakePLC(){
        guard network != nil else { return }
                PlainPing.ping(network!.mittlaplcIpAddress!, withTimeout: 1.0, completionBlock:{ (timeElapsed:Double?, error:Error?) in
                    
                    self.failedToPingMITTLAPLC = false
                    
                    if let latency = timeElapsed {
        //                print("PLC pinged successfully")
                        self.logger.logData(data:latency.description)
                        
                        //After pinging the plc, you wanted to make sure that you are actually getting a data. If pinging fails then there's something wrong with the plc itself, else you are just waiting for the plc to give you a data. NOTE: any register number will do.
                        
                        
                        // NOTE: Plain ping can only ping one address at a time. So, when PLC is already connected -- ping the server next or vice versa.
                        if !self.fireMITTLAOnce {
                           self.mittlaconnect()
                        }

                        UserDefaults.standard.set("MITTLAPLCConnected", forKey: "MITTLAPLCConnectionStatus")
                        if self.numberOfFailedMITTLAPlcConnections > 0 {
                            self.numberOfFailedMITTLAPlcConnections = 0
        //                    print("RESETTING FAILED PLC COUNTER TO \(self.numberOfFailedPlcConnections)")
                            self.fireMITTLAOnce = false
                        }
                    }
                    
                    if error != nil {
                        self.failedToPingMITTLAPLC = true
                        self.numberOfFailedMITTLAPlcConnections += 1
        //                print("PLC CONNECTION FAILED \(self.numberOfFailedPlcConnections)")
                        
                        if self.numberOfFailedMITTLAPlcConnections >= MAX_CONNECTION_FAULTS && self.numberOfFailedMITTLAPlcConnections < MAX_CONNECTION_FAILED {
//                            UserDefaults.standard.set("connectingATDEPLC", forKey: "MITTLAPLCConnectionStatus")
//                            self.mittlaplcConnectionState = CONNECTION_STATE_CONNECTING
        //                    print("PLC CONNECTION FAILED \(self.numberOfFailedPlcConnections).. RECONNECTING")
                            self.reinitialize()
                        } else if self.numberOfFailedMITTLAPlcConnections >= MAX_CONNECTION_FAILED {
                            self.mittlaplcConnectionState = CONNECTION_STATE_FAILED
        //                    print("PLC CONNECTION FAILED: \(self.numberOfFailedPlcConnections). MAX AMOUNT OF FAIL REACHED")
                            UserDefaults.standard.set("MITTLAplcFailed", forKey: "MITTLAPLCConnectionStatus")
                            self.reinitialize()
                        }
                    }
                    
                })
                
            
                if failedToPingMITTLAPLC {
                    self.numberOfFailedMITTLAPlcConnections += 1
        //            print("PLC CONNECTION FAILED \(self.numberOfFailedPlcConnections)")
                    
                    if self.numberOfFailedMITTLAPlcConnections >= MAX_CONNECTION_FAULTS && self.numberOfFailedMITTLAPlcConnections < MAX_CONNECTION_FAILED {
//                        UserDefaults.standard.set("connectingATDEPLC", forKey: "MITTLAPLCConnectionStatus")
//                        self.mittlaplcConnectionState = CONNECTION_STATE_CONNECTING
        //                print("PLC CONNECTION FAILED \(self.numberOfFailedPlcConnections).. RECONNECTING")
                        self.reinitialize()
                    } else if self.numberOfFailedMITTLAPlcConnections >= MAX_CONNECTION_FAILED {
                        self.mittlaplcConnectionState = CONNECTION_STATE_FAILED
        //                print("PLC CONNECTION FAILED: \(self.numberOfFailedPlcConnections). MAX AMOUNT OF FAIL REACHED")
                        UserDefaults.standard.set("MITTLAplcFailed", forKey: "MITTLAPLCConnectionStatus")
                        self.reinitialize()
                        
                    }
                    
                }
                
                guard self.mittlaplcConnectionState == CONNECTION_STATE_CONNECTED else{
                    return
                }
                getCurrentLakeShowAlInfo()
                readLakeBackWashRunning()
                
    }

    
    /***************************************************************************
     * Function :  Read Back Wash Running Bit
     * Input    :  none
     * Output   :  none
     * Comment  :  Check whether the back wash is running or not. We need to save the value to  Userdefaults. If back wash is running we cannot play a show.
     ***************************************************************************/
    
    private func readBackWashRunning(){
        
        CENTRAL_SYSTEM?.readBits(plcIpAddress:MITT_LAG_PLC_IP_ADDRESS, length: 1, startingRegister: Int32(FILTRATION_BWASH_RUNNING_BIT), completion: { (success, response) in
            
            guard success == true else { return }
            
            let running = Int(truncating: response![0] as! NSNumber)

            if running == 1{
                UserDefaults.standard.set(1, forKey: "backWashRunningStat")
            } else {
                UserDefaults.standard.set(0, forKey: "backWashRunningStat")
            }
            
        })
    }
    
    private func readLakeBackWashRunning(){
        
        CENTRAL_SYSTEM?.readBits(plcIpAddress:MITT_LA_PLC_IP_ADDRESS, length: 1, startingRegister: Int32(FILTRATION_BWASH_RUNNING_BIT), completion: { (success, response) in
            
            guard success == true else { return }
            
            let running = Int(truncating: response![0] as! NSNumber)

            if running == 1{
                UserDefaults.standard.set(1, forKey: "lakebackWashRunningStat")
            } else {
                UserDefaults.standard.set(0, forKey: "lakebackWashRunningStat")
            }
            
        })
    }
    
    /***************************************************************************
     * Function :  getAlightCurrentShowInfo
     * Input    :  none
     * Output   :  none
     * Comment  :  Fetches current show info and saves data to user defaults
     ***************************************************************************/
    
    private func getCurrentShowInfo(){
    
        let isShowScannerActive = UserDefaults.standard.object(forKey: "scanningShows") as? String
        
        if isShowScannerActive == "0" {
            
            let showPlayStat = self.showManager.getCurrentAndNextShowInfo()
            
            UserDefaults.standard.set(showPlayStat.currentShowNumber, forKey: "currentShowNumber")
            UserDefaults.standard.set(showPlayStat.deflate, forKey: "deflate")
            UserDefaults.standard.set(showPlayStat.nextShowNumber, forKey: "nextShowNumber")
            UserDefaults.standard.set(showPlayStat.showRemaining, forKey: "show time remaining")
            UserDefaults.standard.set(showPlayStat.playType, forKey: "Show Type")
            UserDefaults.standard.set(showPlayStat.nextShowTime, forKey: "nextShowTime")
            UserDefaults.standard.set(showPlayStat.playMode, forKey: "playMode")
            UserDefaults.standard.set(showPlayStat.playStatus, forKey: "playStatus")
            UserDefaults.standard.set(showPlayStat.showDuration, forKey: "showDuration")
            UserDefaults.standard.set(showPlayStat.currentShowName, forKey: "currentShowName")
            
        } else if isShowScannerActive == "1" {
            print("Lagoon ShowScanActive")
        }
    }
    
    private func getCurrentLakeShowAlInfo(){
    
        let isShowScannerActive = UserDefaults.standard.object(forKey: "lakescanningShows") as? String
        
        if isShowScannerActive == "0" {
            
            let showPlayStat = self.showManager.getLakeCurrentAndNextShowInfo()
            
            UserDefaults.standard.set(showPlayStat.currentShowNumber, forKey: "lakecurrentShowNumber")
            UserDefaults.standard.set(showPlayStat.deflate, forKey: "lakedeflate")
            UserDefaults.standard.set(showPlayStat.nextShowNumber, forKey: "lakenextShowNumber")
            UserDefaults.standard.set(showPlayStat.showRemaining, forKey: "lakeshow time remaining")
            UserDefaults.standard.set(showPlayStat.playType, forKey: "lakeShow Type")
            UserDefaults.standard.set(showPlayStat.nextShowTime, forKey: "lakenextShowTime")
            UserDefaults.standard.set(showPlayStat.playMode, forKey: "lakeplayMode")
            UserDefaults.standard.set(showPlayStat.playStatus, forKey: "lakeplayStatus")
            UserDefaults.standard.set(showPlayStat.showDuration, forKey: "lakeshowDuration")
            UserDefaults.standard.set(showPlayStat.currentShowName, forKey: "lakecurrentShowName")
            
        } else if isShowScannerActive == "1" {
            print("Lake ShowScanActive")
        }
    }
    

    
   
    /***************************************************************************
     * Function :  pingServer, ping2Server
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    private func pingServer(){
        
        guard self.network != nil else{ return }
        
        failedToPingserver = true
        
        PlainPing.ping(self.network!.serverIpAddress!, withTimeout: 1.0, completionBlock:{ (timeElapsed:Double?, error:Error?) in
            
            self.failedToPingserver = false
            
            if let latency = timeElapsed{
//                print("Server pinged succesfully")
                self.logger.logData(data:"CENTRAL SYSTEM: SERVER PINING SUCCESS -> \(latency.description)")
                
                //Same as pinging the plc.. For the server, you wanted to make sure that you are actually getting a data. If pinging fails then there's something wrong with the server itself, else you are just waiting for the server to give you a data. NOTE: any path number will do.
                
                self.httpComm.httpGetResponseFromPath(url: READ_SHOW_PLAY_STAT){ (response) in
                    
                    guard response != nil else {
                        self.serverConnectionState = CONNECTION_STATE_POOR_CONNECTION
                        UserDefaults.standard.set("poorServer", forKey: "ServerConnectionStatus")
                        return
                    }
                    
                    self.serverConnectionState = CONNECTION_STATE_CONNECTED
                    
                    UserDefaults.standard.set("serverConnected", forKey: "ServerConnectionStatus")
                    self.getErrorLogFromServer()
                    self.getServerTime()
                }
                
                
                if self.numberOfFailedServerConnections > 0 {
                    self.numberOfFailedServerConnections = 0
//                    print("RESETTING SERVER FAILED COUNTER TO \(self.numberOfFailedPlcConnections)")
                }
                
            }
            
            if error != nil {
                self.numberOfFailedServerConnections += 1
//                print("SERVER CONNECTION FAILED \(self.numberOfFailedServerConnections)")
                
                if self.numberOfFailedServerConnections >= MAX_CONNECTION_FAULTS && self.numberOfFailedServerConnections < MAX_CONNECTION_FAILED {
                   // self.serverConnectionState = CONNECTION_STATE_CONNECTING
//                    print("SERVER CONNECTION FAILED \(self.numberOfFailedServerConnections).. RECONNECTING")
                    //UserDefaults.standard.set("connectingServer", forKey: "ServerConnectionStatus")
                } else if self.numberOfFailedServerConnections >= MAX_CONNECTION_FAILED {
                    self.serverConnectionState = CONNECTION_STATE_FAILED
//                     print("SERVER CONNECTION FAILED: \(self.numberOfFailedServerConnections). MAX AMOUNT OF FAIL REACHED")
                    UserDefaults.standard.set("serverFailed", forKey: "ServerConnectionStatus")
                }
            }
        })
        
        if failedToPingserver {
            self.numberOfFailedServerConnections += 1
//            print("SERVER CONNECTION FAILED \(self.numberOfFailedServerConnections)")
            
            if self.numberOfFailedServerConnections >= MAX_CONNECTION_FAULTS && self.numberOfFailedServerConnections < MAX_CONNECTION_FAILED {
               // self.serverConnectionState = CONNECTION_STATE_CONNECTING
//                print("SERVER CONNECTION FAILED \(self.numberOfFailedServerConnections).. RECONNECTING")
                //UserDefaults.standard.set("connectingServer", forKey: "ServerConnectionStatus")
            } else if self.numberOfFailedServerConnections >= MAX_CONNECTION_FAILED {
                self.serverConnectionState = CONNECTION_STATE_FAILED
//                print("SERVER CONNECTION FAILED: \(self.numberOfFailedServerConnections). MAX AMOUNT OF FAIL REACHED")
                UserDefaults.standard.set("serverFailed", forKey: "ServerConnectionStatus")
            }
        }
    }
    
    private func ping2Server(){
            
            guard self.network != nil else{ return }
            
            failedToPing2server = true
            
            PlainPing.ping(self.network!.server2IpAddress!, withTimeout: 1.0, completionBlock:{ (timeElapsed:Double?, error:Error?) in
                
                self.failedToPing2server = false
                
                if let latency = timeElapsed{
    //                print("Server pinged succesfully")
                    self.logger.logData(data:"CENTRAL SYSTEM: SERVER 2 PINING SUCCESS -> \(latency.description)")
                    
                    //Same as pinging the plc.. For the server, you wanted to make sure that you are actually getting a data. If pinging fails then there's something wrong with the server itself, else you are just waiting for the server to give you a data. NOTE: any path number will do.
                    
                    self.httpComm.httpGetResponseFromPath(url: SERVER2_TIME_PATH){ (response) in
                        
                        guard response != nil else {
                            self.serverConnection2State = CONNECTION_STATE_POOR_CONNECTION
                            UserDefaults.standard.set("poorServer", forKey: "Server2ConnectionStatus")
                            return
                        }
                        
                        self.serverConnection2State = CONNECTION_STATE_CONNECTED
                        
                        UserDefaults.standard.set("serverConnected", forKey: "Server2ConnectionStatus")
                        self.getErrorLogFromServer()
                        self.getServer2Time()
                    }
                    
                    
                    if self.numberOfFailed2ServerConnections > 0 {
                        self.numberOfFailed2ServerConnections = 0
    //                    print("RESETTING SERVER FAILED COUNTER TO \(self.numberOfFailedPlcConnections)")
                    }
                    
                }
                
                if error != nil {
                    self.numberOfFailed2ServerConnections += 1
    //                print("SERVER CONNECTION FAILED \(self.numberOfFailedServerConnections)")
                    
                    if self.numberOfFailed2ServerConnections >= MAX_CONNECTION_FAULTS && self.numberOfFailed2ServerConnections < MAX_CONNECTION_FAILED {
                        //self.serverConnection2State = CONNECTION_STATE_CONNECTING
    //                    print("SERVER CONNECTION FAILED \(self.numberOfFailedServerConnections).. RECONNECTING")
                       // UserDefaults.standard.set("connectingServer", forKey: "Server2ConnectionStatus")
                    } else if self.numberOfFailed2ServerConnections >= MAX_CONNECTION_FAILED {
                        self.serverConnection2State = CONNECTION_STATE_FAILED
    //                     print("SERVER CONNECTION FAILED: \(self.numberOfFailedServerConnections). MAX AMOUNT OF FAIL REACHED")
                        UserDefaults.standard.set("serverFailed", forKey: "Server2ConnectionStatus")
                    }
                }
            })
            
            if failedToPing2server {
                self.numberOfFailed2ServerConnections += 1
    //            print("SERVER CONNECTION FAILED \(self.numberOfFailedServerConnections)")
                
                if self.numberOfFailed2ServerConnections >= MAX_CONNECTION_FAULTS && self.numberOfFailed2ServerConnections < MAX_CONNECTION_FAILED {
                   // self.serverConnection2State = CONNECTION_STATE_CONNECTING
    //                print("SERVER CONNECTION FAILED \(self.numberOfFailedServerConnections).. RECONNECTING")
                    //UserDefaults.standard.set("connectingServer", forKey: "Server2ConnectionStatus")
                } else if self.numberOfFailed2ServerConnections >= MAX_CONNECTION_FAILED {
                    self.serverConnection2State = CONNECTION_STATE_FAILED
    //                print("SERVER CONNECTION FAILED: \(self.serverConnection2State). MAX AMOUNT OF FAIL REACHED")
                    UserDefaults.standard.set("serverFailed", forKey: "Server2ConnectionStatus")
                }
            }
        }
    
    /***************************************************************************
     * Function :  getErrorLogFromServer
     * Input    :  none
     * Output   :  none
     * Comment  :  Fetches certain flags from server and saves them in user
     *             defaults
     ***************************************************************************/
    
    private func getErrorLogFromServer(){
        
        self.httpComm.httpGetResponseFromPath(url: ERROR_LOG_FTP_PATH){ (response) in
            
            let responseArray = response as? NSArray
            
            if responseArray != nil && (responseArray?.count)! > 0{
                
                let responseDictionary = responseArray![0] as? NSDictionary
                
                if responseDictionary != nil{
                    
//                    let dayMode   = responseDictionary?.object(forKey: "dayMode")               as? NSNumber
//                    let ratMode   = responseDictionary?.object(forKey: "spm_RAT_Mode")          as? NSNumber
//                    let noSpmComm = responseDictionary?.object(forKey: "SPM_Modbus_Connection") as? NSNumber
                    
                    if let noSpmComm = responseDictionary?.object(forKey: "SPM_Modbus_Connection") as? NSNumber{
                        UserDefaults.standard.set(Int(truncating: noSpmComm), forKey:"noSpmComm")
                    }
                    
                    if let ratMode = responseDictionary?.object(forKey: "spm_RAT_Mode") as? NSNumber{
                        UserDefaults.standard.set(Int(truncating: ratMode), forKey: "ratMode")
                    }
                    
//                    if let dayMode   = responseDictionary?.object(forKey: "dayMode") as? NSNumber{
//                        UserDefaults.standard.set(Int(truncating: dayMode), forKey: "dayMode")
//                        self.DAY_MODE = dayMode as! Int
//
//                    }
                }
                
            }else{
                
                //TODO: Show Server Connection Error
                
            }
        }
    }
    
    
    

    
    
    /***************************************************************************
     * Function :  getConnectivityStat
     * Input    :  none
     * Output   :  plcConnectionState:Int , serverConnectionState,serverConnection2State:Int
     * Comment  :
     ***************************************************************************/
    
    public func getConnectivityStat()->(Int,Int,Int,Int){
        
        return (mittlagplcConnectionState,mittlaplcConnectionState,serverConnectionState,serverConnection2State)
        
    }
    
    /***************************************************************************
     * Function :  readBits
     * Input    :  length, startingRegister
     * Output   :  Bool,[AnyObject]
     * Comment  :  Read EBool Bits From PLC and return the Bit Array which will only
     *             containt 1 element if we read single bits
     ***************************************************************************/
    
    func readBits(plcIpAddress:String, length:Int32, startingRegister:Int32, completion:@escaping (Bool,[AnyObject]?)->()){
        
        switch plcIpAddress {
            case MITT_LAG_PLC_IP_ADDRESS:
                lagmodubus?.readBits(from: startingRegister, count: length,success:{ (responseObject) in
                    
                    guard responseObject != nil else{
                 
                        //Send completion handler to the controller that called this function
                        completion(false,nil)
                        
                        //Log the error for debugging purposes on the terminal
                        self.logger.logData(data: "CENTRAL SYSTEM: Empty Array While Reading \(startingRegister) REGISTER")
                        
                        return
                        
                    }
                    
                    //On Success, first we want to make sure we have the total number of response inside the array
                    //We can check that by comparing the count of the objects inside the returned array with the length specified by the program
                    
                    if responseObject!.count == Int(length){
                        
                        completion(true, responseObject as [AnyObject]?)
                        
                    }
                    
                },failure:{ (error) in

                    //Send completion handler to the controller that called this function
                    completion(false,nil)
                    
                    //Log the error for debugging purposes on the terminal
                    self.logger.logData(data: "CENTRAL SYSTEM: READ BITS ERROR -> \(String(describing: error))")
                        
                })
            case MITT_LA_PLC_IP_ADDRESS:
                lamodubus?.readBits(from: startingRegister, count: length,success:{ (responseObject) in
                    
                    guard responseObject != nil else{
                 
                        //Send completion handler to the controller that called this function
                        completion(false,nil)
                        
                        //Log the error for debugging purposes on the terminal
                        self.logger.logData(data: "CENTRAL SYSTEM: Empty Array While Reading \(startingRegister) REGISTER")
                        
                        return
                        
                    }
                    
                    //On Success, first we want to make sure we have the total number of response inside the array
                    //We can check that by comparing the count of the objects inside the returned array with the length specified by the program
                    
                    if responseObject!.count == Int(length){
                        
                        completion(true, responseObject as [AnyObject]?)
                        
                    }
                    
                },failure:{ (error) in

                    //Send completion handler to the controller that called this function
                    completion(false,nil)
                    
                    //Log the error for debugging purposes on the terminal
                    self.logger.logData(data: "CENTRAL SYSTEM: READ BITS ERROR -> \(String(describing: error))")
                        
                })
           default:
               print("Error")
        }
    }
    /***************************************************************************
     * Function :  readRealRegister
     * Input    :  startingRegister, length
     * Output   :  State: (Bool) ,Response: (String)
     * Comment  :  Read real value type registers from PLC
     ***************************************************************************/
    
    func readRealRegister(plcIpAddress:String, register:Int ,length:Int, completion:@escaping (Bool,String)->()){
        
        modubus = ObjectiveLibModbus(tcp: plcIpAddress, port: Int32(PLC_PORT), device: 1)
        
        modubus!.readRegisters(from: Int32(register), count: Int32(length), success:{ (responseArray) in
                                
            guard responseArray != nil else{
                
                //Send completion handler to the controller that called this function
                completion(false,"")
                    
                //Log the error for debugging purposes on the terminal
                self.logger.logData(data: "CENRAL SYSTEM: READ REGISTERS -> Empty Array While Reading \(register) REGISTER")
                    
                return
                    
            }
                
            //Then we want to normalize the data if necessary
            //Them we want to show it on the corresponding screens
            
            let dataWithRealValue = self.modubus!.convertArray(toReal: responseArray)
            
            if dataWithRealValue.description == PLC_REAL_VALUE_ONE{
                completion(true,"0")
            }else{
                completion(true,"\(dataWithRealValue)")
            }
                                
        },failure:{ (error) in
            
            //Send completion handler to the controller that called this function
            completion(false,"")
            
            //Log the error for debugging purposes on the terminal
            self.logger.logData(data: "CENTRAL SYSTEM: READ REGISTERS ERROR -> \(String(describing: error))")
            
        })
    }
    /***************************************************************************
     * Function :  readRegister
     * Input    :  length , starting register address
     * Output   :  completion block with state and response
     * Comment  :
     ***************************************************************************/
    
    func readRegister(plcIpAddress:String, length:Int32, startingRegister:Int32, completion:@escaping (Bool,[AnyObject]?)->()){
        
        switch plcIpAddress {
            case MITT_LAG_PLC_IP_ADDRESS:
               lagmodubus?.readRegisters(from: startingRegister, count: length, success: { (responseObject) in
                    
                    guard responseObject != nil else{

                        //Send completion handler to the controller that called this function
                        completion(false,nil)
                        
                        //Log the error for debugging purposes on the terminal
                        self.logger.logData(data: "CENTRAL SYSTEM: Empty Array While Reading \(startingRegister) REGISTER")
                        
                        return
                        
                    }
                    
                    //On Success, first we want to make sure we have the total number of response inside the array
                    //We can check that by comparing the count of the objects inside the returned array with the length specified by the program
                    
                    if responseObject!.count == Int(length){
                        
                        completion(true, responseObject as [AnyObject]?)
                        
                    }
                    
                },failure:{ (error) in

                    //Send completion handler to the controller that called this function
                    completion(false,nil)
                    
                    //Log the error for debugging purposes on the terminal
                    self.logger.logData(data: "CENTRAL SYSTEM: READ BITS ERROR -> \(String(describing: error))")
                    
                })
            case MITT_LA_PLC_IP_ADDRESS:
                lamodubus?.readRegisters(from: startingRegister, count: length, success: { (responseObject) in
                    
                    guard responseObject != nil else{

                        //Send completion handler to the controller that called this function
                        completion(false,nil)
                        
                        //Log the error for debugging purposes on the terminal
                        self.logger.logData(data: "CENTRAL SYSTEM: Empty Array While Reading \(startingRegister) REGISTER")
                        
                        return
                        
                    }
                    
                    //On Success, first we want to make sure we have the total number of response inside the array
                    //We can check that by comparing the count of the objects inside the returned array with the length specified by the program
                    
                    if responseObject!.count == Int(length){
                        
                        completion(true, responseObject as [AnyObject]?)
                        
                    }
                    
                },failure:{ (error) in

                    //Send completion handler to the controller that called this function
                    completion(false,nil)
                    
                    //Log the error for debugging purposes on the terminal
                    self.logger.logData(data: "CENTRAL SYSTEM: READ BITS ERROR -> \(String(describing: error))")
                    
                })
           default:
               print("Error")
        }
        
    }
    
    /***************************************************************************
     * Function :  writeRealValue
     * Input    :  real value address: Int, value: Float
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    func writeRealValue(plcIpAddress:String, register:Int, value:Float){
        switch plcIpAddress {
            case MITT_LAG_PLC_IP_ADDRESS:
                lagmodubus?.writeReal(Float32(value), Int32(register))
            case MITT_LA_PLC_IP_ADDRESS:
                lamodubus?.writeReal(Float32(value), Int32(register))
           default:
               print("Error")
        }
    }
    
    /***************************************************************************
     * Function :  writeRegister
     * Input    :  register address: Int, value: Int
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    func writeRegister(plcIpAddress:String, register:Int, value:Int){
        
        switch plcIpAddress {
            case MITT_LAG_PLC_IP_ADDRESS:
                lagmodubus?.writeRegister(Int32(register), to: Int32(value), success:{
                print("Lagoon Write Success  \(register) " + "\(value)")
                },failure:{ (error) in
                    
                    self.logger.logData(data: "CENTRAL SYSTEM: FAILED TO WRITE TO PLC REGISTER")
                    
                })
            case MITT_LA_PLC_IP_ADDRESS:
                lamodubus?.writeRegister(Int32(register), to: Int32(value), success:{
                print("Lake Write Success  \(register) " + "\(value)")
                },failure:{ (error) in
                    
                    self.logger.logData(data: "CENTRAL SYSTEM: FAILED TO WRITE TO PLC REGISTER")
                    
                })
           default:
               print("Error")
        }
    }
    
    
    /***************************************************************************
     * Function :  writeBit
     * Input    :  bit: Int, value: Int (1,0)
     * Output   :  none
     * Comment  :  Write Bit To PLC
     ***************************************************************************/
    
    func writeBit(plcIpAddress:String, bit:Int, value:Int){
    
        var bitVal = false
        
        if value == 1{
            bitVal = true
        }else if value == 0{
            bitVal = false
        }
        
        switch plcIpAddress {
            case MITT_LAG_PLC_IP_ADDRESS:
                lagmodubus?.writeBit(Int32(bit), to: bitVal, success:{
                  print("LAGOON Write Success  \(bit) " + "\(bitVal)")
                },failure:{ (error) in
                
                })
            case MITT_LA_PLC_IP_ADDRESS:
                lamodubus?.writeBit(Int32(bit), to: bitVal, success:{
                   print("LAKE Write Success  \(bit) " + "\(bitVal)")
                },failure:{ (error) in
                
                })
           default:
               print("Error")
        }
    }
}
