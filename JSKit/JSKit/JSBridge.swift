//
//  JSBridge.swift
//  JSKit
//
//  Created by 谈超 on 2017/8/25.
//  Copyright © 2017年 谈超. All rights reserved.
//

import UIKit
import WebKit
import SwiftyJSON
import Foundation
let JSBridgeHandle = "JSBridgeHandle"
class JSBridge: NSObject {
    var webView : WKWebView?
    let handleJS : String = try! String(contentsOfFile: Bundle(for: JSBridge.self).path(forResource: "JSBridge", ofType: "js")!, encoding: .utf8)
    static let shared = JSBridge()
}
extension JSBridge : WKScriptMessageHandler{
    @available(iOS 8.0, *)
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == JSBridgeHandle else {return}
        guard let jsonData = (message.body as? String)?.data(using: .utf8, allowLossyConversion: false) else { return}
        guard let dic = JSON(data: jsonData).dictionaryObject else { return }
        jsaction(methodName: dic["methodName"] as? String , params: dic["params"] as? [String:Any] ?? [String:Any]() ,{ (response, resultType) in
            if let callBackName = dic["callBackName"] as? String{
                var jscode = ""
                if let result = response as? [String : Any]{
                    if let data = try? JSONSerialization.data(withJSONObject: result, options: JSONSerialization.WritingOptions.prettyPrinted){
                        jscode = "JSBridge.callBack\(callBackName,JSON(data: data),resultType ? "success":"fail")"
                    }
                }else if let result = response as? [Any]{
                    if let data = try? JSONSerialization.data(withJSONObject: result, options: JSONSerialization.WritingOptions.prettyPrinted){
                        jscode = "JSBridge.callBack\(callBackName,JSON(data: data),resultType ? "success":"fail")"
                    }
                }else{
                    jscode = "JSBridge.callBack\(callBackName,response,resultType ? "success":"fail")"
                }
                DispatchQueue.main.async {
                    self.webView?.evaluateJavaScript(jscode, completionHandler: { (data, error) in
                        JSLogger.debug("methodName:\(dic["methodName"] as? String ?? "")\nparams:\(dic["params"] as? [String:Any] ?? [String:Any]())\ncallBackName:\(callBackName),JS=\(jscode)")
                        if (error != nil){
                            JSLogger.debug("evaluateJavaScript:error  \(String(describing: error))")
                        }
                    })
                }
            }
        })
    }
    func jsaction(methodName : String?, params:[String:Any] = [String:Any](),_ callback:@escaping ((_ response:Any?,_ resultType:Bool)->()) ) {
        guard methodName != nil else {
            JSLogger.debug("methodName为空")
            return
        }
        let diction = NSMutableDictionary(dictionary: params as NSDictionary)
        diction.setValue(callback, forKey: "callbackMethod")
            if responds(to: Selector("\(methodName ?? ""):")){
                self.perform(Selector("\(methodName ?? ""):"), with: diction )
        }
    
    }
    @objc func openBluetoothAdapter(_ params:[String:Any]) {
        JSLogger.debug(params)
        if let callbackMethod =  params["callbackMethod"] as? ((_ response:Any?,_ resultType:Bool)->()){
            callbackMethod(["isSupportBLE":true],true)
        }
    }
}

fileprivate class JSLogger {
    
    public static let FATAL_LEVEL = 1000
    public static let ERROR_LEVEL = 900
    public static let WARN_LEVEL = 800
    public static let INFO_LEVEL = 700
    public static let DEBUG_LEVEL = 600
    public static let TRACE_LEVEL = 500
    
    public static var LOG_LEVEL = TRACE_LEVEL
    
    public static func debug(
        _ message: Any = "",
        file: String = #file,
        line: UInt = #line,
        function: String = #function) {
        if LOG_LEVEL <= DEBUG_LEVEL {
            log("DEBUG", message: message, file: file, line: line, function: function, verbose: true)
        }
    }
    
    public static func fatal(
        _ message: Any = "",
        file: String = #file,
        line: UInt = #line,
        function: String = #function) {
        
        if LOG_LEVEL <= FATAL_LEVEL {
            log("FATAL", message: message ,file: file, line: line, function: function, verbose: true)
        }
        
    }
    
    public static func error(
        _ message: Any = "",
        file: String = #file,
        line: UInt = #line,
        function: String = #function) {
        if LOG_LEVEL <= ERROR_LEVEL {
            log("ERROR", message: message, file: file, line: line, function: function, verbose: true)
        }
    }
    
    public static func warn(
        _ message: Any = "",
        file: String = #file,
        line: UInt = #line,
        function: String = #function) {
        if LOG_LEVEL <= WARN_LEVEL {
            log("WARN", message: message, file: file, line: line, function: function, verbose: true)
        }
    }
    
    public static func info(
        _ message: Any = "",
        file: String = #file,
        line: UInt = #line,
        function: String = #function) {
        if LOG_LEVEL <= INFO_LEVEL {
            log("INFO", message: message, file: file, line: line, function: function, verbose: true)
        }
    }
    
    public static func trace(
        _ message: Any = "",
        file: String = #file,
        line: UInt = #line,
        function: String = #function) {
        if LOG_LEVEL <= TRACE_LEVEL {
            log("TRACE", message: message, file: file, line: line, function: function, verbose: true)
        }
    }
    
    public static func log (
        _ prefix: String,
        message: Any = "",
        file: String = #file,
        line: UInt = #line,
        function: String = #function,
        verbose: Bool) {
        
        let aDateFormat = DateFormatter()
        aDateFormat.dateFormat = "YYYY-MM-dd hh:mm:ss"
        let time = aDateFormat.string(from: Date())
        
        var fileName = "Unknown File"
        if let theFileName = file.components(separatedBy: "/").last {
            fileName = theFileName
        }
        if verbose {
            print("[\(prefix)] \(time) IN \(fileName) LINE: \(line) FUNC: \(function) - \(message)")
        }else{
            print("[\(prefix)] \(time) \(message)")
        }
        
    }
}
