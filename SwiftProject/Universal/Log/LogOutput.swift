import Foundation

public protocol LogOutput {
    func write(_ entry: LogEntry)
}
public class FileOutput: LogOutput {
    private let fileManager = FileManager.default
    private let queue = DispatchQueue(label: "com.logger.fileoutput", qos: .utility)
    private let maxFileSize: UInt64 = 10 * 1024 * 1024 // 10MB
    private let maxFileCount = 5
    
    private var currentFileHandle: FileHandle?
    private var currentLogFile: URL?
    
    public init() {
        setupLogDirectory()
        rotateLogFilesIfNeeded()
        openCurrentLogFile()
    }
    
    deinit {
        try? currentFileHandle?.close()
    }
    
    public func write(_ entry: LogEntry) {
        queue.async {
            guard let data = (entry.formattedMessage + "\n").data(using: .utf8) else { return }
            
            self.checkAndRotateLogFileIfNeeded()
            
            do {
                try self.currentFileHandle?.write(contentsOf: data)
            } catch {
                print("Error writing to log file: \(error)")
            }
        }
    }
    
    private func setupLogDirectory() {
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let logsDirectory = documentsDirectory.appendingPathComponent("Logs")
        
        do {
            try fileManager.createDirectory(at: logsDirectory, withIntermediateDirectories: true)
        } catch {
            print("Error creating logs directory: \(error)")
        }
    }
    
    private func getLogsDirectory() -> URL? {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Logs")
    }
    
    private func openCurrentLogFile() {
        guard let logsDirectory = getLogsDirectory() else { return }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let fileName = "log-\(dateFormatter.string(from: Date())).txt"
        currentLogFile = logsDirectory.appendingPathComponent(fileName)
        
        if !fileManager.fileExists(atPath: currentLogFile!.path) {
            fileManager.createFile(atPath: currentLogFile!.path, contents: nil)
        }
        
        do {
            currentFileHandle = try FileHandle(forWritingTo: currentLogFile!)
            try currentFileHandle?.seekToEnd()
        } catch {
            print("Error opening log file: \(error)")
        }
    }
    
    private func checkAndRotateLogFileIfNeeded() {
        guard let currentLogFile = currentLogFile,
              let attributes = try? fileManager.attributesOfItem(atPath: currentLogFile.path),
              let fileSize = attributes[.size] as? UInt64 else { return }
        
        if fileSize >= maxFileSize {
            rotateLogFilesIfNeeded()
            try? currentFileHandle?.close()
            openCurrentLogFile()
        }
    }
    
    private func rotateLogFilesIfNeeded() {
        guard let logsDirectory = getLogsDirectory() else { return }
        
        do {
            let logFiles = try fileManager.contentsOfDirectory(at: logsDirectory,
                                                             includingPropertiesForKeys: [.creationDateKey],
                                                             options: [.skipsHiddenFiles])
                .filter { $0.pathExtension == "txt" }
                .sorted { file1, file2 in
                    let date1 = try? file1.resourceValues(forKeys: [.creationDateKey]).creationDate
                    let date2 = try? file2.resourceValues(forKeys: [.creationDateKey]).creationDate
                    return date1 ?? Date() > date2 ?? Date()
                }
            
            if logFiles.count >= maxFileCount {
                for file in logFiles[maxFileCount-1..<logFiles.count] {
                    try? fileManager.removeItem(at: file)
                }
            }
        } catch {
            print("Error rotating log files: \(error)")
        }
    }
}

public class EncryptedFileOutput: LogOutput {
    private let encryptionKey: String
    private let fileOutput: FileOutput
    
    public init(encryptionKey: String) {
        self.encryptionKey = encryptionKey
        self.fileOutput = FileOutput()
    }
    
    public func write(_ entry: LogEntry) {
        // Simple XOR encryption for demonstration
        guard let data = entry.formattedMessage.data(using: .utf8),
              let keyData = encryptionKey.data(using: .utf8) else { return }
        
        var encryptedData = Data(count: data.count)
        for i in 0..<data.count {
            let keyByte = keyData[i % keyData.count]
            let dataByte = data[i]
            encryptedData[i] = dataByte ^ keyByte
        }
        
        let encryptedEntry = LogEntry(
            timestamp: entry.timestamp,
            level: entry.level,
            message: encryptedData.base64EncodedString(),
            module: entry.module,
            file: entry.file,
            function: entry.function,
            line: entry.line
        )
        
        fileOutput.write(encryptedEntry)
    }
} 
