//  File name   : ShoppingFillInformationVC.swift
//
//  Author      : khoi tran
//  Created date: 4/3/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import Eureka
import RxSwift
import FwiCore
import FwiCoreRX

protocol ShoppingFillInformationPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    
    var newInfo: DeliveryInputInformation { get }
    var currentInfo: DeliveryInputInformation { get }
    var supplyConfig: Observable<SupplyConfig> { get }
    
    func moveBack()
    func routeToChangeAddress()
    func routeToPinAdress()
    func updateInformation()
    func routeToContact()
    func fillInformationMe()
    func udpateReceiver(phone: String?)
}

enum ShoppingFillInformationCellType: String, CaseIterable {
    case name = "NameInput"
    case phone = "PhoneInput"
    case notePackage = "NotePackage"
    case estimatePrice = "EstimatePrice"
    case chooseReceiver = "ChooseReceiver"
    case email = "Email"
    case address = "Address"
}

final class ShoppingFillInformationVC: FormViewController, ShoppingFillInformationPresentable, ShoppingFillInformationViewControllable {
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: ShoppingFillInformationPresentableListener?
    
    // MARK: View's lifecycle
    override func loadView() {
        super.loadView()
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        tableView.separatorColor = .clear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
        reloadOldInfo()
    }
    override func viewWillAppear(_ animated: Bool) {
        if #available(iOS 13.0, *) {
            UIApplication.setStatusBar(using: .darkContent)
        } else {
            UIApplication.setStatusBar(using: .default)
        }
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        super.viewWillAppear(animated)
        localize()
        
        crrRowTag = ShoppingFillInformationCellType.phone.rawValue
        if let fRow = self.form.rowBy(tag: crrRowTag) as? RowInputDelivery<FillInformationPhoneCell> {
            fRow.cell.cellBecomeFirstResponder()
        }
    }
    
    /// Class's private properties.
    internal lazy var disposeBag = DisposeBag()
    private var btnNext: UIButton?
    private var vatoLocationHeader: VatoLocationHeaderView?
    private var headerViewContain: UIView?
    private var viewBgNext: UIView?
    
    private let type: DeliveryDisplayType = .receiver
    private var nxtRowTag: String = ShoppingFillInformationCellType.name.rawValue
    private var crrRowTag: String = ShoppingFillInformationCellType.phone.rawValue

    override func tableView(_: UITableView, viewForFooterInSection _: Int) -> UIView? {
        return nil
    }
    
    override func tableView(_: UITableView, heightForFooterInSection s: Int) -> CGFloat {
        return 0.1
    }
}

// MARK: View's event handlers
extension ShoppingFillInformationVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension ShoppingFillInformationVC {
}

