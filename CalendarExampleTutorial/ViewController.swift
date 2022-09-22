import UIKit

public protocol DateSelection {
    func changeMonth(date: Date)
    func selectedDateContains(_ dateComponents: DateComponents) -> Bool
}

open class SingleSelectionDate: DateSelection {
    
    weak private var delegate: SingleSelectionDateDelegate?
    private var selectedDate: DateComponents?
    
    public init(delegate: SingleSelectionDateDelegate?) {
        self.delegate = delegate
    }
    
    open func setSelected(_ selectedDate: DateComponents?) {
        self.selectedDate = selectedDate
        delegate?.dateSelection(self, dateComponents: selectedDate)
    }
    
    open func changeMonth(date: Date) {
        delegate?.changeMonth(date: date)
    }
    
    open func selectedDateContains(_ dateComponents: DateComponents) -> Bool {
        return CalendarHelper().compare(CalendarHelper().getDateFromComponents(dateComponents), to: CalendarHelper().getDateFromComponents(selectedDate!), toGranularity: .day)
    }
}

public protocol SingleSelectionDateDelegate: AnyObject {
    
    func dateSelection(_ selection: SingleSelectionDate, dateComponents: DateComponents?)
    func changeMonth(date: Date)
}


open class MultiSelectionDate: DateSelection {

    private var selectedDates: [DateComponents]
    weak private var delegate: MultiSelectionDateDelegate?
    
    /// Creates a new multi-date selection with the specified delegate.
    public init(delegate: MultiSelectionDateDelegate?) {
        self.delegate = delegate
        self.selectedDates = []
    }
    
    open func changeMonth(date: Date) {
        delegate?.changeMonth(date: date)
    }
    
    open func selectedDateContains(_ dateComponents: DateComponents) -> Bool {
        return selectedDates.contains(where: { $0.day == dateComponents.day && $0.month == dateComponents.month && $0.year == dateComponents.year })
    }
    
    open func setSelectedDates(_ dateComponents: DateComponents) {
        if  !selectedDateContains(dateComponents) {
            selectedDates.append(dateComponents)
        } else {
            if let index = selectedDates.firstIndex(of: dateComponents) {
                selectedDates.remove(at: index)
            }
        }
        
        delegate?.multiDateSelection(self, dateComponents: selectedDates)
    }
}

public protocol MultiSelectionDateDelegate: AnyObject {
    func changeMonth(date: Date)
    func multiDateSelection(_ selection: MultiSelectionDate, dateComponents: [DateComponents])
}

class ViewController: UIViewController {
    
    let start = CalendarHelper().getDate(.month, value: -2, date: Date())
    let end = CalendarHelper().getDate(.hour, value: 0, date: Date())
    let currentDate = CalendarHelper().getDate(.hour, value: 0, date: Date())
    
    private lazy var changeMonthView: MonthYearView = {
        let topView = MonthYearView(availabelRanges: .init(start: start, end: end), currentDate: currentDate)
        topView.delegate = self
        topView.axis = .horizontal
        topView.distribution = .fill
        return topView
    }()
    
    private lazy var timeView: TimeView = {
        let timeView = TimeView(delegate: self, currentDate: currentDate)
        return timeView
    }()
    
    private let buttonView = ButtonView()
    
    private lazy var calenderViewController: CalendarPageViewCotnroller = {
        let singleDateSelection = SingleSelectionDate(delegate: self)
        singleDateSelection.setSelected(CalendarHelper().getDateComponent(date: currentDate, components: [.year, .month, .day, .hour, .minute, .second]))
        return CalendarPageViewCotnroller(selectedDate: currentDate, availabelRanges: .init(start: start, end: end), dateSelection: singleDateSelection)
    }()
    
    /// Todo: change
    private lazy var timePickerView: TimePickerView = {
        let timePickerView = TimePickerView(availabelRanges: .init(start: start, end: end), selectedDate: end)
        timePickerView.delegate = self
        timePickerView.isHidden = true
        return timePickerView
    }()
    
    private lazy var monthPicker: MonthPickerView = {
        let picker = MonthPickerView(availabelRange: .init(start: start, end: end), currentDate: currentDate)
        picker.delegate = self
        picker.isHidden = true
        return picker
    }()
    
    private lazy var middleView: UIStackView = {
        let middleView = UIStackView()
        middleView.axis = .vertical
        middleView.distribution = .fill
        return middleView
    }()
    
    private lazy var mainStackView: UIStackView = {
        let mainStackView = UIStackView()
        mainStackView.distribution = .fill
        mainStackView.axis = .vertical
        mainStackView.backgroundColor = .black
        return mainStackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Vishal", end, currentDate)
        configureUI()
    }
    
