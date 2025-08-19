//
//  String+date.swift
//  Start
//
//  Created by lixiuqin on 2025/6/10.
//
let dateFormatter = DateFormatter()

import UIKit

extension String {
    
    func stringToDate(_ format: String = "yyyy-MM-dd") -> Date {
        dateFormatter.dateFormat = format
//        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // 确保时区正确，避免自动调整到本地时区的问题
//        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // 设置时区为GMT
        return dateFormatter.date(from: self) ?? Date()
    }
    static func stringToDate(_ format: String = "yyyy-MM-dd",dateString:String) -> Date {
        dateFormatter.dateFormat = format
//        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // 确保时区正确，避免自动调整到本地时区的问题
//        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // 设置时区为GMT
        return dateFormatter.date(from: dateString) ?? Date()
    }

    /*
     * 获取当前日期 是周几
    *   dateString：需要转换的日期 为空字符串时 显示的为当前时间
    *   format：需要转换成的格式  默认 ：“yyyy-MM-dd” “Y年M月d日”
     switch weekday {
     case 1:
         return "Sunday"
     case 2:
         return "Monday"
     case 3:
         return "Tuesday"
     case 4:
         return "Wednesday"
     case 5:
         return "Thursday"
     case 6:
         return "Friday"
     case 7:
         return "Saturday"
     default:
         return nil
     }

    */
    static func dayOfWeek(for dateString: String, format: String = "yyyy-MM-dd") -> Int{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let calendar = Calendar.current
        guard let date = dateFormatter.date(from: dateString) else {
            return calendar.component(.weekday, from: Date())
        }
        
        return calendar.component(.weekday, from: date)
        
    }
    /**
     *  时间是否是当前周
     */
   static func isDateInCurrentWeek(_ date: Date) -> Bool {
        // 获取当前日历
        let calendar = Calendar.current
        
        // 获取本周的开始和结束日期（周日作为一周的开始）
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) else { return false }
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)! // 本周的结束日期是本周开始日期的后6天
        
        // 获取给定日期的开始和结束日期（时分秒都为0）
        let dateStart = calendar.startOfDay(for: date)
        let dateEnd = calendar.date(byAdding: .second, value: -1, to: calendar.date(byAdding: .day, value: 1, to: dateStart)!)! // 给定日期的结束时间是下一天的开始时间的前一秒
        
        // 判断给定日期是否在本周范围内
        return (dateStart >= startOfWeek && dateStart <= endOfWeek) || (dateEnd >= startOfWeek && dateEnd <= endOfWeek) || (dateStart <= startOfWeek && dateEnd >= endOfWeek)
    }

}

