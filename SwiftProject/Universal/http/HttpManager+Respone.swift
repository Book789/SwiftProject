//
//  HttpRespone.swift
//  Start
//
//  Created by Book on 2023/4/24.
//

import Foundation
import Alamofire

typealias FailureHandler = (_ error: HttpNetworkError) -> Void

extension Alamofire.DataRequest{
    
    func responseObject(success: ((_ value:[String:AnyObject]?) -> Void)?,
                                     failure: FailureHandler?){
       respose(DataResponseSerializer(), success: success, failure: failure)
    }
    private func respose(_ serializer:DataResponseSerializer,success:((_ value:[String:AnyObject]) -> Void)?,failure: FailureHandler?){
        response(responseSerializer: serializer) { (response) in
            
            let metrics = response.metrics
            for transactionMetric in metrics?.transactionMetrics ?? [] {
                // 打印各个阶段的耗时
                if let fetchStartDate = transactionMetric.fetchStartDate, // 开始请求时间
                   let domainLookupStartDate = transactionMetric.domainLookupStartDate, // DNS 解析开始时间
                   let domainLookupEndDate = transactionMetric.domainLookupEndDate, // DNS 解析结束时间
                   let connectStartDate = transactionMetric.connectStartDate, // TCP 连接开始时间
                   let connectEndDate = transactionMetric.connectEndDate, // TCP 连接结束时间
                   let secureConnectionStartDate = transactionMetric.secureConnectionStartDate, // TLS 握手开始时间
                   let secureConnectionEndDate = transactionMetric.secureConnectionEndDate, // TLS 握手结束时间
                   let requestStartDate = transactionMetric.requestStartDate,  // 请求发送开始时间
                   let requestEndDate = transactionMetric.requestEndDate, // 请求发送结束时间
                   let responseStartDate = transactionMetric.responseStartDate, // 服务器处理开始时间
                   let responseEndDate = transactionMetric.responseEndDate { // 服务器处理结束时间
                    
                    let dnsTime = domainLookupEndDate.timeIntervalSince(domainLookupStartDate)
                    let connectTime = connectEndDate.timeIntervalSince(connectStartDate)
                    let tlsTime = secureConnectionEndDate.timeIntervalSince(secureConnectionStartDate)
                    let requestTime = requestEndDate.timeIntervalSince(requestStartDate)
                    let serverProcessingTime = responseStartDate.timeIntervalSince(requestEndDate)
                    let responseTime = responseEndDate.timeIntervalSince(responseStartDate)
                    
                    print("DNS 解析耗时: \(dnsTime) seconds")
                    print("TCP 连接时间: \(connectTime) seconds")
                    print("TLS 握手时间: \(tlsTime) seconds")
                    print("请求发送时间: \(requestTime) seconds")
                    print("服务端处理时间: \(serverProcessingTime) seconds")
                    print("服务器响应时间: \(responseTime) seconds")
                }
            }
            print("request = \(String(describing:response.request?.url?.absoluteString))\nresponse = \(String(describing: response.request?.allHTTPHeaderFields))\n,data = \(String(describing: response.data?.dataToJSON()))")
            switch response.result{
            case .success(_):
                self.vaildResponseData(data: response.data, success: success,failure: failure)
            case .failure(let error):
                let networkError = NetworkErrorHandler.handle(error)
                failure?(networkError)
            }
        }
    }
    
    private func vaildResponseData(data:Data?,success:((_ value:[String:AnyObject]) -> Void)?,failure: FailureHandler?){

        guard let respondData = data else {
            failure?(.noDataReceived)
            return
        }
        if(respondData.isEmpty){
            failure?(.emptyResponse)
            return
        }
        do {
            if let json = try JSONSerialization.jsonObject(with: respondData, options: []) as? [String : AnyObject] {
                
                let code = json["code"] as! Int
                if code == 200{
                    success?(json)
                }
                
//                let networkError = HttpNetworkError.custom(message: <#T##String#>, code: <#T##Int#>)
            }else{
                failure?(.invalidResponseData)
            }
        } catch {
            failure?(.jsonParsingFailed(error))
        }

    }
}
