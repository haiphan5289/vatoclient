//  File name   : MasterPincodeCell.swift
//
//  Author      : Phuc Tran
//  Created date: 7/27/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import Eureka
import FwiCore

public final class MasterPincodeCell: MasterFieldCell<String>, CellType {
    // MARK: Class's properties

    // MARK: Class's public methods
    public override func setup() {
        super.setup()
        height = { 100.0 }
        borderImageView.isHidden = true

        textField.isHidden = true
        textField.keyboardType = .numberPad
        textField.autocapitalizationType = .none

        pinLabels.forEach {
            $0.font = UIFont.systemFont(ofSize: 20.0, weight: .medium)
            $0.textAlignment = .center
        }

        let spacing: CGFloat = 10.0
        let width = CGFloat(pinLabels.count) * 20.0 + CGFloat(pinLabels.count - 1) * spacing

        let stackView1 = UIStackView(arrangedSubviews: pinLabels)
        stackView1 >>> contentView >>> {
            $0.backgroundColor = .red
            $0.distribution = .fillEqually
            $0.axis = .horizontal
            $0.spacing = spacing
            $0.snp.makeConstraints {
                $0.center.equalToSuperview()
                $0.width.equalTo(width)
                $0.height.equalTo(30.0)
            }
        }
        let stackView2 = UIStackView(arrangedSubviews: lineImageViews)
        stackView2 >>> contentView >>> {
            $0.backgroundColor = .yellow
            $0.distribution = .fillEqually
            $0.axis = .horizontal
            $0.spacing = spacing
            $0.snp.makeConstraints {
                $0.leading.equalTo(stackView1.snp.leading)
                $0.trailing.equalTo(stackView1.snp.trailing)
                $0.top.equalTo(stackView1.snp.bottom)
                $0.height.equalTo(2.0)
            }
        }

        titleLabel.snp.removeConstraints()
        titleLabel >>> contentView >>> {
            $0.numberOfLines = 0
            $0.snp.makeConstraints {
                $0.leading.equalToSuperview()
                $0.trailing.equalToSuperview()
                $0.bottom.equalToSuperview()
            }
        }
    }

    public override func update() {
        super.update()
        titleLabel.text = row.title
        titleLabel.textAlignment = .center
        titleLabel.textColor = EurekaConfig.errorColor
        titleLabel.font = UIFont.systemFont(ofSize: 14.0, weight: .regular)

        // Apply text color for all labels
        if let fieldRow = row as? MasterFieldRowProtocol {
            let color = row.isDisabled ? fieldRow.disabledDetailColor : fieldRow.detailColor
            pinLabels.forEach { $0.textColor = color }
            
//            if textField.isFirstResponder {
                lineImageViews.forEach { $0.backgroundColor = EurekaConfig.primaryColor }
//            } else {
//                lineImageViews.forEach { $0.backgroundColor = EurekaConfig.separatorColor }
//            }
        }

        // Display value according to user's input
        let value = row.value ?? ""
        for (idx, pinLabel) in pinLabels.enumerated() {
            if idx < value.count {
                let index = value.index(value.startIndex, offsetBy: idx)
                let c = value[index]
                
                pinLabel.text = "\(c)"
//                pinLabel.text = "●"
            } else {
                pinLabel.text = ""
//                pinLabel.text = "○"
            }
        }
    }

    @objc public override func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else {
            row.value = nil
            update()
            return
        }
        row.value = text
        update()

        guard let masterRow = row as? MasterPincodeRow else {
            return
        }

        if text.count == pinLabels.count {
            masterRow.onFinished?(true)
//            textField.resignFirstResponder()
//
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
//                masterRow.onFinished?(true)
//            }
        } else {
            masterRow.onFinished?(false)
        }
    }

    // MARK: TextFieldDelegate's members
    public override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        /* Condition validation: maximum input must equal to number of labels */
        let nextText = (textField.text ?? "") + string
        if nextText.count > pinLabels.count {
            return false
        }
        return formViewController()?.textInput(textField, shouldChangeCharactersInRange:range, replacementString:string, cell: self) ?? true
    }

    /// Class's private properties.
    private lazy var pinLabels: [UILabel] = {
        let length = (row as? MasterPincodeRow)?.length ?? 0
        return (0..<length).map { _ in UILabel() }
    }()
    private lazy var lineImageViews: [UIImageView] = {
        let length = (row as? MasterPincodeRow)?.length ?? 0
        return (0..<length).map { _ in UIImageView() }
    }()
}
