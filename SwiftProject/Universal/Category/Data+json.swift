//
//  Data+json.swift
//  SwiftProject
//
//  Created by cloud on 2024/3/13.
//

import Foundation

extension Data{
   
    func dataToJSON() -> AnyObject? {
        do {
            return try JSONSerialization.jsonObject(with: self, options: .mutableContainers) as AnyObject
        } catch {
            return error as AnyObject
        }
    }

}
