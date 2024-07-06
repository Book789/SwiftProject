//
//  NSString+string.swift
//  Start
//
//  Created by Book on 2023/4/21.
//

import Foundation


extension String {
    
    func getTextHeight(font:UIFont,width:CGFloat)-> CGFloat{
        
        let size = self.boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: [.usesLineFragmentOrigin,.usesFontLeading],attributes: [NSAttributedString.Key.font : font],context: nil)
        return size.height
    }
    
    func getTextWith(font:UIFont)-> CGFloat{
        
        let size = self.boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT)), options: [.usesLineFragmentOrigin,.usesFontLeading],attributes: [NSAttributedString.Key.font : font],context: nil)
        return size.width
    }
    
    //获取文字的宽高
    func getStringSize(font: UIFont, viewSize: CGSize) -> CGSize {
        let rect = self.boundingRect(with: viewSize, options: [.usesLineFragmentOrigin,.truncatesLastVisibleLine,.usesFontLeading], attributes: [NSAttributedString.Key.font: font], context: nil)
        return rect.size
    }
    
    static func GetClassFromString(_ classString: String) -> AnyClass? {
        
        guard let bundleName: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String else {
            return nil
        }
        var anyClass: AnyClass?
        if(classString.hasPrefix(bundleName)){
            anyClass =  NSClassFromString(classString) as! BaseViewController.Type
        }else{
            anyClass =  NSClassFromString(bundleName + "." + classString) as! BaseViewController.Type
        }
        if (anyClass == nil) {
            anyClass = NSClassFromString(classString)
        }
        return anyClass
    }
    
}
