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

if (ATGLPLCConnected){

    atglplc_client.readHoldingRegister(1006,43,function(resp){
      if (resp != undefined && resp != null){

        //P601
        if(checkUpdatedValue(gvfd1_faultCode[0],resp.register[0],501)){
           gvfd1_faultCode[0] = resp.register[0];
        }

        //P602
        if(checkUpdatedValue(gvfd1_faultCode[1],resp.register[14],502)){
           gvfd1_faultCode[1] = resp.register[14];
        }

        //P603
        if(checkUpdatedValue(gvfd1_faultCode[2],resp.register[28],503)){
           gvfd1_faultCode[2] = resp.register[28];
        }

        //P604
        if(checkUpdatedValue(gvfd1_faultCode[3],resp.register[42],504)){
           gvfd1_faultCode[3] = resp.register[42];
        }

      }      
    });

}
    
if (ATHOPLCConnected){

     athoplc_client.readHoldingRegister(1006,113,function(resp){
      if (resp != undefined && resp != null){

        //P601
        if(checkUpdatedValue(vfd1_faultCode[0],resp.register[0],601)){
           vfd1_faultCode[0] = resp.register[0];
        }

        //P602
        if(checkUpdatedValue(vfd1_faultCode[1],resp.register[14],602)){
           vfd1_faultCode[1] = resp.register[14];
        }

        //P603
        if(checkUpdatedValue(vfd1_faultCode[2],resp.register[28],603)){
           vfd1_faultCode[2] = resp.register[28];
        }

        //P604
        if(checkUpdatedValue(vfd1_faultCode[3],resp.register[42],604)){
           vfd1_faultCode[3] = resp.register[42];
        }

        //P605
        if(checkUpdatedValue(vfd1_faultCode[4],resp.register[56],605)){
           vfd1_faultCode[4] = resp.register[56];
        }

        //P606
        if(checkUpdatedValue(vfd1_faultCode[5],resp.register[70],606)){
           vfd1_faultCode[5] = resp.register[70];
        }

        //P607
        if(checkUpdatedValue(vfd1_faultCode[6],resp.register[84],607)){
           vfd1_faultCode[6] = resp.register[84];
        }

        //P608
        if(checkUpdatedValue(vfd1_faultCode[7],resp.register[98],608)){
           vfd1_faultCode[7] = resp.register[98];
        }

        //P609
        if(checkUpdatedValue(vfd1_faultCode[8],resp.register[112],609)){
           vfd1_faultCode[8] = resp.register[112];
        }

      }      
    });

    athoplc_client.readHoldingRegister(1132,113,function(resp){
      if (resp != undefined && resp != null){

        //P610
        if(checkUpdatedValue(vfd2_faultCode[0],resp.register[0],610)){
           vfd2_faultCode[0] = resp.register[0];
        }

        //P611
        if(checkUpdatedValue(vfd2_faultCode[1],resp.register[14],611)){
           vfd2_faultCode[1] = resp.register[14];
        }

        //P612
        if(checkUpdatedValue(vfd2_faultCode[2],resp.register[28],612)){
           vfd2_faultCode[2] = resp.register[28];
        }

        //P613
        if(checkUpdatedValue(vfd2_faultCode[3],resp.register[42],613)){
           vfd2_faultCode[3] = resp.register[42];
        }

        //P614
        if(checkUpdatedValue(vfd2_faultCode[4],resp.register[56],614)){
           vfd2_faultCode[4] = resp.register[56];
        }

        //P615
        if(checkUpdatedValue(vfd2_faultCode[5],resp.register[70],615)){
           vfd2_faultCode[5] = resp.register[70];
        }

        //P616
        if(checkUpdatedValue(vfd2_faultCode[6],resp.register[84],616)){
           vfd2_faultCode[6] = resp.register[84];
        }

        //P617
        if(checkUpdatedValue(vfd2_faultCode[7],resp.register[98],617)){
           vfd2_faultCode[7] = resp.register[98];
        }

        //P618
        if(checkUpdatedValue(vfd2_faultCode[8],resp.register[112],618)){
           vfd2_faultCode[8] = resp.register[112];
        }

      }      
    });

    athoplc_client.readHoldingRegister(1258,71,function(resp){
      if (resp != undefined && resp != null){
        
        //P619
        if(checkUpdatedValue(vfd3_faultCode[0],resp.register[0],619)){
           vfd3_faultCode[0] = resp.register[0];
        }

        //P620
        if(checkUpdatedValue(vfd3_faultCode[1],resp.register[14],620)){
           vfd3_faultCode[1] = resp.register[14];
        }

        //P621
        if(checkUpdatedValue(vfd3_faultCode[2],resp.register[28],621)){
           vfd3_faultCode[2] = resp.register[28];
        }

        //P622
        if(checkUpdatedValue(vfd3_faultCode[3],resp.register[42],622)){
           vfd3_faultCode[3] = resp.register[42];
        }

        //P623
        if(checkUpdatedValue(vfd3_faultCode[4],resp.register[56],623)){
           vfd3_faultCode[4] = resp.register[56];
        }

        //P624
        if(checkUpdatedValue(vfd3_faultCode[5],resp.register[70],624)){
           vfd3_faultCode[5] = resp.register[70];
        }

      }      
    });

    athoplc_client.readCoils(0,11,function(resp1){
        
        if (resp1 != undefined && resp1 != null){  
            // Show Stoppers - atho
            fault_ShowStoppers.push(resp1.coils[5] ? resp1.coils[5] : 0); // System Estop
            fault_ShowStoppers.push(resp1.coils[6] ? resp1.coils[6] : 0); // Intrusion ShowStopper
            fault_ShowStoppers.push(resp1.coils[7] ? resp1.coils[7] : 0); // ST1001 Wind ShowStopper
            fault_ShowStoppers.push(resp1.coils[8] ? resp1.coils[8] : 0); // WaterLevel ShowStopper
            fault_ShowStoppers.push(resp1.coils[9] ? resp1.coils[9] : 0); // LEL6501_Above_Hi OR LEL6501_Channel_Fault ShowStopper
            fault_ShowStoppers.push(resp1.coils[10] ? resp1.coils[10] : 0); // SS601 Alarm
        }
    });//end of first PLC modbus call  

    atglplc_client.readCoils(0,9,function(resp2){
        
        if (resp2 != undefined && resp2 != null){  
            // Show Stoppers - atgl
            fault_ShowStoppers.push(resp2.coils[5] ? resp2.coils[5] : 0); // System Estop
            fault_ShowStoppers.push(resp2.coils[6] ? resp2.coils[6] : 0); // SS501 Alarm
            fault_ShowStoppers.push(resp2.coils[7] ? resp2.coils[7] : 0); // LT6201 Below LLL
            fault_ShowStoppers.push(resp2.coils[8] ? resp2.coils[8] : 0); // LEL5501_Above_Hi OR LEL5501_Channel_Fault ShowStopper
        }
    });//end of first PLC modbus call  
    
    athoplc_client.readHoldingRegister(100,17,function(resp){
        
        if (resp != undefined && resp != null){
        
            fault_ESTOP.push(nthBit(resp.register[0],0) ? nthBit(resp.register[0],0) : 0); // CP601 Estop
            fault_ESTOP.push(nthBit(resp.register[0],1) ? nthBit(resp.register[0],1) : 0); // CP602 Estop
            fault_ESTOP.push(nthBit(resp.register[0],2) ? nthBit(resp.register[0],2) : 0); // CP603 Estop
            fault_ESTOP.push(nthBit(resp.register[0],3) ? nthBit(resp.register[0],3) : 0); // FCP601 Estop
            fault_ESTOP.push(nthBit(resp.register[0],4) ? nthBit(resp.register[0],4) : 0); // FCP602 Estop
            fault_ESTOP.push(nthBit(resp.register[0],5) ? nthBit(resp.register[0],5) : 0); // FCP603 Estop
            fault_ESTOP.push(nthBit(resp.register[0],6) ? nthBit(resp.register[0],6) : 0); // FCP604 Estop
            fault_ESTOP.push(nthBit(resp.register[0],7) ? nthBit(resp.register[0],7) : 0); // MCC601 Estop
            fault_ESTOP.push(nthBit(resp.register[0],8) ? nthBit(resp.register[0],8) : 0); // MCC602 Estop
            fault_ESTOP.push(nthBit(resp.register[0],9) ? nthBit(resp.register[0],9) : 0); // MCC603 Estop
            fault_ESTOP.push(nthBit(resp.register[0],10) ? nthBit(resp.register[0],10) : 0); // MCC604 Estop
            fault_ESTOP.push(nthBit(resp.register[0],11) ? nthBit(resp.register[0],11) : 0); // MCC605 Estop
            fault_ESTOP.push(nthBit(resp.register[0],12) ? nthBit(resp.register[0],12) : 0); // SPP601 Estop
            fault_ESTOP.push(nthBit(resp.register[0],13) ? nthBit(resp.register[0],13) : 0); // SPP602 Estop
            fault_ESTOP.push(nthBit(resp.register[0],14) ? nthBit(resp.register[0],14) : 0); // SPP603 Estop
            fault_ESTOP.push(nthBit(resp.register[2],9) ? nthBit(resp.register[2],9) : 0); // Out_BMS6001A
            fault_ESTOP.push(nthBit(resp.register[2],10) ? nthBit(resp.register[2],10) : 0); // Out_BMS6001B

            // Wind Speed - atho

            status_windSensor.push(nthBit(resp.register[1],0) ? nthBit(resp.register[1],0) : 0); // ST1001_Drctn_Channel_Fault 
            status_windSensor.push(nthBit(resp.register[1],1) ? nthBit(resp.register[1],1) : 0); // ST1001_Abort Show
            status_windSensor.push(nthBit(resp.register[1],2) ? nthBit(resp.register[1],2) : 0); // ST1001_Above_Hi
            status_windSensor.push(nthBit(resp.register[1],3) ? nthBit(resp.register[1],3) : 0); // ST1001_Above_Medium
            status_windSensor.push(nthBit(resp.register[1],4) ? nthBit(resp.register[1],4) : 0); // ST1001_Above_Low
            status_windSensor.push(nthBit(resp.register[1],5) ? nthBit(resp.register[1],5) : 0); // ST1001_Speed_Channel_Fault
            status_windSensor.push(nthBit(resp.register[1],6) ? nthBit(resp.register[1],6) : 0); // ST1001_No_Wind

            status_windSensor.push(nthBit(resp.register[1],7) ? nthBit(resp.register[1],7) : 0); // ST1002_Drctn_Channel_Fault 
            status_windSensor.push(nthBit(resp.register[1],8) ? nthBit(resp.register[1],8) : 0); // ST1002_Abort Show
            status_windSensor.push(nthBit(resp.register[1],9) ? nthBit(resp.register[1],9) : 0); // ST1002_Above_Hi
            status_windSensor.push(nthBit(resp.register[1],10) ? nthBit(resp.register[1],10) : 0); // ST1002_Above_Medium
            status_windSensor.push(nthBit(resp.register[1],11) ? nthBit(resp.register[1],11) : 0); // ST1002_Above_Low
            status_windSensor.push(nthBit(resp.register[1],12) ? nthBit(resp.register[1],12) : 0); // ST1002_Speed_Channel_Fault
            status_windSensor.push(nthBit(resp.register[1],13) ? nthBit(resp.register[1],13) : 0); // ST1002_No_Wind

            status_windSensor.push(nthBit(resp.register[1],14) ? nthBit(resp.register[1],14) : 0); // WindMode_HA


            windHi = status_windSensor[2] || status_windSensor[9];
            windMed = status_windSensor[3] || status_windSensor[10];
            windLo = status_windSensor[4] || status_windSensor[11];
            windNo = status_windSensor[6] || status_windSensor[13];
            windHA = status_windSensor[14];

            // Water Level Sensor

            status_WaterLevel.push(nthBit(resp.register[2],0) ? nthBit(resp.register[2],0) : 0); // LT6201 Above Hi 2
            status_WaterLevel.push(nthBit(resp.register[2],1) ? nthBit(resp.register[2],1) : 0); // LT6201 Below Low
            status_WaterLevel.push(nthBit(resp.register[2],2) ? nthBit(resp.register[2],2) : 0); // LT6201 Below LowLow
            status_WaterLevel.push(nthBit(resp.register[2],3) ? nthBit(resp.register[2],3) : 0); // LT6201 Below LowLowLow
            status_WaterLevel.push(nthBit(resp.register[2],4) ? nthBit(resp.register[2],4) : 0); // LT6201 ChannelFault
            status_WaterLevel.push(nthBit(resp.register[2],5) ? nthBit(resp.register[2],5) : 0); // WaterMakeupOn
            status_WaterLevel.push(nthBit(resp.register[2],6) ? nthBit(resp.register[2],6) : 0); // WaterMakeup Timeout 
            status_WaterLevel.push(nthBit(resp.register[2],7) ? nthBit(resp.register[2],7) : 0); // LT6202 Channel Fault
            status_WaterLevel.push(nthBit(resp.register[2],8) ? nthBit(resp.register[2],8) : 0); // LT6202 Below Low

            status_WaterQuality.push(nthBit(resp.register[12],3) ? nthBit(resp.register[12],3) : 0); // Weir Pump Schedule Enable
            status_WaterQuality.push(nthBit(resp.register[12],4) ? nthBit(resp.register[12],4) : 0); // Weir Pump Schedule On
            status_WaterQuality.push(nthBit(resp.register[12],5) ? nthBit(resp.register[12],5) : 0); // Weir Pump Schedule Run
            status_WaterQuality.push(nthBit(resp.register[12],6) ? nthBit(resp.register[12],6) : 0); // Filtration Pump Schedule Enable
            status_WaterQuality.push(nthBit(resp.register[12],7) ? nthBit(resp.register[12],7) : 0); // Filtration Pump Schedule On
            status_WaterQuality.push(nthBit(resp.register[12],8) ? nthBit(resp.register[12],8) : 0); // Filtration Pump Schedule Run
            status_WaterQuality.push(nthBit(resp.register[7],3) ? nthBit(resp.register[7],3) : 0); // Backwash1 Manual Trigger 
            status_WaterQuality.push(nthBit(resp.register[7],4) ? nthBit(resp.register[7],4) : 0); // Backwash2 Manual Trigger 
            status_WaterQuality.push(nthBit(resp.register[7],5) ? nthBit(resp.register[7],5) : 0); // Backwash1 Run
            status_WaterQuality.push(nthBit(resp.register[7],6) ? nthBit(resp.register[7],6) : 0); // Backwash2 Run 
            status_WaterQuality.push(nthBit(resp.register[7],7) ? nthBit(resp.register[7],7) : 0); // Scheduled Backwash Running 
            status_WaterQuality.push(nthBit(resp.register[7],8) ? nthBit(resp.register[7],8) : 0); // PDSH1 Run
            status_WaterQuality.push(nthBit(resp.register[7],9) ? nthBit(resp.register[7],9) : 0); // PDSH2 Run

            //Intrusion
            fault_INTRUSION.push(nthBit(resp.register[3],0) ? nthBit(resp.register[3],0) : 0); // IS01A_Sensor Tripped   //Z1 (1B - 2B - 3A - 4A)
            fault_INTRUSION.push(nthBit(resp.register[3],1) ? nthBit(resp.register[3],1) : 0); // IS01B_Sensor Tripped   //Z2 (3B - 4B - 5A - 6A)
            fault_INTRUSION.push(nthBit(resp.register[3],2) ? nthBit(resp.register[3],2) : 0); // IS02A_Sensor Tripped   //Z3 (5B - 6B - 7A - 8A)
            fault_INTRUSION.push(nthBit(resp.register[3],3) ? nthBit(resp.register[3],3) : 0); // IS02B_Sensor Tripped   //Z4 (7B - 8B - 9A - 10A)
            fault_INTRUSION.push(nthBit(resp.register[3],4) ? nthBit(resp.register[3],4) : 0); // IS03A_Sensor Tripped   //Z5 (9B - 10B - 11A - 12A)
            fault_INTRUSION.push(nthBit(resp.register[3],5) ? nthBit(resp.register[3],5) : 0); // IS03B_Sensor Tripped   //Z6 (11B - 12B - 1A - 2A)
            fault_INTRUSION.push(nthBit(resp.register[3],6) ? nthBit(resp.register[3],6) : 0); // IS04A_Sensor Tripped 
            fault_INTRUSION.push(nthBit(resp.register[3],7) ? nthBit(resp.register[3],7) : 0); // IS04B_Sensor Tripped 
            fault_INTRUSION.push(nthBit(resp.register[3],8) ? nthBit(resp.register[3],8) : 0); // IS05A_Sensor Tripped 
            fault_INTRUSION.push(nthBit(resp.register[3],9) ? nthBit(resp.register[3],9) : 0); // MCC603 Estop
            fault_INTRUSION.push(nthBit(resp.register[3],10) ? nthBit(resp.register[3],10) : 0); // IS06A_Sensor Tripped 
            fault_INTRUSION.push(nthBit(resp.register[3],11) ? nthBit(resp.register[3],11) : 0); // IS06B_Sensor Tripped 
            fault_INTRUSION.push(nthBit(resp.register[3],12) ? nthBit(resp.register[3],12) : 0); // IS07A_Sensor Tripped 
            fault_INTRUSION.push(nthBit(resp.register[3],13) ? nthBit(resp.register[3],13) : 0); // IS07B_Sensor Tripped 
            fault_INTRUSION.push(nthBit(resp.register[3],14) ? nthBit(resp.register[3],14) : 0); // IS08A_Sensor Tripped 
            fault_INTRUSION.push(nthBit(resp.register[3],15) ? nthBit(resp.register[3],15) : 0); // IS08B_Sensor Tripped 
            fault_INTRUSION.push(nthBit(resp.register[4],0) ? nthBit(resp.register[4],0) : 0); // IS09A_Sensor Tripped 
            fault_INTRUSION.push(nthBit(resp.register[4],1) ? nthBit(resp.register[4],1) : 0); // IS09B_Sensor Tripped 
            fault_INTRUSION.push(nthBit(resp.register[4],2) ? nthBit(resp.register[4],2) : 0); // IS010A_Sensor Tripped 
            fault_INTRUSION.push(nthBit(resp.register[4],3) ? nthBit(resp.register[4],3) : 0); // IS010B_Sensor Tripped 
            fault_INTRUSION.push(nthBit(resp.register[4],4) ? nthBit(resp.register[4],4) : 0); // IS011A_Sensor Tripped 
            fault_INTRUSION.push(nthBit(resp.register[4],5) ? nthBit(resp.register[4],5) : 0); // IS011B_Sensor Tripped 
            fault_INTRUSION.push(nthBit(resp.register[4],6) ? nthBit(resp.register[4],6) : 0); // IS012A_Sensor Tripped 
            fault_INTRUSION.push(nthBit(resp.register[4],7) ? nthBit(resp.register[4],7) : 0); // IS012B_Sensor Tripped 


            //Fog
            fault_FOG.push(nthBit(resp.register[5],0) ? nthBit(resp.register[5],0) : 0);        // FS6301 HA Mode
            fault_FOG.push(nthBit(resp.register[5],1) ? nthBit(resp.register[5],1) : 0);        // FS6301 Hand ON
            fault_FOG.push(nthBit(resp.register[5],2) ? nthBit(resp.register[5],2) : 0);        // FS6301 Pressure Fault
            fault_FOG.push(nthBit(resp.register[5],3) ? nthBit(resp.register[5],3) : 0);        // FS6301 Pump Fault
            fault_FOG.push(nthBit(resp.register[5],4) ? nthBit(resp.register[5],4) : 0);        // FS6301 Pump Overload
            fault_FOG.push(nthBit(resp.register[5],5) ? nthBit(resp.register[5],5) : 0);        // FS6301 Running

            fault_FOG.push(nthBit(resp.register[5],6) ? nthBit(resp.register[5],6) : 0);        // FS6302 HA Mode
            fault_FOG.push(nthBit(resp.register[5],7) ? nthBit(resp.register[5],7) : 0);        // FS6302 Hand ON
            fault_FOG.push(nthBit(resp.register[5],8) ? nthBit(resp.register[5],8) : 0);        // FS6302 Pressure Fault
            fault_FOG.push(nthBit(resp.register[5],9) ? nthBit(resp.register[5],9) : 0);        // FS6302 Pump Fault
            fault_FOG.push(nthBit(resp.register[5],10) ? nthBit(resp.register[5],10) : 0);      // FS6302 Pump Overload
            fault_FOG.push(nthBit(resp.register[5],11) ? nthBit(resp.register[5],11) : 0);      // FS6302 Running

            fault_FOG.push(nthBit(resp.register[5],12) ? nthBit(resp.register[5],12) : 0);      // FS6303 HA Mode
            fault_FOG.push(nthBit(resp.register[5],13) ? nthBit(resp.register[5],13) : 0);      // FS6303 Hand ON
            fault_FOG.push(nthBit(resp.register[5],14) ? nthBit(resp.register[5],14) : 0);      // FS6303 Pressure Fault
            fault_FOG.push(nthBit(resp.register[5],15) ? nthBit(resp.register[5],15) : 0);      // FS6303 Pump Fault
            fault_FOG.push(nthBit(resp.register[6],0) ? nthBit(resp.register[6],0) : 0);        // FS6303 Pump Overload
            fault_FOG.push(nthBit(resp.register[6],1) ? nthBit(resp.register[6],1) : 0);        // FS6303 Running

            fault_FOG.push(nthBit(resp.register[6],2) ? nthBit(resp.register[6],2) : 0);        // FogLift Request

            
            status_AirPressure.push(nthBit(resp.register[16],0) ? nthBit(resp.register[16],0) : 0);     // LEL6501 Above Hi
            status_AirPressure.push(nthBit(resp.register[16],1) ? nthBit(resp.register[16],1) : 0);     // LEL6501 Below Low
            status_AirPressure.push(nthBit(resp.register[16],2) ? nthBit(resp.register[16],2) : 0);     // LEL6501 Channel Fault
            status_AirPressure.push(nthBit(resp.register[7],0) ? nthBit(resp.register[7],0) : 0);       // PT6401 Above Hi
            status_AirPressure.push(nthBit(resp.register[7],0) ? nthBit(resp.register[7],1) : 0);       // PT6401 Below Low
            status_AirPressure.push(nthBit(resp.register[7],0) ? nthBit(resp.register[7],2) : 0);       // PT6401 Channel Fault

            // Water Quality

            status_WaterQuality.push(nthBit(resp.register[8],0) ? nthBit(resp.register[8],0) : 0); // TDS Above Hi
            status_WaterQuality.push(nthBit(resp.register[8],1) ? nthBit(resp.register[8],1) : 0); // TDS Channel Fault
            status_WaterQuality.push(nthBit(resp.register[8],2) ? nthBit(resp.register[8],2) : 0); // PH Above Hi
            status_WaterQuality.push(nthBit(resp.register[8],3) ? nthBit(resp.register[8],3) : 0); // PH Below Low
            status_WaterQuality.push(nthBit(resp.register[8],4) ? nthBit(resp.register[8],4) : 0); // PH Channel Fault
            status_WaterQuality.push(nthBit(resp.register[8],5) ? nthBit(resp.register[8],5) : 0); // ORP Above Hi
            status_WaterQuality.push(nthBit(resp.register[8],6) ? nthBit(resp.register[8],6) : 0); // ORP Below Low
            status_WaterQuality.push(nthBit(resp.register[8],7) ? nthBit(resp.register[8],7) : 0); // ORP Channel Fault
            status_WaterQuality.push(nthBit(resp.register[8],8) ? nthBit(resp.register[8],8) : 0); // Bromine Dosing
            status_WaterQuality.push(nthBit(resp.register[8],9) ? nthBit(resp.register[8],9) : 0); // FSL6001 Enable
            status_WaterQuality.push(nthBit(resp.register[8],10) ? nthBit(resp.register[8],10) : 0); // FSL6001 Enable

            
            status_WaterQuality.push(nthBit(resp.register[12],13) ? nthBit(resp.register[12],13) : 0); //P625 OzonePump Overload
            status_WaterQuality.push(nthBit(resp.register[12],14) ? nthBit(resp.register[12],14) : 0); //P625 OzonePump Fault
            status_WaterQuality.push(nthBit(resp.register[12],15) ? nthBit(resp.register[12],15) : 0); //P625 OzonePump Running

            
            status_WaterQuality.push(nthBit(resp.register[13],0) ? nthBit(resp.register[13],0) : 0); //PSL-121 Clean Strainer
            status_WaterQuality.push(nthBit(resp.register[13],1) ? nthBit(resp.register[13],1) : 0); //PSL-122 Clean Strainer
            status_WaterQuality.push(nthBit(resp.register[13],2) ? nthBit(resp.register[13],2) : 0); //PSL-123 Clean Strainer
            status_WaterQuality.push(nthBit(resp.register[13],3) ? nthBit(resp.register[13],3) : 0); //PSL-124 Clean Strainer

            // Lights  
            status_LIGHTS.push(nthBit(resp.register[9],0) ? nthBit(resp.register[9],0) : 0);    // Prisma LCP ON 
            status_LIGHTS.push(nthBit(resp.register[9],1) ? nthBit(resp.register[9],1) : 0);    // Prisma LCP Sch ON 
            status_LIGHTS.push(nthBit(resp.register[9],2) ? nthBit(resp.register[9],2) : 0);    // Prisma LCP Hand ON  
            status_LIGHTS.push(nthBit(resp.register[9],3) ? nthBit(resp.register[9],3) : 0);    // Prisma LCP HOA 
            status_LIGHTS.push(nthBit(resp.register[9],4) ? nthBit(resp.register[9],4) : 0);    // Strobe LCP ON  
            status_LIGHTS.push(nthBit(resp.register[9],5) ? nthBit(resp.register[9],5) : 0);    // Strobe LCP Sch ON   
            status_LIGHTS.push(nthBit(resp.register[9],6) ? nthBit(resp.register[9],6) : 0);    // Strobe LCP Hand ON  
            status_LIGHTS.push(nthBit(resp.register[9],7) ? nthBit(resp.register[9],7) : 0);    // Strobe LCP HOA 

            // Pumps

            fault_PUMPS.push(nthBit(resp.register[10],0) ? nthBit(resp.register[10],0) : 0); // VFD 601 NetworkFault (oarsman Pump)
            fault_PUMPS.push(nthBit(resp.register[10],1) ? nthBit(resp.register[10],1) : 0); // VFD 602 NetworkFault (oarsman Pump)
            fault_PUMPS.push(nthBit(resp.register[10],2) ? nthBit(resp.register[10],2) : 0); // VFD 603 NetworkFault (oarsman Pump)
            fault_PUMPS.push(nthBit(resp.register[10],3) ? nthBit(resp.register[10],3) : 0); // VFD 604 NetworkFault (oarsman Pump)
            fault_PUMPS.push(nthBit(resp.register[10],4) ? nthBit(resp.register[10],4) : 0); // VFD 605 NetworkFault (oarsman Pump)
            fault_PUMPS.push(nthBit(resp.register[10],5) ? nthBit(resp.register[10],5) : 0); // VFD 606 NetworkFault (oarsman Pump)
            fault_PUMPS.push(nthBit(resp.register[10],6) ? nthBit(resp.register[10],6) : 0); // VFD 607 NetworkFault (oarsman Pump)  
            fault_PUMPS.push(nthBit(resp.register[10],7) ? nthBit(resp.register[10],7) : 0); // VFD 608 NetworkFault (oarsman Pump)  
            fault_PUMPS.push(nthBit(resp.register[10],8) ? nthBit(resp.register[10],8) : 0); // VFD 609 NetworkFault (oarsman Pump)  
            fault_PUMPS.push(nthBit(resp.register[10],9) ? nthBit(resp.register[10],9) : 0); // VFD 610 NetworkFault (oarsman Pump) 
            fault_PUMPS.push(nthBit(resp.register[10],10) ? nthBit(resp.register[10],10) : 0); // VFD 611 NetworkFault (oarsman Pump)  
            fault_PUMPS.push(nthBit(resp.register[10],11) ? nthBit(resp.register[10],11) : 0); // VFD 612 NetworkFault (oarsman Pump)  
            fault_PUMPS.push(nthBit(resp.register[10],12) ? nthBit(resp.register[10],12) : 0); // VFD 613 NetworkFault (oarsman Pump)  
            fault_PUMPS.push(nthBit(resp.register[10],13) ? nthBit(resp.register[10],13) : 0); // VFD 614 NetworkFault (oarsman Pump)  
            fault_PUMPS.push(nthBit(resp.register[10],14) ? nthBit(resp.register[10],14) : 0); // VFD 615 NetworkFault (oarsman Pump)  
            fault_PUMPS.push(nthBit(resp.register[10],15) ? nthBit(resp.register[10],15) : 0); // VFD 616 NetworkFault (oarsman Pump)  
            fault_PUMPS.push(nthBit(resp.register[11],0) ? nthBit(resp.register[11],0) : 0); // VFD 617 NetworkFault (oarsman Pump)
            fault_PUMPS.push(nthBit(resp.register[11],1) ? nthBit(resp.register[11],1) : 0); // VFD 618 NetworkFault (oarsman Pump)
            fault_PUMPS.push(nthBit(resp.register[11],2) ? nthBit(resp.register[11],2) : 0); // VFD 619 NetworkFault (oarsman Pump)
            fault_PUMPS.push(nthBit(resp.register[11],3) ? nthBit(resp.register[11],3) : 0); // VFD 620 NetworkFault (oarsman Pump)
            fault_PUMPS.push(nthBit(resp.register[11],4) ? nthBit(resp.register[11],4) : 0); // VFD 621 NetworkFault (oarsman Pump)
            fault_PUMPS.push(nthBit(resp.register[11],5) ? nthBit(resp.register[11],5) : 0); // VFD 622 NetworkFault (oarsman Pump)
            fault_PUMPS.push(nthBit(resp.register[11],6) ? nthBit(resp.register[11],6) : 0); // VFD 623 NetworkFault (oarsman Pump)  
            fault_PUMPS.push(nthBit(resp.register[11],7) ? nthBit(resp.register[11],7) : 0); // VFD 624 NetworkFault (oarsman Pump)

            fault_PUMPS.push(nthBit(resp.register[11],8) ? nthBit(resp.register[11],8) : 0); // SPP 601 NetworkFault (REMIO) 
            fault_PUMPS.push(nthBit(resp.register[11],9) ? nthBit(resp.register[11],9) : 0); // FCP 601 NetworkFault (REMIO)
            fault_PUMPS.push(nthBit(resp.register[11],10) ? nthBit(resp.register[11],10) : 0); // FCP 602 NetworkFault (REMIO)  
            fault_PUMPS.push(nthBit(resp.register[11],11) ? nthBit(resp.register[11],11) : 0); // FCP 603 NetworkFault (REMIO)
            fault_PUMPS.push(nthBit(resp.register[11],12) ? nthBit(resp.register[11],12) : 0); // FCP 604 NetworkFault (REMIO) 

            fault_PUMPS.push(nthBit(resp.register[12],9) ? nthBit(resp.register[12],9) : 0); // Pressure Fault 121
            fault_PUMPS.push(nthBit(resp.register[12],10) ? nthBit(resp.register[12],10) : 0); // Pressure Fault 122 
            fault_PUMPS.push(nthBit(resp.register[12],11) ? nthBit(resp.register[12],11) : 0); // Pressure Fault 123
            fault_PUMPS.push(nthBit(resp.register[12],12) ? nthBit(resp.register[12],12) : 0); // Pressure Fault 124

            showStopper = 0;
            for (var i=0; i <= (fault_ShowStoppers.length-7); i++){
                showStopper = showStopper + fault_ShowStoppers[i];
            }   

            totalStatus = [ 
                            fault_ShowStoppers,
                            fault_ESTOP,
                            status_windSensor,
                            status_WaterLevel,
                            status_WaterQuality,
                            fault_INTRUSION,
                            fault_FOG,
                            status_AirPressure,
                            status_LIGHTS,
                            fault_PUMPS];

            totalStatus = bool2int(totalStatus);

            if (devStatus.length > 1) {
                logChanges(totalStatus); // detects change of total status
            }

            devStatus = totalStatus; // makes the total status equal to the current error state

            // creates the status array that is sent to the iPad (via errorLog) AND logged to file
            sysStatus = [{
                            "***************************ESTOP STATUS**************************" : "1",
                            "CP601 Estop": fault_ESTOP[0],
                            "CP602 Estop": fault_ESTOP[1],
                            "CP603 Estop": fault_ESTOP[2],
                            "FCP601 Estop": fault_ESTOP[3],
                            "FCP602 Estop": fault_ESTOP[4],
                            "FCP603 Estop": fault_ESTOP[5],
                            "FCP604 Estop": fault_ESTOP[6],
                            "MCC601 Estop": fault_ESTOP[7],
                            "MCC602 Estop": fault_ESTOP[8],
                            "MCC603 Estop": fault_ESTOP[9],
                            "MCC604 Estop": fault_ESTOP[10],
                            "MCC605 Estop": fault_ESTOP[11],
                            "SPP601 Estop": fault_ESTOP[12],
                            "SPP602 Estop": fault_ESTOP[13],
                            "SPP603 Estop": fault_ESTOP[14],
                            "Out_BMS6001A": fault_ESTOP[15],
                            "Out_BMS6001B": fault_ESTOP[16],
                            "ShowStopper :Estop": fault_ShowStoppers[0],
                            "ShowStopper :Intrusion Tripped": fault_ShowStoppers[1],
                            "ShowStopper :ST1001 Wind_Abort": fault_ShowStoppers[2],
                            "ShowStopper :LT6201 WaterLevelLow": fault_ShowStoppers[3],
                            "FireStopper :LEL6501 Above_Hi OR LEL6501_Channel_Fault": fault_ShowStoppers[4],
                            "FireStopper :SS601 Alarm": fault_ShowStoppers[5],
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
                            "****************************WIND STATUS********************" : "3",
                            "ST1001 Direction_Channel_Fault": status_windSensor[0],
                            "ST1001 Abort_Show": status_windSensor[1],
                            "ST1001 Above_Hi": status_windSensor[2],
                            "ST1001 Above_Med": status_windSensor[3],
                            "ST1001 Below_Low": status_windSensor[4],
                            "ST1001 Speed_Channel_Fault": status_windSensor[5],
                            "ST1001 No_Wind": status_windSensor[6],
                            "ST1002 Direction_Channel_Fault": status_windSensor[7],
                            "ST1002 Abort_Show": status_windSensor[8],
                            "ST1002 Above_Hi": status_windSensor[9],
                            "ST1002 Above_Med": status_windSensor[10],
                            "ST1002 Below_Low": status_windSensor[11],
                            "ST1002 Speed_Channel_Fault": status_windSensor[12],
                            "ST1002 No_Wind": status_windSensor[13],
                            "WindMode HA": status_windSensor[14],
                             "****************************WATERLEVEL STATUS********************" : "4",
                            "LT6201 Above_Hi":status_WaterLevel[0],
                            "LT6201 Below_Low":status_WaterLevel[1],
                            "LT6201 Below_LowLow":status_WaterLevel[2],
                            "LT6201 Below_LowLowLow":status_WaterLevel[3],
                            "LT6201 ChannelFault":status_WaterLevel[4],
                            "LT6201 WaterMakeup On":status_WaterLevel[5],
                            "LT6201 WaterMakeup Timeout":status_WaterLevel[6],
                            "LT6202 ChannelFault":status_WaterLevel[7],
                            "LT6202 Below_Low":status_WaterLevel[8],
                            "****************************WATER QUALITY STATUS*****************" : "5",
                            "Weir Pump Schedule Enable": status_WaterQuality[0],
                            "Weir Pump Schedule On": status_WaterQuality[1],
                            "Weir Pump Schedule Run": status_WaterQuality[2],
                            "Filtration Pump Schedule Enable": status_WaterQuality[3],
                            "Filtration Pump Schedule On": status_WaterQuality[4],
                            "Filtration Pump Schedule Run": status_WaterQuality[5],
                            "Backwash1 Manual Trigger": status_WaterQuality[6],
                            "Backwash2 Manual Trigger": status_WaterQuality[7],
                            "Backwash1 Run": status_WaterQuality[8],
                            "Backwash2 Run": status_WaterQuality[9],
                            "Schedule Backwash Trigger": status_WaterQuality[10],
                            "PDSH1": status_WaterQuality[11],
                            "PDSH2": status_WaterQuality[12],
                            "TDS Above Hi": status_WaterQuality[13],
                            "TDS ChannelFault": status_WaterQuality[14],
                            "PH Above Hi": status_WaterQuality[15],
                            "PH Below Low": status_WaterQuality[16],
                            "PH ChannelFault": status_WaterQuality[17],
                            "ORP Above Hi": status_WaterQuality[18],
                            "ORP Below Low": status_WaterQuality[19],
                            "ORP ChannelFault": status_WaterQuality[20],
                            "Bromine Dosing": status_WaterQuality[21],
                            "Bromine Timeout": status_WaterQuality[22],
                            "WaterFlow Bromine Enabled": status_WaterQuality[23],
                            "P625 Ozone Pump Overload": status_WaterQuality[24],
                            "P625 Ozone Pump Fault": status_WaterQuality[25],
                            "P625 Ozone Pump Running": status_WaterQuality[26],
                            "PSL-121 Clean Strainer": status_WaterQuality[27],
                            "PSL-122 Clean Strainer": status_WaterQuality[28],
                            "PSL-123 Clean Strainer": status_WaterQuality[39],
                            "PSL-124 Clean Strainer": status_WaterQuality[30],
                            "****************************INTRUSION STATUS*****************" : "6",
                            "ZONE 1 IS01B Sensor Tripped": fault_INTRUSION[1],
                            "ZONE 1 IS02B Sensor Tripped": fault_INTRUSION[3],
                            "ZONE 1 IS03A Sensor Tripped": fault_INTRUSION[4],
                            "ZONE 1 IS04A Sensor Tripped": fault_INTRUSION[6],
                            "ZONE 2 IS03B Sensor Tripped": fault_INTRUSION[5],
                            "ZONE 2 IS04B Sensor Tripped": fault_INTRUSION[7],
                            "ZONE 2 IS05A Sensor Tripped": fault_INTRUSION[8],
                            "ZONE 2 IS06A Sensor Tripped": fault_INTRUSION[10],
                            "ZONE 3 IS05B Sensor Tripped": fault_INTRUSION[9],
                            "ZONE 3 IS06B Sensor Tripped": fault_INTRUSION[11],
                            "ZONE 3 IS07A Sensor Tripped": fault_INTRUSION[12],
                            "ZONE 3 IS08A Sensor Tripped": fault_INTRUSION[14],
                            "ZONE 4 IS07B Sensor Tripped": fault_INTRUSION[13],
                            "ZONE 4 IS08B Sensor Tripped": fault_INTRUSION[15],
                            "ZONE 4 IS09A Sensor Tripped": fault_INTRUSION[16],
                            "ZONE 4 IS10A Sensor Tripped": fault_INTRUSION[18],
                            "ZONE 5 IS09B Sensor Tripped": fault_INTRUSION[17],
                            "ZONE 5 IS10B Sensor Tripped": fault_INTRUSION[19],
                            "ZONE 5 IS11A Sensor Tripped": fault_INTRUSION[20],
                            "ZONE 5 IS12A Sensor Tripped": fault_INTRUSION[22],
                            "ZONE 6 IS11B Sensor Tripped": fault_INTRUSION[21],
                            "ZONE 6 IS12B Sensor Tripped": fault_INTRUSION[23],
                            "ZONE 6 IS01A Sensor Tripped": fault_INTRUSION[0],                         
                            "ZONE 6 IS02A Sensor Tripped": fault_INTRUSION[2],
                            "****************************FOG STATUS*****************" : "7",
                            "FS6301 HA Mode": fault_FOG[0],
                            "FS6301 Hand On": fault_FOG[1],
                            "FS6301 Pressure Fault": fault_FOG[2],
                            "FS6301 Pump Fault": fault_FOG[3],
                            "FS6301 Pump Overload": fault_FOG[4],
                            "FS6301 Running": fault_FOG[5],
                            "FS6302 HA Mode": fault_FOG[6],
                            "FS6302 Hand On": fault_FOG[7],
                            "FS6302 Pressure Fault": fault_FOG[8],
                            "FS6302 Pump Fault": fault_FOG[9],
                            "FS6302 Pump Overload": fault_FOG[10],
                            "FS6302 Running": fault_FOG[11],
                            "FS6303 HA Mode": fault_FOG[12],
                            "FS6303 Hand On": fault_FOG[13],
                            "FS6303 Pressure Fault": fault_FOG[14],
                            "FS6303 Pump Fault": fault_FOG[15],
                            "FS6303 Pump Overload": fault_FOG[16],
                            "FS6303 Running": fault_FOG[17],
                            "Fog Lift Request": fault_FOG[18],
                            "***************************AIR PRESSURE STATUS**************************" : "8",
                            "LEL6501 Above Hi": status_AirPressure[0],
                            "LEL6501 Below Low": status_AirPressure[1],
                            "LEL6501 ChannelFault": status_AirPressure[2],
                            "PT6401 Above Hi": status_AirPressure[3],
                            "PT6401 Below Low": status_AirPressure[4],
                            "PT6401 ChannelFault": status_AirPressure[5],
                            "****************************LIGHTS STATUS*****************" : "9",
                            "Prisma LCP ON": status_LIGHTS[0],
                            "Prisma LCP Sch ON": status_LIGHTS[1],
                            "Prisma LCP Hand ON": status_LIGHTS[2],
                            "Prisma LCP HOA": status_LIGHTS[3],
                            "Storbe LCP ON": status_LIGHTS[4],
                            "Storbe LCP Sch ON": status_LIGHTS[5],
                            "Storbe LCP Hand ON": status_LIGHTS[6],
                            "Storbe LCP HOA": status_LIGHTS[7],
                            "***************************PUMPS STATUS**************************" : "10",
                            "VFD 601 Fault Code":vfd1_faultCode[0],
                            "VFD 602 Fault Code":vfd1_faultCode[1],
                            "VFD 603 Fault Code":vfd1_faultCode[2],
                            "VFD 604 Fault Code":vfd1_faultCode[3],
                            "VFD 605 Fault Code":vfd1_faultCode[4],
                            "VFD 606 Fault Code":vfd1_faultCode[5],
                            "VFD 607 Fault Code":vfd1_faultCode[6],
                            "VFD 608 Fault Code":vfd1_faultCode[7],
                            "VFD 609 Fault Code":vfd1_faultCode[8],
                            "VFD 610 Fault Code":vfd2_faultCode[0],
                            "VFD 611 Fault Code":vfd2_faultCode[1],
                            "VFD 612 Fault Code":vfd2_faultCode[2],
                            "VFD 613 Fault Code":vfd2_faultCode[3],
                            "VFD 614 Fault Code":vfd2_faultCode[4],
                            "VFD 615 Fault Code":vfd2_faultCode[5],
                            "VFD 616 Fault Code":vfd2_faultCode[6],
                            "VFD 617 Fault Code":vfd2_faultCode[7],
                            "VFD 618 Fault Code":vfd2_faultCode[8],
                            "VFD 619 Fault Code":vfd3_faultCode[0],
                            "VFD 620 Fault Code":vfd3_faultCode[1],
                            "VFD 621 Fault Code":vfd3_faultCode[2],
                            "VFD 622 Fault Code":vfd3_faultCode[3],
                            "VFD 623 Fault Code":vfd3_faultCode[4],
                            "VFD 624 Fault Code":vfd3_faultCode[5],
                            "VFD 601 Network Fault":fault_PUMPS[0],
                            "VFD 602 Network Fault":fault_PUMPS[1],
                            "VFD 603 Network Fault":fault_PUMPS[2],
                            "VFD 604 Network Fault":fault_PUMPS[3],
                            "VFD 605 Network Fault":fault_PUMPS[4],
                            "VFD 606 Network Fault":fault_PUMPS[5],
                            "VFD 607 Network Fault":fault_PUMPS[6],
                            "VFD 608 Network Fault":fault_PUMPS[7],
                            "VFD 609 Network Fault":fault_PUMPS[8],
                            "VFD 610 Network Fault":fault_PUMPS[9],
                            "VFD 611 Network Fault":fault_PUMPS[10],
                            "VFD 612 Network Fault":fault_PUMPS[11],
                            "VFD 613 Network Fault":fault_PUMPS[12],
                            "VFD 614 Network Fault":fault_PUMPS[13],
                            "VFD 615 Network Fault":fault_PUMPS[14],
                            "VFD 616 Network Fault":fault_PUMPS[15],
                            "VFD 617 Network Fault":fault_PUMPS[16],
                            "VFD 618 Network Fault":fault_PUMPS[17],
                            "VFD 619 Network Fault":fault_PUMPS[18],
                            "VFD 620 Network Fault":fault_PUMPS[19],
                            "VFD 621 Network Fault":fault_PUMPS[20],
                            "VFD 622 Network Fault":fault_PUMPS[21],
                            "VFD 623 Network Fault":fault_PUMPS[22],
                            "VFD 624 Network Fault":fault_PUMPS[23],
                            "SPP 601 REMIO Network Fault":fault_PUMPS[24],
                            "FCP 601 REMIO Network Fault":fault_PUMPS[25],
                            "FCP 602 REMIO Network Fault":fault_PUMPS[26],
                            "FCP 603 REMIO Network Fault":fault_PUMPS[27],
                            "FCP 604 REMIO Network Fault":fault_PUMPS[28],
                            "P121 Pressure Fault":fault_PUMPS[29],
                            "P122 Pressure Fault":fault_PUMPS[30],
                            "P123 Pressure Fault":fault_PUMPS[31],
                            "P124 Pressure Fault":fault_PUMPS[32],
                           "***************************GLIMMER PUMPS STATUS**************************" : "11",
                            "VFD 501 Fault Code":gvfd1_faultCode[0],
                            "VFD 502 Fault Code":gvfd1_faultCode[1],
                            "VFD 503 Fault Code":gvfd1_faultCode[2],
                            "VFD 504 Fault Code":gvfd1_faultCode[3],
                           "****************************DEVICE CONNECTION STATUS*************" : "12",
                            "SPM_Heartbeat": SPM_Heartbeat,
                            "SPM_Modbus_Connection": SPMConnected,
                            "ATHO_PLC_Heartbeat": ATHOPLC_Heartbeat,
                            "ATHO_PLC_Modbus_Connection": ATHOPLCConnected,
                            "ATSU_PLC_Heartbeat": ATSUPLC_Heartbeat,
                            "ATSU_PLC_Modbus_Connection": ATSUPLCConnected,
                            "****************************ATGL STATUS********************" : "13",
                            "ATGL ShowStopper :Estop": fault_ShowStoppers[6],
                            "ATGL FireStopper :SS501 Alarm": fault_ShowStoppers[7],
                            "ATGL ShowStopper :LT6201 WaterLevelLow": fault_ShowStoppers[8],
                            "ATGL FireStopper :LEL5501 Above_Hi OR LEL5501_Channel_Fault": fault_ShowStoppers[9],
                           
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

     // athoplc_client.readCoils(3,1,function(resp){
     //    var m3Bit = resp.coils[0];
     //    watchDog.eventLog('Read PLC M3 value: '+m3Bit);
     // });

     spm_client.readHoldingRegister(3136,3,function(resp){

         // Fog data
        
         if (resp.register[0] !== smpFgData1){
            smpFgData1 = resp.register[0];
            watchDog.eventLog("Fog Data A1-A6,B1,B2 ::  "  +intByte_HiLo(resp.register[0])[0]);    // A1-A6,B1,B2
            watchDog.eventLog("Fog Data B3-A6,C1-C4 ::  "  +intByte_HiLo(resp.register[0])[1]);    // B3-A6,C1-C4
         }
         if (resp.register[1] !== smpFgData2){
            smpFgData2 = resp.register[1];
            watchDog.eventLog("Fog Data C5,C6,D1-D6 ::  "  +intByte_HiLo(resp.register[1])[0]);    // C5,C6,D1-D6
            watchDog.eventLog("Fog Data E1-E6,F1,F2 ::  "  +intByte_HiLo(resp.register[1])[1]);    // E1-E6,F1,F2
         }
         if (resp.register[2] !== smpFgData3){
            smpFgData3 = resp.register[2];
            watchDog.eventLog("Fog Data F3-F6 ::  "  +intByte_HiLo(resp.register[2])[0]);          // F3-F6
         }

         atho_noe_plc_client.writeSingleRegister(2203,resp.register[0],function(resp1){});
         atho_noe_plc_client.writeSingleRegister(2204,resp.register[1],function(resp2){});
         atho_noe_plc_client.writeSingleRegister(2205,resp.register[2],function(resp3){});
     });

    if(autoMan===1){
       athoplc_client.writeSingleCoil(4,1,function(resp){});
    }
    else{
      athoplc_client.writeSingleCoil(4,0,function(resp){});
    }

}

    // compares current state to previous state to log differences
    function logChanges(currentState){
        // {"yes":"n/a","no":"n/a"} object template for detection but no logging... "n/a" disables log
        // {"yes":"positive edge message","no":"negative edge message"} object template for detection and logging
        // pattern of statements must match devStatus and totalStatus format
        var statements=[

            [   // Show Stopper - atho
                {"yes":"ATHO - Show Stopper: Estop","no":"ATHO - Show Stopper Resolved: Estop"},
                {"yes":"ATHO - Show Stopper: Intrusion Tripped","no":"ATHO - Show Stopper Resolved: Intrusion"},
                {"yes":"ATHO - Show Stopper: ST1001 Wind_Speed_Abort_Show","no":"ATHO - Show Stopper Resolved: ST1001 Wind_Speed_Abort_Show"},
                {"yes":"ATHO - Show Stopper: Water Level Below L","no":"ATHO - Show Stopper Resolved: Water Level Below L"},
                {"yes":"ATHO - Fire Stopper: SS601 Alarm","no":"ATHO - Fire Stopper Resolved: SS601 Alarm"},
                {"yes":"ATHO - Fire Stopper: LEL6501 Above_Hi OR LEL6501_Channel_Fault","no":"ATHO - Fire Stopper Resolved: LEL6501 Above_Hi OR LEL6501_Channel_Fault"},
                {"yes":"ATGL - Show Stopper: Estop","no":"ATGL - Show Stopper Resolved: Estop"},
                {"yes":"ATGL - Fire Stopper: SS501 Alarm","no":"ATGL - Fire Stopper Resolved: SS501 Alarm"},
                {"yes":"ATGL - Show Stopper: Water Level Below L","no":"ATGL - Show Stopper Resolved: Water Level Below L"},
                {"yes":"ATGL - Fire Stopper: LEL5501 Above_Hi OR LEL5501_Channel_Fault","no":"ATGL - Fire Stopper Resolved: LEL5501 Above_Hi OR LEL5501_Channel_Fault"},
                
            ],

            [   // estop - atho 
                {"yes":"ATHO - CP601 Estop Triggered","no":"ATHO - Resolved: CP601 Estop"}, 
                {"yes":"ATHO - CP602 Estop Triggered","no":"ATHO - Resolved: CP602 Estop"}, 
                {"yes":"ATHO - CP603 Estop Triggered","no":"ATHO - Resolved: CP603 Estop"}, 
                {"yes":"ATHO - FCP601 Estop Triggered","no":"ATHO - Resolved: FCP601 Estop"}, 
                {"yes":"ATHO - FCP602 Estop Triggered","no":"ATHO - Resolved: FCP602 Estop"}, 
                {"yes":"ATHO - FCP603 Estop Triggered","no":"ATHO - Resolved: FCP603 Estop"}, 
                {"yes":"ATHO - FCP604 Estop Triggered","no":"ATHO - Resolved: FCP604 Estop"}, 
                {"yes":"ATHO - MCC601 Estop Triggered","no":"ATHO - Resolved: MCC601 Estop"}, 
                {"yes":"ATHO - MCC602 Estop Triggered","no":"ATHO - Resolved: MCC602 Estop"}, 
                {"yes":"ATHO - MCC603 Estop Triggered","no":"ATHO - Resolved: MCC603 Estop"}, 
                {"yes":"ATHO - MCC604 Estop Triggered","no":"ATHO - Resolved: MCC604 Estop"}, 
                {"yes":"ATHO - MCC605 Estop Triggered","no":"ATHO - Resolved: MCC605 Estop"}, 
                {"yes":"ATHO - SPP601 Estop Triggered","no":"ATHO - Resolved: SPP601 Estop"}, 
                {"yes":"ATHO - SPP602 Estop Triggered","no":"ATHO - Resolved: SPP602 Estop"}, 
                {"yes":"ATHO - SPP603 Estop Triggered","no":"ATHO - Resolved: SPP603 Estop"}, 
                {"yes":"ATHO - One/More System Warning","no":"ATHO - No Warnings"}, 
                {"yes":"ATHO - One/More System Faults ","no":"ATHO - No Faults"},
            ],

            [   // anemometer - atho
                {"yes":"ATHO - ST1001 Direction_Channel_Fault","no":"ATHO - ST1001 Direction_Channel_Fault Resolved"},
                {"yes":"ATHO - ST1001 AbortShow","no":"ATHO - ST1001 AbortShow Resolved"},
                {"yes":"ATHO - ST1001 Wind Speed Above Hi","no":"ATHO - ST1001 Wind Above Hi Resolved"},
                {"yes":"ATHO - ST1001 Wind Speed Above Medium","no":"ATHO - ST1001 Wind Above Medium Resolved"},
                {"yes":"ATHO - ST1001 Wind Speed Below Low","no":"ATHO - ST1001 Wind Below Low Resolved"},
                {"yes":"ATHO - ST1001 Speed_Channel_Fault","no":"ATHO - ST1001 Speed_Channel_Fault Resolved"},
                {"yes":"ATHO - ST1001 Wind Speed NoWind","no":"ATHO - ST1001 Wind Speed Not in NoWind"},
                {"yes":"ATHO - ST1002 Direction_Channel_Fault","no":"ATHO - ST1002 Direction_Channel_Fault Resolved"},
                {"yes":"ATHO - ST1002 AbortShow","no":"ATHO - ST1002 AbortShow Resolved"},
                {"yes":"ATHO - ST1002 Wind Speed Above Hi","no":"ATHO - ST1002 Wind Above Hi Resolved"},
                {"yes":"ATHO - ST1002 Wind Speed Above Medium","no":"ATHO - ST1002 Wind Above Medium Resolved"},
                {"yes":"ATHO - ST1002 Wind Speed Below Low","no":"ATHO - ST1002 Wind Below Low Resolved"},
                {"yes":"ATHO - ST1002 Speed_Channel_Fault","no":"ATHO - ST1002 Speed_Channel_Fault Resolved"},
                {"yes":"ATHO - ST1002 Wind Speed NoWind","no":"ATHO - ST1002 Wind Speed Not in NoWind"},
                {"yes":"ATHO - Wind Mode in Hand","no":"ATHO - Wind Mode in Auto"},
                
            ],

            [   // water level - atho
                {"yes":"ATHO - LT6201 AboveHi","no":"ATHO - Resolved: LT6201 AboveHi Alarm"},
                {"yes":"ATHO - LT6201 Below_Low","no":"ATHO - Resolved: LT6201 Below_Low Alarm"},
                {"yes":"ATHO - LT6201 Below_LowLow","no":"ATHO - Resolved: LT6201 Below_LowLow Alarm"},
                {"yes":"ATHO - LT6201 Below_LowLowLow","no":"ATHO - Resolved: LT6201 Below_LowLowLow Alarm"},
                {"yes":"ATHO - LT6201 Channel Fault","no":"ATHO - Resolved: LT6201 Channel Fault Alarm"},
                {"yes":"ATHO - LT6201 WaterMakeup On","no":"ATHO - LT6201 WaterMakeup Off"},
                {"yes":"ATHO - LT6201 WaterMakeup Timeout","no":"ATHO - Resolved:LT6201 WaterMakeup Timeout"},
                {"yes":"ATHO - LT6202 Channel Fault","no":"ATHO - Resolved: LT6202 Channel Fault Alarm"},
                {"yes":"ATHO - LT6202 Below_Low","no":"ATHO - Resolved: LT6202 Below_Low Alarm"},
                
            ],

            [   //Water Quality Status - atho
                {"yes":"ATHO - Weir Pump Schedule Enabled","no":"ATHO - Weir Pump Schedule Disabled"},
                {"yes":"ATHO - Weir Pump Schedule ON","no":"ATHO - Weir Pump Schedule OFF"},
                {"yes":"ATHO - Weir Pump Schedule Running","no":"ATHO - Weir Pump Schedule Not_Running"},
                {"yes":"ATHO - Filtration Pump Schedule Enabled","no":"ATHO - Filtration Pump Schedule Disabled"},
                {"yes":"ATHO - Filtration Pump Schedule ON","no":"ATHO - Filtration Pump Schedule OFF"},
                {"yes":"ATHO - Filtration Pump Schedule Running","no":"ATHO - Filtration Pump Schedule Not_Running"},
                {"yes":"ATHO - Manual Trigger Backwash 1","no":"ATHO - Manual Trigger Backwash 1 Ended"},
                {"yes":"ATHO - Manual Trigger Backwash 2","no":"ATHO - Manual Trigger Backwash 2 Ended"},
                {"yes":"ATHO - Backwash 1 Running","no":"ATHO - Backwash 1 Ended"},
                {"yes":"ATHO - Backwash 2 Running","no":"ATHO - Backwash 2 Ended"}, 
                {"yes":"ATHO - Scheduled Backwash Running","no":"ATHO - Scheduled Backwash Ended"}, 
                {"yes":"ATHO - PDSH1 Triggered Backwash","no":"ATHO - PDSH1 Triggered Backwash Ended"},
                {"yes":"ATHO - PDSH2 Triggered Backwash","no":"ATHO - PDSH2 Triggered Backwash Ended"},
                {"yes":"ATHO - TDS AboveHi","no":"ATHO - Resolved: TDS Above Hi Alarm "},
                {"yes":"ATHO - TDS Channel Fault","no":"ATHO - Resolved: TDS Channel Fault"},
                {"yes":"ATHO - PH AboveHi","no":"ATHO - Resolved: PH Above Hi Alarm "},
                {"yes":"ATHO - PH Below_Low","no":"ATHO - Resolved: PH Below Low Alarm "},
                {"yes":"ATHO - PH Channel Fault","no":"ATHO - Resolved: PH Channel Fault"},
                {"yes":"ATHO - ORP AboveHi","no":"ATHO - Resolved: ORP Above Hi Alarm "},
                {"yes":"ATHO - ORP Below_Low","no":"ATHO - Resolved: ORP Below Low Alarm "},
                {"yes":"ATHO - ORP Channel Fault","no":"ATHO - Resolved: ORP Channel Fault"},
                {"yes":"ATHO - Bromine Dosing ON","no":"ATHO - Bromine Dosing OFF"},
                {"yes":"ATHO - Bromine Timeout","no":"ATHO - Resolved:Bromine Timeout"},
                {"yes":"ATHO - FSL 6001 WaterFlow Enabled","no":"ATHO - FSL 6001 WaterFlow Disabled"},
                {"yes":"ATHO - Ozone Pump Overload","no":"ATHO - Resolved: Ozone Pump Overload"},
                {"yes":"ATHO - Ozone Pump Fault","no":"ATHO - Resolved: Ozone Pump Fault"},
                {"yes":"ATHO - Ozone Pump Running","no":"ATHO - Resolved: Ozone Pump NotRunning"},
                {"yes":"ATHO - PSL-121 Clean Strainer Warning","no":"ATHO - Resolved: PSL-121 Clean Strainer Warning"},
                {"yes":"ATHO - PSL-122 Clean Strainer Warning","no":"ATHO - Resolved: PSL-122 Clean Strainer Warning"},
                {"yes":"ATHO - PSL-123 Clean Strainer Warning","no":"ATHO - Resolved: PSL-123 Clean Strainer Warning"},
                {"yes":"ATHO - PSL-124 Clean Strainer Warning","no":"ATHO - Resolved: PSL-124 Clean Strainer Warning"},
            ],

            [   //Intrusion Status - atho
                {"yes":"ATHO - Resolved: Zone 6 Intrusion","no":"ATHO - Zone 6 IS01A Tripped"},
                {"yes":"ATHO - Resolved: Zone 1 Intrusion","no":"ATHO - Zone 1 IS01B Tripped"},
                {"yes":"ATHO - Resolved: Zone 6 Intrusion","no":"ATHO - Zone 6 IS02A Tripped"},
                {"yes":"ATHO - Resolved: Zone 1 Intrusion","no":"ATHO - Zone 1 IS02B Tripped"},
                {"yes":"ATHO - Resolved: Zone 1 Intrusion","no":"ATHO - Zone 1 IS03A Tripped"},
                {"yes":"ATHO - Resolved: Zone 2 Intrusion","no":"ATHO - Zone 2 IS03B Tripped"},
                {"yes":"ATHO - Resolved: Zone 1 Intrusion","no":"ATHO - Zone 1 IS04A Tripped"},
                {"yes":"ATHO - Resolved: Zone 2 Intrusion","no":"ATHO - Zone 2 IS04B Tripped"},
                {"yes":"ATHO - Resolved: Zone 2 Intrusion","no":"ATHO - Zone 2 IS05A Tripped"},
                {"yes":"ATHO - Resolved: Zone 3 Intrusion","no":"ATHO - Zone 3 IS05B Tripped"},
                {"yes":"ATHO - Resolved: Zone 2 Intrusion","no":"ATHO - Zone 2 IS06A Tripped"},
                {"yes":"ATHO - Resolved: Zone 3 Intrusion","no":"ATHO - Zone 3 IS06B Tripped"},
                {"yes":"ATHO - Resolved: Zone 3 Intrusion","no":"ATHO - Zone 3 IS07A Tripped"},
                {"yes":"ATHO - Resolved: Zone 4 Intrusion","no":"ATHO - Zone 4 IS07B Tripped"},
                {"yes":"ATHO - Resolved: Zone 3 Intrusion","no":"ATHO - Zone 3 IS08A Tripped"},
                {"yes":"ATHO - Resolved: Zone 4 Intrusion","no":"ATHO - Zone 4 IS08B Tripped"},
                {"yes":"ATHO - Resolved: Zone 4 Intrusion","no":"ATHO - Zone 4 IS09A Tripped"},
                {"yes":"ATHO - Resolved: Zone 5 Intrusion","no":"ATHO - Zone 5 IS09B Tripped"},
                {"yes":"ATHO - Resolved: Zone 4 Intrusion","no":"ATHO - Zone 4 IS010A Tripped"},
                {"yes":"ATHO - Resolved: Zone 5 Intrusion","no":"ATHO - Zone 5 IS010B Tripped"},
                {"yes":"ATHO - Resolved: Zone 5 Intrusion","no":"ATHO - Zone 5 IS011A Tripped"},
                {"yes":"ATHO - Resolved: Zone 6 Intrusion","no":"ATHO - Zone 6 IS011B Tripped"},
                {"yes":"ATHO - Resolved: Zone 5 Intrusion","no":"ATHO - Zone 5 IS012A Tripped"},
                {"yes":"ATHO - Resolved: Zone 6 Intrusion","no":"ATHO - Zone 6 IS012B Tripped"},
            ],

            [   //Fog Status - atho
                {"yes":"ATHO - FS6301 Hand Mode","no":"ATHO - FS6301 Auto Mode"},
                {"yes":"ATHO - FS6301 Hand On","no":"ATHO - FS6301 Hand Off"},
                {"yes":"ATHO - FS6301 Pressure Fault","no":"ATHO - Resolved: FS6301 Pressure Fault"},
                {"yes":"ATHO - FS6301 Pump Fault","no":"ATHO - Resolved: FS6301 Pump Fault"},
                {"yes":"ATHO - FS6301 Pump Overload","no":"ATHO - Resolved: FS6301 Pump Overload"},
                {"yes":"ATHO - FS6301 Pump Running","no":"ATHO - FS6301 Pump Stopped"},
                {"yes":"ATHO - FS6302 Hand Mode","no":"ATHO - FS6302 Auto Mode"},
                {"yes":"ATHO - FS6302 Hand On","no":"ATHO - FS6302 Hand Off"},
                {"yes":"ATHO - FS6302 Pressure Fault","no":"ATHO - Resolved: FS6302 Pressure Fault"},
                {"yes":"ATHO - FS6302 Pump Fault","no":"ATHO - Resolved: FS6302 Pump Fault"},
                {"yes":"ATHO - FS6302 Pump Overload","no":"ATHO - Resolved: FS6302 Pump Overload"},
                {"yes":"ATHO - FS6302 Pump Running","no":"ATHO - FS6302 Pump Stopped"},
                {"yes":"ATHO - FS6303 Hand Mode","no":"ATHO - FS6303 Auto Mode"},
                {"yes":"ATHO - FS6303 Hand On","no":"ATHO - FS6303 Hand Off"},
                {"yes":"ATHO - FS6303 Pressure Fault","no":"ATHO - Resolved: FS6303 Pressure Fault"},
                {"yes":"ATHO - FS6303 Pump Fault","no":"ATHO - Resolved: FS6303 Pump Fault"},
                {"yes":"ATHO - FS6303 Pump Overload","no":"ATHO - Resolved: FS6303 Pump Overload"},
                {"yes":"ATHO - FS6303 Pump Running","no":"ATHO - FS6303 Pump Stopped"},
                {"yes":"ATHO - Fog Lift Requested On","no":"ATHO - Fog Lift Requested Off"},
            ],

            [   //Air Pressure Status - atho
                {"yes":"ATHO - LEL 6501 AboveHi","no":"ATHO - Resolved: LEL 6501 Above Hi Alarm "},
                {"yes":"ATHO - LEL 6501 Below_Low","no":"ATHO - Resolved: LEL 6501 Below Low Alarm "},
                {"yes":"ATHO - LEL 6501 Channel Fault","no":"ATHO - Resolved: LEL 6501 Channel Fault"},
                {"yes":"ATHO - PT 6401 AboveHi","no":"ATHO - Resolved: PT 6401 Above Hi Alarm "},
                {"yes":"ATHO - PT 6401 Below_Low","no":"ATHO - Resolved: PT 6401 Below Low Alarm "},
                {"yes":"ATHO - PT 6401 Channel Fault","no":"ATHO - Resolved: PT 6401 Channel Fault"},
                
            ],

            [   //Lights Status - atho
                {"yes":"ATHO - Prisma Lights On","no":"ATHO - Prisma Lights Off"},
                {"yes":"ATHO - Prisma Lights Sch On","no":"ATHO - Prisma Sch Off"},
                {"yes":"ATHO - Prisma Lights Hand On","no":"ATHO - Prisma Hand Off"},
                {"yes":"ATHO - Prisma Lights Hand Mode","no":"ATHO - Prisma Lights Auto Mode"},
                {"yes":"ATHO - Strobe Lights On","no":"ATHO - Strobe Lights Off"},
                {"yes":"ATHO - Strobe Lights Sch On","no":"ATHO - Strobe Sch Off"},
                {"yes":"ATHO - Strobe Lights Hand On","no":"ATHO - Strobe Hand Off"},
                {"yes":"ATHO - Strobe Lights Hand Mode","no":"ATHO - Strobe Lights Auto Mode"},
            ],

            [   // pumps - atho
                {"yes":"ATHO - Resolved: P601 Network Fault","no":"ATHO - P601 Network Fault"},
                {"yes":"ATHO - Resolved: P602 Network Fault","no":"ATHO - P602 Network Fault"}, 
                {"yes":"ATHO - Resolved: P603 Network Fault","no":"ATHO - P603 Network Fault"}, 
                {"yes":"ATHO - Resolved: P604 Network Fault","no":"ATHO - P604 Network Fault"},  
                {"yes":"ATHO - Resolved: P605 Network Fault","no":"ATHO - P605 Network Fault"},  
                {"yes":"ATHO - Resolved: P606 Network Fault","no":"ATHO - P606 Network Fault"},  
                {"yes":"ATHO - Resolved: P607 Network Fault","no":"ATHO - P607 Network Fault"},  
                {"yes":"ATHO - Resolved: P608 Network Fault","no":"ATHO - P608 Network Fault"},  
                {"yes":"ATHO - Resolved: P609 Network Fault","no":"ATHO - P609 Network Fault"},  
                {"yes":"ATHO - Resolved: P610 Network Fault","no":"ATHO - P610 Network Fault"}, 
                {"yes":"ATHO - Resolved: P611 Network Fault","no":"ATHO - P611 Network Fault"},
                {"yes":"ATHO - Resolved: P612 Network Fault","no":"ATHO - P612 Network Fault"}, 
                {"yes":"ATHO - Resolved: P613 Network Fault","no":"ATHO - P613 Network Fault"}, 
                {"yes":"ATHO - Resolved: P614 Network Fault","no":"ATHO - P614 Network Fault"},  
                {"yes":"ATHO - Resolved: P615 Network Fault","no":"ATHO - P615 Network Fault"},  
                {"yes":"ATHO - Resolved: P616 Network Fault","no":"ATHO - P616 Network Fault"},  
                {"yes":"ATHO - Resolved: P617 Network Fault","no":"ATHO - P617 Network Fault"},  
                {"yes":"ATHO - Resolved: P618 Network Fault","no":"ATHO - P618 Network Fault"},  
                {"yes":"ATHO - Resolved: P619 Network Fault","no":"ATHO - P619 Network Fault"},  
                {"yes":"ATHO - Resolved: P620 Network Fault","no":"ATHO - P620 Network Fault"}, 
                {"yes":"ATHO - Resolved: P621 Network Fault","no":"ATHO - P621 Network Fault"},
                {"yes":"ATHO - Resolved: P622 Network Fault","no":"ATHO - P622 Network Fault"}, 
                {"yes":"ATHO - Resolved: P623 Network Fault","no":"ATHO - P623 Network Fault"}, 
                {"yes":"ATHO - Resolved: P624 Network Fault","no":"ATHO - P624 Network Fault"}, 
                {"yes":"ATHO - Resolved: SPP601 Network Fault","no":"ATHO - SPP601 Network Fault"},
                {"yes":"ATHO - Resolved: FCP601 Network Fault","no":"ATHO - FCP601 Network Fault"}, 
                {"yes":"ATHO - Resolved: FCP602 Network Fault","no":"ATHO - FCP602 Network Fault"}, 
                {"yes":"ATHO - Resolved: FCP603 Network Fault","no":"ATHO - FCP603 Network Fault"}, 
                {"yes":"ATHO - Resolved: FCP604 Network Fault","no":"ATHO - FCP604 Network Fault"}, 
                {"yes":"ATHO - PSL121 Pressure Fault","no":"ATHO - Resolved: PSL121 Pressure Fault"},
                {"yes":"ATHO - PSL122 Network Fault","no":"ATHO - Resolved: PSL122 Pressure Fault"}, 
                {"yes":"ATHO - PSL123 Network Fault","no":"ATHO - Resolved: PSL123 Pressure Fault"}, 
                {"yes":"ATHO - PSL124 Network Fault","no":"ATHO - Resolved: PSL124 Pressure Fault"}, 
                    
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
