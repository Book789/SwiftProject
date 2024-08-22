//
//  Macro.swift
//  swiftBase
//
//  Created by Book on 2023/3/21.
//

import Foundation
import UIKit

var kColorWithHex: (NSInteger) -> UIColor = {hex in
    return UIColor(red: ((CGFloat)((hex & 0xFF0000) >> 16)) / 255.0, green: ((CGFloat)((hex & 0xFF00) >> 8)) / 255.0, blue: ((CGFloat)(hex & 0xFF)) / 255.0, alpha: 1);
}

var keyWindow:() -> UIWindow = {
    
    if #available(iOS 15.0, *) {
        let keyWindow = UIApplication.shared.connectedScenes
            .map({ $0 as? UIWindowScene })
            .compactMap({ $0 })
            .first?.windows.first ?? UIWindow()
        return keyWindow
    }else{
        let keyWindow = UIApplication.shared.windows.first ?? UIWindow()
        return keyWindow
    }
}
/**
 * 顶部状态栏高度（包括安全区）
 */
var xp_statusBarHeight:() -> CGFloat = {
    var statusBarHeight: CGFloat = keyWindow().safeAreaInsets.top
    if(statusBarHeight==0){
        statusBarHeight = keyWindow().safeAreaInsets.left
    }
    return statusBarHeight
}
var Ratio:(CGFloat) -> CGFloat = {width in
    
    let ratio:CGFloat = kScreenWidth/375.0*width
    return ratio
}
func safeDistanceBottom() -> CGFloat {
    let safeBottom: CGFloat = keyWindow().safeAreaInsets.bottom
    return safeBottom
}
/*
 * 本地视频文件夹
 */
func videoDirectory() -> URL {
    
    let fileManager = FileManager.default
    let urlString = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
    let documentDirectory:NSURL = urlString.first! as NSURL
    let outputURL:URL = documentDirectory.appendingPathComponent("Video/")! as URL
    return outputURL
}
/*
 *  清空本地视频文件夹
 */
func cleanVideoCache(){
    let fileManager = FileManager.default
    if(!fileManager.fileExists(atPath:  videoDirectory().path)){
        try! fileManager.createDirectory(atPath: videoDirectory().path, withIntermediateDirectories: true)
    }else{
        try? FileManager.default.removeItem(at:videoDirectory())
        try! fileManager.createDirectory(atPath: videoDirectory().path, withIntermediateDirectories: true)
    }
}
/*
 *  获取文件的大小
 */
func getFileSize(_ url:URL) -> Double {
    if let fileData:Data = try? Data.init(contentsOf: url) {
        let size = Double(fileData.count) / (1024.00 * 1024.00)
        return size
    }
    return 0.00
}
// MARK: - 本地文件路径

let kPKBgAudo = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first?.appending("/pkBgAudo")


// MARK: - 常用宽高

/// 屏幕Bounds
let kScreenBounds = UIScreen.main.bounds;
/// 屏幕高度
let kScreenHeight = UIScreen.main.bounds.size.height;
/// 屏幕宽度
let kScreenWidth = UIScreen.main.bounds.size.width;
/// 导航栏高度
let kNavBarHeight = 44.0;
/// 状态栏高度x
let kStatusBarHeight = xp_statusBarHeight
/// Tab栏高度
let kTabBarHeight = 49.0

let kSafeAreaBottomHeight = safeDistanceBottom
///消息已读
let kNotificationReadMessage = "notificationReadMessage";
