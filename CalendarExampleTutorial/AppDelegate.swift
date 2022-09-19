//
//  AppDelegate.swift
//  CalendarExampleTutorial
//
//  Created by CallumHill on 14/1/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		return true
	}

	// MARK: UISceneSession Lifecycle

	func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
		// Called when a new scene session is being created.
		// Use this method to select a configuration to create the new scene with.
		return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
	}

	func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
		// Called when the user discards a scene session.
		// If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
		// Use this method to release any resources that were specific to the discarded scenes, as they will not return.
	}


}

public extension Date {
    
    private static let formatter = DateFormatter()

    static func string(from date: Date, formatter: DateFormatter = mediumStyleFormatter()) -> String {
        return formatter.string(from: date)
    }
    
    static func date(from string: String, formatter: DateFormatter = mediumStyleFormatter()) -> Date? {
        return formatter.date(from: string)
    }
    
    static func string(from stringTimestamp: String, offset: Int, formatter: DateFormatter = timePreviewStyleFormatter()) -> String {
        
        let timestamp = (stringTimestamp == "now") ?
        "\(Date().timeIntervalSince1970)" : stringTimestamp
        guard let backendDate = date(from: timestamp) else { return "" }
        
        let formattedDate = backendDate.date(in: offset)
        return formatter.string(from: formattedDate)
    }
    
    func string(offset: Int, formatter: DateFormatter = timePreviewStyleFormatter()) -> String {
        let formattedDate = self.date(in: offset)
        return formatter.string(from: formattedDate)
    }
    
    static func mediumStyleFormatter() -> DateFormatter {
        formatter.timeZone = TimeZone.init(secondsFromGMT: 0)
        formatter.dateFormat = "yyyyMMddHHmmss.SSS"
        
        return formatter
    }
    
    static func roundedMediumStyleFormatter() -> DateFormatter {
        formatter.timeZone = TimeZone.init(secondsFromGMT: 0)
        formatter.dateFormat = "yyyyMMddHHmmss.000"
        
        return formatter
    }
    
    static func shortStyleFormatter() -> DateFormatter {
        formatter.timeZone = TimeZone.init(secondsFromGMT: 0)
        formatter.dateFormat = "MM/dd, HH:mm"
        
        return formatter
    }
    
    static func timePreviewStyleFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.init(secondsFromGMT: 0)
        formatter.dateFormat = "HH:mm:ss"
        
