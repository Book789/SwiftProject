import AVFoundation

// MARK: - 资源加载器（修复 cancelled 错误 + 稳定预加载）
class VideoResourceLoader: NSObject, AVAssetResourceLoaderDelegate {
    var asset: AVURLAsset?
    private let cacheManager: VideoCacheManager
    private let preloadThreshold: Double
    private var dataTask: URLSessionDataTask?
    private var cachedData = Data()
    private var currentOffset: Int64 = 0
    // 新增：任务状态标记（避免重复取消/调用）
    var isPreloading = false
    // 新增：最小预加载间隔（避免每秒重复触发）
    private let minPreloadInterval: TimeInterval = 3.0
    private var lastPreloadTime: Date = Date.distantPast
    
    // MARK: - 初始化
    init(url: URL, cacheManager: VideoCacheManager, preloadThreshold: Double) {
        self.cacheManager = cacheManager
        self.preloadThreshold = preloadThreshold
        
        // 配置 AVURLAsset，启用资源加载代理
        let assetOptions: [String: Any] = [
            AVURLAssetPreferPreciseDurationAndTimingKey: true,
            AVURLAssetAllowsCellularAccessKey: true
        ]
        self.asset = AVURLAsset(url: url, options: assetOptions)
        super.init()
        
        // 设置资源加载代理
        self.asset?.resourceLoader.setDelegate(self, queue: DispatchQueue(label: "com.videoPlayer.resourceLoader"))
    }
    
