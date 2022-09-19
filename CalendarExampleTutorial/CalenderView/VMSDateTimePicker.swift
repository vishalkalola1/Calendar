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

public class PageViewCotnroller: UIPageViewController {

    private var selectedDate: Date
    private var calendarDelegate: CalenderViewDelegate
    
    init(_ selectedDate: Date, delegate: CalenderViewDelegate) {
        self.selectedDate = selectedDate
        self.calendarDelegate = delegate
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
        let calenderCollectionController = CalenderCollectionController(date)
        calenderCollectionController.delegate = calendarDelegate
        return calenderCollectionController
    }
    
    private var currentViewController: CalenderCollectionController {
        return viewControllers!.first! as! CalenderCollectionController
    }
    
    public func nextMonth() {
        setViewController(currentViewController.nextMonthDate)
    }
    
    public func previousMonth() {
        setViewController(currentViewController.previousMonthDate, direction: .reverse)
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { _ in
            self.currentViewController.invalidLayout()
        }
    }
}

extension PageViewCotnroller: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        print("current", (viewController as? CalenderCollectionController)?.selectedMonth)
        print("next", (viewController as? CalenderCollectionController)?.nextMonthDate)
        guard let date = (viewController as? CalenderCollectionController)?.nextMonthDate else { return nil }
        return getViewController(date)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        print("current", (viewController as? CalenderCollectionController)?.selectedMonth)
        print("previous", (viewController as? CalenderCollectionController)?.previousMonthDate)
        guard let date = (viewController as? CalenderCollectionController)?.previousMonthDate else { return nil }
        return getViewController(date)
    }
}
