function pumpSchWrapper(){

    //console.log("WS Pump Schedule script triggered");

    //shows - schedule
    //filler shows - fixed show number in between scheduled shows
        //filler show will run only in AUTO mode
    //no show - only water wall - PLC manual mode

    var moment = new Date();
    var current_day = moment.getDay();      //0-6
    var current_hour = moment.getHours();   //0-23
    var current_min = moment.getMinutes();  //0-59
    var current_time = (current_hour*100)+current_min;
    var day_ID = 0;

    //6am + 1
    if (current_hour >= (6+1)){
        day_ID = current_day;
    }
    else{ 
        day_ID = current_day - 1;
        if (day_ID < 0){
            day_ID = 6;
        }  
    }

    var fillerShowData = fillerShowSch;
    var on_time = fillerShowData[(3*day_ID)+1];
    var off_time = fillerShowData[(3*day_ID)+2];

    //adjusting for 6am-6ma display on the iPad
    if ((current_time > 600)&&(off_time <= 600)){
        off_time = 2400;
    }
    else if ((current_time <= 600)&&(off_time <=600)){
        if (on_time >= 600){
            on_time = 0;
        }
    }
    else{
        //So nothing
    }

    //watchDog.eventLog("on_time: " +on_time +" current_time: " +current_time +" off_time: " +off_time);
    var fillerShow_enable = fillerShow.FillerShow_Enable;
    //actual logic
    if (fillerShow_enable){ 
        //plc_client.writeSingleCoil(5500,1,function(resp){});
        if ((current_time >= on_time)&&(current_time < off_time)){

            //turn ON
            //Filler Show ON
            fillerShow_ok = 1;
            //watchDog.eventLog("fillerShow ON   " +fillerShow_ok);
            //plc_client.writeSingleCoil(5501,1,function(resp){});

        }else{
                
            //turn OFF
            //Filler Show OFF
            fillerShow_ok = 0;
            //plc_client.writeSingleCoil(5501,0,function(resp){});
        }
    }
    else{
        //turn OFF
        //Filler Show OFF
        fillerShow_ok = 0;
        //plc_client.writeSingleCoil(5500,0,function(resp){});
    }


}

module.exports=pumpSchWrapper;