import Foundation
import UIKit

class CalendarHelper
{
    private var calendar = Calendar.current
    
    func plusMonth(date: Date) -> Date
    {
        return calendar.date(byAdding: .month, value: 1, to: date)!
    }
    
    func minusMonth(date: Date) -> Date
    {
        return calendar.date(byAdding: .month, value: -1, to: date)!
    }
    
    func monthString(date: Date) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL"
        return dateFormatter.string(from: date)
    }
    
    func monthShortString(date: Date) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLL"
        return dateFormatter.string(from: date)
    }
    
    func yearString(date: Date) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: date)
    }
    
    func dayString(date: Date) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        return dateFormatter.string(from: date)
    }
    
    func daysInMonth(date: Date) -> Int
    {
        let range = calendar.range(of: .day, in: .month, for: date)!
        return range.count
    }
    
    func dayOfMonth(date: Date) -> Int
    {
        let components = calendar.dateComponents([.day], from: date)
        return components.day!
    }
    
    func getDateComponent(date: Date) -> DateComponents {
        let components = calendar.dateComponents([.year, .month], from: date)
        return components
    }
    
    func getYearAndMonth(date: Date) -> (month: Int, year: Int) {
        let components = getDateComponent(date: date)
        return (components.month!, components.year!)
    }
    
    func firstOfMonth(date: Date) -> Date
    {
        let components = getDateComponent(date: date)
        return calendar.date(from: components)!
    }
    
    func create(day: Int, month: Int, year: Int) -> DateComponents {
        var date = DateComponents()
        date.year = year
        date.month = month
        date.day = day
        return date
    }
    
    func weekDay(date: Date) -> Int {
        let components = calendar.dateComponents([.weekday], from: firstOfMonth(date: date))
        let gap = components.weekday! - 2
        return gap < 0 ? 6 : gap
    }
    
    func months(from minDate: Date, maxdate: Date) -> Int {
        return calendar.dateComponents([.month], from: minDate, to: maxdate).month ?? 0
    }
    
    func getDateFromComponents(_ components: DateComponents) -> Date {
        calendar.date(from: components)!
    }
    
    func getDays() -> [String] {
        var weekdaySymbols = calendar.veryShortWeekdaySymbols
        let firstDay = weekdaySymbols.remove(at: weekdaySymbols.startIndex)
        weekdaySymbols.append(firstDay)
        return weekdaySymbols
    }
    
    func getMonthsComponents(_ day: Int, year: Int) -> [DateComponents] {
        return (1...12).map({ create(day: day, month: $0, year: year) })
    }
    
    func getMonths() -> [String] {
        calendar.shortMonthSymbols
    }
    
    func isDateInRange(_ date: Date, availabelRange: DateInterval, toGranularity: Calendar.Component) -> Bool {
        let minbool = calendar.compare(date, to: availabelRange.start, toGranularity: toGranularity) == .orderedDescending
                    || calendar.compare(date, to: availabelRange.start, toGranularity: toGranularity) == .orderedSame
        let maxbool = calendar.compare(date, to: availabelRange.end, toGranularity: toGranularity) == .orderedAscending
                    || calendar.compare(date, to: availabelRange.end, toGranularity: toGranularity) == .orderedSame
        return maxbool && minbool
    }
}
