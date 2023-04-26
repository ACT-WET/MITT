function wsdmw(){

    // DEFAULT Wind Scaling Setting setPoints
    // {
    // "windBelowLow" : 1,
    //  "windAboveHi" : 4,
    //  "windNeither" : 2
    // }
    
    //console.log("wind Speed script triggered");

    var windBelowLow = windScalingData.windBelowLow;
    var windAboveHi = windScalingData.windAboveHi;
    var windNeither = windScalingData.windNeither;
    var dayModeValue = 0;

    if (dayMode == 1){
        dayModeValue = 16;
    }
    else{
        dayModeValue = 0;
    }
    //watchDog.eventLog('DayMode : ' +dayMode);
    //watchDog.eventLog('DayMode Value: ' +dayModeValue);

    //SPM Register 1002: Bit - 0 : Low Wind
    //                 : Bit - 1 : Med Wind
    //                 : Bit - 2 : High Wind

    //watchDog.eventLog('Wind Status: ' +windStatus );

    var hiWindMode = sysStatus[0].Wind_AboveHi;
    var loWindMode = sysStatus[0].Wind_BelowLow;

    // watchDog.eventLog('hiWindMode: ' +hiWindMode);
    // watchDog.eventLog('loWindMode: ' +loWindMode);

    //Wind speed Below Low
    if (loWindMode === 1){
        //watchDog.eventLog('here1');
        spm_client.writeSingleRegister(1002, windBelowLow,function(resp){});

    }
    
    //Wind Speed Above High

    else if (hiWindMode === 1){
        //watchDog.eventLog('here2');
        spm_client.writeSingleRegister(1002, windAboveHi,function(resp){});

    }

    //Wind Speed Neither
    else{
        //watchDog.eventLog('here3');
        spm_client.writeSingleRegister(1002, windNeither,function(resp){});

    }
    
    
}

module.exports=wsdmw;