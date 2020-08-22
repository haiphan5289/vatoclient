//  File name   : TicketUserInfomationVC.swift
//
//  Author      : vato.
//  Created date: 10/9/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import Eureka
import SnapKit
import FwiCore
import FwiCoreRX
import RxSwift
import RxCocoa

protocol TicketUserInfomationPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    
    var ticketUserModel: TicketUser? { get }
    var ticketUserObser: Observable<TicketUser> { get }
    var dateStart: Date { get }
    var originLocation: TicketLocation? { get }
    var destLocation: TicketLocation? { get }
    func ticketUserInfomationMoveBack()
    func resetInfoToCurrent()
    func resetInfo()
    func didTouchNext()
    func openTermOfTicket()
    func updateEmailToApi()
    func nextWithoutUpdateEmail()
    
}

enum TicketUserInfomationCellType: String, CaseIterable {
    case address = "RowInputAddress"
    case name = "NameInput"
    case phone = "PhoneInput"
    case phone2 = "Phone2Input"
    case identifyCard = "identifyCard"
    case email = "EmailInput"
    case chooseReceiver = "ChooseReceiver"
}

final class TicketUserInfomationVC: FormViewController, TicketUserInfomationPresentable, TicketUserInfomationViewControllable {
    func update(type: TicketUserInfomationCellType, value: Any?) {
        let cell = self.form.rowBy(tag: type.rawValue)
        switch type {
        case .phone:
            let phone = cell as? RowInputDelivery<FillInformationPhoneCell>
            phone?.cell.setText(value as? String)
        case .address:
            let address = cell as? RowDetailGeneric<FillInformationAddressCell>
            address?.value = (value as? AddressProtocol)?.name
        case .name:
            let name = cell as? RowInputDelivery<FillInformationNameCell>
            name?.cell.setText(value as? String)
        case .chooseReceiver:
            let choose = cell as? RowDetailGeneric<InputDeliveryChooseReceiver>
            choose?.value = value as? Bool
        case .identifyCard:
            let identifyCard = cell as? RowInputDelivery<FillInformationInputTextCell>
            identifyCard?.cell.setText(value as? String)
        case .email:
            let email = cell as? RowInputDelivery<FillInformationNameCell>
            email?.cell.setText(value as? String)
        case .phone2:
            let phone2 = cell as? RowInputDelivery<FillInformationPhoneCell>
            phone2?.cell.setText(value as? String)
        }
        guard let cell1 = cell else {
            return
        }
        validate(row: cell1)
    }
    
    func showPopupUpdateEmail(email: String) {
        let message = String(format: Text.updateEmailMessage.localizedText, email)
        AlertVC.showAlertObjc(on: self,
                              title: Text.updateEmailAccount.localizedText,
                              message: message,
                              actionOk: Text.updateNow.localizedText,
                              actionCancel: Text.later.localizedText,
                              callbackOK: { [weak self] in
                                self?.listener?.updateEmailToApi()
                                
        }, callbackCancel: {[weak self] in
            self?.listener?.nextWithoutUpdateEmail()
        })
        
    }
    
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: TicketUserInfomationPresentableListener?
    internal lazy var disposeBag = DisposeBag()
    private var btnNext: UIButton?
    private var btnNextInput: UIButton?
    private var viewButtonInput: UIView?
    // MARK: View's lifecycle
    override func loadView() {
        super.loadView()
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        tableView.separatorColor = .clear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        visualize()
        setupRX()
        listener?.resetInfoToCurrent()
        self.setupKeyboardAnimation()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.endEditing(true)
    }
    
    /// Class's private properties.
    override func tableView(_: UITableView, viewForFooterInSection _: Int) -> UIView? {
        return nil
    }
    
    override func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat { return 0.1 }
    
    override func tableView(_: UITableView, heightForFooterInSection s: Int) -> CGFloat {
        switch s {
        case 0:
            return 10
        default:
            return 5
        }
    }
    
    override func tableView(_: UITableView, viewForHeaderInSection _: Int) -> UIView? { return nil }
}

// MARK: View's event handlers
extension TicketUserInfomationVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension TicketUserInfomationVC {
}

// MARK: Class's private methods
private extension TicketUserInfomationVC {
    private func localize() {
        // todo: Localize view's here.
    }
    
