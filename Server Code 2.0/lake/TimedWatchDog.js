function tmdWrapper(){

  //let ATAL_PLC_IP_ADDRESS            = "10.0.4.231"
  //let ATDE_PLC_IP_ADDRESS            = "10.0.4.230"
  //let SPM_IP_ADDRESS                 = "10.0.4.201"
  //let SERVER_IP_ADDRESS              = "10.0.4.2"
  
 //========================== ATAL PLC CONNECTION ===========//

  if((ATALPLCConnected == 0)&& (10 <= ATALPLC_Heartbeat) && (ATALPLC_Heartbeat < 15)){
    watchDog.eventLog('Attempted to reconnect to ATAL PLC ' +ATALPLC_Heartbeat);

    atalplc_client.destroy();
    atalplc_client=null;

    atalplc_client = jsModbus.createTCPClient(502,'10.0.4.231',function(err){

      if(err){

        //watchDog.eventLog('PLC MODBUS CONNECTION FAILED');
        ATALPLCConnected=false;

      }else{

        watchDog.eventLog(' ATAL PLC MODBUS CONNECTION SUCCESSFUL');
        ATALPLCConnected = 1;
        ATALPLC_Heartbeat = 0;

      }

    });
  } 
  else if((ATALPLCConnected == 0) && (ATALPLC_Heartbeat > 60)){
    ATALPLC_Heartbeat = 1;
  }

  // //========================== ATDE PLC CONNECTION ===========//

  if((ATDEPLCConnected == 0)&& (10 <= ATDEPLC_Heartbeat) && (ATDEPLC_Heartbeat < 15)){
    watchDog.eventLog('Attempted to reconnect to ATDE PLC ' +ATDEPLC_Heartbeat);

    atdeplc_client.destroy();
    atdeplc_client=null;

    atdeplc_client = jsModbus.createTCPClient(502,'10.0.4.230',function(err){

      if(err){

        //watchDog.eventLog('PLC MODBUS CONNECTION FAILED');
        ATDEPLCConnected=false;

      }else{

        watchDog.eventLog(' ATDE PLC MODBUS CONNECTION SUCCESSFUL');
        ATDEPLCConnected = 1;
        ATDEPLC_Heartbeat = 0;

      }

    });
  } 
  else if((ATDEPLCConnected == 0) && (ATDEPLC_Heartbeat > 60)){
    ATDEPLC_Heartbeat = 1;
  }

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