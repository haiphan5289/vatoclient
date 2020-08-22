//
//  MerchantStoreProductCell.swift
//  Vato
//
//  Created by khoi tran on 11/22/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation
import RxSwift
import FwiCore

final class MerchantStoreProductCell: StoreProductCell<DisplayProduct> {
    
    var editButton: UIButton = UIButton(frame: .zero)
    var openSwitch: UISwitch = UISwitch(frame: .zero)
    
    private var productEnableChangedCallback: ((Int?, Bool)->Void)?
    
    private var productId: Int?
    
    private var disposeBag = DisposeBag()
    
    override func visualize() {
        super.visualize()
        
        openSwitch >>> contentView >>> {
            
            $0.onTintColor = UIColor(red: 239/255, green: 82/255, blue: 34/255, alpha: 1.0)
            $0.snp.makeConstraints({ (make) in
                make.right.equalTo(-16)
                make.bottom.equalTo(-16)
            })
        }
        
        let imageView = UIImageView(image: UIImage(named: "ic_add_favorite_place_edit"))
        imageView >>> contentView >>> {
            $0.backgroundColor = UIColor(red: 239/255, green: 82/255, blue: 34/255, alpha: 0.2)
            $0.isUserInteractionEnabled = false
            $0.cornerRadius = 12
            $0.snp.makeConstraints({ (make) in
                make.right.equalTo(openSwitch.snp.left).offset(-16)
                make.bottom.equalTo(-16)
                make.width.equalTo(24)
                make.height.equalTo(24)
            })
        }
        
        editButton >>> contentView >>> {
            $0.backgroundColor = .clear
            $0.isUserInteractionEnabled = false
            $0.snp.makeConstraints({ (make) in
                make.right.equalTo(openSwitch.snp.left).offset(-16)
                make.bottom.equalTo(-16)
                make.width.equalTo(40)
                make.height.equalTo(40)
            })
        }
        
        self.setupRX()
        
    }
    
    override func setupDisplay(item: DisplayProduct?) {
        super.setupDisplay(item: item)
        self.productId = item?.productId
        openSwitch.setOn(item?.productIsOpen ?? false, animated: false)
    }

    private func setupRX() {
        self.openSwitch.rx.value.bind { [weak self] (value) in
            guard let me = self else { return }
            if let callback = me.productEnableChangedCallback {
                callback(me.productId, value)
            }
        }.disposed(by: disposeBag)
    }
    
}
extension MerchantStoreProductCell {
    public func onProductEnableChanged(callback: @escaping (Int?, Bool)->Void ) {
        self.productEnableChangedCallback = callback
    }
}



