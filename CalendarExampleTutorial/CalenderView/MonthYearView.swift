//
//  ChangeMonthYearView.swift
//  CalendarExampleTutorial
//
//  Created by vishal on 9/15/22.
//

import UIKit

public protocol ChangeMonthYearViewDelegate: AnyObject {
    func nextMonth(_ nextDate: Date)
    func previousMonth(_ previousDate: Date)
    func changeMonth()
}

public class MonthYearView: UIStackView {
    
    private let changeMonthYearButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(changeMonthYearAction(_:)), for: .touchUpInside)
        button.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        button.setTitle("September 2022", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.tintColor = .white
        button.semanticContentAttribute = .forceRightToLeft
        button.contentHorizontalAlignment = .trailing
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 30.0, left: 5.0, bottom: 30.0, right: -10.0);
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return button
    }()
    
    private let nextMonthButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(nextMonth(_:)), for: .touchUpInside)
        button.setImage(UIImage(systemName: "chevron.forward"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private let previousMonthButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(previousMonth(_:)), for: .touchUpInside)
        button.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    public weak var delegate: ChangeMonthYearViewDelegate?
    private let availabelRanges: DateInterval
    private var currentDate: Date
    
    public init(availabelRanges: DateInterval, currentDate: Date) {
        self.availabelRanges = availabelRanges
        self.currentDate = currentDate
        super.init(frame: .zero)
        configureUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        axis = .horizontal
        distribution = .fill
        
        let buttonStack = UIStackView(arrangedSubviews: [previousMonthButton, nextMonthButton])
        buttonStack.distribution = .fillEqually
        
        addArrangedSubviews([changeMonthYearButton, UIView(), buttonStack])
        
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.widthAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    @objc private func changeMonthYearAction(_ sender: UIButton) {
        sender.isSelected.toggle()
        UIView.animate(withDuration: 0.2) {
            sender.imageView?.transform = CGAffineTransform(rotationAngle: sender.isSelected ? .pi/2 : 0)
        }
        delegate?.changeMonth()
    }
    
    func updateMonthYear(_ date: Date) {
        currentDate = date
        let text = CalendarHelper().monthString(date: date) + " " + CalendarHelper().yearString(date: date)
        changeMonthYearButton.setTitle(text, for: .normal)
        disableButton()
    }
    
    private func disableButton() {
        nextMonthButton.isEnabled = !CalendarHelper().compare(availabelRanges.end, to: currentDate, toGranularity: .month)
        previousMonthButton.isEnabled = !CalendarHelper().compare(availabelRanges.start, to: currentDate, toGranularity: .month)
    }
    
    @objc func nextMonth(_ sender: UIButton) {
        sender.isEnabled = false
        let nextMonth = CalendarHelper().plusMonth(date: currentDate)
        delegate?.nextMonth(nextMonth)
    }
    
    @objc func previousMonth(_ sender: UIButton) {
        sender.isEnabled = false
        let previousMonth = CalendarHelper().minusMonth(date: currentDate)
        delegate?.previousMonth(previousMonth)
    }
}



import SwiftUI

struct MonthYearView_Previews: PreviewProvider {
    static var previews: some View {
        ViewPreview {
            let currentDate = Date()
            let start = Calendar.current.date(byAdding: .month, value: -1, to: currentDate)!
            let end = Calendar.current.date(byAdding: .month, value: 1, to: currentDate)!
            return MonthYearView(availabelRanges: .init(start: start, end: end), currentDate: currentDate)
        }
    }
}
