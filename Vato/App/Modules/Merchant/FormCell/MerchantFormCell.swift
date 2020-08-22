//
//  MerchantFormCell.swift
//  Vato
//
//  Created by khoi tran on 10/21/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation
import RxSwift
import Eureka

typealias ValidateCallBack = (Int) -> Void
protocol ValidateProtocol {
    func setValidateCallback(callback: ValidateCallBack?)
    func updateValidateState(state: Int)
}

class MerchantFormRequireInputCell: FillInformationInputTextCell, ValidateProtocol, CallbackSelectProtocol {
    
    private var callback: SelectCallback?
    private (set) lazy var textfieldConentView = UIView.init(frame: .zero)
    private (set) lazy var button = UIButton.init(frame: .zero)
    private (set) lazy var errorImageView = UIImageView(frame: .zero)
    
    private lazy var disposeBag = DisposeBag()
    
   
    override func visualize() {
        selectionStyle = .none
        textLabel?.isHidden = true
        
        lblTitle >>> contentView >>> {
            $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            $0.textColor = UIColor.init(red: 99/255, green: 114/255, blue: 128/255, alpha: 1.0)
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(16)
                make.top.equalTo(16)
                make.height.equalTo(15.0)
            })
        }
        
        let _lblStar = UILabel(frame: .zero)
        _lblStar >>> contentView >>> {
            $0.textColor = Color.orange
            $0.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            $0.text = "*"
            $0.snp.makeConstraints({ (make) in
                make.centerY.equalTo(lblTitle.snp.centerY)
                make.left.equalTo(lblTitle.snp.right).offset(8)
            })
        }
        
        self.lblStar = _lblStar
        
        textfieldConentView >>> contentView >>> {
            $0.backgroundColor = .clear
            $0.borderWidth = 1
            $0.borderColor = UIColor.init(red: 221/255, green: 226/255, blue: 232/255, alpha: 1.0)
            $0.cornerRadius = 8
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(lblTitle.snp.bottom).offset(4)
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.height.equalTo(36)
                make.bottom.equalTo(0)
            })
        }
        
        textField >>> textfieldConentView >>> {
            $0.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            $0.snp.makeConstraints({ (make) in
                make.left.equalToSuperview().offset(12)
                make.right.equalToSuperview()
                make.top.equalToSuperview()
                make.bottom.equalToSuperview()
            })
        }
        
        errorImageView >>> textfieldConentView >>> {
            $0.isHidden = true
            $0.image = UIImage(named: "ic_text_error")
            $0.snp.makeConstraints({ (make) in
                make.centerY.equalToSuperview()
                make.right.equalTo(-8)
                make.width.equalTo(24)
                make.height.equalTo(24)
            })
        }
        
        button >>> textfieldConentView >>> {
            $0.setTitle("", for: .normal)
            $0.isHidden = true
            $0.snp.makeConstraints({ (make) in
                make.right.equalTo(0)
                make.top.equalTo(0)
                make.bottom.equalTo(0)
                make.width.equalTo(32)
            })
        }
        
        super.setupRX()
    }
    
    override func setupRX() {
        super.setupRX()
        
        button.rx.tap.bind { [weak self] _ in
            guard let callback = self?.callback else { return }
            callback(0)
        }.disposed(by: disposeBag)
    }
    func set(callback: SelectCallback?) {
        self.callback = callback
    }
    
    func setValidateCallback(callback: ValidateCallBack?) {
        
    }
    
    func updateValidateState(state: Int) {
        if state == 0 {
            textfieldConentView.borderColor = UIColor(red: 225/255, green: 36/255, blue: 36/255, alpha: 0.4)
            errorImageView.isHidden = false
        } else {
            textfieldConentView.borderColor = UIColor.init(red: 221/255, green: 226/255, blue: 232/255, alpha: 1.0)
            errorImageView.isHidden = true
        }
    }
    
    override func update(title: String?, placeHolder: String) {
        lblTitle.text = title
        textField.placeholder = placeHolder
    }
    
    func enableImage(isHidden: Bool, imageName: String) {
        button.isHidden = isHidden
        button.setImage(UIImage(named: imageName), for: .normal)
    }
        
}

final class MerchantDoubleFormInputCell: Eureka.Cell<[String]>, CellType, UITextFieldDelegate, UpdateDisplayProtocol {
   
