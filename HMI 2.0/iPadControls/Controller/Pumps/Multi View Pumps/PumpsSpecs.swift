//
//  AnimationPumpsSpecs.swift
//  iPadControls
//
//  Created by Jan Manalo on 9/10/18.
//  Copyright © 2018 WET. All rights reserved.
//

import Foundation

let PUMPS_LANGUAGE_DATA_PARAM                    = "pumps"

//=============== Animation Pumps

let PUMPS_AUTO_HAND_PLC_REGISTER                 = (register: 49, type:"REGISTER", name:"All Pumps Auto")
let PUMP_SPEED_INDICATOR_READ_LIMIT              = 2

let PUMP_SETS                       = [PUMP_SET_A, PUMP_SET_B]
let PUMP_DETAILS_SETS               = [PUMP_DETAILS_SPECS_SET_A, PUMP_DETAILS_SPECS_SET_B]

let PUMP_SET_A = [
    
    (register:1, type:"INT", name: "iPad1_PumpNumber"),
    (register:2, type:"INT", name: "Manual_Speed"),
    (register:3, type:"INT", name: "Output_Freq"),
    (register:4, type:"INT", name: "Current"),
    (register:5, type:"INT", name: "Voltage"),
    (register:6, type:"INT", name: "Temperature"),
    (register:7, type:"INT", name: "Auto_Mode"),
    (register:8, type:"INT", name: "Manual_Mode"),
    (register:9, type:"INT", name: "Manual_Start"),
    (register:10, type:"INT", name: "Mode_Feedback"),
    (register:11, type:"INT", name: "Man_Speed2"),
    (register:13, type:"INT", name: "Press Fault"),
    (register:14, type:"INT", name: "VFD Fault"),
    (register:15, type:"INT", name: "GFCI Fault")
    
]

let PUMP_SET_B = [
    
    (register:21, type:"INT", name: "iPad2_PumpNumber"),
    (register:22, type:"INT", name: "Manual_Speed"),
    (register:23, type:"INT", name: "Output_Freq"),
    (register:24, type:"INT", name: "Current"),
    (register:25, type:"INT", name: "Voltage"),
    (register:26, type:"INT", name: "Temperature"),
    (register:27, type:"INT", name: "Auto_Mode"),
    (register:28, type:"INT", name: "Manual_Mode"),
    (register:29, type:"INT", name: "Manual_Start"),
    (register:30, type:"INT", name: "Mode_Feedback"),
    (register:31, type:"INT", name: "Man_Speed2"),
    (register:33, type:"INT", name: "Press Fault"),
    (register:34, type:"INT", name: "VFD Fault"),
    (register:35, type:"INT", name: "GFCI Fault")
    
]


let PUMP_DETAILS_SPECS_SET_A = [
    
    (register:13, type:"INT", name: "HZ_Max"),
    (register:14, type:"INT", name: "Voltage_Max"),
    (register:15, type:"INT", name: "Voltage_Min"),
    (register:16, type:"INT", name: "Current_Max"),
    (register:17, type:"INT", name: "Temperature_Max")
    
]

let PUMP_DETAILS_SPECS_SET_B = [
    
    (register:33, type:"INT", name: "HZ_Max"),
    (register:34, type:"INT", name: "Voltage_Max"),
    (register:35, type:"INT", name: "Voltage_Min"),
    (register:36, type:"INT", name: "Current_Max"),
    (register:37, type:"INT", name: "Temperature_Max")
    
]


let PUMP_FAULT_SET = [
    (tag: 200, bitwiseLocation: 0, type:"INT", name: "Pump Fault"),
    (tag: 201, bitwiseLocation: 1, type:"INT", name: "Press Fault"),
    (tag: 202, bitwiseLocation: 2, type:"INT", name: "VFD Fault"),
    (tag: 203, bitwiseLocation: 3, type:"INT", name: "GFCI Fault"),
    (tag: 204, bitwiseLocation: 4, type:"INT", name: "Network Fault"),
    (tag: 205, bitwiseLocation: 5, type:"INT", name: "Mode Feedback"),
    (tag: 206, bitwiseLocation: 6, type:"INT", name: "CleanStrainer Warning"),
    (tag: 207, bitwiseLocation: 7, type:"INT", name: "Run Status"),
    (tag: 208, bitwiseLocation: 8, type:"INT", name: "Low Water Level"),
    (tag: 209, bitwiseLocation: 9, type:"INT", name: "Low Flow Fault")
]



