//
//  FogSpecs.swift
//  iPadControls
//
//  Created by Jan Manalo on 9/10/18.
//  Copyright © 2018 WET. All rights reserved.
//

import Foundation

/***************************************************************************
 * Section  :  FOG SPECS
 * Comments :  Use this file to change and write the correct address
 ***************************************************************************/

let FOG113_AUTO_HAND_BIT_ADDR     = 7006
let FOG113_PLAY_STOP_BIT_ADDR     = 7000
let FOG113_PUMP_RUNNING           = 7000

let FOG_JOCKEYPUMP_TRIGGER     = 6523


struct FOG_MOTOR_LIVE_VALUES{
    
    var pumpStart     = 0
    var pumpRunning   = 0
    var pumpShutdown  = 0
    var pumpOverLoad  = 0
    var pumpFault     = 0
    var pumpMode      = 0
    var panelMode     = 0
    var cleanStrainer   = 0
}
