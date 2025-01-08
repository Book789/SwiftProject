//
//
import Foundation
import Alamofire
import SSZipArchive


extension HttpManager {
    
    /**
    - parameter url:   下载链接
    - parameter saveFileName:   自定义名称
    - parameter pathExtension:  下载的 文件后缀
    - parameter completedCallBack: 结果回调
    */
    class func download(
        _ urlPath:String,
        _ saveFileName:String,
        _ pathExtension: String,
        _ progressHandle:@escaping ProgressHandler,
        completedCallBack:@escaping ResultComplete){
            
            let destination: DownloadRequest.Destination = { _, _ in
                var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                documentsURL.appendPathComponent(saveFileName+"."+pathExtension)
                return (documentsURL, [.removePreviousFile, .createIntermediateDirectories])
            }

            Alamofire.AF.download(urlPath,to:destination).downloadProgress{ progress in
                print(progress.fractionCompleted)
                progressHandle(progress.fractionCompleted)
            }.response{ response in
                if response.error == nil {
                    guard let desUrl = response.fileURL else {return}
                    let path = kAssets
//                    path += "\(saveFileName)/"
                    let pathURL = URL(fileURLWithPath: path)
                    do {
                        try FileManager.default.createDirectory(at: pathURL, withIntermediateDirectories: true, attributes: nil)
                        print("解压路径：\(pathURL.path)")
                    } catch let err {
                        print(err.localizedDescription)
                    }
                    let urlStr = desUrl.absoluteString
                    print("源文件路径：\(urlStr)")
                    let done = SSZipArchive.unzipFile(atPath: urlStr.replacingOccurrences(of: "file://", with: ""), toDestination: path)//解压,两个参数一个是文件的路径,一个是解压后的位置
                    if done {
                        print("解压成功")
                        completedCallBack([],nil)
                        //清除压缩包
                        try? FileManager.default.removeItem(atPath: urlStr)
                    }else{
                        print("解压失败")
//                        completedCallBack(nil,NSError(domain: NSCocoaErrorDomain, code: 409,userInfo: [NSLocalizedDescriptionKey:"文件解压失败"]))
                    }
                }else{
//                    completedCallBack(nil, HttpManager.sharedInstance.error(error: response.error!) as? Error)
                }
            }
        }
}
