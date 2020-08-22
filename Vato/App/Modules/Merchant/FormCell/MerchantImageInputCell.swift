//
//  MerchantDoubleImageFormCell.swift
//  Vato
//
//  Created by khoi tran on 10/29/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation
import Eureka
import RxSwift
import FwiCore
import FwiCoreRX


typealias AddImageCallBack = ()->Void
protocol AddImageProtocol {
    var callback: AddImageCallBack? { get }
    func setImageCallback(callback: AddImageCallBack?)
}

class AddImageStackView: UIView, AddImageProtocol {
    var stackView: UIStackView = UIStackView(frame: .zero)
    var viewAddImage: AddImageView = AddImageView(frame: .zero)
    fileprivate let disposeBag = DisposeBag()

    var maxItem = 2
    var callback: AddImageCallBack?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        visualize()
        setupRX()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func visualize() {
    }
    
    func setupRX() {
    }
    
    func addNew(image: UploadedImage?) {
        
    }
    
    func setImageCallback(callback: AddImageCallBack?) {
        self.callback = callback
    }

}

final class AddImageStackViewOne : AddImageStackView {
    
    var imageData: UploadedImage?

    override func visualize() {
        stackView >>> self >>> {
            $0.axis = .horizontal
            $0.distribution = .fill
            $0.spacing = 4
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(0)
                make.left.equalTo(0)
                make.bottom.equalTo(0)
            })
        }
        
        viewAddImage = AddImageView.create {
            $0.backgroundImageView.image = UIImage(named: "bg_add_photo")
            $0.imageView.image = UIImage(named: "ic_add_photo")
            $0.lblTitle.text = Text.uploadPhoto.localizedText
            $0.lblTitle.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.cornerRadius = 8
            $0.snp.makeConstraints({ (make) in
                make.width.equalTo(80)
            })
        }
        
        let button = UIButton(frame: .zero)
        button >>> viewAddImage >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        
        button.rx.tap.bind(onNext: { [weak self] in
            guard let callback = self?.callback else { return }
            callback()
        }).disposed(by: disposeBag)
        
        stackView.addArrangedSubview(viewAddImage)
    }
    
    override func addNew(image: UploadedImage?) {
        if self.stackView.arrangedSubviews.count >= maxItem {
            if let imageView = self.stackView.arrangedSubviews.first as? UIImageView {
                if let data = self.imageData {
                    data.removeStorageImage()
                }
                imageData = image
                imageView.setImage(from: image, placeholder: nil, size: CGSize(width: 80, height: 80))
                
            }
        } else {
            imageData = image
            let imageView = UIImageView.create {
                $0.contentMode = .scaleAspectFill
                $0.cornerRadius = 8
                $0.setImage(from: image, placeholder: nil, size: CGSize(width: 80, height: 80))
                $0.snp.makeConstraints({ (make) in
                    make.width.equalTo(80)
                })
            }
            
            self.stackView.insertArrangedSubview(imageView, at: 0)
        }
    }
}

final class AddImageStackViewMultiple : AddImageStackView {
    
    
    var scrollView: UIScrollView = UIScrollView(frame: .zero)
    var imageData: [UploadedImage] = []
    
    
    private var imageDataSubject : PublishSubject<[UploadedImage]> = PublishSubject()
    
    public var imageDataObservable:Observable<[UploadedImage]> {
        return imageDataSubject.asObservable()
    }
    
    override func visualize() {
        scrollView >>> self >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        
        stackView >>> scrollView >>> {
            $0.axis = .horizontal
            $0.distribution = .fill
            $0.spacing = 4
            $0.snp.makeConstraints({ (make) in
               make.edges.equalToSuperview()
            })
        }
        
        viewAddImage = AddImageView.create {
            $0.backgroundImageView.image = UIImage(named: "bg_add_photo")
            $0.imageView.image = UIImage(named: "ic_add_photo")
            $0.lblTitle.text = Text.uploadPhoto.localizedText
            $0.lblTitle.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.cornerRadius = 8
            $0.snp.makeConstraints({ (make) in
                make.width.equalTo(80)
                make.height.equalTo(80)
            })
        }
        
        let button = UIButton(frame: .zero)
        button >>> viewAddImage >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        
        button.rx.tap.bind(onNext: { [weak self] in
            guard let callback = self?.callback else { return }
            callback()
        }).disposed(by: disposeBag)
        
        stackView.addArrangedSubview(viewAddImage)
    }
    
