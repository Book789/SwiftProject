
//
//  MediaPipePoseDetector.swift
//  SwiftProject
//
//  Created by cloud on 2025/11/12.
//
import UIKit
import AVFoundation
import MediaPipeTasksVision

/// 人体姿态检测结果代理协议
public protocol PoseDetectionManagerDelegate: AnyObject {
    func poseDetectionManager(_ manager: MediaPipePoseDetector, didDetectPoses poses: [Pose])
    func poseDetectionManager(_ manager: MediaPipePoseDetector, didFailWithError error: Error)
}
/// 人体姿态检测管理器
public final class MediaPipePoseDetector: NSObject {
    
    // MARK: - Public Properties
    public weak var delegate: PoseDetectionManagerDelegate?
    public var config: PoseDetectionConfig
    
    // MARK: - Private Properties
    private var poseLandmarker: PoseLandmarker?
    
    // MARK: - Initialization
    public init(config: PoseDetectionConfig = PoseDetectionConfig()) {
        self.config = config
        super.init()
        setupPoseLandmarker()
        
    }
    
    // MARK: - Private Methods
    private func setupPoseLandmarker() {
        guard let modelPath = Bundle.main.path(
            forResource: config.modelName,
            ofType: "task"
        ) else {
            delegate?.poseDetectionManager(self, didFailWithError: PoseDetectionError.modelNotFound)
            return
        }
        
        let options = PoseLandmarkerOptions()
        options.baseOptions.modelAssetPath = modelPath
        options.baseOptions.delegate = .GPU
        options.runningMode = config.runningMode
        options.numPoses = config.maxPoses
        options.minPoseDetectionConfidence = config.minPoseDetectionConfidence
        options.minPosePresenceConfidence = config.minPosePresenceConfidence
        options.minTrackingConfidence = config.minTrackingConfidence
        options.poseLandmarkerLiveStreamDelegate = self

        do {
            poseLandmarker = try PoseLandmarker(options: options)
        } catch {
            delegate?.poseDetectionManager(self, didFailWithError: PoseDetectionError.landmarkerInitializationFailed(error))
        }
    }
    // MARK: - Public Methods
    public func detectAsync(pixelBuffer: CVPixelBuffer, timestampInMilliseconds: Int) {
        guard let poseLandmarker = poseLandmarker else {
           return
        }
        
        guard let mpImage = try? MPImage(pixelBuffer: pixelBuffer,orientation:UIImage.Orientation.up) else {
            return
        }
        try? poseLandmarker.detectAsync(image: mpImage, timestampInMilliseconds: timestampInMilliseconds)
        
    }

    
    
}
extension MediaPipePoseDetector:PoseLandmarkerLiveStreamDelegate{
    public func poseLandmarker(_ poseLandmarker: PoseLandmarker, didFinishDetection result: PoseLandmarkerResult?, timestampInMilliseconds: Int, error: (any Error)?) {
        if let error = error {
            print("检测错误: \(error)")
            return
        }
        
        guard let result = result else { return }
        
        // 处理检测结果
        DispatchQueue.main.async {
            let poses = result.landmarks.map { landmark in
                Pose(landmarks: landmark, timestamp: TimeInterval(timestampInMilliseconds))
            }
            self.delegate?.poseDetectionManager(self, didDetectPoses: poses)
            // 更新UI或处理姿态数据
//            print(poses)
        }
    }
}

/// 人体姿态数据结构
public struct Pose {
    public let landmarks: [NormalizedLandmark]
    public let timestamp: TimeInterval
    public let confidence: Float?
    
    public init(landmarks: [NormalizedLandmark], timestamp: TimeInterval, confidence: Float? = nil) {
        self.landmarks = landmarks
        self.timestamp = timestamp
        self.confidence = confidence
    }
}
/// 人体姿态检测配置
public struct PoseDetectionConfig {
    public let modelName: String
    public let maxPoses: Int
    public let minPoseDetectionConfidence: Float
    public let minPosePresenceConfidence: Float
    public let minTrackingConfidence: Float
    public let runningMode: RunningMode
    
    public init(modelName: String = "pose_landmarker_full",
                maxPoses: Int = 1,
                minPoseDetectionConfidence: Float = 0.7,
                minPosePresenceConfidence: Float = 0.7,
                minTrackingConfidence: Float = 0.7,
                runningMode: RunningMode = .liveStream) {
        self.modelName = modelName
        self.maxPoses = maxPoses
        self.minPoseDetectionConfidence = minPoseDetectionConfidence
        self.minPosePresenceConfidence = minPosePresenceConfidence
        self.minTrackingConfidence = minTrackingConfidence
        self.runningMode = runningMode
    }
}
// MARK: - Error Handling
public enum PoseDetectionError: Error, LocalizedError {
    case modelNotFound
    case landmarkerNotInitialized
    case landmarkerInitializationFailed(Error)
    case cameraPermissionDenied
    case cameraSessionNotAvailable
    case cameraDeviceNotFound
    case imageConversionFailed
    case detectionFailed(Error)
    
    public var errorDescription: String? {
        switch self {
        case .modelNotFound:
            return "姿态检测模型文件未找到"
        case .landmarkerNotInitialized:
            return "姿态检测器未初始化"
        case .landmarkerInitializationFailed(let error):
            return "姿态检测器初始化失败: \(error.localizedDescription)"
        case .cameraPermissionDenied:
            return "摄像头权限被拒绝"
        case .cameraSessionNotAvailable:
            return "摄像头会话不可用"
        case .cameraDeviceNotFound:
            return "未找到可用的摄像头设备"
        case .imageConversionFailed:
            return "图片转换失败"
        case .detectionFailed(let error):
            return "姿态检测失败: \(error.localizedDescription)"
        }
    }
}
