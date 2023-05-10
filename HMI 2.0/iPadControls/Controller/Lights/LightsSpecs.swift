//
//  LightsSpecs.swift
//  iPadControls
//
//  Created by Jan Manalo on 9/6/18.
//  Copyright © 2018 WET. All rights reserved.
//

import Foundation


/***************************************************************************
 * Section  :  LIGHTS SPECS
 * Comments :  Use this file to change and write the correct address
 * Note     :  Double check if the read and write server path is correct
 ***************************************************************************/


let LIGHTS_AUTO_HAND_PLC_REGISTER              = 3500
let LIGHTS_STATUS                              = 3500
let LIGHTS_ON_OFF_WRITE_REGISTERS              = 3501

let WATER_LEVE_LSH2001                         = 3103
let SURGE_WATER_LEVEL_BELOW_L                  = 3102
let GLIMMER_WATER_LEVEL_BELOW_L                = 3100
let LIGHTS_DAY_MODE_BTN_UI_TAG_NUMBER          = 15
let LIGHTS_DAY_MODE_CMD                        = "\(HTTP_PASS)\(SERVER_IP_ADDRESS):8080/setDayMode?"
let DAY_MODE_BUTTON_TAG                        = 6
let READ_LIGHT_SERVER_PATH                     = "readLights"
let WRITE_LIGHT_SERVER_PATH                    = "writeLights"
let READ_LAKE_LIGHT_SERVER_PATH                = "readLights"
let WRITE_LAKE_LIGHT_SERVER_PATH               = "writeLights"

let LCP901_AUTO_HAND_PLC_REGISTER              = 3500
let LCP901_ON_OFF_WRITE_REGISTERS              = 3502
let LCP901_STATUS                              = 3503
let LCP902_ON_OFF_WRITE_REGISTERS              = 3504
let LCP902_STATUS                              = 3505

let LIGHTS_LANGUAGE_DATA_PARAM           = "lights"