    override func addNew(image: UploadedImage?) {
        guard let image = image else { return }
        
        if self.stackView.arrangedSubviews.count >= maxItem {
            self.viewAddImage.isHidden = true
            
        } else {
            self.viewAddImage.isHidden = false
        }
        
        let imageView = DisplayAddedImageView.create {
            $0.contentMode = .scaleAspectFill
            $0.cornerRadius = 8
            $0.setImage(from: image, placeholder: nil, size: CGSize(width: 80, height: 80))
            
            $0.snp.makeConstraints({ (make) in
                make.width.equalTo(80)
            })
        }
        
        imageView.btnClose.rx.tap.bind(onNext: { [weak self] in
            guard let me = self else { return }
            me.stackView.removeArrangedSubview(imageView)
            imageView.removeFromSuperview()
            image.removeStorageImage()
            me.imageData.removeAll(where: { (img) -> Bool in
                return img == image
            })
            me.imageDataSubject.onNext(me.imageData)
            me.viewAddImage.isHidden = false
            
        }).disposed(by: disposeBag)
        
        self.imageData.append(image)
        self.imageDataSubject.onNext(self.imageData)
        self.stackView.insertArrangedSubview(imageView, at: self.stackView.arrangedSubviews.count-1)
    }
    
    func getImageData() -> [UploadedImage?] {
        return self.imageData
    }
    
}

protocol UploadImageProtocol {
    func getImageData() -> [UploadedImage?]
    func getUploadParam() -> [URL:String]?
}

struct MerchantDoubleImage: Equatable {
    var left: UploadedImage?
    var right: UploadedImage?
    
    static func == (lhs: MerchantDoubleImage, rhs: MerchantDoubleImage) -> Bool {
        return lhs.left == rhs.left && lhs.right == rhs.right
    }
}

final class MerchantDoubleImageInputCell: Eureka.Cell<MerchantDoubleImage>, CellType, UpdateDisplayProtocol, UploadImageProtocol {
    
    var lblLeftTitle: UILabel = UILabel(frame: .zero)
    var lblRightTitle: UILabel = UILabel(frame: .zero)
    var stackViewTitle: UIStackView = UIStackView(frame: .zero)
    
    var leftView: AddImageStackViewOne = AddImageStackViewOne(frame: .zero)
    var rightView: AddImageStackViewOne = AddImageStackViewOne(frame: .zero)
    
    
    var leftCallbackHandler: BlockAction<UploadedImage>?
    var rightCallbackHandler: BlockAction<UploadedImage>?
    
    
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        self.leftCallbackHandler = { image in
            self.row.value?.left = image
            self.leftView.addNew(image: image)
        }
        
        self.rightCallbackHandler = { image in
            self.row.value?.right = image
            self.rightView.addNew(image: image)
        }
        
        visualize()
        setupRX()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupDisplay(item: MerchantDoubleImage?) {
        
    }
    
