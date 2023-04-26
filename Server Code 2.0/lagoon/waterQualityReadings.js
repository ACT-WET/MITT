function waterQualityWrapper(){

  //console.log("Water Quality script triggered");

  var date = new Date();
  var time = date.getFullYear() + "."+  ((date.getMonth() + 1) < 10 ? "0" :"") + (date.getMonth() + 1) + "." + (date.getDate() < 10 ? "0" : "") + date.getDate() + " " + (date.getHours() < 10 ? "0" : "") + date.getHours() + ":" + (date.getMinutes() < 10 ? "0" : "") + date.getMinutes() + ":" + (date.getSeconds() < 10 ? "0" : "") + date.getSeconds();

  var wq1PH;
  var wq1ORP;
  var wq1TDS;
  var wq1BR;

  var swq1PH;
  var swq1ORP;
  var swq1TDS;
  var swq1BR;

  var gwq1PH;
  var gwq1ORP;
  var gwq1TDS;
  var gwq1BR;

  if (ATHOPLCConnected){
    // if ((date.getSeconds() === 1) || (date.getSeconds() === 11) || (date.getSeconds() === 21) || (date.getSeconds() === 31) || (date.getSeconds() === 41) || (date.getSeconds() === 51)) {
    athoplc_client.readHoldingRegister(300, 2, function(resp){

      wq1PH =  parseFloat( Number( parseFloat("" + back2Real(resp.register[0], resp.register[1]) + "").toFixed(1) ) );
      
      athoplc_client.readHoldingRegister(310, 2, function(resp){
        wq1ORP = parseFloat( Number( parseFloat("" + back2Real(resp.register[0], resp.register[1]) + "").toFixed(1) ) );

        athoplc_client.readHoldingRegister(320, 2, function(resp){
          wq1TDS = parseFloat( Number( parseFloat("" + back2Real(resp.register[0], resp.register[1]) + "").toFixed(1) ) );

          athoplc_client.readCoils(332,1,function(resp){
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

if (ATSUPLCConnected){
    // if ((date.getSeconds() === 1) || (date.getSeconds() === 11) || (date.getSeconds() === 21) || (date.getSeconds() === 31) || (date.getSeconds() === 41) || (date.getSeconds() === 51)) {
    atsuplc_client.readHoldingRegister(300, 2, function(resp){

      swq1PH =  parseFloat( Number( parseFloat("" + back2Real(resp.register[0], resp.register[1]) + "").toFixed(1) ) );
      
      atsuplc_client.readHoldingRegister(310, 2, function(resp){
        swq1ORP = parseFloat( Number( parseFloat("" + back2Real(resp.register[0], resp.register[1]) + "").toFixed(1) ) );

        atsuplc_client.readHoldingRegister(320, 2, function(resp){
          swq1TDS = parseFloat( Number( parseFloat("" + back2Real(resp.register[0], resp.register[1]) + "").toFixed(1) ) );

          atsuplc_client.readCoils(332,1,function(resp){
            swq1BR= (resp.coils[0]) ? 1 : 0;

            //"LIVE" data
            //sampling frequency is once every second
            //collect and display only 15 mins worth data
            if (swq1_Live["ph"].length > 900) {
              swq1_Live["ph"].shift();
              swq1_Live["orp"].shift();
              swq1_Live["tds"].shift();
              swq1_Live["br"].shift();
              swq1_Live["date"].shift();
            }

            swq1_Live["ph"].push(swq1PH);
            swq1_Live["orp"].push(swq1ORP);
            swq1_Live["tds"].push(swq1TDS);
            swq1_Live["br"].push(swq1BR);
            swq1_Live["date"].push(time);

          }); 
        });
      });
    });
 // }
} 

if (ATGLPLCConnected){
    // if ((date.getSeconds() === 1) || (date.getSeconds() === 11) || (date.getSeconds() === 21) || (date.getSeconds() === 31) || (date.getSeconds() === 41) || (date.getSeconds() === 51)) {
    atglplc_client.readHoldingRegister(300, 2, function(resp){

      gwq1PH =  parseFloat( Number( parseFloat("" + back2Real(resp.register[0], resp.register[1]) + "").toFixed(1) ) );
      
      atglplc_client.readHoldingRegister(310, 2, function(resp){
        gwq1ORP = parseFloat( Number( parseFloat("" + back2Real(resp.register[0], resp.register[1]) + "").toFixed(1) ) );

        atglplc_client.readHoldingRegister(320, 2, function(resp){
          gwq1TDS = parseFloat( Number( parseFloat("" + back2Real(resp.register[0], resp.register[1]) + "").toFixed(1) ) );

          atglplc_client.readCoils(332,1,function(resp){
            gwq1BR= (resp.coils[0]) ? 1 : 0;

            //"LIVE" data
            //sampling frequency is once every second
            //collect and display only 15 mins worth data
            if (gwq1_Live["ph"].length > 900) {
              gwq1_Live["ph"].shift();
              gwq1_Live["orp"].shift();
              gwq1_Live["tds"].shift();
              gwq1_Live["br"].shift();
              gwq1_Live["date"].shift();
            }

            gwq1_Live["ph"].push(gwq1PH);
            gwq1_Live["orp"].push(gwq1ORP);
            gwq1_Live["tds"].push(gwq1TDS);
            gwq1_Live["br"].push(gwq1BR);
            gwq1_Live["date"].push(time);

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