    // MARK: - 预加载更多数据（核心修复：防重复取消）
    func preloadMoreData() {
        // 1. 防高频重复调用：3秒内不重复预加载
        let now = Date()
        if now.timeIntervalSince(lastPreloadTime) < minPreloadInterval {
            print("⏳ 预加载频率限制，跳过本次调用")
            return
        }
        lastPreloadTime = now
        
        // 2. 防重复任务：已有预加载任务则直接返回
        guard !isPreloading else {
            print("⏳ 已有预加载任务运行中，跳过本次调用")
            return
        }
        
        guard let url = asset?.url else { return }
        
        // 3. 安全取消旧任务（仅当任务未完成时）
        if let task = dataTask, task.state == .running {
            print("🔄 取消旧预加载任务（准备新任务）")
            task.cancel()
        }
        
        // 4. 计算预加载范围：小分片（2MB）避免超时
        let preloadSize = Int64(2 * 1024 * 1024) // 2MB 分片（稳定优先）
        let startOffset = currentOffset + Int64(cachedData.count)
        let endOffset = startOffset + preloadSize - 1
        
        // 5. 标记任务状态
        isPreloading = true
        
        // 6. 创建请求（兼容 200/206 响应）
        var request = URLRequest(url: url)
        // 兼容服务器：先尝试 Range 请求，失败则自动降级为完整请求
        request.addValue("bytes=\(startOffset)-\(endOffset)", forHTTPHeaderField: "Range")
        request.cachePolicy = .returnCacheDataElseLoad
        request.timeoutInterval = 15.0 // 延长超时时间
        
        // 7. 发起预加载请求
        dataTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            // 重置任务状态（无论成功/失败）
            defer {
                self.isPreloading = false
                self.dataTask = nil
            }
            
            // 区分「主动取消」和「真失败」
            if let error = error {
                // 主动取消：不报错，仅日志
                if (error as NSError).code == NSURLErrorCancelled {
                    print("🔄 预加载任务被主动取消（非失败）")
                    return
                }
                // 真失败：输出错误
                print("❌ 预加载真失败：\(error.localizedDescription)")
                return
            }
            
            guard let data = data, !data.isEmpty else {
                print("⚠️ 预加载无数据返回（可能服务器不支持Range）")
                // 降级方案：加载完整文件（不再用Range）
                self.loadFullDataFallback(url: url)
                return
            }
            
            // 8. 处理响应（兼容 200/206）
            if let httpResponse = response as? HTTPURLResponse {
                print("✅ 预加载响应状态码：\(httpResponse.statusCode)")
                // 206 = 分段成功，200 = 完整文件（也正常处理）
                if httpResponse.statusCode == 200 {
                    self.currentOffset = 0 // 完整文件重置偏移
                } else if httpResponse.statusCode == 206 {
                    self.currentOffset = endOffset // 分段文件更新偏移
                }
            }
            
            // 9. 缓存数据
            self.cachedData.append(data)
            print("📥 预加载完成：\(data.count) 字节，总缓存：\(self.cachedData.count) 字节")
        }
        dataTask?.resume()
    }
    
    // MARK: - 降级方案：加载完整文件（服务器不支持Range时）
    private func loadFullDataFallback(url: URL) {
        guard !isPreloading else { return }
        
        isPreloading = true
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30.0)
        
        dataTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            defer {
                self.isPreloading = false
                self.dataTask = nil
            }
            
            if let error = error {
                if (error as NSError).code == NSURLErrorCancelled {
                    print("🔄 完整文件加载任务被取消")
                    return
                }
                print("❌ 完整文件加载失败：\(error.localizedDescription)")
                return
            }
            
            guard let data = data, !data.isEmpty else {
                print("⚠️ 完整文件加载无数据")
                return
            }
            
            self.cachedData = data // 替换为完整数据
            self.currentOffset = Int64(data.count)
            print("📥 完整文件加载完成：\(data.count) 字节（降级方案生效）")
        }
        dataTask?.resume()
    }
    
    // MARK: - AVAssetResourceLoaderDelegate（核心：稳定返回数据）
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        guard let dataRequest = loadingRequest.dataRequest else {
            loadingRequest.finishLoading(with: NSError(domain: "VideoResourceLoader", code: -1, userInfo: [NSLocalizedDescriptionKey: "无数据请求"]))
            return false
        }
        
        // 1. 获取请求范围（公开API）
        let requestedOffset = dataRequest.requestedOffset
        let requestedLength = dataRequest.requestedLength
        
        // 2. 检查缓存是否满足
        if requestedOffset + Int64(requestedLength) <= Int64(cachedData.count) {
            // 缓存足够：直接返回数据
            let range = Range<Data.Index>(NSRange(location: Int(requestedOffset), length: requestedLength))!
            let responseData = cachedData.subdata(in: range)
            dataRequest.respond(with: responseData)
            loadingRequest.finishLoading()
            print("📤 从缓存返回数据：\(responseData.count) 字节")
            return true
        } else {
            // 缓存不足：等待预加载（不重复发起请求）
            print("⌛ 缓存不足，等待预加载完成...")
            // 延迟1秒重试（避免立即失败）
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self = self else {
                    loadingRequest.finishLoading(with: NSError(domain: "VideoResourceLoader", code: -2, userInfo: [NSLocalizedDescriptionKey: "加载超时"]))
                    return
                }
                
                // 重试：缓存足够则返回，否则失败
                if requestedOffset + Int64(requestedLength) <= Int64(self.cachedData.count) {
                    let range = Range<Data.Index>(NSRange(location: Int(requestedOffset), length: requestedLength))!
                    let responseData = self.cachedData.subdata(in: range)
                    dataRequest.respond(with: responseData)
                    loadingRequest.finishLoading()
                    print("📤 重试后返回数据：\(responseData.count) 字节")
                } else {
                    loadingRequest.finishLoading(with: NSError(domain: "VideoResourceLoader", code: -3, userInfo: [NSLocalizedDescriptionKey: "缓存不足"]))
                    print("❌ 重试后仍缓存不足，加载失败")
                }
            }
            return true
        }
    }
    
    // MARK: - 安全取消任务（仅取消运行中的任务）
    func cancelAllTasks() {
        // 仅取消运行中的任务，避免触发 cancelled 错误
        if let task = dataTask, task.state == .running {
            task.cancel()
            print("🔌 取消运行中的预加载任务")
        }
        cachedData.removeAll()
        currentOffset = 0
        isPreloading = false
        lastPreloadTime = Date.distantPast
    }
    
    // MARK: - 析构函数
    deinit {
        cancelAllTasks()
        print("📌 VideoResourceLoader 已释放")
    }
}
