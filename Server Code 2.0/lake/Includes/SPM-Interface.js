//	Module: SPM-Interface
//	Author: Joseph Gee
//	Date: 04/07/2020
//
//	Purpose: This module provides functions to control the SPM.
//	
// 

// TODO:
//	1. Add support for ShowScan functionality.
//	2. add support for Load and Play Show.
//	3. Track state of SPM, specifically if comm with SPM fails, we should signal the rest of the system.


// SPM UDP Settings

//var MAXTIMEOUT_MESSAGE = 100;

var NUMBER_OF_RELIABLE_RETRIES = 5; // "retries" is actually one less than this as first regular msg is counted as a retry


var dgram = require('dgram');
var spmPort = 9556;
var spmIP = "10.0.4.201";

const BASE_MESSAGE_TIMEOUT = 100;

// SPM Data Structures

// Define a custom Error?

// Promise based Solution
// Reliably send a message.


// Test Functions
function testParallelSend()
{

	sendMessagesInParallel("CM\r", "1AM\r", "2AM\r").then( values => {
		watchDog.eventLog('testParallelSend:Succes: ' + values);
	}).catch( error => {
		watchDog.eventLog('testParallelSend:Error: ' + error );
	});

}

// While the server runs, it will have to keep track of which groups need to be disabled at any given time.
// Tracking that state, is outside of the scope of this library, so far.
// This function demonstrates a pattern that can be used to make use of that information however.
// It is assumed this tfucntionality will be called before each time we tell the SPM to play a show.
// This gives, us a brute force way to assure, the SPM is in the correct state.
// If we could detect the SPM rebooting with high confidence, we might not need to do this every time.
// This added overhead, should not impose too much delay, so so far there is not a lot of motivation to find that solution.
function testAutomatedDisableGroups()
{
	// Determine what groups should be disabled.
	// We fake it here with an array of groups that should be disabled.

	var disableGroupsArray = [1, 2, 2];


	//setDisableGroups
	setDisableGroups(...disableGroupsArray).then( values => {
		watchDog.eventLog('testAutomatedDisableGroups:Succes: ' + values);
	}).catch( error => {
		watchDog.eventLog('testAutomatedDisableGroups:Error: ' + error );
	});

}



// Test functions, convert to reusable. Send specific messages
function sendClearMaskReliable(){

	    sendMessageReliable( "CM\r").then((res) => {
        //console.log(res)
        watchDog.eventLog('sendClearMaskReliable:SuccessfulTransmit:' + res)
    }).catch(err => {
        //console.error(err)
        watchDog.eventLog('sendClearMaskReliable:Failedtransmit:' + err)
    });

}

// disableGroup is a number.
function sendAddMaskReliable( disableGroup ){

	var msg = disableGroup + "AM\r";

	watchDog.eventLog('sendAddMaskReliable:Begin:disableGroup: ' + disableGroup);

	sendMessageReliable(msg).then((res) => {
        //console.log(res)
        watchDog.eventLog('sendAddMaskReliable:SuccessfulTransmit:' + res)
    }).catch(err => {
        //console.error(err)
        watchDog.eventLog('sendAddMaskReliable:Failedtransmit:' + err)
    });

}

function send1AMReliable()
{

	sendAddMaskReliable(1);
}






// Operational Interface Functions
//		These functions should be called by other modules, to set or monitor the SPM and it's state.


// Takes a variable, list of arguments. Each being a number corresponding to a disable group that needs to be set.
// Parameters: (group1, group2, group3, ... )
function setDisableGroups()
{
	return new Promise((resolve, reject) => {

		var msgArray = [];
		var promiseArray = [];

		
		// Send CM, then send any needed AMs.

		var cmPromise = sendMessageReliable("CM\r").then( res => {

			if ( arguments.length == 0)
			{	
				// No Disable groups need to be set, all we needed to send was a CM.
				watchDog.eventLog('setDisableGroups:Success: 0 disableGroups requested, 0 disableGroups sent.');
				resolve('setDisableGroups:Success: 0 disableGroups requested, 0 disableGroups sent.');
			}

			// Only send AMs after the CM has been ACKed.
			for (i = 0; i < arguments.length; i++) {

				let tmpMsg = arguments[i] + "AM\r";
				msgArray.push(tmpMsg);
    		
    			promiseArray.push(sendMessageReliable(tmpMsg));
  			}

  			watchDog.eventLog('setDisableGroups:msgs: ' + JSON.stringify(msgArray));
  			watchDog.eventLog('setDisableGroups:promiseArray: ' + JSON.stringify(promiseArray[0]));

  			var msgAll = Promise.all(promiseArray).then(values => { 
  			//var msgAll = Promise.all([promiseArray[0], promiseArray[1], promiseArray[2]]).then(values => { 

  				watchDog.eventLog('setDisableGroups:msgAll:Success:values: ' + values);
  				//console.log(values);
  				resolve(values);
			}).catch(error => { 
				watchDog.eventLog('setDisableGroups:msgAll:Error:' + error);
  				//console.error(error.message)
  				reject(error);
			});

		}).catch( err => {		// cmPromise

			reject('setDisableGroups:cmPromise:Error:Failed to send CM:error: ' + err );
		}); // catch cmPromise

		

  		


  	}); // return
}











// Lower Level Functions Message Sending Functions.
//	Typically these should only be called from within this module.


