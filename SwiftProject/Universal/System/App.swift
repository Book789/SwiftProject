//
//  AboutApp.swift
//  TSWeChat
//
//  Created by Hilen on 11/23/15.
//  Copyright © 2015 Hilen. All rights reserved.
//

import Foundation
import UIKit

public struct App {
    public static var appName: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as! String
    }
    
    public static var appVersion: String {
        return Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    }
    
    public static var uuid: String {
        guard let uuidString = String.getFromKeychain(key: "uuid") else{
            let string = UUID().uuidString
            String.addToKeychain(key: "uuid", value: string)
            return string
        }
        return uuidString
    }

    
    public static var appBuild: String {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
    }
    
    public static var bundleIdentifier: String {
        return Bundle.main.infoDictionary!["CFBundleIdentifier"] as! String
    }
    
    public static var bundleName: String {
        return Bundle.main.infoDictionary!["CFBundleName"] as! String
    }
    
    public static var appStoreURL: URL {
        return URL(string: "your URL")!
    }
    
    public static var appVersionAndBuild: String {
        let version = appVersion, build = appBuild
        return version == build ? "v\(version)" : "v\(version)(\(build))"
    }
}



