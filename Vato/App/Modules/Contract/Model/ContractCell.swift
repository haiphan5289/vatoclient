//
//  ContractCell.swift
//  Vato
//
//  Created by an.nguyen on 8/17/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation
import Eureka
import FwiCoreRX
import FwiCore
import SnapKit

enum FillContractCellType: String, CaseIterable {
    case origin       = "OriginAdd"
    case destination  = "DestinationAdd"
    case turn = "TypeTurn"
    case departure = "DepartureDate"
    case arrive = "ArriveDate"
    case customer = "NumberCustomer"
    case driver = "GenderDriver"
    case car = "LevelCar"
    case seats = "NumberSeats"
    case bill = "ExportBill"
    case ticket = "BuyTicket"
    case name = "FullName"
    case phone = "PhoneNumber"
    case email = "Email"
    
    var tag: Int {
      switch self {
          case .turn: return  1
          case .departure : return  2
          case .arrive : return 3
          case .customer : return 4
          case .driver : return 5
          case .car : return 6
          case .seats : return 7
          case .bill: return 8
          default: return 0
      }
    }
}

final class FillInformationCell: FillInformationInputTextCell {
    override func update(from type: DeliveryDisplayType) {
        lblTitle.text = Text.fullname.localizedText
        textField.placeholder = type.placholderName
    }

    override func update(title: String?, placeHolder: String) {
        lblTitle.text = title
        textField.placeholder = placeHolder
    }
}

//final class DropBoxCell: FillInformationInputTextCell {
//    private (set) lazy var icDropdown = UIImageView(frame: .zero)
//    var source: [String] = []
//    override func visualize() {
//        super.visualize()
//        icDropdown.image = UIImage(named: "ic_dropdown_gray")
//        icDropdown >>> {
//            $0.contentMode = .scaleAspectFit
//            $0.snp.makeConstraints({ (make) in
//                make.size.equalTo(CGSize(width: 24, height: 24))
//            })
//        }
//
//        textField.rightView = icDropdown
//        textField.rightViewMode = .always
//        textField.tintColor = .white
//
//        lblStar?.isHidden = true
//    }
//
//    func update(withSource source: [String]) {
//        self.source = source
//    }
//
//    override func update(title: String?, placeHolder: String) {
//        lblTitle.text = title
//        textField.placeholder = placeHolder
//    }
//}

final class MixDropBoxTextCell: FillInformationInputTextCell {
    private (set) lazy var icDropdown = UIImageView(frame: .zero)
    var source: [String] = []
    private (set) var lblTitle2 = UILabel(frame: .zero)
    let textField2: UITextField = UITextField(frame: .zero)

    override func visualize() {
        super.visualize()
        icDropdown.image = UIImage(named: "ic_dropdown_gray")
        icDropdown >>> {
            $0.contentMode = .scaleAspectFit
            $0.snp.makeConstraints({ (make) in
                make.size.equalTo(CGSize(width: 24, height: 24))
            })
        }
        
//        let stackView = UIStackView.create {
//            $0 >>> contentView >>> {
//                $0.snp.makeConstraints({ (make) in
//                    make.left.bottom.right.equalToSuperview()
//                    make.top.equalTo(lblTitle.snp.bottom).offset(4)
//                })
//            }
//        }
//
//        stackView.axis = .vertical
//        stackView.distribution = .fillProportionally
        
        lblTitle2 >>> contentView >>> {
            $0.font = UIFont.systemFont(ofSize: 13)
            $0.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(contentView.snp.centerX).offset(8)
                make.top.equalTo(16)
            })
        }

        textField2 >>> contentView >>> {
            $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            $0.borderStyle = .roundedRect
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(lblTitle.snp.bottom).offset(4)
                make.left.equalTo(lblTitle2.snp.left)
                make.right.equalTo(-16)
                make.height.equalTo(36)
                make.bottom.equalTo(-4)
            })
        }
        textField >>> contentView >>> {
            $0.borderStyle = .roundedRect
            $0.snp.makeConstraints({ (make) in
                make.right.equalTo(textField2.snp.left).offset(-8)
            })
        }
        
        bgRoundView?.isHidden = true
        
        textField.rightView = icDropdown
        textField.rightViewMode = .always
        textField.tintColor = .white
        lblStar?.isHidden = true
    }
    
    func update(withSource source: [String], title1: String, title2: String) {
        self.source = source
        lblTitle.text = title1
        lblTitle2.text = title2
    }
}