    func visualize() {
        selectionStyle = .none
        textLabel?.isHidden = true
        imageView?.isHidden = true

        lblLeftTitle = UILabel.create{
            $0.textColor = UIColor(red: 99/255, green: 114/255, blue: 118/255, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            $0.text = ""
        }
        
        lblRightTitle = UILabel.create{
            $0.textColor = UIColor(red: 99/255, green: 114/255, blue: 118/255, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            $0.text = ""
        }
        
        stackViewTitle >>> contentView >>> {
            $0.axis = .horizontal
            $0.distribution = .fillEqually
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(16)
                make.left.equalTo(16)
                make.right.equalTo(16)
            })
        }
        
        stackViewTitle.addArrangedSubview(lblLeftTitle)
        stackViewTitle.addArrangedSubview(lblRightTitle)
        
        let width = (UIScreen.main.bounds.width - 16 * 3)/2
        leftView >>> contentView >>> {
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(16)
                make.top.equalTo(stackViewTitle.snp.bottom).offset(4)
                make.height.equalTo(80)
                make.bottom.equalTo(0)
                make.width.equalTo(width)
            })
        }
        
        rightView >>> contentView >>> {
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(leftView.snp.right).offset(16)
                make.top.equalTo(stackViewTitle.snp.bottom).offset(4)
                make.height.equalTo(80)
                make.width.equalTo(width)
                make.bottom.equalTo(0)
            })
        }
    }
    
    func setupRX() {
        
    }
    
    func updateView(leftTitle: String?, rightTitle: String?) {
        self.lblLeftTitle.text = leftTitle
        self.lblRightTitle.text = rightTitle
    }
    
    func updateCallback(left: AddImageCallBack?, right: AddImageCallBack?) {
        leftView.setImageCallback(callback: left)
        rightView.setImageCallback(callback: right)
    }
    
    func getImageData() -> [UploadedImage?] {
        return [self.row.value?.left, self.row.value?.right]
    }
    
    func getUploadParam() -> [URL:String]? {
        let listUploadImage = self.getImageData().compactMap({$0})
        if listUploadImage.count == 0 {return nil}
        var uploadParam: [URL:String] = [:]
        for uploadImage in listUploadImage {
            if let url = uploadImage.getStorageUrl(),
                let path = uploadImage.getFullPath() {
                uploadParam[url] = path
            } else {
                return nil
            }
        }
        return uploadParam
    }
    
    func getUploadParam(index: Int) -> [URL:String]? {
        let listUploadImage = self.getImageData().compactMap({$0})
        if listUploadImage.count == 0 || index >= listUploadImage.count { return nil }
        
        let uploadImage = listUploadImage[index]
        var uploadParam: [URL:String] = [:]
        if let url = uploadImage.getStorageUrl(),
            let path = uploadImage.getFullPath() {
            uploadParam[url] = path
        } else {
            return nil
        }
        return uploadParam
    }
    
    func getUploadImage(index: Int) -> UploadedImage? {
        let listUploadImage = self.getImageData().compactMap({$0})
        if listUploadImage.count == 0 || index >= listUploadImage.count { return nil }
        return listUploadImage[index]
    }
    
    
    func setLeftImage(image: UploadedImage) {
        self.row.value?.left = image
        self.leftView.addNew(image: image)
    }
    
    func setRightImage(image: UploadedImage) {
        self.row.value?.right = image
        self.rightView.addNew(image: image)
    }
    
}


final class MerchantMultipleImageInputCell: Eureka.Cell<[UploadedImage]>, CellType, UpdateDisplayProtocol, UploadImageProtocol {            
    var lblTitle: UILabel = UILabel(frame: .zero)

    var imageListView: AddImageStackViewMultiple = AddImageStackViewMultiple(frame: .zero)

    var callbackHandler: BlockAction<UploadedImage>?

    private var disposeBag = DisposeBag()
    
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        callbackHandler = { image in
            self.imageListView.addNew(image: image)
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

        lblTitle >>> contentView >>> {
            $0.textColor = UIColor(red: 99/255, green: 114/255, blue: 118/255, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            $0.text = ""
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(16)
                make.left.equalTo(16)
            })
        }
        
        
        imageListView >>> contentView >>> {
            $0.maxItem = 8
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(16)
                make.top.equalTo(lblTitle.snp.bottom).offset(4)
                make.height.equalTo(80)
                make.bottom.equalTo(0)
                make.right.equalTo(-16)
            })
        }
        
        
    }
    
    func setupRX() {
        imageListView.imageDataObservable.bind(onNext: { [weak self] imageData in
            guard let me = self else { return }
            
            me.row.value = imageData
        }).disposed(by: disposeBag)
    }
    
    func setupDisplay(item: [UploadedImage]?) {
        
        
    }
    
    func addValue(items: [UploadedImage]?) {
        guard let items = items else {
            return
        }
        for i in items {
            self.imageListView.addNew(image: i)
        }
    }
    
    
    func updateCallback(_ callback : AddImageCallBack?) {
        self.imageListView.callback = callback
    }
    
    func updateView(title: String?) {
        self.lblTitle.text = title
    }
    
    func getImageData() -> [UploadedImage?] {
        return imageListView.imageData
    }
    
    func getUploadParam() -> [URL:String]? {
        let listUploadImage = self.getImageData()
        if listUploadImage.count == 0 { return nil }
        var uploadParam: [URL:String] = [:]
        for uploadImage in listUploadImage {
            if let uploadImage = uploadImage,
                let url = uploadImage.getStorageUrl(),
                let path = uploadImage.getFullPath() {
                uploadParam[url] = path
            }
        }
        return uploadParam
    }
}



