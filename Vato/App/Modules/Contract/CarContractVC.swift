//  File name   : CarContractVC.swift
//
//  Author      : an.nguyen
//  Created date: 8/18/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import Eureka
import SnapKit
import FwiCore
import FwiCoreRX
import RxSwift
import RxCocoa
import FSCalendar

protocol CarContractPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func moveBack()
    func goToOrder()
    func routeToMap(type: FillContractCellType)
    func routeToPickTime()
    
    var optionObser: Observable<OptionContract> { get }
    func submitOrder(contract: CarContract)
}

final class CarContractVC: FormViewController, CarContractPresentable, CarContractViewControllable {
    private struct Config {
        static let AdressSection = "AdressSection"
        static let TicketSection = "TicketSection"
        static let UserSection = "UserSection"
    }

    /// Class's public properties.
    weak var listener: CarContractPresentableListener?

    // MARK: View's lifecycle
    override func loadView() {
        super.loadView()
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.separatorColor = .clear
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setUpRX()
        
//        loadInfo()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }

    /// Class's private properties.
    @IBOutlet weak var viewDestination: UIView!
    @IBOutlet weak var btnRequest: UIButton!
    
    private lazy var disposeBag = DisposeBag()
    
    var picker1 = UIPickerView()
    var picker2 = UIPickerView()
    var picker3 = UIPickerView()

//    var source1: [String]? = [Text.singleTrip.localizedText, Text.roundTrip.localizedText]
//    var source2 = ["Tieu chuan", "Chat luong"]
//    var source3 = ["4 chỗ", "7 chỗ"]
    
    var source1 : [String]?
    var source2 : [String]?
    var source3 : [String]?

    let toolBar = UIToolbar()
    var pickerDate = FSCalendar()
}

// MARK: View's event handlers
extension CarContractVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension CarContractVC {
    func update(cellType: FillContractCellType, value: Any?) {
        if let r = self.form.rowBy(tag: cellType.rawValue) as? RowInputDelivery<FillInformationDateCell> {
            r.cell.setText(value as? String)
        }
    }
    
    func update(model: AddressProtocol, type: FillContractCellType) {
        if let r = self.form.rowBy(tag: type.rawValue) as? RowDetailGeneric<AddressCell> {
            r.value = model.name
        }
    }
    
    func loadInfo() {
        if let r = self.form.rowBy(tag: FillContractCellType.turn.rawValue) as? RowInputDelivery<MixDropBoxTextCell> {
            r.cell.textField.text = source1?[0]
        }
        
        if let r = self.form.rowBy(tag: FillContractCellType.car.rawValue) as? RowInputDelivery<FillInformationMultiTextFieldCell> {
            r.cell.textField.text = source2?[0]
            r.cell.textField2.text = source3?[0]
        }
    }
    
    private func getUserOrder() -> CarContract {
        let all = self.form.values()
        let type = FillContractCellType.self
        let pickupAdd = all[type.origin.rawValue] as? String
        let dropAdd = all[type.destination.rawValue] as? String
        let tripType = all[type.turn.rawValue] as? String
        let departureTime = all[type.departure.rawValue] as? Double
        let arriveTime = all[type.arrive.rawValue] as? Double
        let bill = all[type.bill.rawValue] as? Bool
        let name = all[type.name.rawValue] as? String
        let phone = all[type.phone.rawValue] as? String
        let email = all[type.email.rawValue] as? String
        let customerNum = all[type.customer.rawValue] as? Int
        let seatNum = all[type.seats.rawValue] as? Int
        let vehicleRank = all[type.car.rawValue] as? String
        let driverGender = all[type.driver.rawValue] as? String
        let otherTicket = all[type.ticket.rawValue] as? Bool
        
        let contract = CarContract(pickup: pickupAdd, pickup_time: departureTime, drop: dropAdd, drop_time: arriveTime, trip_type: tripType, num_of_people: customerNum, num_of_seat: seatNum, vehicle_rank: vehicleRank, driver_gender: driverGender, require_bill: bill, note: "", other_grant: otherTicket, other_name: name, other_phone: phone, other_email: email)
        return contract
    }
}

// MARK: Class's private methods
private extension CarContractVC {
    private func localize() {
        // todo: Localize view's here.
    }
    
