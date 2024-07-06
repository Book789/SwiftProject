//
//  Protocol.swift
//  SwiftProject
//
//  Created by cloud on 2024/3/23.
//

import Foundation


@objc protocol XXManagerDelegate {
    
    func downloadFailFailed(error: Error)
    @objc optional func downloadFileComplete() // 可选协议的实现
}
