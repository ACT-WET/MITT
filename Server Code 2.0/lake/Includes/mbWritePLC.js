module.exports = function (val,addr,callback){    
    atalplc_client.writeSingleRegister(addr,val,function(resp){        
        if(typeof callback !== 'undefined'){callback();    
        }});
};