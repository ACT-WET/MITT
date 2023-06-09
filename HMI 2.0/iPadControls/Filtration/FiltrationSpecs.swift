//
//  FiltrationSpecs.swift
//  iPadControls
//
//  Created by Jan Manalo on 9/10/18.
//  Copyright © 2018 WET. All rights reserved.
//

import Foundation

/***************************************************************************
 * Section  :  FILTRATION SPECS
 * Comments :  Use this file to change and write the correct address
 * Note     :  Double check if the read and write server path is correct
 ***************************************************************************/

let READ_BACK_WASH1                              = "\(HTTP_PASS)\(SERVER_IP_ADDRESS):8080/readBW"
let READ_SURGEBACK_WASH1                              = "\(HTTP_PASS)\(SERVER_IP_ADDRESS):8080/readSBW"
let READ_GLIMBACK_WASH1                              = "\(HTTP_PASS)\(SERVER_IP_ADDRESS):8080/readGBW"
let READ_LAKEBACK_WASH1                              = "\(HTTP_PASS)\(SERVER_IP2_ADDRESS):8080/readBW"
let FILTRATION_PUMP_NUMBERS                     = [113,114]

let READ_FILTRATION_SERVER_PATH               = "readFilterSch"
let WRITE_FILTRATION_SERVER_PATH              = "writeFilterSch"

let READ_SKIMMER_SERVER_PATH               = "readWeirPumpSch"
let WRITE_SKIMMER_SERVER_PATH              = "writeWeirPumpSch"

let SKIMMER_PUMP_EN                = 2110
let SKIMMER_PUMP_SCH_BIT           = 2112

let SS_AUTOHAND         = 945
let SS_HANDCMD          = 946

let READ_ALIGHTBACK_WASH1                              = "\(HTTP_PASS)\(SERVER_IP2_ADDRESS):8080/readABW"

let FILTRATION_PUMP_EN                = 2115
let FILTRATION_PUMP_SCH_BIT           = 2117

let FILTRATION_RUNNING_BIT            = 2121

let FILTRATION_STATUS                           = (register: 2013,type:"EBOOL", count: 1)
let FILTRATION_ON_OFF_WRITE_REGISTERS           = [2012]
let FILTRATION_AUTO_HAND_PLC_REGISTER           = (register: 2010,type:"EBOOL", name: "Filtration_Auto_Man_mode")

/* SHOWN ON BACKWASH TAB ON EXCEL */
let FILTRATION_STRAINERSP_REGISTER              = 4100 //
let FILTRATION_PUMPOFF_REGISTER                 = 4101 //
let FILTRATION_BWPRESSSP_REGISTER               = 4102 //

let FILTRATION_BW_DURATION_REGISTER             = 6516 // BW_Duration_SP
let FILTRATION_TOGGLE_BWASH_BIT                 = 4002 // BW1_Server_Trigger
let FILTRATION_TOGGLE_BWASH_BIT2                = 4004 // BW2_Server_Trigger
let FILTRATION_TOGGLE_BWASH_BIT3                = 4006 // BW3_Server_Trigger
let FILTRATION_BWASH_RUNNING_BIT                = 4001 // BW1_Running
let FILTRATION_BWASH_RUNNING_BIT_W2             = 4003 // BW2_Running
let FILTRATION_BWASH_RUNNING_BIT_W3             = 4005 // BW3_Running
let FILTRATION_PDSH_DELAY                       = 6518
let FAN_HELD_DELAY                              = 6508
let SURGEFILTRATION_TOGGLE_BWASH_BIT            = 4002 // BW1_Server_Trigger
let SURGEFILTRATION_BWASH_RUNNING_BIT           = 4001 // BW1_Running

let ALIGHTFILTRATION_TOGGLE_BWASH_BIT            = 4002 // BW1_Server_Trigger
let ALIGHTFILTRATION_BWASH_RUNNING_BIT           = 4001 // BW1_Running

let GLIMFILTRATION_TOGGLE_BWASH_BIT            = 4002 // BW1_Server_Trigger
let GLIMFILTRATION_BWASH_RUNNING_BIT           = 4001 // BW1_Running
let FILTRATION_VALVE_OPEN_CLOSE_TIME_BIT        = 6520 // Modified Timer/Times Tab on Spreadsheet. Check T_BW_Value
let FILTRATION_PUMP_FAULT                       = 1232

/* SHOWN ON PUMPS TAB ON EXCEL -- SHOULD SAY FILTRATION */
let FILTRATION_BWASH_SPEED_REGISTERS            = [1231] // Check BW_Speed address
let FILTRATION_PUMP_SPEED_ADDRESSESS            = [1225] // Use this if the fountain doesn't use the pump template, else we write pump number to read/write speed

/* SHOWN ON STRAINER TAB ON EXCEL -- SHOULD SAY FILTRATION */
let FILTRATION_CLEAN_STRAINER_START_BIT         = 4500 // Check spread sheet, see what's the first register
let FILTRATION_CLEAN_STRAINER_BIT_COUNT         = 1    // How many clean strainer does it have. Modify function that use this accordingly
let CONVERTED_FREQUENCY_LIMIT                   = 500  // Change to 600 if limit is 60 hertz. Change to 500 if limit is 50 hertz
let CONVERTED_BW_SPEED_LIMIT                    = 500  // Change to 600 if limit is 60 hertz. Change to 500 if limit is 50 hertz

