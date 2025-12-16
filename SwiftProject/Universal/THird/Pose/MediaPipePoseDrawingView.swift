//
//  MediaPipePoseDrawingView.swift
//  SwiftProject
//
//  Created by cloud on 2025/11/26.
//
import UIKit
import MediaPipeTasksVision

/// 姿态关键点连接定义
public struct PoseConnection {
    public let start: Int
    public let end: Int
    
    public init(start: Int, end: Int) {
        self.start = start
        self.end = end
    }
}

/// 姿态绘制配置
public struct PoseDrawingConfig {
    public let pointRadius: CGFloat
    public let pointColor: UIColor
    public let connectionWidth: CGFloat
    public let connectionColor: UIColor
    public let showPoints: Bool
    public let showConnections: Bool
    
    public init(pointRadius: CGFloat = 4.0,
                pointColor: UIColor = .red,
                connectionWidth: CGFloat = 3.0,
                connectionColor: UIColor = .green,
                showPoints: Bool = true,
                showConnections: Bool = true) {
        self.pointRadius = pointRadius
        self.pointColor = pointColor
        self.connectionWidth = connectionWidth
        self.connectionColor = connectionColor
        self.showPoints = showPoints
        self.showConnections = showConnections
    }
}

/// 人体姿态绘制视图
public final class PoseDrawingView: UIView {
    
    // MARK: - Public Properties
    public var poses: [Pose] = []
    public var config: PoseDrawingConfig = PoseDrawingConfig()
    
    /// 预定义的人体姿态连接关系
    public static let defaultConnections: [PoseConnection] = [
        // 面部
        PoseConnection(start: 0, end: 1),
        PoseConnection(start: 1, end: 2),
        PoseConnection(start: 2, end: 3),
        PoseConnection(start: 3, end: 7),
        PoseConnection(start: 0, end: 4),
        PoseConnection(start: 4, end: 5),
        PoseConnection(start: 5, end: 6),
        PoseConnection(start: 6, end: 8),
        PoseConnection(start: 9, end: 10),
        
        // 身体
        PoseConnection(start: 11, end: 12),
        PoseConnection(start: 11, end: 13),
        PoseConnection(start: 13, end: 15),
        PoseConnection(start: 15, end: 17),
        PoseConnection(start: 15, end: 19),
        PoseConnection(start: 15, end: 21),
        PoseConnection(start: 17, end: 19),
        PoseConnection(start: 12, end: 14),
        PoseConnection(start: 14, end: 16),
        PoseConnection(start: 16, end: 18),
        PoseConnection(start: 16, end: 20),
        PoseConnection(start: 16, end: 22),
        PoseConnection(start: 18, end: 20),
        PoseConnection(start: 11, end: 23),
        PoseConnection(start: 12, end: 24),
        PoseConnection(start: 23, end: 24),
        
        // 左臂
        PoseConnection(start: 11, end: 13),
        PoseConnection(start: 13, end: 15),
        
        // 右臂
        PoseConnection(start: 12, end: 14),
        PoseConnection(start: 14, end: 16),
        
        // 左腿
        PoseConnection(start: 23, end: 25),
        PoseConnection(start: 25, end: 27),
        PoseConnection(start: 27, end: 29),
        PoseConnection(start: 27, end: 31),
        PoseConnection(start: 29, end: 31),
        
        // 右腿
        PoseConnection(start: 24, end: 26),
        PoseConnection(start: 26, end: 28),
        PoseConnection(start: 28, end: 30),
        PoseConnection(start: 28, end: 32),
        PoseConnection(start: 30, end: 32)
    ]
    
    // MARK: - Lifecycle
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // 清空画布
        context.clear(rect)
        
        for pose in poses {
            drawPose(pose, in: context)
        }
    }
    
    // MARK: - Public Methods
    
    /// 更新姿态数据并重绘
    public func updatePoses(_ poses: [Pose]) {
        self.poses = poses
        setNeedsDisplay()
    }
    
    /// 清空画布
    public func clear() {
        poses.removeAll()
        setNeedsDisplay()
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        backgroundColor = .clear
        isOpaque = false
    }
    
    private func drawPose(_ pose: Pose, in context: CGContext) {
        let landmarks = pose.landmarks
        
        // 绘制关键点连接
        if config.showConnections {
            drawConnections(for: landmarks, in: context)
        }
        
        // 绘制关键点
        if config.showPoints {
            drawLandmarks(for: landmarks, in: context)
        }
    }
    
    private func drawLandmarks(for landmarks: [NormalizedLandmark], in context: CGContext) {
        context.setFillColor(config.pointColor.cgColor)
        
        for landmark in landmarks {
            let point = convertNormalizedPointToViewCoordinates(
                normalizedX: CGFloat(landmark.x),
                normalizedY: CGFloat(landmark.y)
            )
            
            let pointRect = CGRect(
                x: point.x - config.pointRadius,
                y: point.y - config.pointRadius,
                width: config.pointRadius * 2,
                height: config.pointRadius * 2
            )
            
            context.fillEllipse(in: pointRect)
        }
    }
    
    private func drawConnections(for landmarks: [NormalizedLandmark], in context: CGContext) {
        context.setLineWidth(config.connectionWidth)
        context.setStrokeColor(config.connectionColor.cgColor)
        
        for connection in PoseDrawingView.defaultConnections {
            guard connection.start < landmarks.count,
                  connection.end < landmarks.count else { continue }
            
            let startLandmark = landmarks[connection.start]
            let endLandmark = landmarks[connection.end]
            
            let startPoint = convertNormalizedPointToViewCoordinates(
                normalizedX: CGFloat(startLandmark.x),
                normalizedY: CGFloat(startLandmark.y)
            )
            let endPoint = convertNormalizedPointToViewCoordinates(
                normalizedX: CGFloat(endLandmark.x),
                normalizedY: CGFloat(endLandmark.y)
            )
            
            context.move(to: startPoint)
            context.addLine(to: endPoint)
            context.strokePath()
        }
    }
    
    private func convertNormalizedPointToViewCoordinates(normalizedX: CGFloat, normalizedY: CGFloat) -> CGPoint {
        return CGPoint(
            x: normalizedX * bounds.width,
            y: normalizedY * bounds.height
//            y: (1 - normalizedY) * bounds.height
        )
    }
}
