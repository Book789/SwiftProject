//
//  VideoPlayerViewController.swift
//  SwiftProject
//
//  Created by cloud on 2026/3/21.
//

import UIKit

class VideoPlayerViewController: UIViewController {
    /// 自定义播放器
    private var videoPlayer: VideoPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayer()
    }
    
    private func setupPlayer() {
        // 配置播放器
        var config = VideoPlayerConfig()
        config.enableHardwareDecode = true
        config.preloadThreshold = 15.0
        
        // 初始化播放器
        videoPlayer = VideoPlayer(config: config)
        videoPlayer.playerLayer.frame = view.bounds
        view.layer.addSublayer(videoPlayer.playerLayer)
        
        // 设置回调
        videoPlayer.firstFrameLoaded = { [weak self] image in
            print("首帧加载完成：\(image != nil)")
            // 可以显示首帧占位图
        }
        
        videoPlayer.playStateChanged = { isPlaying in
            print("播放状态：\(isPlaying ? "播放中" : "已暂停")")
        }
        
        // 加载视频
        guard let videoURL = URL(string: "https://cdn.ydj.fit/app-vue/%E8%AF%A6%E6%83%85%E9%A1%B5%E9%A2%84%E8%A7%88%E8%A7%86%E9%A2%91.mp4") else { return }
        videoPlayer.loadVideo(with: videoURL)
        
        // 自动播放
        videoPlayer.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        videoPlayer.pause()
    }
    
    deinit {
        videoPlayer.destroy()
    }
}
