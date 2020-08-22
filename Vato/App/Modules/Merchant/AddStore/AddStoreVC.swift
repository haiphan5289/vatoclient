//  File name   : AddStoreVC.swift
//
//  Author      : khoi tran
//  Created date: 10/21/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Eureka
import FwiCore
import FwiCoreRX
import VatoNetwork

enum AddStoreCellType: String {
    case name
    case address
    case coordinate
    case phoneNumber
    case link
    case category
    case activeTime
    case banner
    case title
    case save
    case image
    
    case mon = "2"
    case tue = "3"
    case wed = "4"
    case thu = "5"
    case fri = "6"
    case sat = "7"
    case sun = "8"
    
}

enum ChoosePhotoType {
    case TakePhoto
}

enum MerchantActionCommand {
    case create
    case update
}

protocol AddStorePresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func backToMerchantDetail()
    func routeToSearchAddress()
    func choosePhoto(type: UIImagePickerController.SourceType)
    
    var errorObserable: Observable<MerchantState>{ get }
    var eLoadingObser: Observable<(Bool,Double)> {get}

    var selectedImage: Observable<UploadedImage> { get }
    var currentStore: Observable<Store?> { get }
    var listLeafCategory: Observable<[MerchantCategory]> { get }
    
    func getCurrentSelectedStore()-> Store?
    func updateStore(command: MerchantActionCommand, params: [String: Any], bannerImage: [URL:String]?, listOtherImage: [UploadedImage]?)
    
    func updateListSelectedCategory(listSelectedCategory:  [MerchantCategory])
    var listSelectedCategory: [MerchantCategory] { get }
}

final class AddStoreVC: FormViewController, AddStorePresentable, AddStoreViewControllable, LoadingAnimateProtocol, DisposableProtocol {
    
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: AddStorePresentableListener?
    
    // MARK: View's lifecycle
    override func loadView() {
        super.loadView()
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        tableView.separatorColor = .clear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Thông tin cửa hàng"
        visualize()
        setupRX()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }
    
    /// Class's private properties.
    var disposeBag = DisposeBag()
    private static let maxImageNumber = 5
    var workingHours: FoodWorkingHours?
    var saveButton: UIButton = UIButton(frame: .zero)
    
    override func tableView(_: UITableView, viewForFooterInSection _: Int) -> UIView? { return nil }
    
    override func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat { return 0.1 }
    
    override func tableView(_: UITableView, heightForFooterInSection s: Int) -> CGFloat { return 0.1 }
    
    override func tableView(_: UITableView, viewForHeaderInSection _: Int) -> UIView? { return nil }
    
    func didSelectAddress(model: MapModel.Place) {
        self.updateRow(type: .address, value: model.address)
        let lat = model.location?.lat != nil ? String(model.location!.lat) : "0"
        let lon = model.location?.lon != nil ? String(model.location!.lon) : "0"
        self.updateRow(type: .coordinate, value: [lat, lon])
    }
}

// MARK: View's event handlers
extension AddStoreVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension AddStoreVC {
}

// MARK: Class's private methods
private extension AddStoreVC {
    
    
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        self.setupNavigation()
        