final class FillInformationMultiTextFieldCell: FillInformationInputTextCell {
    private (set) lazy var icon = UIImageView(frame: .zero)
    private (set) lazy var icon2 = UIImageView(frame: .zero)
    private (set) var lblTitle2 = UILabel(frame: .zero)
    let textField2: UITextField = UITextField(frame: .zero)

    override func visualize() {
        super.visualize()
        icon >>> {
            $0.contentMode = .scaleAspectFit
            $0.snp.makeConstraints({ (make) in
                make.size.equalTo(CGSize(width: 24, height: 24))
            })
        }
        
        icon2 >>> {
            $0.contentMode = .scaleAspectFit
            $0.snp.makeConstraints({ (make) in
                make.size.equalTo(CGSize(width: 24, height: 24))
            })
        }

        
        lblTitle2 >>> contentView >>> {
            $0.font = UIFont.systemFont(ofSize: 13)
            $0.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(contentView.snp.centerX).offset(8)
                make.top.equalTo(16)
            })
        }

        textField2 >>> contentView >>> {
            $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            $0.borderStyle = .roundedRect
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(lblTitle.snp.bottom).offset(4)
                make.left.equalTo(lblTitle2.snp.left)
                make.right.equalTo(-16)
                make.height.equalTo(36)
                make.bottom.equalTo(-4)
            })
        }

        textField >>> contentView >>> {
            $0.borderStyle = .roundedRect
            $0.snp.makeConstraints({ (make) in
                make.right.equalTo(textField2.snp.left).offset(-8)
            })
        }
        
        bgRoundView?.isHidden = true
        
        textField.rightView = icon
        textField.rightViewMode = .always
        textField.tintColor = .white
        
        textField2.rightView = icon2
        textField2.rightViewMode = .always
        textField2.tintColor = .white
        
        lblStar?.isHidden = true
    }
    
    func update(with title1: String, title2: String, icon1Name: String, icon2Name: String) {
        lblTitle.text = title1
        lblTitle2.text = title2
        
        icon.image = UIImage(named: icon1Name)
        icon2.image = UIImage(named: icon2Name)
    }
    
    func updateShowField(isShow: Bool) {
        lblTitle2.isHidden = !isShow
        textField2.isHidden = !isShow
    }
}

final class RowMulti<C: MultiTextFieldCell>: Row<C>, RowType {}
final class MultiTextFieldCell: Eureka.Cell<String>, CellType, UITextFieldDelegate {
    let lblTitle1: UILabel
    let textField1: UITextField
    
    let lblTitle2: UILabel
    let textField2: UITextField

    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        lblTitle1 = UILabel(frame: .zero)
        textField1 = UITextField(frame: .zero)
        
        lblTitle2 = UILabel(frame: .zero)
        textField2 = UITextField(frame: .zero)
        
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
                
        lblTitle1 >>> contentView >>> {
            $0.font = UIFont.systemFont(ofSize: 13)
            $0.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(16)
                make.top.equalTo(16)
            })
        }
        
        lblTitle2 >>> contentView >>> {
            $0.font = UIFont.systemFont(ofSize: 13)
            $0.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(contentView.snp.centerX).offset(8)
                make.top.equalTo(16)
            })
        }
        
        let stackView = UIStackView.create {
            $0.axis = .horizontal
            $0.distribution = .fillProportionally
            $0.spacing = 16.0
            $0 >>> contentView >>> {
                $0.snp.makeConstraints({ (make) in
                    make.left.right.bottom.equalToSuperview()
                    make.top.equalTo(lblTitle1.snp.bottom).offset(4)
                })
            }
        }

        textField1.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textField1.borderStyle = .roundedRect
        textField2.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textField2.borderStyle = .roundedRect

        stackView.addArrangedSubview(textField1)
        stackView.addArrangedSubview(textField2)
        