    let lblTitle: UILabel
    var lblStar: UILabel?

    private var leftTextfieldConentView = UIView.init(frame: .zero)
    private var rightTextfieldConentView = UIView.init(frame: .zero)
    private var leftTextfield: UITextField
    private var rightTextfield: UITextField
    
    
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        lblTitle = UILabel(frame: .zero)
        leftTextfield = UITextField(frame: .zero)
        rightTextfield = UITextField(frame: .zero)
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
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(16)
                make.top.equalTo(16)
            })
        }
        
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
        
        leftTextfieldConentView >>> contentView >>> {
            $0.backgroundColor = .clear
            $0.borderWidth = 1
            $0.borderColor = UIColor.init(red: 221/255, green: 226/255, blue: 232/255, alpha: 1.0)
            $0.cornerRadius = 8
            $0.snp.makeConstraints({ (make) in
                make.top.equalToSuperview().offset(8)
                make.left.equalTo(16)
                make.width.equalToSuperview().dividedBy(2.0).offset(-24)
                make.height.equalTo(36)
                make.bottom.equalTo(-4)
            })
        }
        
        leftTextfield >>> leftTextfieldConentView >>> {
            $0.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            $0.snp.makeConstraints({ (make) in
                make.left.equalToSuperview().offset(12)
                make.right.equalToSuperview()
                make.top.equalToSuperview()
                make.bottom.equalToSuperview()
            })
        }
        
        rightTextfieldConentView >>> contentView >>> {
            $0.backgroundColor = .clear
            $0.borderWidth = 1
            $0.borderColor = UIColor.init(red: 221/255, green: 226/255, blue: 232/255, alpha: 1.0)
            $0.cornerRadius = 8
            $0.snp.makeConstraints({ (make) in
                make.top.equalToSuperview().offset(8)
                make.right.equalTo(-16)
                make.width.equalToSuperview().dividedBy(2.0).offset(-24)
                make.height.equalTo(36)
                make.bottom.equalTo(-4)
            })
        }
        
        rightTextfield >>> rightTextfieldConentView >>> {
            $0.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            $0.snp.makeConstraints({ (make) in
                make.left.equalToSuperview().offset(12)
                make.right.equalToSuperview()
                make.top.equalToSuperview()
                make.bottom.equalToSuperview()
            })
        }
        
        self.setupRX()
    }
    
    func setupRX() {
        leftTextfield.delegate = self
        leftTextfield.addTarget(self, action: #selector(textChanged(sender:)), for: .valueChanged)
        leftTextfield.addTarget(self, action: #selector(textChanged(sender:)), for: .editingChanged)
        
        rightTextfield.delegate = self
        rightTextfield.addTarget(self, action: #selector(textChanged(sender:)), for: .valueChanged)
        leftTextfield.addTarget(self, action: #selector(textChanged(sender:)), for: .editingChanged)
    }
    
    func update(title: String?, leftPlaceholder: String, rightPlaceholder: String) {
        lblTitle.text = title
        leftTextfield.placeholder = leftPlaceholder
        leftTextfield.keyboardType = .phonePad
        
        rightTextfield.placeholder = rightPlaceholder
        rightTextfield.keyboardType = .phonePad
    }

    @objc func textChanged(sender: UITextField?) {
        
    }
    
    func setupDisplay(item: [String]?) {
        self.leftTextfield.text = item?[0]
        self.rightTextfield.text = item?[1]
    }
    
    func allowInput(isAllowed: Bool) {
        leftTextfield.isEnabled = isAllowed
        rightTextfield.isEnabled = isAllowed
    }
    
    
    
}


class MerchantSelectionFormCell: MerchantFormRequireInputCell {
    
    private (set) lazy var dropDownImageView = UIImageView.init(frame: .zero)

    private lazy var disposeBag = DisposeBag()
    
    
    override func visualize() {
        super.visualize()
        self.textField.isEnabled = false
        
        
        dropDownImageView >>> textfieldConentView >>> {
            $0.contentMode = .scaleAspectFit
            $0.image = UIImage(named: "ic_dropdown")
            $0.snp.makeConstraints({ (make) in
                make.centerY.equalToSuperview()
                make.right.equalToSuperview().offset(-8)
                make.size.equalTo(CGSize(width: 24, height: 24))
            })
        }
        
    }
    
    func update(title: String?, text: String) {
        self.lblTitle.text = title
        self.textField.text = text
        self.row.value = text
    }
    
    func setText(text: String?, updateValue: Bool = true) {
        self.textField.text = text
        if updateValue {
            self.row.value = text
        }

    }
    
    func setInputSource(picker: UIPickerView?) {
        guard let picker = picker else {
            return
        }
        
        self.textField.inputView = picker
    }
    
    func textFieldNeedFocus(focus: Bool) {
        self.textField.becomeFirstResponder()
    }
}


final class MerchantRightSelectionFormCell: MerchantSelectionFormCell {
    private (set) lazy var subTitleLabel = UILabel(frame: .zero)
    
    override func visualize() {
        super.visualize()
        
        subTitleLabel >>> contentView >>> {
            $0.textColor = UIColor(red: 99/255, green: 114/255, blue: 128/255, alpha: 1.0)
            $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            $0.snp.makeConstraints({ (make) in
                make.centerY.equalTo(textfieldConentView.snp.centerY)
                make.left.equalToSuperview().offset(16)
            })
        }
        
        textfieldConentView.snp.updateConstraints { (make) in
            make.left.equalTo(76)
        }
        
    }
    
    func update(title: String?, subtitle: String?, placeholder: String) {
        super.update(title: title, placeHolder: placeholder)
        subTitleLabel.text = subtitle
    }
    
    func updateLblTitleHidden(isHidden: Bool) {
        self.lblTitle.isHidden = isHidden
        
        let height = isHidden ? 0 : 15
        let top = isHidden ? 4 : 16
        self.lblTitle.snp.updateConstraints { (make) in
            make.height.equalTo(height)
            make.top.equalTo(top)
        }
    }
    
    
}

final class MerchantTitleFormCell: Eureka.Cell<String>, CellType, UpdateDisplayProtocol {
    var lblTitle: UILabel
    var lblStar: UILabel?
    
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        lblTitle = UILabel(frame: .zero)
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
        
        contentView.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 0)
        
        lblTitle >>> contentView >>> {
            $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            $0.textColor = UIColor.init(red: 99/255, green: 114/255, blue: 128/255, alpha: 1.0)
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(16)
                make.top.equalTo(16)
                make.bottom.equalTo(-8)
            })
        }
        
        let _lblStar = UILabel(frame: .zero)
        _lblStar >>> contentView >>> {
            $0.textColor = Color.orange
            $0.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            $0.text = "*"
            $0.snp.makeConstraints({ (make) in
                make.centerY.equalTo(lblTitle.snp.centerY)
                make.left.equalTo(lblTitle.snp.right).offset(8)
                make.bottom.equalTo(-4.0)
            })
        }
        
        self.lblStar = _lblStar
    }
    
    func setupRX() {
        
    }
    
    func setupDisplay(item: String?) {
        
    }
    
    func update(title: String) {
        self.lblTitle.text = title
    }
}


