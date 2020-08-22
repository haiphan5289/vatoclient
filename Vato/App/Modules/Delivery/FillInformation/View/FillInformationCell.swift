//  File name   : FillInformationCell.swift
//
//  Author      : Dung Vu
//  Created date: 8/19/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import Eureka
import FwiCoreRX
import FwiCore
import SnapKit

protocol UpdateDisplayProtocol {
    associatedtype Value
    func setupDisplay(item: Value?)
}

typealias SelectCallback = (Int) -> Void
protocol CallbackSelectProtocol {
    func set(callback: SelectCallback?)
}

// MARK: - Address
final class FillInformationAddressCell: Eureka.Cell<String>, CellType, UpdateDisplayProtocol {
    private let iconView: UIImageView
    private let lblTitle: UILabel
    private let lblAddress: UILabel
    private var currentType: DeliveryDisplayType?
    
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        iconView = UIImageView(frame: .zero)
        lblTitle = UILabel(frame: .zero)
        lblAddress = UILabel(frame: .zero)
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        visualize()
    }
    
    override func setup() {
        super.setup()
        height = { 77 }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func visualize() {
        selectionStyle = .none
        textLabel?.isHidden = true
        iconView >>> contentView >>> {
            $0.contentMode = .scaleAspectFill
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(16)
                make.top.equalTo(16)
                make.size.equalTo(CGSize(width: 18, height: 18))
            })
        }
        
        let arrowView  = UIImageView(image: UIImage(named: "ic_chevron_right"))
        arrowView >>> self >>> {
            $0.contentMode = .scaleAspectFill
            $0.snp.makeConstraints({ (make) in
                make.centerY.equalToSuperview()
                make.size.equalTo(CGSize(width: 8, height: 12))
                make.right.equalTo(-16)
            })
        }
        
        lblTitle >>> contentView >>> {
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.numberOfLines = 0
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(iconView.snp.top)
                make.left.equalTo(iconView.snp.right).offset(12)
                make.right.equalTo(arrowView.snp.left).offset(-5).priority(.high)
            })
        }
        
        lblAddress >>> self >>> {
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.numberOfLines = 0
            $0.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            $0.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(lblTitle.snp.left)
                make.top.equalTo(lblTitle.snp.bottom).offset(8)
                make.right.equalTo(lblTitle.snp.right)
                make.bottom.equalTo(-16).priority(.high)
            })
        }
    }
    
    func update(with type: DeliveryDisplayType) {
        currentType = type
        iconView.image = type.icon
        lblTitle.text = type.titleAddress
    }
    
    func setupDisplay(item: String?) {
        let color = item?.description != nil ? #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1) : #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 0.3775858275)
        lblAddress.textColor = color
        lblAddress.text = item ?? currentType?.placholderAddress
    }
}

