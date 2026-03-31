//
//  VideoCacheManager.swift
//  SwiftProject
//
//  Created by cloud on 2026/3/21.
//

import AVFoundation
import UIKit
import CryptoKit

/// 网络质量监测
class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    /// 网络质量
    enum Quality {
        case high    // 高速网络（WiFi/5G）
        case medium  // 中速网络（4G）
        case low     // 低速网络（3G/2G）
        case unknown // 未知
    }
    
    var currentQuality: Quality = .unknown
    
    private init() {
        // 这里可以集成网络监测逻辑
        // 简化实现，默认返回high
        currentQuality = .high
    }
}

/// 视频缓存管理器
import UIKit
import CommonCrypto

class VideoCacheManager {
    // MARK: - 常量定义
    private let cacheDirectory: URL
    private let MD5_DIGEST_LENGTH = 16
    // 异步队列（避免主线程操作）
    private let cacheQueue = DispatchQueue(label: "com.videoPlayer.cacheQueue", qos: .utility)
    
    // MARK: - 初始化
    init() {
        // 获取缓存目录
        let cachesDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheDirectory = cachesDir.appendingPathComponent("VideoPlayerCache")
        
        // 创建缓存目录（不存在则创建）
        cacheQueue.async { [weak self] in
            guard let self = self else { return }
            do {
                try FileManager.default.createDirectory(at: self.cacheDirectory, withIntermediateDirectories: true)
            } catch {
                print("❌ 创建缓存目录失败：\(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - 核心方法：URL 转哈希字符串
    private func hashForURL(_ url: URL) -> String {
        let inputString = url.absoluteString
        guard let inputData = inputString.data(using: .utf8) else {
            return url.lastPathComponent
        }
        
        // MD5 哈希（兼容新版 SDK）
        var digest = [UInt8](repeating: 0, count: MD5_DIGEST_LENGTH)
        inputData.withUnsafeBytes { bytes in
            CC_MD5(bytes.baseAddress, CC_LONG(inputData.count), &digest)
        }
        
        // 转换为十六进制字符串
        let hashString = digest.map { String(format: "%02hhx", $0) }.joined()
        return hashString
    }
    
    // MARK: - 异步读取首帧缓存
    func getFirstFrame(for url: URL, completion: @escaping (UIImage?) -> Void) {
        // 切换到异步队列，避免主线程阻塞
        cacheQueue.async { [weak self] in
            guard let self = self else {
                completion(nil)
                return
            }
            
            let hash = self.hashForURL(url)
            let cachePath = self.cacheDirectory.appendingPathComponent("\(hash)_firstframe.png")
            
            // 1. 检查缓存文件是否存在
            guard FileManager.default.fileExists(atPath: cachePath.path) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            // 2. 检查缓存过期时间（异步）
            do {
                // 修复：用 FileAttributeKey 读取文件属性（正确写法）
                let attributes = try FileManager.default.attributesOfItem(atPath: cachePath.path)
                if let modificationDate = attributes[.modificationDate] as? Date {
                    let hoursSinceModification = Date().timeIntervalSince(modificationDate) / 3600
                    // 超过24小时则删除缓存
                    if hoursSinceModification > 24 {
                        try FileManager.default.removeItem(at: cachePath)
                        DispatchQueue.main.async { completion(nil) }
                        return
                    }
                }
            } catch {
                print("❌ 检查缓存过期时间失败：\(error.localizedDescription)")
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            // 3. 异步读取文件
            do {
                let imageData = try Data(contentsOf: cachePath)
                let image = UIImage(data: imageData)
                DispatchQueue.main.async { completion(image) }
            } catch {
                print("❌ 读取缓存首帧失败：\(error.localizedDescription)")
                DispatchQueue.main.async { completion(nil) }
            }
        }
    }
    
    // MARK: - 异步缓存首帧
    func cacheFirstFrame(image: UIImage, for url: URL, completion: (() -> Void)? = nil) {
        cacheQueue.async { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async { completion?() }
                return
            }
            
            let hash = self.hashForURL(url)
            let cachePath = self.cacheDirectory.appendingPathComponent("\(hash)_firstframe.png")
            
            // 转换图片为 PNG 数据
            guard let imageData = image.pngData() else {
                print("❌ 转换首帧为 PNG 失败")
                DispatchQueue.main.async { completion?() }
                return
            }
            
            // 异步写入文件
            do {
                try imageData.write(to: cachePath)
                print("💾 成功缓存首帧：\(cachePath.lastPathComponent)")
            } catch {
                print("❌ 缓存首帧失败：\(error.localizedDescription)")
            }
            
            DispatchQueue.main.async { completion?() }
        }
    }
    
    // MARK: - 异步清理过期缓存（核心修复：URLResourceKey 正确写法）
    func cleanExpiredCache(completion: (() -> Void)? = nil) {
        cacheQueue.async { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async { completion?() }
                return
            }
            
            do {
                // 修复：URLResourceKey 正确属性名 + 完整读取逻辑
                let resourceKeys: [URLResourceKey] = [
                    .contentModificationDateKey, // 正确属性名
                ]
                
                let files = try FileManager.default.contentsOfDirectory(
                    at: self.cacheDirectory,
                    includingPropertiesForKeys: resourceKeys, // 传入正确的资源键
                    options: .skipsHiddenFiles
                )
                
                for fileURL in files {
                    // 方式1：通过 URLResourceValues 读取（推荐）
                    do {
                        let resourceValues = try fileURL.resourceValues(forKeys: Set(resourceKeys))
                        if let modificationDate = resourceValues.contentModificationDate {
                            let hoursSinceModification = Date().timeIntervalSince(modificationDate) / 3600
                            if hoursSinceModification > 24 {
                                try FileManager.default.removeItem(at: fileURL)
                                print("🗑️ 删除过期缓存：\(fileURL.lastPathComponent)")
                            }
                        }
                    } catch {
                        // 方式2：降级用 FileAttributeKey 读取（兼容所有场景）
                        let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
                        if let modificationDate = attributes[.modificationDate] as? Date {
                            let hoursSinceModification = Date().timeIntervalSince(modificationDate) / 3600
                            if hoursSinceModification > 24 {
                                try FileManager.default.removeItem(at: fileURL)
                                print("🗑️ 删除过期缓存（降级）：\(fileURL.lastPathComponent)")
                            }
                        }
                    }
                }
            } catch {
                print("❌ 清理过期缓存失败：\(error.localizedDescription)")
            }
            
            DispatchQueue.main.async { completion?() }
        }
    }
    
    // MARK: - 异步清理所有缓存
    func cleanAllCache(completion: (() -> Void)? = nil) {
        cacheQueue.async { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async { completion?() }
                return
            }
            
            do {
                let files = try FileManager.default.contentsOfDirectory(at: self.cacheDirectory, includingPropertiesForKeys: nil)
                for fileURL in files {
                    try FileManager.default.removeItem(at: fileURL)
                }
                print("🗑️ 清理所有视频缓存完成")
            } catch {
                print("❌ 清理所有缓存失败：\(error.localizedDescription)")
            }
            
            DispatchQueue.main.async { completion?() }
        }
    }
}


// MARK: - URL扩展
extension URL {
    /// 生成sha256
    var sha256: String {
        guard let data = try? Data(contentsOf: self) else {
            return self.absoluteString
        }
        
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
        
    }
}