// Returns a promise, once all messages have been sent successfully it will resolve.
// If one of the messages fails, the entire promise will reject()
// Parameters: (msg1, msg2, msg3, )
function sendMessagesInParallel()
{
	return new Promise((resolve, reject) => {
		watchDog.eventLog('sendTheseParallelPromise:Begin');

		if ( arguments.length == 0)
		{
			// should we resolve, or reject?
			resolve('sendTheseParallelPromise:Succes: 0 messages requested, 0 messages sent.');
		}

		
		// build array of msgs to be sent.
		let msgArray = [];
		var promiseArray = [];
		for (i = 0; i < arguments.length; i++) {
			msgArray.push(arguments[i]);
    		//sum += arguments[i];
    		promiseArray.push(sendMessageReliable(arguments[i]));
  		}

  		watchDog.eventLog('sendTheseParallelPromise:msgs: ' + JSON.stringify(msgArray));
  		watchDog.eventLog('sendTheseParallelPromise:promiseArray: ' + JSON.stringify(promiseArray[0]));
  		
  		//let msgAll = promise.all(promiseArray).then(values => { 
  		var msgAll = Promise.all([promiseArray[0], promiseArray[1], promiseArray[2]]).then(values => { 

  			watchDog.eventLog('sendTheseParallelPromise:Success:values: ' + values);
  			//console.log(values);
  			resolve(values);
		}).catch(error => { 
			watchDog.eventLog('sendTheseParallelPromise:Error:' + error);
  			//console.error(error.message)
  			reject(error);
		});


  	});
}





function sendMessageReliable( message )
{

    return new Promise((resolve, reject) => {

    	// TODO: message valid test 
    	// 	Add valid message test, reject if not valid.
    	//	similar to a guard statement, but Promisey
    	//	check for ends in "\r"
    	//	is message on supported list

    	sendMessageWithRetry( message, NUMBER_OF_RELIABLE_RETRIES, 1).then((res) => {
        //console.log(res)
        watchDog.eventLog('sendMessageReliable:SuccessfulTransmit:msg:' + message + ':response: ' + res);
        resolve(res);
    }).catch(err => {
        //console.error(err)
        watchDog.eventLog('sendMessageReliable:FailedAllTransmits:msg:' + message + ':response: ' + err)
        reject(err);
    });


    });// return
}

function sendMessageWithRetry( message, retryCountLimit, currentTries = 1) {
  return new Promise((resolve, reject) => {
    watchDog.eventLog('sendMessageWithRetry:Begin:message:' + message + ' :currentTries: ' + currentTries);
    if (currentTries <= retryCountLimit) {
      //const timeout = (Math.pow(2, currentTries) - 1) * 100;
      const timeout = 10;
      sendMessagePromise(message, currentTries)
        .then(resolve)
        .catch((error) => {
          //setTimeout(() => {
            //console.log('sendClearMaskWithRetry:TimoutError: ', error);
            //console.log(`Waiting ${timeout} ms`);
            watchDog.eventLog('sendMessageWithRetry:message:' + message + ' :Timout:Error: ' + error);
            //watchDog.eventLog(`sendClearMaskWithRetry:Timout:Waiting ${timeout} ms`);
            watchDog.eventLog('sendMessageWithRetry:message:' + message + 'Timout:currentTries: ' + currentTries);
            sendMessageWithRetry( message, retryCountLimit, currentTries + 1).then(resolve).catch(reject);
          //}, timeout);
        }); // catch
    } else {
      //console.log('No retries left, giving up.');
      watchDog.eventLog('sendMessageWithRetry:message: ' + message + ':No retries left, giving up.');
      reject('No retries left, giving up.');
    }
  });
}





function sendMessagePromise( original_message, sendAttempt )
{
	var sendMsg = original_message;    //"CM\r"
    var sendClient = dgram.createSocket('udp4');

	return new Promise((resolve, reject) => {

    	


    	sendClient.on('message', function(message, remote) {

        	// Expect an "R" to come back
        	watchDog.eventLog('sendMessagePromise:sendAttempt: ' + sendAttempt+ ' :UDP Msg Reply: ' + remote.address + ':' + remote.port +' - ' + 'Reply to message' + ' : '+ original_message + ':' +message);
        	//watchDog.eventLog('sendMessagePromise:UDP Msg Reply: ' + remote.address + ':' + remote.port +' - ' + 'Reply to: ' + original_message + ' : ' +message);
        
        	resolve(message);
    	}); //on


    	setTimeout(() => {
      		
      		reject(`sendClient:Ack:Timeout:message: ' + message + ' :sendAttempt: ${sendAttempt}`);
    	}, sendAttempt*BASE_MESSAGE_TIMEOUT);

    	sendClient.send(sendMsg, 0, sendMsg.length, spmPort, spmIP, function(err, bytes) {
        	
        	if (err) return Promise.reject(err);

        	watchDog.eventLog('sendMessagePromise:UDP message '+sendMsg + ' :sendAttempt: ' + sendAttempt + ' sent to ' + spmIP +':'+ spmPort);
        	//client.close();
    	}); // send

  	}).catch( (error) => {

        // Timeout occured on a single message
        
        watchDog.eventLog('sendMessagePromise:message: ' + original_message + ' :sendAttempt: ' + sendAttempt + ' :TimeOut:Error:'+ error );
        //clearClient.close();
        //reject(error);
        return Promise.reject(error);

    }).finally( () => {
    	watchDog.eventLog('sendMessagePromise:finally: ' + original_message + ' :sendAttempt: ' + sendAttempt);
    	// clean up resources.
    	sendClient.close();

    });

}






module.exports.clearDisableGroupsMsg = testAutomatedDisableGroups; //testParallelSend;	//sendClearMaskReliable;
module.exports.setDisableGroupMsg = send1AMReliable;