final class MerchantChooseImagerFormCell: Eureka.Cell<String>, CellType, UpdateDisplayProtocol, CallbackSelectProtocol {
    
    var addBannerButton = UIButton(frame: .zero)
    private lazy var disposeBag = DisposeBag()

    private var callback: SelectCallback?
    
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
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
        
        addBannerButton >>> contentView >>> {
            $0.tintColor = .white
            $0.setBackgroundImage(UIImage(named: "bg_add_photo"), for: .normal)
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.top.equalTo(4)
                make.bottom.equalTo(-4)
                make.height.equalTo(100)
            })
        }
        
        addBannerButton.rx.tap.bind { [weak self] _ in
            guard let callback = self?.callback else { return }
            callback(0)
        }.disposed(by: disposeBag)
    }
  
    
    func setupRX() {
        
    }
    
    func setupDisplay(item: String?) {
        
    }
    
    func set(callback: SelectCallback?) {
        self.callback = callback
    }
    
}


final class MerchantImageFormCell: Eureka.Cell<UploadedImage>, CellType, UpdateDisplayProtocol {
   
    var bannerImageView = UIImageView(frame: .zero)
    var closeButton: UIButton?
    
    
    private var callback: SelectCallback?
    private lazy var disposeBag = DisposeBag()
    
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
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
        imageView?.isHidden = true
        
