//  File name   : CreateMerchantDetailVC.swift
//
//  Author      : khoi tran
//  Created date: 10/19/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxSwift
import RxCocoa
import Eureka
import FwiCore
import FwiCoreRX
import KeyPathKit

enum AddImageType {
    case avatar
    case banner
}

enum AddMerchantCellType: String {
    case name = "Name"
    case scope = "Scope"
    case sectionTitle = "SectionTitle"
    //    case
}

protocol CreateMerchantDetailPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    
    var listMerchantAttributes: Observable<[MerchantAttribute]> { get }
    var selectedImage: Observable<UploadedImage> { get }
    var listMerchantAttributesData: Observable<[MerchantAttributeData]> { get }
    var currentSelectedMerchant: Merchant? { get }
    var eLoadingObser: Observable<(Bool,Double)> {get}
    var currentCategory: MerchantCategory? { get }
    var listMerchantType: Observable<[MerchantType]> { get}
    
    func getListMerchantAttribute(code: String?)
    func choosePhoto(type: UIImagePickerController.SourceType, imageType: AddImageType)
    func backToMainMerchant()
    func createMerchant(params: [String: Any])
    func updateMerchant(merchantId: Int, params: [String: Any])
    func uploadMerchantAttributes(code: String, listImage: [UploadedImage]) -> Observable<MerchantAttributeData>
    var errorObserable: Observable<MerchantState>{ get }

}

struct MerchantIdentifierCellType {
    var identifer: String
    var type: MerchantAttributeElementType
}

final class CreateMerchantDetailVC: FormViewController, CreateMerchantDetailPresentable, CreateMerchantDetailViewControllable, LoadingAnimateProtocol, DisposableProtocol {
    private struct Config {
        static var UploadAvatar = "UploadAvatar"
    }
    
    /// Class's public properties.
    weak var listener: CreateMerchantDetailPresentableListener?
    var selectImageCallback: BlockAction<UploadedImage>?
    
    override func loadView() {
        super.loadView()
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        tableView.separatorColor = .clear
        //        tableView.sec
    }
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Text.profileMerchant.localizedText
        
        visualize()
        setupRX()
        
        if let currentMerchant = self.listener?.currentSelectedMerchant {
            self.listener?.getListMerchantAttribute(code: currentMerchant.typeCode)
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }
    
    /// Class's private properties.
    var saveButton: UIButton = UIButton(frame: .zero)
    lazy var disposeBag = DisposeBag()
    
    override func tableView(_: UITableView, viewForFooterInSection _: Int) -> UIView? { return nil }
    
    override func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat { return 0.1 }
    
    override func tableView(_: UITableView, heightForFooterInSection s: Int) -> CGFloat { return 0.1 }
    
    override func tableView(_: UITableView, viewForHeaderInSection _: Int) -> UIView? { return nil }
    
    var listAttributeIdentifier:[MerchantIdentifierCellType] = []
    var modifiedMerchant: MerchantModifyData?
    
    private lazy var pickerView: UIPickerView = UIPickerView()
    private lazy var toolBar = UIToolbar()
    private var tempSelectMerchantType: MerchantType?
}

// MARK: View's event handlers
extension CreateMerchantDetailVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension CreateMerchantDetailVC {
}

// MARK: Class's private methods
private extension CreateMerchantDetailVC {
    private func localize() {
        // todo: Localize view's here.
    }
    
