import AVFoundation
import VideoToolbox
import UIKit

// MARK: - AVPlayerItem 通知扩展（公开标准写法）
extension NSNotification.Name {
    /// 播放缓存为空（需要加载更多数据）
    static let AVPlayerItemPlaybackBufferEmpty = NSNotification.Name(rawValue: "AVPlayerItemPlaybackBufferEmptyNotification")
    /// 播放缓存充足（可以继续播放）
    static let AVPlayerItemPlaybackLikelyToKeepUp = NSNotification.Name(rawValue: "AVPlayerItemPlaybackLikelyToKeepUpNotification")
    /// 播放完成
    static let AVPlayerItemDidPlayToEndTime = NSNotification.Name(rawValue: "AVPlayerItemDidPlayToEndTimeNotification")
}

// MARK: - UIDevice 扩展（获取精准设备型号）
extension UIDevice {
    var modelIdentifier: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
}

/// 视频缓存模型
struct VideoCacheModel {
    let url: URL
    let firstFrame: UIImage?
    let lastPlayTime: CMTime
    let cacheTime: Date
    let duration: CMTime
}

/// 播放器配置
struct VideoPlayerConfig {
    /// 是否启用硬件解码
    var enableHardwareDecode = true
    /// 预加载阈值（单位：秒）
    var preloadThreshold: Double = 2
    /// 首帧缓存过期时间（单位：小时）
    var firstFrameCacheExpireHours: Double = 24
    /// 最大缓存大小（单位：MB）
    var maxCacheSize: Double = 100
}

/// 视频播放器封装类（最终无错误版）
class VideoPlayer: NSObject {
    // MARK: - 公开属性
    /// 播放器实例
    public private(set) var player: AVPlayer!
    /// 播放器层
    public let playerLayer: AVPlayerLayer
    /// 播放器配置
    public var config = VideoPlayerConfig()
    /// 播放状态回调
    public var playStateChanged: ((_ isPlaying: Bool) -> Void)?
    /// 首帧加载完成回调
    public var firstFrameLoaded: ((_ image: UIImage?) -> Void)?
    /// 播放器错误回调
    public var playerError: ((_ error: Error?) -> Void)?
    
    // MARK: - 私有属性
    /// 当前播放URL
    private var currentURL: URL?
    /// 播放项（KVO 自动管理）
    private var playerItem: AVPlayerItem? {
        didSet {
            // 移除旧的 KVO 监听
            if let oldItem = oldValue {
                removePlayerItemObservers(for: oldItem)
            }
            // 添加新的 KVO 监听
            if let newItem = playerItem {
                addPlayerItemObservers(for: newItem)
            }
        }
    }
    /// 资源加载器
    private var resourceLoader: VideoResourceLoader?
    /// 缓存管理器
    private let cacheManager = VideoCacheManager()
    /// 播放历史管理器
    private let historyManager = VideoPlayHistoryManager()
    /// 首帧加载队列
    private let firstFrameQueue = DispatchQueue(label: "com.videoPlayer.firstFrameQueue", qos: .userInitiated)
    /// 时间观察器
    private var timeObserver: Any?
    /// KVO 上下文（避免冲突）
    private var playerItemObservationContext = 0
    
    // MARK: - 初始化
    override init() {
        player = AVPlayer()
        playerLayer = AVPlayerLayer(player: player)
        super.init()
        
        setupPlayerConfig()
        setupNotifications()
    }
    
    /// 带配置初始化
    init(config: VideoPlayerConfig) {
        self.config = config
        player = AVPlayer()
        playerLayer = AVPlayerLayer(player: player)
        super.init()
        
        setupPlayerConfig()
        setupNotifications()
    }
    
