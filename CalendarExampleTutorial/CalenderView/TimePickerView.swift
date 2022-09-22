//
//  TimePickerView.swift
//  CalendarExampleTutorial
//
//  Created by vishal on 9/19/22.
//

import UIKit

public protocol TimePickerViewDelegate: AnyObject {
    func updateTime(date: Date)
}

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

public class TimePickerView: UIStackView {

    public enum TimeFormat: String {
        case h12
        case h24
        
        var hours: [Int] {
            switch self {
            case .h12:
                return Array(1...12)
            case .h24:
                return Array(0...23)
            }
        }
        
        var components: [TimeComponent] {
            switch self {
            case .h12:
                return [.hour, .minute, .second, .format]
            case .h24:
                return [.hour, .minute, .second]
            }
        }
    }
    
    public enum HourFormat: String, CaseIterable {
        case am = "AM"
        case pm = "PM"
    }
    
    public enum TimeComponent: Int, CaseIterable {
        case hour = 0
        case minute = 1
        case second = 2
        case format = 3
    }
    
    // MARK: - Public properties
    /// The default height in points of each row in the picker view.
    public var rowHeight: CGFloat = 60.0
    
    private var availabelRanges: DateInterval
    private var selectedDate: Date
    
    // MARK: - Private properties
    private var timeFormat: TimeFormat
    private var components: [TimeComponent]
    private var hours: [Int]
    private var minutes: [Int] = Array(0..<60)
    private var seconds: [Int] = Array(0..<60)
    private var hourFormats: [HourFormat] = HourFormat.allCases
    
    private var selectedHour: Int?
    private var selectedMinute: Int?
    private var selectedSecond: Int?
    private var selectedHourFormat: HourFormat?
    public weak var delegate: TimePickerViewDelegate?
    
    private var hourRows: Int = 10_000
    private lazy var hourRowsMiddle: Int = ((hourRows / hours.count) / 2) * hours.count
    private var minuteRows: Int = 10_000
    private lazy var minuteRowsMiddle: Int = ((minuteRows / minutes.count) / 2) * minutes.count
    
    private var secondRows: Int = 10_000
    private lazy var secondRowsMiddle: Int = ((secondRows / seconds.count) / 2) * seconds.count
    // MARK: - Views
    
    public var pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        return pickerView
    }()
    
    private lazy var colonLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = ":"
        return label
    }()
    
    private lazy var colonLabel2: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = ":"
        return label
    }()
    
    
    private lazy var colonLabel3: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = ":"
        return label
    }()
    
    private var leftConstraintAnchor: NSLayoutConstraint?
    private var leftConstraintAnchorcolon2: NSLayoutConstraint?
    private var leftConstraintAnchorcolon3: NSLayoutConstraint?
    
    public init(format: TimeFormat = .h24,
                availabelRanges: DateInterval,
                selectedDate: Date) {
        self.timeFormat = format
        self.availabelRanges = availabelRanges
        self.selectedDate = selectedDate
        self.components = format.components
        self.hours = format.hours
        super.init(frame: .zero)
        setupViews()
        updateDateTime(selectedDate)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateSelectedDate(_ selectedDate: Date) {
        self.selectedDate = selectedDate
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        guard !components.isEmpty else { return }
        let offset = (frame.width / CGFloat(components.count)) - 2
        let offset2 = offset * 2
        
        leftConstraintAnchor?.constant = offset
        leftConstraintAnchor?.isActive = true
        
        leftConstraintAnchorcolon2?.constant = offset2
        leftConstraintAnchorcolon2?.isActive = true
        
        colonLabel3.isHidden = timeFormat == .h24
        if timeFormat == .h12 {
            let offset3 = offset * 3
            leftConstraintAnchorcolon3?.constant = offset3
            leftConstraintAnchorcolon3?.isActive = true
        }
    }
    
    open func setupViews() {
        
        backgroundColor = .black
        
        addArrangedSubview(pickerView)
        
        pickerView.addSubview(colonLabel)
        colonLabel.translatesAutoresizingMaskIntoConstraints = false
        colonLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        leftConstraintAnchor = colonLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 0)
        
        
        pickerView.addSubview(colonLabel2)
        colonLabel2.translatesAutoresizingMaskIntoConstraints = false
        colonLabel2.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        leftConstraintAnchorcolon2 = colonLabel2.leftAnchor.constraint(equalTo: leftAnchor, constant: 0)
        
        
        pickerView.addSubview(colonLabel3)
        colonLabel3.translatesAutoresizingMaskIntoConstraints = false
        colonLabel3.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        leftConstraintAnchorcolon3 = colonLabel3.leftAnchor.constraint(equalTo: leftAnchor, constant: 0)
        
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    
    open func updateDateTime(_ date: Date) {
        updateSelectedDate(date)
        let currentTime = CalendarHelper().getHourMinuteAndSecond(date)
        if var hour = currentTime.hour, components.count > TimeComponent.hour.rawValue {
            if timeFormat == .h12 {
                selectedHourFormat = hour < 12 ? .am : .pm
                /// 0:00 / midnight to 0:59 add 12 hours and AM to the time:
                if hour == 0 {
                    selectedHourFormat = .am
                    hour += 12
                }
                /// From 1:00 to 11:59, simply add AM to the time:
                if hour >= 1 && hour <= 11 {
                    selectedHourFormat = .am
                }
                /// For times between 13:00 to 23:59, subtract 12 hours and add PM to the time:
                if hour >= 13 && hour <= 23 {
                    hour -= 12
                    selectedHourFormat = .pm
                }
            }
            let neededRowIndex = hourRowsMiddle + hour
            self.selectedHour = hour
            switch selectedHourFormat {
            case .am:
                pickerView.selectRow(0, inComponent: TimeComponent.format.rawValue, animated: true)
            case .pm:
                pickerView.selectRow(1, inComponent: TimeComponent.format.rawValue, animated: true)
            default:
                break
            }
            switch timeFormat {
            case .h12 where hours.first == 1:
                pickerView.selectRow(neededRowIndex - 1, inComponent: TimeComponent.hour.rawValue, animated: true)
            case .h24:
                pickerView.selectRow(neededRowIndex, inComponent: TimeComponent.hour.rawValue, animated: true)
            default:
                break
            }
        }
        
        if var minute = currentTime.minute, components.count > TimeComponent.minute.rawValue {
            let neededRowIndex = minuteRowsMiddle + minute
            self.selectedMinute = minute
            pickerView.selectRow(neededRowIndex, inComponent: TimeComponent.minute.rawValue, animated: true)
        }
        
        if var second = currentTime.second, components.count > TimeComponent.second.rawValue {
            let neededRowIndex = secondRowsMiddle + second
            self.selectedSecond = second
            pickerView.selectRow(neededRowIndex, inComponent: TimeComponent.second.rawValue, animated: true)
        }
    }
}

