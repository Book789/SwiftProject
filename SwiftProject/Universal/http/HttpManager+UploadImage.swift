//
//  HttpManager+UploadImage.swift
//  TSWeChat
//
//  Created by Hilen on 11/27/15.
//  Copyright © 2015 Hilen. All rights reserved.
//

import Foundation
import Alamofire
import Qiniu
//上传图片 ,multipartFormData 上传。key = attach

extension HttpManager {
    /**
    上传单张图片
    
    - parameter image:   UIImage
    - parameter completedCallBack: 结果回调
    */
    class func uploadSingleImage(
        _ image:UIImage,
        _ token:String,
        completedCallBack:@escaping ResultComplete){
            
            let key = ""
            let upManager = QNUploadManager()
            let time = (NSDate().timeIntervalSince1970)
//            let key = String(format:"head/%0.f", time*100000) + (S_UserInfoLocal.sharedInstance.userInfoModel?.uid.description ?? "")

            upManager?.put(image.jpegData(compressionQuality: 0.7), key: key, token: token, complete: { (info, key, resp) -> Void in
                if (info?.statusCode == 200 && resp != nil){
                    //上传完毕
                    let data = S_ProjectConfig.sharedInstance.QiniuDomainURL+"/" + (resp?["key"] as? String ?? "")
                    completedCallBack(data,nil)
                }else{
                    //失败
                    let json = NSError(domain: NSCocoaErrorDomain, code: 501,userInfo: [NSLocalizedDescriptionKey:resp!["message"] as! String])
                    completedCallBack(nil,json )
                }
            }, option: nil)
        }
    
    /**
    上传姿态评估图片
    
    - parameter image:   UIImage
    - parameter completedCallBack: 结果回调
    */
    class func uploadPostureImage(
        _ image:UIImage,
        _ token:String,
        completedCallBack:@escaping ResultComplete){
            
            let upManager = QNUploadManager()
            let time = (NSDate().timeIntervalSince1970)
            let key = ""
//            let key = String(format:"posture/%0.f", time*100000) + (S_UserInfoLocal.sharedInstance.userInfoModel?.uid.description ?? "")

            upManager?.put(image.jpegData(compressionQuality: 0.7), key: key, token: token, complete: { (info, key, resp) -> Void in
                if (info?.statusCode == 200 && resp != nil){
                    //上传完毕
//                    let data = S_ProjectConfig.sharedInstance.QiniuDomainURL+"/" + (resp?["key"] as? String ?? "")
//                    completedCallBack(data,nil)

                    
                }else{
                    //失败
                    let json = NSError(domain: NSCocoaErrorDomain, code: 501,userInfo: [NSLocalizedDescriptionKey:resp!["message"] as! String])
                    completedCallBack(nil,json )
                }
            }, option: nil)
        }
    
    class func uploadServerImage(
        _ image:UIImage,
        completedCallBack:@escaping ResultComplete){
           
            var  headers:HTTPHeaders = HttpManager.sharedInstance.httpHeaders
//            if S_UserInfoLocal.sharedInstance.userInfoModel != nil {
//                headers.add(name: "Authorization", value: S_UserInfoLocal.sharedInstance.userInfoModel!.token)
//            }

      
          let imageData = image.jpegData(compressionQuality: 0.7)
          /*
          这里需要填写上传图片的 API
          */
          let urlString = HttpManager.sharedInstance.baseURL + "/user/face/search"
          let params = Dictionary<String, Any>()
  
          Alamofire.AF.upload(multipartFormData: { multiPart in
              for p in params {
                  multiPart.append("\(p.value)".data(using: String.Encoding.utf8)!, withName: p.key)
              }
              multiPart.append(imageData!, withName: "file", fileName: NSDate().description + ".jpg", mimeType: "image/jpg")
          }, to: urlString, method: .post, headers: headers) .uploadProgress(queue: .main, closure: { progress in
              print("Upload Progress: \(progress.fractionCompleted)")
  //            progressClosure(progress.fractionCompleted)
  
          }).response { (response) in
//              switch response.result  {
//              case let .success(data):
//                  let json = HttpManager.sharedInstance.respone(data: data!)
//                  if json is NSError{
//                      completedCallBack(nil,json as! NSError)
//                  }else{
//                      completedCallBack(json,nil)
//                  }
//                  break
//              case let .failure(error):
//                  completedCallBack(nil,error)
//                  break
//              }
          }
            
        }

            
//        let parameters = [
//            "access_token": ""
//        ]
//
//        let imageData = image.jpegData(compressionQuality: 0.7)
//        /*
//        这里需要填写上传图片的 API
//        */
//        let urlString = ""
//        let params = Dictionary<String, Any>()
//
//        Alamofire.AF.upload(multipartFormData: { multiPart in
//            for p in params {
//                multiPart.append("\(p.value)".data(using: String.Encoding.utf8)!, withName: p.key)
//            }
//            multiPart.append(imageData!, withName: "attach", fileName: "1.jpg", mimeType: "image/jpg")
//        }, to: urlString, method: .post, headers: nil) .uploadProgress(queue: .main, closure: { progress in
//            print("Upload Progress: \(progress.fractionCompleted)")
////            progressClosure(progress.fractionCompleted)
//
//        }).response { (response) in
//            switch response.result {
//            case .success(let dataObj):
//                completedCallBack(dataObj,nil)
//            case .failure(let error):
//                print("upload err: \(error)")
//                completedCallBack(nil,error)
//
//            }
//        }

//    /**
//    上传多张图片
//
//    - parameter imagesArray: 图片数组
//    - parameter success:     返回图片数组 model,和图片逗号分割的字符串 "123123,23344,590202"
//    - parameter failure:     失败
//    */
//    class func uploadMultipleImages(
//        _ imagesArray:[UIImage],
//        success:@escaping (_ imageModel: [UploadImageModel], _ imagesId: String) ->Void,
//        failure:@escaping () ->Void)
//    {
//        guard imagesArray.count != 0 else {
//            assert(imagesArray.count == 0, "Invalid images array") // here
//            failure()
//            return
//        }
//
//        for image in imagesArray {
//            guard image.isKind(of: UIImage.self) else {
//                failure()
//                return
//            }
//        }
//
//
//        let resultImageIdArray = NSMutableArray()
//        let resultImageModelArray = NSMutableArray()
//
//        let emtpyId = ""
//        for _ in 0..<imagesArray.count {
//            resultImageIdArray.add(emtpyId)
//        }
//
//        let group = DispatchGroup()
//        var index = 0
//        for (image) in imagesArray {
//            group.enter();
//            self.uploadSingleImage(
//                image,
//                success: {model in
//                    let imageId = model.imageId
//                    resultImageIdArray.replaceObject(at: index, with: imageId!)
//                    resultImageModelArray.add(model)
//                    group.leave();
//                },
//                failure: {
//                    group.leave();
//                }
//            )
//            index += 1
//        }
//
//        group.notify(queue: DispatchQueue.main, execute: {
//            let checkIds = resultImageIdArray as NSArray as! [String]
//            for imageId: String in checkIds {
//                if imageId == emtpyId {
//                    failure()
//                    return
//                }
//            }
//
//            let ids = resultImageIdArray.componentsJoined(by: ",")
//            let images = resultImageModelArray as NSArray as! [UploadImageModel]
//            success(images, ids)
//        })
//    }
}




