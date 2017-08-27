var JSBridge = {
    /*
    *调取原生的方法
    */
	callNativeFunc:function(methodName,params,callBack){
		var methodName = (methodName.replace(/function\s?/mi,"").split("("))[0];
        var message;
        // 没有回调
        if (!callBack) {
        	message = {
        		'methodName':methodName,
		        	'params':params
	        };
        }else{
            var callBackName =methodName + 'CallBack';
            /*有回调*/
        	message = {
        		'methodName':methodName,
		        	'params':params,
              'callBackName':callBackName
	        };
	        if (!Event._listeners[callBackName]) {
	        	Event.addEvent(callBackName,callBack)
	        }
        }
        /*向原生发送消息*/
        window.webkit.messageHandlers.JSBridgeHandle.postMessage(JSON.stringify(message));
	},

	callBack:function(callBackName,data,callType){
		Event.fireEvent(callBackName,data,callType);
	},

	removeAllCallBacks:function(data) {
		Event._listeners = {};
	}

}
var Event = {
    _listeners: {},
    addEvent: function(type, fn) {
        if (typeof this._listeners[type] === "undefined") {
            this._listeners[type] = [];
        }
        if(fn != null){
            this._listeners[type].push(fn);
        }
        return this;
    },
    fireEvent: function(type,param,callType) {
        var arrayEvent = this._listeners[type];
        if (arrayEvent instanceof Array) {
            for (var i=0, length=arrayEvent.length; i<length; i+=1) {
                if (typeof arrayEvent[i] === "function") {
                    arrayEvent[i](param);
                }else{
                    var func = eval(arrayEvent[i]);
                    if(callType == "fail"){
                        func.fail(param);
                    }else if(callType == "success"){
                        func.success(param);
                    }
                }
            }
        }
        return this;
    },
    
    removeEvent: function(type, fn) {
        var arrayEvent = this._listeners[type];
        if (typeof type === "string" && arrayEvent instanceof Array) {
            if (typeof fn === "function") {
                for (var i=0, length=arrayEvent.length; i<length; i+=1){
                    if (arrayEvent[i] === fn){
                        this._listeners[type].splice(i, 1);
                        break;
                    }
                }
            } else {
                delete this._listeners[type];
            }
        }
        
        return this;
    }
};
