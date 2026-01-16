//
//  S_ClassifyFileManager.swift
//

import UIKit

class S_ClassifyFileManager: NSObject {

    
    static func writeToFileWithArray(responseArray:[Any],filepath:String){
        let data = try? NSKeyedArchiver.archivedData(withRootObject: responseArray, requiringSecureCoding: false)
        if(data != nil){
            self.writeToFileWithData(data: data!, path: filepath)
        }
    }
    static func readClassifyArrayWithPath(path:String)->[Any]{
        do {
            // 读取文件数据
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            // 使用NSKeyedUnarchiver解档数据
            if let array = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, NSString.self, NSNumber.self, NSDictionary.self, NSDate.self], from: data) as? [Any] {
                print("本地文件数组读取成功，共\(array.count)个元素")
                return array
            }
        } catch {
            print("本地文件数组读取失败：\(error.localizedDescription)")
        }
        return []
    }

    static func readClassifyDicWithPath(path:String)->Dictionary<String, Any>{
        
        let fileData = self.readClassifyFileWithPath(path: path)
        if(fileData==nil){
            return Dictionary()
        }
        do{
            let object = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSString.self,NSDictionary.self,NSNumber.self,NSArray.self], from: fileData!)
            return object as? Dictionary ?? Dictionary()
        }catch{
            print("本地文件字典读取失败：\(error.localizedDescription)")
            return Dictionary()
        }
    }
    static func writeToFileWithDic(responseDic:Dictionary<String, Any>,filepath:String){
        let data = try? NSKeyedArchiver.archivedData(withRootObject:responseDic, requiringSecureCoding: true)
        if(data != nil){
            self.writeToFileWithData(data: data!, path: filepath)
        }
    }
    

    static func writeToFileWithString(string:String,filePath:String){
        try? string.write(toFile: filePath, atomically: true, encoding: .utf8)
    }
    
    
    static func readClassifyFileWithPath(path:String)->Data?{
        guard let data = try? Data.init(contentsOf: URL(fileURLWithPath: path)) else{
            return nil
        }
        return data
    }
    static func writeToFileWithData(data:Data,path:String){
        let fm = FileManager.default
        var ifsucess = false
        ifsucess = fm.createFile(atPath: path, contents: data)
        if(ifsucess){
            print("文件 create file sucess")
        }else{
            print("文件 create file failed")
        }
    }
}
