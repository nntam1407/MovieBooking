//
//  NSDateExtension.swift
//  ChatApp
//
//  Created by Ngoc Tam Nguyen on 12/4/14.
//  Copyright (c) 2014 Ngoc Tam Nguyen. All rights reserved.
//

import Foundation

extension Date {
    
    /**
     * Method convert NSDate to string message fo UI
     */
    func toElapsedTimeString() -> String {
        
        if (fabs(self.timeIntervalSinceNow) < 1) {
            return NSLocalizedString("just now", comment: "")
        }
        
        let timeComponents = Calendar.current.dateComponents(Set(arrayLiteral: Calendar.Component.year, Calendar.Component.month, Calendar.Component.weekOfMonth, Calendar.Component.day, Calendar.Component.hour, Calendar.Component.minute, Calendar.Component.second), from: Date(), to: self)
        
        // Year
        let year = timeComponents.year
        
        if (year! > 1) {
            return String(format: NSLocalizedString("%d years later", comment: ""), year!)
        } else if (year! == 1) {
            return NSLocalizedString("a year later", comment: "")
        } else if (year! == -1) {
            return NSLocalizedString("a year ago", comment: "")
        } else if (year! < -1) {
            return String(format: NSLocalizedString("%d years ago", comment: ""), abs(year!))
        }
        
        // Month
        let months = timeComponents.month
        
        if (months! > 1) {
            return String(format: NSLocalizedString("%d months later", comment: ""), months!)
        } else if (months! == 1) {
            return NSLocalizedString("a month later", comment: "")
        } else if (months! == -1) {
            return NSLocalizedString("a month ago", comment: "")
        } else if (months! < -1) {
            return String(format: NSLocalizedString("%d months ago", comment: ""), abs(months!))
        }
        
        // Weeks
        let weeks = timeComponents.weekOfMonth
        
        if (weeks! > 1) {
            return String(format: NSLocalizedString("%d weeks later", comment: ""), weeks!)
        } else if (weeks! == 1) {
            return NSLocalizedString("a week later", comment: "")
        } else if (weeks! == -1) {
            return NSLocalizedString("a week ago", comment: "")
        } else if (weeks! < -1) {
            return String(format: NSLocalizedString("%d weeks ago", comment: ""), abs(weeks!))
        }
        
        // Days
        let day = timeComponents.day
        
        if (day! > 1) {
            return String(format: NSLocalizedString("%d days later", comment: ""), day!)
        } else if (day! == 1) {
            return NSLocalizedString("a day later", comment: "")
        } else if (day! == -1) {
            return NSLocalizedString("a day ago", comment: "")
        } else if (day! < -1) {
            return String(format: NSLocalizedString("%d days ago", comment: ""), abs(day!))
        }
        
        // Hours
        let hours = timeComponents.hour
        
        if (hours! > 1) {
            return String(format: NSLocalizedString("%d hours later", comment: ""), hours!)
        } else if (hours! == 1) {
            return NSLocalizedString("a hour later", comment: "")
        } else if (hours! == -1) {
            return NSLocalizedString("a hour ago", comment: "")
        } else if (hours! < -1) {
            return String(format: NSLocalizedString("%d hours ago", comment: ""), abs(hours!))
        }
        
        // Minutes
        let minutes = timeComponents.minute
        
        if (minutes! > 1) {
            return String(format: NSLocalizedString("%d mins later", comment: ""), minutes!)
        } else if (minutes! == 1) {
            return NSLocalizedString("a min later", comment: "")
        } else if (minutes! == -1) {
            return NSLocalizedString("a min ago", comment: "")
        } else if (minutes! < -1) {
            return String(format: NSLocalizedString("%d mins ago", comment: ""), abs(minutes!))
        }
        
        // seconds
        let seconds = timeComponents.second
        
        if (seconds! >= 1) {
            return String(format: NSLocalizedString("%d seconds later", comment: ""), seconds!)
        } else if (seconds! < 1) {
            return String(format: NSLocalizedString("%d seconds ago", comment: ""), abs(seconds!))
        }
        
        return NSLocalizedString("N/A", comment: "")
    }
    
    func toWeekTimeFormatString() -> String {
        let today = Date()
        
        if (self.timeInSameDay(today)) {
            // Formater for parse time
            let formatter = DateFormatter()
            formatter.locale = Locale.current
            formatter.dateFormat =  "hh:mm a"
            
            return String(format: NSLocalizedString("Today, %@", comment: ""), formatter.string(from: self))
        }
        
        var gregorianCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
        gregorianCalendar.firstWeekday = 1 // Sunday = 1
        
        var components = gregorianCalendar.dateComponents(Set(arrayLiteral: Calendar.Component.weekOfYear), from: today)
        let weekOfYearToday = components.weekOfYear
        
        components = gregorianCalendar.dateComponents(Set(arrayLiteral: Calendar.Component.weekOfYear), from: self)
        let weekOfYearSelf = components.weekOfYear
        
        // Formater for parse time
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = weekOfYearSelf != weekOfYearToday ? "MM/dd/yyyy, hh:mm a" : "EE, hh:mm a"
        
        return formatter.string(from: self)
    }
    
    /**
     * Check this time in same day with other time
     */
    func timeInSameDay(_ otherTime: Date) -> Bool {
        let gregorianCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
        
        var components = gregorianCalendar.dateComponents(Set(arrayLiteral: Calendar.Component.day), from: otherTime)
        let dayOfOtherTime = components.day
        
        components = gregorianCalendar.dateComponents(Set(arrayLiteral: Calendar.Component.day), from: self)
        let dayOfSelf = components.day
        
        return dayOfOtherTime == dayOfSelf
    }
    
    func numberOfDaysUtilDate(_ nextDate: Date) -> Int {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let components = calendar.dateComponents(Set(arrayLiteral: Calendar.Component.day), from: self, to: nextDate)
        
        return components.day!
    }
    
    // MARK:
    // MARK: lass methods
    
    static func dateFromDotNetTimeString(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        var result = dateFormatter.date(from: dateString)
        
        if (result == nil) {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            
            result = dateFormatter.date(from: dateString)
        }
        
        return result
    }
    
    static func fromDateString(dateString: String, format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        return dateFormatter.date(from: dateString)
    }
    
    // MARK:
    // MARK: Methods support to convert to string value
    
    func toDotNetTimeString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

        return dateFormatter.string(from: self)
    }
    
    func toShortDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        return dateFormatter.string(from: self)
    }
    
    static func dateFromShortDateString(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        return dateFormatter.date(from: dateString)
    }
    
    func toString(_ format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: self)
    }
}
