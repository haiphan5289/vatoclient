//  File name   : MasterFieldCell.swift
//
//  Author      : Phuc Tran
//  Created date: 7/7/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import Eureka
import SnapKit
import RxSwift
import RxCocoa

public protocol MasterFieldCellProtocol {
    var titleLabel: UILabel { get }
    var borderImageView: UIImageView { get }
}

open class MasterFieldCell<T>: Cell<T>, UITextFieldDelegate, TextFieldCell, MasterFieldCellProtocol where T: Equatable, T: InputTypeInitiable {
    /// Class's public properties
    public var textField: UITextField! {
        return textField_
    }

    public var titleLabel: UILabel {
        return titleLabel_
    }

    public private(set) lazy var borderImageView = UIImageView()

    /// Class's constructors.
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    public required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        self.textLabel?.isHidden = true
        self.detailTextLabel?.isHidden = true
    }
    
    /// Class's destructor.
    deinit {
        textField_.delegate = nil
        textField_.removeTarget(nil, action: nil, for: .allEvents)
    }
    
    // MARK: Class's public methods
    open override func setup() {
        super.setup()
        // General setup
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: nil, queue: .main) { [weak self](notify) in
            guard let textF = notify.object as? UITextField else { return }
            guard let wSelf = self, textF === wSelf.textField_ else { return }
            wSelf.textFieldDidChange(textF)
        }
        
        height = EurekaConfig.defaultHeight
        backgroundColor = .clear
        selectionStyle = .none
        borderImageView >>> contentView >>> { $0.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(EurekaConfig.paddingLeft)
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(2.0)
        }}

        textField_ >>> contentView >>> {
            $0.clearButtonMode = .whileEditing
            $0.autocapitalizationType = .none
            $0.autocorrectionType = .default
            $0.spellCheckingType = .no
            $0.keyboardType = .default
            $0.returnKeyType = .default
            $0.snp.updateConstraints {
                $0.leading.equalTo(borderImageView.snp.leading)
                $0.trailing.equalTo(borderImageView.snp.trailing)
                $0.bottom.equalTo(borderImageView.snp.top)
                $0.height.equalTo(40.0)
            }
        }

        titleLabel_ >>> contentView >>> { $0.snp.updateConstraints {
            $0.leading.equalTo(borderImageView.snp.leading)
            $0.trailing.equalTo(borderImageView.snp.trailing)
            $0.top.greaterThanOrEqualToSuperview()
            $0.bottom.equalTo(textField.snp.top)
        }}
    }

    open override func update() {
        super.update()
        
        // Enable highlight effect
        if !row.isValid {
            titleLabel_.textColor = EurekaConfig.errorColor
            borderImageView.backgroundColor = EurekaConfig.errorColor
        } else {
            if textField_.isFirstResponder {
                borderImageView.backgroundColor = EurekaConfig.primaryColor
            } else {
                borderImageView.backgroundColor = EurekaConfig.separatorColor
                titleLabel_.text = row.title

                if let fieldRow = row as? MasterFieldRowProtocol {
                    titleLabel_.font = fieldRow.titleFont
                    titleLabel_.textColor = row.isDisabled ? fieldRow.disabledTitleColor : fieldRow.titleColor
                }
            }
        }
        
        // Format for placeholder text
        textField.delegate = self
        textField.isEnabled = !row.isDisabled
        textField.text = row.displayValueFor?(row.value)
        if let fieldRow = row as? MasterFieldRowProtocol {
            textField.font = fieldRow.detailFont
            textField.textColor = row.isDisabled ? EurekaConfig.disabledDetailColor : fieldRow.detailColor
        }
        
        if let fieldRow = row as? (FieldRowConformance & MasterFieldRowProtocol), let placeholder = fieldRow.placeholder {
            if let color = fieldRow.placeholderColor {
                let attributes: [NSAttributedString.Key:Any] = [
                    .foregroundColor:color,
                    .font:fieldRow.titleFont
                ]
                textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
            } else {
                textField.placeholder = placeholder
            }
        }
    }
    
    open override func cellResignFirstResponder() -> Bool {
        return textField?.resignFirstResponder() ?? true
    }
    
    open override func cellCanBecomeFirstResponder() -> Bool {
        return !row.isDisabled && textField?.canBecomeFirstResponder == true
    }
    
    open override func cellBecomeFirstResponder(withDirection: Direction) -> Bool {
        return textField?.becomeFirstResponder() ?? false
    }

    @objc open func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else {
            row.value = nil
            return
        }
        let next = text.isEmpty ? nil : (T(string: text) ?? row.value)
        guard let fieldRow = row as? FieldRowConformance, let formatter = fieldRow.formatter else {
            row.value = next
            return
        }

        if fieldRow.useFormatterDuringInput {
            var value: AnyObject?
            if formatter.getObjectValue(&value, for: text, errorDescription: nil), let v = value as? T {
                row.value = v

                guard var selStartPos = textField.selectedTextRange?.start else {
                    return
                }
                let oldVal = textField.text

                textField.text = row.displayValueFor?(row.value)
                selStartPos = (formatter as? FormatterProtocol)?.getNewPosition(forPosition: selStartPos, inTextInput: textField, oldValue: oldVal, newValue: textField.text) ?? selStartPos
                textField.selectedTextRange = textField.textRange(from: selStartPos, to: selStartPos)
            }
        } else {
            var value: AnyObject?
            if formatter.getObjectValue(&value, for: text, errorDescription: nil), let v = value as? T {
                row.value = v
            } else {
                row.value = text.isEmpty ? nil : (T(string: text) ?? row.value)
            }
        }
    }

    // MARK: TextFieldDelegate's members
    open func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldBeginEditing(textField, cell: self) ?? true
    }
    open func textFieldDidBeginEditing(_ textField: UITextField) {
        formViewController()?.beginEditing(of: self)
        formViewController()?.textInputDidBeginEditing(textField, cell: self)
        
        if
            let fieldRowConformance = row as? FormatterConformance,
            fieldRowConformance.formatter != nil, fieldRowConformance.useFormatterOnDidBeginEditing ?? fieldRowConformance.useFormatterDuringInput
        {
            textField.text = displayValue(useFormatter: true)
        } else {
            textField.text = displayValue(useFormatter: false)
        }
    }
    
    open func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldEndEditing(textField, cell: self) ?? true
    }
    open func textFieldDidEndEditing(_ textField: UITextField) {
        formViewController()?.endEditing(of: self)
        formViewController()?.textInputDidEndEditing(textField, cell: self)
        
        textFieldDidChange(textField)
        textField.text = displayValue(useFormatter: (row as? FormatterConformance)?.formatter != nil)
    }
    
    open func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldClear(textField, cell: self) ?? true
    }
    open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldReturn(textField, cell: self) ?? true
    }
    open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return formViewController()?.textInput(textField, shouldChangeCharactersInRange:range, replacementString:string, cell: self) ?? true
    }
    
    // MARK: Class's private methods
    private func displayValue(useFormatter: Bool) -> String? {
        guard let v = row.value else {
            return nil
        }
        
        if let formatter = (row as? FormatterConformance)?.formatter, useFormatter {
            return textField?.isFirstResponder == true ? formatter.editingString(for: v) : formatter.string(for: v)
        }
        return String(describing: v)
    }

    /// Class's private properties.
    private lazy var titleLabel_ = UILabel()
    private lazy var textField_ = UITextField()
}

