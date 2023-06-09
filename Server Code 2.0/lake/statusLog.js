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
    var status_AirPressure = [];
    var status_Ethernet = [];
    var fault_ShowStoppers = [];
    var status_GasPressure = [];
    var date = new Date();   

if (PLCConnected){

     //VFD-301
    plc_client.readHoldingRegister(1006,1,function(resp){
        
        if (resp != undefined && resp != null){
            vfd1_faultCode[0] = resp.register[0];
            if (vfd1_faultCode[0]>0){ 
                if(tempfc1 == vfd1_faultCode[0]){}else{
                    tempfc1 = vfd1_faultCode[0];
                    vfdfaultCodeDescription[0] = vfdCode.vfdFaultCodeAnalyzer(301,vfd1_faultCode[0]);
                    watchDog.eventLog("VFD-301 FaultCode:  " +vfd1_faultCode[0] +" Description: "+vfdfaultCodeDescription[0]); 
                }
            } else {
                vfdfaultCodeDescription[0] = "";
                if(tempfc1 == vfd1_faultCode[0]){}else{
                    tempfc1 = vfd1_faultCode[0];
                    watchDog.eventLog("Resolved: VFD-301 Fault");
                } 
            }
        }
    });

    

    plc_client.readCoils(0,11,function(resp1){
        
        if (resp1 != undefined && resp1 != null){  
            // Show Stoppers - lake
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
        
            // EStop - lake

            fault_ESTOP.push(nthBit(resp.register[0],0) ? nthBit(resp.register[0],0) : 0); // CP301 Estop
            fault_ESTOP.push(nthBit(resp.register[2],6) ? nthBit(resp.register[2],6) : 0); // Out_BMS3001A
            fault_ESTOP.push(nthBit(resp.register[2],7) ? nthBit(resp.register[2],7) : 0); // Out_BMS3001B

            // Wind Speed - lake

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

            // Water Quality - lake

            status_WaterQuality.push(nthBit(resp.register[0],9) ? nthBit(resp.register[0],9) : 0);      // Backwash1 Run 
            status_WaterQuality.push(nthBit(resp.register[0],10) ? nthBit(resp.register[0],10) : 0);    // Scheduled Backwash Running 
            status_WaterQuality.push(nthBit(resp.register[0],11) ? nthBit(resp.register[0],11) : 0);    // PDSH1 Run
            status_WaterQuality.push(nthBit(resp.register[0],12) ? nthBit(resp.register[0],12) : 0);    // TDS Above Hi
            status_WaterQuality.push(nthBit(resp.register[0],13) ? nthBit(resp.register[0],13) : 0);    // TDS Channel Fault
            status_WaterQuality.push(nthBit(resp.register[0],14) ? nthBit(resp.register[0],14) : 0);    // PH Above Hi
            status_WaterQuality.push(nthBit(resp.register[0],15) ? nthBit(resp.register[0],15) : 0);    // PH Below Low
            status_WaterQuality.push(nthBit(resp.register[1],0) ? nthBit(resp.register[1],0) : 0);      // PH Channel Fault
            status_WaterQuality.push(nthBit(resp.register[1],1) ? nthBit(resp.register[1],1) : 0);      // ORP Above Hi
            status_WaterQuality.push(nthBit(resp.register[1],2) ? nthBit(resp.register[1],2) : 0);      // ORP Below Low
            status_WaterQuality.push(nthBit(resp.register[1],3) ? nthBit(resp.register[1],3) : 0);      // ORP Channel Fault
            status_WaterQuality.push(nthBit(resp.register[1],4) ? nthBit(resp.register[1],4) : 0);      // Bromine Dosing
            status_WaterQuality.push(nthBit(resp.register[1],5) ? nthBit(resp.register[1],5) : 0);      // Bromine Timeout
            status_WaterQuality.push(nthBit(resp.register[1],6) ? nthBit(resp.register[1],6) : 0);      // FSL6001 Enable

            //Lights - lake
            
            status_LIGHTS.push(nthBit(resp.register[1],7) ? nthBit(resp.register[1],7) : 0);        // LCP301 Status
            status_LIGHTS.push(nthBit(resp.register[1],8) ? nthBit(resp.register[1],8) : 0);        // LCP 301 Sch ON
            status_LIGHTS.push(nthBit(resp.register[1],10) ? nthBit(resp.register[1],10) : 0);      // LCP301 Status
            status_LIGHTS.push(nthBit(resp.register[1],11) ? nthBit(resp.register[1],11) : 0);      // LCP 301 Sch ON

            // Pumps - lake 

            fault_PUMPS.push(nthBit(resp.register[1],13) ? nthBit(resp.register[1],13) : 0);      // VFD 301 NetworkFault (Filtration Pump)
            fault_PUMPS.push(nthBit(resp.register[1],14) ? nthBit(resp.register[1],14) : 0);      // Filtration Pump Sch Enable
            fault_PUMPS.push(nthBit(resp.register[1],15) ? nthBit(resp.register[1],15) : 0);      // Filtration Pump Sch ON
            fault_PUMPS.push(nthBit(resp.register[2],0) ? nthBit(resp.register[2],0) : 0);        // Filtration Pump Sch Run
            fault_PUMPS.push(nthBit(resp.register[2],1) ? nthBit(resp.register[2],1) : 0);        // VFD 301 Pressure Fault
            fault_PUMPS.push(nthBit(resp.register[2],2) ? nthBit(resp.register[2],2) : 0);        // VFD 301 CLeanStrainer Warning

            // Water Level Sensor - lake 

            status_WaterLevel.push(nthBit(resp.register[2],3) ? nthBit(resp.register[2],3) : 0); // LS3001 Above Hi
            status_WaterLevel.push(nthBit(resp.register[2],4) ? nthBit(resp.register[2],4) : 0); // LS3001 Below Low
            status_WaterLevel.push(nthBit(resp.register[2],5) ? nthBit(resp.register[2],5) : 0); // LS3001 Below LowLow

            showStopper = 0;
            for (var i=0; i <= (fault_ShowStoppers.length-1); i++){
                showStopper = showStopper + fault_ShowStoppers[i];
                if(serviceRequired === 1){
                   showStopper = 1; 
                   watchDog.eventLog("ShowStopper:: Service Required 1");
                }
            }   

            if (((date.getMonth() > 3) && (date.getDate() > 29)) || (date.getMonth() > 4)){
                //serviceRequired = 1;
            } else {
                //serviceRequired = 0;
            }   

            totalStatus = [ 
                            fault_ShowStoppers,
                            fault_ESTOP,
                            status_windSensor,
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
                            "CP301 Estop": fault_ESTOP[0],
                            "Out_BMS3001A": fault_ESTOP[1],
                            "Out_BMS3001B": fault_ESTOP[2],
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
                            "LS3001 Above_Hi":status_WaterLevel[0],
                            "LS3001 Below_Low":status_WaterLevel[1],
                            "LS3001 Below_LowLow":status_WaterLevel[2],
                            "****************************WATER QUALITY STATUS*****************" : "5",
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
                            "****************************LIGHTS STATUS********************" : "6",
                            "LCP301 Status": status_LIGHTS[0],
                            "LCP301 Schedule On": status_LIGHTS[1],
                            "LCP302 Status": status_LIGHTS[2],
                            "LCP302 Schedule On": status_LIGHTS[3],
                            "***************************PUMPS STATUS**************************" : "7",
                            "VFD 301 Fault Code":vfd1_faultCode[0],
                            "VFD 301 Network Fault":fault_PUMPS[0],
                            "VFD 301 Schedule Enable": fault_PUMPS[1],
                            "VFD 301 Schedule On": fault_PUMPS[2],
                            "VFD 301 Schedule Run": fault_PUMPS[3],
                            "VFD 301 Pressure Fault":fault_PUMPS[4],
                            "VFD 301 CleanStrainer Warning":fault_PUMPS[5],
                           "****************************DEVICE CONNECTION STATUS*************" : "8",
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

            [   // Show Stopper - lake
                {"yes":"Show Stopper: Estop","no":"Show Stopper Resolved: Estop"},
                {"yes":"Show Stopper: ST1001 Wind_Speed_Abort_Show","no":"Show Stopper Resolved: ST1001 Wind_Speed_Abort_Show"},
                {"yes":"Show Stopper: Water Level Below L","no":"Show Stopper Resolved: Water Level Below L"},
            ],

            [   // estop - lake 
                {"yes":"CP301 Estop Triggered","no":"Resolved: CP301 Estop"}, 
                {"yes":"One/More System Warning","no":"No Warnings"}, 
                {"yes":"One/More System Faults ","no":"No Faults"},
            ],

            [   // anemometer - lake
                {"yes":"ST1001 Direction_Channel_Fault","no":"ST1001 Direction_Channel_Fault Resolved"},
                {"yes":"ST1001 AbortShow","no":"ST1001 AbortShow Resolved"},
                {"yes":"ST1001 Wind Speed Above Hi","no":"ST1001 Wind Above Hi Resolved"},
                {"yes":"ST1001 Wind Speed Above Medium","no":"ST1001 Wind Above Medium Resolved"},
                {"yes":"ST1001 Wind Speed Below Low","no":"ST1001 Wind Below Low Resolved"},
                {"yes":"ST1001 Speed_Channel_Fault","no":"ST1001 Speed_Channel_Fault Resolved"},
                {"yes":"ST1001 Wind Speed NoWind","no":"ST1001 Wind Speed Not in NoWind"},
                {"yes":"Wind Mode in Hand","no":"Wind Mode in Auto"},
                
            ],

            [   //Water Quality Status - lake
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

            [   // lights - lake

                {"yes":"Lights 301 ON","no":"Lights 301 ON"},
                {"yes":"Lights 301 Schedule ON","no":"Lights 301 Schedule OFF"},
                {"yes":"Lights 302 ON","no":"Lights 302 ON"},
                {"yes":"Lights 302 Schedule ON","no":"Lights 302 Schedule OFF"},
            ],

            [   // pumps - lake
                {"yes":"Resolved: P301 Network Fault","no":"P301 Network Fault"},
                {"yes":"Filtration Pump Schedule Enabled","no":"Filtration Pump Schedule Disabled"},
                {"yes":"Filtration Pump Schedule ON","no":"Filtration Pump Schedule OFF"},
                {"yes":"Filtration Pump Schedule Running","no":"Filtration Pump Schedule Not_Running"},
                {"yes":"Resolved: P101 Pressure Fault","no":"P101 Pressure Fault"},
                {"yes":"Resolved: P101 CleanStrainer Warning","no":"P101 CleanStrainer Warning"},
            ],

            [   // water level - lake
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
