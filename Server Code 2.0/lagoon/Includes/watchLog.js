function eventLog(entry){
	// entry = JSON.stringify(entry);
	// entry = entry.replace(/["']/g, "");
	var moment = new Date();
	var zerosInFront;

	if ((moment.getMilliseconds() >= 10) && (moment.getMilliseconds() < 100)){
		zerosInFront = '0';
	}
	else if ((moment.getMilliseconds() >= 0) && (moment.getMilliseconds() < 10)){
		zerosInFront = '00';
	}
	else{
		zerosInFront = '';
	}

	var timeStamp = (moment.getFullYear() 
					+ '-' + (moment.getMonth()+1)) 
					+ '-' + moment.getDate() 
					+ ' ' + moment.getHours() 
					+ ':' + (moment.getMinutes()<10?'0':'') + moment.getMinutes() 
					+ ':' + (moment.getSeconds()<10?'0':'') + moment.getSeconds();
	// +'^'
	
	
	sysData["data"] = entry;
	sysData["date"] = timeStamp;

   fs.appendFileSync(homeD+'/UserFiles/systemLog.txt',JSON.stringify(sysData),'utf-8');
   fs.appendFileSync(homeD+'/UserFiles/systemLog.txt','\n','utf-8');
}

module.exports.eventLog=eventLog;