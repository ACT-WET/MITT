function tmdWrapper(){

  //let ATGL_PLC_IP_ADDRESS            = "10.0.5.230"
  //let ATSU_PLC_IP_ADDRESS            = "10.0.9.230"
  //let ATHO_PLC_IP_ADDRESS            = "10.0.6.230"
  //let SERVER_IP_ADDRESS              = "10.0.6.2"
  //let SPM_IP_ADDRESS                 = "10.0.6.201"

 //========================== PLC CONNECTION ===========//

  if((PLCConnected == 0)&& (10 <= PLC_Heartbeat) && (PLC_Heartbeat < 15)){
    watchDog.eventLog('Attempted to reconnect to PLC ' +PLC_Heartbeat);

    plc_client.destroy();
    plc_client=null;

    plc_client = jsModbus.createTCPClient(502,'10.0.4.230',function(err){

      if(err){

        //watchDog.eventLog('PLC MODBUS CONNECTION FAILED');
        PLCConnected=false;

      }else{

        watchDog.eventLog(' PLC MODBUS CONNECTION SUCCESSFUL');
        PLCConnected = 1;
        PLC_Heartbeat = 0;

      }

    });
  } 
  else if((PLCConnected == 0) && (PLC_Heartbeat > 60)){
    PLC_Heartbeat = 1;
  }

 //========================== BENDER CONNECTION ===========//

  // if((BenderConnected == 0)&& (5 <= Bndr_Heartbeat) && (Bndr_Heartbeat < 10)){
  //   watchDog.eventLog('Attempted to reconnect to Bender ' +Bndr_Heartbeat);

  //   bender_client.destroy();
  //   bender_client=null;

  //   bender_client = jsModbus.createTCPClient(502,'10.0.4.231',function(err){

  //     if(err){

  //       //watchDog.eventLog('PLC MODBUS CONNECTION FAILED');
  //       BenderConnected=false;

  //     }else{

  //       watchDog.eventLog('BENDER MODBUS CONNECTION SUCCESSFUL');
  //       BenderConnected = 1;
  //       Bndr_Heartbeat = 0;

  //     }

  //   });
  // } 
  // else if((BenderConnected == 0) && (Bndr_Heartbeat > 10)){
  //   Bndr_Heartbeat = 1;
  // }
  
  //========================== SPM CONNECTION ===========//

  if((SPMConnected == 0) && (10 <= SPM_Heartbeat) && (SPM_Heartbeat < 15)){
    watchDog.eventLog('Attempted to reconnect to SPM ' +SPM_Heartbeat);

    spm_client.destroy();
    spm_client=null;

    spm_client = jsModbus.createTCPClient(502,'10.0.4.201',function(err){

      if(err){

        //watchDog.eventLog('SPM MODBUS CONNECTION FAILED');
        SPMConnected=0;

      }else{

        watchDog.eventLog('SPM MODBUS CONNECTION SUCCESSFUL');
        SPMConnected = 1;
        SPM_Heartbeat = 0;
        jumpToStep_auto = 0;
        if(jumpToStep_manual == 5){
          jumpToStep_manual = 4;
        }
        else{
          jumpToStep_manual = 0;
        }
      }

    });

  }
  else if((SPMConnected == 0) && (SPM_Heartbeat > 60)){
    SPM_Heartbeat = 1;
  }

  //end
}

module.exports=tmdWrapper;