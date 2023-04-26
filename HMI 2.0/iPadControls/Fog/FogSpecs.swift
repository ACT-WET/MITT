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

let FOG601_FAULTS                 = (startAddr: 7001, count:6)
let FOG602_FAULTS                 = (startAddr: 7011, count:6)
let FOG603_FAULTS                 = (startAddr: 7021, count:6)
let FOG601_AUTO_HAND_BIT_ADDR     = 7006
let FOG601_PLAY_STOP_BIT_ADDR     = 7000
let FOG602_AUTO_HAND_BIT_ADDR     = 7016
let FOG602_PLAY_STOP_BIT_ADDR     = 7010
let FOG603_AUTO_HAND_BIT_ADDR     = 7026
let FOG603_PLAY_STOP_BIT_ADDR     = 7020
let FOG601_PUMPMODE_ADDR          = 7000
let FOG602_PUMPMODE_ADDR          = 7010
let FOG603_PUMPMODE_ADDR          = 7020
let FOG_LIFTS                = (startAddr: 7030, count:2)

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
