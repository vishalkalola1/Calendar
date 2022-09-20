//
//  TimePickerView.swift
//  CalendarExampleTutorial
//
//  Created by vishal on 9/19/22.
//

import UIKit

struct TimeModel {
    var items: [Int]
}

class DateTimePickerViewModel {
    
    private let minDateTime: Date
    private let maxDateTime: Date
    public var currentDateTime: Date
    public var timeFormate: TimeFormate
    var timeModel: [TimeModel] = []
    
    init(minDateTime: Date,
         maxDateTime: Date,
         currentDateTime: Date,
         timeFormate: TimeFormate) {
        self.minDateTime = minDateTime
        self.maxDateTime = maxDateTime
        self.currentDateTime = currentDateTime
        self.timeFormate = timeFormate
        
        setDatasource()
    }
    
    var defaultHours: [Int] {
        return timeFormate == .hour12 ? [Int](0...11) : [Int](0...23)
    }
    
    func setDatasource(hours: [Int]? = nil, minutes: [Int] = [Int](0...59), seconds: [Int] = [Int](0...59), formate: [Int] = [Int](0...1)) {
        let hours = hours == nil ? defaultHours : hours
        if timeFormate == .hour12 {
            timeModel = [.init(items: hours!), .init(items: minutes), .init(items:seconds), .init(items: formate)]
        } else {
            timeModel = [.init(items: hours!) , .init(items: minutes), .init(items:seconds)]
        }
    }
    
    func getHourMinuteAndSecondTupple(_ date: Date) -> (hour: Int, minute:Int, second: Int)  {
        let currentTime = getHourMinuteAndSecond(date)
        return (hour: currentTime[0], minute:currentTime[1], second: currentTime[2])
    }
    
    func getHourMinuteAndSecond(_ date: Date) -> [Int] {
        let dateTime = normalStyleFormate.string(from: date).components(separatedBy: " ")
        var time = dateTime[1].components(separatedBy: ":").map({ Int($0)! } )
        if timeFormate == .hour12 {
            time.append(dateTime.last == "PM" ? 1 : 0)
        }
        return time
    }

    var currentTimeFormatted: String {
        let currentTimeTuple = getHourMinuteAndSecondTupple(currentDateTime)
        return "\(currentTimeTuple.hour)" + ":" + "\(currentTimeTuple.minute)" + ":" + "\(currentTimeTuple.second)"
    }
    
    var maxDateShortFormate: Date {
        let formatter = Date.shortDateFormatter()
        return formatter.date(from: formatter.string(from: maxDateTime))!
    }
    
    var currentDateShortFormate: Date {
        let formatter = Date.shortDateFormatter()
        return formatter.date(from: formatter.string(from: currentDateTime))!
    }
    
    var normalStyleFormate: DateFormatter {
        let timeFormate: String = timeFormate == .hour12 ? Date.timePreviewAMPMStyleFormatter().dateFormat : Date.timePreviewStyleFormatter().dateFormat
        return Date.normalStyleFormatter(timeFormate)
    }
    
    func setSelectedDate(_ selectedDate: String, time: String? = nil) {
        var selectedDateTime = selectedDate + " "
        if let time = time {
            selectedDateTime += time
        } else {
            selectedDateTime += currentTimeFormatted
        }
        let formatter = Date.normalStyleFormatter()
        self.currentDateTime = formatter.date(from: selectedDateTime)!
    }
    
    func reconfigureDatasource(_ selectedIndex: [Int]) {
        let maxtuple = getHourMinuteAndSecondTupple(maxDateTime)
        if maxDateShortFormate == currentDateShortFormate {
            if maxtuple.hour == selectedIndex[0] {
                if selectedIndex[1] >= maxtuple.minute {
                    setDatasource(hours: [Int](0...maxtuple.hour), minutes: [Int](0...maxtuple.minute), seconds: [Int](0...maxtuple.second))
                } else {
                    setDatasource(hours: [Int](0...maxtuple.hour), minutes: [Int](0...maxtuple.minute))
                }
            } else {
                setDatasource(hours: [Int](0...maxtuple.hour))
            }
        } else {
            setDatasource()
        }
    }
}

