//
//  CalenderView.swift
//  CalendarExampleTutorial
//
//  Created by vishal on 9/15/22.
//

import UIKit

fileprivate class WeekHeader: UICollectionReusableView {
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        stackView.addArrangedSubviews(getLabels())
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func getLabels() -> [UILabel] {
        var labels = [UILabel]()
        for day in CalendarHelper().getDays() {
            labels.append(getLabel(day))
        }
        return labels
    }
    
    private func getLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .lightGray
        label.textAlignment = .center
        return label
    }
}

fileprivate struct VMSDate {
    let dateComponents: DateComponents
    let isEnable: Bool
}

public class DatePickerView: UICollectionViewController {
    
    public var selectedMonth: Date
    private var totalDates = [VMSDate]()
    private var availabelRanges: DateInterval
    private var dateSelection: DateSelection
    
    public init(_ selectedMonth: Date, availabelRanges: DateInterval, dateSelection: DateSelection) {
        self.selectedMonth = selectedMonth
        self.availabelRanges = availabelRanges
        self.dateSelection = dateSelection
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        flowLayout.scrollDirection = .vertical
        flowLayout.itemSize = CGSize(width: 1, height: 1)
        
        super.init(collectionViewLayout: flowLayout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(CalendarCell.self, forCellWithReuseIdentifier: "calCell")
        collectionView.register(WeekHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setMonthView()
    }
    
    func setMonthView() {
        totalDates.removeAll()
        
        let nextMonthSelectedDate = CalendarHelper().plusMonth(date: selectedMonth)
        let previousMonthSelectedDate = CalendarHelper().minusMonth(date: selectedMonth)
        
        let previousMonthTotalDays = CalendarHelper().daysInMonth(date: previousMonthSelectedDate)
        let currentMonthTotalDays = CalendarHelper().daysInMonth(date: selectedMonth)
        let startingSpaces = CalendarHelper().weekDay(date: selectedMonth)
        
        let previousMonthAndYear = CalendarHelper().getYearAndMonth(date: previousMonthSelectedDate)
        let currentMonthAndYear = CalendarHelper().getYearAndMonth(date: selectedMonth)
        let nextMonthAndYear = CalendarHelper().getYearAndMonth(date: nextMonthSelectedDate)
        
        var count: Int = 1
        
        while(count <= 42)
        {
            if(count <= startingSpaces) {
                let previousMonthComponents = CalendarHelper().create(day: previousMonthTotalDays - (startingSpaces - count), month: previousMonthAndYear.month, year: previousMonthAndYear.year)
                let vmsDate = VMSDate(dateComponents: previousMonthComponents, isEnable: false)
                totalDates.append(vmsDate)
            } else if count - startingSpaces > currentMonthTotalDays {
                let nextMonthComponents = CalendarHelper().create(day: (count % currentMonthTotalDays) - startingSpaces, month: nextMonthAndYear.month, year: nextMonthAndYear.year)
                let vmsDate = VMSDate(dateComponents: nextMonthComponents, isEnable: false)
                totalDates.append(vmsDate)
            } else {
                let currentMonthComponents = CalendarHelper().create(day: count - startingSpaces, month: currentMonthAndYear.month, year: currentMonthAndYear.year)
                let vmsDate = VMSDate(dateComponents: currentMonthComponents, isEnable: CalendarHelper().isDateInRange(CalendarHelper().getDateFromComponents(currentMonthComponents), availabelRange: availabelRanges, toGranularity: .day))
                totalDates.append(vmsDate)
            }
            count += 1
        }
        dateSelection.changeMonth(date: selectedMonth)
        collectionView.reloadData()
    }

    var nextMonthDate: Date {
        return CalendarHelper().plusMonth(date: selectedMonth)
    }
    
    var previousMonthDate: Date {
        return CalendarHelper().minusMonth(date: selectedMonth)
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { _ in
            self.invalidLayout()
        }
    }
    
    func invalidLayout() {
        collectionView.collectionViewLayout.invalidateLayout()
    }
}

extension DatePickerView: UICollectionViewDelegateFlowLayout {
    
    public override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        totalDates.count
    }
    
    public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calCell", for: indexPath) as! CalendarCell
        let vmsdate = totalDates[indexPath.item]
        
        cell.configCell(vmsdate.dateComponents.day!, isEnabled: vmsdate.isEnable, isSelected: vmsdate.isEnable && dateSelection.selectedDateContains(vmsdate.dateComponents))
        
        return cell
    }
    
    public override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! WeekHeader
            return headerView
        default:
            assert(false, "Unexpected element kind")
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/7, height: collectionView.frame.height/7)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.frame.width, height: collectionView.frame.height/7)
    }
    
    public override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vmsdate = totalDates[indexPath.item]
        if vmsdate.isEnable {
            let monthYear = CalendarHelper().getYearAndMonth(date: selectedMonth)
            let selectedDateComponents = CalendarHelper().create(day: vmsdate.dateComponents.day!, month: monthYear.month, year: monthYear.year)
            
            if let multiSelection = dateSelection as? MultiSelectionDate {
                multiSelection.setSelectedDates(selectedDateComponents)
            }
            
            if let singleSelection = dateSelection as? SingleSelectionDate {
                singleSelection.setSelected(selectedDateComponents)
            }
            
            collectionView.reloadData()
        }
    }
}
