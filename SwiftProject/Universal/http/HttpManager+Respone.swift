//
//  HttpRespone.swift
//  Start
//
//  Created by Book on 2023/4/24.
//

import Foundation
import Alamofire

typealias FailureHandler = (_ error: Error) -> Void

extension Alamofire.DataRequest{
    
    func responseObject(success: ((_ value:AnyObject?) -> Void)?,
                                     failure: FailureHandler?){
       respose(DataResponseSerializer(), success: success, failure: failure)
    }
    private func respose(_ serializer:DataResponseSerializer,success:((_ value:AnyObject) -> Void)?,failure: FailureHandler?){
        response(responseSerializer: serializer) { (response) in
            print("request = \(String(describing:response.request?.url?.absoluteString))\nresponse = \(String(describing: response.request?.allHTTPHeaderFields))\n,data = \(String(describing: response.data?.dataToJSON()))")
            switch response.result{
            case .success(let value):
                self.vaildResponseData(data: response.data, success: success,failure: failure)
            case .failure(let error):
                failure?(error as Error)
            }
        }
    }
    
    private func vaildResponseData(data:Data?,success:((_ value:AnyObject) -> Void)?,failure: FailureHandler?){
        
        guard let respondData = data else {
            let error = HttpNetworkError.responseDataNilFailed
            failure?(error)
            return
        }
        guard let json = respondData.dataToJSON() else {
            let error = HttpNetworkError.jsonEncodFailed
            failure?(error)
            return
        }
        if json["code"] as! Int==200{
            success?(json)
        }
        let error = HttpNetworkError.responseDataNilFailed
        failure?(error)
        
        if json["code"] as! Int==403{
            
            //
//            S_UserInfoLocal.exitLogin()
            failure?(NSError(domain: NSCocoaErrorDomain, code: json["code"]as! Int,userInfo: [NSLocalizedDescriptionKey:""]))
            return
        }
        if json["code"] as! Int==500{
            failure?(NSError(domain: NSCocoaErrorDomain, code: json["code"]as! Int,userInfo: [NSLocalizedDescriptionKey:json["message"] as? String ?? "服务器异常繁忙，请稍后再试"]))
            return
        }
    }
}
