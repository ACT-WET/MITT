/*********************  TIME KEEPER VARIABLE INFO

    showNumber:

    Description: This variable will hold the current scheduled manual show from the playlist arrau
    Possible Values: Integer Numbers
    Note: This variable only get accessed on Manual state

**********************/

var SCHEDULED_SHOW_TIME = 0
var GOT_SCHEDLED_SHOW   = 0
var CALLED_CONDITION_2  = 0
var CALLED_CONDITION_1  = 0
var CALLED_CONDITION_5  = 0
var CALLED_CONDITION_6  = 0

function timeKeeperWrapper(){

    //console.log("TimeKeeper script triggered");
    //watchDog.eventLog("TimeKeeper script triggered");
    //========= Initialization Parameters
    //Special Show will override AUTO and MANUAL shows ONLY when FILLER SHOW SCH is true
    //Heirarchy: Show Stoppers > Special Show > Show > Filler Show
    //Filler Show will run only in AUTO mode

    //Create a new moment from Date Object as soon as the script loads
    var moment = new Date();
    //Get the current hour and minute from the new moment Data Object created
    var now = moment.getHours()*10000 + moment.getMinutes()*100 + moment.getSeconds();

    //Variable to hold as schedulep[g] changes
    var spmRequest;

    //Load and parse appropriate schedule according to the day of the week
    var today = moment.getDay();

    //watchDog.eventLog("ShowStopper: " +showStopper);

    //========================== MAIN SHOW STOPPER CHECK POINT =======================//

    //Implement Show Stopper Values check point.
    //If there is a show stopping fault read from the PLC, play show 0 to 'stop' the show

    if(showStopper > 0){  

        //Check if a show is playing so that show0 is trigger only when needed
        if (playing == 1 && show != 0){
            //Instruct the SPM To Play Show Zero
            spm_client.writeSingleRegister(1005,0,function(resp){
                show = 0;
                spm_client.writeSingleRegister(1004,0,function(resp){
                    spm_client.writeSingleRegister(1004,8,function(resp){
                        playing = 0;
                        jumpToStep_auto = 0;
                        jumpToStep_manual = 0;
                        watchDog.eventLog("ShowStopper Show Aborted");
                    });
                });
            });

        }
        else{
            //watchDog.eventLog("Show Aborted");
        }

    }
    
    //Conditions are OK to play shows
    else{

        //Check if regular show is scheduled and if, abort filler show 
        
        //========================== MANUAL MODE =======================//
        if(autoMan == 1 && SPMConnected){

            //watchDog.eventLog("SERVER IS IN MANUAL MODE");
            jumpToStep_auto = 0;
            deadMan = 0;

            //Logic
            //Play show 0 as soon as it enters manual mode - only once
            //Wait for user to click on play button
            //Play according to betabuffer

            if (jumpToStep_manual == 0){//jumpToStep_manual is set to 0 when in auto mode

                //Instruct the SPM To Play Show Zero
                spm_client.writeSingleRegister(1005,0,function(resp){
                    show = 0;
                    spm_client.writeSingleRegister(1004,0,function(resp){
                        spm_client.writeSingleRegister(1004,8,function(resp){
                            jumpToStep_manual = 2;
                            watchDog.eventLog("iPad Mode changed to Manual Playing Show #0");
                        });
                    });
                });

                jumpToStep_manual = 1;

            }

            if (!manPlay && jumpToStep_manual != 1){//covers the condition when user aborts the playlist ie jumpToStep_manual = 8

                //Start time of the first show is always 2 seconds from the current time 
                betabufferData = alphaconverter.sew(alphaconverter.endtime(now,2),'p'+manFocus);
                jumpToStep_manual = 4;    

            }

            if (jumpToStep_manual == 4){

                //Wait for user to click on PLAY button

                if (manPlay && jumpToStep_manual !== 8){

                    //steal logic for Auto mode and use betabuffer instead of alphabuffer
                    var schedule = betabufferData;
                    //last element in the schedule array  
                    for (var g=schedule.length-2;g>=0;g-=2){

                        //show start time + 2 sec.
                        showTriggerTime = alphaconverter.endtime(schedule[g],2);
                        if (playlists[manFocus-1].contents[2] == 1){
                            var playlistEndtime = alphaconverter.getEndtime( betabufferData[betabufferData.length-2] , betabufferData[betabufferData.length-1],1);
                        } else {
                            var playlistEndtime = alphaconverter.getEndtime( betabufferData[betabufferData.length-2] , betabufferData[betabufferData.length-1],0);
                        }
                        //Make sure we dont run a show0 when nothing is scheduled
                        //Compare with timeLastCmnd to make sure it plays the existing show only once
                        //watchDog.eventLog("testorReg" + playlists[manFocus-1].contents[2]);
                        if ((now <= showTriggerTime && now >= schedule[g]) && (schedule[g+1] != 0) && (schedule[g] > timeLastCmnd)){
                            currentShow = schedule[g+1];
                            manIndex = (g/2) + 1;

                            var playTestReg = 0;
                            if ((playlists[manFocus-1].contents[2] == 1) && (manFocus === 41)){
                                playTestReg = 2;
                                show = currentShow + 1024;   
                            } else {
                                playTestReg = 8;
                                show = currentShow;
                            }

                            watchDog.eventLog("About to Start Show #" + currentShow);
                            watchDog.eventLog("This is #" + manIndex +" show in the playlist #" +manFocus +"is a ShowType "+playlists[manFocus-1].contents[2] + "with PlayReg" +playTestReg);

                            spm_client.writeSingleRegister(1005,currentShow,function(resp){
                                showType = playlists[manFocus-1].contents[2];
                                spm_client.writeSingleRegister(1004,0,function(resp){
                                    spm_client.writeSingleRegister(1004,playTestReg,function(resp){
                                        playing = 1;
                                        moment1 = moment;   //displays time on iPad
                                        timeLastCmnd = now;
                                        watchDog.eventLog("MANUAL: Play Show # " + currentShow);
  
                                    });
                                });
                            });

                            jumpToStep_manual = 5;

                        }

                        if (now >= playlistEndtime){

                            playing = 0;
                            jumpToStep_manual = 6;
                            //play show0 once, logic cant be implemented if iPad does NOT set manPlay to 0

                        }
                    }
                }
            }

            if (jumpToStep_manual == 5 && playing){
                jumpToStep_manual = 4; //acts like a break statement
            }

            if (jumpToStep_manual == 6){

                //Play show0 at the end of the playlist

                spm_client.writeSingleRegister(1005,0,function(resp){
                    show = 0;
                    spm_client.writeSingleRegister(1004,0,function(resp){
                        spm_client.writeSingleRegister(1004,8,function(resp){
                            jumpToStep_manual = 8;
                            manPlay = 0;
                            watchDog.eventLog("END OF THE SHOW : Playing Show 0");
                        });
                    });
                });

                jumpToStep_manual = 7;

            }

            //User presses the STOP button

            if (!manPlay && playing){

                spm_client.writeSingleRegister(1005,0,function(resp){
                    show = 0;
                    spm_client.writeSingleRegister(1004,0,function(resp){
                        spm_client.writeSingleRegister(1004,8,function(resp){
                            jumpToStep_manual = 8;
                            watchDog.eventLog("iPAD User press STOP Button: Playing Show 0");
                        });
                    });
                }); 

                playing = 0;    
            }
        }
        //========================== MANUAL MODE END =======================//

        //========================== AUTO MODE ========================//
        else if(autoMan == 0  && SPMConnected){

            //watchDog.eventLog("SERVER IS IN AUTO MODE");
            jumpToStep_manual = 0;    

            if(now<235950){

                //get curent days schedule 
                var schedule = alphabufferData[1];

                //compare current hour and minute to schedule and play appropriate show
                //start comparing from the last element of the array

                if (jumpToStep_auto == 0){

                    for(var g=schedule.length-2;g>=0;g-=2){

                        //show start time + 2 sec.
                        showTriggerTime = alphaconverter.endtime(schedule[g],2);
                        
                        //trigger show between (show start time) and (show start time + 2)seconds.
                        //make sure we dont run a show0 when nothing is scheduled
                        //compare with timeLastCmnd to make sure it plays the existing show only once

                        // We want to get the time stamps in seconds so we can send proper projector commands depending on Delta Time 
             
                        var startHour = Math.floor(schedule[g]/10000);
                        var startMin = Math.floor((schedule[g]-startHour*10000)/100);
                        var startSec = schedule[g]-startHour*10000-startMin*100;

                        SCHEDULED_SHOW_TIME = (startHour*3600) + (startMin * 60) + startSec;                        
                    
                        var nowInSeconds = (moment.getHours()*3600) + (moment.getMinutes()*60) + moment.getSeconds();
                        // watchDog.eventLog('Scheduled Show time in seconds:  ' + SCHEDULED_SHOW_TIME);
                        // watchDog.eventLog('startHour  ' + startHour);
                        // watchDog.eventLog('startMin  ' + startMin);
                        // watchDog.eventLog('startSec  ' + startSec);

                        // 90 seconds before show starts
                        if(nowInSeconds == (SCHEDULED_SHOW_TIME-30))
                        {

                            if(CALLED_CONDITION_1 == 0)
                            {
                                watchDog.eventLog("NOW 30 Seconds Before Show" + now);
                                deadMan = 1;
                                GOT_SCHEDLED_SHOW = 1;
                                CALLED_CONDITION_1 = 1;
                            }else
                            {
                                //watchDog.eventLog("Could not trigger 90 second pre show the condition 1 flag did not reset");
                            }   
                        } 

                        // // 15 seconds before show starts
                        // if(nowInSeconds == (SCHEDULED_SHOW_TIME-15) && CALLED_CONDITION_2 == 0)
                        // {
                        //     //watchDog.eventLog("NOW 15 Seconds Before -- PROJECTOR" + now);
                        //     CALLED_CONDITION_2 = 1;
                        // }


                        if ((now <= showTriggerTime && now >= schedule[g]) && (schedule[g+1] != 0) && (schedule[g] > timeLastCmnd)){
                            currentShow = schedule[g+1];
                            spmRequest = schedule[g];
                            //watchDog.eventLog("schedule[g] is " + schedule[g]);

                            jumpToStep_auto = 1;
                            //watchDog.eventLog("jumpToStep_auto is " + jumpToStep_auto);
                            break;
                        }

                        else{

                            jumpToStep_auto = 0;

                        }
                    }

                    //Read Status from the SPM
                    spm_client.readHoldingRegister(2000,1,function(resp){

                        if (nthBit(resp.register[0],4) == 1){
                            playing = 1;
                        }
                        else{
                            playing = 0;
                        }

                    });

                    // ------------------ Filler Show Logic ---------------------- //
                        if ((fillerShow_ok) && (jumpToStep_auto == 0)){
                            //check for jumpToStep_auto = 0 because upcoming scheduled show will set it to 1 in the FOR loop
                            //no show is running
                            if (playing === 0){
                                //play show #3
                                watchDog.eventLog("About to Start Filler Show ");
                                spm_client.writeSingleRegister(1005,fillerShow.FillerShow_Number,function(resp){
                                    show = fillerShow.FillerShow_Number;
                                    spm_client.writeSingleRegister(1004,0,function(resp){
                                        spm_client.writeSingleRegister(1004,8,function(resp){
                                            playing = 1;
                                            moment1 = moment;   //displays time on iPad
                                            timeLastCmnd = now;
                                            watchDog.eventLog("FILLER Show: Playing Show number " +show);
                                            jumpToStep_manual = 0;
                                        });
                                    });
                                });

                            }
                            else{
                                //Read Status from the SPM
                                //do nothing till the existing filler show ends
                                if (now >= alphaconverter.endtime(timeLastCmnd,2)){
                                    spm_client.readHoldingRegister(2000,1,function(resp){
                                        if (nthBit(resp.register[0],4) == 1){
                                            playing = 1;
                                        }
                                        else{
                                            playing = 0;
                                        }
                                    });
                                }
                                else{
                                    //do nothing
                                }
                            }
                        }
                        else{
                            //do nothing
                            //filler show is not active
                        }
                        // ------------------ Filler Show Logic ---------------------- //

                }

                if (jumpToStep_auto == 1){

                    //watchDog.eventLog("jumpToStep_auto is " + jumpToStep_auto);
                    watchDog.eventLog("About to Start Show # " + currentShow);
                    if ((currentShow==3) || (currentShow==6) || (currentShow==9)){
                        fireLog.fireEventLog('Playing Show #   ' +currentShow);  
                    }
                    CALLED_CONDITION_1 = 0;
                    deadMan = 0;
                    //Issue the SPM to Play SHOW
                    spm_client.writeSingleRegister(1005,currentShow,function(resp){
                        show = currentShow;
                        spm_client.writeSingleRegister(1004,0,function(resp){
                            spm_client.writeSingleRegister(1004,8,function(resp){
                                watchDog.eventLog("iPAD AUTO MODE: Playing Show # "+currentShow);
                                CALLED_CONDITION_1 = 0;
                                jumpToStep_auto = 3;
                                playing = 1;
                                moment1 = moment;//displays time on iPad
                                
                                //Set timeLastCmnd only after successful write to SPM
                                //If set to now, it triggers the show twice, so I am forcing it to be scheduled time
                                timeLastCmnd = spmRequest;  
                                //watchDog.eventLog("timeLastCmnd : "+timeLastCmnd);
                            });       
                        });
                    });

                    jumpToStep_auto = 2;
                }    

                if (jumpToStep_auto == 3){

                    //Check after 3 seconds to confirm if SPM has responded to the command
                    //watchDog.eventLog("now: " +now +", timeLastCmnd+3: " +(alphaconverter.endtime(timeLastCmnd,3)) +"timeLastCmnd+6: " +(alphaconverter.endtime(timeLastCmnd,6))  );
                    if ( (now >= alphaconverter.endtime(timeLastCmnd,3)) && (now < alphaconverter.endtime(timeLastCmnd,6)) ) {

                        //Read Status from the SPM
                        //watchDog.eventLog("IF is true in jumpStep == 3");
                        spm_client.readHoldingRegister(2000,1,function(resp){
                            if (nthBit(resp.register[0],4) == 1){   
                                //Stop checking and reset jumpToStep_auto to 0
                                jumpToStep_auto = 0;
                                playing = 1; 
                            }
                        }); 
                    }
                    else if (now >= alphaconverter.endtime(timeLastCmnd,6)){
                        //Show did not start after issuing the command 
                        watchDog.eventLog("SPM Status did not change");
                        playing = 0;
                        timeLastCmnd == now;
                        jumpToStep_auto = 0;
                    }
                }

            }
        }
        //========================== AUTO MODE END =======================//

        else{
            //do nothing. Should not be here.
        }
    
    }
    
     if (playing == 0){
        idleState_Counter++;
        //watchDog.eventLog("END LOGIC: IDLE state " +idleState_Counter +"show0_endShow: " +show0_endShow); 
        if(show0_endShow == 0){
            watchDog.eventLog("END LOGIC: Prepping to play Show0 " );
            if (idleState_Counter >= 5){
                watchDog.eventLog("END LOGIC: Play Show 0" );
                // no shows having playing for 5s   
                show0_endShow = 1; //one shot
                //play show 0
                spm_client.writeSingleRegister(1005,0,function(resp){
                    show = 0;
                    spm_client.writeSingleRegister(1004,0,function(resp){
                        spm_client.writeSingleRegister(1004,8,function(resp){
                            playing = 0;
                            jumpToStep_auto = 0;
                            jumpToStep_manual = 0;
                            idleState_Counter = 0;
                            watchDog.eventLog("END LOGIC: Gap in scheduled shows. Playing Show 0.");
                        });
                    });
                });
            }
        }
        if (idleState_Counter >= 30){
            //reset counter
            idleState_Counter = 0;
            //watchDog.eventLog("END LOGIC: Show0 already played. SPM is IDLE. Reset Counter" );
        }
    }
    else{
        if (show != 0){
            //some other show is playing
            //watchDog.eventLog("END LOGIC: Show #"+show +" is playing");
            idleState_Counter = 0; //sets counterback to 0
            show0_endShow = 0; //sets up server to play show0 no show is running
        }
        else{
            //watchDog.eventLog("END LOGIC: Show 0 is playing");
        }
    }

    //============================== offset show playing Time  ============//
    //Cesar
    if ( (autoMan == 0) && (showStopper === 0) ){
        var schedule_mirror = alphabufferData[1];//will still work if SPM is not connected
        for(var g=schedule_mirror.length-2;g>=0;g-=2){
            //takes current time and adds 5 sec to it
            var futureTime_3mins = alphaconverter.endtime(now,5);

            if ((futureTime_3mins >= schedule_mirror[g] && now <= schedule_mirror[g]) && (schedule_mirror[g+1] != 0) && (schedule_mirror[g] > timeLastCmnd)){
                atalplc_client.writeSingleCoil(2,1,function(resp){});
                break;
            }
            
        }
    }

    if ( (playing===1) || (showStopper > 0) ){
       atalplc_client.writeSingleCoil(2,0,function(resp){});
    }
    //============================== offset show playing Time  ============//

    //========================== NEXT SHOW IDENTIFICATION =======================//
    if (autoMan == 0){

        for (var g=alphabufferData[1].length-2;g>=0;g-=2){
             //watchDog.eventLog('g Valve '+g);
            if ( (g>=2) && (now < alphabufferData[1][g]) && (now >= alphabufferData[1][g-2]) ){
                nxtTime = alphabufferData[1][g];
                nxtShow = alphabufferData[1][g+1];
                //watchDog.eventLog('Here1');
                break;
            }
            else if ( (g==0) && (now < alphabufferData[1][0]) ){
                nxtTime = alphabufferData[1][0];
                nxtShow = alphabufferData[1][1];
                // watchDog.eventLog('Here2');
                break;
            }
            else if ( (now > alphabufferData[1][g]) && (alphabufferData[1][g] != 0) && (alphabufferData[1][g+2] === 0) ){
                //next days scheduled show
                var nextDayData = alphaconverter.tomorrowFirstShow();

                nxtTime = nextDayData[0];
                nxtShow = nextDayData[1];
                //watchDog.eventLog('was here for next days first show data');

                break;
            }
            else{
                // nxtTime = 500;
                // nxtShow = 4;
                // watchDog.eventLog('NxtTime is '+alphabufferData[1][0]);
                // watchDog.eventLog('NxtShow is '+alphabufferData[1][1]);
            }
        }    
   
    }
    else{
        if (manPlay){
            for (var g=betabufferData.length-2;g>=0;g-=2){
                if ( (g>=2) && (now < betabufferData[g]) && (now >= betabufferData[g-2]) ){
                    nxtTime = betabufferData[g];
                    nxtShow = betabufferData[g+1];
                    break;
                }
                else if ( (g==0) && (now < betabufferData[0]) ){
                    nxtTime = betabufferData[0];
                    nxtShow = betabufferData[1];
                    break;
                }
                else if ( (now > betabufferData[g]) && (g===betabufferData.length-2) ){
                    nxtTime = 0;
                    nxtShow = 0;
                    break;
                }
            }
        }
        else{ 
            nxtTime=0;
            nxtShow=0;
        }
    }

    // stringifying date object in order to broadcast when SPM started playing show
    // For iPad Show Time Display
    if(playing === 1){
        var show_endTime = new Date(moment1.getTime() + (shows[show].duration * 1000) );
        showTime_remaining =  Math.round ( (show_endTime.getTime() - moment.getTime() )/1000 );
        deflate = JSON.stringify(moment1);
    }
    else{
        deflate = "nothing";
    }

    //========================== NEXT SHOW IDENTIFICATION =======================//

    //========================== SPM PLC CONNECTION STATUS =======================//
    //Check SPM Connection
    if(SPM_Heartbeat == 2){
        spm_client.readHoldingRegister(2000,1,function(resp){
            SPM_Heartbeat = 0; //check again in the next scan
            SPMConnected = true;       
        });
        SPM_Heartbeat = 3;
    }
    else{
        SPM_Heartbeat++;
    }

    if(SPM_Heartbeat==9){
        if (SPMConnected){
            watchDog.eventLog('SPM MODBUS CONNECTION FAILED');
        }//log it only once
        SPMConnected = false;
    }


    //Check ATAL PLC Connection
    if(ATALPLC_Heartbeat == 2){
        atalplc_client.readHoldingRegister(1,1,function(resp){
            ATALPLC_Heartbeat = 0; //check again in the next scan
            ATALPLCConnected = true;       
        });
        ATALPLC_Heartbeat = 3;
    }
    else{
        ATALPLC_Heartbeat++;
    }

    if(ATALPLC_Heartbeat==9){
        if (ATALPLCConnected){
            watchDog.eventLog('ATAL PLC MODBUS CONNECTION FAILED');
        }//log it only once
        ATALPLCConnected = false;
    }

    //  //Check ATDE PLC Connection
    if(ATDEPLC_Heartbeat == 2){
        atdeplc_client.readHoldingRegister(1,1,function(resp){
            ATDEPLC_Heartbeat = 0; //check again in the next scan
            ATDEPLCConnected = true;       
        });
        ATDEPLC_Heartbeat = 3;
    }
    else{
        ATDEPLC_Heartbeat++;
    }

    if(ATDEPLC_Heartbeat==9){
        if (ATDEPLCConnected){
            watchDog.eventLog('ATDE PLC MODBUS CONNECTION FAILED');
        }//log it only once
        ATDEPLCConnected = false;
    }

    //========================== TIME CALCULATION FUNCIONS ===========//
//Watch until last moments of the day
    if(Math.floor(now/100)<2359){

        newDay = 1;

    }

    //If it is 23:59 already
    else{
        
        if(newDay){

            //Initiate the alphabuffer to build "tomorrow's" schedule
            watchDog.eventLog('alphaconverter: NEW DAY - ' + moment.getDay());
            alphaconverter.initiate(1);
            timeLastCmnd = 0;
            //Define the next show
            var future = alphaconverter.seer(moment.getHours()*10000 + moment.getMinutes()*100 + moment.getSeconds(),0);
            nxtShow=future[1];
            nxtTime=future[0];

            //Prevent loop from repetitively updating to newDay every second of 12:59PM
            newDay=0;

        }
    }

//============================ RAT MODE =================================//
spm_client.readHoldingRegister(2000,2,function(resp){
    spmRATMode = nthBit(resp.register[0],8);
    dayModeStatus = nthBit(resp.register[1],7);
    showPlayingBit = nthBit(resp.register[0],4);
    //watchDog.eventLog('DayMode '+dayModeStatus); 
    if (dayModeStatus===1){
        if(windHi==1){
            spm_client.writeSingleRegister(1002,20,function(resp){}); 
            //watchDog.eventLog('SPM set to High Wind and DayMode 1');  
        } else if(windLo==1){
            spm_client.writeSingleRegister(1002,17,function(resp){}); 
            //watchDog.eventLog('SPM set to Low Wind and DayMode 1');  
        } else if(windNo==1){
            spm_client.writeSingleRegister(1002,16,function(resp){}); 
            //watchDog.eventLog('SPM set to No Wind and DayMode 1');    
        } 
    } else {
        if(windHi==1){
            spm_client.writeSingleRegister(1002,4,function(resp){}); 
            //watchDog.eventLog('SPM set to High Wind and DayMode 0');  
        } else if(windLo==1){
            spm_client.writeSingleRegister(1002,1,function(resp){}); 
            //watchDog.eventLog('SPM set to Low Wind and DayMode 0');  
        } else if(windNo==1){
            spm_client.writeSingleRegister(1002,0,function(resp){}); 
            //watchDog.eventLog('SPM set to Med Wind and DayMode 0');    
        } 
    }
    atalplc_client.writeSingleCoil(3,(showPlayingBit || spmRATMode),function(resp){});
    //atalplc_client.writeSingleCoil(501,spmRATMode,function(resp){});
});


    
spm_client.readHoldingRegister(2005,1,function(resp)
{
    var spm_data_2005 = resp.register[0];
    if (spm_data_2005 == spmTempData){

    } else {
        spmTempData = spm_data_2005;  
    }

    // Modbus Register 2005 from SPM will give a 16-bit Int value

    // bit 0    - Audio Mute
    // bit 1    - Lights Dim
    // bit 2    - Fire Enable
    // bit 3    - Fog Enable
    // bit 4    - Fire Enable Spire 1
    // bit 5    - Fire Enable Spire 2
    // bit 6    - Fire Enable Spire 3
    // bit 7    - Fire Enable Spire 4
    // bit 8    - Fire Enable Spire 5
    // bit 9    - Fire Enable Spire 6
    // bit 10   - Fire Spire 1 Anim 
    // bit 11   - Fire Spire 2 Anim 
    // bit 12   - Fire Spire 3 Anim 
    // bit 13   - Fire Spire 4 Anim 
    // bit 14   - Fire Spire 5 Anim 
    // bit 15   - Fire Spire 6 Anim 
    
    // var audMu = nthBit(resp.register[0],0);
    // var lightOn = nthBit(resp.register[0],1);
    // var fireEn = nthBit(resp.register[0],2);
    // var fogEn = nthBit(resp.register[0],3);
    // var fireSp1 = nthBit(resp.register[0],4);
    // var fireSp2 = nthBit(resp.register[0],5);
    // var fireSp3 = nthBit(resp.register[0],6);
    // var fireSp4 = nthBit(resp.register[0],7);
    // var fireSp5 = nthBit(resp.register[0],8);
    // var fireSp6 = nthBit(resp.register[0],9);
    // var fireSp1En = nthBit(resp.register[0],10);
    // var fireSp2En = nthBit(resp.register[0],11);
    // var fireSp3En = nthBit(resp.register[0],12);
    // var fireSp4En = nthBit(resp.register[0],13);
    // var fireSp5En = nthBit(resp.register[0],14);
    // var fireSp6En = nthBit(resp.register[0],15);

    // watchDog.eventLog('audMu ' +audMu); 
    // watchDog.eventLog('lightOn ' +lightOn); 
    // watchDog.eventLog('fireEn ' +fireEn); 
    // watchDog.eventLog('fogEn ' +fogEn); 
    // watchDog.eventLog('fireSp1 ' +fireSp1); 
    // watchDog.eventLog('fireSp2 ' +fireSp2); 
    // watchDog.eventLog('fireSp3 ' +fireSp3); 
    // watchDog.eventLog('fireSp4 ' +fireSp4); 
    // watchDog.eventLog('fireSp5 ' +fireSp5); 
    // watchDog.eventLog('fireSp6 ' +fireSp6); 
    // watchDog.eventLog('fireSp1En ' +fireSp1En); 
    // watchDog.eventLog('fireSp2En ' +fireSp2En); 
    // watchDog.eventLog('fireSp3En ' +fireSp3En); 
    // watchDog.eventLog('fireSp4En ' +fireSp4En); 
    // watchDog.eventLog('fireSp5En ' +fireSp5En); 
    // watchDog.eventLog('fireSp6En ' +fireSp6En); 
    // atalplc_client.writeSingleCoil(506,fireEn,function(resp){
    //         watchDog.eventLog('SPM to PLC Send: fireEn ' +fireEn); 
    // });
    
}); 
}

//==== Return the value of the b-th of n 

function nthBit(n,b){

    var currentBit = 1 << b;

    if (currentBit & n){
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

module.exports=timeKeeperWrapper;

