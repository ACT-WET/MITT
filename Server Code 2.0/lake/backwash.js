
//Scheduled BW only
//manual BW is based on manBWcanRun bit. and iPad sends trigger directly to the PLC.

function bwWrapper(){
	//watchDog.eventLog("bwWrapper:start")
	console.log("backwash script cycle triggered");
	//Create a new moment from Date Object as soon as the script loads
	var moment = new Date(); //new Date();
	var dayToday = moment.getDay() + 1; //getDay is 0-6 but we need 1-7
	var now = moment.getHours()*10000 + moment.getMinutes()*100 + moment.getSeconds();

	//get curent days schedule 
	var schedule = alphabufferData[1];

	//get duration from the PLC
	atalplc_client.readHoldingRegister(6519,1,function(resp){
		if (resp != undefined && resp != null){
			bwData.duration = resp.register[0];	
		}  
		else{
			bwData.duration = 3;
		}      
	});

	//check if manual BW can be trigger at this moment
	if (autoMan === 0){//auto mode
		bwData.manBWcanRun = checkManualBW(bwData.duration,Math.floor(now/100),dayToday);
	}
	else{//man Mode
		if(manPlay){// if playing manual shows, then block BW routine
			bwData.manBWcanRun = 0;
		}
		else{//if playlist is not playing shows then we can run BW
			bwData.manBWcanRun = 1;
		}
	}

	//check filtration pump status
	// var filtrationPump_Status = [0,0,0];

	// // VFD 107
	// atalplc_client.readCoils(1120,1,function(resp){
	// 	if(resp.coils[0]){
	// 		filtrationPump_Status[0] = 1;
	// 	}
	// 	else{
	// 		filtrationPump_Status[0] = 0;
	// 	}
	// 	//watchDog.eventLog("filtrationPump_Status: " +filtrationPump_Status);
	// });

	// // VFD 207
	// atalplc_client.readCoils(1400,1,function(resp){
	// 	if(resp.coils[0]){
	// 		filtrationPump_Status[1] = 1;
	// 	}
	// 	else{
	// 		filtrationPump_Status[1] = 0;
	// 	}
	// 	//watchDog.eventLog("filtrationPump_Status: " +filtrationPump_Status);
	// });

	// // VFD 307
	// atalplc_client.readCoils(1540,1,function(resp){
	// 	if(resp.coils[0]){
	// 		filtrationPump_Status[2] = 1;
	// 	}
	// 	else{
	// 		filtrationPump_Status[2] = 0;
	// 	}
	// 	//watchDog.eventLog("filtrationPump_Status: " +filtrationPump_Status);
	// });

	// if (filtrationPump_Status.includes(1)) {
	// 	bwData.pump_Status = 1;
	// } else {
	// 	bwData.pump_Status = 0;
	// }

	//PDSH - request for BW
	var trigger_BW_PDSH = 0;
	var pdsh_sensor = 0;

	//BW 1 Sensor
	atalplc_client.readCoils(4007,1,function(resp){
		if (resp != undefined && resp != null){
			if(resp.coils[0] > 0){
				pdsh_sensor = 1;
			}
			else{
				pdsh_sensor = 0;
			}
		}
	});

	if(pdsh_sensor>0){
		bwData.PDSH_req4BW = 1;
	}
	else{
		bwData.PDSH_req4BW = 0;
	}

	if (bwData.PDSH_req4BW){
		trigger_BW_PDSH = checkManualBW(bwData.duration,Math.floor(now/100),dayToday);
		//server still considers this as a scheduled BW and checks for timeout status
	}
	else{
		trigger_BW_PDSH = 0;
	}
	//PDSH - end

	//======================== BW Trigger conditions start ==============================

		if (bwData.SchBWStatus === 0) {

			// 3 IF Statements below. Schedule time, PDSH request and BackLog
			//watchDog.eventLog("Trying to Schedule BW");
			//check for:
			//schDay should be the current day	
			//if time jumps on the server
            var timeOffset = (alphaconverter.endtime(bwData.schTime,1))*100;	
			if ( (dayToday === bwData.schDay) && (( now >= (bwData.schTime*100) ) && ( now <= timeOffset )) ){
				
				watchDog.eventLog("Backwash Time: Check if SPM Playing shows");
				//manBWcanrun tells us if we can run the BW now
				//playing = 0 tells us there is no show running right now

				if ( (bwData.manBWcanRun == 1) && (playing == 0) ){
					watchDog.eventLog("No Shows Played, About to trigger Sch BW routine");
					//Issue the BW trigger to PLC
					trigBW(now,moment);
				}
				
				//if BW could NOT be executed, set the flag and run the routine when possible
				else{
					bwData.trigBacklog = 1;
				}
			}// end of sch check
			else{
				//do nothing
			}

			//PDSH request for BW. One SHOT
			if (trigger_BW_PDSH){
				watchDog.eventLog("About to trigger Alight BW routine as requested by PDSH Sensor");
				//Issue the BW trigger to PLC
			    trigBW(now,moment);    	
			}
			//trigger backup BW when possible. One SHOT
			if ((bwData.trigBacklog == 1) && (autoMan == 0)){
				var gapCheck = checkManualBW(bwData.duration,Math.floor(now/100),dayToday);
				if (gapCheck){
					watchDog.eventLog("Triggering backed-up scheduled BW now");
					//Issue the BW trigger to PLC
					trigBW(now,moment);
					bwData.trigBacklog = 0;
			    }
			}

		}// end of IF blockSchBW

		else if (bwData.SchBWStatus === 1){
			atalplc_client.writeSingleCoil(4000,0,function(resp){
				atalplc_client.readCoils(4001,1,function(resp){
					if(resp.coils[0]){
						bwData.SchBWStatus = 2;
						watchDog.eventLog("Alight Sch BW Running");
						bwData.timeoutCountdown = bwData.timeout;
					}
					//else wait for PLC to acknowledge BW is running
					if ( (resp.coils[0] ==0) && ( (now/100) >= alphaconverter.endtime(((bwData.timeLastBW)/100),1) ) ){
						//no acknowledgement from PLC after 1 min
						//abort bw routine
						bwData.SchBWStatus = 0;
						bwData.blockBWuntil = 0;
						watchDog.eventLog("PLC did not respond to a BW Trigger from the Server.");
					}
				});
			});	
		} // end of else if

		else if (bwData.SchBWStatus === 2){// if blockSchBW = 2
            //watchDog.eventLog(alphaconverter.endtime(bwData.timeLastBW,bwData.timeout));
            var timeoutMoment = new Date(bwData.blockBWuntil);
            if (moment.getTime() >= timeoutMoment.getTime()){
                bwData.SchBWStatus = 0; //end of timeout
            } 
            else{
                bwData.SchBWStatus = 2;
            }
            bwData.timeoutCountdown = Math.round ( (timeoutMoment.getTime() - moment.getTime() )/1000 );
            //watchDog.eventLog('----------------------------------------------- TimeOut '+timeoutMoment.getTime());
            //watchDog.eventLog('----------------------------------------------- TimeNow '+moment.getTime());
		}// end of else if

		else{
			//catch exception. bwData.SchBWStatus should be 0, 1 or 2. 
		}

	//======================== BW Trigger conditions end ==============================
	//update txt file
	if (bwData.blockBWuntil !== undefined){
		//watchDog.eventLog("bwData ok");
		fs.writeFileSync(homeD+'/UserFiles/backwash.txt',JSON.stringify(bwData),'utf-8');
		fs.writeFileSync(homeD+'/UserFiles/backwashBkp.txt',JSON.stringify(bwData),'utf-8');
	}
	else{
		//bwData is corrupt. Load default values and write to the file
		watchDog.eventLog("bwData Undefined. Pushed in default values.");
		bwData = {"BWshowNumber":999,"duration":3,"SchBWStatus":0,"timeout":86400,"timeoutCountdown":0,"timeLastBW":0,"trigBacklog":0,"manBWcanRun":1,"PDSH_req4BW":0,"schDay":1,"schTime":2300, "blockBWuntil":0 };
		fs.writeFileSync(homeD+'/UserFiles/backwash.txt',JSON.stringify(bwData),'utf-8');
		fs.writeFileSync(homeD+'/UserFiles/backwashBkp.txt',JSON.stringify(bwData),'utf-8');
	}
  	//watchDog.eventLog("bwWrapper:end")
}

function checkManualBW(duration,timeNow,dayID){
	//check if there is a show playing
	//check if there is a show scheduled to run between now and (now + BW duration)
	//check for Filtration Pump status - no fault - checking on iPad side is easier
	var canRunManBWnow = 0;

	var gapAvailable = alphaconverter.checkInsert(alphaconverter.endtime(timeNow,2),999,dayID);//2 seconds in the future

	//watchDog.eventLog("Gap available: " +gapAvailable);

	if ((playing == 0) && (gapAvailable == 1)){
		canRunManBWnow = 1;
		//watchDog.eventLog("Can Run");
	}
	else{
		canRunManBWnow = 0;
		//watchDog.eventLog("Nope!");
	}

	return canRunManBWnow;
}

function trigBW(now,moment){
	//only when there is no pump Fault
	atalplc_client.writeSingleCoil(4000,1,function(resp){
		watchDog.eventLog("Alight BW Trigger Sent to PLC");
		bwData.SchBWStatus = 1;
		bwData.timeLastBW = now;
		bwData.blockBWuntil = new Date(moment.getTime() + (bwData.timeout * 1000) );
		bwData.trigBacklog = 0;
	});
}

module.exports=bwWrapper;

				
