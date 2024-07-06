//
//  String+Keychain.swift
//  Start
//
//  Created by cloud on 2024/3/6.
//

import Foundation
import Security

extension String {
     
    static func addToKeychain(key: String, value: String) {
        let query = [kSecClass as String : kSecClassGenericPassword,
                    kSecAttrAccount as String : key,
                    kSecValueData as String : value.data(using: .utf8)!] as CFDictionary
        
        SecItemAdd(query, nil)
    }
         
   static func getFromKeychain(key: String) -> String? {
        var result: AnyObject?
        let query = [kSecClass as String : kSecClassGenericPassword,
                    kSecAttrAccount as String : key,
                    kSecReturnData as String : true] as CFDictionary
        
        if SecItemCopyMatching(query, &result) == noErr {
            return NSString(data: result as! Data, encoding: String.Encoding.utf8.rawValue)?.replacingOccurrences(of: "\0", with: "")
        } else {
            return nil
        }
    }
         
    func updateInKeychain(key: String, newValue: String) {
        let attributes = [kSecClass as String : kSecClassGenericPassword,
                          kSecAttrAccount as String : key] as CFDictionary
        
        let status = SecItemUpdate(attributes, [kSecValueData as String : newValue.data(using: .utf8)] as CFDictionary)
        if status != errSecSuccess {
            print("Failed to update the item in Keychain")
        }
    }
        
    func removeFromKeychain(key: String) {
        let query = [kSecClass as String : kSecClassGenericPassword,
                    kSecAttrAccount as String : key] as CFDictionary
        
        SecItemDelete(query)
    }




}
