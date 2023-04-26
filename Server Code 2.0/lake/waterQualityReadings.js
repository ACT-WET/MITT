function waterQualityWrapper(){

  //console.log("Water Quality script triggered");

  var date = new Date();
  var time = date.getFullYear() + "."+  ((date.getMonth() + 1) < 10 ? "0" :"") + (date.getMonth() + 1) + "." + (date.getDate() < 10 ? "0" : "") + date.getDate() + " " + (date.getHours() < 10 ? "0" : "") + date.getHours() + ":" + (date.getMinutes() < 10 ? "0" : "") + date.getMinutes() + ":" + (date.getSeconds() < 10 ? "0" : "") + date.getSeconds();

  var wq1PH;
  var wq1ORP;
  var wq1TDS;
  var wq1BR;

  var dwq1PH;
  var dwq1ORP;
  var dwq1TDS;
  var dwq1BR;

  if (ATALPLCConnected){
    // if ((date.getSeconds() === 1) || (date.getSeconds() === 11) || (date.getSeconds() === 21) || (date.getSeconds() === 31) || (date.getSeconds() === 41) || (date.getSeconds() === 51)) {
    atalplc_client.readHoldingRegister(300, 2, function(resp){

      wq1PH =  parseFloat( Number( parseFloat("" + back2Real(resp.register[0], resp.register[1]) + "").toFixed(1) ) );
      
      atalplc_client.readHoldingRegister(310, 2, function(resp){
        wq1ORP = parseFloat( Number( parseFloat("" + back2Real(resp.register[0], resp.register[1]) + "").toFixed(1) ) );

        atalplc_client.readHoldingRegister(320, 2, function(resp){
          wq1TDS = parseFloat( Number( parseFloat("" + back2Real(resp.register[0], resp.register[1]) + "").toFixed(1) ) );

          atalplc_client.readCoils(332,1,function(resp){
            wq1BR= (resp.coils[0]) ? 1 : 0;

            //"LIVE" data
            //sampling frequency is once every second
            //collect and display only 15 mins worth data
            if (wq1_Live["ph"].length > 900) {
              wq1_Live["ph"].shift();
              wq1_Live["orp"].shift();
              wq1_Live["tds"].shift();
              wq1_Live["br"].shift();
              wq1_Live["date"].shift();
            }

            wq1_Live["ph"].push(wq1PH);
            wq1_Live["orp"].push(wq1ORP);
            wq1_Live["tds"].push(wq1TDS);
            wq1_Live["br"].push(wq1BR);
            wq1_Live["date"].push(time);

          }); 
        });
      });
    });
 // }
} 

if (ATDEPLCConnected){
    // if ((date.getSeconds() === 1) || (date.getSeconds() === 11) || (date.getSeconds() === 21) || (date.getSeconds() === 31) || (date.getSeconds() === 41) || (date.getSeconds() === 51)) {
    atdeplc_client.readHoldingRegister(300, 2, function(resp){

      dwq1PH =  parseFloat( Number( parseFloat("" + back2Real(resp.register[0], resp.register[1]) + "").toFixed(1) ) );
      
      atdeplc_client.readHoldingRegister(310, 2, function(resp){
        dwq1ORP = parseFloat( Number( parseFloat("" + back2Real(resp.register[0], resp.register[1]) + "").toFixed(1) ) );

        atdeplc_client.readHoldingRegister(320, 2, function(resp){
          dwq1TDS = parseFloat( Number( parseFloat("" + back2Real(resp.register[0], resp.register[1]) + "").toFixed(1) ) );

          atdeplc_client.readCoils(332,1,function(resp){
            dwq1BR= (resp.coils[0]) ? 1 : 0;

            //"LIVE" data
            //sampling frequency is once every second
            //collect and display only 15 mins worth data
            if (dwq1_Live["ph"].length > 900) {
              dwq1_Live["ph"].shift();
              dwq1_Live["orp"].shift();
              dwq1_Live["tds"].shift();
              dwq1_Live["br"].shift();
              dwq1_Live["date"].shift();
            }

            dwq1_Live["ph"].push(dwq1PH);
            dwq1_Live["orp"].push(dwq1ORP);
            dwq1_Live["tds"].push(dwq1TDS);
            dwq1_Live["br"].push(dwq1BR);
            dwq1_Live["date"].push(time);

          }); 
        });
      });
    });
 // }
}  

function back2Real(low, high){
  var fpnum=low|(high<<16);
  var negative=(fpnum>>31)&1;
  var exponent=(fpnum>>23)&0xFF;
  var mantissa=(fpnum&0x7FFFFF);
  if(exponent==255){
   if(mantissa!==0)return Number.NaN;
   return (negative) ? Number.NEGATIVE_INFINITY :
         Number.POSITIVE_INFINITY;
  }
  if(exponent===0)exponent++;
  else mantissa|=0x800000;
  exponent-=127;
  var ret=(mantissa*1.0/0x800000)*Math.pow(2,exponent);
  if(negative)ret=-ret;
  return ret;
}

function avg1min(totalArray){

  //watchDog.eventLog("totalArray: " +totalArray);
  //watchDog.eventLog("Array Length: " +totalArray.length);
  
  var avg = 0;
  if (totalArray.length > 60){
    for (var i=0; i <= 60 ; i++){
      avg += totalArray[i];
    }
    avg = avg/60;
  }
  else{
    for (var i=0; i <= (totalArray.length-1) ; i++){
      avg += totalArray[i];
    }
    avg = avg/(totalArray.length-1);
  }
  return avg;
}

}

module.exports=waterQualityWrapper;