        bannerImageView >>> contentView >>> {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.cornerRadius = 8
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.top.equalTo(4)
                make.bottom.equalTo(-4)
            })
        }
        
        let closeButton = UIButton.init(type: .custom)
        closeButton >>> contentView >>> {
            $0.setImage(UIImage(named: "ic_clear_photo"), for: .normal)
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(4)
                make.right.equalTo(-20)
                make.width.equalTo(24)
                make.right.equalTo(24)
            })
        }
        self.closeButton = closeButton
        closeButton.rx.tap.bind { [weak self] _ in
            guard let callback = self?.callback else { return }
            if let value = self?.row.value {
                value.removeStorageImage()
            }
            callback(0)
            }.disposed(by: disposeBag)
    }
    
    
    func setupRX() {
        
    }
    override func setup() {
        super.setup()
        height = { 174 }
    }
    
    func setupDisplay(item: UploadedImage?) {
        bannerImageView.setImage(from: item, placeholder: nil, size: CGSize(width: UIScreen.main.bounds.width-32, height: 174))
    }
    
    
    
    func set(callback: SelectCallback?) {
        self.callback = callback
    }
    
}


final class MerchantButtonFormCell : Eureka.Cell<Bool>, CellType, UpdateDisplayProtocol {
    var button = UIButton(frame: .zero)
    private var callback: SelectCallback?
    private lazy var disposeBag = DisposeBag()
    
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
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
        imageView?.isHidden = true
        
        button >>> contentView >>> {
            $0.backgroundColor = UIColor(red: 239/255, green: 82/255, blue: 34/255, alpha: 1.0)
            $0.cornerRadius = 24
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(16)
                make.bottom.equalTo(-16)
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.height.equalTo(48)
            })
        }
        
        button.rx.tap.bind { [weak self] _ in
            guard let callback = self?.callback else { return }
            callback(0)
        }.disposed(by: disposeBag)
    }
    
    func setupRX() {
        
    }
    
    override func setup() {
        super.setup()
    }
    
    func set(callback: SelectCallback?) {
        self.callback = callback
    }
    
    func setupDisplay(item: Bool?) {
        guard let item = item else {
            return
        }
        button.isEnabled = item
        if item {
            button.backgroundColor = UIColor(red: 239/255, green: 82/255, blue: 34/255, alpha: 1.0)

        } else {
            button.backgroundColor = #colorLiteral(red: 0.7529411765, green: 0.7764705882, blue: 0.8, alpha: 1)
        }
    }
    
    func update(title: String?) {
        button.setTitle(title, for: .normal)
    }
}

struct MerchantAddNameValue: Equatable {
    var image: UploadedImage?
    var name: String?
    
    static func == (lhs: MerchantAddNameValue, rhs: MerchantAddNameValue) -> Bool {
        return lhs.image == rhs.image && lhs.name == rhs.name
    }

}


final class MerchantAddNameFormCell: Eureka.Cell<MerchantAddNameValue>, CellType, UpdateDisplayProtocol, UITextFieldDelegate, AddImageProtocol, ValidateProtocol {
    
    var uploadPhotoButton = UIButton(frame: .zero)
    var textField: UITextField
    var lineView: UIView
    var callback: AddImageCallBack?

    var callbackHandler: BlockAction<UploadedImage?>?

