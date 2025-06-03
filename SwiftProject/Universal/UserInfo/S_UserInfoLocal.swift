//
//  S_UserInfoLocal.swift
//
//

import UIKit
import HandyJSON

class S_UserInfoLocal: NSObject {
    
    var model:S_UserInfoModel?
    
    var semaphore:DispatchSemaphore = DispatchSemaphore(value: 1)

    var userInfoModel:S_UserInfoModel?{
        
        set(infoModel){
            self.model = infoModel
        }
        get{
            
            if(self.model != nil){
                return self.model
            }
            let key:String = UserDefaults.standard.object(forKey: "phone") as? String ?? ""
            if(key==""){
                return nil
            }
            let dictionary:NSMutableDictionary = self.getLoginUserInfo()
            self.model = dictionary.object(forKey: key) as? S_UserInfoModel
            return self.model
        }
    }
    
    class var sharedInstance : S_UserInfoLocal {
        struct Static {
            static let instance : S_UserInfoLocal = S_UserInfoLocal()
        }
        return Static.instance
    }
    
    func saveLoginedUserInfo(model:S_UserInfoModel?){
        
        if(model==nil){
            return
        }
        userInfoModel = model
        let key:String = UserDefaults.standard.object(forKey: "phone") as? String ?? ""
        
        var  dictionary:NSMutableDictionary = NSMutableDictionary()
        if(key.count==11){
            dictionary = self.getLoginUserInfo()
        }
        UserDefaults.standard.set(model!.tel, forKey: "phone")
        UserDefaults.standard.synchronize()
        dictionary.setValue(model!, forKey: model!.tel)
        let file = (NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last?.appending("/LoacalUsrInfo"))!
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject:dictionary, requiringSecureCoding: true)
            do {
                try data.write(to: URL(fileURLWithPath: file),options: .atomic)
                print("写入成功")
            } catch {
                print("data写入本地失败: \(error)")
            }
        } catch{
            print("模型转data失败: \(error)")
        }
    }
    
    func removeLocalUserInfo(key:String){
        
        if(userInfoModel?.tel==key){
            userInfoModel = nil
            UserDefaults.standard.removeObject(forKey: "phone")
            UserDefaults.standard.synchronize()
        }
        let dictionary:NSMutableDictionary = self.getLoginUserInfo()
        dictionary.removeObject(forKey: key)
        let file = (NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last?.appending("/LoacalUsrInfo"))!
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject:dictionary, requiringSecureCoding: true)
            do {
                _ = try data.write(to: URL(fileURLWithPath: file),options: .atomic)
                print("写入成功")
            } catch {
                print("data写入本地失败: \(error)")
            }
        } catch{
            print("模型转data失败: \(error)")
        } 
    }
    
   /*
    * isPassive: 是否被挤下线
    */
    class func exitLogin(isPassive: Bool, message: String){
        
        S_UserInfoLocal.sharedInstance.semaphore.wait()
        
        if(S_UserInfoLocal.sharedInstance.userInfoModel == nil){
            S_UserInfoLocal.sharedInstance.semaphore.signal()
            return
        }
        
        S_UserInfoLocal.sharedInstance.removeLocalUserInfo(key: S_UserInfoLocal.sharedInstance.userInfoModel?.tel ?? "")
        
        S_UserInfoLocal.sharedInstance.semaphore.signal()
        
        S_UserInfoLocal.switchLogin()

        //
//            /// 弹窗提示被挤
//            if (isPassive) {
//                let alertController = UIAlertController(title: "提示",
//                                message: message, preferredStyle: .alert)
//                let cancelAction = UIAlertAction(title: "我知道了", style: .cancel, handler: nil)
//                alertController.addAction(cancelAction)
//                UIViewController.current().present(alertController, animated: true, completion: nil)
//            }
//           
//        }
        
    }
    
    func getLoginUserInfo()->NSMutableDictionary{

        let file = (NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last?.appending("/LoacalUsrInfo"))
        do {
            guard let data = try? Data.init(contentsOf: URL(fileURLWithPath: file!)) else{
                return NSMutableDictionary.init()
            }
            // 当用户首次登陆, 直接从沙盒获取数据, 就会为nil  所以这里需要使用as?
            do{
                let object = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSMutableDictionary.self, NSDictionary.self, NSNumber.self,NSArray.self,NSString.self,S_UserInfoModel.self], from: data)
                return object as? NSMutableDictionary ?? NSMutableDictionary.init()
            }catch{
                return NSMutableDictionary.init()
            }
        }
    }
    
    
    
    class func isLogin()->Bool{
        
        if(S_UserInfoLocal.sharedInstance.userInfoModel==nil){
            return false
        }
        return true
    }

    
    class func isNeedSwitchLogin()->Bool{
        
        if(S_UserInfoLocal.sharedInstance.userInfoModel==nil){
            self.switchLogin()
            return true
        }
        return false
    }
    class func switchLogin(){
       
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
            let base = BaseNavigationController(rootViewController: S_LoginViewController())
            base.modalPresentationStyle = .fullScreen
            rootViewController.present(base, animated: true,completion: {
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first,
                   let rootViewController = window.rootViewController {
                    let tabbarcontroller:BaseTabBarController = rootViewController as! BaseTabBarController
                    let baseNav = tabbarcontroller.selectedViewController as? BaseNavigationController
                    if(baseNav?.viewControllers.count ?? 0>1){
                        baseNav?.popToRootViewController(animated: false)
                    }
                    if(tabbarcontroller.selectedIndex > 0){
                        tabbarcontroller.selectedIndex = 0
                    }
                }

            })
        }
    }
    


}
