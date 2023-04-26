module.exports = function (val,addr,callback){    
    athoplc_client.writeSingleRegister(addr,val,function(resp){        
        if(typeof callback !== 'undefined'){callback();    
        }});
};