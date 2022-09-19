import UIKit

class ViewController: UIViewController {
    
    private let minDate: Date = Date()
    private let maxDate: Date = Date()
    private let selectedDate: Date = Date()
    
    private lazy var changeMonthView: ChangeMonthYearView = {
        let topView = ChangeMonthYearView()
        topView.delegate = self
        topView.axis = .horizontal
        topView.distribution = .fill
        return topView
    }()
    
    private lazy var timeView: TimeView = {
        let timeView = TimeView(delegate: self)
        return timeView
    }()
    
    private let buttonView = ButtonView(currentDate: Date())
    private lazy var calenderViewController: PageViewCotnroller = {
        return PageViewCotnroller(Date(), delegate: self)
    }()
    
    private let timePickerView: TimePickerView = {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let minDate = calendar.date(byAdding: .day, value: -5, to: Date())!.date(in: 7200)
        let maxDate = calendar.date(byAdding: .day, value: 0, to: Date())!.date(in: 7200)
        let currentDate = calendar.date(byAdding: .day, value: 0, to: Date())!.date(in: 7200)
        let timePickerView = TimePickerView(minDateTime: minDate, maxDateTime: maxDate, currentDateTime: currentDate, timeFormate: .hour12)
        timePickerView.isHidden = true
        return timePickerView
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
        configureUI()
    }
    
    func addChildView() {
        addChild(calenderViewController)
        middleView.addArrangedSubviews([calenderViewController.view, timePickerView])
        calenderViewController.didMove(toParent: self)
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

extension ViewController : CalenderViewDelegate {
    public func changeMonth(monthYear: String) {
        changeMonthView.updateMonthYear(monthYear)
    }
    
    public func selectedDates(dateComponents: [DateComponents]) {
        print(dateComponents)
    }
}

extension ViewController: ChangeMonthYearViewDelegate {
    public func nextMonth() {
        calenderViewController.nextMonth()
    }
    
    public func previousMonth() {
        calenderViewController.previousMonth()
    }
    
    public func changeMonth() {
        print("Change View")
    }
}

extension ViewController: TimeViewDelegate {
    func timeAction() {
        timePickerView.isHidden.toggle()
        calenderViewController.view.isHidden.toggle()
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
