//
//  VMSDateTimePicker.swift
//  CalendarExampleTutorial
//
//  Created by vishal on 9/14/22.
//

import Foundation
import UIKit

extension UIStackView {
    func addArrangedSubviews(_ views: [UIView]) {
        for view in views {
            addArrangedSubview(view)
        }
    }
}

public class CalendarPageViewCotnroller: UIPageViewController {

    private var selectedDate: Date
    private var availabelRanges: DateInterval
    private var dateSelection: DateSelection
    
    init(selectedDate: Date, availabelRanges: DateInterval,  dateSelection: DateSelection) {
        self.availabelRanges = availabelRanges
        self.selectedDate = selectedDate
        self.dateSelection = dateSelection
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    func configureView() {
        delegate = self
        dataSource = self
        setViewController(selectedDate)
    }
    
    private func setViewController(_ date: Date, direction: UIPageViewController.NavigationDirection = .forward) {
        setViewControllers([getViewController(date)], direction: direction, animated: true)
    }
    
    private func getViewController(_ date: Date) -> UIViewController {
        let calenderCollectionController = DatePickerView(date, availabelRanges: availabelRanges, dateSelection: dateSelection)
        return calenderCollectionController
    }
    
    private var currentViewController: DatePickerView {
        return viewControllers!.first! as! DatePickerView
    }
    
    public func updateSelectedMonth(_ month: Date) {
        currentViewController.updateSelectedMonth(month)
    }
    
    public func nextMonth() {
        setViewController(currentViewController.nextMonthDate)
    }
    
    public func previousMonth() {
        setViewController(currentViewController.previousMonthDate, direction: .reverse)
    }
    
    private func isEnabled(_ date: Date) -> Bool {
        CalendarHelper().isDateInRange(date, availabelRange: availabelRanges, toGranularity: .month)
    }
}

extension CalendarPageViewCotnroller: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let date = (viewController as? DatePickerView)?.nextMonthDate, isEnabled(date) else { return nil }
        return getViewController(date)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let date = (viewController as? DatePickerView)?.previousMonthDate, isEnabled(date) else { return nil }
        return getViewController(date)
    }
}