public enum TimeFormate: String {
    case hour12
    case hour24
}

public protocol TimePickerViewDelegate: AnyObject {
    func updateTime(date: Date)
}

public class TimePickerView: UIStackView {
    
    private let viewModel: DateTimePickerViewModel
    
    private lazy var timePicker: UIPickerView = {
        let timePicker = UIPickerView()
        timePicker.delegate = self
        timePicker.dataSource = self
        return timePicker
    }()
    
    public weak var delegate: TimePickerViewDelegate?
    
    public init(minDate: Date, maxDate: Date, currentDate: Date, timeFormate: TimeFormate = .hour24) {
        self.viewModel = DateTimePickerViewModel(minDateTime: minDate, maxDateTime: maxDate, currentDateTime: currentDate, timeFormate: timeFormate)
        super.init(frame: .zero)
        configureUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        distribution = .equalSpacing
        addArrangedSubviews([emptyView, timePicker, emptyView])
        
        reloadData()
    }
    
    var emptyView: UIView {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }
    
    func reloadData() {
        movePicker()
        viewModel.reconfigureDatasource(getSelectedPickerIndex())
        timePicker.reloadAllComponents()
    }
    
    func updateCurrentDate(_ selectedDate: Date) {
        viewModel.currentDateTime = selectedDate
        reloadData()
    }
}

extension TimePickerView: UIPickerViewDelegate, UIPickerViewDataSource {
    
    private func movePicker() {
        let currentTime = viewModel.getHourMinuteAndSecond(viewModel.currentDateTime)
        setSelectedPickerIndex(selectedIndexes: currentTime)
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return viewModel.timeModel.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let datasource = viewModel.timeModel[component].items
        return datasource.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {

        let datasource = viewModel.timeModel[component]
        let item = datasource.items[row]
            
        let label = UILabel()
        if viewModel.timeFormate == .hour12 && component == 3 {
            label.text = item == 0 ? "AM" : "PM"
        } else {
            label.text = String(format:"%02d", item)
        }
        label.textColor = .white
        label.textAlignment = .center
        
        return label
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedIndexes = getSelectedPickerIndex()
        viewModel.reconfigureDatasource(selectedIndexes)
        pickerView.reloadAllComponents()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let selectedIndexes = self.getSelectedPickerIndex()
            let currentDate = Date.string(from: self.viewModel.currentDateTime, formatter: Date.shortDateFormatter())
            self.viewModel.setSelectedDate(currentDate, time: "\(selectedIndexes[0]):\(selectedIndexes[1]):\(selectedIndexes[2])")
            self.delegate?.updateTime(date: self.viewModel.currentDateTime)
        }
    }
    
    public func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        pickerView.frame.width / CGFloat(viewModel.timeModel.count)
    }
    
    private func getSelectedPickerIndex() -> [Int] {
        var timeIndex = [Int]()
        for component in 0..<viewModel.timeModel.count {
            let index = timePicker.selectedRow(inComponent: component)
            timeIndex.append(index)
        }
        return timeIndex
    }
    
    private func setSelectedPickerIndex(selectedIndexes: [Int]) {
        for component in 0..<viewModel.timeModel.count {
            self.timePicker.selectRow(selectedIndexes[component], inComponent: component, animated: true)
        }
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
            let fromDate = Calendar.current.date(byAdding: .day, value: -5, to: Date())
            let nowDate = Calendar.current.date(byAdding: .day, value: 0, to: Date())
            return TimePickerView(minDate: fromDate!, maxDate: Date(), currentDate: nowDate!, timeFormate: .hour24)
        }
    }
}