// MARK: Class's private methods
private extension ShoppingFillInformationVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        self.view.backgroundColor = .white
        
        var topPadding: CGFloat = 0
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            topPadding = window?.safeAreaInsets.top ?? 0
        }
        topPadding = (topPadding > 0) ? topPadding : 24
        
        let headerViewContain = UIView()
        headerViewContain.backgroundColor = .white
        self.view.addSubview(headerViewContain)
        
        headerViewContain.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        let headerView = VatoLocationHeaderView.loadXib()
        headerViewContain.addSubview(headerView)
        headerView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(topPadding)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        headerView.titleLabel.text = Text.storeLocation.localizedText
        self.vatoLocationHeader = headerView
        self.headerViewContain = headerViewContain
        
        // next
        let _viewBgNext = UIView(frame: .zero) >>> view >>> {
            $0.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(0)
                make.right.equalTo(0)
                make.bottom.equalTo(0)
                make.height.equalTo(78)
            })
        }
        
        // table view
        tableView >>> view >>> {
            $0.snp.makeConstraints({ (make) in
                make.left.equalToSuperview()
                make.right.equalToSuperview()
                make.top.equalTo(headerView.snp.bottom)
                make.bottom.equalTo(_viewBgNext.snp.top)
                
            })
        }
        
        self.viewBgNext = _viewBgNext
        
        let button = UIButton(frame: .zero)
        button >>> _viewBgNext >>> {
            $0.setBackground(using: Color.orange, state: .normal)
            //            $0.setBackground(using: Color.battleshipGrey, state: .disabled)
            $0.setTitleColor(.white, for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            $0.layer.cornerRadius = 8
            $0.clipsToBounds = true
            $0.setTitle(Text.continue.localizedText, for: .normal)
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.top.equalTo(10)
                make.height.equalTo(48)
            })
        }

        self.btnNext = button
        
        //
        var arrSection = [gensection1()]
        
        arrSection += [gensection2()]
        UIView.performWithoutAnimation {
            self.form += arrSection
        }
        
        self.view.bringSubviewToFront(self.viewBgNext!)
    }
    
    private func setupRX() {
        vatoLocationHeader?.backButton.rx.tap.bind(onNext: { [weak self] _ in
            self?.listener?.moveBack()
        }).disposed(by: disposeBag)
        
        vatoLocationHeader?.btnSearchAddress?.rx.tap.bind(onNext: { [weak self] _ in
            self?.listener?.routeToChangeAddress()
        }).disposed(by: disposeBag)
        
        vatoLocationHeader?.mapButton?.rx.tap.bind(onNext: { [weak self] _ in
            self?.listener?.routeToPinAdress()
        }).disposed(by: disposeBag)
        
        let showEvent = NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification).map (KeyboardInfo.init)
        let hideEvent = NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification).map (KeyboardInfo.init)
        
        Observable.merge([showEvent, hideEvent]).filterNil().bind { [weak self] d in
            guard let wSelf = self else { return }
            UIView.animate(withDuration: d.duration, animations: {
                wSelf.viewBgNext?.snp.updateConstraints({ (make) in
                    make.bottom.equalTo(-d.height)
                })
                wSelf.view.layoutIfNeeded()
            }, completion: { _ in
                guard let v = wSelf.tableView.findFirstResponder() else {
                    return
                }
                let rect = v.convert(v.bounds, to: wSelf.tableView)
                wSelf.tableView.scrollRectToVisible(rect, animated: true)
            })
        }.disposed(by: disposeBag)
        
        self.btnNext?.rx.tap.bind(onNext: weakify({ (wSelf) in
            wSelf.goNextField()
        })).disposed(by: disposeBag)
        
        self.listener?.supplyConfig.observeOn(MainScheduler.asyncInstance).bind(onNext: {[weak self] (s) in
            guard let wSelf = self else { return }
            guard let row = wSelf.form.rowBy(tag: ShoppingFillInformationCellType.estimatePrice.rawValue) as? RowInputDelivery<FillInformationPriceCell> else { return }
            
            row.remove(ruleWithIdentifier: "max_rule")
            row.add(ruleSet: RulesMaximumPrice.rules(maximumValue: s.maxEstimatedPrice ?? 3000000))
            
            
            let v = UIView(frame: .zero)
            v.backgroundColor = .clear
            
            let s1 = String(format: Text.shoppingFillInformationNote.localizedText, (s.maxEstimatedPrice ?? 3000000).currency)
            
            let label = UILabel.create {
                $0.numberOfLines = 0
                $0.text = s1
                $0.textColor = #colorLiteral(red: 0.4623882771, green: 0.5225807428, blue: 0.5743968487, alpha: 1)
                $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            }
            
            label >>> v >>> {
                $0.snp.makeConstraints { (make) in
                    make.top.equalTo(10)
                    make.left.equalTo(16)
                    make.right.equalTo(-16)
                    make.bottom.equalTo(-10)
                }
            }
            
            let s = v.systemLayoutSizeFitting(CGSize(width: UIScreen.main.bounds.width, height: .infinity), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
            v.frame = CGRect(origin: .zero, size: s)
            
            wSelf.tableView.tableFooterView = v
        }).disposed(by: disposeBag)
    }
}