class FillInformationInputTextCell: Eureka.Cell<String>, CellType, UITextFieldDelegate {
    let lblTitle: UILabel
    let textField: UITextField
    var lblStar: UILabel?
    var bgRoundView: UIView?
    private var lineView: UIView?
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        lblTitle = UILabel(frame: .zero)
        textField = UITextField(frame: .zero)
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        visualize()
        setupRX()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func visualize() {
        selectionStyle = .none
        textLabel?.isHidden = true
        lblTitle >>> contentView >>> {
            $0.font = UIFont.systemFont(ofSize: 13)
            $0.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(16)
                make.top.equalTo(16)
            })
        }
        
        let bgRoundView = UIView(frame: .zero)
        bgRoundView >>> contentView >>> {
            $0.borderView(with: #colorLiteral(red: 0.8666666667, green: 0.8862745098, blue: 0.9098039216, alpha: 1) , width: 1, andRadius: 8)
            $0.snp.makeConstraints({ (make) in
                make.bottom.equalTo(-4)
                make.left.equalToSuperview().offset(5)
                make.right.equalToSuperview().offset(-5)
                make.top.equalTo(lblTitle.snp.bottom).offset(4  )
            })
        }
        
        self.bgRoundView = bgRoundView
        let _lblStar = UILabel(frame: .zero)
        _lblStar >>> contentView >>> {
            $0.textColor = Color.orange
            $0.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            $0.text = "*"
            $0.snp.makeConstraints({ (make) in
                make.centerY.equalTo(lblTitle.snp.centerY)
                make.left.equalTo(lblTitle.snp.right).offset(4)
            })
        }
        self.lblStar = _lblStar
        textField >>> contentView >>> {
            $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(lblTitle.snp.bottom).offset(4)
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.height.equalTo(36)
                make.bottom.equalTo(-4)
            })
        }
    }
    
    func update(from type: DeliveryDisplayType) {}
    
    func update(title: String?, placeHolder: String) {
        lblTitle.text = title
        textField.placeholder = placeHolder
    }
        
    func updateLine(with edges: UIEdgeInsets) {
        lineView >>> {
            $0?.snp.remakeConstraints({ (make) in
                make.height.equalTo(0.5)
                make.left.equalTo(edges.left)
                make.right.equalTo(-edges.right).priority(.low)
                make.bottom.equalTo(-edges.bottom)
            })
        }
    }
    
    func setupRX() {
        textField.delegate = self
        textField.addTarget(self, action: #selector(textChanged(sender:)), for: .valueChanged)
        textField.addTarget(self, action: #selector(textChanged(sender:)), for: .editingChanged)
        textField.addTarget(self, action: #selector(textChanged(sender:)), for: .editingDidEnd)
    }
    
    @objc func textChanged(sender: UITextField?) {
        row.value = sender?.text
    }
    
    @discardableResult override func cellResignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }
    
    @discardableResult func cellBecomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        lineView?.backgroundColor = Color.orange
        bgRoundView?.borderView(with: Color.orange.withAlphaComponent(0.5) , width: 1, andRadius: 8)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        lineView?.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1)
        bgRoundView?.borderView(with: #colorLiteral(red: 0.8666666667, green: 0.8862745098, blue: 0.9098039216, alpha: 1) , width: 1, andRadius: 8)
        formViewController()?.endEditing(of: self)
        formViewController()?.textInputDidEndEditing(textField, cell: self)
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldEndEditing(textField, cell: self) ?? true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldClear(textField, cell: self) ?? true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldReturn(textField, cell: self) ?? true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return formViewController()?.textInput(textField, shouldChangeCharactersInRange: range, replacementString: string, cell: self) ?? true
    }
    
    func setText(_ text: String?) {
        textField.text = text
        textField.sendActions(for: .valueChanged)
    }
    
    func allowInput(isAllowed: Bool) {
        self.textField.isEnabled = isAllowed
    }
}
class FillInformationInputTimeCell: FillInformationInputTextCell {
    let lblTitleTime: UILabel
    let lblTime: UILabel
    let iconTime: UIImageView
    let lblSchedule: UILabel
    
    private var lineView: UIView?
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        lblTitleTime = UILabel(frame: .zero)
        lblTitleTime.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lblTitleTime.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
        
        lblTime = UILabel(frame: .zero)
        lblTime.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        lblTime.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
        
        iconTime = UIImageView(frame: .zero)
        iconTime.image = UIImage(named: "ic_food_clock")
        
        lblSchedule = UILabel(frame: .zero)
        lblSchedule.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        lblSchedule.textColor = #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1)
        
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        visualize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func visualize() {
        selectionStyle = .none
        textLabel?.isHidden = true
        
        lblTitleTime >>> contentView >>> {
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(16)
                make.top.equalTo(16)
            })
        }
        
        lblTime >>> contentView >>> {
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(16)
                make.top.equalTo(lblTitleTime.snp.bottom).offset(4)
                make.bottom.equalTo(-16)
            })
        }
        
        iconTime >>> contentView >>> {
            $0.snp.makeConstraints({ (make) in
                make.right.equalTo(-16)
                make.height.width.equalTo(24)
                make.centerY.equalToSuperview()
            })
        }
        
        lblSchedule >>> contentView >>> {
            $0.snp.makeConstraints({ (make) in
                make.right.equalTo(iconTime.snp.left).offset(-2)
                make.left.equalTo(lblTime.snp.right)
                make.centerY.equalToSuperview()
            })
        }
        
        lineView?.isHidden = true
    }
}

final class FillInformationPhoneCell: FillInformationInputTextCell {
    private (set) lazy var btnContact = UIButton(frame: .zero)
    override func visualize() {
        super.visualize()
        btnContact = UIButton(frame: .zero)
        btnContact.setImage(UIImage(named: "ic_contact"), for: .normal)
        btnContact >>> {
            $0.snp.makeConstraints({ (make) in
                make.size.equalTo(CGSize(width: 24, height: 24))
            })
        }
        
        textField.rightView = btnContact
        textField.rightViewMode = .always
    }
    
