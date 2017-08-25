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
        jsAction(methodName: dic["methodName"] as? String , params: dic["params"] as? [String:Any] ?? [String:Any]() ,{ (response, resultType) in
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
                        print("methodName:\(dic["methodName"] as? String ?? "")\nparams:\(dic["params"] as? [String:Any] ?? [String:Any]())\ncallBackName:\(callBackName),JS=\(jscode)")
                        if (error != nil){
                            print("evaluateJavaScript:error  \(String(describing: error))")
                        }
                    })
                }
            }
        })
    }
    func jsAction(methodName : String?, params:[String:Any] = [String:Any](),_ callback:@escaping ((_ response:Any?,_ resultType:Bool)->()) ) {
        guard methodName != nil else {
            print("methodName为空")
            return
        }
        let diction = NSMutableDictionary(dictionary: params as NSDictionary)
        diction.setValue(callback, forKey: "callbackMethod")
            if responds(to: Selector("\(methodName ?? ""):")){
                self.perform(Selector("\(methodName ?? ""):"), with: diction )
        }
    }
    @objc func openBluetoothAdapter(_ params:[String:Any]) {
        print(params)
        if let callbackMethod =  params["callbackMethod"] as? ((_ response:Any?,_ resultType:Bool)->()){
            callbackMethod(["isSupportBLE":true],true)
        }
    }
}