extension ShoppingFillInformationVC {
    func goNextField() {
        var b: Bool = true
        self.form.rows.forEach({r in
            if !validate(at: r) {
                b = false
                return
            }
        })
        if b {
            let emptyAddress = vatoLocationHeader?.nameLabel.text == headerAddress()
            if emptyAddress {
                let actionOK = AlertAction.init(style: .default, title: Text.ok.localizedText, handler: {})
                AlertVC.show(on: self, title: headerAddress(), message: nil, from: [actionOK], orderType: .horizontal)
            } else {
                self.listener?.updateInformation()
            }
        } else {
            let nextRow = self.form.rowBy(tag: nxtRowTag)
            let oldRow  = self.form.rowBy(tag: crrRowTag)
            let type = ShoppingFillInformationCellType.self
            if let nr = nextRow as? RowInputDelivery<FillInformationNameCell>, let or = oldRow as? RowInputDelivery<FillInformationPhoneCell> {
                or.cell.cellResignFirstResponder()
                crrRowTag = nxtRowTag
                nr.cell.cellBecomeFirstResponder()
                nxtRowTag = type.notePackage.rawValue
            }
            else if let nr = nextRow as? RowDetailGeneric<ShoppingNoteCell>, let or = oldRow as? RowInputDelivery<FillInformationNameCell>{
                or.cell.cellResignFirstResponder()
                crrRowTag = nxtRowTag
                nr.cell.cellBecomeFirstResponder()
                nxtRowTag = type.estimatePrice.rawValue
            }
            else if let nr = nextRow as? RowInputDelivery<FillInformationPriceCell>, let or = oldRow as? RowDetailGeneric<ShoppingNoteCell> {
                or.cell.cellResignFirstResponder()
                crrRowTag = nxtRowTag
                nr.cell.cellBecomeFirstResponder()
                nxtRowTag = type.phone.rawValue
            }
            else if let nr = nextRow as? RowInputDelivery<FillInformationPhoneCell>, let or = oldRow as? RowInputDelivery<FillInformationPriceCell> {
                or.cell.cellResignFirstResponder()
                crrRowTag = nxtRowTag
                nr.cell.cellBecomeFirstResponder()
                nxtRowTag = type.name.rawValue
            }
        }
    }
    
