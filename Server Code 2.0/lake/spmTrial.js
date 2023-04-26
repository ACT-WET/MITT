// verify state of device in question

//id(1) = clearMsg
//id(2) = verifyMsg
//id(3) = addMsg
//id(4) = loadMsg

var dgram = require('dgram');
var spmPort = 9556;
var spmIP = "10.0.4.201";
var spmMsg = "";

function sendPacketstoSPM(num,msgid){
    
    var clearMsg = "CM\r"
    var verifyMsg = num+"?V\r"
    var addMsg = num+"AM\r"
    var loadMsg = num+"LM\r"
    var disableMsg = num+"CM\r"

    switch (msgid){
        case 1: spmMsg = clearMsg;  break;
        case 2: spmMsg = verifyMsg;  break;
        case 3: spmMsg = addMsg;  break;
        case 4: spmMsg = loadMsg;  break; 
        case 5: spmMsg = disableMsg;  break;        
    }

    var spmudpClient = dgram.createSocket('udp4');

    spmudpClient.on('message', function(message, remote) {

        // Expect an "R" to come back
        watchDog.eventLog('UDP Msg Reply: ' + remote.address + ':' + remote.port +' - ' + 'Reply to MaskMsg' + ' : ' +message);
        spmudpClient.close();
    });

    spmudpClient.send(spmMsg, 0, spmMsg.length, spmPort, spmIP, function(err, bytes) {
        if (err) throw err;
        watchDog.eventLog('UDP message '+spmMsg +' sent to ' + spmIP +':'+ spmPort);
        //client.close();
    });


}

module.exports.sendPacketstoSPM = sendPacketstoSPM; 