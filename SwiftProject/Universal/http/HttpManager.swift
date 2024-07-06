//
//  HttpManager.swift
//  TSWeChat
//
//  Created by Hilen on 11/3/15.
//  Copyright © 2015 Hilen. All rights reserved.
//

import UIKit
import Alamofire


public typealias ResultComplete = (Any?,Error?)->Void
 
class HttpManager: NSObject {
    
    class var sharedInstance : HttpManager {
        struct Static {
            static let instance : HttpManager = HttpManager()
        }
        return Static.instance
    }
    var timeout:TimeInterval = 15.00
    
    var baseURL = S_ProjectConfig.sharedInstance.domainURL!
    
    var httpHeaders:HTTPHeaders{
        get{
            return ["mac":App.uuid,"os":"ios","versionCode":App.appVersion,"model":UIDevice.current.localizedModel]
        }
    }

    
    fileprivate override init() {
        super.init()
        
    }
    
    
    class func GET(
        path: String,
        params: Parameters? = nil,
        completedCallBack:@escaping ResultComplete) -> Void {
            HttpManager.sharedInstance.request(path: path,method: .get,parameters: params, completedCallBack: completedCallBack)
    }
    class func POST(
        path: String,
        params: Parameters? = nil,
        completedCallBack:@escaping ResultComplete) -> Void {
            HttpManager.sharedInstance.request(path: path,method: .post,parameters: params, completedCallBack: completedCallBack)
    }
    
    class func GETJson(
        path: String,
        params: Parameters? = nil,
        completedCallBack:@escaping ResultComplete) -> Void {
            var  headers:HTTPHeaders = HttpManager.sharedInstance.httpHeaders
            headers.add(name: "Content-Type", value: "application/json")
            HttpManager.sharedInstance.request(path: path,method: .get,parameters: params, encoding: JSONEncoding.default,headers: headers,completedCallBack: completedCallBack)
    }
    class func POSTJson(
        path: String,
        params: Parameters? = nil,
        completedCallBack:@escaping ResultComplete) -> Void {
            var  headers:HTTPHeaders = HttpManager.sharedInstance.httpHeaders
            headers.add(name: "Content-Type", value: "application/json")
            HttpManager.sharedInstance.request(path: path,method: .post,parameters: params, encoding: JSONEncoding.default,headers: headers,completedCallBack: completedCallBack)
            
    }
    
    
    
    open func request(path: String,
                      method: HTTPMethod = .get,
                      parameters: Parameters? = nil,
                      encoding: ParameterEncoding = URLEncoding.default,
                      headers: HTTPHeaders? = HttpManager.sharedInstance.httpHeaders,
                      completedCallBack:@escaping ResultComplete) -> Void{
       
        Alamofire.AF.request(HttpManager.sharedInstance.baseURL + path,
                             method: method,
                             parameters: parameters,
                             encoding: encoding,
                             headers: headers,
               requestModifier: {$0.timeoutInterval = HttpManager.sharedInstance.timeout})
        .responseObject { value in
            completedCallBack(value,nil)
        } failure: { error in
            completedCallBack(nil,error)
        }
    }
    
    class func cancelAllRequests()-> () {
          Alamofire.AF.cancelAllRequests()
    }

}
