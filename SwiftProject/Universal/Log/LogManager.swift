//
//  LogManager.swift
//  SwiftProject
//
//  Created by cloud on 2025/6/3.
//
/***
 分级日志：支持不同级别（Debug、Info、Warning、Error、Fatal）。
 分类日志：按模块分类（如网络、UI、数据库）。
 多输出渠道：控制台、本地文件、远程服务器上报。
 性能优化：异步写入、内存缓存、避免主线程阻塞。
 日志管理：滚动存储、自动清理、加密压缩。
 动态配置：运行时调整日志级别、开关特定模块日志。
 异常监控：崩溃日志捕获与关联分析。
*/
import UIKit

class LogManager: NSObject {
    
    public static let shared = LogManager()
    // MARK: - Properties
    private let queue = DispatchQueue(label: "com.logger.queue", qos: .utility)
    private var outputs: [LogOutput] = []
    private var minimumLogLevel: LogLevel = .debug
    private var enabledModules: Set<String> = Set(["default"])

    override init() {
        super.init()
        
        self.setupDefaultOutputs()
    }

    // MARK: - Logging Methods
    public func log(_ message: String,
                   level: LogLevel,
                   module: String = "default",
                   file: String = #file,
                   function: String = #function,
                   line: Int = #line) {
        
        queue.async {
            guard level.rawValue >= self.minimumLogLevel.rawValue,
                  self.enabledModules.contains(module) else { return }
            
            let logEntry = LogEntry(
                timestamp: Date(),
                level: level,
                message: message,
                module: module,
                file: file,
                function: function,
                line: line
            )
            print(logEntry.formattedMessage)
            
            self.outputs.forEach { output in
                output.write(logEntry)
            }
        }
    }
    
    // MARK: - Convenience Methods
    public func debug(_ message: String, module: String = "default", file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .debug, module: module, file: file, function: function, line: line)
    }
    
    public func info(_ message: String, module: String = "default", file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .info, module: module, file: file, function: function, line: line)
    }
    
    public func warning(_ message: String, module: String = "default", file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .warning, module: module, file: file, function: function, line: line)
    }
    
    public func error(_ message: String, module: String = "default", file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .error, module: module, file: file, function: function, line: line)
    }
    
    public func fatal(_ message: String, module: String = "default", file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .fatal, module: module, file: file, function: function, line: line)
    }

    // MARK: - Output Management
    public func addOutput(_ output: LogOutput) {
        queue.async {
            self.outputs.append(output)
        }
    }
    
    public func removeAllOutputs() {
        queue.async {
            self.outputs.removeAll()
        }
    }
    
    private func setupDefaultOutputs() {
//        addOutput(ConsoleOutput())
        addOutput(FileOutput())
    }


}
