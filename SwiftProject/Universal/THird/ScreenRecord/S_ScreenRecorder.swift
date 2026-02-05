//
//  S_Recorder.swift
//  1111
//
//  Created by cloud on 2023/7/28.
//

import UIKit
import AVFoundation

class S_ScreenRecorder: NSObject {

    
    var audioRecorder:S_AudioRecorder!
    
    var videoRecorder:S_VideoRecorder!
    
    var isLandscape:Bool = false{
        didSet{
            self.videoRecorder.isLandscape = self.isLandscape
        }
    }

    override init() {
        super.init()
        self.audioRecorder = S_AudioRecorder.init()
        self.videoRecorder = S_VideoRecorder.init()
    }
    
    func startRecording(){
        self.videoRecorder.startRecording()
        self.audioRecorder.startRecorder()
    }
    
    func recording(pixelBuffer: CVPixelBuffer,time:CMTime,durationTime:CMTime){
        self.videoRecorder.recording(pixelBuffer: pixelBuffer, time: time,durationTime: durationTime)
    }
    func pause(){
        self.audioRecorder.pauseRecorder()
        self.videoRecorder.isDistance = true
    }
    func resume(){
        self.audioRecorder.resumeRecorder()
    }
    
    func stopRecording(handle:@escaping(URL) -> Void){
        
        // 先停止音频录制（同步）
        self.audioRecorder.stopRecorder()
        if(self.videoRecorder.videoWriterInput == nil){
            // 如果视频录制未开始，直接返回音频文件（如果有）
            if FileManager.default.fileExists(atPath: self.audioRecorder.audioFilename.path) {
                handle(self.audioRecorder.audioFilename)
            }
            return
        }
        
        // 等待视频写入完成后再合并
        self.videoRecorder.stopRecord {
            // 确保文件存在后再合并
            let fileManager = FileManager.default
            let videoPath = self.videoRecorder.outURLString as URL
            let audioPath = self.audioRecorder.audioFilename
            
            // 检查视频文件是否存在
            guard fileManager.fileExists(atPath: videoPath.path) else {
                print("视频文件不存在: \(videoPath.path)")
                // 如果视频文件不存在，返回音频文件（如果有）
                if fileManager.fileExists(atPath: audioPath.path) {
                    handle(audioPath)
                }
                return
            }
            
            self.mergeVideo(videoPath: self.videoRecorder.outURLString, audioPath: audioPath as NSURL, handle: handle)
        }
    }
    
    
    
    /*
     * 获取文件大小（MB）
     */
    private func getFileSize(_ url: URL) -> Double {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
              let fileSize = attributes[.size] as? UInt64 else {
            return 0.0
        }
        return Double(fileSize) / (1024 * 1024) // 转换为MB
    }
    