        return formatter
    }
    
    static func timePreviewAMPMStyleFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.init(secondsFromGMT: 0)
        formatter.dateFormat = "hh:mm:ss a"
        
        return formatter
    }
    
    static func timePreviewWithMilliSecondStyleFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.init(secondsFromGMT: 0)
        formatter.dateFormat = "HH:mm:ss.SSS"
        
        return formatter
    }
    
    static func timePreviewAMPMWithMilliSecondStyleFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.init(secondsFromGMT: 0)
        formatter.dateFormat = "hh:mm:ss.SSS a"
        
        return formatter
    }
    
    static func normalStyleFormatter() -> DateFormatter {
        formatter.timeZone = TimeZone.init(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return formatter
    }
    
    static func normalRoudedlStyleFormatter() -> DateFormatter {
        formatter.timeZone = TimeZone.init(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        
        return formatter
    }
    
    static func normalStyleFormatter(_ timeFormate: String) -> DateFormatter {
        formatter.timeZone = TimeZone.init(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd \(timeFormate)"
        
        return formatter
    }
    
    static func normalStyleDoubleSpaceFormatter() -> DateFormatter {
        formatter.timeZone = TimeZone.init(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd  HH:mm:ss"
        
        return formatter
    }
    
    static func normalStyleDoubleSpaceFormatter(_ timeFormate: String) -> DateFormatter {
        formatter.timeZone = TimeZone.init(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd  \(timeFormate)"
        
        return formatter
    }
    
    static func metricsGraphStyleFormatter() -> DateFormatter {
        formatter.timeZone = TimeZone.init(secondsFromGMT: TimeZone.current.secondsFromGMT())
        formatter.dateFormat = "MM/dd\nHH:mm"
        
        return formatter
    }
    
    func getRoundingTimeInterval() -> (roundedDateTime: TimeInterval,
                                       milliseconds: TimeInterval,
                                       minutes: TimeInterval,
                                       hours: TimeInterval) {
        var calendar = Calendar.current
        calendar.timeZone = .init(secondsFromGMT: 0)!
        
        let milliseconds = timeIntervalSince1970.truncatingRemainder(dividingBy: 1)
        let seconds = Double(calendar.component(.second, from: self))
        let minutes = Double(calendar.component(.minute, from: self)) * 60
        let hours = Double(calendar.component(.hour, from: self)) * 3600
        
        return (self.timeIntervalSince1970 - seconds - milliseconds, seconds + milliseconds, minutes, hours)
    }
    
    func hoursAndMinutesString() -> String {
        return Date.shortTimeFormatter().string(from: self)
    }
    
    func getHourAndMinute() -> (hour: Int, minute: Int) {
        var calendar = Calendar.current
        calendar.timeZone = .init(secondsFromGMT: 0)!

        let hour = calendar.component(.hour, from: self)
        let minute = calendar.component(.minute, from: self)
        
        return (hour: hour, minute: minute)
    }
    
    func getHourMinuteAndSecond() -> (hour: Int, minute: Int, second: Int) {
        var calendar = Calendar.current
        calendar.timeZone = .init(secondsFromGMT: 0)!

        let hour = calendar.component(.hour, from: self)
        let minute = calendar.component(.minute, from: self)
        let second = calendar.component(.second, from: self)
        
        return (hour: hour, minute: minute, second: second)
    }
    
    func getHourAndMinuteString() -> String {
        var calendar = Calendar.current
        calendar.timeZone = .init(secondsFromGMT: 0)!

        let hour = calendar.component(.hour, from: self)
        let minute = calendar.component(.minute, from: self)
        
        return "\(String(format: "%02d", hour))\(String(format: "%02d", minute))"
    }
    
    static func shortTimeFormatter() -> DateFormatter {
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone.init(secondsFromGMT: 0)
        return formatter
    }
    
    static func shortDateFormatter() -> DateFormatter {
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.init(secondsFromGMT: 0)
        return formatter
    }
    
    func date(in timezoneOffset: Int) -> Date {
        // 1) Get the current date (GMT) in seconds since 1970. Epoch datetime.
        let epochDate = self.timeIntervalSince1970
        
        // 2) Perform a calculation with timezoneOffset + epochDate to get the total seconds for the
        //    local date since 1970.
        let timezoneEpochOffset = (epochDate + Double(timezoneOffset))

        // 3) Finally, create a date using the seconds offset since 1970 for the local date.
        return Date(timeIntervalSince1970: timezoneEpochOffset)
    }
    
    static func date(from hour: Int?, minute: Int?) -> Date {
        var calendar = Calendar.current
        calendar.timeZone = .init(secondsFromGMT: 0)!
        return calendar.date(bySettingHour: hour ?? 8, minute: minute ?? 0, second: 0, of: .init()) ?? .init()
    }
    
    static func analyticsStartTime(for date: Date) -> Date? {
        var components = Calendar.current.dateComponents([.hour, .day, .month, .year], from: date)
        if let hour = components.hour,
              hour < 2 {
            let previousDay = date.addingTimeInterval(-60*60*12)
            components = Calendar.current.dateComponents([.hour, .day, .month, .year], from: previousDay)
        }
        components.hour = 2
        return Calendar.current.date(from: components)
    }
    
    static func getDates(from date:Date, toDate: Date) -> [Date] {
        var dates: [Date] = []
        var date = date
        
        while date <= toDate {
            dates.append(date)
            guard let newDate = Calendar.current.date(byAdding: .day, value: 1, to: date) else { break }
            date = newDate
        }
        return dates
    }
    
    static func calculateDuration(_ start: Date, end: Date) -> String {
        let diffComponents = Calendar.current.dateComponents([.hour,.minute, .second],
                                                             from: start,
                                                             to: end)
        let hours = String(format: "%02d", diffComponents.hour ?? 0)
        let minutes = String(format: "%02d", diffComponents.minute ?? 0)
        let seconds = String(format: "%02d", diffComponents.second ?? 0)
        
        return (diffComponents.hour ?? 0) > 0 ? "\(hours):\(minutes):\(seconds)" : "\(minutes):\(seconds)"
    }
}

public extension Int {
    var seconds: Double {
        return Double(self * 24 * 60 * 60)
    }
}

public extension TimeInterval {
    func date(in timezoneOffset: Int) -> Date {
        
        // 1) Get the current date (GMT) in seconds since 1970. Epoch datetime.
        let epochDate = self
        
        // 2) Perform a calculation with timezoneOffset + epochDate to get the total seconds for the
        //    local date since 1970.
        let timezoneEpochOffset = (epochDate + Double(timezoneOffset))

        // 3) Finally, create a date using the seconds offset since 1970 for the local date.
        return Date(timeIntervalSince1970: timezoneEpochOffset)
    }
}