    private lazy var disposeBag = DisposeBag()
    
    
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.textField = UITextField(frame: .zero)
        self.lineView = UIView(frame: .zero)
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        self.callbackHandler = { image in
            
            guard let image = image else {
                return
            }
            
            if let oldSource = self.row.value?.image {
                oldSource.removeStorageImage()
            }
            
            self.row.value?.image = image
            
            self.uploadPhotoButton.kf.setBackgroundImage(with: image.sourceImage, for: .normal)
            self.uploadPhotoButton.setImage(nil, for: .normal)

        }
        visualize()
        setupRX()
    }
   
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func visualize() {
        selectionStyle = .none
        textLabel?.isHidden = true
        imageView?.isHidden = true
        
        uploadPhotoButton >>> contentView >>> {
            $0.setBackgroundImage(UIImage(named: "bg_add_photo_circle"), for: .normal)
            $0.setImage(UIImage(named: "ic_add_photo"), for: .normal)
            $0.setTitle("", for: .normal)
            $0.cornerRadius = 32
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(16)
                make.left.equalTo(16)
                make.bottom.equalTo(0)
                make.size.equalTo(CGSize(width: 64, height: 64))
            })
        }
        
        textField >>> contentView >>> {
            $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            $0.borderStyle = .none
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(uploadPhotoButton.snp.right).offset(16)
                make.right.equalTo(-16)
                make.top.equalTo(uploadPhotoButton.snp.top).offset(20)
                
            })
        }
        
        lineView >>> contentView >>> {
            $0.backgroundColor = UIColor(red: 162/255, green: 171/255, blue: 179/255, alpha: 0.3)
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(uploadPhotoButton.snp.right).offset(16)
                make.height.equalTo(2)
                make.right.equalTo(-16)
                make.top.equalTo(textField.snp.bottom).offset(4)
            })
            
        }
        
    }
    
    func setupRX() {
        textField.delegate = self
        textField.addTarget(self, action: #selector(textChanged(sender:)), for: .valueChanged)
        textField.addTarget(self, action: #selector(textChanged(sender:)), for: .editingChanged)
        
        uploadPhotoButton.rx.tap.bind(onNext: { [weak self] in
            guard let callback = self?.callback else { return }
            callback()
        }).disposed(by: disposeBag)
    }
    
    func setupDisplay(item: MerchantAddNameValue?) {
    }
    
    func update(placeholder: String) {
        textField.placeholder = placeholder
    }
    
    
    func setImageCallback(callback: AddImageCallBack?) {
        self.callback = callback
    }
    
    @objc func textChanged(sender: UITextField?) {
        var newValue = MerchantAddNameValue()
        newValue.name = sender?.text
        newValue.image = row.value?.image
        row.value? = newValue
    }
    
    override func cellResignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }
    
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
    
    func setText(_ text: String?) {
        textField.text = text
        textField.sendActions(for: .valueChanged)
    }
    
    func setImage(image: UploadedImage?) {
        guard let callback = self.callbackHandler else {
            return
        }
        
        callback(image)
    }    
    
    func getImage() -> UploadedImage? {
        return self.row.value?.image
    }
    
    func setValidateCallback(callback: ValidateCallBack?) {
        
    }
    
    func updateValidateState(state: Int) {
        if state == 2 {
            uploadPhotoButton.setBackgroundImage(UIImage(named: "bg_add_photo_circle_error"), for: .normal)
        } else {
            uploadPhotoButton.setBackgroundImage(UIImage(named: "bg_add_photo_circle"), for: .normal)
        }
    }
    
    
}


final class MerchantAttributeTitleCell: Eureka.Cell<String>, CellType, UpdateDisplayProtocol {
    
    var lblTitle: UILabel
    
    var titleContentView = UIView(frame: .zero)

    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.lblTitle = UILabel(frame: .zero)
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
        imageView?.isHidden = true
        
        
        titleContentView >>> contentView >>> {
            $0.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1.0)
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(16)
                make.left.equalTo(0)
                make.bottom.equalTo(0)
                make.right.equalTo(0)
                make.height.equalTo(40)
            })
        }
        
        lblTitle >>> titleContentView >>> {
            $0.font = UIFont.systemFont(ofSize: 14.0, weight: .medium)
            $0.textColor = UIColor(red: 99/255, green: 118/255, blue: 128/255, alpha: 1.0)
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(14)
                make.left.equalTo(16)
                make.bottom.equalTo(0)
            })
        }
        
        UIView(frame: .zero) >>> titleContentView >>> {
            $0.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
            $0.snp.makeConstraints({ (make) in
                make.left.equalToSuperview()
                make.right.equalToSuperview()
                make.top.equalToSuperview()
                make.height.equalTo(0.5)
            })
        }
        
        UIView(frame: .zero) >>> titleContentView >>> {
            $0.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
            $0.snp.makeConstraints({ (make) in
                make.left.equalToSuperview()
                make.right.equalToSuperview()
                make.bottom.equalToSuperview()
                make.height.equalTo(0.5)
            })
        }
    }
    
    func setupRX() {
        
    }
    
    func setupDisplay(item: String?) {
        
    }
    
    func update(title: String) {
        lblTitle.text = title
    }
    
   
}


final class MerchantAddImageFormCell: Eureka.Cell<[UIImage]>, CellType, UpdateDisplayProtocol {
    
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        visualize()
        setupRX()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupDisplay(item: [UIImage]?) {
        
    }
    
    func visualize() {
        
    }
    
    func setupRX() {
        
    }
    
}


