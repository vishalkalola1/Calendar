//
//  ButtonView.swift
//  CalendarExampleTutorial
//
//  Created by vishal on 9/15/22.
//

import UIKit

public class ButtonView: UIView {
    
    private let currentDate: Date
    
    private let applyButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(applyAction(_:)), for: .touchUpInside)
        button.setTitle("Apply", for: .normal)
        return button
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(cancelAction(_:)), for: .touchUpInside)
        button.setTitle("Cancel", for: .normal)
        return button
    }()
    
    let hLine: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    let vLine: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    public init(currentDate: Date) {
        self.currentDate = currentDate
        super.init(frame: .zero)
        configureUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        let stackView = UIStackView(arrangedSubviews: [cancelButton, applyButton])
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        
        addSubview(stackView)
        addSubview(hLine)
        addSubview(vLine)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        hLine.translatesAutoresizingMaskIntoConstraints = false
        hLine.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        hLine.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        hLine.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        hLine.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        vLine.translatesAutoresizingMaskIntoConstraints = false
        vLine.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        vLine.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        vLine.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        vLine.widthAnchor.constraint(equalToConstant: 0.5).isActive = true
    }
    
    @objc private func applyAction(_ sender: UIButton) {
        print("Apply Click")
    }
    
    @objc private func cancelAction(_ sender: UIButton) {
        print("Cancel Click")
    }
}
