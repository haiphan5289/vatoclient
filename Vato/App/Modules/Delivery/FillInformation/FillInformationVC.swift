//  File name   : FillInformationVC.swift
//
//  Author      : Dung Vu
//  Created date: 8/14/19
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

protocol FillInformationPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var currentInfo: DeliveryInputInformation { get }
    var newInfo: DeliveryInputInformation { get }
    var serviceType: DeliveryServiceType { get }
    func moveBack()
    func routeToContact()
    func routeToChangeAdress()
    func routeToPinAdress()
    func updateInformation()
    func fillInformationMe()
    func routeToPickTime()
    func udpateReceiver(phone: String?)
}

enum FillInformationCellType: String, CaseIterable {
    case address = "RowInputAddress"
    case name = "NameInput"
    case phone = "PhoneInput"
    case email = "EmailInput"
    case sizePackage = "SizePackage"
    case notePackage = "NotePackage"
    case chooseReceiver = "ChooseReceiver"
    case time = "time"
    
    var tag: Int {
      switch self {
          case .address: return  1
          case .name : return  2
          case .phone : return 3
          case .email : return 4
          case .sizePackage : return 5
          case .notePackage : return 6
          case .chooseReceiver : return 7
          case .time : return 8
      }
    }
}

final class FillInformationVC: FormViewController, FillInformationPresentable, FillInformationViewControllable {
    func update(type: FillInformationCellType, value: Any?) {
        let cell = self.form.rowBy(tag: type.rawValue)
        switch type {
        case .phone:
            let phone = cell as? RowInputDelivery<FillInformationPhoneCell>
            phone?.cell.setText(value as? String)
            
            self.listener?.udpateReceiver(phone: value as? String)
        case .address:
            let address = cell as? RowDetailGeneric<FillInformationAddressCell>
            address?.value = (value as? AddressProtocol)?.name
            if let location = value as? AddressProtocol {
                self.vatoLocationHeader?.setupDisplay(item: location)
            }
            self.validate(row: nil)
        case .name:
            let name = cell as? RowInputDelivery<FillInformationNameCell>
            name?.cell.setText(value as? String)
        case .chooseReceiver:
            let choose = cell as? RowDetailGeneric<InputDeliveryChooseReceiver>
            choose?.value = value as? Bool
        case .email:
            let email = cell as? RowInputDelivery<FillInformationEmailCell>
            email?.cell.setText(value as? String)
        case .sizePackage:
            let sizePackage = cell as? RowInputDelivery<FillInformationDropBoxCell>
            sizePackage?.cell.setText(value as? String)
        case .notePackage:
            let notePackage = cell as? RowInputDelivery<FillInformationInputTextCell>
            notePackage?.cell.setText(value as? String)
        case .time:
            let time = cell as? RowInputDelivery<FillInformationInputTimeCell>
            time?.cell.lblTime.text = value as? String
            break
        }
        guard let cell1 = cell else {
            return
        }
        validate(row: cell1)
    }
    
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: FillInformationPresentableListener?
    private let type: DeliveryDisplayType
    internal lazy var disposeBag = DisposeBag()
    private var btnNext: UIButton?
    private var vatoLocationHeader: VatoLocationHeaderView?
    private var headerViewContain: UIView?
    private var viewBgNext: UIView?
    private lazy var bookingConfirmView: MainDeliveryBookingView = MainDeliveryBookingView.loadXib(type: .DOMESTIC_DELIVERY)
    private var nxtRowTag: String = FillInformationCellType.name.rawValue
    private var crrRowTag: String = FillInformationCellType.phone.rawValue
    private var actionFill: ActionFill = .notyet
    enum ActionFill {
        case notyet
        case willNot
        case willFillAtSize
        case willFillAtNote
        case willFillAtEmail
    }

    // picker select package size
    var picker = UIPickerView()
    let toolBar = UIToolbar()
    let sizePackages :[PackageSize] = PackageSize.generateData()
    
