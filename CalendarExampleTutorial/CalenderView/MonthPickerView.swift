//
//  MonthPickerView.swift
//  CalendarExampleTutorial
//
//  Created by vishal on 9/20/22.
//

import UIKit

protocol MonthPickerDelegate: AnyObject {
    func updateMonth(_ date: Date)
}

class MonthCell: UICollectionViewCell
{
    private let dayOfMonth: UILabel = {
        let label = UILabel()
        label.text = "Month"
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    private let stackview: UIStackView = {
        let stackview = UIStackView()
        stackview.distribution = .fill
        stackview.layer.cornerRadius = 4
        stackview.layer.masksToBounds = true
        return stackview
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        stackview.addArrangedSubview(dayOfMonth)
        contentView.addSubview(stackview)
        
        stackview.translatesAutoresizingMaskIntoConstraints = false
        stackview.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        stackview.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        stackview.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        stackview.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configCell(_ month: String, isEnabled: Bool, isSelected: Bool) {
        dayOfMonth.text = month
        stackview.backgroundColor = isSelected ? .systemBlue : .clear
        dayOfMonth.textColor = isEnabled ? .white : .gray
    }
}

class MonthPickerView: UIStackView {
    
    struct VMSMonth {
        let dateComponents: DateComponents
        let isEnable: Bool
    }
    
    private var currentDate: Date
    private var availabelRange: DateInterval
    private var selectedMonth: Date
    
    private var totalMonths = [VMSMonth]()
    private var months = CalendarHelper().getMonths()
    
    public lazy var collectionView: UICollectionView = {
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        flowLayout.scrollDirection = .vertical
        flowLayout.itemSize = CGSize(width: 1, height: 1)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MonthCell.self, forCellWithReuseIdentifier: "monthCell")
        collectionView.backgroundColor = .clear
        
        return collectionView
    }()
    
    public weak var delegate: MonthPickerDelegate?
    
    public init(availabelRange: DateInterval, currentDate: Date) {
        self.currentDate = currentDate
        self.availabelRange = availabelRange
        self.selectedMonth = currentDate
        super.init(frame: .zero)
        configureUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI() {
        distribution = .fill
        addArrangedSubview(collectionView)
        
        setMonthView()
    }
    
    func setMonthView() {
        totalMonths.removeAll()
        
        let year = CalendarHelper().yearString(date: selectedMonth)
        let day = CalendarHelper().dayString(date: selectedMonth)
        for dateComponents in CalendarHelper().getMonthsComponents(Int(day)!, year: Int(year)!) {
            let date = CalendarHelper().getDateFromComponents(dateComponents)
            let vmsMonth = VMSMonth(dateComponents: dateComponents, isEnable: CalendarHelper().isDateInRange(date, availabelRange: availabelRange, toGranularity: .month))
            totalMonths.append(vmsMonth)
        }
        
        collectionView.reloadData()
    }
    
    func updateMonth(_ date: Date) {
        selectedMonth = date
        setMonthView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if self.isHidden == false {
            invalidLayout()
        }
    }
    
    func invalidLayout() {
        collectionView.collectionViewLayout.invalidateLayout()
    }
}

extension MonthPickerView: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        totalMonths.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "monthCell", for: indexPath) as! MonthCell
        let vmsdate = totalMonths[indexPath.item]
        
        cell.configCell(months[vmsdate.dateComponents.month! - 1],
                        isEnabled: vmsdate.isEnable,
                        isSelected: vmsdate.isEnable && selectedDateContains(CalendarHelper().getDateFromComponents(vmsdate.dateComponents)))
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/3, height: collectionView.frame.height/4)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vmsdate = totalMonths[indexPath.item]
        if vmsdate.isEnable {
            let selectedMonth = CalendarHelper().getDateFromComponents(vmsdate.dateComponents)
            self.selectedMonth = selectedMonth
            delegate?.updateMonth(selectedMonth)
            collectionView.reloadData()
        }
    }
    
    private func selectedDateContains(_ date: Date) -> Bool {
        return Calendar.current.compare(selectedMonth, to: date, toGranularity: .month) == .orderedSame
    }
}


import SwiftUI

struct MonthPickerView_Previews: PreviewProvider {
    static var previews: some View {
        ViewPreview {
            let currentDate = Date()
            let start = Calendar.current.date(byAdding: .month, value: -7, to: currentDate)!
            let end = Calendar.current.date(byAdding: .month, value: 3, to: currentDate)!
            return MonthPickerView(availabelRange: .init(start: start, end: end), currentDate: currentDate)
        }
    }
}