    func addChildView() {
        addChild(calenderViewController)
        middleView.addArrangedSubviews([calenderViewController.view, timePickerView, monthPicker])
        calenderViewController.didMove(toParent: self)
    }
    
    func removeViewFromParent() {
        calenderViewController.willMove(toParent: nil)
        calenderViewController.view.removeFromSuperview()
        calenderViewController.removeFromParent()
    }
    
    func configureUI() {
        
        addChildView()
        
        checkTraitCollection()
        
        changeMonthView.translatesAutoresizingMaskIntoConstraints = false
        changeMonthView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        view.addSubview(mainStackView)
        
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        mainStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    func arrangeHstackView() {
        mainStackView.removeFullyAllArrangedSubviews()
        
        let vstack = UIStackView(arrangedSubviews: [changeMonthView, timeView])
        vstack.axis = .vertical
        timeView.axis = .vertical
        
        let stackView = UIStackView(arrangedSubviews: [middleView, vstack])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        mainStackView.addArrangedSubviews([stackView, buttonView])
        
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        buttonView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func arrangeVstackView() {
        
        mainStackView.removeFullyAllArrangedSubviews()
        
        let bottomView = UIStackView(arrangedSubviews: [timeView, buttonView])
        bottomView.axis = .vertical
        bottomView.distribution = .fillEqually
        
        timeView.axis = .horizontal
        
        mainStackView.addArrangedSubviews([changeMonthView, middleView, bottomView])
        
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
    
    func checkTraitCollection() {
        if view.traitCollection.verticalSizeClass == .compact  {
            arrangeHstackView()
        } else {
            arrangeVstackView()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        checkTraitCollection()
    }
}

extension ViewController: SingleSelectionDateDelegate {
    func dateSelection(_ selection: SingleSelectionDate, dateComponents: DateComponents?) {
        if let dateComponents = dateComponents {
            let time = timeView.getCurrentTime()
            var date = CalendarHelper().getDateFromComponents(dateComponents)
            date = Calendar.current.date(bySettingHour: time.hour!, minute: time.minute!, second: time.second!, of:  date)!
            date = checkDateInRange(date)
            timePickerView.updateDateTime(date)
            timeView.updateTime(date)
        }
    }
    
    func checkDateInRange(_ date: Date) -> Date {
        if start.compare(date) == .orderedDescending {
            return start
        }
        
        if date.compare(end) == .orderedDescending {
            return end
        }
        
        return date
    }
    
    public func changeMonth(date: Date) {
        changeMonthView.updateMonthYear(date)
        monthPicker.updateMonth(date)
    }
}

extension ViewController: ChangeMonthYearViewDelegate {
    
    public func nextMonth(_ nextDate: Date) {
        calenderViewController.nextMonth()
    }
    
    public func previousMonth(_ previousDate: Date) {
        calenderViewController.previousMonth()
    }
    
    public func changeMonth() {
        monthPicker.isHidden.toggle()
        timePickerView.isHidden = true
        if !monthPicker.isHidden {
            removeViewFromParent()
        } else {
            addChildView()
        }
    }
}

extension ViewController: TimeViewDelegate {
    func timeAction() {
        timePickerView.isHidden.toggle()
        monthPicker.isHidden = true
        if !timePickerView.isHidden {
            removeViewFromParent()
        } else {
            addChildView()
        }
    }
}

extension ViewController: MonthPickerDelegate {
    func updateMonth(_ date: Date) {
        changeMonthView.updateMonthYear(date)
        calenderViewController.updateSelectedMonth(date)
    }
}

extension ViewController: TimePickerViewDelegate {
    func updateTime(date: Date) {
        timeView.updateTime(date)
    }
}







extension UIStackView {
    
    func removeFully(view: UIView) {
        removeArrangedSubview(view)
        view.removeFromSuperview()
    }
    
    func removeFullyAllArrangedSubviews() {
        arrangedSubviews.forEach { (view) in
            removeFully(view: view)
        }
    }
    
}


import UIKit
import SwiftUI

struct ViewControllerPreview: UIViewControllerRepresentable {
    
    let viewControllerBuilder: () -> UIViewController

    init(_ viewControllerBuilder: @escaping () -> UIViewController) {
        self.viewControllerBuilder = viewControllerBuilder
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        return viewControllerBuilder()
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        // Not needed
    }
}

struct PreviewViewController_Previews: PreviewProvider {
    static var previews: some View {
        ViewControllerPreview {
            ViewController()
        }
    }
}
