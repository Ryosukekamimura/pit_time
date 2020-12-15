//
//  DateFormatter.swift
//  PitTime
//
//  Created by 神村亮佑 on 2020/11/24.
//

import Foundation

class DateUtils {
    // Date型からString
    class func stringFromDate(date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.string(from: date)
    }

    // String型からDate
    class func dateFromString(string: String, format: String) -> Date {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.date(from: string)!
    }

    // String型のMonth --> "2020"
    class func stringFromOnlyYear(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "YY"
        return formatter.string(from: date)
    }

    // String型のMonth　--> "09"
    class func stringFromDateOnlyMonth(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM"
        return formatter.string(from: date)
    }

    // String型のDay --> "2"
    class func stringFromDateOnlyDay(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "d", options: 0, locale: Locale(identifier: "jp_JP"))
        return formatter.string(from: date)
    }

    // String型のHour　--> "3"
    class func stringFromDateOnlyHour(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "H", options: 0, locale: Locale(identifier: "jp_JP"))
        return formatter.string(from: date)
    }

    // String型のMinutes --> "03"
    class func stringFromDateOnlyMinutes(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "mm", options: 0, locale: Locale(identifier: "jp_JP"))
        let minutes = formatter.string(from: date)
        if minutes.count == 1 {
            return "0" + minutes
        } else {
            return minutes
        }
    }

    class func HourFromTotalMunutes(date: Date) -> Int {
        let minutes = Int(date.timeIntervalSince1970) % (24 * 60 * 60) / 60
        return minutes / 60
    }
}