extension TimePickerView: UIPickerViewDelegate, UIPickerViewDataSource {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return components.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch components[component] {
        case .hour:
            return hourRows
        case .minute:
            return minuteRows
        case .second:
            return secondRows
        case .format:
            return hourFormats.count
        }
    }
    
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        switch components[component]  {
        case .hour:
            label.text = String(format: "%02d", hours[row % hours.count])
        case .minute:
            label.text = String(format: "%02d", minutes[row % minutes.count])
        case .second:
            label.text = String(format: "%02d", seconds[row % seconds.count])
        case .format:
            label.text = hourFormats[row].rawValue
        }
        return label
    }
    
    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return rowHeight
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch components[component] {
        case .hour:
            self.selectedHour = hours[safe: row % hours.count]
        case .minute:
            self.selectedMinute = minutes[safe: row % minutes.count]
        case .second:
            self.selectedSecond = seconds[safe: row % seconds.count]
        case .format:
            self.selectedHourFormat = hourFormats[safe: row]
        }
        guard var hour = selectedHour, let minute = selectedMinute, let selectedSecond = selectedSecond else { return }
        var calendar = Calendar.current
        calendar.timeZone = .current
        switch selectedHourFormat {
        case .pm where hour >= 1 && hour <= 11:
            hour += 12
        case .am where hour == 12:
            hour -= 12
        default:
            break
        }
        guard let date = calendar.date(bySettingHour: hour, minute: minute, second: selectedSecond, of:  selectedDate) else {
            return
        }
        
        if let rangeDate = dateInAvailabelRange(date) {
            updateDateTime(rangeDate)
        } else {
            delegate?.updateTime(date: date)
        }
    }
    
    func dateInAvailabelRange(_ date: Date) -> Date? {
        if availabelRanges.start.compare(date) == .orderedDescending {
            return availabelRanges.start
        }
        
        if date.compare(availabelRanges.end) == .orderedDescending {
            return availabelRanges.end
        }
        
        return nil
    }
}

import UIKit
import SwiftUI

struct ViewPreview: UIViewRepresentable {
    
    typealias UIViewType = UIView
    
    let viewBuilder: () -> UIView

    init(_ viewBuilder: @escaping () -> UIView) {
        self.viewBuilder = viewBuilder
    }
    
    
    func makeUIView(context: Context) -> UIView {
        viewBuilder()
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        print("View Updated")
    }
}

struct PreviewView_Previews: PreviewProvider {
    static var previews: some View {
        ViewPreview {
            let fromDate = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
            let nowDate = Calendar.current.date(byAdding: .hour, value: 12, to: Date())!
            return TimePickerView(format: .h12, availabelRanges: .init(start: fromDate, end: nowDate), selectedDate: nowDate)
        }
    }
}