    // MARK: - 公开方法
    /// 加载视频
    /// - Parameter url: 视频URL（支持本地/网络）
    // MARK: - 公开方法
    /// 加载视频
    /// - Parameter url: 视频URL（支持本地/网络）
    func loadVideo(with url: URL) {
        currentURL = url
        
        // 1. 优先异步读取首帧缓存（核心修复：替换同步调用）
        cacheManager.getFirstFrame(for: url) { [weak self] cachedImage in
            guard let self = self else { return }
            self.firstFrameLoaded?(cachedImage)
        }
        
        // 2. 初始化资源加载器和播放项
        configurePlayerItem(with: url)
        
        // 3. 异步预加载并缓存首帧
        preloadFirstFrame()
        
        // 4. 记录播放历史（用于进度恢复）
        historyManager.addPlayHistory(url: url)
    }

    // MARK: - 私有方法
    /// 异步预加载首帧并缓存（核心修复：避免主线程解析网络 asset）
    private func preloadFirstFrame() {
        guard let url = currentURL, let playerItem = playerItem else { return }
        
        // 切换到异步队列，且避免主线程解析 asset
        firstFrameQueue.async { [weak self] in
            guard let self = self else { return }
            
            // 配置 AVAssetImageGenerator（异步生成首帧）
            let generator = AVAssetImageGenerator(asset: playerItem.asset)
            generator.appliesPreferredTrackTransform = true
            generator.requestedTimeToleranceBefore = CMTime.zero
            generator.requestedTimeToleranceAfter = CMTime(seconds: 0.1, preferredTimescale: 1000)
            
            // 使用异步 API 生成首帧（替换同步 copyCGImage）
            let time = CMTime.zero
            generator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)]) { [weak self] requestedTime, image, actualTime, result, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("首帧预加载失败：\(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.firstFrameLoaded?(nil)
                    }
                    return
                }
                
                guard let image = image, result == .succeeded else {
                    DispatchQueue.main.async {
                        self.firstFrameLoaded?(nil)
                    }
                    return
                }
                
                // 异步缓存首帧
                let firstFrame = UIImage(cgImage: image)
                self.cacheManager.cacheFirstFrame(image: firstFrame, for: url) {
                    DispatchQueue.main.async {
                        self.firstFrameLoaded?(firstFrame)
                    }
                }
            }
        }
    }
    
    /// 播放视频
    func play() {
        guard player.currentItem?.status == .readyToPlay else {
            print("播放器未就绪，暂不播放")
            return
        }
        player.play()
        playStateChanged?(true)
    }
    
    /// 暂停视频
    func pause() {
        player.pause()
        playStateChanged?(false)
        
        // 保存当前播放进度（5秒内重复暂停不重复保存）
        guard let url = currentURL,
              let currentTime = player.currentItem?.currentTime(),
              currentTime.seconds > 0 else { return }
        historyManager.updatePlayProgress(url: url, progress: currentTime.seconds)
    }
    
    /// 销毁播放器（释放资源）
    func destroy() {
        pause()
        player.replaceCurrentItem(with: nil)
        playerItem = nil
        resourceLoader = nil
        
        // 移除时间观察器
        if let observer = timeObserver {
            player.removeTimeObserver(observer)
            timeObserver = nil
        }
        
        // 移除所有通知监听
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - 私有核心配置
    /// 基础播放器配置
    private func setupPlayerConfig() {
        // 播放器层适配（保持宽高比）
        playerLayer.videoGravity = .resizeAspect
        // 硬件解码默认开启（可通过 config 关闭）
        player.automaticallyWaitsToMinimizeStalling = true // 默认保守策略
    }
    
    /// 配置硬件解码（全公开API）
    private func setupHardwareDecoder(for playerItem: AVPlayerItem) {
        guard config.enableHardwareDecode else { return }
        
        // 1. 基础硬解参数（系统自动启用 VideoToolbox）
        playerItem.preferredForwardBufferDuration = 5.0 // 前置缓冲5秒
        playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = true
        
        // 2. 根据设备性能动态调整解码策略（包含峰值码率配置）
        adjustDecoderStrategy(for: playerItem)
        
        // 3. 优先选择 H.264/H.265 硬解轨道
        setupHardwareDecodeTracks(for: playerItem)
    }
    
    /// 按设备性能调整解码策略（整合峰值码率配置）
    private func adjustDecoderStrategy(for playerItem: AVPlayerItem) {
        let deviceModel = UIDevice.current.modelIdentifier
        
        // 高性能设备（iPhone 15+/iPad Pro/M1+）：激进策略（减少缓冲等待）
        if deviceModel.contains("iPhone15") ||
           deviceModel.contains("iPad14") ||
           deviceModel.contains("MacBook") {
            player.automaticallyWaitsToMinimizeStalling = false
            playerItem.preferredPeakBitRate = 50_000_000 // 50Mbps（支持4K）
        }
        // 中性能设备（iPhone 12-14/iPad Air）：平衡策略
        else if deviceModel.contains("iPhone14") ||
                deviceModel.contains("iPhone13") ||
                deviceModel.contains("iPhone12") {
            player.automaticallyWaitsToMinimizeStalling = true
            playerItem.preferredPeakBitRate = 30_000_000 // 30Mbps（支持1080P 60fps）
        }
        // 低性能设备（iPhone 11/SE/旧iPad）：保守策略
        else {
            player.automaticallyWaitsToMinimizeStalling = true
            playerItem.preferredPeakBitRate = 10_000_000 // 10Mbps（支持720P）
        }
    }
    
    /// 筛选硬解轨道（H.264/H.265）
    private func setupHardwareDecodeTracks(for playerItem: AVPlayerItem) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            // 获取视频轨道
            let videoTracks = playerItem.asset.tracks(withMediaType: .video)
            guard !videoTracks.isEmpty else { return }
            
            // 筛选支持硬件解码的轨道
            let hardwareTracks = videoTracks.filter { track in
                guard let formatDescs = track.formatDescriptions as? [CMFormatDescription] else {
                    return false
                }
                // 仅保留 H.264 或 H.265 编码（iOS硬解核心支持）
                return formatDescs.contains { desc in
                    let codecType = CMFormatDescriptionGetMediaSubType(desc)
                    return codecType == kCMVideoCodecType_H264 || codecType == kCMVideoCodecType_HEVC
                }
            }
            
            // 有硬解轨道时，无需额外操作（已在 adjustDecoderStrategy 中配置码率）
            if !hardwareTracks.isEmpty {
                DispatchQueue.main.async {
                    print("✅ 检测到硬解轨道（H.264/H.265），已启用硬件解码")
                }
            } else {
                DispatchQueue.main.async {
                    print("⚠️ 未检测到硬解轨道，将使用软件解码")
                }
            }
        }
    }
    
    /// 配置播放项（核心逻辑）
    /// 配置播放项（核心逻辑）
    private func configurePlayerItem(with url: URL) {
        // 初始化资源加载器（处理预加载/缓存）
        resourceLoader = VideoResourceLoader(
            url: url,
            cacheManager: cacheManager,
            preloadThreshold: config.preloadThreshold
        )
        
        guard let asset = resourceLoader?.asset else {
            playerError?(NSError(domain: "VideoPlayer", code: -1, userInfo: [NSLocalizedDescriptionKey: "资源加载器初始化失败"]))
            return
        }
        
        // 创建播放项
        let playerItem = AVPlayerItem(asset: asset)
        
        // 基础配置（默认码率，后续会被 adjustDecoderStrategy 覆盖）
        playerItem.preferredPeakBitRate = 10_000_000 // 默认10Mbps
        playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = true
        
        // 异步恢复历史播放进度（核心修复）
        historyManager.getPlayProgress(for: url) { [weak self] progress in
            guard let self = self, let progress = progress else { return }
            playerItem.seek(to: CMTime(seconds: progress, preferredTimescale: 1000))
        }
        
        // 替换播放项（触发 KVO 自动监听）
        player.replaceCurrentItem(with: playerItem)
        self.playerItem = playerItem
        
        // 启用硬件解码
        setupHardwareDecoder(for: playerItem)
        
        // 添加进度观察器（预加载策略）
        addTimeObserver()
    }
