function statusLogWrapper(){

    //console.log("StatusLog script triggered");

    var totalStatus;
    var data = [];
    var status_wof = [];
    var status_windSensor = [];
    var status_pressTransmitter = [];
    var fault_PUMPS = [];
    var status_WaterLevel = [];
    var status_WaterQuality = [];
    var status_LIGHTS = [];
    var fault_ESTOP = [];
    var fault_INTRUSION = [];
    var fault_FOG = [];
    var status_AirPressure = [];
    var status_Ethernet = [];
    var fault_ShowStoppers = [];
    var status_GasPressure = [];
    var bender3AData = [];
    var bender3BData = [];
    var benderAlarm = [];
 
if (BenderConnected){

     bender_client.readInputRegister(528,23,function(resp){
      if (resp != undefined && resp != null){
        bender3AData[0] = back2Float(resp.register[1], resp.register[0]);
        bender3AData[1] = intByte_HiLo(resp.register[2])[1],function(resp){};
        bender3AData[2] = back2Float(resp.register[5], resp.register[4]);
        bender3AData[3] = intByte_HiLo(resp.register[6])[1],function(resp){};
        bender3AData[4] = back2Float(resp.register[9], resp.register[8]);
        bender3AData[5] = intByte_HiLo(resp.register[10])[1],function(resp){};
        bender3AData[6] = back2Float(resp.register[13], resp.register[12]);
        bender3AData[7] = intByte_HiLo(resp.register[14])[1],function(resp){};
        bender3AData[8] = back2Float(resp.register[17], resp.register[16]);
        bender3AData[9] = intByte_HiLo(resp.register[18])[1],function(resp){};
        bender3AData[10] = back2Float(resp.register[21], resp.register[20]);
        bender3AData[11] = intByte_HiLo(resp.register[22])[1],function(resp){};

        plc_client.writeSingleRegister(6000,bender3AData[1],function(resp){});
        plc_client.writeSingleRegister(6001,bender3AData[3],function(resp){});
        plc_client.writeSingleRegister(6002,bender3AData[5],function(resp){});
        plc_client.writeSingleRegister(6003,bender3AData[7],function(resp){});
        plc_client.writeSingleRegister(6004,bender3AData[9],function(resp){});
        plc_client.writeSingleRegister(6005,bender3AData[11],function(resp){});

        // if (playing == 1 && (date.getSeconds()%5 == 0))
        // {
        //    b3_Curr["b31"] = (bender3Data[0]*1000).toFixed(2);
        //    b3_Curr["b32"] = (bender3Data[2]*1000).toFixed(2);
        //    b3_Curr["b33"] = (bender3Data[4]*1000).toFixed(2);
        //    b3_Curr["b34"] = (bender3Data[6]*1000).toFixed(2);
        //    b3_Curr["b35"] = (bender3Data[8]*1000).toFixed(2);
        //    b3_Curr["b36"] = (bender3Data[10]*1000).toFixed(2);
        //    b3_Curr["showNum"] = show;   
        //    b3_Curr["date"] = time;  

        //    b3_Alam["b31"] = bender3Data[1];
        //    b3_Alam["b32"] = bender3Data[3];
        //    b3_Alam["b33"] = bender3Data[5];
        //    b3_Alam["b34"] = bender3Data[7];
        //    b3_Alam["b35"] = bender3Data[9];
        //    b3_Alam["b36"] = bender3Data[11];
        //    b3_Alam["showNum"] = show;   
        //    b3_Alam["date"] = time; 

        //    fs.appendFileSync(homeD+'/UserFiles/b3CurrentData.txt','\n','utf-8');
        //    fs.appendFileSync(homeD+'/UserFiles/b3CurrentData.txt',JSON.stringify(b3_Curr),'utf-8');
        //    fs.appendFileSync(homeD+'/UserFiles/b3AlarmData.txt','\n','utf-8');
        //    fs.appendFileSync(homeD+'/UserFiles/b3AlarmData.txt',JSON.stringify(b3_Alam),'utf-8');
        // }
        
      }      
     });

     bender_client.readInputRegister(552,23,function(resp){
      if (resp != undefined && resp != null){
        bender3BData[0] = back2Float(resp.register[1], resp.register[0]);
        bender3BData[1] = intByte_HiLo(resp.register[2])[1],function(resp){};
        bender3BData[2] = back2Float(resp.register[5], resp.register[4]);
        bender3BData[3] = intByte_HiLo(resp.register[6])[1],function(resp){};
        bender3BData[4] = back2Float(resp.register[9], resp.register[8]);
        bender3BData[5] = intByte_HiLo(resp.register[10])[1],function(resp){};
        bender3BData[6] = back2Float(resp.register[13], resp.register[12]);
        bender3BData[7] = intByte_HiLo(resp.register[14])[1],function(resp){};
        bender3BData[8] = back2Float(resp.register[17], resp.register[16]);
        bender3BData[9] = intByte_HiLo(resp.register[18])[1],function(resp){};
        bender3BData[10] = back2Float(resp.register[21], resp.register[20]);
        bender3BData[11] = intByte_HiLo(resp.register[22])[1],function(resp){};

        plc_client.writeSingleRegister(6006,bender3BData[1],function(resp){});
        plc_client.writeSingleRegister(6007,bender3BData[3],function(resp){});
        plc_client.writeSingleRegister(6008,bender3BData[5],function(resp){});
        plc_client.writeSingleRegister(6009,bender3BData[7],function(resp){});
        plc_client.writeSingleRegister(6010,bender3BData[9],function(resp){});
        plc_client.writeSingleRegister(6011,bender3BData[11],function(resp){});

        // if (playing == 1 && (date.getSeconds()%5 == 0))
        // {
        //    b1_Curr["b11"] = (bender1Data[0]*1000).toFixed(2);
        //    b1_Curr["b12"] = (bender1Data[2]*1000).toFixed(2);
        //    b1_Curr["b13"] = (bender1Data[4]*1000).toFixed(2);
        //    b1_Curr["b14"] = (bender1Data[6]*1000).toFixed(2);
        //    b1_Curr["b15"] = (bender1Data[8]*1000).toFixed(2);
        //    b1_Curr["b16"] = (bender1Data[10]*1000).toFixed(2);
        //    b1_Curr["showNum"] = show;   
        //    b1_Curr["date"] = time;   

        //    b1_Alam["b11"] = bender1Data[1];
        //    b1_Alam["b12"] = bender1Data[3];
        //    b1_Alam["b13"] = bender1Data[5];
        //    b1_Alam["b14"] = bender1Data[7];
        //    b1_Alam["b15"] = bender1Data[9];
        //    b1_Alam["b16"] = bender1Data[11];
        //    b1_Alam["showNum"] = show;   
        //    b1_Alam["date"] = time;   

        //    fs.appendFileSync(homeD+'/UserFiles/b1CurrentData.txt','\n','utf-8');
        //    fs.appendFileSync(homeD+'/UserFiles/b1CurrentData.txt',JSON.stringify(b1_Curr),'utf-8');
        //    fs.appendFileSync(homeD+'/UserFiles/b1AlarmData.txt','\n','utf-8');
        //    fs.appendFileSync(homeD+'/UserFiles/b1AlarmData.txt',JSON.stringify(b1_Alam),'utf-8');
        // }
      }      
     });
}

if (PLCConnected){

     //VFD-101
        if (vfd1_faultCode[0]>0){ 
            if(tempfc1 == vfd1_faultCode[0]){}else{
                tempfc1 = vfd1_faultCode[0];
                vfdfaultCodeDescription[0] = vfdCode.vfdFaultCodeAnalyzer(101,vfd1_faultCode[0]);
                watchDog.eventLog("VFD-101 FaultCode:  " +vfd1_faultCode[0] +" Description: "+vfdfaultCodeDescription[0]); 
            }
        } else {
            vfdfaultCodeDescription[0] = "";
            if(tempfc1 == vfd1_faultCode[0]){}else{
                tempfc1 = vfd1_faultCode[0];
                watchDog.eventLog("Resolved: VFD-101 Fault"); 
            } 
        }


    plc_client.readCoils(6020,12,function(resp){
        
        if (resp != undefined && resp != null){

            benderAlarm.push(resp.coils[0] ? resp.coils[0] : 0);         // Bender 101 AlarmTripped
            benderAlarm.push(resp.coils[1] ? resp.coils[1] : 0);         // Bender 102 AlarmTripped
            benderAlarm.push(resp.coils[2] ? resp.coils[2] : 0);         // Bender 103 AlarmTripped
            benderAlarm.push(resp.coils[3] ? resp.coils[3] : 0);         // Bender 104 AlarmTripped
            benderAlarm.push(resp.coils[4] ? resp.coils[4] : 0);         // Bender 105 AlarmTripped
            benderAlarm.push(resp.coils[5] ? resp.coils[5] : 0);         // Bender 106 AlarmTripped

            benderAlarm.push(resp.coils[6] ? resp.coils[6] : 0);         // Bender 107 AlarmTripped
            benderAlarm.push(resp.coils[7] ? resp.coils[7] : 0);         // Bender 108 AlarmTripped
            benderAlarm.push(resp.coils[8] ? resp.coils[8] : 0);         // Bender 109 AlarmTripped
            benderAlarm.push(resp.coils[9] ? resp.coils[9] : 0);         // Bender 110 AlarmTripped
            benderAlarm.push(resp.coils[10] ? resp.coils[10] : 0);       // Bender 111 AlarmTripped
            benderAlarm.push(resp.coils[11] ? resp.coils[11] : 0);       // Bender 112 AlarmTripped

        }
    });//end of first PLC modbus call

    plc_client.readCoils(0,11,function(resp1){
        
        if (resp1 != undefined && resp1 != null){  
            // Show Stoppers - lagoon
            fault_ShowStoppers.push(resp1.coils[5] ? resp1.coils[5] : 0); // System Estop
            fault_ShowStoppers.push(resp1.coils[6] ? resp1.coils[6] : 0); // WaterLevel ShowStopper
            fault_ShowStoppers.push(resp1.coils[7] ? resp1.coils[7] : 0); // ST1001 Wind ShowStopper
        }
    });//end of first PLC modbus call  

    plc_client.readHoldingRegister(502,1,function(resp){
        
        if (resp != undefined && resp != null){
            autoMan = resp.register[0];
        }
    });
    
    plc_client.readHoldingRegister(100,5,function(resp){
        
        if (resp != undefined && resp != null){
        
            // EStop - lagoon

            fault_ESTOP.push(nthBit(resp.register[0],0) ? nthBit(resp.register[0],0) : 0); // CP301 Estop
            fault_ESTOP.push(nthBit(resp.register[3],6) ? nthBit(resp.register[3],6) : 0); // Out_BMS2001A
            fault_ESTOP.push(nthBit(resp.register[3],7) ? nthBit(resp.register[3],7) : 0); // Out_BMS2001B

            // Wind Speed - lagoon

            status_windSensor.push(nthBit(resp.register[0],1) ? nthBit(resp.register[0],1) : 0); // ST1001_Drctn_Channel_Fault 
            status_windSensor.push(nthBit(resp.register[0],2) ? nthBit(resp.register[0],2) : 0); // ST1001_Abort Show
            status_windSensor.push(nthBit(resp.register[0],3) ? nthBit(resp.register[0],3) : 0); // ST1001_Above_Hi
            status_windSensor.push(nthBit(resp.register[0],4) ? nthBit(resp.register[0],4) : 0); // ST1001_Above_Medium
            status_windSensor.push(nthBit(resp.register[0],5) ? nthBit(resp.register[0],5) : 0); // ST1001_Above_Low
            status_windSensor.push(nthBit(resp.register[0],6) ? nthBit(resp.register[0],6) : 0); // ST1001_Speed_Channel_Fault
            status_windSensor.push(nthBit(resp.register[0],7) ? nthBit(resp.register[0],7) : 0); // ST1001_No_Wind
            status_windSensor.push(nthBit(resp.register[0],8) ? nthBit(resp.register[0],8) : 0); // WindMode_HA 


            windHi = status_windSensor[2];
            windMed = status_windSensor[3];
            windLo = status_windSensor[4];
            windNo = status_windSensor[6];
            windHA = status_windSensor[7];

            //Fog - lagoon

            fault_FOG.push(nthBit(resp.register[0],9) ? nthBit(resp.register[0],9) : 0);          // FS113 HA Mode
            fault_FOG.push(nthBit(resp.register[0],10) ? nthBit(resp.register[0],10) : 0);        // FS113 Hand ON
            fault_FOG.push(nthBit(resp.register[0],11) ? nthBit(resp.register[0],11) : 0);        // FS113 Running

            // Water Quality - lagoon

            status_WaterQuality.push(nthBit(resp.register[0],12) ? nthBit(resp.register[0],12) : 0); // Backwash1 Run 
            status_WaterQuality.push(nthBit(resp.register[0],13) ? nthBit(resp.register[0],13) : 0); // Scheduled Backwash Running 
            status_WaterQuality.push(nthBit(resp.register[0],14) ? nthBit(resp.register[0],14) : 0); // PDSH1 Run
            status_WaterQuality.push(nthBit(resp.register[0],15) ? nthBit(resp.register[0],15) : 0); // TDS Above Hi
            status_WaterQuality.push(nthBit(resp.register[1],0) ? nthBit(resp.register[1],0) : 0);   // TDS Channel Fault
            status_WaterQuality.push(nthBit(resp.register[1],1) ? nthBit(resp.register[1],1) : 0);   // PH Above Hi
            status_WaterQuality.push(nthBit(resp.register[1],2) ? nthBit(resp.register[1],2) : 0);   // PH Below Low
            status_WaterQuality.push(nthBit(resp.register[1],3) ? nthBit(resp.register[1],3) : 0);   // PH Channel Fault
            status_WaterQuality.push(nthBit(resp.register[1],4) ? nthBit(resp.register[1],4) : 0);   // ORP Above Hi
            status_WaterQuality.push(nthBit(resp.register[1],5) ? nthBit(resp.register[1],5) : 0);   // ORP Below Low
            status_WaterQuality.push(nthBit(resp.register[1],6) ? nthBit(resp.register[1],6) : 0);   // ORP Channel Fault
            status_WaterQuality.push(nthBit(resp.register[1],7) ? nthBit(resp.register[1],7) : 0);   // Bromine Dosing
            status_WaterQuality.push(nthBit(resp.register[1],8) ? nthBit(resp.register[1],8) : 0);   // Bromine Timeout
            status_WaterQuality.push(nthBit(resp.register[1],9) ? nthBit(resp.register[1],9) : 0);   // FSL6001 Enable

            // Lights - lagoon 
            
            status_LIGHTS.push(nthBit(resp.register[1],10) ? nthBit(resp.register[1],10) : 0);    // LCP201 ON 
            status_LIGHTS.push(nthBit(resp.register[1],13) ? nthBit(resp.register[1],13) : 0);    // LCP202 ON  

            // Pumps - lagoon 

            fault_PUMPS.push(nthBit(resp.register[2],0) ? nthBit(resp.register[2],0) : 0);      // VFD 101 NetworkFault (Filtration Pump)
            fault_PUMPS.push(nthBit(resp.register[2],1) ? nthBit(resp.register[2],1) : 0);      // VFD 101 Pump Sch Enable
            fault_PUMPS.push(nthBit(resp.register[2],2) ? nthBit(resp.register[2],2) : 0);      // VFD 101 Pump Sch ON
            fault_PUMPS.push(nthBit(resp.register[2],3) ? nthBit(resp.register[2],3) : 0);      // VFD 101 Pump Sch Run
            fault_PUMPS.push(nthBit(resp.register[2],4) ? nthBit(resp.register[2],4) : 0);      // VFD 101 Pressure Fault
            fault_PUMPS.push(nthBit(resp.register[2],5) ? nthBit(resp.register[2],5) : 0);      // VFD 101 CLeanStrainer Warning

            fault_PUMPS.push(nthBit(resp.register[2],6) ? nthBit(resp.register[2],6) : 0);      // YS201 GFCI Tripped
            fault_PUMPS.push(nthBit(resp.register[2],7) ? nthBit(resp.register[2],7) : 0);      // YS202 GFCI Tripped
            fault_PUMPS.push(nthBit(resp.register[2],8) ? nthBit(resp.register[2],8) : 0);      // YS203 GFCI Tripped
            fault_PUMPS.push(nthBit(resp.register[2],9) ? nthBit(resp.register[2],9) : 0);      // YS204 GFCI Tripped
            fault_PUMPS.push(nthBit(resp.register[2],10) ? nthBit(resp.register[2],10) : 0);    // YS205 GFCI Tripped
            fault_PUMPS.push(nthBit(resp.register[2],11) ? nthBit(resp.register[2],11) : 0);    // YS206 GFCI Tripped
            fault_PUMPS.push(nthBit(resp.register[2],12) ? nthBit(resp.register[2],12) : 0);    // YS207 GFCI Tripped
            fault_PUMPS.push(nthBit(resp.register[2],13) ? nthBit(resp.register[2],13) : 0);    // YS208 GFCI Tripped
            fault_PUMPS.push(nthBit(resp.register[2],14) ? nthBit(resp.register[2],14) : 0);    // YS209 GFCI Tripped
            fault_PUMPS.push(nthBit(resp.register[2],15) ? nthBit(resp.register[2],15) : 0);    // YS210 GFCI Tripped
            fault_PUMPS.push(nthBit(resp.register[3],0) ? nthBit(resp.register[3],0) : 0);      // YS211 GFCI Tripped
            fault_PUMPS.push(nthBit(resp.register[3],1) ? nthBit(resp.register[3],1) : 0);      // YS212 GFCI Tripped

            fault_PUMPS.push(nthBit(resp.register[4],0) ? nthBit(resp.register[2],0) : 0);      // Skimmer Pump Sch Enable
            fault_PUMPS.push(nthBit(resp.register[4],1) ? nthBit(resp.register[2],1) : 0);      // Skimmer Pump Sch ON
            fault_PUMPS.push(nthBit(resp.register[4],2) ? nthBit(resp.register[2],2) : 0);      // Skimmer Pump Sch Run

            // Water Level Sensor - lagoon 

            status_WaterLevel.push(nthBit(resp.register[3],3) ? nthBit(resp.register[3],3) : 0); // LS2001 Above Hi
            status_WaterLevel.push(nthBit(resp.register[3],4) ? nthBit(resp.register[3],4) : 0); // LS2001 Below Low
            status_WaterLevel.push(nthBit(resp.register[3],5) ? nthBit(resp.register[3],5) : 0); // LS2001 Below LowLow

            showStopper = 0;
            for (var i=0; i <= (fault_ShowStoppers.length-1); i++){
                showStopper = showStopper + fault_ShowStoppers[i];
            }   

            totalStatus = [ 
                            fault_ShowStoppers,
                            fault_ESTOP,
                            status_windSensor,
                            fault_FOG,
                            status_WaterQuality,
                            status_LIGHTS,
                            fault_PUMPS,
                            status_WaterLevel];

            totalStatus = bool2int(totalStatus);

            if (devStatus.length > 1) {
                logChanges(totalStatus); // detects change of total status
            }

            devStatus = totalStatus; // makes the total status equal to the current error state

            // creates the status array that is sent to the iPad (via errorLog) AND logged to file
            sysStatus = [{
                            "***************************ESTOP STATUS**************************" : "1",
                            "CP601 Estop": fault_ESTOP[0],
                            "Out_BMS2001A": fault_ESTOP[1],
                            "Out_BMS2001B": fault_ESTOP[2],
                            "ShowStopper :Estop": fault_ShowStoppers[0],
                            "ShowStopper :WaterLevelLow": fault_ShowStoppers[1],
                            "ShowStopper :ST1001 Wind_Abort": fault_ShowStoppers[2],
                            "***************************SHOW STATUS***************************" : "2",
                            "Show PlayMode": autoMan,
                            "Show PlayStatus":playing,
                            "CurrentShow Number":show,
                            "deflate":deflate,
                            "NextShowTime": nxtTime,
                            "NextShowNumber": nxtShow,
                            "timeLastCmnd": timeLastCmnd,
                            "SPM_RAT_Mode":Boolean(spmRATMode),
                            "JumpToStepAuto": jumpToStep_auto,
                            "JumpToStepManual": jumpToStep_manual,
                            "SPM: DayMode Status":dayModeStatus,
                            "iPad Scheduler: DayMode Status":dayMode,
                            "****************************WIND STATUS********************" : "3",
                            "ST1001 Direction_Channel_Fault": status_windSensor[0],
                            "ST1001 Abort_Show": status_windSensor[1],
                            "ST1001 Above_Hi": status_windSensor[2],
                            "ST1001 Above_Med": status_windSensor[3],
                            "ST1001 Below_Low": status_windSensor[4],
                            "ST1001 No_Wind": status_windSensor[5],
                            "ST1001 Speed_Channel_Fault": status_windSensor[6],
                            "ST1001 Wind Mode": status_windSensor[7],
                             "****************************WATERLEVEL STATUS********************" : "4",
                            "LS2001 Above_Hi":status_WaterLevel[0],
                            "LS2001 Below_Low":status_WaterLevel[1],
                            "LS2001 Below_LowLow":status_WaterLevel[2],
                            "***************************BENDER STATUS**************************" : "5",
                            "BENDER 1 3-PHASE CURRENT DATA":bender3AData[0],
                            "BENDER 1 3-PHASE ALARM DATA":bender3AData[1],
                            "BENDER 2 3-PHASE CURRENT DATA":bender3AData[2],
                            "BENDER 2 3-PHASE ALARM DATA":bender3AData[3],
                            "BENDER 3 3-PHASE CURRENT DATA":bender3AData[4],
                            "BENDER 3 3-PHASE ALARM DATA":bender3AData[5],
                            "BENDER 4 3-PHASE CURRENT DATA":bender3AData[6],
                            "BENDER 4 3-PHASE ALARM DATA":bender3AData[7],
                            "BENDER 5 3-PHASE CURRENT DATA":bender3AData[8],
                            "BENDER 5 3-PHASE ALARM DATA":bender3AData[9],
                            "BENDER 6 3-PHASE CURRENT DATA":bender3AData[10],
                            "BENDER 6 3-PHASE ALARM DATA":bender3AData[11],
                            "BENDER 7 3-PHASE CURRENT DATA":bender3BData[0],
                            "BENDER 7 3-PHASE ALARM DATA":bender3BData[1],
                            "BENDER 8 3-PHASE CURRENT DATA":bender3BData[2],
                            "BENDER 8 3-PHASE ALARM DATA":bender3BData[3],
                            "BENDER 9 3-PHASE CURRENT DATA":bender3BData[4],
                            "BENDER 9 3-PHASE ALARM DATA":bender3BData[5],
                            "BENDER 10 3-PHASE CURRENT DATA":bender3BData[6],
                            "BENDER 10 3-PHASE ALARM DATA":bender3BData[7],
                            "BENDER 11 3-PHASE CURRENT DATA":bender3BData[8],
                            "BENDER 11 3-PHASE ALARM DATA":bender3BData[9],
                            "BENDER 12 3-PHASE CURRENT DATA":bender3BData[10],
                            "BENDER 12 3-PHASE ALARM DATA":bender3BData[11],
                            "BENDER 1 3-PHASE ALARM TRIPPED":benderAlarm[0],
                            "BENDER 2 3-PHASE ALARM TRIPPED":benderAlarm[1],
                            "BENDER 3 3-PHASE ALARM TRIPPED":benderAlarm[2],
                            "BENDER 4 3-PHASE ALARM TRIPPED":benderAlarm[3],
                            "BENDER 5 3-PHASE ALARM TRIPPED":benderAlarm[4],
                            "BENDER 6 3-PHASE ALARM TRIPPED":benderAlarm[5],
                            "BENDER 7 3-PHASE ALARM TRIPPED":benderAlarm[6],
                            "BENDER 8 3-PHASE ALARM TRIPPED":benderAlarm[7],
                            "BENDER 9 3-PHASE ALARM TRIPPED":benderAlarm[8],
                            "BENDER 10 3-PHASE ALARM TRIPPED":benderAlarm[9],
                            "BENDER 11 3-PHASE ALARM TRIPPED":benderAlarm[10],
                            "BENDER 12 3-PHASE ALARM TRIPPED":benderAlarm[11],
                            "****************************WATER QUALITY STATUS*****************" : "6",
                            "Backwash1 Run": status_WaterQuality[0],
                            "Schedule Backwash Trigger": status_WaterQuality[1],
                            "PDSH1": status_WaterQuality[2],
                            "TDS Above Hi": status_WaterQuality[3],
                            "TDS ChannelFault": status_WaterQuality[4],
                            "PH Above Hi": status_WaterQuality[5],
                            "PH Below Low": status_WaterQuality[6],
                            "PH ChannelFault": status_WaterQuality[7],
                            "ORP Above Hi": status_WaterQuality[8],
                            "ORP Below Low": status_WaterQuality[9],
                            "ORP ChannelFault": status_WaterQuality[10],
                            "Bromine Dosing": status_WaterQuality[11],
                            "Bromine Timeout": status_WaterQuality[12],
                            "WaterFlow Bromine Enabled": status_WaterQuality[13],
                            "****************************FOG STATUS*****************" : "7",
                            "FS113 HA Mode": fault_FOG[0],
                            "FS113 Hand On": fault_FOG[1],
                            "FS113 Running": fault_FOG[5],
                            "****************************LIGHTS STATUS*****************" : "9",
                            "MicroShooter Lights ON": status_LIGHTS[0],
                            "Oarsman Lights ON": status_LIGHTS[1],
                            "***************************PUMPS STATUS**************************" : "10",
                            "VFD 101 Schedule Enable": fault_PUMPS[1],
                            "VFD 101 Schedule On": fault_PUMPS[2],
                            "VFD 101 Schedule Run": fault_PUMPS[3],
                            "Skimmer Pump Schedule Enable": fault_PUMPS[18],
                            "Skimmer Pump Schedule On": fault_PUMPS[19],
                            "Skimmer Pump Schedule Run": fault_PUMPS[20],
                            "VFD 101 Fault Code":vfd1_faultCode[0],
                            "VFD 101 Network Fault":fault_PUMPS[0],
                            "VFD 101 Pressure Fault":fault_PUMPS[4],
                            "VFD 101 CleanStrainer Warning":fault_PUMPS[5],
                            "YS201 GFCI TRIPPED":fault_PUMPS[6],
                            "YS202 GFCI TRIPPED":fault_PUMPS[7],
                            "YS203 GFCI TRIPPED":fault_PUMPS[8],
                            "YS204 GFCI TRIPPED":fault_PUMPS[9],
                            "YS205 GFCI TRIPPED":fault_PUMPS[10],
                            "YS206 GFCI TRIPPED":fault_PUMPS[11],
                            "YS207 GFCI TRIPPED":fault_PUMPS[12],
                            "YS208 GFCI TRIPPED":fault_PUMPS[13],
                            "YS209 GFCI TRIPPED":fault_PUMPS[14],
                            "YS210 GFCI TRIPPED":fault_PUMPS[15],
                            "YS211 GFCI TRIPPED":fault_PUMPS[16],
                            "YS212 GFCI TRIPPED":fault_PUMPS[17],
                           "****************************DEVICE CONNECTION STATUS*************" : "11",
                            "SPM_Heartbeat": SPM_Heartbeat,
                            "SPM_Modbus_Connection": SPMConnected,
                            "PLC_Heartbeat": PLC_Heartbeat,
                            "PLC_Modbus_Connection": PLCConnected,
                           
                            }];

            playStatus = [{
                            "Play Mode": autoMan,
                            "play status":playing,
                            "Current Show":show,
                            "Current Show Name": shows[show].name,
                            "Current Show Duration":shows[show].duration,
                            "Show Type":showType,
                            "deflate":deflate,
                            "show time remaining": showTime_remaining,
                            "Service Required": serviceRequired,
                            "next Show Time": nxtTime,
                            "next Show Num": nxtShow
                            }];
                            
            playMode_init = {"autoMan":autoMan};

            fs.writeFileSync(homeD+'/UserFiles/playMode.txt',JSON.stringify(playMode_init),'utf-8');
            fs.writeFileSync(homeD+'/UserFiles/playModeBkp.txt',JSON.stringify(playMode_init),'utf-8');
        
        
        }
    });//end of first PLC modbus call
}

if (SPMConnected){

    if(autoMan===1){
       plc_client.writeSingleCoil(4,1,function(resp){});
    }
    else{
      plc_client.writeSingleCoil(4,0,function(resp){});
    }

}

    // compares current state to previous state to log differences
    function logChanges(currentState){
        // {"yes":"n/a","no":"n/a"} object template for detection but no logging... "n/a" disables log
        // {"yes":"positive edge message","no":"negative edge message"} object template for detection and logging
        // pattern of statements must match devStatus and totalStatus format
        var statements=[

            [   // Show Stopper - lagoon
                {"yes":"Show Stopper: Estop","no":"Show Stopper Resolved: Estop"},
                {"yes":"Show Stopper: ST1001 Wind_Speed_Abort_Show","no":"Show Stopper Resolved: ST1001 Wind_Speed_Abort_Show"},
                {"yes":"Show Stopper: Water Level Below L","no":"Show Stopper Resolved: Water Level Below L"},
            ],

            [   // estop - lagoon 
                {"yes":"CP601 Estop Triggered","no":"Resolved: CP601 Estop"}, 
                {"yes":"One/More System Warning","no":"No Warnings"}, 
                {"yes":"One/More System Faults ","no":"No Faults"},
            ],

            [   // anemometer - lagoon
                {"yes":"ST1001 Direction_Channel_Fault","no":"ST1001 Direction_Channel_Fault Resolved"},
                {"yes":"ST1001 AbortShow","no":"ST1001 AbortShow Resolved"},
                {"yes":"ST1001 Wind Speed Above Hi","no":"ST1001 Wind Above Hi Resolved"},
                {"yes":"ST1001 Wind Speed Above Medium","no":"ST1001 Wind Above Medium Resolved"},
                {"yes":"ST1001 Wind Speed Below Low","no":"ST1001 Wind Below Low Resolved"},
                {"yes":"ST1001 Speed_Channel_Fault","no":"ST1001 Speed_Channel_Fault Resolved"},
                {"yes":"ST1001 Wind Speed NoWind","no":"ST1001 Wind Speed Not in NoWind"},
                {"yes":"Wind Mode in Hand","no":"Wind Mode in Auto"},
                
            ],

            [   //Fog Status - lagoon
                {"yes":"Fog Hand Mode","no":"Fog Auto Mode"},
                {"yes":"Fog Hand On","no":"Fog Hand Off"},
                {"yes":"Fog Pump Running","no":"Fog Pump Stopped"},
            ],

            [   //Water Quality Status - lagoon
                {"yes":"Backwash 1 Running","no":"Backwash 1 Ended"},
                {"yes":"Scheduled Backwash Running","no":"Scheduled Backwash Ended"}, 
                {"yes":"PDSH1 Triggered Backwash","no":"PDSH1 Triggered Backwash Ended"},
                {"yes":"TDS AboveHi","no":"Resolved: TDS Above Hi Alarm "},
                {"yes":"TDS Channel Fault","no":"Resolved: TDS Channel Fault"},
                {"yes":"PH AboveHi","no":"Resolved: PH Above Hi Alarm "},
                {"yes":"PH Below_Low","no":"Resolved: PH Below Low Alarm "},
                {"yes":"PH Channel Fault","no":"Resolved: PH Channel Fault"},
                {"yes":"ORP AboveHi","no":"Resolved: ORP Above Hi Alarm "},
                {"yes":"ORP Below_Low","no":"Resolved: ORP Below Low Alarm "},
                {"yes":"ORP Channel Fault","no":"Resolved: ORP Channel Fault"},
                {"yes":"Bromine Dosing ON","no":"Bromine Dosing OFF"},
                {"yes":"Bromine Timeout","no":"Resolved:Bromine Timeout"},
                {"yes":"FSL 6001 WaterFlow Enabled","no":"FSL 6001 WaterFlow Disabled"},
            ],

            [   // Lights Status - lagoon
                {"yes":"Microshooter Lights On","no":"Microshooter Lights Off"},
                {"yes":"Oarsman Lights On","no":"Oarsman Lights Off"},
            ],

            [   // pumps - lagoon
                {"yes":"Resolved: P101 Network Fault","no":"P101 Network Fault"},
                {"yes":"Filtration Pump Schedule Enabled","no":"Filtration Pump Schedule Disabled"},
                {"yes":"Filtration Pump Schedule ON","no":"Filtration Pump Schedule OFF"},
                {"yes":"Filtration Pump Schedule Running","no":"Filtration Pump Schedule Not_Running"},
                {"yes":"Resolved: P101 Pressure Fault","no":"P101 Pressure Fault"},
                {"yes":"Resolved: P101 CleanStrainer Warning","no":"P101 CleanStrainer Warning"},
                {"yes":"Resolved: YS201 GFCI Tripped","no":"YS201 GFCI Tripped"},
                {"yes":"Resolved: YS202 GFCI Tripped","no":"YS202 GFCI Tripped"},
                {"yes":"Resolved: YS203 GFCI Tripped","no":"YS203 GFCI Tripped"},
                {"yes":"Resolved: YS204 GFCI Tripped","no":"YS204 GFCI Tripped"},
                {"yes":"Resolved: YS205 GFCI Tripped","no":"YS205 GFCI Tripped"},
                {"yes":"Resolved: YS206 GFCI Tripped","no":"YS206 GFCI Tripped"},
                {"yes":"Resolved: YS207 GFCI Tripped","no":"YS207 GFCI Tripped"},
                {"yes":"Resolved: YS208 GFCI Tripped","no":"YS208 GFCI Tripped"},
                {"yes":"Resolved: YS209 GFCI Tripped","no":"YS209 GFCI Tripped"},
                {"yes":"Resolved: YS210 GFCI Tripped","no":"YS210 GFCI Tripped"},
                {"yes":"Resolved: YS211 GFCI Tripped","no":"YS211 GFCI Tripped"},
                {"yes":"Resolved: YS212 GFCI Tripped","no":"YS212 GFCI Tripped"},
                {"yes":"Skimmer Pump Schedule Enabled","no":"Skimmer Pump Schedule Disabled"},
                {"yes":"Skimmer Pump Schedule ON","no":"Skimmer Pump Schedule OFF"},
                {"yes":"Skimmer Pump Schedule Running","no":"Skimmer Pump Schedule Not_Running"},
            ],

            [   // water level - lagoon
                {"yes":"LS2001 AboveHi","no":"Resolved: LS2001 AboveHi Alarm"},
                {"yes":"LS2001 Below_Low","no":"Resolved: LS2001 Below_Low Alarm"},
                {"yes":"LS2001 Below_LowLow","no":"Resolved: LS2001 Below_LowLow Alarm"},
                
            ]
        ];
        
        if (devStatus.length > 0) {
            for(var each in currentState){
                // find all indeces with values different from previous examination
                var suspects = kompare(currentState[each],devStatus[each]);
                for(var each2 in suspects){
                    var text = (currentState[each][suspects[each2]]) ? statements[each][suspects[each2]].yes:statements[each][suspects[each2]].no;
                    var description = "";
                    var message = "";
                    var category = "";
                    if(text !== "n/a"){
                        //watchDog.eventLog('each: ' +each +' and each2: ' +each2+' and suspcts: ' +suspects);
                        watchDog.eventLog(text);
                        watchLog.eventLog(text);
                    }
                }
            }
        }

    }

    // returns the value of the bth bit of n
    function nthBit(n,b){
        var here = 1 << b;
        if (here & n){
            return 1;
        }
        return 0;
    }

    function intByte_HiLo(query){
        var loByte = 0;
        for(var i = 0; i < 8; i++){
            loByte = loByte + (nthBit(query,i)* Math.pow(2, i));
        }
        var hiByte = 0;
        for(var i = 8; i < 16; i++){
            hiByte = hiByte + (nthBit(query,i)* Math.pow(2, i-8));
        }
        var byte_arr = [];
        byte_arr[0] = loByte;
        byte_arr[1] = hiByte;
        return byte_arr;
    }

    // converts up to 11-bit binary (including 0 bit) to decimal
    function oddByte(fruit){
        var min=0;
        for (k=0;k<11;k++){
            if(nthBit(fruit,k)){min+=Math.pow(2,k);}
        }
        return min;
    }

    // general function that will help DEEP compare arrays
    function kompare (array1,array2) {
        var collisions = [];

        for (var i = 0, l=array1.length; i < l; i++) {
            // Check if we have nested arrays
            if (array1[i] instanceof Array && array2[i] instanceof Array) {
                // recurse into the nested arrays
                if (!kompare(array1[i],array2[i])){
                    return [false];
                }
            }
            else if (array1[i] !== array2[i]) {
                // Warning - two different object instances will never be equal: {x:20} != {x:20}
                collisions.push(i);
            }
        }

        return collisions;
    }


    //check and execute only once
    function checkUpdatedValue(oldValue,newValue,pumpNumber){
        // watchDog.eventLog("oldValue  :::   "+oldValue);
        // watchDog.eventLog("newValue  :::   "+newValue);
        if(newValue==oldValue){
            return 0;
        } else {
            vfdCode.vfdFaultCodeAnalyzer(pumpNumber,newValue);
            return 1;
        }
    }


    // convert boolean to int
    function bool2int(array){
        for (var each in array) {
            // Check if we have nested arrays
            if (array[each] instanceof Array) {
                // recurse into the nested arrays
                array[each] = bool2int(array[each]);
            }
            else {
                // Warning - two different object instances will never be equal: {x:20} != {x:20}
                array[each] = (array[each]) ? 1 : 0;
            }
        }
        return array;
    }

    function back2Float(low, high){
        var fpnum=low|(high<<16);
        var negative=(fpnum>>31)&1;
        var exponent=(fpnum>>23)&0xFF;
        var mantissa=(fpnum&0x7FFFFF);
        
        if(exponent==255){
         
            if(mantissa!==0)return Number.NaN;
            return (negative) ? Number.NEGATIVE_INFINITY :Number.POSITIVE_INFINITY;
        
        }
        
        if(exponent===0)exponent++;
        else mantissa|=0x800000;
        
        exponent-=127;
        var ret=(mantissa*1.0/0x800000)*Math.pow(2,exponent);
        
        if(negative)ret=-ret;
        return ret;
    }
}

module.exports=statusLogWrapper;
