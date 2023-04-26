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
    var status_Fire = [];

    
if (ATALPLCConnected){

     atalplc_client.readHoldingRegister(1006,71,function(resp){
      if (resp != undefined && resp != null){

        //P201
        if(checkUpdatedValue(vfd1_faultCode[0],resp.register[0],201)){
           vfd1_faultCode[0] = resp.register[0];
        }

        //P202
        if(checkUpdatedValue(vfd1_faultCode[1],resp.register[14],202)){
           vfd1_faultCode[1] = resp.register[14];
        }

        //P203
        if(checkUpdatedValue(vfd1_faultCode[2],resp.register[28],203)){
           vfd1_faultCode[2] = resp.register[28];
        }

        //P204
        if(checkUpdatedValue(vfd1_faultCode[3],resp.register[42],204)){
           vfd1_faultCode[3] = resp.register[42];
        }

        //P205
        if(checkUpdatedValue(vfd1_faultCode[4],resp.register[56],205)){
           vfd1_faultCode[4] = resp.register[56];
        }

        //P206
        if(checkUpdatedValue(vfd1_faultCode[5],resp.register[70],206)){
           vfd1_faultCode[5] = resp.register[70];
        }

      }      
    });

    atalplc_client.readCoils(935,1,function(resp){
        
        if (resp != undefined && resp != null){
            status_Fire.push(resp.coils[0] ? resp.coils[0] : 0); // SS Alarm
            
            if (ss401Alarm !== resp.coils[0]){

               ss401Alarm = resp.coils[0];
               atalplc_client.readHoldingRegister(940,4,function(resp){
                 if (resp != undefined && resp != null){
                   watchDog.eventLog("SS 401 Value is ::   "+ss401Alarm);
                   watchDog.eventLog("M 940 Value is ::   "+resp.register[0]);
                   watchDog.eventLog("M 941 Value is ::   "+resp.register[1]);
                   watchDog.eventLog("M 942 Value is ::   "+resp.register[2]);
                   watchDog.eventLog("M 943 Value is ::   "+resp.register[3]);
                 }      
               });
               
            }
        }
    });//end of first PLC modbus call

    atalplc_client.readHoldingRegister(940,4,function(resp){
      if (resp != undefined && resp != null){
        var kv1501vc = nthBit(resp.register[0],0);
        var kv1502vc = nthBit(resp.register[0],1);
        var kv1503vc = nthBit(resp.register[0],2);
        var kv1504vc = nthBit(resp.register[0],3);
        var kv1502vo = nthBit(resp.register[0],4);
        var kv1503vo = nthBit(resp.register[0],5);
        var kv1502fo = nthBit(resp.register[0],6);
        var kv1502fc = nthBit(resp.register[0],7);
        var kv1503fo = nthBit(resp.register[0],8);
        var kv1503fc = nthBit(resp.register[0],9);
        var estop = nthBit(resp.register[0],10);
        var pslFault = nthBit(resp.register[0],11);
        var pshFault = nthBit(resp.register[0],12);
        var lel1501abvH = nthBit(resp.register[0],13);
        var lel1502abvH = nthBit(resp.register[0],14);
        var lel1503abvH = nthBit(resp.register[0],15);

        var lel1504abvH = nthBit(resp.register[1],0);
        var lel1505abvH = nthBit(resp.register[1],1);
        var intrusion = nthBit(resp.register[1],2);
        var f1ANR = nthBit(resp.register[1],3);
        var f1BNR = nthBit(resp.register[1],4);
        var f2ANR = nthBit(resp.register[1],5);
        var f2BNR = nthBit(resp.register[1],6);
        var f1ATr = nthBit(resp.register[1],7);
        var f1BTr = nthBit(resp.register[1],8);
        var f2ATr = nthBit(resp.register[1],9);
        var f2BTr = nthBit(resp.register[1],10);
        var fs1501NF = nthBit(resp.register[1],11);
        var fs1502NF = nthBit(resp.register[1],12);
        var psl1401 = nthBit(resp.register[1],13);

        var t1000F = nthBit(resp.register[2],0);
        var t2000F = nthBit(resp.register[2],1);
        var t3000F = nthBit(resp.register[2],2);
        var t4000F = nthBit(resp.register[2],3);
        var t1001H = nthBit(resp.register[2],4);
        var t1002H = nthBit(resp.register[2],5);
        var t1003H = nthBit(resp.register[2],6);
        var t2001H = nthBit(resp.register[2],7);
        var t2002H = nthBit(resp.register[2],8);
        var t2003H = nthBit(resp.register[2],9);
        var t3001H = nthBit(resp.register[2],10);
        var t3002H = nthBit(resp.register[2],11);
        var t3003H = nthBit(resp.register[2],12);
        var t4001H = nthBit(resp.register[2],13);
        var t4002H = nthBit(resp.register[2],14);
        var t4003H = nthBit(resp.register[2],15);
        
        var fsh1201FS = nthBit(resp.register[3],0);
        var fsh1202FS = nthBit(resp.register[3],1);
        var fsh1203FS = nthBit(resp.register[3],2);
        var fsh1204FS = nthBit(resp.register[3],3);

        status_Fire.push(kv1501vc ? kv1501vc : 0); //kv1501 Valve Closed
        status_Fire.push(kv1502vc ? kv1502vc : 0); //kv1502 Valve Closed
        status_Fire.push(kv1503vc ? kv1503vc : 0); //kv1503 Valve Closed
        status_Fire.push(kv1504vc ? kv1504vc : 0); //kv1504 Valve Closed
        status_Fire.push(kv1502vo ? kv1502vo : 0); //kv1502 Valve Open
        status_Fire.push(kv1503vo ? kv1503vo : 0); //kv1503 Valve Open
        status_Fire.push(kv1502fo ? kv1502fo : 0); //kv1502 Fail To Open
        status_Fire.push(kv1502fc ? kv1502fc : 0); //kv1502 Fail To Close
        status_Fire.push(kv1503fo ? kv1503fo : 0); //kv1503 Fail To Open
        status_Fire.push(kv1503fc ? kv1503fc : 0); //kv1503 Fail To Close
        status_Fire.push(estop ? estop : 0); //Estop
        status_Fire.push(pslFault ? pslFault : 0); //PSL Fault
        status_Fire.push(pshFault ? pshFault : 0); //PSH Fault
        status_Fire.push(lel1501abvH ? lel1501abvH : 0); //LEL 1501 Above Hi
        status_Fire.push(lel1502abvH ? lel1502abvH : 0); //LEL 1502 Above Hi
        status_Fire.push(lel1503abvH ? lel1503abvH : 0); //LEL 1503 Above Hi

        status_Fire.push(lel1504abvH ? lel1504abvH : 0); //LEL 1504 Above Hi
        status_Fire.push(lel1505abvH ? lel1505abvH : 0); //LEL 1505 Above Hi
        status_Fire.push(intrusion ? intrusion : 0); //Intrusion Alarm
        status_Fire.push(f1ANR ? f1ANR : 0); //Fan 1A Not Running
        status_Fire.push(f1BNR ? f1BNR : 0); //Fan 1B Not Running
        status_Fire.push(f2ANR ? f2ANR : 0); //Fan 2A Not Running
        status_Fire.push(f2BNR ? f2BNR : 0); //Fan 2B Not Running
        status_Fire.push(f1ATr ? f1ATr : 0); //Fan 1A Tripped
        status_Fire.push(f1BTr ? f1BTr : 0); //Fan 1B Tripped
        status_Fire.push(f2ATr ? f2ATr : 0); //Fan 2A Tripped
        status_Fire.push(f2BTr ? f2BTr : 0); //Fan 2B Tripped
        status_Fire.push(fs1501NF ? fs1501NF : 0); //FS 1501 No Flow alarm
        status_Fire.push(fs1502NF ? fs1502NF : 0); //FS 1502 No Flow alarm
        status_Fire.push(psl1401 ? psl1401 : 0); //PSL1401 Air Receiver Alarm

        status_Fire.push(t1000F ? t1000F : 0); //Temperature 1000 Fault
        status_Fire.push(t2000F ? t2000F : 0); //Temperature 2000 Fault
        status_Fire.push(t3000F ? t3000F : 0); //Temperature 3000 Fault
        status_Fire.push(t4000F ? t4000F : 0); //Temperature 4000 Fault
        status_Fire.push(t1001H ? t1001H : 0); //Temperature 1001 High
        status_Fire.push(t1002H ? t1002H : 0); //Temperature 1002 High
        status_Fire.push(t1003H ? t1003H : 0); //Temperature 1003 High
        status_Fire.push(t2001H ? t2001H : 0); //Temperature 2001 High
        status_Fire.push(t2002H ? t2002H : 0); //Temperature 2002 High
        status_Fire.push(t2003H ? t2003H : 0); //Temperature 2003 High
        status_Fire.push(t3001H ? t3001H : 0); //Temperature 3001 High
        status_Fire.push(t3002H ? t3002H : 0); //Temperature 3002 High
        status_Fire.push(t3003H ? t3003H : 0); //Temperature 3003 High
        status_Fire.push(t4001H ? t4001H : 0); //Temperature 4001 High
        status_Fire.push(t4002H ? t4002H : 0); //Temperature 4002 High
        status_Fire.push(t4003H ? t4003H : 0); //Temperature 4003 High


        status_Fire.push(fsh1201FS ? fsh1201FS : 0); //FSH 1201 Flow Switch Alarm
        status_Fire.push(fsh1202FS ? fsh1202FS : 0); //FSH 1202 Flow Switch Alarm
        status_Fire.push(fsh1203FS ? fsh1203FS : 0); //FSH 1203 Flow Switch Alarm
        status_Fire.push(fsh1204FS ? fsh1204FS : 0); //FSH 1204 Flow Switch Alarm
        
      }      
    });
    
    atalplc_client.readCoils(0,10,function(resp){
        
        if (resp != undefined && resp != null){

            // Show Stoppers - atal
            fault_ShowStoppers.push(resp.coils[5] ? resp.coils[5] : 0); // System Estop
            fault_ShowStoppers.push(resp.coils[6] ? resp.coils[6] : 0); // SS_401 Alarm
            fault_ShowStoppers.push(resp.coils[7] ? resp.coils[7] : 0); // LT1101 or LT2101 Below LLL

            showStopper = 0;
            for (var i=0; i <= (fault_ShowStoppers.length-1); i++){
                showStopper = showStopper + fault_ShowStoppers[i];
            }   

            totalStatus = [ 
                            fault_ShowStoppers,
                            status_Fire
                          ];

            totalStatus = bool2int(totalStatus);

            if (devStatus.length > 1) {
                logChanges(totalStatus); // detects change of total status
            }

            devStatus = totalStatus; // makes the total status equal to the current error state

            // creates the status array that is sent to the iPad (via errorLog) AND logged to file
            sysStatus = [{
                            "***************************ESTOP STATUS**************************" : "1",
                            "ShowStopper :Estop": fault_ShowStoppers[0],
                            "ShowStopper :SS_401": fault_ShowStoppers[1],
                            "ShowStopper :Water Level": fault_ShowStoppers[2],
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
                            "DayMode Status":dayModeStatus,
                            "***************************PUMPS STATUS**************************" : "3",
                            "ATAL VFD 201 Fault Code":vfd1_faultCode[0],
                            "ATAL VFD 202 Fault Code":vfd1_faultCode[1],
                            "ATAL VFD 203 Fault Code":vfd1_faultCode[2],
                            "ATAL VFD 204 Fault Code":vfd1_faultCode[3],
                            "ATAL VFD 205 Fault Code":vfd1_faultCode[4],
                            "ATAL VFD 206 Fault Code":vfd1_faultCode[5],
                            "***************************SUPERVISORY STATUS**************************" : "4",
                            "ATAL Supervisory Station in Alarm":status_Fire[0],
                            "KV1501 Valve Closed":status_Fire[1],
                            "KV1502 Valve Closed":status_Fire[2],
                            "KV1503 Valve Closed":status_Fire[3],
                            "KV1504 Valve Closed":status_Fire[4],
                            "KV1502 Valve Open":status_Fire[5],
                            "KV1503 Valve Open":status_Fire[6],
                            "KV1502 FailTo Open":status_Fire[7],
                            "KV1502 FailTo Close":status_Fire[8],
                            "KV1503 FailTo Open":status_Fire[9],
                            "KV1503 FailTo Close":status_Fire[10],
                            "Estop":status_Fire[11],
                            "PSL Fault":status_Fire[12],
                            "PSH Fault":status_Fire[13],
                            "LEL 1501 Above Hi":status_Fire[14],
                            "LEL 1502 Above Hi":status_Fire[15],
                            "LEL 1503 Above Hi":status_Fire[16],
                            "LEL 1504 Above Hi":status_Fire[17],
                            "LEL 1505 Above Hi":status_Fire[18],
                            "Intrusion":status_Fire[19],
                            "Fan 1A Not Running":status_Fire[20],
                            "Fan 1B Not Running":status_Fire[21],
                            "Fan 2A Not Running":status_Fire[22],
                            "Fan 2B Not Running":status_Fire[23],
                            "Fan 1A Tripped":status_Fire[24],
                            "Fan 1B Tripped":status_Fire[25],
                            "Fan 2A Tripped":status_Fire[26],
                            "Fan 2B Tripped":status_Fire[27],
                            "FS 1501 No Flow Alarm":status_Fire[28],
                            "FS 1502 No Flow Alarm":status_Fire[29],
                            "PSL 1401 Air Receiver Alarm":status_Fire[30],
                            "Temperature 1000 Fault":status_Fire[31],
                            "Temperature 2000 Fault":status_Fire[32],
                            "Temperature 3000 Fault":status_Fire[33],
                            "Temperature 4000 Fault":status_Fire[34],
                            "Temperature 1001 High":status_Fire[35],
                            "Temperature 1002 High":status_Fire[36],
                            "Temperature 1003 High":status_Fire[37],
                            "Temperature 2001 High":status_Fire[38],
                            "Temperature 2002 High":status_Fire[39],
                            "Temperature 2003 High":status_Fire[40],
                            "Temperature 3001 High":status_Fire[41],
                            "Temperature 3002 High":status_Fire[42],
                            "Temperature 3003 High":status_Fire[43],
                            "Temperature 4001 High":status_Fire[44],
                            "Temperature 4002 High":status_Fire[45],
                            "Temperature 4003 High":status_Fire[46],
                            "FSH 1201 FlowSwitch Alarm":status_Fire[47],
                            "FSH 1202 FlowSwitch Alarm":status_Fire[48],
                            "FSH 1203 FlowSwitch Alarm":status_Fire[49],
                            "FSH 1204 FlowSwitch Alarm":status_Fire[50],
                            "****************************DEVICE CONNECTION STATUS*************" : "5",
                            "SPM_Heartbeat": SPM_Heartbeat,
                            "SPM_Modbus_Connection": SPMConnected,
                            "ATAL_PLC_Heartbeat": ATALPLC_Heartbeat,
                            "ATAL_PLC_Modbus_Connection": ATALPLCConnected,
                            "ATDE_PLC_Heartbeat": ATDEPLC_Heartbeat,
                            "ATDE_PLC_Modbus_Connection": ATDEPLCConnected,
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
                            "enableDeadman": deadMan,
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
       atalplc_client.writeSingleCoil(4,1,function(resp){});
    }
    else{
       atalplc_client.writeSingleCoil(4,0,function(resp){});
    }

}

    // compares current state to previous state to log differences
    function logChanges(currentState){
        // {"yes":"n/a","no":"n/a"} object template for detection but no logging... "n/a" disables log
        // {"yes":"positive edge message","no":"negative edge message"} object template for detection and logging
        // pattern of statements must match devStatus and totalStatus format
        var statements=[

            [   // Show Stopper - atal
                {"yes":"Show Stopper: Estop","no":"Show Stopper Resolved: Estop"},
                {"yes":"Show Stopper: SS401 Alarm","no":"Show Stopper Resolved: SS401 Alarm"},
                {"yes":"Show Stopper: Water Level Below L","no":"Show Stopper Resolved: Water Level Below L"},
            ],
            [   // Show Stopper - atal
                {"yes":"SS in Alarm","no":"SS Not in Alarm"},
                {"yes":"kv1501 Valve Closed is 1","no":"kv1501 Valve Closed is 0"},
                {"yes":"kv1502 Valve Closed is 1","no":"kv1502 Valve Closed is 0"},
                {"yes":"kv1503 Valve Closed is 1","no":"kv1503 Valve Closed is 0"},
                {"yes":"kv1504 Valve Closed is 1","no":"kv1504 Valve Closed is 0"},
                {"yes":"kv1502 Valve Open is 1","no":"kv1502 Valve Open is 0"},
                {"yes":"kv1503 Valve Open is 1","no":"kv1503 Valve Open is 0"},
                {"yes":"kv1502 Fail to Open","no":"Resolved : kv1502 Fail to Open"},
                {"yes":"kv1502 Fail to Close","no":"Resolved : kv1502 Fail to Close"},
                {"yes":"kv1503 Fail to Open","no":"Resolved : kv1503 Fail to Open"},
                {"yes":"kv1503 Fail to Close","no":"Resolved : kv1503 Fail to Close"},
                {"yes":"Estop","no":"Resolved : Estop"},
                {"yes":"PSL Fault","no":"Resolved : PSL Fault"},
                {"yes":"PSH Fault","no":"Resolved : PSH Fault"},
                {"yes":"LEL 1501 Above Hi","no":"Resolved : LEL 1501 Above Hi"},
                {"yes":"LEL 1502 Above Hi","no":"Resolved : LEL 1502 Above Hi"},
                {"yes":"LEL 1503 Above Hi","no":"Resolved : LEL 1503 Above Hi"},
                {"yes":"LEL 1504 Above Hi","no":"Resolved : LEL 1504 Above Hi"},
                {"yes":"LEL 1505 Above Hi","no":"Resolved : LEL 1505 Above Hi"},
                {"yes":"Intrusion Alarm","no":"Resolved : Intrusion Alarm"},
                {"yes":"Fan 1A Not Running","no":"Resolved : Fan 1A Not Running"},
                {"yes":"Fan 1B Not Running","no":"Resolved : Fan 1B Not Running"},
                {"yes":"Fan 2A Not Running","no":"Resolved : Fan 2A Not Running"},
                {"yes":"Fan 2B Not Running","no":"Resolved : Fan 2B Not Running"},
                {"yes":"Fan 1A Tripped","no":"Resolved : Fan 1A Tripped"},
                {"yes":"Fan 1B Tripped","no":"Resolved : Fan 1B Tripped"},
                {"yes":"Fan 2A Tripped","no":"Resolved : Fan 2A Tripped"},
                {"yes":"Fan 2B Tripped","no":"Resolved : Fan 2B Tripped"},
                {"yes":"FS 1501 No Flow Alarm","no":"Resolved : FS 1501 No Flow Alarm"},
                {"yes":"FS 1502 No Flow Alarm","no":"Resolved : FS 1502 No Flow Alarm"},
                {"yes":"PSL 1401 Air Receiver Alarm","no":"Resolved : PSL 1401 Air Receiver Alarm"},
                {"yes":"Temperature 1000 Fault","no":"Resolved : Temperature 1000 Fault"},
                {"yes":"Temperature 2000 Fault","no":"Resolved : Temperature 2000 Fault"},
                {"yes":"Temperature 3000 Fault","no":"Resolved : Temperature 3000 Fault"},
                {"yes":"Temperature 4000 Fault","no":"Resolved : Temperature 4000 Fault"},
                {"yes":"Temperature 1001 High","no":"Resolved : Temperature 1001 High"},
                {"yes":"Temperature 1002 High","no":"Resolved : Temperature 1002 High"},
                {"yes":"Temperature 1003 High","no":"Resolved : Temperature 1003 High"},
                {"yes":"Temperature 2001 High","no":"Resolved : Temperature 2001 High"},
                {"yes":"Temperature 2002 High","no":"Resolved : Temperature 2002 High"},
                {"yes":"Temperature 2003 High","no":"Resolved : Temperature 2003 High"},
                {"yes":"Temperature 3001 High","no":"Resolved : Temperature 3001 High"},
                {"yes":"Temperature 3002 High","no":"Resolved : Temperature 3002 High"},
                {"yes":"Temperature 3003 High","no":"Resolved : Temperature 3003 High"},
                {"yes":"Temperature 4001 High","no":"Resolved : Temperature 4001 High"},
                {"yes":"Temperature 4002 High","no":"Resolved : Temperature 4002 High"},
                {"yes":"Temperature 4003 High","no":"Resolved : Temperature 4003 High"},
                {"yes":"FSH 1201 No Flow Alarm","no":"Resolved : FSH 1201 No Flow Alarm"},
                {"yes":"FSH 1202 No Flow Alarm","no":"Resolved : FSH 1202 No Flow Alarm"},
                {"yes":"FSH 1203 No Flow Alarm","no":"Resolved : FSH 1203 No Flow Alarm"},
                {"yes":"FSH 1204 No Flow Alarm","no":"Resolved : FSH 1204 No Flow Alarm"},
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
}

module.exports=statusLogWrapper;
