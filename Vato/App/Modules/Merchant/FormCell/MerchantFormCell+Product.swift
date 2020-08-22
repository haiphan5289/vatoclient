//
//  MerchantFormCell+Product.swift
//  Vato
//
//  Created by khoi tran on 11/7/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation
import Eureka
import RxSwift
import UIKit

class CheckBoxCVC: UICollectionViewCell {
    
    
    lazy var checkBoxImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        visualize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                self.checkBoxImageView.image = UIImage(named: "ic_check")
            } else {
                self.checkBoxImageView.image = UIImage(named: "ic_uncheck")
            }
        }
    }
    
    private func visualize() {
        
        checkBoxImageView >>> contentView >>> {
            $0.contentMode = .scaleAspectFill
            $0.image = UIImage(named: "ic_uncheck")
            $0.snp.makeConstraints({ (make) in
                make.centerY.equalToSuperview()
                make.width.equalTo(22)
                make.height.equalTo(22)
                make.left.equalTo(0)
            })
        }
        
        titleLabel >>> contentView >>> {
            $0.text = ""
            $0.snp.makeConstraints({ (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(checkBoxImageView.snp.right).offset(12)
                make.right.equalTo(-4)
            })
        }
    }
    
    
    
}


final class MerchantCheckBoxCell: Eureka.Cell<[Bool?]>, CellType, UpdateDisplayProtocol {
    
    var lblTitle: UILabel
    var lblStar: UILabel?

    var collectionView: UICollectionView
    
    private var disposeBag = DisposeBag()
    
    private var source: [MerchantAttributeElementValue] = []

    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.lblTitle = UILabel(frame: .zero)
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        
        layout.scrollDirection = .horizontal
        
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        
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
        
        collectionView.register(CheckBoxCVC.self, forCellWithReuseIdentifier: CheckBoxCVC.identifier)
        
        collectionView >>> contentView >>> {
            $0.backgroundColor = .white
            $0.allowsMultipleSelection = true
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(lblTitle.snp.bottom).offset(8)
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.height.equalTo(22)
            })
        }
        
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
        collectionView.rx.setDataSource(self).disposed(by: disposeBag)
    }
    
    override func setup() {
        super.setup()
        height = { 61 }
    }
    
    
    func setupRX() {
        
    }
    
    func update(title: String) {
        lblTitle.text = title
    }
    
    func setupDisplay(item: [Bool?]?) {
       
    }
    
    func setupData(items: [MerchantAttributeElementValue]?) {
        guard let items = items else {
            return
        }
        
        source = items
        collectionView.reloadData()
    }
    
    
    func updateTitle(title: String?) {
        self.lblTitle.text = title
    }
    
    func getSelectedValue() -> String? {
        guard let indexPaths = collectionView.indexPathsForSelectedItems else {
            return ""
        }
        
       return indexPaths.map { (i) -> String? in
            if let id = source[i.row].id {
                return "\(id)"
            }
            return nil
        }.compactMap({ $0 }).joined(separator: ",")
    }
    
    
    func setSelectedValue(value: String) {
        let listId = value.split(",")
        
        var index = 0
        for i in source {
            if let id = i.id {
                if listId.contains("\(id)") {
                    collectionView.selectItem(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .top)
                }
            }
            index += 1
        }
    }
}

extension MerchantCheckBoxCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numItem = min(max(self.source.count,1) , 4)
        let w = (UIScreen.main.bounds.width - 32) / CGFloat(numItem)
        return CGSize(width: max(w, 0), height: 22)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
    }
}

extension MerchantCheckBoxCell: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return source.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CheckBoxCVC.identifier, for: indexPath) as? CheckBoxCVC else {
            fatalError("Error")
        }
        cell.titleLabel.text = source[indexPath.row].label
        return cell
    }
}



final class MerchantTextViewCell: Eureka.Cell<String>, CellType, UpdateDisplayProtocol {
    
    var lblTitle: UILabel = UILabel(frame: .zero)
    var lblStar: UILabel?
    var textView: UITextView = UITextView(frame: .zero)
    
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.visualize()
        self.setupRX()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func visualize() {
        selectionStyle = .none
        textLabel?.isHidden = true
        imageView?.isHidden = true
        
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
        
        textView >>> contentView >>> {
            $0.cornerRadius = 8
            $0.borderColor = UIColor(red: 221/255, green: 226/255, blue: 232/255, alpha: 1.0)
            $0.backgroundColor = .white
            $0.borderWidth = 1.0
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.top.equalTo(lblTitle.snp.bottom).offset(4)
                make.height.equalTo(80)
                make.bottom.equalTo(0)
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
    
    
    func getText() -> String {
        return textView.text
    }
    
    func setText(text: String) {
        self.textView.text = text
    }
    
}



final class MerchantSwitchViewCell: Eureka.Cell<Bool>, CellType, UpdateDisplayProtocol {
    var lblTitle: UILabel = UILabel(frame: .zero)
    var valueSwitch: UISwitch = UISwitch(frame: .zero)
    
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        visualize()
        setupRX()
    }
    
    override func setup() {
        super.setup()
        height = { 56 }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func visualize() {
        selectionStyle = .none
        textLabel?.isHidden = true
        imageView?.isHidden = true
        
        self.backgroundColor = .white
        lblTitle >>> contentView >>> {
            $0.textColor = UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 1.0)
            $0.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            $0.snp.makeConstraints({ (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(16)
            })
        }
        
        valueSwitch >>> contentView >>> {
            $0.isOn = true
            $0.onTintColor = UIColor(red: 239/255, green: 82/255, blue: 34/255, alpha: 0.8)
            $0.snp.makeConstraints({ (make) in
                make.centerY.equalToSuperview()
                make.right.equalTo(-16)
            })
        }
    }
    
    func setupRX() {
        
    }
    
    func setupDisplay(item: Bool?) {
        guard let item = item else {
            return
        }
        
        valueSwitch.setOn(item, animated: false)
    }
    
    func update(title: String) {
        lblTitle.text = title
    }
    
    func getValue() -> Bool {
        return valueSwitch.isOn
    }
}
