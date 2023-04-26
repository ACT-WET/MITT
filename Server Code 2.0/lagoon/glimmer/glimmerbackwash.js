
//Scheduled BW only
//manual BW is based on manBWcanRun bit. and iPad sends trigger directly to the PLC.

function bwWrapper(){
	//watchDog.eventLog("bwWrapper:start")
	console.log("Glimmer : backwash script cycle triggered");
	//Create a new moment from Date Object as soon as the script loads
	var moment = new Date(); //new Date();
	var dayToday = moment.getDay() + 1; //getDay is 0-6 but we need 1-7
	var now = moment.getHours()*10000 + moment.getMinutes()*100 + moment.getSeconds();

	//get curent days schedule 
	var schedule = alphabufferData[1];
	glimbwData.manBWcanRun = 1;
	//get duration from the PLC
	atglplc_client.readHoldingRegister(6519,1,function(resp){
		if (resp != undefined && resp != null){
			glimbwData.duration = resp.register[0];	
		}  
		else{
			glimbwData.duration = 3;
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
	var high_Disble = 0;

	//BW 1 & 2 & 3 Sensor
	atglplc_client.readCoils(4007,1,function(resp){
		if (resp != undefined && resp != null){
			if((resp.coils[0]) > 0){
				pdsh_sensor = 1;
			}
			else{
				pdsh_sensor = 0;
			}
		}
	});
	atglplc_client.readCoils(4003,1,function(resp){
		if (resp != undefined && resp != null){
			high_Disble = resp.coils[0];
		}
	});

	if(pdsh_sensor>0){
		glimbwData.PDSH_req4BW = 1;
	}
	else{
		glimbwData.PDSH_req4BW = 0;
	}

	if (glimbwData.PDSH_req4BW){
		trigger_BW_PDSH = checkManualBW(glimbwData.duration,Math.floor(now/100),dayToday);
		//server still considers this as a scheduled BW and checks for timeout status
	}
	else{
		trigger_BW_PDSH = 0;
	}
	//PDSH - end

	//======================== BW Trigger conditions start ==============================

		if (glimbwData.SchBWStatus === 0) {

			// 3 IF Statements below. Schedule time, PDSH request and BackLog
			//watchDog.eventLog("Trying to Schedule BW");
			//check for:
			//schDay should be the current day	
			//if time jumps on the server
            var timeOffset = (alphaconverter.endtime(glimbwData.schTime,1))*100;	
			if ( (dayToday === glimbwData.schDay) && (( now >= (glimbwData.schTime*100) ) && ( now <= timeOffset )) ){
				
				//manBWcanrun tells us if we can run the BW now
				//playing = 0 tells us there is no show running right now

				if ((glimbwData.manBWcanRun == 1)){
					watchDog.eventLog("No Shows Played, About to trigger Sch BW routine");
					//Issue the BW trigger to PLC
					if (high_Disble === 1){
						trigBW(now,moment);
					} else {
						watchDog.eventLog("No Sch BW routine due to High Disable Alarm");
					}
					
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
			       	if (high_Disble === 1){
						trigBW(now,moment);
					} else {
						watchDog.eventLog("No PDSH BW routine due to High Disable Alarm");
					} 
			    }    	
			}
			//trigger backup BW when possible. One SHOT
			if ((glimbwData.trigBacklog == 1) && (autoMan == 0)){
				var gapCheck = checkManualBW(glimbwData.duration,Math.floor(now/100),dayToday);
				if (gapCheck){
					if (filtrationPump_Status === 0){
						watchDog.eventLog("Triggering backed-up scheduled BW now");
						//Issue the BW trigger to PLC
						if (high_Disble === 1){
							trigBW(now,moment);
						} else {
							watchDog.eventLog("No backed-up scheduled BW routine due to High Disable Alarm");
						}
						glimbwData.trigBacklog = 0;
					}
				}
			}

		}// end of IF blockSchBW

		else if (glimbwData.SchBWStatus === 1){
			atglplc_client.writeSingleCoil(4000,0,function(resp){
				atglplc_client.readCoils(4001,1,function(resp){
					if(resp.coils[0]){
						glimbwData.SchBWStatus = 2;
						watchDog.eventLog("Glimmer : Sch BW Running");
						glimbwData.timeoutCountdown = glimbwData.timeout;
					}
					//else wait for PLC to acknowledge BW is running
					if ( (resp.coils[0] ==0) && ( (now/100) >= alphaconverter.endtime(((glimbwData.timeLastBW)/100),1) ) ){
						//no acknowledgement from PLC after 1 min
						//abort bw routine
						glimbwData.SchBWStatus = 0;
						glimbwData.blockBWuntil = 0;
						watchDog.eventLog("Glimmer : PLC did not respond to a BW Trigger from the Server.");
					}
				});
			});	
		} // end of else if

		else if (glimbwData.SchBWStatus === 2){// if blockSchBW = 2
            //watchDog.eventLog(alphaconverter.endtime(bwData.timeLastBW,bwData.timeout));
            var timeoutMoment = new Date(glimbwData.blockBWuntil);
            if (moment.getTime() >= timeoutMoment.getTime()){
                glimbwData.SchBWStatus = 0; //end of timeout
            } 
            else{
                glimbwData.SchBWStatus = 2;
            }
            glimbwData.timeoutCountdown = Math.round ( (timeoutMoment.getTime() - moment.getTime() )/1000 );
            //watchDog.eventLog('----------------------------------------------- TimeOut '+timeoutMoment.getTime());
            //watchDog.eventLog('----------------------------------------------- TimeNow '+moment.getTime());
		}// end of else if

		else{
			//catch exception. bwData.SchBWStatus should be 0, 1 or 2. 
		}

	//======================== BW Trigger conditions end ==============================
	//update txt file
	if (glimbwData.blockBWuntil !== undefined){
		//watchDog.eventLog("bwData ok");
		fs.writeFileSync(homeD+'/UserFiles/glimbackwash.txt',JSON.stringify(glimbwData),'utf-8');
		fs.writeFileSync(homeD+'/UserFiles/glimbackwashBkp.txt',JSON.stringify(glimbwData),'utf-8');
	}
	else{
		//bwData is corrupt. Load default values and write to the file
		watchDog.eventLog("glimbwData Undefined. Pushed in default values.");
		glimbwData = {"BWshowNumber":999,"duration":3,"SchBWStatus":0,"timeout":86400,"timeoutCountdown":0,"timeLastBW":0,"trigBacklog":0,"manBWcanRun":1,"PDSH_req4BW":0,"schDay":1,"schTime":2300, "blockBWuntil":0 };
		fs.writeFileSync(homeD+'/UserFiles/glimbackwash.txt',JSON.stringify(glimbwData),'utf-8');
		fs.writeFileSync(homeD+'/UserFiles/glimbackwashBkp.txt',JSON.stringify(glimbwData),'utf-8');
	}
  	//watchDog.eventLog("bwWrapper:end")
}

function trigBW(now,moment){
	//only when there is no pump Fault
	atglplc_client.writeSingleCoil(4000,1,function(resp){
		watchDog.eventLog("GLimmer : BW Trigger Sent to PLC");
		glimbwData.SchBWStatus = 1;
		glimbwData.timeLastBW = now;
		glimbwData.blockBWuntil = new Date(moment.getTime() + (glimbwData.timeout * 1000) );
		glimbwData.trigBacklog = 0;
	});
}

module.exports=bwWrapper;

				
