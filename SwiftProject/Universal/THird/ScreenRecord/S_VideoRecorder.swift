//
//  S_VideoRecorder.swift
//  1111
//
//  Created by cloud on 2023/7/28.
//

import UIKit
import AVFoundation
import VideoToolbox
import MetalKit

class S_VideoRecorder: NSObject {
  
    lazy var outURLString:NSURL = {
        
        let fileManager = FileManager.default
        let urlString = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory:NSURL = urlString.first! as NSURL
        
        let videoOutURLString:NSURL = documentDirectory.appendingPathComponent("videoRecord.mp4")! as NSURL
        if(fileManager.fileExists(atPath: videoOutURLString.path!)){
            do{
                try fileManager.removeItem(at: videoOutURLString as URL)
            }catch{
                print("unable to delete file")
            }
        }
        
        return videoOutURLString
    }()

    fileprivate lazy var assetWriter : AVAssetWriter = try! AVAssetWriter(url: self.outURLString as URL, fileType: .mp4)
    
   
    var videoWriterInput:AVAssetWriterInput!

    
    var adaptor:AVAssetWriterInputPixelBufferAdaptor!

    var isLandscape:Bool = false
    
    
    var rect:CGRect!
    
    var isCapture:Bool = false
    
    
    var timeOffset:CMTime = CMTimeMake(value: 0, timescale: 0)
    
    var lastpts:CMTime!

    var isDistance:Bool = false

    var view:UIView!

    override init() {
        super.init()
        
    }
    
    func startRecording(){
        
        if(self.isLandscape){
            self.rect = CGRect(x: 0, y: 0, width: kScreenHeight, height: kScreenWidth)
        }else{
            self.rect = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)

        }
        self.view = UIViewController.currentViewController()?.view
        
        videoWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: [
            AVVideoCodecKey : AVVideoCodecType.hevc,
            AVVideoScalingModeKey: AVVideoScalingModeResizeAspectFill,
            AVVideoWidthKey : self.rect.width,
            AVVideoHeightKey : self.rect.height,
            AVVideoCompressionPropertiesKey : [
                AVVideoExpectedSourceFrameRateKey: 25,
                AVVideoQualityKey:0.9,
                AVVideoAverageBitRateKey : 3*kScreenWidth*kScreenHeight,
                AVVideoProfileLevelKey:kVTProfileLevel_HEVC_Main10_AutoLevel
            ] as [String : Any],
        ])
        videoWriterInput.expectsMediaDataInRealTime = true
        
        self.adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoWriterInput)

        if assetWriter.canAdd(videoWriterInput) {
            assetWriter.add(videoWriterInput)
            print("video input added")
        } else {
            print("no input added")
        }

        let isWrite = assetWriter.startWriting()
        if(isWrite==false){
//            UIWindow.fm_showTextHUD("该设备不支持录屏功能")
        }

    }
    
    func recording(pixelBuffer: CVPixelBuffer,time:CMTime,durationTime:CMTime){
        
        if(self.assetWriter.status != .writing){
            return
        }
        if(self.isDistance == true){
            self.isDistance = false
            var pts:CMTime = time
            let last = self.lastpts
            if(self.lastpts != nil){
                let cmOffset = self.timeOffset
                if last!.flags.contains(CMTimeFlags.valid) {
                    if cmOffset.flags.contains(CMTimeFlags.valid) {
                        pts = CMTimeSubtract(pts, cmOffset);
                    }
                    let offset:CMTime = CMTimeSubtract(pts, last!)
                    if (self.timeOffset.value == 0){
                        self.timeOffset = offset;
                    }
                    else{
                        self.timeOffset = CMTimeAdd(self.timeOffset, offset);
                    }
                }
                self.lastpts.flags = []
            }
        }
        
        if ((self.timeOffset.value) > 0){
            self.lastpts = CMTimeSubtract(time, self.timeOffset)
        }else{
            self.lastpts = time
        }
        // record most recent time so we know the length of the pause
//        let ptsBuffer:CMTime = time
//        let dur:CMTime = CMSampleBufferGetDuration(sampleBuffer);
//        if (dur.value > 0){
//            self.lastpts = CMTimeAdd(ptsBuffer, dur);
//        }

        assetWriter.startSession(atSourceTime: self.lastpts)
        if (self.videoWriterInput.isReadyForMoreMediaData) {
            if (self.adaptor.assetWriterInput.isReadyForMoreMediaData) {
                DispatchQueue.main.sync {
                    let pixel = self.createPixelBuffer()
                    self.adaptor.append(pixel ?? pixelBuffer, withPresentationTime: self.lastpts)
                }
            }else{
                
            }
        } else {
            print("Not ready for video data");
        }

    }
    func stopRecord(){
        if(self.videoWriterInput == nil){
            return
        }
        if self.assetWriter.status == .writing {
            
            self.videoWriterInput.markAsFinished()
            self.assetWriter.finishWriting {
                
            }
            
            return
        }
      
    }
    private func createPixelBuffer() -> CVPixelBuffer? {
           let width = Int(UIScreen.main.bounds.width)
           let height = Int(UIScreen.main.bounds.height)
           
           var pixelBuffer: CVPixelBuffer?
           let attributes: [CFString: Any] = [
               kCVPixelBufferCGImageCompatibilityKey: true,
               kCVPixelBufferCGBitmapContextCompatibilityKey: true
           ]
           
           let status = CVPixelBufferCreate(
               kCFAllocatorDefault,
               width,
               height,
               kCVPixelFormatType_32ARGB,
               attributes as CFDictionary,
               &pixelBuffer
           )
           
           guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
               return nil
           }
           
           CVPixelBufferLockBaseAddress(buffer, .readOnly)
           defer {
               CVPixelBufferUnlockBaseAddress(buffer, .readOnly)
           }
           
           guard let context = CGContext(
               data: CVPixelBufferGetBaseAddress(buffer),
               width: width,
               height: height,
               bitsPerComponent: 8,
               bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
               space: CGColorSpaceCreateDeviceRGB(),
               bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
           ) else { return nil }
           
           UIGraphicsPushContext(context)
           defer { UIGraphicsPopContext() }
           
           // 关键修复：应用坐标系变换
           context.translateBy(x: 0, y: CGFloat(height))
           context.scaleBy(x: 1.0, y: -1.0)
           
        if #available(iOS 15.0, *) {
            let keyWindow = UIApplication.shared.connectedScenes
                .map({ $0 as? UIWindowScene })
                .compactMap({ $0 })
                .first?.windows.first ?? UIWindow()
            keyWindow.drawHierarchy(in: CGRect(x: 0, y: 0, width: width, height: height), afterScreenUpdates: false)
        }else{
            let keyWindow = UIApplication.shared.windows.first ?? UIWindow()
            keyWindow.drawHierarchy(in: CGRect(x: 0, y: 0, width: width, height: height), afterScreenUpdates: false)
        }
           return buffer
       }
    
}
