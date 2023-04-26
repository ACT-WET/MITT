function tmdWrapper(){

  //let ATGL_PLC_IP_ADDRESS            = "10.0.5.230"
  //let ATSU_PLC_IP_ADDRESS            = "10.0.9.230"
  //let ATHO_PLC_IP_ADDRESS            = "10.0.6.230"
  //let SERVER_IP_ADDRESS              = "10.0.6.2"
  //let SPM_IP_ADDRESS                 = "10.0.6.201"
   //========================== ATGL PLC CONNECTION ===========//

  if((ATGLPLCConnected == 0)&& (10 <= ATGLPLC_Heartbeat) && (ATGLPLC_Heartbeat < 15)){
    watchDog.eventLog('Attempted to reconnect to ATGL PLC ' +ATGLPLC_Heartbeat);

    atglplc_client.destroy();
    atglplc_client=null;

    atglplc_client = jsModbus.createTCPClient(502,'10.0.5.230',function(err){

      if(err){

        //watchDog.eventLog('PLC MODBUS CONNECTION FAILED');
        ATGLPLCConnected=false;

      }else{

        watchDog.eventLog(' ATGL PLC MODBUS CONNECTION SUCCESSFUL');
        ATGLPLCConnected = 1;
        ATGLPLC_Heartbeat = 0;

      }

    });
  } 
  else if((ATGLPLCConnected == 0) && (ATGLPLC_Heartbeat > 60)){
    ATGLPLC_Heartbeat = 1;
  }

 //========================== ATHO PLC CONNECTION ===========//

  if((ATHOPLCConnected == 0)&& (10 <= ATHOPLC_Heartbeat) && (ATHOPLC_Heartbeat < 15)){
    watchDog.eventLog('Attempted to reconnect to ATHO PLC ' +ATHOPLC_Heartbeat);

    athoplc_client.destroy();
    athoplc_client=null;

    athoplc_client = jsModbus.createTCPClient(502,'10.0.6.230',function(err){

      if(err){

        //watchDog.eventLog('PLC MODBUS CONNECTION FAILED');
        ATHOPLCConnected=false;

      }else{

        watchDog.eventLog(' ATHO PLC MODBUS CONNECTION SUCCESSFUL');
        ATHOPLCConnected = 1;
        ATHOPLC_Heartbeat = 0;

      }

    });
  } 
  else if((ATHOPLCConnected == 0) && (ATHOPLC_Heartbeat > 60)){
    ATHOPLC_Heartbeat = 1;
  }

  if((ATHONOEPLCConnected == 0)&& (10 <= ATHONOEPLC_Heartbeat) && (ATHONOEPLC_Heartbeat < 15)){
    watchDog.eventLog('Attempted to reconnect to ATHO NOE PLC ' +ATHONOEPLC_Heartbeat);

    atho_noe_plc_client.destroy();
    atho_noe_plc_client=null;

    atho_noe_plc_client = jsModbus.createTCPClient(502,'10.0.6.231',function(err){

      if(err){

        //watchDog.eventLog('PLC MODBUS CONNECTION FAILED');
        ATHONOEPLCConnected=false;

      }else{

        watchDog.eventLog(' ATHO NOE PLC MODBUS CONNECTION SUCCESSFUL');
        ATHONOEPLCConnected = 1;
        ATHONOEPLC_Heartbeat = 0;

      }

    });
  } 
  else if((ATHONOEPLCConnected == 0) && (ATHONOEPLC_Heartbeat > 60)){
    ATHONOEPLC_Heartbeat = 1;
  }


  // //========================== ATSU PLC CONNECTION ===========//

  if((ATSUPLCConnected == 0)&& (10 <= ATSUPLC_Heartbeat) && (ATSUPLC_Heartbeat < 15)){
    watchDog.eventLog('Attempted to reconnect to ATSU PLC ' +ATSUPLC_Heartbeat);

    atsuplc_client.destroy();
    atsuplc_client=null;

    atsuplc_client = jsModbus.createTCPClient(502,'10.0.9.230',function(err){

      if(err){

        //watchDog.eventLog('PLC MODBUS CONNECTION FAILED');
        ATSUPLCConnected=false;

      }else{

        watchDog.eventLog(' ATSU PLC MODBUS CONNECTION SUCCESSFUL');
        ATSUPLCConnected = 1;
        ATSUPLC_Heartbeat = 0;

      }

    });
  } 
  else if((ATSUPLCConnected == 0) && (ATSUPLC_Heartbeat > 60)){
    ATSUPLC_Heartbeat = 1;
  }
  //========================== SPM CONNECTION ===========//

  if((SPMConnected == 0) && (10 <= SPM_Heartbeat) && (SPM_Heartbeat < 15)){
    watchDog.eventLog('Attempted to reconnect to SPM ' +SPM_Heartbeat);

    spm_client.destroy();
    spm_client=null;

    spm_client = jsModbus.createTCPClient(502,'10.0.6.201',function(err){

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