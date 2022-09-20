//
//  TimeView.swift
//  CalendarExampleTutorial
//
//  Created by vishal on 9/15/22.
//

import UIKit

public protocol TimeViewDelegate: AnyObject {
    func timeAction()
}

public class TimeView: UIStackView {

    private let nowButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(nowAction(_:)), for: .touchUpInside)
        button.setTitle("Now", for: .normal)
        button.backgroundColor = .gray
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 16
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        button.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return button
    }()
    
    let emptyView: UIView = {
        let view = UIView()
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return view
    }()
    
    private lazy var nowButtonStack: UIStackView = {
        
        let stackview = UIStackView(arrangedSubviews: [nowButton, emptyView])
        stackview.distribution = .fill
        stackview.axis = .vertical
        stackview.spacing = 5.0
        stackview.layoutMargins = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        stackview.isLayoutMarginsRelativeArrangement = true
        stackview.layer.cornerRadius = 4
        
        nowButton.translatesAutoresizingMaskIntoConstraints = false
        nowButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        nowButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 60).isActive = true
        
        return stackview
    }()
    
    private let timeButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(timeAction(_:)), for: .touchUpInside)
        button.setTitle("11:00:00 AM", for: .normal)
        button.contentHorizontalAlignment = .leading
        button.setTitleColor(.white, for: .normal)
        button.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return button
    }()
    
    private let imageView = UIImageView()
    
    private lazy var timeStack: UIStackView = {
        
        imageView.image = UIImage(systemName: "chevron.down")
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        
        let stackview = UIStackView(arrangedSubviews: [timeButton, imageView])
        stackview.distribution = .fill
        stackview.alignment = .center
        stackview.spacing = 5.0
        stackview.backgroundColor = .gray
        stackview.layoutMargins = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 8)
        stackview.isLayoutMarginsRelativeArrangement = true
        stackview.layer.cornerRadius = 4
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 12).isActive = true
        
        return stackview
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "Time"
        label.textColor = .white
        label.textAlignment = .center
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return label
    }()
    
    private lazy var timeStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [timeLabel, timeStack])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 12.0
        
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 50).isActive = true
        
        timeStack.translatesAutoresizingMaskIntoConstraints = false
        timeStack.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        return stackView
    }()
    
    public weak var delegate: TimeViewDelegate?
    
    public init(delegate: TimeViewDelegate) {
        self.delegate = delegate
        super.init(frame: .zero)
        configureUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func updateTime(_ date: Date, timeFormate: TimeFormate) {
        let formate = timeFormate == .hour12 ? Date.timePreviewAMPMStyleFormatter() : Date.timePreviewStyleFormatter()
        timeButton.setTitle(formate.string(from: date), for: .normal)
    }
    
    
    private func configureUI() {
        checkTraitCollection()
        
        distribution = .fill
        spacing = 12.0
        layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        isLayoutMarginsRelativeArrangement = true
        
        let timeStack = UIStackView(arrangedSubviews: [timeStackView])
        timeStack.alignment = .center
        
        addArrangedSubviews([timeStack, nowButtonStack])
        
        timeStack.translatesAutoresizingMaskIntoConstraints = false
        timeStack.heightAnchor.constraint(equalToConstant: 32).isActive = true
    }
    
    func checkTraitCollection() {
        if self.traitCollection.verticalSizeClass == .compact  {
            axis = .vertical
            emptyView.isHidden = false
        } else {
            axis = .horizontal
            emptyView.isHidden = true
        }
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        checkTraitCollection()
    }
    
    @objc private func nowAction(_ sender: UIButton) {
        print("Now Click")
    }
    
    func toggleBorder(_ isselected: Bool) {
        timeStack.layer.borderColor = isselected ? UIColor.blue.cgColor : UIColor.clear.cgColor
        timeStack.layer.borderWidth = 1
    }
    
    @objc private func timeAction(_ sender: UIButton) {
        sender.isSelected.toggle()
        toggleBorder(sender.isSelected)
        UIView.animate(withDuration: 0.2) {
            self.imageView.transform = CGAffineTransform(rotationAngle: sender.isSelected ? .pi : 0)
        }
        delegate?.timeAction()
    }
}
