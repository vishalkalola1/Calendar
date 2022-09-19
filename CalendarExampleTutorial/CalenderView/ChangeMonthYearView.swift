//
//  ChangeMonthYearView.swift
//  CalendarExampleTutorial
//
//  Created by vishal on 9/15/22.
//

import UIKit

public protocol ChangeMonthYearViewDelegate: AnyObject {
    func nextMonth()
    func previousMonth()
    func changeMonth()
}


public class ChangeMonthYearView: UIStackView {
    
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
    
    public init() {
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
        delegate?.changeMonth()
    }
    
    func updateMonthYear(_ text: String) {
        changeMonthYearButton.setTitle(text, for: .normal)
    }
    
    @objc func nextMonth(_ sender: UIButton) {
        delegate?.nextMonth()
    }
    
    @objc func previousMonth(_ sender: UIButton) {
        delegate?.previousMonth()
    }
}