//    /// 预加载首帧并缓存
//    private func preloadFirstFrame() {
//        guard let url = currentURL, let playerItem = playerItem else { return }
//        
//        firstFrameQueue.async { [weak self] in
//            guard let self = self else { return }
//            
//            // 生成首帧图片
//            let generator = AVAssetImageGenerator(asset: playerItem.asset)
//            generator.appliesPreferredTrackTransform = true // 适配旋转
//            generator.requestedTimeToleranceBefore = CMTime.zero
//            generator.requestedTimeToleranceAfter = CMTime(seconds: 0.1, preferredTimescale: 1000)
//            
//            do {
//                let cgImage = try generator.copyCGImage(at: CMTime.zero, actualTime: nil)
//                let firstFrame = UIImage(cgImage: cgImage)
//                
//                // 缓存首帧（24小时过期）
//                self.cacheManager.cacheFirstFrame(image: firstFrame, for: url)
//                
//                // 主线程回调
//                DispatchQueue.main.async {
//                    self.firstFrameLoaded?(firstFrame)
//                }
//            } catch {
//                print("首帧预加载失败：\(error.localizedDescription)")
//                DispatchQueue.main.async {
//                    self.firstFrameLoaded?(nil)
//                }
//            }
//        }
//    }
    
    /// 添加播放进度观察器（智能预加载）
    /// 添加播放进度观察器（优化：减少预加载触发频率）
    private func addTimeObserver() {
        // 移除旧观察器
        if let observer = timeObserver {
            player.removeTimeObserver(observer)
            timeObserver = nil
        }
        
        // 延长检测间隔：5秒一次（而非1秒），减少重复调用
        let interval = CMTime(seconds: 5.0, preferredTimescale: 1000)
        timeObserver = player.addPeriodicTimeObserver(
            forInterval: interval,
            queue: .main
        ) { [weak self] time in
            guard let self = self, let url = self.currentURL else { return }
            
            // 智能预加载：仅当剩余时间 < 预加载阈值，且不在预加载中时触发
            let currentProgress = CMTimeGetSeconds(time)
            let totalDuration = CMTimeGetSeconds(self.playerItem?.duration ?? CMTime.zero)
            if totalDuration - currentProgress < self.config.preloadThreshold,
               !(self.resourceLoader?.isPreloading ?? false){ // 新增：防重复
                self.resourceLoader?.preloadMoreData()
            }
            
            // 每5秒保存一次播放进度
            if Int(currentProgress) % 5 == 0 {
                self.historyManager.updatePlayProgress(url: url, progress: currentProgress)
            }
        }
    }
    // MARK: - KVO 监听（替代私有通知）
    /// 添加播放项 KVO 监听
    private func addPlayerItemObservers(for playerItem: AVPlayerItem) {
        // 监听播放状态
        playerItem.addObserver(
            self,
            forKeyPath: #keyPath(AVPlayerItem.status),
            options: [.new, .old],
            context: &playerItemObservationContext
        )
        // 监听播放错误
        playerItem.addObserver(
            self,
            forKeyPath: #keyPath(AVPlayerItem.error),
            options: .new,
            context: &playerItemObservationContext
        )
    }
    
    /// 移除播放项 KVO 监听
    private func removePlayerItemObservers(for playerItem: AVPlayerItem) {
        playerItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), context: &playerItemObservationContext)
        playerItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.error), context: &playerItemObservationContext)
    }
    
    /// KVO 回调处理
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        // 只处理当前上下文的 KVO
        guard context == &playerItemObservationContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        guard let playerItem = object as? AVPlayerItem else { return }
        
        // 处理播放状态变化
        if keyPath == #keyPath(AVPlayerItem.status) {
            switch playerItem.status {
            case .readyToPlay:
                print("✅ 播放器准备就绪")
                self.play()
            case .failed:
                let error = playerItem.error ?? NSError(domain: "VideoPlayer", code: -2, userInfo: [NSLocalizedDescriptionKey: "播放项加载失败"])
                print("❌ 播放失败：\(error.localizedDescription)")
                playStateChanged?(false)
                playerError?(error)
            case .unknown:
                print("ℹ️ 播放器状态未知（加载中）")
            @unknown default:
                break
            }
        }
        
        // 处理播放错误
        if keyPath == #keyPath(AVPlayerItem.error), let error = playerItem.error {
            playerError?(error)
        }
    }
    
    // MARK: - 通知监听（标准化写法）
    private func setupNotifications() {
        // 1. 播放完成通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemDidPlayToEndTime),
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )
        
        // 2. 缓存为空（需要预加载）
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemPlaybackBufferEmpty),
            name: .AVPlayerItemPlaybackBufferEmpty,
            object: nil
        )
        
        // 3. 缓存充足（恢复播放）
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemPlaybackLikelyToKeepUp),
            name: .AVPlayerItemPlaybackLikelyToKeepUp,
            object: nil
        )
    }
    
    // MARK: - 通知回调
    @objc private func playerItemDidPlayToEndTime(_ notification: Notification) {
        pause()
        // 播放完成后重置进度
        guard let url = currentURL else { return }
        historyManager.updatePlayProgress(url: url, progress: 0)
        playStateChanged?(false)
    }
    
    @objc private func playerItemPlaybackBufferEmpty(_ notification: Notification) {
        print("⚠️ 播放缓存为空，开始预加载更多数据")
        resourceLoader?.preloadMoreData()
    }
    
    @objc private func playerItemPlaybackLikelyToKeepUp(_ notification: Notification) {
        print("✅ 播放缓存充足，恢复播放")
        if player.rate == 0 { // 暂停状态时自动恢复播放
            play()
        }
    }
    
    // MARK: - 析构函数（释放资源）
    deinit {
        // 移除 KVO 监听
        if let playerItem = playerItem {
            removePlayerItemObservers(for: playerItem)
        }
        // 销毁播放器
        destroy()
        print("📌 VideoPlayer 已释放")
    }
}

