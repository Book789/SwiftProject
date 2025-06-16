import Foundation

public enum LogLevel: Int {
    
    case debug = 0
    case info = 1
    case warning = 2
    case error = 3
    case fatal = 4
    
    var symbol: String {
        switch self {
        case .debug: return "🔍"
        case .info: return "ℹ️"
        case .warning: return "⚠️"
        case .error: return "❌"
        case .fatal: return "💀"
        }
    }
    
    var color: String {
        switch self {
        case .debug: return "\u{001B}[0;37m"  // 灰色
        case .info: return "\u{001B}[0;32m"   // 绿色
        case .warning: return "\u{001B}[0;33m" // 黄色
        case .error: return "\u{001B}[0;31m"   // 红色
        case .fatal: return "\u{001B}[0;94m"   // 蓝色
        }
    }
    var description: String {
        switch self {
        case .debug: return "DEBUG"
        case .info: return "INFO"
        case .warning: return "WARNING"
        case .error: return "ERROR"
        case .fatal: return "FATAL"
        }
    }
} 
