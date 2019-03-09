//
//  DateFunctions.swift
//  GeoChat
//
//  Created by Avery Pozzobon on 2019-03-07.
//  Copyright © 2019 Avery Pozzobon. All rights reserved.
//

import Foundation
import UIKit

class DateFunctions {
    //convert UTC to Local
    func UTCToLocal(date:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let dt = dateFormatter.date(from: date)
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'"
        
        return dateFormatter.string(from: dt!)
    }
    
    func DateToTime(date:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'"
        
        let dt = dateFormatter.date(from: date)
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "hh:mm a"
        
        return dateFormatter.string(from: dt!)
    }
    
    func getDateFormatted(dateString:String, formatting:String) -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatting
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let dateFromString = dateFormatter.date(from: dateString)
        return dateFromString!
    }
    
    func getDate(dateString:String) -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'"
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let dateFromString = dateFormatter.date(from: dateString)
        return dateFromString!
    }
    
    func displayDate(date:String) -> String {
        var time_of_message = ""
        let date121 = UTCToLocal(date: String((date).split(separator: ".")[0])).split(separator: "T")[0]
        let dateNow = Date()
        let formatNow = DateFormatter()
        formatNow.dateFormat = "yyyy'-'MM'-'dd'"
        let result = formatNow.string(from: dateNow)
        let diff = Calendar.current.dateComponents([.day], from: getDate(dateString: String(date121)), to: getDate(dateString: result))
        if diff.day == 0 {
            time_of_message = DateToTime(date: UTCToLocal(date: String((date).split(separator: ".")[0])))
        } else {
            time_of_message = String(date121)
        }
        return time_of_message
    }
}