    func gensection2() -> Section {
        let section = Section("") { (s) in
            s.tag = "InputNote"
            // header
            var header = HeaderFooterView<UIView>(.callback { UIView() })
            header.onSetupView = { (view, _) in
                let label = UILabel()
                label >>> view >>> {
                    $0.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
                    $0.font = EurekaConfig.titleFont
                    $0.text = Text.orderInformation.localizedText
                    $0.snp.makeConstraints {
                        $0.left.equalTo(10)
                        $0.right.equalToSuperview()
                        $0.bottom.equalTo(-8)
                    }
                }
            }
            
            header.height = { 48 }
            s.header = header
        }
        
        // cell
        section <<< RowDetailGeneric<ShoppingNoteCell>.init(ShoppingFillInformationCellType.notePackage.rawValue, { (row) in
            row.cell.contentView.addSeperator(with: .zero, position: .top)
            
            row.add(rule: RuleRequired(msg: Text.shoppingNoteRequiredMessage.localizedText))
            row.cell.updatePlaceHolder(Text.shoppingNotePlaceHolder.localizedText)
            let _ = row.onChange {[weak self] (row) in
                self?.listener?.newInfo.packageNote = row.value
                self?.validate(row: row)
            }
            
            row.onRowValidationChanged { _, row in
                let rowIndex = row.indexPath!.row
                while row.section!.count > rowIndex + 1, row.section?[rowIndex + 1] is InputDeliveryErrorRow {
                    row.section?.remove(at: rowIndex + 1)
                }
                if !row.isValid {
                    let message = row.validationErrors.first?.msg
                    let labelRow = InputDeliveryErrorRow("errorPhone") { eRow in
                        eRow.value = message
                    }
                    let indexPath = row.indexPath!.row + 1
                    row.section?.insert(labelRow, at: indexPath)
                }
                
                self.validate(row: row)
            }
        })
        
        section <<< RowInputDelivery<FillInformationPriceCell>.init(ShoppingFillInformationCellType.estimatePrice.rawValue, { (row) in
            row.cell.update(title: Text.estimatePrice.localizedText, placeHolder: "")
            row.add(ruleSet: RulesMaximumPrice.rules(maximumValue: 3000000))
            row.onChange({ [weak self](row) in
                self?.listener?.newInfo.estimatePrice = Int(row.value ?? "")
                self?.validate(row: row)
            })
            row.onRowValidationChanged { [weak self] _, row in
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
                
                self?.validate(row: row)
            }
            if type != .receiver {
                row.cell.updateLine(with: .zero)
            }
        })
        
        return section
    }
    func gensection1() -> Section {
        let section = Section("") { (s) in
            s.tag = "InputInfor"
            // header
            var header = HeaderFooterView<UIView>(.callback { UIView() })
            header.onSetupView = { (view, _) in
                let label = UILabel()
                label >>> view >>> {
                    $0.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
                    $0.font = EurekaConfig.titleFont
                    $0.text = self.type.title
                    $0.snp.makeConstraints {
                        $0.left.equalTo(10)
                        $0.right.equalToSuperview()
                        $0.bottom.equalTo(-8)
                    }
                }
            }
            header.height = { 48 }
            s.header = header
        }
        
        // cell phone
        section <<< RowInputDelivery<FillInformationPhoneCell>.init(ShoppingFillInformationCellType.phone.rawValue, { (row) in
            row.cell.contentView.addSeperator(with: .zero, position: .top)
            row.cell.update(from: self.type)
            row.add(ruleSet: RulesPhoneNumber.rules())
            row.onChange({ [weak self](row) in
                self?.listener?.newInfo.phone = row.value
                self?.validate(row: row)
                self?.listener?.udpateReceiver(phone: row.value)
            })
            
            row.cell.btnContact.rx.tap.bind(onNext: weakify({ (wSelf) in
                wSelf.listener?.routeToContact()
            })).disposed(by: disposeBag)
            
            row.onRowValidationChanged { _, row in
                let rowIndex = row.indexPath!.row
                while row.section!.count > rowIndex + 1, row.section?[rowIndex + 1] is InputDeliveryErrorRow {
                    row.section?.remove(at: rowIndex + 1)
                }
                if !row.isValid {
                    let message = row.validationErrors.first?.msg
                    let labelRow = InputDeliveryErrorRow("errorPhone") { eRow in
                        eRow.value = message
                    }
                    let indexPath = row.indexPath!.row + 1
                    row.section?.insert(labelRow, at: indexPath)
                }
                
                self.validate(row: row)
            }
        })
        
        // cell name
        section <<< RowInputDelivery<FillInformationNameCell>.init(ShoppingFillInformationCellType.name.rawValue, { (row) in
            row.cell.update(from: self.type)
            row.add(ruleSet: RulesName.rules())
            row.onChange({ [weak self](row) in
                self?.listener?.newInfo.name = row.value
                self?.validate(row: row)
            })
            row.onRowValidationChanged { [weak self] _, row in
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
                
                self?.validate(row: row)
            }
            if type != .receiver {
                row.cell.updateLine(with: .zero)
            }
        })
        
        if type == .receiver {
            section <<< RowDetailGeneric<InputDeliveryChooseReceiver>.init(ShoppingFillInformationCellType.chooseReceiver.rawValue, { (row) in
                row.cell.contentView.addSeperator(with: .zero, position: .bottom)
                row.value = false
                row.onCellSelection({ [weak self](_, row) in
                    row.value = !(row.value ?? false)
                    self?.listener?.newInfo.isMe = row.value ?? false
                    if row.value == true {
                        self?.listener?.fillInformationMe()
                    }
                })
            })
        } else {
            // email
            section <<< RowInputDelivery<FillInformationEmailCell>.init(ShoppingFillInformationCellType.email.rawValue, { (row) in
                row.cell.update(title: Text.email.localizedText, placeHolder: Text.inputEmailAdress.localizedText)
                row.cell.lblStar?.isHidden = true
                row.add(ruleSet: RulesEmailOptional.rules())
                row.onChange({ [weak self](row) in
                    self?.listener?.newInfo.email = row.value
                    self?.validate(row: row)
                })
                row.onRowValidationChanged { [weak self] _, row in
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
                    
                    self?.validate(row: row)
                }
                if type != .receiver {
                    row.cell.updateLine(with: .zero)
                }
            })
        }
        
        return section
    }
    
