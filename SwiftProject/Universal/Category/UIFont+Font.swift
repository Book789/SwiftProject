//
//  UIFont-Font.swift
//  Start
//
//  Created by Book on 2023/4/20.
//

import UIKit

extension UIFont {
    
    class func regularFontOfSize(size:CGFloat)-> UIFont{
        return UIFont.init(name: "PingFangSC-Regular", size: size)!
    }
    class func semiboldFontOfSize(size:CGFloat)-> UIFont{
        return UIFont.init(name: "PingFangSC-Semibold", size: size)!
    }
    class func mediumFontOfSize(size:CGFloat)-> UIFont{
        return UIFont.init(name: "PingFangSC-Medium", size: size)!
    }
    class func boldFontOfSize(size:CGFloat)-> UIFont{
        return UIFont.init(name: "PingFangSC-Semibold", size: size)!

//        return UIFont.init(name: "PingFangSCBold", size: size)!
    }

    class func YouSheBiaoTiHeiFontOfSize(size:CGFloat)-> UIFont{
        return UIFont.init(name: "YouSheBiaoTiHei", size: size)!
    }
    class func YouSheBiaoTiYuanFontOfSize(size:CGFloat)-> UIFont{
        return UIFont.init(name: "YouSheBiaoTiYuan", size: size)!
    }
    
    

}
