//
//  HttpManager+UploadVideo.swift
//  Start
//
//  Created by cloud on 2023/5/25.
//

import Foundation
import Alamofire
import Qiniu


extension HttpManager {
    /**
    - parameter videoPath:   视频路径
    - parameter completedCallBack: 结果回调
    */
    class func uploadVideo(
        _ videoPath:String,
        _ token:String,
        _ progress:@escaping QNUpProgressHandler,
        completedCallBack:@escaping ResultComplete){
            
            let uploadOption = QNUploadOption.init { key, percent in
                // percent 为上传进度
                progress(key,percent)
            }
            
            let fileManager = FileManager.default
            let urlString = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
            let documentDirectory:NSURL = urlString.first! as NSURL
            
            let fileurl:NSURL = documentDirectory.appendingPathComponent("upprogress")! as NSURL

            let upManager = QNUploadManager.init(recorder: fileurl as? QNRecorderDelegate)
            
            let date = Date()
            let time = (date.timeIntervalSince1970)
          
            let  formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd"
            let dates = formatter.string(from: date)
            let key = ""
//            let key = String(format:"video/%@/%0.f",dates,time*100000) + (S_UserInfoLocal.sharedInstance.userInfoModel?.uid.description ?? "") + ".mp4"
            
            upManager!.putFile(videoPath, key: key, token: token, complete: { info,key,resp in
                
                if (info?.statusCode == 200 && resp != nil){
                    //上传完毕
                    let data = S_ProjectConfig.sharedInstance.QiniuDomainURL+"/" + (resp?["key"] as? String ?? "")
                    completedCallBack(data,nil)
                    
                }else{
                    //失败
                    let error = NSError(domain: NSCocoaErrorDomain, code: 501,userInfo: [NSLocalizedDescriptionKey:resp?["message"] as? String ?? "上传失败"])
                    completedCallBack(nil,json)
                }
                
            }, option: uploadOption)
            
        }
}