// MARK: Text Cell
public final class MasterAccountFieldCell: MasterFieldCell<String>, CellType {
    public override func setup() {
        super.setup()
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.keyboardType = .asciiCapable
    }
}
public final class MasterEmailFieldCell: MasterFieldCell<String>, CellType {
    public override func setup() {
        super.setup()
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.keyboardType = .emailAddress
    }
}
public final class MasterNameFieldCell: MasterFieldCell<String>, CellType {
    public override func setup() {
        super.setup()
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .words
        textField.keyboardType = .asciiCapable
    }
}
public final class MasterPasswordFieldCell: MasterFieldCell<String>, CellType {
    public override func setup() {
        super.setup()
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.keyboardType = .asciiCapable
        textField.isSecureTextEntry = true
    }
}
public final class MasterPhoneFieldCell: MasterFieldCell<String>, CellType {
    public override func setup() {
        super.setup()
        textField.keyboardType = .phonePad
    }
}
public final class MasterTextFieldCell: MasterFieldCell<String>, CellType {
    public override func setup() {
        super.setup()
        textField.autocapitalizationType = .sentences
    }
}
public final class MasterURLFieldCell: MasterFieldCell<URL>, CellType {
    public override func setup() {
        super.setup()
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.keyboardType = .URL
    }
}
public final class MasterZipCodeFieldCell: MasterFieldCell<String>, CellType {
    public override func update() {
        super.update()
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .allCharacters
        textField.keyboardType = .numbersAndPunctuation
    }
}

public final class MasterIntFieldCell: MasterFieldCell<Int>, CellType {
    public override func setup() {
        super.setup()
        textField.autocapitalizationType = .none
        textField.keyboardType = .numberPad
    }
}
public final class MasterDecimalFieldCell: MasterFieldCell<Double>, CellType {
    public override func setup() {
        super.setup()
        textField.autocorrectionType = .no
        textField.keyboardType = .decimalPad
    }
}
