
//
//  DisplayAddedImageView.swift
//  Vato
//
//  Created by khoi tran on 10/23/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation
import UIKit
import FwiCore


class DisplayAddedImageView: UIView {
    let imageView: UIImageView
    let btnClose: UIButton
    
    var source: UploadedImage?
    
    override init(frame: CGRect) {
        imageView = UIImageView(frame: .zero)
        btnClose = UIButton(frame: .zero)
        super.init(frame: .zero)
        visualize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func visualize() {
        imageView >>> self >>> {
            $0.contentMode = .scaleAspectFill
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        
        btnClose >>> self >>> {
            $0.setImage(UIImage(named: "ic_clear_photo"), for: .normal)
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(4)
                make.right.equalTo(-4)
                make.width.equalTo(24)
                make.right.equalTo(24)
            })
        }
    }
    
    func setImage(from source: UploadedImage?, placeholder: UIImage? = nil, size: CGSize? = nil) {
        self.source = source
        self.imageView.setImage(from: source, placeholder: placeholder, size: size)
    }
    
    
    func removeStorageImage() {
        if let source = self.source {
            source.removeStorageImage()
        }
    }
}