    func validate(row: BaseRow?) {
        let errors = row?.validate()
        if let errors = errors, !errors.isEmpty {
//            self.btnNext?.isEnabled = false
            return
        }
//        self.btnNext?.isEnabled = self.listener?.newInfo.shoppingValid ?? false
    }
    
    func validate(at row: BaseRow?) -> Bool {
        let errors = row?.validate()
        if let errors = errors, !errors.isEmpty {
            return false
        }
        return true
    }

    func update(type: ShoppingFillInformationCellType, value: Any?) {
        let cell = self.form.rowBy(tag: type.rawValue)
        switch type {
        case .address:
            let address = cell as? RowDetailGeneric<FillInformationAddressCell>
            address?.value = (value as? AddressProtocol)?.name
            if let location = value as? AddressProtocol {
                self.vatoLocationHeader?.setupDisplay(item: location)
            }
            self.validate(row: nil)
        case .phone:
            let phone = cell as? RowInputDelivery<FillInformationPhoneCell>
            phone?.cell.setText(value as? String)
            self.listener?.udpateReceiver(phone: value as? String)
        case .name:
            let name = cell as? RowInputDelivery<FillInformationNameCell>
            name?.cell.setText(value as? String)
        case .chooseReceiver:
            let choose = cell as? RowDetailGeneric<InputDeliveryChooseReceiver>
            choose?.value = value as? Bool
        case .email:
            let email = cell as? RowInputDelivery<FillInformationEmailCell>
            email?.cell.setText(value as? String)
        case .notePackage:
            let notePackage = cell as? RowDetailGeneric<ShoppingNoteCell>
            notePackage?.value = (value as? String)
        case .estimatePrice:
            let estimate = cell as? RowInputDelivery<FillInformationPriceCell>
            if let v = value as? Int {
                estimate?.cell.setText(String(v))
            } else {
                estimate?.cell.setText("")
            }
        }
        guard let cell1 = cell else {
            return
        }
        validate(row: cell1)
    }
    
    private func headerAddress() -> String {
       return (type == .receiver) ? Text.shoppingOriginTitle.localizedText : Text.deliveryInputAdressSenderPlaceholder.localizedText
    }
    
    func reloadOldInfo() {
        if let current = self.listener?.currentInfo {
            
            if let location = current.originalDestination {
                self.update(type: .address, value: location)
            } else {
                self.vatoLocationHeader?.nameLabel.text = headerAddress()
                self.validate(row: nil)
            }
            
            if let packageNote = current.packageNote {
                self.update(type: .notePackage, value: packageNote)
            }
            if let name = current.name {
                self.update(type: .name, value: name)
            }
            
            if let phone = current.phone {
                self.update(type: .phone, value: phone)
            }
            if let email = current.email {
                self.update(type: .email, value: email)
            }
            
            if let estimatePrice = current.estimatePrice {
                self.update(type: .estimatePrice, value: estimatePrice)
            }
            
            if let isMe = current.isMe {
                self.update(type: .chooseReceiver, value: isMe)
            } else {
                self.update(type: .chooseReceiver, value: true)
                self.listener?.fillInformationMe()
            }
            
        } else {
            self.update(type: .chooseReceiver, value: true)
            self.listener?.fillInformationMe()
        }
    }
}
