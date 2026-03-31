//
//  VideoPlayHistoryManager.swift
//  SwiftProject
//
//  Created by cloud on 2026/3/21.
//

import AVFoundation
import CommonCrypto

/// 播放历史模型
struct PlayHistory {
    let url: URL
    var progress: Double
    var playCount: Int
    var lastPlayTime: Date
}

/// 播放历史管理器
// MARK: - 播放历史管理器（异步 + 移除废弃 API）
class VideoPlayHistoryManager {
    private let historyKey = "VideoPlayerPlayHistory"
    // 新增：异步队列
    private let historyQueue = DispatchQueue(label: "com.videoPlayer.historyQueue", qos: .utility)
    
    // MARK: - 异步记录播放历史
    func addPlayHistory(url: URL) {
        historyQueue.async { [weak self] in
            guard let self = self else { return }
            
            var history = self.getPlayHistory()
            let hash = self.hashForURL(url)
            
            if !history.keys.contains(hash) {
                history[hash] = [
                    "url": url.absoluteString,
                    "progress": 0.0,
                    "lastPlayTime": Date().timeIntervalSince1970
                ]
                self.savePlayHistory(history)
            }
        }
    }
    
    // MARK: - 异步更新播放进度
    func updatePlayProgress(url: URL, progress: Double) {
        historyQueue.async { [weak self] in
            guard let self = self else { return }
            
            var history = self.getPlayHistory()
            let hash = self.hashForURL(url)
            
            if var item = history[hash] {
                item["progress"] = progress
                item["lastPlayTime"] = Date().timeIntervalSince1970
                history[hash] = item
                self.savePlayHistory(history)
            }
        }
    }
    
    // MARK: - 异步读取播放进度
    func getPlayProgress(for url: URL, completion: @escaping (Double?) -> Void) {
        historyQueue.async { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            let history = self.getPlayHistory()
            let hash = self.hashForURL(url)
            
            guard let item = history[hash], let progress = item["progress"] as? Double else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            DispatchQueue.main.async { completion(progress) }
        }
    }
    
    // MARK: - 私有方法：读取历史数据
    private func getPlayHistory() -> [String: [String: Any]] {
        guard let data = UserDefaults.standard.data(forKey: self.historyKey),
              let history = try? JSONSerialization.jsonObject(with: data) as? [String: [String: Any]] else {
            return [:]
        }
        return history
    }
    
    // MARK: - 私有方法：保存历史数据（移除废弃的 synchronize()）
    private func savePlayHistory(_ history: [String: [String: Any]]) {
        guard let data = try? JSONSerialization.data(withJSONObject: history) else {
            print("❌ 保存播放历史失败")
            return
        }
        UserDefaults.standard.set(data, forKey: self.historyKey)
        // 移除：UserDefaults.standard.synchronize()（iOS 10+ 已废弃，且是同步操作）
    }
    
    // MARK: - 私有方法：URL 哈希
    private func hashForURL(_ url: URL) -> String {
        let inputString = url.absoluteString
        guard let inputData = inputString.data(using: .utf8) else {
            return url.lastPathComponent
        }
        
        // MD5 哈希
        var digest = [UInt8](repeating: 0, count: 16)
        inputData.withUnsafeBytes { bytes in
            CC_MD5(bytes.baseAddress, CC_LONG(inputData.count), &digest)
        }
        
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
}
// MARK: - PlayHistory 扩展
extension PlayHistory: Codable {
    enum CodingKeys: String, CodingKey {
        case url
        case progress
        case playCount
        case lastPlayTime
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        url = try container.decode(URL.self, forKey: .url)
        progress = try container.decode(Double.self, forKey: .progress)
        playCount = try container.decode(Int.self, forKey: .playCount)
        lastPlayTime = try container.decode(Date.self, forKey: .lastPlayTime)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(url, forKey: .url)
        try container.encode(progress, forKey: .progress)
        try container.encode(playCount, forKey: .playCount)
        try container.encode(lastPlayTime, forKey: .lastPlayTime)
    }
}
