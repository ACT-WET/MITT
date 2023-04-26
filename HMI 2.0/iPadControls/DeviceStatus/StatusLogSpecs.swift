//
//  StatusLogspecs.swift
//  iPadControls
//
//  Created by Rak on 3/28/20.
//  Copyright © 2019 WET. All rights reserved.
//

import Foundation


/*
 let showStoppereStop = responseDictionary!["ShowStopper :Estop"] as? Int,
 let showStopperwind = responseDictionary!["ShowStopper :High Speed Wind Abort"] as? Int,
 let showStopperwater = responseDictionary!["ShowStopper :WaterLevelLow"] as? Int,
 
 let wf1lights = responseDictionary!["WF-1 Lights Off"] as? Int,
 let wf2lights = responseDictionary!["WF-2 Lights Off"] as? Int,
 let wf3lights = responseDictionary!["WF-3 Lights Off"] as? Int,
 let wf4lights = responseDictionary!["WF-4 Lights Off"] as? Int,
 let wf5lights = responseDictionary!["WF-5 Lights Off"] as? Int,
 let wf6lights = responseDictionary!["WF-6 Lights Off"] as? Int,
 let lights101 = responseDictionary!["LCP 101 Relay OFF"] as? Int,
 let lights102A = responseDictionary!["LCP 102A Relay OFF"] as? Int,
 let lights102B = responseDictionary!["LCP 102B Relay OFF"] as? Int,
 
 let pumpFault1101 =responseDictionary!["VFD 1101 Pump Fault"] as? Int,
 let pumpFault1102 =responseDictionary!["VFD 1102 Pump Fault"] as? Int,
 let pumpFault1301 =responseDictionary!["VFD 1301 Pump Fault"] as? Int,
 let pumpFault1302 =responseDictionary!["VFD 1302 Pump Fault"] as? Int,
 let pumpFault1303 =responseDictionary!["VFD 1303 Pump Fault"] as? Int,
 let pumpFault1401 =responseDictionary!["VFD 1401 Pump Fault"] as? Int,
 let pumpFault1402 =responseDictionary!["VFD 1402 Pump Fault"] as? Int,
 let pumpFault1501 =responseDictionary!["VFD 1501 Pump Fault"] as? Int,
 let pumpFault1502 =responseDictionary!["VFD 1502 Pump Fault"] as? Int,
 let pumpFault1503 =responseDictionary!["VFD 1503 Pump Fault"] as? Int,
 let pumpFault1601 =responseDictionary!["VFD 1601 Pump Fault"] as? Int,
 let pumpFault1602 =responseDictionary!["VFD 1602 Pump Fault"] as? Int,
 let pressFault1101 =responseDictionary!["VFD 1101 Pressure Fault"] as? Int,
 let pressFault1102 =responseDictionary!["VFD 1102 Pressure Fault"] as? Int,
 let pressFault1301 =responseDictionary!["VFD 1301 Pressure Fault"] as? Int,
 let pressFault1302 =responseDictionary!["VFD 1302 Pressure Fault"] as? Int,
 let pressFault1303 =responseDictionary!["VFD 1303 Pressure Fault"] as? Int,
 let pressFault1401 =responseDictionary!["VFD 1401 Pressure Fault"] as? Int,
 let pressFault1402 =responseDictionary!["VFD 1402 Pressure Fault"] as? Int,
 let pressFault1501 =responseDictionary!["VFD 1501 Pressure Fault"] as? Int,
 let pressFault1502 =responseDictionary!["VFD 1502 Pressure Fault"] as? Int,
 let pressFault1503 =responseDictionary!["VFD 1503 Pressure Fault"] as? Int,
 let pressFault1601 =responseDictionary!["VFD 1601 Pressure Fault"] as? Int,
 let pressFault1602 =responseDictionary!["VFD 1602 Pressure Fault"] as? Int,
 
 let ls1101belowLL = responseDictionary!["LS1101 Below_LL"] as? Int,
 let ls1201belowLL = responseDictionary!["LS1201 Below_LL"] as? Int,
 let ls1301belowLL = responseDictionary!["LS1301 Below_LL"] as? Int,
 let ls1401belowLL = responseDictionary!["LS1401 Below_LL"] as? Int,
 let ls1501belowLL = responseDictionary!["LS1501 Below_LL"] as? Int,
 let ls1601belowLL = responseDictionary!["LS1601 Below_LL"] as? Int,
 let ls1201makeupOn = responseDictionary!["LS1201 WaterMakeup On/Off"] as? Int,
 let ls1201makeupTimeout = responseDictionary!["LS1201 WaterMakeup Timeout"] as? Int,
 let lt1001makeupTimeout = responseDictionary!["LT1001 WaterMakeup Timeout"] as? Int,
 let lt1001makeupOn = responseDictionary!["LT1001 WaterMakeup On/Off"] as? Int,
 
 let ph1ChFault = responseDictionary!["pH1: Channel_Fault"] as? Int,
 let ph1AbvHi = responseDictionary!["pH1: AboveHi"] as? Int,
 let ph1belowL = responseDictionary!["pH1: Below_Low"] as? Int,
 let orp1ChFault = responseDictionary!["ORP1: Channel_Fault"] as? Int,
 let orp1AbvHi = responseDictionary!["ORP1: AboveHi"] as? Int,
 let orp1belowL = responseDictionary!["ORP1: Below_Low"] as? Int,
 let tds1ChFault = responseDictionary!["TDS1: Channel_Fault"] as? Int,
 let tds1AbvHi = responseDictionary!["TDS1: AboveHi"] as? Int,
 let tds1belowL = responseDictionary!["TDS1: Below_Low"] as? Int,
 let ph2ChFault = responseDictionary!["pH2: Channel_Fault"] as? Int,
 let ph2AbvHi = responseDictionary!["pH2: AboveHi"] as? Int,
 let ph2belowL = responseDictionary!["pH2: Below_Low"] as? Int,
 let orp2ChFault = responseDictionary!["ORP2: Channel_Fault"] as? Int,
 let orp2AbvHi = responseDictionary!["ORP2: AboveHi"] as? Int,
 let orp2belowL = responseDictionary!["ORP2: Below_Low"] as? Int,
 let tds2ChFault = responseDictionary!["TDS2: Channel_Fault"] as? Int,
 let tds2AbvHi = responseDictionary!["TDS2: AboveHi"] as? Int,
 let tds2belowL = responseDictionary!["TDS2: Below_Low"] as? Int,
 let bw1Running = responseDictionary![""BackwashRunning WF-13456"] as? Int,
 let bw2Running = responseDictionary![""BackwashRunning WF-2"] as? Int,
 let pressFault1001 = responseDictionary!["VFD 1001 Pressure Fault"] as? Int,
 let pressFault1201 = responseDictionary!["VFD 1201 Pressure Fault"] as? Int,
 let pumpFault1001 = responseDictionary!["VFD 1001 Pump Fault"] as? Int,
 let pumpFault1201 = responseDictionary!["VFD 1201 Pump Fault"] as? Int,

 
 
 
 let windAbvHi = responseDictionary!["Wind_AboveHi"] as? Int,
 let windbelowL = responseDictionary!["Wind_BelowLow"] as? Int,
 let windspeedFault = responseDictionary!["Wind: SpeedFault"] as? Int,
 let windDirectionFault = responseDictionary!["Wind: DirectionFault"] as? Int,
 
 let fs101pumpOverload = responseDictionary!["FS101 PumpOverload"] as? Int,
 let fs101pumpFault = responseDictionary!["FS101 Pump Fault"] as? Int,
 let fs101pressFault = responseDictionary!["FS101 Pressure Fault"] as? Int,
 let fs102pumpOverload = responseDictionary!["FS102 PumpOverload"] as? Int,
 let fs102pumpFault = responseDictionary!["FS102 Pump Fault"] as? Int,
 let fs102pressFault = responseDictionary!["FS102 Pressure Fault"] as? Int,
 
 let sysWarning = responseDictionary!["SYSTEM WARNINGS"] as? Int,
 let sysFault = responseDictionary!["SYSTEM FAULTS"] as? Int,
 let spmRatmode = responseDictionary!["SPM RAT MODE"] as? Int,
 let winterizeMode = responseDictionary!["Winterize Mode"] as? Int,
 let playMode = responseDictionary!["Show PlayMode"] as? Int,
 
*/