    private func setUpRX() {
        listener?.optionObser.bind(onNext: weakify { (options, wSelf) in
            wSelf.source1 = options.trip_types
            wSelf.source2 = options.ranks
            wSelf.source3 = options.seats
        }).disposed(by: disposeBag)
        
        btnRequest.rx.tap.bind { [weak self] in
            guard let wSelf = self else { return }
            let contract = wSelf.getUserOrder()
            wSelf.listener?.submitOrder(contract: contract)
        }
    }
    
    private func visualize() {
        // todo: Visualize view's here.
        title = Text.titleContract.localizedText
        view.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        let item = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_back").withRenderingMode(.alwaysTemplate), landscapeImagePhone: #imageLiteral(resourceName: "ic_back").withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: nil)
        self.navigationItem.leftBarButtonItem = item
        item.rx.tap.bind { [weak self] in
            self?.listener?.moveBack()
        }.disposed(by: disposeBag)
        
        let rightItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_order").withRenderingMode(.alwaysTemplate), landscapeImagePhone: #imageLiteral(resourceName: "ic_order").withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: nil)
        self.navigationItem.rightBarButtonItem = rightItem
        rightItem.rx.tap.bind { [weak self] in
            self?.listener?.goToOrder()
        }.disposed(by: disposeBag)

        UIApplication.setStatusBar(using: .lightContent)
        let navigationBar = self.navigationController?.navigationBar
        navigationBar?.barTintColor = Color.orange
        navigationBar?.isTranslucent = false
        navigationBar?.tintColor = .white
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        navigationBar?.shadowImage = UIImage()

        createToolBar()
        picker1 = createPicker()
        picker2 = createPicker()
        picker3 = createPicker()
        createPickerDate()
        
        tableView >>> view >>> {
            $0.snp.makeConstraints({ (make) in
                make.left.right.equalToSuperview()
                make.top.equalTo(66)
                make.bottom.equalTo(btnRequest.snp.top)
            })
        }

        self.form += [genSection0()]
        self.form += [genSection1()]
        self.form += [genSection2()]
    }
    
    private func genSection0() -> Section {
        let section = Section("") { (s) in
            s.tag = Config.AdressSection
            s.header = nil
        }
        
        //origin
        section <<< RowDetailGeneric<AddressCell>.init(FillContractCellType.origin.rawValue, { (row) in
            row.cell.update(with: "Đón bạn tại", iconName: "ic_origin")
            row.cell.addUI()
            row.cell.addSeperator(with: UIEdgeInsets(top: 0, left: 48, bottom: 0, right: 0), position: .bottom)
            row.onChange({ [weak self](row) in
                self?.validate(row: row)
            })
            row.onCellSelection { [weak self] (_, _) in
                self?.listener?.routeToMap(type: .origin)
            }
        })
        
        //destination
        section <<< RowDetailGeneric<AddressCell>.init(FillContractCellType.destination.rawValue, { (row) in
            row.cell.update(with: "Đưa bạn đến", iconName: "ic_destination")
            row.onChange({ [weak self](row) in
                self?.validate(row: row)
            })
            row.onCellSelection { [weak self] (_, _) in
                self?.listener?.routeToMap(type: .destination)
            }
        })

        return section
    }
    
    private func genSection1() -> Section {
        let section = Section("") { (s) in
            s.tag = Config.TicketSection
            var header = HeaderFooterView<UIView>(.callback { UIView() })
            header.onSetupView = { (view, _) in
                view.backgroundColor = .clear
            }
            
            header.height = { 10 }
            s.header = header
        }

        //turn
        section <<< RowInputDelivery<MixDropBoxTextCell>.init(FillContractCellType.turn.rawValue, { (row) in
            row.cell.textField.inputView = self.picker1
            row.cell.textField.inputAccessoryView = self.toolBar
            row.cell.textField.tag = FillContractCellType.turn.tag
            row.cell.textField.text = source1?[0]

            row.cell.update(withSource: [Text.singleTrip.localizedText, Text.roundTrip.localizedText], title1: Text.kindTrip.localizedText, title2: Text.customerNumber.localizedText)
            row.onChange({ [weak self](row) in
                self?.validate(row: row)
                self?.updateTicketSection(isRound: (row.value == Text.roundTrip.localizedText))
            })
        })

        //departure
        section <<< RowInputDelivery<FillInformationDateCell>.init(FillContractCellType.departure.rawValue, { (row) in
            row.cell.lblTitle.text = "Ngày khởi hành"
            row.onChange({ [weak self](row) in
                self?.validate(row: row)
            })
            row.onCellSelection({ [weak self](c,r) in
                self?.listener?.routeToPickTime()
            })
        })
        
        //driver
        
        //car
        section <<< RowInputDelivery<FillInformationMultiTextFieldCell>.init(FillContractCellType.car.rawValue, { (row) in
            row.cell.textField.inputView = self.picker2
            row.cell.textField.inputAccessoryView = self.toolBar
            row.cell.textField.text = source2?[0]

            row.cell.textField2.inputView = self.picker3
            row.cell.textField2.inputAccessoryView = self.toolBar
            row.cell.textField2.text = source3?[0]

            row.cell.update(with: Text.carLevel.localizedText, title2: Text.seatsNumber.localizedText, icon1Name: "ic_dropdown_gray", icon2Name: "ic_dropdown_gray")
            row.onChange({ [weak self](row) in
                self?.validate(row: row)
            })
        })
        
        //bill
        section <<< RowDetailGeneric<InputDeliveryChooseReceiver>.init(FillContractCellType.bill.rawValue, { (row) in
            row.value = false
            row.cell.lblTitle?.text = "Xuất hoá đơn điện tử"
            row.onCellSelection({ [weak self](_, row) in
                row.value = !(row.value ?? false)
            })
        })

        return section
    }
    
