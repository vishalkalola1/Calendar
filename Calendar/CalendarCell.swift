//
//  CalendarCell.swift
//  CalendarExampleTutorial
//
//  Created by CallumHill on 14/1/21.
//

import UIKit

class CalendarCell: UICollectionViewCell
{
    private let dayOfMonth: UILabel = {
        let label = UILabel()
        label.text = "Time"
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    private let stackview: UIStackView = {
        let stackview = UIStackView()
        stackview.distribution = .fill
        stackview.layer.cornerRadius = 18
        stackview.layer.masksToBounds = true
        return stackview
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        stackview.addArrangedSubview(dayOfMonth)
        contentView.addSubview(stackview)
        stackview.translatesAutoresizingMaskIntoConstraints = false
        stackview.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        stackview.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        stackview.widthAnchor.constraint(equalToConstant: 36)
            .isActive = true
        stackview.heightAnchor.constraint(equalToConstant: 36)
            .isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configCell(_ datecomponent: DateComponents, isEnabled: Bool, isSelected: Bool) {
        if checkTodayDate(datecomponent) {
            dayOfMonth.textColor = .blue
        } else {
            dayOfMonth.textColor = isEnabled ? .white : .gray
        }
        dayOfMonth.text = "\(datecomponent.day!)"
        stackview.backgroundColor = isSelected ? .systemBlue : .clear
        
    }
    
    func checkTodayDate(_ dateComponent: DateComponents) -> Bool {
        CalendarHelper().isToday(dateComponent)
    }
}
