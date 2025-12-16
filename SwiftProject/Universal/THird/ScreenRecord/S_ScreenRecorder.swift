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
        
        self.videoRecorder.stopRecord()
        self.audioRecorder.stopRecorder()
        
        if(self.videoRecorder.videoWriterInput == nil){
            return
        }
        self.mergeVideo(videoPath: self.videoRecorder.outURLString, audioPath: self.audioRecorder.audioFilename as NSURL,handle: handle)
    }
    
    
    
    /*
     * 将视频和音频合并
     */
    func mergeVideo(videoPath:NSURL,audioPath:NSURL,handle:@escaping(URL) -> Void){
        
        let fileManager = FileManager.default

        if(getFileSize(audioPath as URL)==0.0){
            handle(videoPath as URL)
            try? fileManager.removeItem(at: videoPath as URL)
            try? fileManager.removeItem(at: audioPath as URL)
            return
        }

        
        let urlString = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory:NSURL = urlString.first! as NSURL
        
        let outputURL:URL = documentDirectory.appendingPathComponent("ScreenRecord.mp4")! as URL
        if(fileManager.fileExists(atPath: outputURL.path)){
            do{
                try fileManager.removeItem(at: outputURL as URL)
            }catch{
                print("unable to delete file")
            }
        }
        // 时间起点
        let startTime = CMTime.zero
        
        // 创建可变的音视频组合
        let composition = AVMutableComposition()
        
        // 视频采集
        let videoAsset = AVURLAsset.init(url: videoPath as URL)
        
        // 视频时间范围
        let videoTimeRange = CMTimeRangeMake(start: startTime, duration: videoAsset.duration)
        // 视频通道 枚举 kCMPersistentTrackID_Invalid = 0
        let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        // 视频采集通道
        let videoAssetTrack = videoAsset.tracks(withMediaType: .video).first
        if(videoAssetTrack != nil){
            //  把采集轨道数据加入到可变轨道之中
            try? videoTrack!.insertTimeRange(videoTimeRange, of: videoAssetTrack!, at: startTime)
        }

        // 声音采集
        let audioAsset = AVURLAsset.init(url: audioPath as URL)
        // 因为视频短这里就直接用视频长度了,如果自动化需要自己写判断
        let audioTimeRange = CMTimeRangeMake(start: startTime, duration: audioAsset.duration);
        // 音频通道
        let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        // 音频采集通道
        let audioAssetTrack = audioAsset.tracks(withMediaType: .audio).first
        if(audioAssetTrack != nil){
            // 加入合成轨道之中
            try? audioTrack!.insertTimeRange(audioTimeRange, of: audioAssetTrack!, at: startTime)
        }
        
        // 创建一个输出
        let assetExport = AVAssetExportSession.init(asset: composition, presetName: AVAssetExportPresetMediumQuality)!       // 输出类型
        assetExport.outputFileType = .mp4
        // 输出地址
        assetExport.outputURL = outputURL
        // 优化
        assetExport.shouldOptimizeForNetworkUse = true
        // 合成完毕
        assetExport.exportAsynchronously {
            
            if assetExport.status == .failed {
                print("失败")
                print(assetExport.error!.localizedDescription)
                
            } else if assetExport.status == .cancelled {
                
                print("取消")
                
            } else if assetExport.status == .completed {
                print("完成")
            } else {
                print("未知")
            }
            handle(assetExport.outputURL!)
            try? fileManager.removeItem(at: videoPath as URL)
            try? fileManager.removeItem(at: audioPath as URL)
        }
    }
}