//ANIMATION PUMPS REGISTERS 22 - 40

let WEIR_PUMP_EN                   = 2113
let WEIR_PUMP_SCH_BIT              = 2115

let WALL_1_SURGE_PUMPS_FAULT_STATUS_START_REGISTER = 1008
let WALL_1_SURGE_PUMPS_RUNNING_STATUS_START_REGISTER = 1004

let WALL_2_SURGE_PUMPS_FAULT_STATUS_START_REGISTER = 1288
let WALL_2_SURGE_PUMPS_RUNNING_STATUS_START_REGISTER = 1284

let WALL_3_SURGE_PUMPS_FAULT_STATUS_START_REGISTER = 1428
let WALL_3_SURGE_PUMPS_RUNNING_STATUS_START_REGISTER = 1424

let READ_WEIR_SERVER_PATH             = "readWeirPumpSch"
let WRITE_WEIR_SERVER_PATH            = "writeWeirPumpSch"

let DISPLAY_PUMPS_FAULT_STATUS_START_REGISTER = 1092
let CASCADE_PUMPS_FAULT_STATUS_START_REGISTER = 1008
let SURGE_PUMPS_FAULT_STATUS_START_REGISTER   = 1120
let EAST_WEST_ZONE_STATUS_REGISTER = 3021
let WEST_MOTOR_STARTER_REGISTER = 2257
let EAST_MOTOR_STARTER_REGISTER = 2262
let PUMP_PLAY_STOP_BIT_ADDR_109     = 5001
let PUMP_PLAY_STOP_BIT_ADDR_110     = 5003
let PUMP_101_RUNSTATUS_REGISTER     = 1004

let PUMPS_RUNNING_STATUS_START_REGISTER = 1004
let PUMPS_FAULT_STATUS_START_REGISTER = 1008

let SURGEPUMPS_RUNNING_STATUS_START_REGISTER = 1018
let SURGEPUMPS_FAULT_STATUS_START_REGISTER = 1022

let GLIMMERPUMPS_RUNNING_STATUS_START_REGISTER = 1018
let GLIMMERPUMPS_FAULT_STATUS_START_REGISTER = 1022

let ALIGHTPUMPS_RUNNING_STATUS_START_REGISTER = 1004
let ALIGHTPUMPS_FAULT_STATUS_START_REGISTER = 1008

let DELUGEPUMPS_RUNNING_STATUS_START_REGISTER = 1018
let DELUGEPUMPS_FAULT_STATUS_START_REGISTER = 1022

let ANIMATION_PUMPS_STATUS_REGING_COUNT   = 1

let PUMPS_XIB_NAME              = "pumps"


var VOLTAGE_RANGE               = 250.0
let MIN_PIXEL                   = 700.0
let MAX_PIXEL                   = 25.0
let SLIDER_PIXEL_RANGE          = 450.0


//ANIMATION PUMP SETPOINT SPECS: REGISTER TYPE: REAL - WRITE/READ

let MAX_FREQUENCY_SP            = 2000
let MAX_TEMPERATURE_SP          = 2002
let MID_TEMPERATURE_SP          = 2004
let MAX_VOLTAGE_SP              = 2008
let MIN_VOLTAGE_SP              = 2010
let MAX_CURRENT_SP              = 2012

let PRESSURE_DELAYTIMER         = 6500
let PDSH_DELAYTIMER             = 6518

let SURGE_PUMP_SETPOINTS     = 3021
let PUMPSETPOINTSPEED        = 1007

