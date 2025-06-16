import Foundation

public struct LogEntry {
    let timestamp: Date
    let level: LogLevel
    let message: String
    let module: String
    let file: String
    let function: String
    let line: Int
    
    private let resetColor = "\u{001B}[0m"

    var formattedMessage: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let timestamp = dateFormatter.string(from: self.timestamp)
        let fileName = (file as NSString).lastPathComponent
        
        return "\(level.color)\(timestamp) \(level.symbol)[\(level.description)][\(module)] \(message) (\(fileName):\(function):\(line))\(resetColor)"
    }
} 
