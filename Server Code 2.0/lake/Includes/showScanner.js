//-------------------------------SHOW SCAN NUMBERS------------------------//
//scanStatus = {"done":true , "progress": {"numShows": 0, "currentShow": 0}};
var testShowScan = require("./testshowScanner.js");
showNumArr = [];
function scanShows(){
    showNumArr[0] = 0;
    var tempShow = showNumArr[0];
    tmpshows  = [];
    spm_client.readHoldingRegister(7000,64,function(resp){
        var spmindex = 0;
        var  k = 1;
        for (var i=0; i < 64 ; i++){
            var a = resp.register[i];
            //watchDog.eventLog('A Value ' +JSON.stringify(a));
                var b = decToBin(a);
                //watchDog.eventLog('B Value ' +JSON.stringify(b));
                for ( var j =0; j < 16 ; j++){
                    //watchDog.eventLog('values ' +JSON.stringify(temp));
                    spmindex = spmindex + 1;
                    var temp = nthBit(b,j);
                    if (temp){
                        showNumArr[k] = spmindex;
                        k = k + 1;
                    } else {
                        tmpshows[spmindex]={"name":"-","number":spmindex,"duration":0,"color":1};
                    }
                }
        }
        
        scanStatus.progress.numShows = showNumArr.length;
        getShowDetails(tempShow,0);
    });
    
}

function getShowDetails(showNum,index){
    if (index < showNumArr.length){
        scanStatus.progress.currentShow = index + 1;
        spm_client.writeSingleRegister(1002,33792,function(resp){}); // kill all outputs disable sdx,dmx and smpte
            spm_client.writeSingleRegister(1004,0,function(resp){}); // zero-out load show register to accomodate high edge 
                spm_client.writeSingleRegister(1005,showNum,function(resp){}); // indicate show number
                    spm_client.writeSingleRegister(1004,8,function(resp){}); // issue load show command to load show register
                        spm_client.writeSingleRegister(1000,32,function(resp){});//stop show
                                spm_client.readHoldingRegister(2014,2,function(resp){
                                        var a = oddByte(resp.register[0]);
                                        var b = oddByte(resp.register[1]);
                                        var duration=a[1] + b[0]*60 + b[1]*3600;
                                        watchDog.eventLog('duration of '+showNum+' '+duration);  
                                        spm_client.readHoldingRegister(6000,24,function(name){     
                                            var nem='';
                                            name.register.every(function(elem){if(elem>0){oddByte(elem).every(function(elem1){nem+=String.fromCharCode(elem1);return true})}return true});
                                            watchDog.eventLog('show No '+showNum+' '+'is '+nem);  
                                            tmpshows[showNum]={"name":nem,"number":showNum,"duration":duration,"test":false,"color":1};
                                            getShowDetails(showNumArr[index + 1],index+1); 
                                        });                            
                                }); // read loaded show's name           
    }  else {
        writeToShowFile();
    }  
}

function writeToShowFile(){

    spm_client.writeSingleRegister(1002,0,function(resp){}); // enable outputs, set to no wind
            spm_client.writeSingleRegister(1005,0,function(resp){}); // indicate show number 0
                spm_client.writeSingleRegister(1004,0,function(resp){}); // zero-out load register to accomodate high edge
                    spm_client.writeSingleRegister(1004,8,function(resp){}); // load show 0
                        spm_client.writeSingleRegister(1004,0,function(resp){}); // zero-out load register to accomodate high edge 

    testShowScan();
}
// converts up to 16-bit binary (including 0 bit) to decimal 
function decToBin(fruit){
    var low=0;
    var high=0;
    for (k=0;k<16;k++){
        if(nthBit(fruit,k)){low+=Math.pow(2,k);}
    }
    
    return low;
}
//==== Return the value of the b-th of n 

function nthBit(n,b){

    var currentBit = 1 << b;

    if (currentBit & n){
        return 1;
    }

    return 0;
}
// converts up to 16-bit binary (including 0 bit) to decimal 
function oddByte(fruit){
    var low=0;
    var high=0;
    for (k=0;k<8;k++){
        if(nthBit(fruit,k)){low+=Math.pow(2,k);}
    }
    for (k=8;k<16;k++){
        if(nthBit(fruit,k)){high+=Math.pow(2,k-8);}
    }
    return [low,high];
}
module.exports=scanShows;