//
//  S_ProjectConfig.swift
//  Start
//
//  Created by Book on 2023/4/21.
//

import UIKit

class S_ProjectConfig: NSObject {

    
    /**
     域名
     */
    var domainURL:String!
    
    /**
    H5的域名
     */
    var H5DomainURL:String!
    
    /**
    H5的域名
     */
    var QiniuDomainURL:String!
    
    /**
    PK 房间分享邀请
     */
    var PKRoomShareInviteURL:String!


    
    var isAppStore:Bool = true

    
    
    class var sharedInstance : S_ProjectConfig {
        struct Static {
            static let instance : S_ProjectConfig = S_ProjectConfig()
        }
        return Static.instance
    }
    
    
    fileprivate override init() {
        super.init()
        
        let Environment = Bundle.main.infoDictionary!["Environment"] as! String
        
        if(Environment=="100"){
            self.domainURL = "http://api-test.ydj.fit"
            self.H5DomainURL = "http://app-test.ydj.fit"
            self.PKRoomShareInviteURL = "http://app-test.ydj.fit/pk_arena?inviteCode="
        }else{
            self.domainURL = "https://api.ydj.fit"
            self.H5DomainURL = "https://app.ydj.fit"
            self.PKRoomShareInviteURL = "https://app.ydj.fit/pk_arena?inviteCode="
        }
        self.QiniuDomainURL = "https://cdn.ydj.fit"
   
    }

}
