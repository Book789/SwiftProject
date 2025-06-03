//
//  S_UserInfoModel.swift
//  Start
//
//  Created by Book on 2023/4/20.
//

import UIKit
import HandyJSON

class S_UserInfoModel: NSObject,HandyJSON,NSCoding,NSSecureCoding{
  
    required override init() {
        super.init()
    }
    
   
    static var supportsSecureCoding:Bool  = true
        

    
    func encode(with coder: NSCoder) {
        
        coder.encode(uid.description, forKey:"uid")
        coder.encode(token, forKey:"token")
        coder.encode(headPhoto, forKey:"headPhoto")
        coder.encode(name, forKey:"name")
        coder.encode(nickName, forKey:"nickName")
        coder.encode(tel, forKey:"tel")
        coder.encode(gender, forKey:"gender")
        coder.encode(birthday, forKey:"birthday")
        coder.encode(address, forKey:"address")
        coder.encode(gymnasiumId, forKey:"gymnasiumId")
        coder.encode(gymnasium, forKey:"gymnasium")
        coder.encode(bodyBasicData, forKey:"bodyBasicData")
        coder.encode(height, forKey:"height")
        coder.encode(weight, forKey:"weight")
        coder.encode(totalCredit, forKey:"totalCredit")
        coder.encode(currentCredit, forKey:"currentCredit")
        coder.encode(primaryAccount, forKey:"primaryAccount")
        coder.encode(openid, forKey:"openid")
        coder.encode(roleIds, forKey:"roleIds")
        coder.encode(vip, forKey:"vip")
        coder.encode(vipExpiration, forKey:"vipExpiration")
        coder.encode(signDay, forKey:"signDay")
        coder.encode(organizationVideo, forKey: "organizationVideo")
        coder.encode(organizationQrcode, forKey: "organizationQrcode")
        coder.encode(redDot, forKey: "redDot")
        coder.encode(guideStatusDict, forKey: "guideStatusDict")
        
        if(birthday.count>=10){
            let year:NSInteger = NSInteger(birthday.substring(to: 3))!
            let components = NSCalendar.current.dateComponents([.year,.month,.weekOfMonth], from: NSDate() as Date)
            age = (components.year! - year).description
        }
        coder.encode(age, forKey:"age")

    }
    required init?(coder: NSCoder) {
        super.init()
        token = (coder.decodeObject(forKey:"token") as? String) ?? ""
        uid = (coder.decodeObject(forKey:"uid")as? String) ?? ""
        headPhoto = (coder.decodeObject(forKey:"headPhoto") as? String) ?? ""
        nickName = (coder.decodeObject(forKey:"nickName") as? String) ?? ""
        name = (coder.decodeObject(forKey:"name")as? String) ?? ""
        gender = (coder.decodeObject(forKey:"gender")as? String) ?? ""
        tel = (coder.decodeObject(forKey:"tel")as? String) ?? ""
        birthday = (coder.decodeObject(forKey:"birthday") as? String ?? "")
        address = (coder.decodeObject(forKey:"address") as? String)  ?? ""
        gymnasiumId = (coder.decodeObject(forKey:"gymnasiumId")as? String ?? "")
        gymnasium = (coder.decodeObject(forKey:"gymnasium")as? String ?? "")
        bodyBasicData = (coder.decodeObject(forKey:"bodyBasicData")as? String)  ?? ""
        height = (coder.decodeObject(forKey:"height")as? String)  ?? ""
        weight = (coder.decodeObject(forKey:"weight")as? String)  ?? ""
        totalCredit = (coder.decodeObject(forKey:"totalCredit")as? String)  ?? ""
        currentCredit = (coder.decodeObject(forKey:"currentCredit")as? String)  ?? ""
        primaryAccount = (coder.decodeObject(forKey:"primaryAccount")as? NSInteger)  ?? 0
        openid = (coder.decodeObject(forKey:"openid")as? String) ?? ""
        age = (coder.decodeObject(forKey:"age")as? String) ?? ""
        roleIds = ((coder.decodeObject(forKey:"roleIds") as? NSArray) ?? [])
        vip = (coder.decodeObject(forKey:"vip")as? NSNumber) ?? 0
        vipExpiration = (coder.decodeObject(forKey:"vipExpiration")as? String) ?? ""
        
        signDay = (coder.decodeObject(forKey:"signDay") as? String) ?? ""
        organizationVideo = (coder.decodeObject(forKey: "organizationVideo") as? String) ?? ""
        organizationQrcode = (coder.decodeObject(forKey: "organizationQrcode") as? String) ?? ""
        redDot = (coder.decodeBool(forKey: "redDot"))
        guideStatusDict = (coder.decodeObject(forKey:"guideStatusDict") as? [String: Int] ?? [:])

        if(birthday.count>=10){
            let year:NSInteger = NSInteger(birthday.substring(to: 3))!
            let components = NSCalendar.current.dateComponents([.year,.month,.weekOfMonth], from: NSDate() as Date)
            age = (components.year! - year).description
        }
       

    }
    
    var token:String!
    /**
     *  用户id
     */
    var uid:String!
    /**
     *  头像地址
     */
    var headPhoto:String!
    
    /**
     *  昵称
     */
    var nickName:String!
    
    /**
     *  姓名
     */
    var name:String!
    /**
     *    手机，格式 19928461353
     */
    var tel:String!

    /**
     *   性别
     */
    var gender:String!
    /**
     *  生日
     */
    var birthday:String = ""
    /**
     *  地址
     */
    var address:String!

    /**
     *  常用球馆 id
     */
    var gymnasiumId:String = ""

    /**
     *  常用球馆名称
     */
    var gymnasium:String = ""


    /**
     *  身体基础数据 格式: 120cm,27kg
     */
    var bodyBasicData:String!
    /**
     *  身高
     */
    var height:String!
    /**
     *  体重
     */
    var weight:String!
    /**
     *  累计获取积分
     */
    var totalCredit:String!

    /**
     *  现有积分
     */
    var currentCredit:String!

    /**
     *  0 表示当前账号是主账号
     */
    var primaryAccount:NSInteger!
    /**
     *  微信方提供的openid
     */
    var openid:String!
    
    
    /**
     *  1是普通用户  5是 教练  7是 市场 8是 主教练
     */
    var roleIds:NSArray = []
    
    /**
     *  是否是vip
     */
    var vip:NSNumber = 0
    /**
     *  vip过期时间
     */
    var vipExpiration: String = ""
    
    var age:String!

    var signDay:String = ""
    /**
     *  机构视频
     */
    var organizationVideo:String = ""
    /**
     *  机构二维码
     */
    var organizationQrcode:String = ""
    
    /**
     *  运动生涯-运动技能（角色）
     */
    var athleticismTitle: String = ""
    
    /**
     *  运动生涯-勋章
     */
    var athleticismMedal: String = ""
    
    
    /**
     *  我的学校是否显示红点
     *  true 显示
     *  false 不显示
     */
    var redDot: Bool = false
    
    
    /**
     *  引导视频是否播放
     *  -1 未知
     *  0 未播放过
     *  1 播放过
     *
     */
    var guideStatusDict: Dictionary<String, Int> = ["trainPlan": -1, "ARProject": -1, "course": -1, "tabata": -1, "specialCourse": -1]
    
  
}