    func setupNavigation() {
        let navigationBar = navigationController?.navigationBar
        let bgImage = UIImage(named:"bg_navigationbar")?.stretchableImage(withLeftCapWidth: 0, topCapHeight: 0)
        navigationBar?.setBackgroundImage(bgImage, for: .default)
        navigationBar?.barTintColor = Color.orange
        navigationBar?.isTranslucent = false
        navigationBar?.tintColor = .white
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        let image = UIImage(named: "ic_arrow_back")
        let leftButton = UIButton(frame: CGRect(origin: .zero, size: image?.size ?? .zero))
        leftButton.setImage(image, for: .normal)
        leftButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
        let leftBarButton = UIBarButtonItem(customView: leftButton)
        navigationItem.leftBarButtonItem = leftBarButton
        leftButton.rx.tap.bind(onNext: weakify { wSelf in
            wSelf.listener?.ticketUserInfomationMoveBack()
        }).disposed(by: disposeBag)
    }
    
    private func visualize() {
        title = Text.customerInformation.localizedText
        // todo: Visualize view's here.
        tableView >>> view >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        
        let section1 = Section("") { (s) in
            s.tag = "InputInfor"
        }
        
        // name
        section1 <<< RowInputDelivery<FillInformationNameCell>.init(TicketUserInfomationCellType.name.rawValue, { (row) in
            row.cell.contentView.addSeperator(with: .zero, position: .top)
            row.cell.update(title: Text.fullname.localizedText, placeHolder: Text.inputFullname.localizedText)
            row.add(ruleSet: RulesName.rules());
            row.onChange({ [weak self](row) in
                self?.listener?.ticketUserModel?.name = row.value?.trim() ?? ""
                self?.validate(row: row)
            })
            row.onRowValidationChanged { _, row in
                let rowIndex = row.indexPath!.row
                while row.section!.count > rowIndex + 1, row.section?[rowIndex + 1] is InputDeliveryErrorRow {
                    row.section?.remove(at: rowIndex + 1)
                }
                if !row.isValid {
                    let message = row.validationErrors.first?.msg
                    let labelRow = InputDeliveryErrorRow("") { eRow in
                        eRow.value = message
                    }
                    let indexPath = row.indexPath!.row + 1
                    row.section?.insert(labelRow, at: indexPath)
                }
                self.validate(row: row)
            }
        })
        
        // phone
        section1 <<< RowInputDelivery<FillInformationPhoneCell>.init(TicketUserInfomationCellType.phone.rawValue, { (row) in
            row.cell.update(title: Text.phoneNumber.localizedText, placeHolder: Text.inputPhoneNumber.localizedText)
            row.add(ruleSet: RulesPhoneNumber.rules())
            row.cell.btnContact.isHidden = true
            row.onChange({ [weak self](row) in
                self?.listener?.ticketUserModel?.phone = row.value?.trim() ?? ""
                self?.validate(row: row)
            })
            row.onRowValidationChanged { _, row in
                let rowIndex = row.indexPath!.row
                while row.section!.count > rowIndex + 1, row.section?[rowIndex + 1] is InputDeliveryErrorRow {
                    row.section?.remove(at: rowIndex + 1)
                }
                if !row.isValid {
                    let message = row.validationErrors.first?.msg
                    let labelRow = InputDeliveryErrorRow("") { eRow in
                        eRow.value = message
                    }
                    let indexPath = row.indexPath!.row + 1
                    row.section?.insert(labelRow, at: indexPath)
                }
                self.validate(row: row)
            }
        })

        // email
        section1 <<< RowInputDelivery<FillInformationNameCell>.init(TicketUserInfomationCellType.email.rawValue, { (row) in
            row.cell.update(title: Text.email.localizedText, placeHolder: Text.inputEmailAdress.localizedText)
            row.add(ruleSet: RulesEmail.rules())
            row.onChange({ [weak self](row) in
                self?.listener?.ticketUserModel?.email = row.value?.trim() ?? ""
                self?.validate(row: row)
            })
            row.onRowValidationChanged { _, row in
                let rowIndex = row.indexPath!.row
                while row.section!.count > rowIndex + 1, row.section?[rowIndex + 1] is InputDeliveryErrorRow {
                    row.section?.remove(at: rowIndex + 1)
                }
                if !row.isValid {
                    let message = row.validationErrors.first?.msg
                    let labelRow = InputDeliveryErrorRow("") { eRow in
                        eRow.value = message
                    }
                    let indexPath = row.indexPath!.row + 1
                    row.section?.insert(labelRow, at: indexPath)
                }
                self.validate(row: row)
            }
        })

        var isVerifyIdentifier = false
        if let dateStart = listener?.dateStart,
            let destLocation = listener?.destLocation {
            isVerifyIdentifier = BuslineConfigDataManager.shared.isValidateIdentifierId(date: dateStart, destLocation: destLocation)
        }
        if isVerifyIdentifier {
            // identify card
            section1 <<< RowInputDelivery<FillInformationInputTextCell>.init(TicketUserInfomationCellType.identifyCard.rawValue, { (row) in
                row.cell.update(title: Text.identityCard.localizedText, placeHolder: Text.inputIdentityCard.localizedText)
                row.add(ruleSet: RulesIdentifyCard.rules())
                
                row.onChange({ [weak self](row) in
                    self?.listener?.ticketUserModel?.identifyCard = row.value?.trim() ?? ""
                    self?.validate(row: row)
                })
                row.onRowValidationChanged { _, row in
                    let rowIndex = row.indexPath!.row
                    while row.section!.count > rowIndex + 1, row.section?[rowIndex + 1] is InputDeliveryErrorRow {
                        row.section?.remove(at: rowIndex + 1)
                    }
                    if !row.isValid {
                        let message = row.validationErrors.first?.msg
                        let labelRow = InputDeliveryErrorRow("") { eRow in
                            eRow.value = message
                        }
                        let indexPath = row.indexPath!.row + 1
                        row.section?.insert(labelRow, at: indexPath)
                    }
                    self.validate(row: row)
                }
            })
        }
        
        // phone second
        section1 <<< RowInputDelivery<FillInformationPhoneCell>.init(TicketUserInfomationCellType.phone2.rawValue, { (row) in
            row.cell.update(title: Text.phoneNumberSecond.localizedText, placeHolder: Text.inputPhoneNumberSecond.localizedText)
            row.add(ruleSet: RulesPhoneOptionalNumber.rules())
            row.cell.btnContact.isHidden = true
            row.cell.lblStar?.isHidden = true
            row.onChange({ [weak self](row) in
                self?.listener?.ticketUserModel?.phoneSecond = row.value?.trim() ?? ""
                self?.validate(row: row)
            })
            row.onRowValidationChanged { _, row in
                let rowIndex = row.indexPath!.row
                while row.section!.count > rowIndex + 1, row.section?[rowIndex + 1] is InputDeliveryErrorRow {
                    row.section?.remove(at: rowIndex + 1)
                }
                if !row.isValid {
                    let message = row.validationErrors.first?.msg
                    let labelRow = InputDeliveryErrorRow("") { eRow in
                        eRow.value = message
                    }
                    let indexPath = row.indexPath!.row + 1
                    row.section?.insert(labelRow, at: indexPath)
                }
                self.validate(row: row)
            }
        })

        section1 <<< RowDetailGeneric<InputDeliveryChooseReceiver>.init(FillInformationCellType.chooseReceiver.rawValue, { (row) in
            row.cell.contentView.addSeperator(with: .zero, position: .bottom)
            row.cell.lblTitle?.text = Text.buyTicketSomeoneElse.localizedText
            row.value = false
            row.onCellSelection({ [weak self](_, row) in
                row.value = !(row.value ?? false)
                if row.value == false {
                    self?.listener?.resetInfoToCurrent()
                } else {
                    self?.listener?.resetInfo()
                }
            })
        })
        
        let lblRequire = UILabel(frame: .zero)
        lblRequire >>> {
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.numberOfLines = 0
            $0.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
            $0.textAlignment = .center
        }
        
        let theTermsTickets = Text.theTermsTickets.localizedText
        let text = String(format: Text.haveAcceptTermWhenPressContinueFormat.localizedText, theTermsTickets)
        let range = (text as NSString).range(of: theTermsTickets)
        lblRequire.text = text

        if range.location != NSNotFound {
            let attributedString = NSMutableAttributedString(string: text, attributes: [
                .font: UIFont.systemFont(ofSize: 14.0, weight: .regular),
                .foregroundColor: #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1),
                .kern: 0.0
                ])
            
            attributedString.addAttribute(.foregroundColor, value: Color.orange, range: range)
            lblRequire.attributedText = attributedString
        }
        
        let footerView = UIView(frame: .zero)
        lblRequire >>> footerView >>> {
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(5)
                make.left.equalTo(16)
                make.right.equalTo(-16).priority(.high)
                make.bottom.equalToSuperview().priority(.high)
            })
        }
        let buttonBgFooter = UIButton()
        buttonBgFooter >>> footerView >>> {
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.snp.makeConstraints({ (make) in
                make.edges.equalTo(lblRequire)
            })
        }
        buttonBgFooter.rx.tap.bind {[weak self] (_) in
            self?.listener?.openTermOfTicket()
            
        }.disposed(by: disposeBag)
        
        let s = footerView.systemLayoutSizeFitting(CGSize(width: UIScreen.main.bounds.width, height: CGFloat.infinity), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        footerView.frame = CGRect(origin: .zero, size: s)
        
        tableView.tableFooterView = footerView
        
        UIView.performWithoutAnimation {
            self.form += [section1]
        }
        
        var paddingBottomButton:CGFloat = 16
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            paddingBottomButton += window?.safeAreaInsets.bottom ?? 0
        }
            
        let viewButtonInput = UIView(frame: .zero)
        viewButtonInput >>> view >>> {
            $0.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
            $0.clipsToBounds = true
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(0)
                make.right.equalTo(0)
                make.bottom.equalToSuperview()
                make.height.equalTo(58)
            })
        }
        
        let buttonInput = UIButton(frame: .zero)
        buttonInput >>> viewButtonInput >>> {
            $0.setBackground(using: Color.orange, state: .normal)
            $0.setTitleColor(.white, for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            $0.layer.cornerRadius = 24
            $0.clipsToBounds = true
            $0.setTitle(Text.continue.localizedText, for: .normal)
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(5)
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.height.equalTo(48)
            })
        }
        buttonInput.isEnabled = false
        buttonInput.rx.tap.bind(onNext: weakify({ (wSelf) in
            wSelf.listener?.didTouchNext()
        })).disposed(by: disposeBag)
        self.viewButtonInput = viewButtonInput
        
        self.btnNextInput = buttonInput
                
        let viewButton = UIView(frame: .zero)
        viewButton >>> view >>> {
            $0.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
            $0.clipsToBounds = true
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(0)
                make.right.equalTo(0)
                make.bottom.equalToSuperview()
                make.height.equalTo(58 + paddingBottomButton)
            })
        }
        
        
        let button = UIButton(frame: .zero)
        button >>> viewButton >>> {
            $0.setBackground(using: Color.orange, state: .normal)
            $0.setTitleColor(.white, for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            $0.layer.cornerRadius = 24
            $0.clipsToBounds = true
            $0.setTitle(Text.continue.localizedText, for: .normal)
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.height.equalTo(48)
                make.bottom.equalTo(-paddingBottomButton)
            })
        }
        button.isEnabled = false
        button.rx.tap.bind(onNext: weakify({ (wSelf) in
            wSelf.listener?.didTouchNext()
        })).disposed(by: disposeBag)
        
        self.btnNext = button

    }
    
    private func setupRX() {
        self.listener?.ticketUserObser.bind(onNext: {[weak self] (model) in
            self?.reloadUI(model: model)
        }).disposed(by: disposeBag)
    }
    
    func reloadUI(model: TicketUser?) {
        guard let model = model else {
            return
        }
        self.update(type: .name, value: model.name)
        self.update(type: .phone, value: model.phone)
        self.update(type: .email, value: model.email)
        self.update(type: .identifyCard, value: model.identifyCard)
        self.update(type: .phone2, value: model.phoneSecond)
    }
    
    func validate(row: BaseRow) {
        let errors = row.validationErrors
        let values = form.values().compactMapValues { $0 }.compactMap { $0 }.filter({ $0.key != "errorPhone"})
        let rows = form.allRows.count
        if !errors.isEmpty {
            self.btnNext?.isEnabled = false
            self.btnNext?.backgroundColor = #colorLiteral(red: 0.7529411765, green: 0.7764705882, blue: 0.8, alpha: 1)
            self.btnNextInput?.isEnabled = false
            self.btnNextInput?.backgroundColor = #colorLiteral(red: 0.7529411765, green: 0.7764705882, blue: 0.8, alpha: 1)
        } else if values.count == rows {
            let enable = form.validate().isEmpty
            self.btnNext?.isEnabled = enable
            self.btnNextInput?.isEnabled = enable
        } else {
            self.btnNext?.isEnabled = false
            self.btnNext?.backgroundColor = #colorLiteral(red: 0.7529411765, green: 0.7764705882, blue: 0.8, alpha: 1)
            self.btnNextInput?.isEnabled = false
            self.btnNextInput?.backgroundColor = #colorLiteral(red: 0.7529411765, green: 0.7764705882, blue: 0.8, alpha: 1)
        }
    }
}
extension TicketUserInfomationVC: KeyboardAnimationProtocol {
    var containerView: UIView? {
        return self.viewButtonInput
    }
}