    init(type: DeliveryDisplayType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        setupNavigationView()
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
        
        crrRowTag = FillInformationCellType.phone.rawValue
        if let fRow = self.form.rowBy(tag: crrRowTag) as? RowInputDelivery<FillInformationPhoneCell> {
            fRow.cell.cellBecomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    /// Class's private properties.
    override func tableView(_: UITableView, viewForFooterInSection _: Int) -> UIView? {
        return nil
    }
    
    override func tableView(_: UITableView, heightForFooterInSection s: Int) -> CGFloat {
        return 0.1
    }
}

// MARK: View's event handlers
extension FillInformationVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension FillInformationVC {
}

// MARK: Class's private methods
private extension FillInformationVC {
    func setupRX() {
        vatoLocationHeader?.backButton.rx.tap.bind(onNext: { [weak self] _ in
            self?.listener?.moveBack()
        }).disposed(by: disposeBag)
        
        vatoLocationHeader?.btnSearchAddress?.rx.tap.bind(onNext: { [weak self] _ in
            self?.listener?.routeToChangeAdress()
        }).disposed(by: disposeBag)
        
        vatoLocationHeader?.mapButton?.rx.tap.bind(onNext: { [weak self] _ in
            self?.listener?.routeToPinAdress()
        }).disposed(by: disposeBag)
        
        let showEvent = NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification).map (KeyboardInfo.init)
        let hideEvent = NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification).map (KeyboardInfo.init)
        
        Observable.merge([showEvent, hideEvent]).filterNil().bind { [weak self] d in
            UIView.animate(withDuration: d.duration, animations: {
                self?.viewBgNext?.snp.updateConstraints({ (make) in
                    make.bottom.equalTo(-d.height)
                })
                self?.view.layoutIfNeeded()
            })
        }.disposed(by: disposeBag)
        
        self.bookingConfirmView.eAction.bind(onNext: weakify({ (type, wSelf) in
            switch type {
            case .booking:
                wSelf.listener?.updateInformation()
            default:
                break
            }
        })).disposed(by: disposeBag)
    }
    
    private func localize() {
        // todo: Localize view's here.
    }
    
    private func visualize() {
        // todo: Visualize view's here.
        createPicker()
//
        self.view.backgroundColor = .white
        // navigation
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
        
        headerView.titleLabel.text = ((type == .sender) ? Text.deliveryTitleAdressSender.localizedText : Text.deliveryTitleAdressReceiver.localizedText)
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
//        button.isEnabled = false
        button.rx.tap.bind(onNext: weakify({ (wSelf) in
            if wSelf.type == .receiver {
                wSelf.goNextField()
            } else {
                wSelf.goNextFieldSender()
            }
        })).disposed(by: disposeBag)
        
        self.btnNext = button
        
        //
        var arrSection = [gensection1()]
        if self.listener?.serviceType == .DOMESTIC_DELIVERY,
            type == .receiver {
            arrSection.insert(gensection0(), at: 0)
        }
        if type == .receiver {
            arrSection += [gensection2()]
        }
        UIView.performWithoutAnimation {
            self.form += arrSection
        }
        
        self.view.bringSubviewToFront(self.viewBgNext!)
        
        if let serviceType = self.listener?.serviceType, serviceType == .DOMESTIC_DELIVERY {
            bookingConfirmView >>> self.view >>> {
                $0.snp.makeConstraints({ (make) in
                    make.edges.equalToSuperview()
                })
            }
            bookingConfirmView.dimiss(false)
        }
    }
    
    func setupNavigationView() {
        
    }
    
    private func headerAddress() -> String {
       return (type == .receiver) ? Text.deliveryInputAdressReceiverPlaceholder.localizedText : Text.deliveryInputAdressSenderPlaceholder.localizedText
    }
    
    func reloadOldInfo() {
        guard let current = self.listener?.currentInfo else {
            return
        }
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
        
        if let packageSize = current.packageSize {
            self.update(type: .sizePackage, value: packageSize.name)
        } else if let model = sizePackages.first {
            self.listener?.newInfo.packageSize = model
            self.update(type: .sizePackage, value: model.name)
        }
        
        self.update(type: .chooseReceiver, value: current.isMe)
    }
    
    func goToUpdate() {
        let emptyAddress = vatoLocationHeader?.nameLabel.text == headerAddress()
        if emptyAddress {
            let actionOK = AlertAction.init(style: .default, title: Text.ok.localizedText, handler: {})
            AlertVC.show(on: self, title: headerAddress(), message: nil, from: [actionOK], orderType: .horizontal)
        } else {
            if let serviceType = self.listener?.serviceType {
                switch serviceType {
                case .URBAN_DELIVERY:
                    self.listener?.updateInformation()
                case .DOMESTIC_DELIVERY:
                    self.bookingConfirmView.show()
                    self.updateFakeData()
                }
            }
        }
    }
    
    func isForcedFieldValidated() -> Bool {
        var b: Bool = true
        self.form.rows.forEach({r in
            if !validate(at: r) {
                b = false
                return
            }
        })
        return b
    }
            
