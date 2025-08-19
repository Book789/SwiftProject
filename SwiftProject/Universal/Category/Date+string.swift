//
//  Date+string.swift
//  SwiftProject
//
//  Created by cloud on 2025/8/19.
//

extension Date {
 
    func dateToString(_ format: String = "yyyy-MM-dd") -> String {
        dateFormatter.dateFormat = format
//        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // 确保时区正确，避免自动调整到本地时区的问题
//        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // 设置时区为GMT
        return dateFormatter.string(from: self)
    }
    static func dateToString(date:Date,format: String = "yyyy-MM-dd") -> String {
        dateFormatter.dateFormat = format
//        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // 确保时区正确，避免自动调整到本地时区的问题
//        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // 设置时区为GMT
        return dateFormatter.string(from: date)
    }

}
