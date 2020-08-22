//  File name   : AddProductVC.swift
//
//  Author      : khoi tran
//  Created date: 11/7/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import Eureka
import FwiCore
import FwiCoreRX
import RxSwift
import RxCocoa

protocol AddProductPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    
    var selectedCategoryFlow: Observable<(String, MerchantCategory)> { get }
    var errorObserable: Observable<MerchantState>{ get }
    var eLoadingObser: Observable<(Bool, Double)> { get }
    var listCategoryAttributes: Observable<[MerchantAttributeElement]> { get }
    var selectedImage: Observable<UploadedImage> { get }
    var productData: Observable<ProductModifyData> { get }
    
    func routeToAddProductType()
    func addProductMoveBack()
    
    func choosePhoto(type: UIImagePickerController.SourceType, imageType: AddImageType)
    func uploadMerchantAttributes(code: String, listImage: [UploadedImage]) -> Observable<MerchantAttributeData>
    func createProduct(attributes: [MerchantAttributeData])
    func requestPathCategory(id: Int?)

}

enum AddProductCellType: String {
    case name = "Name"
    case price = "Price"
    case productType = "ProductType"
    case openTime = "OpenTime"
    case description = "Description"
    case image = "Image"
    //    case
}

final class AddProductVC: FormViewController, AddProductPresentable, AddProductViewControllable, LoadingAnimateProtocol, DisposableProtocol {
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: AddProductPresentableListener?
    
    // MARK: View's lifecycle
    
    override func loadView() {
        super.loadView()
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        tableView.separatorColor = .clear
        //        tableView.sec
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }
    
    /// Class's private properties.
    var saveButton: UIButton = UIButton(frame: .zero)
    lazy var disposeBag = DisposeBag()
    var selectImageCallback: BlockAction<UploadedImage>?
    var listAttributeIdentifier:[MerchantIdentifierCellType] = []
    var currentAttributeSelectType: ProductAttributeVisibility?
    
    override func tableView(_: UITableView, viewForFooterInSection _: Int) -> UIView? { return nil }
    
    override func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat { return 0.1 }
    
    override func tableView(_: UITableView, heightForFooterInSection s: Int) -> CGFloat { return 0.1 }
    
    override func tableView(_: UITableView, viewForHeaderInSection _: Int) -> UIView? { return nil }
    
    private lazy var pickerView: UIDatePicker = UIDatePicker()
    private lazy var toolBar = UIToolbar()
    
    private var datePickerRow = ""
}



// MARK: View's event handlers
extension AddProductVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension AddProductVC {
}

