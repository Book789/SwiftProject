//
//  ReachableNetWork.swift
//  Start
//
//  Created by cloud on 2023/10/31.
//

import CoreTelephony
import SystemConfiguration
import Alamofire

let NotReachable = "notReachable"

class ReachableNetWork: NSObject {
    
    var reachabilityManager = NetworkReachabilityManager.default

     init() {
        // 监听网络状态变化
        reachabilityManager?.startListening { status in
            switch status {
            case .notReachable: break
                print("无网络")
            case .reachable(let type):
                print("有网络")
            case .unknown:break
                print("未知网络")
            }
        }
        reachabilityManager?.stopListening()
    }

    /// 获取网络类型
   class func getNetworkType() -> String {
            var zeroAddress = sockaddr_storage()
            bzero(&zeroAddress, MemoryLayout<sockaddr_storage>.size)
            zeroAddress.ss_len = __uint8_t(MemoryLayout<sockaddr_storage>.size)
            zeroAddress.ss_family = sa_family_t(AF_INET)
            let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { address in
                    SCNetworkReachabilityCreateWithAddress(nil, address)
                }
            }
            guard let defaultRouteReachability = defaultRouteReachability else {
                return NotReachable
            }
            var flags = SCNetworkReachabilityFlags()
            let didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags)
            
            guard didRetrieveFlags == true,
                  (flags.contains(.reachable) && !flags.contains(.connectionRequired)) == true
            else {
                return NotReachable
            }
            if flags.contains(.connectionRequired) {
                return NotReachable
            } else if flags.contains(.isWWAN) {
                return self.cellularType()
            } else {
                return "WiFi"
            }
        }
        
        /// 获取蜂窝数据类型
    class func cellularType() -> String {
            let info = CTTelephonyNetworkInfo()
            var status: String
            
            if #available(iOS 12.0, *) {
                guard let dict = info.serviceCurrentRadioAccessTechnology,
                      let firstKey = dict.keys.first,
                      let statusTemp = dict[firstKey] else {
                    return NotReachable
                }
                status = statusTemp
            } else {
                guard let statusTemp = info.currentRadioAccessTechnology else {
                    return NotReachable
                }
                status = statusTemp
            }
            
            if #available(iOS 14.1, *) {
                if status == CTRadioAccessTechnologyNR || status == CTRadioAccessTechnologyNRNSA {
                    return "5G"
                }
            }
            
            switch status {
            case CTRadioAccessTechnologyGPRS,
                CTRadioAccessTechnologyEdge,
            CTRadioAccessTechnologyCDMA1x:
                return "2G"
            case CTRadioAccessTechnologyWCDMA,
                CTRadioAccessTechnologyHSDPA,
                CTRadioAccessTechnologyHSUPA,
                CTRadioAccessTechnologyeHRPD,
                CTRadioAccessTechnologyCDMAEVDORev0,
                CTRadioAccessTechnologyCDMAEVDORevA,
            CTRadioAccessTechnologyCDMAEVDORevB:
                return "3G"
            case CTRadioAccessTechnologyLTE:
                return "4G"
            default:
                return NotReachable
            }
        }
}