        tableView >>> view >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        
        let section1 = Section("") { (s) in
            s.tag = "InputInfor"
        }
        
        
        // name
        section1 <<< RowInputDelivery<MerchantFormRequireInputCell>.init(AddStoreCellType.name.rawValue, { (row) in
            row.cell.contentView.addSeperator(with: .zero, position: .top)
            row.cell.update(title: Text.nameOutlet.localizedText, placeHolder: Text.inputNameOutlet.localizedText)
            row.add(ruleSet: RulesName.rules());
            row.onChange({ [weak self](row) in
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
        // address
        section1 <<< RowInputDelivery<MerchantFormRequireInputCell>.init(AddStoreCellType.address.rawValue, { (row) in
            row.cell.lblStar?.isHidden = true
            row.cell.update(title: Text.addressShop.localizedText, placeHolder: Text.inputAddress.localizedText)
            row.cell.allowInput(isAllowed: false)
            row.cell.enableImage(isHidden: false, imageName: "ic_merchant_map")
            row.cell.set(callback: {[weak self] (index) in
                guard let me = self else { return }
                me.listener?.routeToSearchAddress()
            })
        })
        
        // lat and long
        section1 <<< RowDetailGeneric<MerchantDoubleFormInputCell>.init(AddStoreCellType.coordinate.rawValue, { (row) in
            row.cell.lblStar?.isHidden = true
            row.cell.lblTitle.isHidden = true
            row.cell.allowInput(isAllowed: false)
            row.cell.update(title: "",
                            leftPlaceholder: Text.latMerchant.localizedText,
                            rightPlaceholder: Text.longMerchant.localizedText)
            row.onRowValidationChanged { _, row in
            }
        })
        
        // phone number
        section1 <<< RowInputDelivery<MerchantFormRequireInputCell>.init(AddStoreCellType.phoneNumber.rawValue, { (row) in
            row.cell.update(title: Text.phoneNumber.localizedText, placeHolder: Text.inputPhoneNumber.localizedText)
            row.cell.textField.keyboardType = .numberPad
            row.add(ruleSet: RulesPhoneNumber.rules());
            row.onChange({ [weak self](row) in
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
        
        // link
        section1 <<< RowInputDelivery<MerchantFormRequireInputCell>.init(AddStoreCellType.link.rawValue, { (row) in
            row.cell.update(title: Text.linktoMerchant.localizedText, placeHolder: Text.inputLink.localizedText)
            row.cell.lblStar?.isHidden = true
            row.add(ruleSet: RulesLink.rules());
            
            row.onChange({ [weak self](row) in
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
        
        
        // category
        section1 <<< RowInputDelivery<MerchantSelectionFormCell>.init(AddStoreCellType.category.rawValue, { (row) in
            row.cell.update(title: Text.categories.localizedText, text: Text.selectCategories.localizedText)
            row.add(rule: RuleRequired(msg: Text.categoriesNotEmpty.localizedText))
            row.onChange({ [weak self](row) in
                self?.validate(row: row)
            })
            row.onCellSelection({  [weak self](row, cell) in
                guard let me = self else { return }
                me.showLeafCategoryView(listLeafCategory: [])
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
        
        
        // monday + title
        section1 <<< RowInputDelivery<MerchantRightSelectionFormCell>.init(AddStoreCellType.mon.rawValue, { (row) in
            row.cell.update(title: Text.hoursWork.localizedText,
                            subtitle: Text.monday.localizedText,
                            placeholder: Text.selectTimeWork.localizedText)
            row.add(ruleSet: RulesName.rules());
            row.onCellSelection({[weak self] (cell, row) in
                self?.showTimeSelectionView(weekDayType: .mon)
            })
        })
        
        // tuesday
        section1 <<< RowInputDelivery<MerchantRightSelectionFormCell>.init(AddStoreCellType.tue.rawValue, { (row) in
            row.cell.update(title: "", subtitle: Text.tuesday.localizedText, placeholder: Text.selectTimeWork.localizedText)
            row.cell.updateLblTitleHidden(isHidden: true)
            row.cell.lblStar?.isHidden = true
            row.add(ruleSet: RulesName.rules())
            row.onCellSelection({[weak self] (cell, row) in
                self?.showTimeSelectionView(weekDayType: .tue)
            })
        })
        
        // wedesday
        section1 <<< RowInputDelivery<MerchantRightSelectionFormCell>.init(AddStoreCellType.wed.rawValue, { (row) in
            row.cell.update(title: "", subtitle: Text.wesneday.localizedText, placeholder: Text.selectTimeWork.localizedText)
            row.cell.updateLblTitleHidden(isHidden: true)
            row.cell.lblStar?.isHidden = true
            row.add(ruleSet: RulesName.rules())
            row.onCellSelection({[weak self] (cell, row) in
                self?.showTimeSelectionView(weekDayType: .wed)
            })
        })
        
        // thursday
        section1 <<< RowInputDelivery<MerchantRightSelectionFormCell>.init(AddStoreCellType.thu.rawValue, { (row) in
            row.cell.update(title: "", subtitle: Text.thursday.localizedText, placeholder: Text.selectTimeWork.localizedText)
            row.cell.updateLblTitleHidden(isHidden: true)
            row.cell.lblStar?.isHidden = true
            row.add(ruleSet: RulesName.rules())
            row.onCellSelection({[weak self] (cell, row) in
                self?.showTimeSelectionView(weekDayType: .thu)
            })
        })
        
        // friday
        section1 <<< RowInputDelivery<MerchantRightSelectionFormCell>.init(AddStoreCellType.fri.rawValue, { (row) in
            row.cell.update(title: "", subtitle: Text.friday.localizedText, placeholder: Text.selectTimeWork.localizedText)
            row.cell.updateLblTitleHidden(isHidden: true)
            row.cell.lblStar?.isHidden = true
            row.add(ruleSet: RulesName.rules())
            row.onCellSelection({[weak self] (cell, row) in
                self?.showTimeSelectionView(weekDayType: .fri)
            })
        })
        
        // saturday
        section1 <<< RowInputDelivery<MerchantRightSelectionFormCell>.init(AddStoreCellType.sat.rawValue, { (row) in
            row.cell.update(title: "", subtitle: Text.saturday.localizedText, placeholder: Text.selectTimeWork.localizedText)
            row.cell.updateLblTitleHidden(isHidden: true)
            row.cell.lblStar?.isHidden = true
            row.add(ruleSet: RulesName.rules())
            row.onCellSelection({[weak self] (cell, row) in
                self?.showTimeSelectionView(weekDayType: .sat)
            })
        })
        
        // sunday
        section1 <<< RowInputDelivery<MerchantRightSelectionFormCell>.init(AddStoreCellType.sun.rawValue, { (row) in
            row.cell.update(title: "", subtitle: Text.sunday.localizedText, placeholder: Text.selectTimeWork.localizedText)
            row.cell.updateLblTitleHidden(isHidden: true)
            row.cell.lblStar?.isHidden = true
            row.add(ruleSet: RulesName.rules())
            row.onCellSelection({[weak self] (cell, row) in
                self?.showTimeSelectionView(weekDayType: .sun)
            })
        })
        
        // banner
        
        section1 <<< RowDetailGeneric<MerchantTitleFormCell>.init(AddStoreCellType.title.rawValue, { (row) in
            row.cell.update(title: Text.photoBanner.localizedText)
        })
        section1 <<< RowDetailGeneric<MerchantChooseImagerFormCell>.init(AddStoreCellType.banner.rawValue, { (row) in
            row.set(callback: {[weak self] (index) in
                guard let me = self else { return }
                if let index =  me.form.allRows.index(of: row) {
                    me.tableView.deselectRow(at: IndexPath(row: index, section: 0), animated: false)
                }
                me.showActionSheet()
            })
        })
        
        section1 <<< RowDetailGeneric<MerchantButtonFormCell>.init(AddStoreCellType.save.rawValue, { (row) in
            row.cell.update(title: "Lưu")
            row.cell.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1.0)
            row.cell.set {[weak self] (index) in
                guard let me = self else { return }
                printDebug("Hello")
                me.updateStore()
            }
        })

        
        UIView.performWithoutAnimation {
            self.form += [section1]
        }        
        
    }
    
    func validate(row: BaseRow) {
        let errors = row.validationErrors
        let values = form.values().compactMapValues { $0 }.compactMap { $0 }.filter({ $0.key != "errorPhone"})
        let rows = form.allRows.count
        if let row = form.rowBy(tag: AddStoreCellType.save.rawValue) as? RowDetailGeneric<MerchantButtonFormCell> {
            if !errors.isEmpty {
                row.value = false
            } else if values.count == rows {
                let enable = form.validate().isEmpty
                row.value = enable
                
            } else {
                row.value = true
            }
        }
    }
    
    private func setupNavigation() {
        
        let navigationBar = navigationController?.navigationBar
        let bgImage = UIImage(named:"bg_navigationbar")?.stretchableImage(withLeftCapWidth: 0, topCapHeight: 0)
        navigationBar?.setBackgroundImage(bgImage, for: .default)
        navigationBar?.barTintColor = Color.orange
        navigationBar?.isTranslucent = false
        navigationBar?.tintColor = .white
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        
        let image = UIImage(named: "ic_arrow_back")
        let button = UIButton(frame: CGRect(origin: .zero, size: image?.size ?? .zero))
        button.setImage(image, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
        let barButton = UIBarButtonItem(customView: button)
        navigationItem.leftBarButtonItem = barButton
        
        button.rx.tap.bind(onNext: weakify { wSelf in
            wSelf.listener?.backToMerchantDetail()
        }).disposed(by: disposeBag)
    }
    
    
    func setupRX() {
        
        self.listener?.selectedImage.bind(onNext: { [weak self] (image) in
            guard let me = self else { return }
            me.addBannerCell(image: image)
            
        }).disposed(by: disposeBag)
        
        self.listener?.currentStore.bind(onNext: {[weak self]  (s) in
            guard let m = self, let store = s else { return }
            m.updateData(s: store)
        }).disposed(by: disposeBag)
        
        showLoading(use: self.listener?.eLoadingObser)
        
        self.saveButton.rx.tap.bind(onNext: {[weak self]  (s) in
            guard let m = self else { return }
            m.updateStore()
        }).disposed(by: disposeBag)
        
        self.listener?.errorObserable.observeOn(MainScheduler.asyncInstance).bind(onNext: { [weak self](err) in
            AlertVC.showError(for: self, message: err.getMsg())
        }).disposed(by: disposeBag)
    }
    
    func addBannerCell(image: UploadedImage) {
        if let row = self.form.rowBy(tag: AddStoreCellType.save.rawValue) {
            let rowIndex = row.indexPath!.row-1
            
            let imageRow = RowDetailGeneric<MerchantImageFormCell>.init(self.generateImageCellTag(), { (row) in
                row.value = image
                row.cell.set(callback: { (index) in
                    if let index = row.indexPath?.row {
                        row.section?.remove(at: index)
                    }
                    self.validateAddBannerCell()
                })
                
            })
            row.section?.insert(imageRow, at: rowIndex)
        }
        
        self.validateAddBannerCell()
    }
    
    func validateAddBannerCell() {
        let rowCount = self.form.allRows.filter { $0.tag?.contains(AddStoreCellType.image.rawValue) ?? false }.count
        
        if rowCount >= AddStoreVC.maxImageNumber {
            if let row = self.form.rowBy(tag: AddStoreCellType.banner.rawValue) {
                let rowIndex = row.indexPath!.row
                row.section?.remove(at: rowIndex)
            }
        } else {
            if let _ = self.form.rowBy(tag: AddStoreCellType.banner.rawValue) {
                return
            } else {
                if let saveRow = self.form.rowBy(tag: AddStoreCellType.save.rawValue) {
                    let bannerRow = RowDetailGeneric<MerchantChooseImagerFormCell>.init(AddStoreCellType.banner.rawValue, { (row) in
                        row.set(callback: {[weak self] (index) in
                            guard let me = self else { return }
                            me.showActionSheet()
                        })                        
                    })
                    let index = saveRow.indexPath!.row
                    saveRow.section?.insert(bannerRow, at: index)
                }
            }
        }
    }
    
    func showActionSheet() {
        let actionsheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionsheet.addAction(UIAlertAction(title: Text.takePhoto.localizedText, style: .default, handler: { (action) -> Void in
            self.listener?.choosePhoto(type: .camera)
        }))
        actionsheet.addAction(UIAlertAction(title: Text.chooseExistPhoto.localizedText, style: .default, handler: { (action) -> Void in
            self.listener?.choosePhoto(type: .photoLibrary)
        }))
        actionsheet.addAction(UIAlertAction(title: Text.cancel.localizedText, style: .cancel, handler: { (action) -> Void in
        }))
        self.present(actionsheet, animated: true, completion: nil)
    }
    
    
    private func generateImageCellTag() -> String {
        return "\(AddStoreCellType.image.rawValue)_\(FireBaseTimeHelper.default.currentTime)"
    }
    
    
    func updateData(s: Store) {
        updateRow(type: .name, value: s.name)
        updateRow(type: .address, value: s.address)
        
        let lat = s.lat != nil ? String(s.lat!) : ""
        let lon = s.lon != nil ? String(s.lon!) : ""
        updateRow(type: .coordinate, value: [lat , lon])
        updateRow(type: .phoneNumber, value: s.phoneNumber)
        updateRow(type: .link, value: s.urlRefer ?? "")
        
        let listSelectedCategory = s.category ?? []
        self.listener?.updateListSelectedCategory(listSelectedCategory: listSelectedCategory)
        updateRow(type: .category, value: listSelectedCategory.map({ $0.name! }).joined(separator: ","))
        
        self.workingHours = s.workingHours
        if let workingHours = s.workingHours?.daily {
            for dow in workingHours {
                self.updateRow(type: AddStoreCellType.init(rawValue: dow.key.rawValue) ?? AddStoreCellType.mon , value: dow.value.time.stringValue)
            }
        }
        
        if let bannerImage = s.bannerImage {
            for imageURL in bannerImage {
                var uploadedImage = UploadedImage()
                uploadedImage.imageURL = imageURL
                self.addBannerCell(image: uploadedImage)
            }
        }
    }
    
    
    func updateRow(type: AddStoreCellType, value: Any?) {
        let row = self.form.rowBy(tag: type.rawValue)
        switch type {
        case .name, .address, .phoneNumber, .link:
            let name = row as? RowInputDelivery<MerchantFormRequireInputCell>
            name?.cell.setText(value as? String)
        case .coordinate:
            let coordinate = row as? RowDetailGeneric<MerchantDoubleFormInputCell>
            coordinate?.value = value as? [String]
        case .mon, .tue, .wed, .thu, .fri, .sat, .sun:
            let mon = row as? RowInputDelivery<MerchantRightSelectionFormCell>
            mon?.cell.setText(text: value as? String)
        case .category:
            let categoryRow = row as? RowInputDelivery<MerchantSelectionFormCell>
            categoryRow?.cell.setText(value as? String)
        default:
            break
        }
        guard let cell1 = row else {
            return
        }
        validate(row: cell1)
    }
    
    
    func updateStore() {
        var json:[String: Any] = [:]
        
        json[Store.CodingKeys.name.rawValue] = self.getCellValue(type: AddStoreCellType.name, valueType: String.self)
        let coords = self.getCellValue(type: AddStoreCellType.coordinate, valueType: [String].self)
        json[Store.CodingKeys.lat.rawValue] = Double(string: coords?.first ?? "")  // coords?.first
        json[Store.CodingKeys.lon.rawValue] = Double(string: coords?.last ?? "") // coords?.last
        
        json[Store.CodingKeys.phoneNumber.rawValue] = self.getCellValue(type: AddStoreCellType.phoneNumber, valueType: String.self)
        json[Store.CodingKeys.address.rawValue] = self.getCellValue(type: AddStoreCellType.address, valueType: String.self)
        json[Store.CodingKeys.urlRefer.rawValue] = self.getCellValue(type: AddStoreCellType.link, valueType: String.self)
        
        json["categoryId"] = self.listener?.listSelectedCategory.map({ (c) -> Int in
                return c.id!
            })
        
        var listDaily = self.workingHours?.daily?.reduce(into: [String: ([String: Int])]()) { (r, element) in
            let key = element.key.rawValue
            
            var value:[String:Int] = [:]
            value["open"] = element.value.time.open
            value["close"] = element.value.time.close
            
            r[key] = value
            
        }
        
        if let listDaily = listDaily {
            let dailyJson = ["daily": listDaily]
            
            json[Store.CodingKeys.workingHours.rawValue] = dailyJson
            
        }
        
        if let s = self.listener?.getCurrentSelectedStore() {
            json["id"] = s.id
            self.listener?.updateStore(command: .update, params: json, bannerImage: nil, listOtherImage: self.getListBannerParams())
        } else {
//            var uploadAvatarParams =
            self.listener?.updateStore(command: .create, params: json, bannerImage: nil, listOtherImage: self.getListBannerParams())
        }
    }
    
    func getCellValue<T>(type: AddStoreCellType, valueType: T.Type) -> T? {
        let cell = self.form.rowBy(tag: type.rawValue)
        switch type {
        case .name, .address, .phoneNumber, .link:
            let name = cell as? RowInputDelivery<MerchantFormRequireInputCell>
            return name?.value as? T
        case .coordinate:
            let coordinate = cell as? RowDetailGeneric<MerchantDoubleFormInputCell>
            return coordinate?.value as? T
        case .mon, .tue, .wed, .thu, .fri, .sat, .sun:
            let dow = cell as? RowInputDelivery<MerchantRightSelectionFormCell>
            return dow?.value as? T
        default:
            return nil
        }
    }
    
    func getListBannerParams() -> [UploadedImage]? {
        let listUploadImage = self.form.allRows.filter { $0.tag?.contains(AddStoreCellType.image.rawValue) ?? false }.map { (row) -> UploadedImage? in
            let imageRow = row as? RowDetailGeneric<MerchantImageFormCell>
            return imageRow?.value

            }.compactMap ({ $0 })
        
        return listUploadImage
    }
    
    
    func showTimeSelectionView(weekDayType: FoodWeekDayType) {
        
        let vc = UIStoryboard(name: "MerchantDetail", bundle: nil).instantiateViewController(withIdentifier: "ViewCheckUI") as! TimeWorkVCViewController
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        vc.day = weekDayType
        vc.callback = { [weak self] (workingWeekDay) in
            guard let me = self, let rowType = AddStoreCellType.init(rawValue: workingWeekDay?.day.rawValue ?? ""), let workingWeekDay = workingWeekDay else {
                return
            }
            
            if me.workingHours == nil {
                me.workingHours = FoodWorkingHours()
                me.workingHours?.daily = [:]
            }
            
            me.workingHours?.daily?[workingWeekDay.day] = workingWeekDay
            me.updateRow(type: rowType, value: workingWeekDay.time.stringValue)
        }
        
        self.present(vc, animated: true) {
            
        }
    }
    
    func showLeafCategoryView(listLeafCategory: [MerchantCategory]) {
        
        self.listener?.listLeafCategory.take(1).bind(onNext: { [weak self] (listLeafCategory) in
            guard let me = self else { return }
            let vc: CategoryViewController<MerchantCategory> = CategoryViewController<MerchantCategory>()
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .crossDissolve
            vc.listCategory = listLeafCategory
            vc.listSelectedCategory = me.listener?.listSelectedCategory ?? []
            
            vc.callback = { [weak self] listCategory in
                guard let me = self else { return }
                guard let listCategory = listCategory else { return }
                me.updateSelectedLeafCategories(listCategory: listCategory)
            }
            me.present(vc, animated: true) {
                
            }
        }).disposed(by: disposeBag)
        
    }
    
    func updateSelectedLeafCategories(listCategory: [MerchantCategory]) {
        self.listener?.updateListSelectedCategory(listSelectedCategory: listCategory)
        self.updateRow(type: .category, value: listCategory.map({ $0.name! }).joined(separator: ","))
    }
}



