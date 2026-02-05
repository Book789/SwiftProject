//
//  S_VideoCapture.swift
//  SwiftProject
//
//  Created by cloud on 2025/11/12.
//

import UIKit
import AVFoundation

class S_VideoCapture: NSObject {
    
    var sampleBufferOutputCallBack: ((CMSampleBuffer)->Void)?

    var bufferSize: CGSize = .zero

    //AVCaptureSession实例化后的变量，主要用于传递视频数据
    private var session = AVCaptureSession()
        
    //用于捕获输出视频数据，同时提供支持对每帧进行修改
    private var videoDataOutput = AVCaptureVideoDataOutput()
    
    //接收videoDataOutput的队列
    private var videoDataOutputQueue = DispatchQueue(label: "VideoDataOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
  
    
    override init() {
        super.init()
        
        self.setupAVCapture()
    }
    func setupAVCapture(position:AVCaptureDevice.Position = .front) {
            
        
        let deviceTypes: [AVCaptureDevice.DeviceType] = [
            .builtInWideAngleCamera,  // 广角镜头
            .builtInDualCamera,       // 双摄像头（如主摄+长焦）
            .builtInTrueDepthCamera   // TrueDepth摄像头（支持人像模式等）
        ]
        
        //解决相机 模糊的问题
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: deviceTypes,
            mediaType: .video,
            position: .unspecified
        )
        // videoDevice用于选择相机设备，比如前置还是后置
        guard let devices = discoverySession.devices.filter({ $0.position == position }).first  else {
               print("摄像头不可用")
               return
           }
        // 设置30fps
        if setFrameRate(for: devices, targetFrameRate: 30.0) {
            print("相机已配置为30fps")
        }
    
        //定义一个用于存储相机输入的数据流的变量
        guard let videoInput = try? AVCaptureDeviceInput(device: devices) else { return }

        
        session.beginConfiguration()      //开始设置session的参数
        session.sessionPreset = .high  // 设置输入数据的像素.
        
        //首先判断是否能添加输入数据流，如果不能就结束函数
        guard session.canAddInput(videoInput) else {
            print("Could not add video device input to the session")
            session.commitConfiguration()      //停止设置session参数
            return
        }
        session.addInput(videoInput)     //程序没停止则说明能够添加，正常加入


        if session.canAddOutput(videoDataOutput) {   //如果可以添加输出接口
            session.addOutput(videoDataOutput)      //添加
            
            // 如果设备正在处理某张图像帧，则新捕获的帧就丢弃
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
    
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
            
            //开启委托，将图片帧存入到队列中，等待videoDataOutput开启连接后就可由captureOutput函数持续接收队列中的数据
            videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
    
        } else {
            //失败就结束函数
            print("Could not add video data output to the session")
            session.commitConfiguration()
            return
        }
        videoDataOutput.connection(with: AVMediaType.video)?.videoOrientation = .portrait

        //videoDataOutput开启连接
        let captureConnection = videoDataOutput.connection(with: .video)
        captureConnection?.isEnabled = true
        if(position == .front){
            captureConnection?.isVideoMirrored = true   //前置摄像头捕获的视频镜像
        }
        do {
            try  devices.lockForConfiguration() //锁定设备
            //更新记录当前设备输入帧的格式大小
            let dimensions = CMVideoFormatDescriptionGetDimensions((devices.activeFormat.formatDescription))
            bufferSize.width = CGFloat(dimensions.width)
            bufferSize.height = CGFloat(dimensions.height)
            devices.unlockForConfiguration()    //解锁
        } catch {
            print(error)
        }

    
        session.commitConfiguration()   //session设置完成
    
    }
    func setFrameRate(for device: AVCaptureDevice, targetFrameRate: Double) -> Bool {
        do {
            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }
            
            // 查找支持目标帧率的格式
            let formats = device.formats
            for format in formats {
                let videoRanges = format.videoSupportedFrameRateRanges
                for range in videoRanges {
                    if range.minFrameRate <= targetFrameRate && range.maxFrameRate >= targetFrameRate {
                        device.activeFormat = format
                        
                        let duration = CMTimeMake(value: 1, timescale: Int32(targetFrameRate))
                        device.activeVideoMinFrameDuration = duration
                        device.activeVideoMaxFrameDuration = duration
                        
                        print("成功设置帧率: \(targetFrameRate) fps")
                        return true
                    }
                }
            }
            
            print("未找到支持 \(targetFrameRate) fps 的格式")
            return false
            
        } catch {
            print("配置失败: \(error.localizedDescription)")
            return false
        }
    }
    func startCaptureSession() {
        self.videoDataOutputQueue.async {
            self.session.startRunning()
        }
    }
    func stopCaptureSession() {
        if(self.session.isRunning){
            self.session.stopRunning()
        }
    }

}
extension S_VideoCapture:AVCaptureVideoDataOutputSampleBufferDelegate{
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection){
        self.sampleBufferOutputCallBack?(sampleBuffer)
    }
}