    override func update(from type: DeliveryDisplayType) {
        lblTitle.text = Text.phoneNumber.localizedText
        textField.placeholder = type.placholderPhone
        textField.keyboardType = .phonePad
    }
    
    override func update(title: String?, placeHolder: String) {
        lblTitle.text = title
        textField.placeholder = placeHolder
        textField.keyboardType = .phonePad
    }
}

final class FillInformationDropBoxCell: FillInformationInputTextCell {
    private (set) lazy var iconDropdow = UIImageView(frame: .zero)
    override func visualize() {
        super.visualize()
        iconDropdow.image = UIImage(named: "ic_dropdown_gray")
        iconDropdow >>> {
            $0.contentMode = .scaleAspectFit
            $0.snp.makeConstraints({ (make) in
                make.size.equalTo(CGSize(width: 24, height: 24))
            })
        }

        textField.rightView = iconDropdow
        textField.rightViewMode = .always
        textField.tintColor = .white
    }
    
    override func update(title: String?, placeHolder: String) {
        lblTitle.text = title
        textField.placeholder = placeHolder
    }
}

final class FillInformationNameCell: FillInformationInputTextCell {
    override func update(from type: DeliveryDisplayType) {
        lblTitle.text = Text.fullname.localizedText
        textField.placeholder = type.placholderName
    }
    
    override func update(title: String?, placeHolder: String) {
        lblTitle.text = title
        textField.placeholder = placeHolder
    }
}

final class FillInformationEmailCell: FillInformationInputTextCell {
    override func update(from type: DeliveryDisplayType) {
        lblTitle.text = Text.fullname.localizedText
        textField.placeholder = type.placholderName
    }
    
    override func update(title: String?, placeHolder: String) {
        lblTitle.text = title
        textField.placeholder = placeHolder
    }
}

final class FillInformationPriceCell: FillInformationInputTextCell {
    override func visualize() {
        super.visualize()
        self.textField.keyboardType = .numberPad
    }
}

final class RowInputDelivery<C: FillInformationInputTextCell>: Row<C>, RowType {}
final class InputDeliveryChooseReceiver: Eureka.Cell<Bool>, CellType, UpdateDisplayProtocol {
    let checkImageView: UIImageView
    var lblTitle: UILabel?
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        checkImageView = UIImageView(frame: .zero)
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        visualize()
    }
    
    override func setup() {
        super.setup()
        height = { 60 }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func visualize() {
        textLabel?.isHidden = true
        selectionStyle = .none
        checkImageView >>> contentView >>> {
            $0.image = UIImage(named: "ic_uncheckedbox")
            $0.highlightedImage = UIImage(named: "ic_checkedbox")
            $0.snp.makeConstraints({ (make) in
                make.size.equalTo(CGSize(width: 20, height: 20))
                make.left.equalTo(16)
                make.centerY.equalToSuperview()
            })
        }
        
        let _lblTitle = UILabel(frame: .zero)
        _lblTitle >>> contentView >>> {
            $0.text = Text.deliveryReceiverIsMe.localizedText
            $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            $0.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.snp.makeConstraints({ (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(checkImageView.snp.right).offset(16)
                make.right.equalTo(-16)
            })
        }
        lblTitle = _lblTitle
    }
    
    func setupDisplay(item: Bool?) {
        checkImageView.isHighlighted = item ?? false
    }
}

// MARK: - Error
final class InputDeliveryErrorCell: Eureka.Cell<String>, CellType, UpdateDisplayProtocol {
    let lblError: UILabel
    required init(style _: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        lblError = UILabel(frame: .zero)
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        visualize()
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func visualize() {
        textLabel?.isHidden = true
        selectionStyle = .none
        lblError >>> contentView >>> {
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            $0.textColor = Color.orange
            $0.numberOfLines = 0
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.snp.makeConstraints { make in
                make.left.equalTo(16)
                make.top.equalTo(2)
                make.right.equalToSuperview()
                make.bottom.equalTo(-3).priority(.high)
            }
        }
    }
    
    func setupDisplay(item: String?) {
        lblError.text = item
    }
}

final class InputDeliveryErrorRow: Row<InputDeliveryErrorCell>, RowType {
    override var value: String? {
        didSet {
            cell.lblError.text = value
        }
    }
}


