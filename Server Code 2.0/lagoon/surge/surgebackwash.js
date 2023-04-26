
//Scheduled BW only
//manual BW is based on manBWcanRun bit. and iPad sends trigger directly to the PLC.

function bwWrapper(){
	//watchDog.eventLog("bwWrapper:start")
	console.log("Surge :  backwash script cycle triggered");
	//Create a new moment from Date Object as soon as the script loads
	var moment = new Date(); //new Date();
	var dayToday = moment.getDay() + 1; //getDay is 0-6 but we need 1-7
	var now = moment.getHours()*10000 + moment.getMinutes()*100 + moment.getSeconds();

	//get curent days schedule 
	var schedule = alphabufferData[1];
	surgebwData.manBWcanRun = 1;
	//get duration from the PLC
	atsuplc_client.readHoldingRegister(6519,1,function(resp){
		if (resp != undefined && resp != null){
			surgebwData.duration = resp.register[0];	
		}  
		else{
			surgebwData.duration = 3;
		}      
	});

	

	//check filtration pump status
	// var filtrationPump_Status = [0,0,0];

	// // VFD 107
	// athoplc_client.readCoils(1120,1,function(resp){
	// 	if(resp.coils[0]){
	// 		filtrationPump_Status[0] = 1;
	// 	}
	// 	else{
	// 		filtrationPump_Status[0] = 0;
	// 	}
	// 	//watchDog.eventLog("filtrationPump_Status: " +filtrationPump_Status);
	// });

	// // VFD 207
	// athoplc_client.readCoils(1400,1,function(resp){
	// 	if(resp.coils[0]){
	// 		filtrationPump_Status[1] = 1;
	// 	}
	// 	else{
	// 		filtrationPump_Status[1] = 0;
	// 	}
	// 	//watchDog.eventLog("filtrationPump_Status: " +filtrationPump_Status);
	// });

	// // VFD 307
	// athoplc_client.readCoils(1540,1,function(resp){
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

	//BW 1 & 2 & 3 Sensor
	atsuplc_client.readCoils(4007,1,function(resp){
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
		surgebwData.PDSH_req4BW = 1;
	}
	else{
		surgebwData.PDSH_req4BW = 0;
	}

	if (surgebwData.PDSH_req4BW){
		trigger_BW_PDSH = checkManualBW(surgebwData.duration,Math.floor(now/100),dayToday);
		//server still considers this as a scheduled BW and checks for timeout status
	}
	else{
		trigger_BW_PDSH = 0;
	}
	//PDSH - end

	//======================== BW Trigger conditions start ==============================

		if (surgebwData.SchBWStatus === 0) {

			// 3 IF Statements below. Schedule time, PDSH request and BackLog
			//watchDog.eventLog("Trying to Schedule BW");
			//check for:
			//schDay should be the current day	
			//if time jumps on the server
            var timeOffset = (alphaconverter.endtime(surgebwData.schTime,1))*100;	
			if ( (dayToday === surgebwData.schDay) && (( now >= (surgebwData.schTime*100) ) && ( now <= timeOffset )) ){
				
				//manBWcanrun tells us if we can run the BW now
				//playing = 0 tells us there is no show running right now

				if ((surgebwData.manBWcanRun == 1)){
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
				if (filtrationPump_Status === 0){
					watchDog.eventLog("About to trigger BW routine as requested by PDSH Sensor");
					//Issue the BW trigger to PLC
			       	trigBW(now,moment); 
			    }    	
			}
			//trigger backup BW when possible. One SHOT
			if ((surgebwData.trigBacklog == 1) && (autoMan == 0)){
				var gapCheck = checkManualBW(surgebwData.duration,Math.floor(now/100),dayToday);
				if (gapCheck){
					if (filtrationPump_Status === 0){
						watchDog.eventLog("Triggering backed-up scheduled BW now");
						//Issue the BW trigger to PLC
						trigBW(now,moment);
						surgebwData.trigBacklog = 0;
					}
				}
			}

		}// end of IF blockSchBW

		else if (surgebwData.SchBWStatus === 1){
			atsuplc_client.writeSingleCoil(4000,0,function(resp){
				atsuplc_client.readCoils(4001,1,function(resp){
					if(resp.coils[0]){
						surgebwData.SchBWStatus = 2;
						watchDog.eventLog("Surge : Sch BW Running");
						surgebwData.timeoutCountdown = surgebwData.timeout;
					}
					//else wait for PLC to acknowledge BW is running
					if ( (resp.coils[0] ==0) && ( (now/100) >= alphaconverter.endtime(((surgebwData.timeLastBW)/100),1) ) ){
						//no acknowledgement from PLC after 1 min
						//abort bw routine
						surgebwData.SchBWStatus = 0;
						surgebwData.blockBWuntil = 0;
						watchDog.eventLog("PLC did not respond to a BW Trigger from the Server.");
					}
				});
			});	
		} // end of else if

		else if (surgebwData.SchBWStatus === 2){// if blockSchBW = 2
            //watchDog.eventLog(alphaconverter.endtime(bwData.timeLastBW,bwData.timeout));
            var timeoutMoment = new Date(surgebwData.blockBWuntil);
            if (moment.getTime() >= timeoutMoment.getTime()){
                surgebwData.SchBWStatus = 0; //end of timeout
            } 
            else{
                surgebwData.SchBWStatus = 2;
            }
            surgebwData.timeoutCountdown = Math.round ( (timeoutMoment.getTime() - moment.getTime() )/1000 );
            //watchDog.eventLog('----------------------------------------------- TimeOut '+timeoutMoment.getTime());
            //watchDog.eventLog('----------------------------------------------- TimeNow '+moment.getTime());
		}// end of else if

		else{
			//catch exception. bwData.SchBWStatus should be 0, 1 or 2. 
		}

	//======================== BW Trigger conditions end ==============================
	//update txt file
	if (surgebwData.blockBWuntil !== undefined){
		//watchDog.eventLog("bwData ok");
		fs.writeFileSync(homeD+'/UserFiles/surgebackwash.txt',JSON.stringify(surgebwData),'utf-8');
		fs.writeFileSync(homeD+'/UserFiles/surgebackwashBkp.txt',JSON.stringify(surgebwData),'utf-8');
	}
	else{
		//bwData is corrupt. Load default values and write to the file
		watchDog.eventLog("surgebwData Undefined. Pushed in default values.");
		surgebwData = {"BWshowNumber":999,"duration":3,"SchBWStatus":0,"timeout":86400,"timeoutCountdown":0,"timeLastBW":0,"trigBacklog":0,"manBWcanRun":1,"PDSH_req4BW":0,"schDay":1,"schTime":2300, "blockBWuntil":0 };
		fs.writeFileSync(homeD+'/UserFiles/surgebackwash.txt',JSON.stringify(surgebwData),'utf-8');
		fs.writeFileSync(homeD+'/UserFiles/surgebackwashBkp.txt',JSON.stringify(surgebwData),'utf-8');
	}
  	//watchDog.eventLog("bwWrapper:end")
}

function trigBW(now,moment){
	//only when there is no pump Fault
	atsuplc_client.writeSingleCoil(4000,1,function(resp){
		watchDog.eventLog("Surge : BW Trigger Sent to PLC");
		surgebwData.SchBWStatus = 1;
		surgebwData.timeLastBW = now;
		surgebwData.blockBWuntil = new Date(moment.getTime() + (surgebwData.timeout * 1000) );
		surgebwData.trigBacklog = 0;
	});
}

module.exports=bwWrapper;

				