//        textField1 >>> contentView >>> {
//            textField1.font = UIFont.systemFont(ofSize: 16, weight: .regular)
//            textField1.snp.makeConstraints({ (make) in
//                make.top.equalTo(lblTitle.snp.bottom).offset(4)
//                make.left.equalTo(16)
//                make.right.equalTo(-16)
//                make.height.equalTo(36)
//                make.bottom.equalTo(-4)
//            })
//        }
    }
    
    func setupRX() {
        textField1.delegate = self
        textField1.addTarget(self, action: #selector(textChanged(sender:)), for: .valueChanged)
        textField1.addTarget(self, action: #selector(textChanged(sender:)), for: .editingChanged)
        textField1.addTarget(self, action: #selector(textChanged(sender:)), for: .editingDidEnd)
    }
    
    @objc func textChanged(sender: UITextField?) {
        row.value = sender?.text
    }
    
//    @discardableResult override func cellResignFirstResponder() -> Bool {
//        return textField1.resignFirstResponder()
//    }
//
//    @discardableResult func cellBecomeFirstResponder() -> Bool {
//        return textField1.becomeFirstResponder()
//    }
//
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
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
}

final class AddressCell: Eureka.Cell<String>, CellType, UpdateDisplayProtocol {

    private let iconView: UIImageView
    private let lblTitle: UILabel
    private let lblAddress: UILabel
    
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        iconView = UIImageView(frame: .zero)
        lblTitle = UILabel(frame: .zero)
        lblAddress = UILabel(frame: .zero)
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        visualize()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        super.setup()
        height = { 90 }
    }

    private func visualize() {
        selectionStyle = .default
        
        iconView >>> contentView >>> {
            $0.contentMode = .scaleAspectFill
            $0.snp.makeConstraints({ (make) in
                make.left.top.equalTo(16)
                make.size.equalTo(CGSize(width: 16, height: 16))
            })
        }
        
        let arrowView  = UIImageView(image: UIImage(named: "ic_chevron_right"))
        arrowView >>> contentView >>> {
            $0.contentMode = .scaleAspectFill
            $0.snp.makeConstraints({ (make) in
                make.centerY.equalToSuperview()
                make.size.equalTo(CGSize(width: 8, height: 12))
                make.right.equalTo(-8)
            })
        }
        
        lblTitle >>> contentView >>> {
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            $0.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(iconView.snp.top)
                make.bottom.equalTo(iconView.snp.bottom)
                make.left.equalTo(iconView.snp.right).offset(16)
//                make.right.equalTo(arrowView.snp.left).offset(-5).priority(.high)
            })
        }
        
        lblAddress >>> contentView >>> {
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.numberOfLines = 0
            $0.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            $0.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(lblTitle.snp.left)
                make.top.equalTo(lblTitle.snp.bottom).offset(8)
                make.right.equalTo(arrowView.snp.left).offset(-5).priority(.high)
                make.bottom.equalTo(-6).priority(.high)
            })
        }
    }
    
    func setupDisplay(item: String?) {
//        let color = item?.description != nil ? #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1) : #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 0.3775858275)
//        lblAddress.textColor = color
        lblAddress.text = item //?? currentType?.placholderAddress
    }
    
    func update(with title: String, iconName: String) {
        iconView.image = UIImage(named: iconName)
        lblTitle.text = title
    }
    
    func addUI() {
        UIImageView.create {
            $0.image = UIImage(named: "ic_vertical_4dots")
        } >>> contentView >>> {
            $0.contentMode = .scaleAspectFill
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(iconView.snp.bottom).offset(19)
                make.centerX.equalTo(iconView.snp.centerX)
                make.bottom.equalTo(-6)
            })
        }
    }
}

final class FillInformationDateCell: FillInformationInputTextCell {
    private (set) lazy var iconDate = UIImageView(frame: .zero)
    override func visualize() {
        super.visualize()
        iconDate.image = UIImage(named: "ic_calendar")
        iconDate >>> {
            $0.contentMode = .scaleAspectFit
            $0.snp.makeConstraints({ (make) in
                make.size.equalTo(CGSize(width: 24, height: 24))
            })
        }

        textField.rightView = iconDate
        textField.rightViewMode = .always
        textField.tintColor = .white
        textField.borderStyle = .roundedRect
        textField.isEnabled = false
        
        lblStar?.isHidden = true
        bgRoundView?.isHidden = true
    }
    
    override func update(title: String?, placeHolder: String) {
        lblTitle.text = title
        textField.placeholder = placeHolder
    }
}