    func goNextField() {
        if isAllToFilled() {
            goToUpdate()
            return
        }
        var crtRowTag = ""
        let isValidate = isForcedFieldValidated()
        let type = FillInformationCellType.self
        let types = type.allCases
        if let tf = self.tableView.findFirstResponder(){
            let tagTf = tf.tag
            crtRowTag = types[tagTf-1].rawValue
        }
        if isValidate && (actionFill == .willFillAtNote){
            goToUpdate()
            return
        }
        if crtRowTag.isEmpty {
            crtRowTag = crrRowTag
        }
        let crrRow  = self.form.rowBy(tag: crtRowTag)
        if let crr = crrRow as? RowInputDelivery<FillInformationPhoneCell> {
            crr.cell.cellResignFirstResponder()
            if let nr = self.form.rowBy(tag: type.name.rawValue) as? RowInputDelivery<FillInformationNameCell> {
//                crrRowTag = type.name.rawValue
                nr.cell.cellBecomeFirstResponder()
            }
        }
        else if let crr = crrRow as? RowInputDelivery<FillInformationNameCell> {
            crr.cell.cellResignFirstResponder()
            if let nr = self.form.rowBy(tag: type.sizePackage.rawValue) as? RowInputDelivery<FillInformationDropBoxCell> {
                crrRowTag = type.sizePackage.rawValue
                nr.cell.cellBecomeFirstResponder()
            }
        }
        else if let crr = crrRow as? RowInputDelivery<FillInformationDropBoxCell> {
            crr.cell.cellResignFirstResponder()
            if let nr = self.form.rowBy(tag: type.notePackage.rawValue) as? RowInputDelivery<FillInformationInputTextCell> {
//                crrRowTag = type.notePackage.rawValue
                nr.cell.cellBecomeFirstResponder()
            }
            actionFill = .willFillAtNote
        }
        else if let crr = crrRow as? RowInputDelivery<FillInformationInputTextCell> {
            crr.cell.cellResignFirstResponder()
            if let nr = self.form.rowBy(tag: type.phone.rawValue) as? RowInputDelivery<FillInformationPhoneCell> {
//                crrRowTag = type.phone.rawValue
                nr.cell.cellBecomeFirstResponder()
            }
        }
    }
        
    func isAllToFilled() -> Bool {
        var result = true
        let type = FillInformationCellType.self
        let rows = [self.form.rowBy(tag: type.phone.rawValue), self.form.rowBy(tag: type.name.rawValue), self.form.rowBy(tag: type.sizePackage.rawValue), self.form.rowBy(tag: type.notePackage.rawValue)]
        rows.forEach {
            guard let v = $0?.baseValue as? String else {
                result = false
                return
            }
            result = result && !v.isEmpty
        }
        return result
    }
    func isAllFromFilled() -> Bool {
        var result = true
         self.form.rows.forEach {
            guard let v = $0.baseValue as? String else {
                result = false
                return
            }
            result = result && !v.isEmpty
        }
        return result
    }
    
    func goNextFieldSender() {
        if isAllFromFilled() {
            goToUpdate()
            return
        }
        let type = FillInformationCellType.self
        var crtRowTag = ""
        let types = type.allCases
        if let tf = self.tableView.findFirstResponder(){
            let tagTf = tf.tag
            crtRowTag = types[tagTf-1].rawValue
        }
        
        let isValidate = isForcedFieldValidated()
        if isValidate && (actionFill == .willFillAtSize){
            goToUpdate()
            return
        }
        let crrRow  = self.form.rowBy(tag: crtRowTag)
        if let crr = crrRow as? RowInputDelivery<FillInformationPhoneCell> {
            crr.cell.cellResignFirstResponder()
            if let nr = self.form.rowBy(tag: type.name.rawValue) as? RowInputDelivery<FillInformationNameCell> {
                crrRowTag = type.name.rawValue
                nr.cell.cellBecomeFirstResponder()
            }
        }
        else if let crr = crrRow as? RowInputDelivery<FillInformationNameCell> {
            crr.cell.cellResignFirstResponder()
            if let nr = self.form.rowBy(tag: type.email.rawValue) as? RowInputDelivery<FillInformationEmailCell> {
                crrRowTag = type.email.rawValue
                nr.cell.cellBecomeFirstResponder()
            }
            actionFill = .willFillAtSize
        }
        else if let crr = crrRow as? RowInputDelivery<FillInformationEmailCell> {
            crr.cell.cellResignFirstResponder()
            if let nr = self.form.rowBy(tag: type.phone.rawValue) as? RowInputDelivery<FillInformationPhoneCell> {
                crrRowTag = type.phone.rawValue
                nr.cell.cellBecomeFirstResponder()
            }
        }
    }
        
    func validate(at row: BaseRow?) -> Bool {
        let errors = row?.validate()
        if let errors = errors, !errors.isEmpty {
            return false
        }
        return true
    }

    func validate(row: BaseRow?) {
        let errors = form.validate()
        if !errors.isEmpty {
//            self.btnNext?.isEnabled = false
            return
        }
//        self.btnNext?.isEnabled = self.listener?.newInfo.valid ?? false
    }
    