// MARK: Class's private methods
private extension AddProductVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        self.setupNavigation()
        
        self.title = "Thêm món mới"
        
        tableView >>> view >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        
        let tableFooterView = UIView.create {
            $0.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 106)
        }
        
        saveButton >>> tableFooterView >>> {
            $0.backgroundColor = UIColor(red: 239/255, green: 82/255, blue: 34/255, alpha: 1.0)
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
        
        pickerView = UIDatePicker(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 180))
        pickerView.datePickerMode = .date
        pickerView.backgroundColor = .white
        
        
        
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: Text.done.localizedText, style: UIBarButtonItem.Style.done, target: self, action: #selector(self.donePicker))
        doneButton.tintColor = Color.orange
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
    }
    
    
    func generateAttributeSection(elements: [MerchantAttributeElement], index: Int) -> Section {
        let section = Section("") { (s) in
            s.tag = "Section"
        }
        
        let listElement = elements.groupBy(\.type).sorted { (m1, m2) -> Bool in
            let s1 = m1.value.first?.sortOrder ?? 9999
            let s2 = m2.value.first?.sortOrder ?? 9999
            return s1 < s2
        }
        
        for elementDict in listElement {
            guard let type = elementDict.key, elementDict.value.count > 0 else {
                fatalError("Implement this type")
            }
            
            switch type {
            case .TEXT:
                for row in self.generateTextRow(elementDict: elementDict) {
                    section <<< row
                }
            case .DOUBLE:
                for row in self.generateTextRow(elementDict: elementDict) {
                    section <<< row
                }
            case .IMAGE:
                if let row = self.generateImageRow(elementDict: elementDict) {
                    section <<< row
                }
            case .IMAGE_LIST:
                if let row = self.generateImageListRow(elementDict: elementDict){
                    section <<< row
                }
            case .TEXT_AREA:
                if let row = self.generateTextAreaRow(elementDict: elementDict) {
                    section <<< row
                }
            case .MULTI_SELECT:
                if let row = self.generateMultiSelectRow(elementDict: elementDict) {
                    section <<< row
                }
            case .CATEGORY:
                if let row = self.generateCategoryRow(elementDict: elementDict) {
                    section <<< row
                }
            case .BOOLEAN:
                if let row = self.generateBooleanRow(elementDict: elementDict) {
                    section <<< row
                }
                break
            case .DATE:
                for row in self.generateDateRow(elementDict: elementDict) {
                    section <<< row
                }
                break
            case .SELECT:
                if let row = self.generateSingleSelectRow(elementDict: elementDict) {
                    section <<< row
                }
            }
        }
        
        
        
        return section
    }
    
    func generateBooleanRow(elementDict: (key: MerchantAttributeElementType?, value: [MerchantAttributeElement])) -> RowDetailGeneric<MerchantSwitchViewCell>? {
        guard let type = elementDict.key, let element = elementDict.value.first else {
            fatalError("Error")
        }
        let cellTitle = "\(element.code!)"
        self.listAttributeIdentifier.append(MerchantIdentifierCellType(identifer: cellTitle, type: type))
        return RowDetailGeneric<MerchantSwitchViewCell>.init(cellTitle, { (row) in
            row.cell.update(title: element.label ?? "")
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
            
        })
    }
    
        
    func generateTextRow(elementDict: (key: MerchantAttributeElementType?, value: [MerchantAttributeElement])) -> [RowInputDelivery<MerchantFormRequireInputCell>] {
        guard let type = elementDict.key, elementDict.value.count > 0 else {
            fatalError("Implement this type")
        }
        
        return elementDict.value.map { (element) -> RowInputDelivery<MerchantFormRequireInputCell> in
            let cellTitle = "\(element.code!)"
            self.listAttributeIdentifier.append(MerchantIdentifierCellType(identifer: cellTitle, type: type))
            
            return RowInputDelivery<MerchantFormRequireInputCell>.init(cellTitle, { (row) in
                let title = element.label ?? ""
                row.cell.textField.keyboardType = type.keyboardType
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
        
    }
    
    func generateDateRow(elementDict: (key: MerchantAttributeElementType?, value: [MerchantAttributeElement])) -> [RowInputDelivery<MerchantFormRequireInputCell>] {
        guard let type = elementDict.key, elementDict.value.count > 0 else {
            fatalError("Implement this type")
        }
        
        return elementDict.value.map { (element) -> RowInputDelivery<MerchantFormRequireInputCell> in
            let cellTitle = "\(element.code!)"
            self.listAttributeIdentifier.append(MerchantIdentifierCellType(identifer: cellTitle, type: type))
            
            return RowInputDelivery<MerchantFormRequireInputCell>.init(cellTitle, {[weak self] (row) in
                guard let wSelf = self else { return }
                let title = element.label ?? ""
                row.cell.update(title: title, placeHolder: "")
                
                row.cell.textField.inputView = wSelf.pickerView
                row.cell.textField.inputAccessoryView = wSelf.toolBar

                row.cell.textField.isEnabled = false
                
                
                row.onCellSelection { (c, r) in
                    c.textField.isEnabled = true
                    c.textField.becomeFirstResponder()
                    wSelf.datePickerRow = cellTitle
                }
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
        
    }
    
    func generateImageRow(elementDict: (key: MerchantAttributeElementType?, value: [MerchantAttributeElement])) -> RowDetailGeneric<MerchantDoubleImageInputCell>? {
        guard let type = elementDict.key, elementDict.value.count >= 2 else {
            fatalError("Wrong config")
        }
        let leftElement = elementDict.value.first!
        let rightElement = elementDict.value.last!
        
        let cellTitle = "\((leftElement.code!))+\(rightElement.code!)"
        self.listAttributeIdentifier.append(MerchantIdentifierCellType(identifer: cellTitle, type: type))
        return RowDetailGeneric<MerchantDoubleImageInputCell>.init(cellTitle, { (row) in
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
                row.onChange({ _ in
                })
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
    }
    
    func generateImageListRow(elementDict: (key: MerchantAttributeElementType?, value: [MerchantAttributeElement])) -> RowDetailGeneric<MerchantMultipleImageInputCell>? {
        guard let type = elementDict.key, let element = elementDict.value.first else {
            fatalError("Error")
        }
        let cellTitle = "\(element.code!)"
        self.listAttributeIdentifier.append(MerchantIdentifierCellType(identifer: cellTitle, type: type))
        
        return RowDetailGeneric<MerchantMultipleImageInputCell>.init(cellTitle, { (row) in
            row.cell.updateView(title: element.label)
            row.value = []
            row.cell.updateCallback({ [weak self] in
                self?.selectImageCallback = row.cell.callbackHandler
                self?.showActionSheet(type: .banner)
            })
            if element.isRequired ?? false {
                row.add(ruleSet: RulesMerchantMultipleImage.rules())
                row.onChange({ _ in
                })
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
    }
    
    func generateTextAreaRow(elementDict: (key: MerchantAttributeElementType?, value: [MerchantAttributeElement])) -> RowDetailGeneric<MerchantTextViewCell>? {
        guard let type = elementDict.key, let element = elementDict.value.first else {
            fatalError("Error")
        }
        let cellTitle = "\(element.code!)"
        self.listAttributeIdentifier.append(MerchantIdentifierCellType(identifer: cellTitle, type: type))
        return RowDetailGeneric<MerchantTextViewCell>.init(cellTitle, { (row) in
            row.cell.update(title: element.label ?? "")
            
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
    
    
    func generateMultiSelectRow(elementDict: (key: MerchantAttributeElementType?, value: [MerchantAttributeElement])) -> RowDetailGeneric<MerchantCheckBoxCell>? {
        
        guard let type = elementDict.key, let element = elementDict.value.first else {
            fatalError("Error")
        }
        
        guard let values = element.values else {
            fatalError("Value Error")
        }
        let cellTitle = "\(element.code!)"
        self.listAttributeIdentifier.append(MerchantIdentifierCellType(identifer: cellTitle, type: type))
        
        
        return RowDetailGeneric<MerchantCheckBoxCell>.init(cellTitle, { (row) in
            row.cell.update(title: element.label ?? "")
            //            row.add(rule: RuleRequired(msg: Text.categoriesNotEmpty.localizedText))
            row.cell.setupData(items: values)
            row.onChange({ [weak self](row) in
                //                self?.validate(row: row)
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
    
    func generateCategoryRow(elementDict: (key: MerchantAttributeElementType?, value: [MerchantAttributeElement])) -> RowInputDelivery<MerchantSelectionFormCell>? {
        
        guard let type = elementDict.key, let element = elementDict.value.first else {
            fatalError("Error")
        }
        
        let cellTitle = "\(element.code!)"
        self.listAttributeIdentifier.append(MerchantIdentifierCellType(identifer: cellTitle, type: type))
        
        return RowInputDelivery<MerchantSelectionFormCell>.init(cellTitle, { (row) in
            row.cell.update(title: element.label ?? "", placeHolder: "")
            //            row.add(rule: RuleRequired(msg: Text.categoriesNotEmpty.localizedText))
            row.onChange({ [weak self](row) in
                //                self?.validate(row: row)
            })
            row.onCellSelection({ [weak self] (cell, row) in
                guard let me = self else { return }
                me.listener?.routeToAddProductType()
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
    
    func generateSingleSelectRow(elementDict: (key: MerchantAttributeElementType?, value: [MerchantAttributeElement])) -> RowInputDelivery<MerchantSelectionFormCell>? {
        
        guard let type = elementDict.key, let element = elementDict.value.first else {
            fatalError("Error")
        }
        
        let cellTitle = "\(element.code!)"
        self.listAttributeIdentifier.append(MerchantIdentifierCellType(identifer: cellTitle, type: type))
        
        return RowInputDelivery<MerchantSelectionFormCell>.init(cellTitle, { (row) in
            row.cell.update(title: element.label ?? "", placeHolder: "")
            row.onChange({ [weak self](row) in
            })
            row.onCellSelection({ [weak self] (cell, row) in
                guard let me = self else { return }
                me.showLeafCategoryView()
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
    
    func validate(row: BaseRow) {
        
    }
    
    private func setupRX() {
        self.listener?.listCategoryAttributes.bind(onNext: { [weak self] (lisMerchantElement) in
            guard let me = self else { return }
            me.listAttributeIdentifier.removeAll()
            let section =  me.generateAttributeSection(elements: lisMerchantElement, index: 0)
            
            UIView.performWithoutAnimation {
                me.form += [section]
            }
            
            me.saveButton.isHidden = false
        }).disposed(by: disposeBag)
        
        self.listener?.selectedCategoryFlow.bind(onNext: { [weak self] (text, category) in
            guard let me = self else { return }
            
            guard let identifier = me.listAttributeIdentifier.filter({ $0.type == .CATEGORY }).first else {
                return
            }
            
            if let row = me.form.rowBy(tag: identifier.identifer) as? RowInputDelivery<MerchantSelectionFormCell>, let id = category.id {
                row.cell.setText(text: text, updateValue: false)
                row.value = "\(id)"
            }
        }).disposed(by: disposeBag)
        
        showLoading(use: self.listener?.eLoadingObser)
        
        self.listener?.selectedImage.bind(onNext: { [weak self] (image) in
            guard let me = self else { return }
            me.addBannerCell(image: image)
            
        }).disposed(by: disposeBag)
        
        self.saveButton.rx.tap.bind(onNext: weakify { wSelf in
            wSelf.submitData()
        }).disposed(by: disposeBag)
        
        self.listener?.productData.bind(onNext: {[weak self] (productData) in
            guard let me = self else { return }
            guard let attributes = productData.attributes else { return }
            
            
            for attribute in attributes {
                me.bindData(data: attribute)
            }
        }).disposed(by: disposeBag)
        
        self.listener?.errorObserable.observeOn(MainScheduler.asyncInstance).bind(onNext: { [weak self](err) in
            AlertVC.showError(for: self, message: err.getMsg())
        }).disposed(by: disposeBag)
    }
    
    func bindData(data: MerchantAttributeData) {
        guard let code = data.code else {
            fatalError("error data")
        }
        
        if let cellIdentifier = self.listAttributeIdentifier.filter({
            $0.identifer.contains(code)
        }).first {
            switch cellIdentifier.type {
            case .TEXT:
                if let row = self.form.rowBy(tag: cellIdentifier.identifer) as? RowInputDelivery<MerchantFormRequireInputCell> {
                    row.cell.setText(data.data?.value)
                }
            case .DOUBLE:
                if let row = self.form.rowBy(tag: cellIdentifier.identifer) as? RowInputDelivery<MerchantFormRequireInputCell>, let value = data.data?.value {
                    let doubleValue = Double(string: value)!
                    row.cell.setText( "\(doubleValue.roundPrice())" )
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
            case .TEXT_AREA:
                if let row = self.form.rowBy(tag: cellIdentifier.identifer) as? RowDetailGeneric<MerchantTextViewCell> {
                    row.cell.setText(text: data.data?.value ?? "")
                }
            case .CATEGORY:
                if let categoryId = Int(data.data?.value ?? "") {
                    self.listener?.requestPathCategory(id: categoryId)
                }
                break
            case .MULTI_SELECT:
                if let row = self.form.rowBy(tag: cellIdentifier.identifer) as? RowDetailGeneric<MerchantCheckBoxCell> {
                    row.cell.setSelectedValue(value: data.data?.value ?? "")
                }
            case .BOOLEAN:
                if let row = self.form.rowBy(tag: cellIdentifier.identifer) as? RowDetailGeneric<MerchantSwitchViewCell> {
                    row.value = (data.data?.value ?? "0") == "0" ? false : true
                }
            case .DATE:
                if let row = self.form.rowBy(tag: cellIdentifier.identifer) as? RowInputDelivery<MerchantFormRequireInputCell> {
                    row.cell.setText(data.data?.value)
                }
                
            case .SELECT:
                if let row = self.form.rowBy(tag: cellIdentifier.identifer) as? RowInputDelivery<MerchantSelectionFormCell> {
                    if let attId = ProductAttributeVisibilityEnum.init(rawValue: Int(data.data?.value ?? "") ?? 0) {
                        let productAttributeVisibility = ProductAttributeVisibility(name: attId.stringValue, id: attId.rawValue)
                        self.currentAttributeSelectType = productAttributeVisibility
                        row.cell.setText(text: productAttributeVisibility.name)
                    }
                    
                }
                break
            }
            printDebug(cellIdentifier)
        }
    }
    
    func addBannerCell(image: UploadedImage) {
        guard let callback = self.selectImageCallback else {
            return
        }
        
        callback(image)
    }
    
    func submitData() {
        var listAttribute: [Observable<MerchantAttributeData>] = []
        
        for att in self.listAttributeIdentifier {
            let listCode = att.identifer.split("+")
            var index = 0
            for code in listCode {
                switch att.type {
                case .TEXT:
                    var m = MerchantAttributeData()
                    m.code = code
                    let value = (self.form.rowBy(tag: att.identifer) as? RowInputDelivery<MerchantFormRequireInputCell>)?.value ?? ""
                    let data = MerchantAttributeElementData(value: value)
                    guard data.valid else { break }
                    m.data = data
                    listAttribute.append(Observable<MerchantAttributeData>.just(m))
                case .DOUBLE:
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
                    var m = MerchantAttributeData()
                    m.code = code
                    let value = (self.form.rowBy(tag: att.identifer) as? RowDetailGeneric<MerchantTextViewCell>)?.cell.getText()
                    let data = MerchantAttributeElementData(value: value ?? "")
                    guard data.valid else { break }
                    m.data = data
                    listAttribute.append(Observable<MerchantAttributeData>.just(m))
                    break
                case .MULTI_SELECT:
                    var m = MerchantAttributeData()
                    m.code = code
                    let value = (self.form.rowBy(tag: att.identifer) as? RowDetailGeneric<MerchantCheckBoxCell>)?.cell.getSelectedValue()
                    let data = MerchantAttributeElementData(value: value ?? "")
                    guard data.valid else { break }
                    m.data = data
                    listAttribute.append(Observable<MerchantAttributeData>.just(m))
                case .CATEGORY:
                    var m = MerchantAttributeData()
                    m.code = code
                    let value = (self.form.rowBy(tag: att.identifer) as? RowInputDelivery<MerchantSelectionFormCell>)?.value
                    let data = MerchantAttributeElementData(value: value ?? "")
                    guard data.valid else { break }
                    m.data = data
                    listAttribute.append(Observable<MerchantAttributeData>.just(m))
                case .BOOLEAN:
                    var m = MerchantAttributeData()
                    m.code = code
                    let value = (self.form.rowBy(tag: att.identifer) as? RowDetailGeneric<MerchantSwitchViewCell>)?.cell.getValue()
                    m.data = MerchantAttributeElementData(value: (value ?? false) ? "1" : "0")
                    listAttribute.append(Observable<MerchantAttributeData>.just(m))
                    
                case .DATE:
                    var m = MerchantAttributeData()
                    m.code = code
                    let value = (self.form.rowBy(tag: att.identifer) as? RowInputDelivery<MerchantFormRequireInputCell>)?.value ?? ""
                    let data = MerchantAttributeElementData(value: value)
                    guard data.valid else { break }
                    m.data = data
                    listAttribute.append(Observable<MerchantAttributeData>.just(m))
                    break
                case .SELECT:
                    if let attId = currentAttributeSelectType?.id {
                        var m = MerchantAttributeData()
                        m.code = code
                        m.data = MerchantAttributeElementData(value: "\(attId)")
                        listAttribute.append(Observable<MerchantAttributeData>.just(m))
                    }
                }
                
                index += 1
            }
        }
        
        Observable.zip(listAttribute).subscribe { [weak self] (e) in
            guard let me = self else { return }
            switch e {
            case .next(let m):
                me.listener?.createProduct(attributes: m)
                printDebug(m)
            case .error(let e):
                printDebug(e.localizedDescription)
                break
            case .completed:
                printDebug("Completed!!!")
                
            }
        }.disposed(by: disposeBag)
        
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
            wSelf.listener?.addProductMoveBack()
        }).disposed(by: disposeBag)
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
    
    func showLeafCategoryView() {
        
        let listCategory = ProductAttributeVisibilityEnum.allCases.map {
            ProductAttributeVisibility(name: $0.stringValue, id: $0.rawValue)
        }
        
        let vc: CategoryViewController<ProductAttributeVisibility> =  CategoryViewController<ProductAttributeVisibility>()
        
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        vc.allowsMultipleSelection = false
        vc.listCategory = listCategory
        if let currentAttributeSelectType = self.currentAttributeSelectType {
            vc.listSelectedCategory = [currentAttributeSelectType]
        }
        //        vc.listSelectedCategory = me.listener?.listSelectedCategory ?? []
        
        
        vc.callback = { [weak self] listCategory in
            guard let me = self else { return }
            guard let listCategory = listCategory else { return }
            me.updateSelectedLeafCategories(listCategory: listCategory)
        }
        self.present(vc, animated: true) {
            
        }
    }
    
    func updateSelectedLeafCategories(listCategory: [ProductAttributeVisibility]) {
        //        self.listener?.updateListSelectedCategory(listSelectedCategory: listCategory)
        guard let identifier = self.listAttributeIdentifier.first(where: { $0.type == .SELECT }) else { return }
        self.currentAttributeSelectType = listCategory.first
        self.updateRow(identifier: identifier, value: listCategory.map({ $0.name! }).joined(separator: ","))
    }
    
    func updateRow(identifier: MerchantIdentifierCellType, value: Any?) {
        switch identifier.type {
        case .SELECT:
            if let row = self.form.rowBy(tag: identifier.identifer) as? RowInputDelivery<MerchantSelectionFormCell> {
                row.cell.setText(value as? String)
            }
        default:
            break
        }
    }
    
    @objc func donePicker() {
        let cell = self.form.rowBy(tag: self.datePickerRow)
        if let row = cell as? RowInputDelivery<MerchantFormRequireInputCell> {
            row.cell.textField.resignFirstResponder()
            let text = pickerView.date.string(from: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
            row.cell.setText(text)
            row.cell.textField.isEnabled = false

        }
    }
    
    @objc func cancelPicker() {
        let cell = self.form.rowBy(tag: self.datePickerRow)
        if let row = cell as? RowInputDelivery<MerchantFormRequireInputCell> {
            row.cell.textField.resignFirstResponder()
            row.cell.textField.isEnabled = false
        }
    }
    
}