    private func updateTicketSection(isRound: Bool) {
        guard var section = self.form.sectionBy(tag: Config.TicketSection) else { return }
        if isRound {
            let r = RowInputDelivery<FillInformationDateCell>.init(FillContractCellType.arrive.rawValue, { (row) in
                row.cell.lblTitle.text = "Ngày về"
                row.onChange({ [weak self](row) in
                    self?.validate(row: row)
                })
                row.onCellSelection({ [weak self](c,r) in
                    self?.listener?.routeToPickTime()
                })
            })
            section.insert(r, at: 2)
        } else {
            section.remove(at: 2)
        }
        section.reload()
    }
    
    private func updateDateRows(isRound: Bool) {
        guard let section = self.form.sectionBy(tag: Config.TicketSection) else { return }
//        if let r = self.form.rowBy(tag: FillContractCellType.departure.rawValue) as? RowInputDelivery<FillInformationMultiTextFieldCell> {
//            r.cell.updateShowField(isShow: isRound)
//        }
        section.reload()
    }
    
    private func genSection2() -> Section {
        let section = Section("") { (s) in
            s.tag = Config.UserSection
            
//            var header = HeaderFooterView<UIView>(.callback { UIView() })
//            header.onSetupView = { (view, _) in
//                view.backgroundColor = .clear
//            }
//
//            header.height = { 10 }
//            s.header = header
        }
        
        //ticket user
        section <<< RowDetailGeneric<TicketSwitchCell>.init(FillContractCellType.ticket.rawValue, {  (row) in
            row.value = false
            row.cell.update(title: "Mua vé cho người khác")
            row.cell.changed.bind {[weak self] (value) in
                self?.updateUserSection(buyForSomeoneElse: value)
            }.disposed(by: disposeBag)
                        
        })
        return section
    }
    
    private func updateUserSection(buyForSomeoneElse: Bool) {
        guard var section = self.form.sectionBy(tag: Config.UserSection) else { return }
        if buyForSomeoneElse {
            //name
            section <<< RowInputDelivery<FillInformationNameCell>.init(FillContractCellType.name.rawValue, {  (row) in
                row.cell.update(title: Text.fullname.localizedText, placeHolder: "Nguyễn Văn A")
            })
            //phone
            section <<< RowInputDelivery<FillInformationPhoneCell>.init(FillContractCellType.phone.rawValue, {  (row) in
                row.cell.update(title: Text.phoneNumber.localizedText, placeHolder: "0123456789")
            })
            //email
            section <<< RowInputDelivery<FillInformationEmailCell>.init(FillContractCellType.email.rawValue, {  (row) in
                row.cell.update(title: Text.email.localizedText, placeHolder: "email@vato.vn")
            })
        } else {
            if section.allRows.count > 3 {
                section.removeLast(3)
            }
        }
        section.reload()
    }
    
    private func validate(row: BaseRow?) {
        let errors = form.validate()
        if !errors.isEmpty {
            self.btnRequest.isEnabled = false
            return
        }
//          self.btnNext?.isEnabled = self.listener?.newInfo.valid ?? false
    }
}