/* MISC */
let FILTRATION_PIXEL_PER_BACKWASH               = 258.0 / 50.0
let PIXEL_PER_FREQUENCY                         = 258.0 / 50.0
let FILTRATION_PIXEL_PER_MANUAL_SPEED           = 258.0 / 50.0
let FILTRATION_PUMP_SPEED_INDICATOR_READ_LIMIT  = 2
let FILTRATION_BW_SPEED_INDICATOR_READ_LIMIT    = 2
let FILTRATION_PIXEL_PER_FREQUENCY              = 50.0 / 258.0
let CONVERTED_FILTRATION_PIXEL_PER_FREQUENCY    = Float(String(format: "%.2f", FILTRATION_PIXEL_PER_FREQUENCY))
let CONVERTED_FILTRATION_PIXEL_PER_BW           = Float(String(format: "%.2f", FILTRATION_PIXEL_PER_FREQUENCY))
let MAX_FILTRATION_BACKWASH_SPEED               = 50.0
let MAX_FILTRATION_FREQUENCY                    = 50.0
let DAY_PICKER_DATA_SOURCE                      = ["SUNDAY","MONDAY","TUESDAY","WEDNESDAY","THURSDAY","FRIDAY","SATURDAY"]


let READ_SURGEFILTER_SERVER_PATH         = "readSurgeFilterPumpSch"
let WRITE_SURGEFILTER_SERVER_PATH        = "writeSurgeFilterPumpSch"
let READ_SURGEWW_SERVER_PATH             = "readSurgeWWPumpSch"
let WRITE_SURGEWW_SERVER_PATH            = "writeSurgeWWPumpSch"

let SURGEFILTRATION_PUMP_EN        = 2110
let SURGEWW_PUMP_EN                = 2113


let READ_GLIMMER_FILTER_SERVER_PATH         = "readGlimFilterPumpSch"
let WRITE_GLIMMER_FILTER_SERVER_PATH        = "writeGlimFilterPumpSch"
let READ_GLIMMERWEIR_SERVER_PATH            = "readGlimWeirPumpSch"
let WRITE_GLIMMERWEIR_SERVER_PATH           = "writeGlimWeirPumpSch"
let READ_GLIMMERWC_SERVER_PATH              = "readGlimWcPumpSch"
let WRITE_GLIMMERWC_SERVER_PATH             = "writeGlimWcPumpSch"
let READ_GLIMMERFIRE_SERVER_PATH            = "readGlimFireSch"
let WRITE_GLIMMERFIRE_SERVER_PATH           = "writeGlimFireSch"

let GLIMMERFILTRATION_PUMP_EN      = 2110
let GLIMMERWC_PUMP_EN              = 2116
let GLIMMERWEIR_PUMP_EN            = 2113
let GLIMMERFIRE_EN                 = 6029

let PT501_LEVEL_SCALED_VALUE            = 4100
let PT501_LEVEL_SCALED_MIN              = 4102
let PT501_LEVEL_SCALED_MAX              = 4104
let PT501_LEVEL_BELOW_LL                = 4112
let PT501_LEVEL_BELOW_L                 = 4114
let PT501_ABOVE_HI                      = 4116

let READ_LAKE_FILTER_SERVER_PATH         = "readLakeFilterSch"
let WRITE_LAKE_FILTER_SERVER_PATH        = "writeLakeFilterSch"
let READ_LAKE_PUMPSCH_PATH                = "readPumpSch"
let WRITE_LAKE_PUMPSCH_PATH               = "writePumpSch"

let READ_DELUGE_FILTER_SERVER_PATH         = "readDelugeFilterPumpSch"
let WRITE_DELUGE_FILTER_SERVER_PATH        = "writeDelugeFilterPumpSch"
let READ_DELUGEDISP_SERVER_PATH            = "readDelugeDispPumpSch"
let WRITE_DELUGEDISP_SERVER_PATH           = "writeDelugeDispPumpSch"

let DELUGEFILTRATION_PUMP_EN      = 2110
let DELUGEDISP_PUMP_EN            = 2113

let ALIGHTFILTRATION_PUMP_EN      = 2116
let ALIGHTWW_PUMP_EN              = 2110
let ALIGHTWEIR_PUMP_EN            = 2113

let FILT1101_AUTO_HAND_BIT_ADDR     = 2251
let FILT1101_PLAY_STOP_BIT_ADDR     = 2252
let FILT1101_FAULTS                 = (startAddr: 2254, count:5)
let PT1001_SCALEDVAL                = 4104
let PT1002_SCALEDVAL                = 4110
let PT1003_SCALEDVAL                = 4116

let PT1001_SCALEDMAX                = 4108
let PT1002_SCALEDMAX                = 4114
let PT1003_SCALEDMAX                = 4120

let PT1001_SCALEDMIN                = 4106
let PT1002_SCALEDMIN                = 4112
let PT1003_SCALEDMIN                = 4118

let CLEANSTR_SP                = 4100
let FILTER_PUMPOFF_SP          = 4101
let BW_PRESS_SP                = 4102

let LT5201_SCALEDVAL = 3080
let LT5201_FAULTS    = 3080
