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
 
public typealias ProgressHandler = (CGFloat?)->Void



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
//MARK: 支持数组格式的数据上传
private let ArrayParametersKey = "ArrayParametersKey"
 
/// Extenstion that allows an array be sent as a request parameters
extension Array {
    /// Convert the receiver array to a `Parameters` object.
    func asParameters() -> Parameters {
        return [ArrayParametersKey: self]
    }
}
 
 
/// Convert the parameters into a json array, and it is added as the request body.
/// The array must be sent as parameters using its `asParameters` method.
public struct ArrayEncoding: ParameterEncoding {
 
    /// The options for writing the parameters as JSON data.
    public let options: JSONSerialization.WritingOptions
 
 
    /// Creates a new instance of the encoding using the given options
    ///
    /// - parameter options: The options used to encode the json. Default is `[]`
    ///
    /// - returns: The new instance
    public init(options: JSONSerialization.WritingOptions = []) {
        self.options = options
    }
 
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = try urlRequest.asURLRequest()
 
        guard let parameters = parameters,
            let array = parameters[ArrayParametersKey] else {
                return urlRequest
        }
 
        do {
            let data = try JSONSerialization.data(withJSONObject: array, options: options)
            if urlRequest.headers["Content-Type"] == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }

            urlRequest.setValue(S_UserInfoLocal.sharedInstance.userInfoModel?.token ?? "", forHTTPHeaderField: "Authorization")

 
            urlRequest.httpBody = data
 
        } catch {
            throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
        }
 
        return urlRequest
    }
}
