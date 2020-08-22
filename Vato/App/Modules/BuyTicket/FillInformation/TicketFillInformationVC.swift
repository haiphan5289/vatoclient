//  File name   : TicketFillInformationVC.swift
//
//  Author      : khoi tran
//  Created date: 4/24/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxSwift
import FwiCore
import Eureka
import SnapKit
import FwiCoreRX
import FwiCore

enum TicketFillInfoStep: Int {
    case chooseWayTrip
    case chooseTime
    case chooseSeat
}

enum TicketFillInfomationCellType: String, CaseIterable {
    case address = "RowInputAddress"
    case name = "NameInput"
    case phone = "PhoneInput"
    case phone2 = "Phone2Input"
    case identifyCard = "identifyCard"
    case email = "EmailInput"
    case chooseReceiver = "ChooseReceiver"
    case busStation = "busStation"
    case ticketTime = "ticketTime"
    case routeStop = "routeStop"
    case defaultUserInfo = "defaultUserInfo"
    case seats = "seats"
    
    var messageRequire: String? {
        switch self {
        case .seats:
            return FwiLocale.localized("Bạn chưa chọn ghế.")
        case .ticketTime:
            return FwiLocale.localized("Bạn chưa chọn giờ.")
        case .routeStop:
            return FwiLocale.localized("Bạn chưa chọn điểm lên xe.")
        default:
            return nil
        }
    }
    
}


protocol TicketFillInformationPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    
    var listBusStation: Observable<[TicketRoutes]>  { get }
    var ticketSchedulesTime: Observable<String?> { get }
    var eTicketModel: Observable<TicketInformation> { get }
    var eLoadingObser: Observable<(Bool, Double)> { get }
    var dateStart: Date { get }
    var destLocation: TicketLocation? { get }
    var ticketUserModel: TicketUser? { get set }
    var ticketUserObser: Observable<TicketUser> { get }
    var error: Observable<BuyTicketPaymenState> {get}
    var seats: Observable<[SeatModel]?> { get }
    var ticketType: TicketRoundTripType { get }
    var isRoundTrip: Bool { get }
    
    func ticketFillInformationMoveBack()
    func routeToTicketTime()
    func didSelectBusStation(with busStation: TicketRoutes)
    func routeToRouteStop()
    func routeToSeatPosition()
    func resetInfoToCurrent()
    func resetInfo()
    func routeToChooseSeats()
}

final class TicketFillInformationVC: FormViewController, TicketFillInformationPresentable, TicketFillInformationViewControllable, LoadingAnimateProtocol, DisposableProtocol {
    private struct Config {
        static let BusStationSection = "BusStationSection"
        static let TicketTimeSection = "TicketTimeSection"
        static let RouteStopSection = "RouteStopSection"
        static let BuyTicketSwitchSection = "BuyTicketSwitchSection"
        static let UserInformationSection = "UserInformationSection"
        static let SeatSection = "SeatSection"
    }
    
    /// Class's public properties.
    weak var listener: TicketFillInformationPresentableListener?
    
    // MARK: View's lifecycle
    
    override func loadView() {
        super.loadView()
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = #colorLiteral(red: 0.9764705882, green: 0.9764705882, blue: 0.9764705882, alpha: 1)
        tableView.separatorColor = .clear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupNavigation()
        setupRX()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }
    
    /// Class's private properties.
    
    private var selectedBusStationId: Int? {
        didSet {
            self.updateSelectedBusStation()
        }
    }
    
    @VariableReplay public var isFormValidated: Bool = false
    @Replay(queue: MainScheduler.asyncInstance) private var step: TicketFillInfoStep
    internal var disposeBag = DisposeBag()
    private var manualInput: Bool = false
    override func tableView(_: UITableView, viewForFooterInSection _: Int) -> UIView? { return nil }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return 0.1 }
    
    func updateRouteStop(routeStop: String?) {
        self.update(type: .routeStop, value: routeStop)
    }
    
    deinit {
        print("!!!\(type(of: self)) \(#function)")
    }
}

// MARK: View's event handlers
extension TicketFillInformationVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension TicketFillInformationVC {
}