    func gensection0() -> Section   {
        let section = Section("") { (s) in
            s.tag = "InputTime"
            // header
            var header = HeaderFooterView<UIView>(.callback { UIView() })
            header.onSetupView = { (view, _) in
                view.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
            }
            header.height = { 10 }
            s.header = header
        }
        
        // cell phone
        section <<< RowInputDelivery<FillInformationInputTimeCell>.init(FillInformationCellType.time.rawValue, { (row) in
            row.cell.contentView.addSeperator(with: .zero, position: .top)
            row.cell.lblTitleTime.text = Text.deliveryTime.localizedText
            row.cell.lblTime.text = Text.chooseDeliveryTime.localizedText
            row.cell.lblSchedule.text = Text.scheduler.localizedText
            row.cell.textField.tag = FillInformationCellType.time.tag
            row.onCellSelection { [weak self] (_, _) in
                self?.listener?.routeToPickTime()
            }
        })
        return section
    }

    func gensection1() -> Section   {
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
        section <<< RowInputDelivery<FillInformationPhoneCell>.init(FillInformationCellType.phone.rawValue, { (row) in
            row.cell.textField.tag = FillInformationCellType.phone.tag
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
        section <<< RowInputDelivery<FillInformationNameCell>.init(FillInformationCellType.name.rawValue, { (row) in
            row.cell.update(from: self.type)
            row.cell.textField.tag = FillInformationCellType.name.tag
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
            section <<< RowDetailGeneric<InputDeliveryChooseReceiver>.init(FillInformationCellType.chooseReceiver.rawValue, { (row) in
                row.cell.contentView.addSeperator(with: .zero, position: .bottom)
//                row.cell.textField.tag = FillInformationCellType.chooseReceiver.tag
//                row.cell.lblTitle?.tag = FillInformationCellType.chooseReceiver.tag
                row.value = false
                row.onCellSelection({ [weak self](_, row) in
                    row.value = !(row.value ?? false)
                    self?.listener?.newInfo.isMe = row.value ?? false
                    if row.value == true {
                        self?.listener?.fillInformationMe()
                    }
                    if let nr = self?.form.rowBy(tag: FillInformationCellType.name.rawValue) as? RowInputDelivery<FillInformationNameCell> {
                            nr.cell.cellBecomeFirstResponder()
                    }
                })
            })
        } else {
            // email
            section <<< RowInputDelivery<FillInformationEmailCell>.init(FillInformationCellType.email.rawValue, { (row) in
                row.cell.update(title: Text.email.localizedText, placeHolder: Text.inputEmailAdress.localizedText)
                row.cell.textField.tag = FillInformationCellType.email.tag
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
    
    func gensection2() -> Section   {
        let section = Section("") { (s) in
            s.tag = "InfoPackage"
            // header
            var header = HeaderFooterView<UIView>(.callback { UIView() })
            header.onSetupView = { (view, _) in
                let label = UILabel()
                label >>> view >>> {
                    $0.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
                    $0.font = EurekaConfig.titleFont
                    $0.text = Text.packageInformation.localizedText
                    $0.snp.makeConstraints {
                        $0.left.equalTo(10)
                        $0.right.equalToSuperview()
                        $0.bottom.equalTo(-8)
                    }
                }
            }
            header.height = { 40 }
            s.header = header
        }
        
        // size Package
        section <<< RowInputDelivery<FillInformationDropBoxCell>.init(FillInformationCellType.sizePackage.rawValue, { (row) in
            row.cell.update(title: Text.packageSize.localizedText, placeHolder: Text.packageSize.localizedText)            
            row.cell.textField.tag = FillInformationCellType.sizePackage.tag
            row.cell.textField.inputView = self.picker
            row.cell.textField.inputAccessoryView = self.toolBar
            row.cell.lblStar?.isHidden = true
            
            row.onChange({ [weak self](row) in
                self?.validate(row: row)
            })
        })
        
        // note Package
        section <<< RowInputDelivery<FillInformationInputTextCell>.init(FillInformationCellType.notePackage.rawValue, { (row) in
            row.cell.update(title: Text.packageNotes.localizedText, placeHolder: Text.fragileGoods.localizedText)
            row.cell.textField.tag = FillInformationCellType.notePackage.tag
            row.cell.lblStar?.isHidden = true
            row.onChange({ [weak self](row) in
                self?.listener?.newInfo.packageNote = row.value
                self?.validate(row: row)
            })
        })
        return section
    }
    
    func updateFakeData() {
        
        let service = ServiceUse(idService: 128, service: Car(id: 128, choose: true, name: "Giao hàng", description: nil), isFixedPrice: true)
        let price = BookingConfirmPrice()
        price.lastPrice = 25000
        price.originalPrice = 25000
        
        price.service = service
        
        self.bookingConfirmView.eUpdate.onNext(.updateListService(listService: [service]))
        self.bookingConfirmView.eUpdate.onNext(.updatePrice(infor: price))
        self.bookingConfirmView.eUpdate.onNext(.service(type: service))
    }
}