    private func visualize() {
        // todo: Visualize view's here.
        self.setupNavigation()
        
        pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 180))
        pickerView.backgroundColor = .white
        
        pickerView.showsSelectionIndicator = true
        
        
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: Text.done.localizedText, style: UIBarButtonItem.Style.done, target: self, action: #selector(self.donePicker))
        doneButton.tintColor = Color.orange
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        
        
        tableView >>> view >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        
        self.generateHeaderSection()
        
        let tableFooterView = UIView.create {
            $0.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 106)
        }
        
        saveButton >>> tableFooterView >>> {
            $0.setBackground(using: #colorLiteral(red: 0.9588660598, green: 0.4115985036, blue: 0.1715823114, alpha: 1), state: .normal)
            $0.cornerRadius = 24
            $0.setTitle(Text.saveMerchant.localizedText, for: .normal)
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(16)
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.height.equalTo(48)
            })
        }
        
        saveButton.isHidden = true
        self.tableView.tableFooterView = tableFooterView
    }
    
    private func generateHeaderSection() {
        let section1 = Section("") { (s) in
            s.tag = "HeaderSection"
        }
        
        // name
        section1 <<< RowDetailGeneric<MerchantAddNameFormCell>.init(AddMerchantCellType.name.rawValue, { (row) in
            row.cell.update(placeholder: "Tên merchant")
            row.add(ruleSet: RulesMerchantName.rules());
            row.value = MerchantAddNameValue()
            row.cell.setImageCallback(callback: { [weak self] in
                self?.selectImageCallback = row.cell.callbackHandler
                self?.showActionSheet(type: .avatar)
            })
            let _ =  row.onChange({ [weak self](row) in
                self?.validate(row: row)
            })
            
            
            row.onRowValidationChanged { _, row in
                let rowIndex = row.indexPath!.row
                while row.section!.count > rowIndex + 1, row.section?[rowIndex + 1] is InputDeliveryErrorRow {
                    row.section?.remove(at: rowIndex + 1)
                }
                
                if !row.isValid {
                    let validationErrors = row.validationErrors
                    let message = validationErrors.first?.msg
                    let labelRow = InputDeliveryErrorRow("") { eRow in
                        eRow.value = message
                    }
                    let indexPath = row.indexPath!.row + 1
                    if validationErrors.count >= 2 {
                        row.cell.updateValidateState(state: 2)
                        row.section?.insert(labelRow, at: indexPath)
                        
                    } else {
                        if message == RulesMerchantName.Configs.ValidateionErrorImageMessage {
                            row.cell.updateValidateState(state: 2)
                        } else {
                            row.section?.insert(labelRow, at: indexPath)
                        }
                    }
                }
            }
        })
        // scope
        
        section1 <<< RowInputDelivery<MerchantSelectionFormCell>.init(AddMerchantCellType.scope.rawValue, {[weak self] (row) in
            guard let wSelf = self else { return }
            row.cell.update(title: "Quy mô", text: wSelf.tempSelectMerchantType?.name ?? "")
            if let currentMerchant = wSelf.listener?.currentSelectedMerchant {
                row.cell.textField.isEnabled = false
            } else {
                row.cell.textField.isEnabled = true

            }
            
            row.cell.textField.inputView = wSelf.pickerView
            row.cell.textField.inputAccessoryView = wSelf.toolBar
            
            row.onCellSelection { (c, r) in
                c.textFieldNeedFocus(focus: true)
            }
            
            row.onChange { row in
                wSelf.validate(row: row)
            }
            
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
                
            }
        })
        
        UIView.performWithoutAnimation {
            self.form += [section1]
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
            wSelf.listener?.backToMainMerchant()
        }).disposed(by: disposeBag)
    }
    
    func setupRX() {
        self.listener?.listMerchantAttributes.observeOn(MainScheduler.asyncInstance).bind(onNext: { [weak self] (listMerchant) in
            guard let me = self else { return }
            me.listAttributeIdentifier.removeAll()
            me.form.removeAll()
            
            me.generateHeaderSection()
            var index = 1
            var isRequired = false
            for merchant in listMerchant {
                let section =  me.generateAttributeSection(attribute: merchant, index: index)
                isRequired = merchant.elements?.reduce(isRequired, {
                    $0 || ($1.isRequired ?? false)
                }) ?? false
                UIView.performWithoutAnimation {
                    me.form += [section]
                }
                index += 1
            }
            me.saveButton.isHidden = false
            me.saveButton.isEnabled = !isRequired
        }).disposed(by: disposeBag)
        
        self.listener?.selectedImage.bind(onNext: { [weak self] (image) in
            guard let me = self else { return }
            me.addBannerCell(image: image)
            
        }).disposed(by: disposeBag)
        
        self.saveButton.rx.tap.bind(onNext: weakify { wSelf in
            wSelf.submitData()
        }).disposed(by: disposeBag)
        
        self.listener?.listMerchantAttributesData.observeOn(MainScheduler.asyncInstance).bind(onNext: {[weak self] listData in
            guard let me = self else { return }
            
            me.updateNameCell()
            for attributeData in listData {
                me.updateAttributeData(data: attributeData)
            }
        }).disposed(by: disposeBag)
        
        showLoading(use: self.listener?.eLoadingObser)
        
        self.listener?.listMerchantType.bind(to: pickerView.rx.itemTitles) { _, item in
            return item.name ?? ""
        }.disposed(by: disposeBag)
        
        self.listener?.listMerchantType.bind(onNext: {[weak self] (listMerchant) in
            guard let currentSelect = self?.listener?.currentSelectedMerchant else {
                return
            }
            
            self?.tempSelectMerchantType = listMerchant.first(where: { $0.code == currentSelect.typeCode})
        }).disposed(by: disposeBag)
        
        pickerView.rx.modelSelected(MerchantType.self)
        .subscribe(onNext: {[weak self] models in
            guard let wSelf = self else {return}
            let merchantType = models.first
            if merchantType?.code != wSelf.tempSelectMerchantType?.code {
                wSelf.tempSelectMerchantType = merchantType
            }
        })
        .disposed(by: disposeBag)
        
        self.listener?.errorObserable.observeOn(MainScheduler.asyncInstance).bind(onNext: { [weak self](err) in
            AlertVC.showError(for: self, message: err.getMsg())
        }).disposed(by: disposeBag)
    }
    
    func validate(row: BaseRow) {
        let errors = row.validationErrors
        
        if !errors.isEmpty {
            saveButton.isEnabled = false
        } else {
            let enable = form.validate().isEmpty
            saveButton.isEnabled = enable
        }
        
        if saveButton.isEnabled {
            saveButton.backgroundColor = UIColor(red: 239/255, green: 82/255, blue: 34/255, alpha: 1.0)
        } else {
            saveButton.backgroundColor = #colorLiteral(red: 0.7529411765, green: 0.7764705882, blue: 0.8, alpha: 1)
        }
        
        
    }
    
    func addBannerCell(image: UploadedImage) {
        guard let callback = self.selectImageCallback else {
            return
        }
        
        callback(image)
    }
    
    func showActionSheet(type: AddImageType) {
        let actionsheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionsheet.addAction(UIAlertAction(title: "Take a Photo", style: .default, handler: { (action) -> Void in
            self.listener?.choosePhoto(type: .camera, imageType: type)
        }))
        actionsheet.addAction(UIAlertAction(title: "Choose Exisiting Photo", style: .default, handler: { (action) -> Void in
            self.listener?.choosePhoto(type: .photoLibrary, imageType: type)
        }))
        actionsheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
        }))
        self.present(actionsheet, animated: true, completion: nil)
    }
    
    
    func generateAttributeSection(attribute: MerchantAttribute, index: Int) -> Section {
        let section = Section("") { (s) in
            s.tag = attribute.code!
        }
        
        // header title
        section <<< RowDetailGeneric<MerchantAttributeTitleCell>.init(AddMerchantCellType.sectionTitle.rawValue, { (row) in
            row.cell.update(title: "\(index). \(attribute.label!)")
        })
        
        
        if let listElement = attribute.elements?.groupBy(\.type).sorted(by: { (m1, m2) -> Bool in
            let s1 = m1.value.first?.sortOrder ?? 9999
            let s2 = m2.value.first?.sortOrder ?? 9999
            return s1 < s2
        })
        {
            for elementDict in listElement {
                guard let type = elementDict.key, elementDict.value.count > 0 else {
                    fatalError("Implement this type")
                }
                
                switch type {
                case .TEXT:
                    for element in elementDict.value {
                        let cellTitle = "\(attribute.code!)+\(element.code!)"
                        self.listAttributeIdentifier.append(MerchantIdentifierCellType(identifer: cellTitle, type: type))
                        section <<< RowInputDelivery<MerchantFormRequireInputCell>.init(cellTitle, { (row) in
                            let title = element.label ?? ""
                            row.cell.update(title: title, placeHolder: "")
                            if element.isRequired ?? false {
                                row.add(rule: RuleRequired(msg: "\(title) không được để trống" ))
                                row.onChange({ [weak self] _ in
                                    self?.validate(row: row)
                                })
                                row.onRowValidationChanged {[weak self]  _, _ in
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
                                    
                                    row.cell.updateValidateState(state: row.isValid ? 1 : 0)
                                    self?.validate(row: row)
                                }
                            }
                        })
                    }
                case .IMAGE:
                    guard elementDict.value.count >= 2 else {
                        fatalError("Wrong config")
                    }
                    let leftElement = elementDict.value.first!
                    let rightElement = elementDict.value.last!
                    
                    let cellTitle = "\(attribute.code!)+\((leftElement.code!))+\(rightElement.code!)"
                    self.listAttributeIdentifier.append(MerchantIdentifierCellType(identifer: cellTitle, type: type))
                    section <<< RowDetailGeneric<MerchantDoubleImageInputCell>.init(cellTitle, { (row) in
                        row.cell.updateView(leftTitle: leftElement.label, rightTitle: rightElement.label)
                        row.value = MerchantDoubleImage()
                        row.cell.updateCallback(left: { [weak self] in
                            self?.selectImageCallback = row.cell.leftCallbackHandler
                            self?.showActionSheet(type: .banner)
                            }, right: { [weak self] in
                                self?.selectImageCallback = row.cell.rightCallbackHandler
                                self?.showActionSheet(type: .banner)
                        })
                        
                        if leftElement.isRequired ?? false {
                            row.add(ruleSet: RulesMerchantDoubleImage.rules())
                            row.onRowValidationChanged { _, _ in
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
                            }
                        }
                    })
                    
                case .IMAGE_LIST:
                    guard let element = elementDict.value.first else { break }
                    let cellTitle = "\(attribute.code!)+\(element.code!)"
                    self.listAttributeIdentifier.append(MerchantIdentifierCellType(identifer: cellTitle, type: type))
                    
                    section <<< RowDetailGeneric<MerchantMultipleImageInputCell>.init(cellTitle, { (row) in
                        row.cell.updateView(title: element.label)
                        row.value = []
                        row.cell.updateCallback({ [weak self] in
                            self?.selectImageCallback = row.cell.callbackHandler
                            self?.showActionSheet(type: .banner)
                        })
                        if element.isRequired ?? false {
                            row.add(ruleSet: RulesMerchantMultipleImage.rules())                            
                            row.onRowValidationChanged { _, _ in
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
                            }
                        }
                    })
                case .TEXT_AREA, .MULTI_SELECT, .CATEGORY, .DOUBLE, .BOOLEAN, .DATE:
                    break
                case .SELECT:
                    break
                }
            }
        }
        return section
    }
    
    func submitData() {
        var command: MerchantActionCommand = .create
        var merchant = MerchantModifyData()
        let merchantId: Int? = self.listener?.currentSelectedMerchant?.basic?.id
        
        
        if let _ = self.listener?.currentSelectedMerchant {
            command = .update
        } else {
            command = .create
        }
        
        var listAttribute: [Observable<MerchantAttributeData>] = []
        
        for att in self.listAttributeIdentifier {
            var listCode = att.identifer.split("+")
            listCode.removeFirst()
            var index = 0
            for code in listCode {
                switch att.type {
                case .TEXT:
                    var m = MerchantAttributeData()
                    m.code = code
                    let value = (self.form.rowBy(tag: att.identifer) as? RowInputDelivery<MerchantFormRequireInputCell>)?.value ?? ""
                    m.data = MerchantAttributeElementData(value: value)
                    listAttribute.append(Observable<MerchantAttributeData>.just(m))
                case .IMAGE:
                    guard let uploadParams = (self.form.rowBy(tag: att.identifer) as? RowDetailGeneric<MerchantDoubleImageInputCell>)?.cell.getUploadImage(index: index) else { break }
                    listAttribute.append(self.listener!.uploadMerchantAttributes(code: code, listImage: [uploadParams]))
                case .IMAGE_LIST:
                    guard let uploadParam = (self.form.rowBy(tag: att.identifer) as? RowDetailGeneric<MerchantMultipleImageInputCell>)?.cell.getImageData().compactMap({ $0 }) else { break }
                    if uploadParam.count > 0 {
                        listAttribute.append(self.listener!.uploadMerchantAttributes(code: code, listImage: uploadParam))
                    }
                case .TEXT_AREA:
                    break
                case .MULTI_SELECT, .CATEGORY, .DOUBLE, .BOOLEAN, .DATE:
                    break
                case .SELECT:
                    break
                }
                index += 1
            }
        }
        
        let uploadParams = (self.form.rowBy(tag: AddMerchantCellType.name.rawValue) as? RowDetailGeneric<MerchantAddNameFormCell>)?.cell.getImage()
        listAttribute.append(FileStorageUploadManager.instance.uploadMerchantAttributes(code: Config.UploadAvatar, listImage: [uploadParams].compactMap({$0})))
        
        
        Observable.zip(listAttribute) { [weak self]  (listAtt) -> MerchantModifyData in
            merchant.name = (self?.form.rowBy(tag: AddMerchantCellType.name.rawValue) as? RowDetailGeneric<MerchantAddNameFormCell>)?.value?.name ?? ""
            merchant.ownerId = UserManager.instance.userId
            switch command {
            case .create:
                merchant.categoryId = (self?.listener?.currentCategory?.id)!
            case .update:
                merchant.categoryId = (self?.listener?.currentSelectedMerchant?.categoryId)!
            }
            
            merchant.typeCode = self?.tempSelectMerchantType?.code ?? ""
            merchant.phoneNumber = UserManager.instance.info?.phone
            merchant.avatarUrl = listAtt.filter({ $0.code == Config.UploadAvatar }).first?.data?.value
            merchant.attributes = listAtt.filter({ $0.code != Config.UploadAvatar })
            return merchant
        }.subscribe { [weak self] (e) in
            guard let me = self else { return }
            switch e {
            case .next(let m):
                do {
                    switch command {
                    case .create:
                        me.listener?.createMerchant(params: try m.toJSON())
                    case .update:
                        guard let merchantId = merchantId else { break }
                        me.listener?.updateMerchant(merchantId: merchantId, params: try m.toJSON())
                    }
                } catch {
                    
                }
            case .error(_):
                break
            case .completed:
                printDebug("Completed!!!")
                
            }
        }.disposed(by: disposeBag)
        
    }
    
    func updateAttributeData(data: MerchantAttributeData) {
        guard let code = data.code else {
            fatalError("error data")
        }
        
        if let cellIdentifier = self.listAttributeIdentifier.filter({
            $0.identifer.contains(code)
        }).first {
            switch cellIdentifier.type {
            case .TEXT:
                if let row = self.form.rowBy(tag: cellIdentifier.identifer) as? RowInputDelivery<MerchantFormRequireInputCell> {
                    row.cell.setText(data.data?.value ?? "")
                }
            case .IMAGE_LIST:
                if let row = self.form.rowBy(tag: cellIdentifier.identifer) as? RowDetailGeneric<MerchantMultipleImageInputCell> {
                    let dataList = data.data?.value?.split(";") ?? []
                    let dataValue = dataList.compactMap({$0}).map({(value) -> UploadedImage in
                        var uploadImage = UploadedImage()
                        uploadImage.imageURL = value
                        return uploadImage
                    })
                    row.cell.addValue(items: dataValue)
                }
            case .IMAGE:
                if let row = self.form.rowBy(tag: cellIdentifier.identifer) as? RowDetailGeneric<MerchantDoubleImageInputCell> {
                    let listAttributeName = cellIdentifier.identifer.split("+")
                    var index = 0
                    for attributeName in listAttributeName {
                        if data.code == attributeName {
                            if index == 1 {
                                var uploadImage = UploadedImage()
                                uploadImage.imageURL = data.data?.value
                                row.cell.setLeftImage(image: uploadImage)
                            } else {
                                var uploadImage = UploadedImage()
                                uploadImage.imageURL = data.data?.value
                                row.cell.setRightImage(image: uploadImage)
                            }
                        }
                        index += 1
                    }
                }
                break
            case .TEXT_AREA, .MULTI_SELECT, .CATEGORY, .DOUBLE, .BOOLEAN, .DATE:
                break
            case .SELECT:
                break
            }
            printDebug(cellIdentifier)
        }
    }
    
    func updateNameCell() {
        guard let currentSelectedMerchant = self.listener?.currentSelectedMerchant else {
            return
        }
        
        if let row  = self.form.rowBy(tag: AddMerchantCellType.name.rawValue) as? RowDetailGeneric<MerchantAddNameFormCell> {
            
            var uploadImage = UploadedImage()
            uploadImage.imageURL = currentSelectedMerchant.basic?.avatarUrl
            
            let value = MerchantAddNameValue(image: uploadImage, name: currentSelectedMerchant.basic?.name)
            row.value = value
            
            row.cell.setText(currentSelectedMerchant.basic?.name)
            row.cell.setImage(image: uploadImage)
        }
        
    }
    
    @objc func donePicker() {
        let cell = self.form.rowBy(tag: AddMerchantCellType.scope.rawValue)
        if let row = cell as? RowInputDelivery<MerchantSelectionFormCell> {
            row.cell.textField.resignFirstResponder()
            
            if row.value != self.tempSelectMerchantType?.name {
                self.listener?.getListMerchantAttribute(code: self.tempSelectMerchantType?.code)
            }
            row.cell.setText(text: self.tempSelectMerchantType?.name)
        }
    }
    
    @objc func cancelPicker() {
        let cell = self.form.rowBy(tag: AddMerchantCellType.scope.rawValue)
        if let row = cell as? RowInputDelivery<MerchantSelectionFormCell> {
            row.cell.textField.resignFirstResponder()
        }
    }
    
}