// MARK: - 依赖类的空实现（确保编译通过）
/// 资源加载器（空实现，可根据业务扩展）
//class VideoResourceLoader {
//    let asset: AVURLAsset
//    init(url: URL, cacheManager: VideoCacheManager, preloadThreshold: Double) {
//        let assetOptions: [String: Any] = [
//            AVURLAssetPreferPreciseDurationAndTimingKey: true,
//            AVURLAssetAllowsCellularAccessKey: true
//        ]
//        self.asset = AVURLAsset(url: url, options: assetOptions)
//    }
//    
//    func preloadMoreData() {
//        // 预加载逻辑可在此实现（如加载后续分片、缓存更多数据）
//        print("📥 开始预加载更多视频数据")
//    }
//}

/// 缓存管理器（空实现，可根据业务扩展）
//class VideoCacheManager {
//    func getFirstFrame(for url: URL) -> UIImage? {
//        // 从本地缓存读取首帧逻辑
//        return nil
//    }
//    
//    func cacheFirstFrame(image: UIImage, for url: URL) {
//        // 缓存首帧到本地逻辑
//        print("💾 缓存视频首帧：\(url.lastPathComponent)")
//    }
//}

/// 播放历史管理器（空实现，可根据业务扩展）
//class VideoPlayHistoryManager {
//    func addPlayHistory(url: URL) {
//        // 记录播放历史逻辑
//        print("📝 记录播放历史：\(url.lastPathComponent)")
//    }
//    
//    func updatePlayProgress(url: URL, progress: Double) {
//        // 更新播放进度逻辑
//        print("⏱️ 更新播放进度：\(url.lastPathComponent) - \(progress)s")
//    }
//    
//    func getPlayProgress(for url: URL) -> Double? {
//        // 读取历史播放进度逻辑
//        return nil
//    }
//}