// MARK: Class's private methods
private extension TicketFillInformationVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        self.view.backgroundColor = #colorLiteral(red: 0.9750739932, green: 0.9750967622, blue: 0.9750844836, alpha: 1)

        tableView >>> view >>> {
            $0.snp.makeConstraints({ (make) in
                make.left.right.top.equalToSuperview()
                make.bottom.equalToSuperview()
            })
        }
    }
    
    func setupNavigation() {
        title = Text.chooseBusStation.localizedText
        
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
            wSelf.listener?.ticketFillInformationMoveBack()
        }).disposed(by: disposeBag)
    }
    
    func setupRX() {
        self.$step.debug("!!!!Item").bind(onNext: weakify({ (type, wSelf) in
            guard !wSelf.form.validate().isEmpty || type == .chooseWayTrip  else {
                return
            }
            switch type {
            case .chooseWayTrip:
                wSelf.listener?.routeToTicketTime()
            case .chooseSeat:
                wSelf.listener?.routeToRouteStop()
            case .chooseTime:
                wSelf.listener?.routeToChooseSeats()
            }
        })).disposed(by: disposeBag)
        
        
        self.listener?.listBusStation.observeOn(MainScheduler.asyncInstance).bind(onNext: weakify({ (listRoute, wSelf) in
            wSelf.generateBusStationSection(listRoute: listRoute)
            wSelf.generateTableSections()
        })).disposed(by: disposeBag)
        
        self.listener?.ticketSchedulesTime.distinctUntilChanged().observeOn(MainScheduler.asyncInstance).bind(onNext: {[weak self] (time) in
            guard let wSelf = self else { return }
            wSelf.update(type: .ticketTime, value: time)
        }).disposed(by: disposeBag)
        
        self.listener?.ticketUserObser.bind(onNext: weakify({ (user, wSelf) in
            guard !wSelf.manualInput else { return }
            wSelf.reloadUI(model: user)
        })).disposed(by: disposeBag)
        
        listener?.error.bind(onNext: {[weak self] (errorType) in
            AlertVC.showError(for: self, message: errorType.getMsg())
        }).disposed(by: disposeBag)
        
        
        self.listener?.seats.observeOn(MainScheduler.asyncInstance).map {
            $0?.map { $0.chair ?? "" }.joined(separator: ", ")
        }.filterNil().distinctUntilChanged().bind(onNext: weakify({ (seats, wSelf) in
            wSelf.update(type: .seats, value: seats)
        })).disposed(by: disposeBag)
        showLoading(use: self.listener?.eLoadingObser)
    }
    
    private func generateTableSections() {
        self.generateEditInfoSection(sectionTag: Config.TicketTimeSection)
        self.updateEditInfoSection(type: .ticketTime, sectionTag: Config.TicketTimeSection, value: nil, title: Text.departureTime.localizedText)
        
        self.generateEditInfoSection(sectionTag: Config.SeatSection)
        self.updateEditInfoSection(type: .seats, sectionTag: Config.SeatSection, value: nil, title: Text.selectSeats.localizedText)
        
        self.generateEditInfoSection(sectionTag: Config.RouteStopSection)
        self.updateEditInfoSection(type: .routeStop, sectionTag: Config.RouteStopSection, value: nil, title: Text.whereToPickup.localizedText)
        
        if self.listener?.ticketType == .startTicket {
            self.generateBuyTicketSwitchSection()
            self.generateUserInformationSection()
            
            listener?.resetInfoToCurrent()
            self.updateUserInformationSection(buyForSomeoneElse: false)
        }
    }
    
    private func generateBusStationSection(listRoute: [TicketRoutes]) {
        form.removeAll { (s) -> Bool in
            s.tag == Config.BusStationSection
        }
        
        let section1 = Section("") { (s) in
            s.tag = Config.BusStationSection
            
            var footer = HeaderFooterView<UIView>(.callback { UIView() })
            footer.onSetupView = { (view, _) in
                view.backgroundColor = .clear
            }
            footer.height = { 8 }
            s.footer = footer
        }
        
        section1 <<< RowDetailGeneric<BusStationCell>.init(TicketFillInfomationCellType.busStation.rawValue, {(row) in
            row.cell.addSeperator(with: .zero, position: .bottom)
            row.cell.segmentView.setupDisplay(item: listRoute)
            row.cell.segmentView.scrollView = tableView
            row.cell.segmentView.selected.bind(onNext: weakify({[weak row] (route, wSelf) in
                row?.value = route
                wSelf.step = .chooseWayTrip
                wSelf.listener?.didSelectBusStation(with: route)
            })).disposed(by: disposeBag)

            if listRoute.count == 1 {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.2) { [weak self, weak row] in
                    guard self != nil else { return }
                    if !listRoute.isEmpty {
                        row?.cell.segmentView.select(at: 0)
                    }
                }
            }
        })
        
        UIView.performWithoutAnimation {
            self.form += [section1]
        }
    }
    
    private func generateEditInfoSection(sectionTag: String) {
        form.removeAll { (s) -> Bool in
            s.tag == sectionTag
        }
        
        let section = Section("") { (s) in
            s.tag = sectionTag
            
            var footer = HeaderFooterView<UIView>(.callback { UIView() })
            footer.onSetupView = { (view, _) in
                view.backgroundColor = .clear
            }
            footer.height = { 0.1 }
            
            s.footer = footer
        }
        
        UIView.performWithoutAnimation {
            self.form += [section]
        }
    }
    
    private func updateEditInfoSection(type: TicketFillInfomationCellType, sectionTag: String, value: String?, title: String?) {
        if let section = form.sectionBy(tag: sectionTag) {
            section.removeAll()
            section <<<  RowDetailGeneric<TicketEditInfoCell>.init(type.rawValue, { (row) in
                row.cell.updateView(title: title)
                if let messageRequire = type.messageRequire {
                    row.add(rule: Eureka.RuleRequired(msg: messageRequire, id: type.rawValue))
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
                }
                
                row.onChange { [unowned self](row) in
                    self.validate(row: row)
                }
                
                row.value = value
                row.onCellSelection {[weak self] (cell, row) in
                    guard let wSelf = self else { return }
                    wSelf.didSelectedEditInfoSection(type: type)
                }
                row.cell.editView.rx.controlEvent(.touchUpInside).bind(onNext: weakify({ (wSelf) in
                    wSelf.didSelectedEditInfoSection(type: type)
                })).disposed(by: disposeBag)
                if type == .ticketTime {
                    row.cell.addSeperator(with: .zero, position: .top)
                    
                }
                row.cell.addSeperator(with: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16), position: .bottom)
            })
        }
    }
    
    func didSelectedEditInfoSection(type: TicketFillInfomationCellType) {
        switch type {
        case .ticketTime:
            self.listener?.routeToTicketTime()
        case .routeStop:
            self.listener?.routeToRouteStop()
        case .seats:
            self.listener?.routeToChooseSeats()
        default:
            break
        }
    }
    
    private func updateSelectedBusStation() {
        guard let id = self.selectedBusStationId else { return }
        
        guard let section = form.sectionBy(tag: Config.BusStationSection) else { return }
        let rowTag = "\(TicketFillInfomationCellType.busStation.rawValue)_\(id)"
        for row in section.allRows {
            if let r = row as? RowDetailGeneric<BusStationCell> {
                r.cell.updateSelected(isSelected: r.tag == rowTag)
            }
        }
    }
    
    private func generateBuyTicketSwitchSection() {
        form.removeAll { (s) -> Bool in
            s.tag == Config.BuyTicketSwitchSection
        }
        
        let section = Section("") { (s) in
            s.tag = Config.BuyTicketSwitchSection
            
            var footer = HeaderFooterView<UIView>(.callback { UIView() })
            footer.onSetupView = { (view, _) in
                view.backgroundColor = .white
            }
            footer.height = { 0.1 }
            s.footer = footer
        }
        
        section <<< RowDetailGeneric<TicketSwitchCell>.init(TicketFillInfomationCellType.chooseReceiver.rawValue, {  (row) in
            row.value = false
            row.cell.update(title: Text.buyTicketSomeoneElse.localizedText)
            
            row.cell.valueSwitch.isEnabled = self.listener?.ticketType == .startTicket
            
            row.cell.changed.bind {[weak self] (value) in
                self?.updateUserInformationSection(buyForSomeoneElse: value)
                if value {
                    self?.listener?.resetInfo()
                } else {
                    self?.listener?.resetInfoToCurrent()
                }
                
            }.disposed(by: disposeBag)
        })
        UIView.performWithoutAnimation {
            form += [section]
        }
    }
    
    private func generateUserInformationSection() {
        form.removeAll { (s) -> Bool in
            s.tag == Config.UserInformationSection
        }
        
        let section = Section("") { (s) in
            s.tag = Config.UserInformationSection
            var header = HeaderFooterView<UIView>(.callback { UIView() })
            header.onSetupView = { (view, _) in
                view.backgroundColor = .clear
            }
            header.height = { 8 }
            s.header = header
            
            var footer = HeaderFooterView<UIView>(.callback { UIView() })
            footer.onSetupView = { (view, _) in
                view.backgroundColor = .white
            }
            footer.height = { 10 }
            s.footer = footer
        }
        
        
        UIView.performWithoutAnimation {
            form += [section]
        }
    }
    
    private func generateInputInfo<C>(section: Section,
                                      type: TicketFillInfomationCellType,
                                      cell: C.Type,
                                      config: (RowInputDelivery<C>) -> ()) where C: FillInformationInputTextCell
    {
        section <<< RowInputDelivery<C>.init(type.rawValue, config)
    }
    
    private func loadInputInfoUser(section: Section, user: UserInfo?, email: String?) {
        if let user = user, user.email?.isEmpty == false {
            manualInput = false
            section <<< RowDetailGeneric<TicketDefaultUserInformationCell>.init(TicketFillInfomationCellType.defaultUserInfo.rawValue, { (row) in
                row.onChange({ [weak self](row) in
                    self?.validate(row: row)
                })
            })
        } else {
            // name
            manualInput = true
            let types: [TicketFillInfomationCellType] = [.name, .phone, .email]
            
            // Type Cell
            func loadCell(by type: TicketFillInfomationCellType) -> FillInformationInputTextCell.Type {
                switch type {
                case .name, .email:
                    return FillInformationNameCell.self
                case .phone:
                    return FillInformationPhoneCell.self
                default:
                    fatalError("Please implement!!!")
                }
            }
            
            let updateInfo: (TicketFillInfomationCellType, String?) -> ()  = { [weak self] type, value in
                guard let wSelf = self else {
                    return
                }
                
                let current = wSelf.listener?.ticketUserModel
                defer {
                    wSelf.listener?.ticketUserModel = current
                }
                
                switch type {
                case .name:
                    current?.name = value?.trim() ?? ""
                case .phone:
                    current?.phone = value?.trim() ?? ""
                case .email:
                    current?.email = value?.trim() ?? ""
                default:
                    fatalError("Please implement!!!")
                }
                
            }
            
            types.forEach { (type) in
                let t = loadCell(by: type)
                var text: String?
                self.generateInputInfo(section: section, type: type, cell: t) { (row) in
                    switch type {
                    case .name:
                        text = user?.fullName
                        row.cell.update(title: Text.fullname.localizedText, placeHolder: Text.inputFullname.localizedText)
                        row.add(ruleSet: RulesName.rules())
                        row.onChange({ [weak self](row) in
                            updateInfo(.name, row.value)
                            self?.validate(row: row)
                        })
                    case .phone:
                        text = user?.phone
                        row.cell.textField.keyboardType = .numberPad
                        row.cell.update(title: Text.phoneNumber.localizedText, placeHolder: Text.inputPhoneNumber.localizedText)
                        row.add(ruleSet: RulesPhoneNumber.rules())
                        (row.cell as? FillInformationPhoneCell)?.btnContact.isHidden = true
                        row.onChange({ [weak self](row) in
                            updateInfo(.phone, row.value)
                            self?.validate(row: row)
                        })
                    case .email:
                        text = user?.email ?? email
                        row.cell.update(title: Text.email.localizedText, placeHolder: Text.inputEmailAdress.localizedText)
                        row.add(ruleSet: RulesEmail.rules())
                        row.onChange({ [weak self](row) in
                            updateInfo(.email, row.value)
                            self?.validate(row: row)
                        })
                    default:
                        fatalError("Please implement!!!")
                    }
                    
                    // Validate
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
                    
                    guard let value = text, !value.isEmpty else { return }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        row.cell.setText(text)
                    }
                }
            }
        }
    }
    
    func updateUserInformationSection(buyForSomeoneElse: Bool) {
        form.removeAll { (s) -> Bool in
            s.tag == Config.UserInformationSection
        }
        
        guard self.listener?.ticketType == .startTicket else {
            return
        }
        
        let section = Section("") { (s) in
            s.tag = Config.UserInformationSection
            var header = HeaderFooterView<UIView>(.callback { UIView() })
            header.onSetupView = { (view, _) in
                view.backgroundColor = .clear
            }
            header.height = { 8 }
            s.header = header
            
            var footer = HeaderFooterView<UIView>(.callback { UIView() })
            footer.onSetupView = { (view, _) in
                view.backgroundColor = .white
            }
            footer.height = { 10 }
            s.footer = footer
        }
        
        guard self.listener?.ticketType == .startTicket else {
            return
        }
        if !buyForSomeoneElse  {
            loadInputInfoUser(section: section, user: UserManager.instance.info, email: nil)
        } else {
            loadInputInfoUser(section: section, user: nil, email: UserManager.instance.info?.email)
        }
        
        if let row = self.createIndentifierCell() {
            section <<< row
        }
        
        UIView.performWithoutAnimation {
            form += [section]
        }
    }
    
    func createIndentifierCell() -> RowInputDelivery<FillInformationInputTextCell>? {
        var isVerifyIdentifier = false
        if let dateStart = listener?.dateStart,
            let destLocation = listener?.destLocation {
            isVerifyIdentifier = BuslineConfigDataManager.shared.isValidateIdentifierId(date: dateStart, destLocation: destLocation)
        }
        if isVerifyIdentifier {
            // identify card
            return RowInputDelivery<FillInformationInputTextCell>.init(TicketFillInfomationCellType.identifyCard.rawValue, { (row) in
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
        } else {
            return nil
        }
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
        
        if let row = self.form.rowBy(tag: TicketFillInfomationCellType.defaultUserInfo.rawValue) as? RowDetailGeneric<TicketDefaultUserInformationCell> {
            
            row.value = model.phone
            row.cell.display(name: model.name, phone: model.phone)
            
            self.listener?.ticketUserModel?.name = model.name
            self.listener?.ticketUserModel?.phone = model.phone
            self.listener?.ticketUserModel?.email = model.email
        }
    }
    
    func update(type: TicketFillInfomationCellType, value: Any?) {
        var cell = self.form.rowBy(tag: type.rawValue)
        switch type {
            
        case .ticketTime:
            if let v = value as? String, !v.isEmpty {
                step = .chooseTime
            }
            self.updateEditInfoSection(type: .ticketTime, sectionTag: Config.TicketTimeSection, value: value as? String, title: Text.departureTime.localizedText)
            
            cell = self.form.rowBy(tag: type.rawValue)
        case .routeStop:
            self.updateEditInfoSection(type: .routeStop, sectionTag: Config.RouteStopSection, value: value as? String, title: Text.whereToPickup.localizedText)
            cell = self.form.rowBy(tag: type.rawValue)
        case .seats:
            if let v = value as? String, !v.isEmpty {
                step = .chooseSeat
            }
            self.updateEditInfoSection(type: .seats, sectionTag: Config.SeatSection, value: value as? String, title: Text.selectSeats.localizedText)
            cell = self.form.rowBy(tag: type.rawValue)
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
        default:
            break
        }
        
        guard let cell1 = cell else {
            return
        }
        self.validate(row: cell1)
        
    }
    
    func validate(row: BaseRow) {
        let errors = row.validationErrors
        let values = form.values().compactMapValues { $0 }.compactMap { $0 }.filter({ $0.key != "errorPhone" })
        let rows = form.allRows.count
        
        if !errors.isEmpty {
            self.isFormValidated = false
        } else if values.count == rows {
            let enable = form.validate().isEmpty
            self.isFormValidated = enable
        } else {
            self.isFormValidated = false
        }
    }
}