    /*
     * 将视频和音频合并
     */
    func mergeVideo(videoPath:NSURL,audioPath:NSURL,handle:@escaping(URL) -> Void){
        
        let fileManager = FileManager.default
        let videoURL = videoPath as URL
        let audioURL = audioPath as URL

        // 检查音频文件是否存在且大小大于0
        if !fileManager.fileExists(atPath: audioURL.path) || getFileSize(audioURL) == 0.0 {
            // 如果没有音频，直接返回视频文件
            print("音频文件不存在或为空，直接返回视频文件")
            handle(videoURL)
            return
        }

        // 检查视频文件是否存在
        guard fileManager.fileExists(atPath: videoURL.path) else {
            print("视频文件不存在: \(videoURL.path)")
            // 如果视频文件不存在，返回音频文件
            handle(audioURL)
            return
        }
        
        let urlString = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        guard let documentDirectory = urlString.first else {
            print("无法获取文档目录")
            handle(videoURL)
            return
        }
        
        let outputURL = documentDirectory.appendingPathComponent("ScreenRecord.mp4")
        if fileManager.fileExists(atPath: outputURL.path) {
            do {
                try fileManager.removeItem(at: outputURL)
            } catch {
                print("无法删除已存在的输出文件: \(error.localizedDescription)")
            }
        }
        
        // 时间起点
        let startTime = CMTime.zero
        
        // 创建可变的音视频组合
        let composition = AVMutableComposition()
        
        // 视频采集
        let videoAsset = AVURLAsset(url: videoURL)
        
        // 等待视频资源加载完成
        videoAsset.loadValuesAsynchronously(forKeys: ["duration", "tracks"]) {
            var videoError: Error?
            let status = videoAsset.statusOfValue(forKey: "duration", error: nil)
            
            guard status == .loaded else {
                print("视频资源加载失败: \(videoError?.localizedDescription ?? "未知错误")")
                DispatchQueue.main.async {
                    handle(videoURL)
                }
                return
            }
            
            // 音频采集
            let audioAsset = AVURLAsset(url: audioURL)
            audioAsset.loadValuesAsynchronously(forKeys: ["duration", "tracks"]) {
                var audioError: Error?
                let audioStatus = audioAsset.statusOfValue(forKey: "duration", error: nil)
                
                guard audioStatus == .loaded else {
                    print("音频资源加载失败: \(audioError?.localizedDescription ?? "未知错误")")
                    DispatchQueue.main.async {
                        handle(videoURL)
                    }
                    return
                }
                
                // 视频时间范围
                let videoDuration = videoAsset.duration
                guard CMTimeCompare(videoDuration, CMTime.zero) > 0 else {
                    print("视频时长为0")
                    DispatchQueue.main.async {
                        handle(audioURL)
                    }
                    return
                }
                
                let videoTimeRange = CMTimeRangeMake(start: startTime, duration: videoDuration)
                
                // 视频通道
                guard let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
                    print("无法创建视频轨道")
                    DispatchQueue.main.async {
                        handle(videoURL)
                    }
                    return
                }
                
                // 视频采集通道
                let videoAssetTracks = videoAsset.tracks(withMediaType: .video)
                guard let videoAssetTrack = videoAssetTracks.first else {
                    print("视频资源中没有视频轨道")
                    DispatchQueue.main.async {
                        handle(audioURL)
                    }
                    return
                }
                
                do {
                    try videoTrack.insertTimeRange(videoTimeRange, of: videoAssetTrack, at: startTime)
                } catch {
                    print("插入视频轨道失败: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        handle(videoURL)
                    }
                    return
                }

                // 音频时间范围
                let audioDuration = audioAsset.duration
                guard CMTimeCompare(audioDuration, CMTime.zero) > 0 else {
                    print("音频时长为0")
                    DispatchQueue.main.async {
                        handle(videoURL)
                    }
                    return
                }
                
                // 使用视频和音频中较短的时间
                let finalDuration = CMTimeCompare(videoDuration, audioDuration) < 0 ? videoDuration : audioDuration
                let audioTimeRange = CMTimeRangeMake(start: startTime, duration: finalDuration)
                
                // 音频通道
                guard let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
                    print("无法创建音频轨道")
                    DispatchQueue.main.async {
                        handle(videoURL)
                    }
                    return
                }
                
                // 音频采集通道
                let audioAssetTracks = audioAsset.tracks(withMediaType: .audio)
                guard let audioAssetTrack = audioAssetTracks.first else {
                    print("音频资源中没有音频轨道")
                    DispatchQueue.main.async {
                        handle(videoURL)
                    }
                    return
                }
                
                do {
                    try audioTrack.insertTimeRange(audioTimeRange, of: audioAssetTrack, at: startTime)
                } catch {
                    print("插入音频轨道失败: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        handle(videoURL)
                    }
                    return
                }
                
                // 创建导出会话
                guard let assetExport = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHEVCHighestQuality) else {
                    print("无法创建导出会话")
                    DispatchQueue.main.async {
                        handle(videoURL)
                    }
                    return
                }
                
                // 输出类型
                assetExport.outputFileType = .mp4
                // 输出地址
                assetExport.outputURL = outputURL
                // 优化
                assetExport.shouldOptimizeForNetworkUse = true
                
                // 合成完毕
                assetExport.exportAsynchronously {
                    DispatchQueue.main.async {
                        switch assetExport.status {
                        case .failed:
                            print("视频合成失败: \(assetExport.error?.localizedDescription ?? "未知错误")")
                            // 导出失败时返回原始视频文件
                            handle(videoURL)
                            
                        case .cancelled:
                            print("视频合成已取消")
                            handle(videoURL)
                            
                        case .completed:
                            print("视频合成完成: \(outputURL.path)")
                            handle(outputURL)
                            // 清理临时文件
                            try? fileManager.removeItem(at: videoURL)
                            try? fileManager.removeItem(at: audioURL)
                            
                        default:
                            print("视频合成状态未知: \(assetExport.status.rawValue)")
                            handle(videoURL)
                        }
                    }
                }
            }
        }
    }
}
