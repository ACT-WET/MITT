function trigScriptsWrapper(){

var moment = new Date();
var msec = moment.getMilliseconds();
var sec = moment.getSeconds();

var timeKeeper_timer = require("./timeKeeper.js");

var timedWatchDog_timer = require("./TimedWatchDog.js");
var statusLog_timer = require("./statusLog.js");
var fillerShw_timer = require("./sch_FillerShows.js");

var backwash_timer = require("./backwash.js");
var lights_timer = require("./sch_lights.js");
var poollights_timer = require("./sch_poollights.js");
var waterQuality_timer = require("./waterQualityReadings.js");

var filter_timer = require("./sch_filter.js");
//var weirPumpSch_timer = require("./sch_WeirPumps.js");

if ((isBetween(msec,0,250)) || (isBetween(msec,250,500)) || (isBetween(msec,500,750)) || (isBetween(msec,750,999))){
	if (timerCount[0] != sec){
		//watchDog.eventLog('Hey! Execute TimeKeeper');
		//timeSync_timer();
		timeKeeper_timer();
		statusLog_timer();
		timerCount[0] = sec;
	}
	else{
		//watchDog.eventLog('Prevented a double Timekeeper trigger');
	}
}

if (isBetween(msec,250,500)){
	if (timerCount[1] != sec){
		//watchDog.eventLog('Hey! Execute BW');
		backwash_timer();
		filter_timer();
		//surge_timer();
		timerCount[1] = sec;
	}
	else{
		//watchDog.eventLog('Prevented a double BW trigger');
	}
}

if (isBetween(msec,500,750)){
	if (timerCount[2] != sec){
		//watchDog.eventLog('Hey! Execute WQ');
		waterQuality_timer();
		fillerShw_timer();
		//flog();
		timerCount[2] = sec;
	}
	else{
		//watchDog.eventLog('Prevented a double WQ trigger');
	}
}

if (isBetween(msec,750,999)){
	if (timerCount[3] != sec){
		//watchDog.eventLog('Hey! Execute Wind');
		if (sysStatus.length != 0){
			//windSpeedDayMode_timer();
			timerCount[3] = sec;
		}
	}
	else{
		//watchDog.eventLog('Prevented a double Wind trigger');
	}
}

if ( (sec%2 === 0) && (isBetween(msec,0,250)) ){
	if (timerCount[4] != sec){
		//watchDog.eventLog('Hey! Execute ErrorLog');
		poollights_timer();
		lights_timer();
		timerCount[4] = sec;
	}
	else{
		//watchDog.eventLog('Prevented a double ErrorLog trigger');
	}
}

if ( (sec%2 === 0) && (isBetween(msec,250,500)) ){
	if (timerCount[5] != sec){
		//watchDog.eventLog('Hey! Execute Lights');
		if (sysStatus.length != 0){
			// dms();
			//displayPumpSch_timer();
			timerCount[5] = sec;
		}
	}
	else{
		//watchDog.eventLog('Prevented a double Lights trigger');
	}
}

if ( (sec%2 === 0) && (isBetween(msec,500,750)) ){
	if (timerCount[6] != sec){
		//watchDog.eventLog('Hey! Execute Weir Pump');
		if (sysStatus.length != 0){
			timerCount[6] = sec;
		}
	}
	else{
		//watchDog.eventLog('Prevented a double Weir Pump trigger');
	}
}

if ( (sec%5 === 0) && (isBetween(msec,500,750)) ){
	if (timerCount[7] != sec){
		//watchDog.eventLog('Hey! Execute Watch TimedDog');
		timedWatchDog_timer();
		timerCount[7] = sec;
	}
	else{
		//watchDog.eventLog('Prevented a double timedWatchDog trigger');
	}
}

function isBetween(num,min,max){
	var result;
	if ((num >= min) && (num < max)){
		result = 1;
		//watchDog.eventLog('1');
	}
	else{
		result = 0;
		//watchDog.eventLog('0');
	}
	return result;
}

	
}
module.exports=trigScriptsWrapper;
