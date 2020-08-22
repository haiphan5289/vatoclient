//  File name   : DestinationView.swift
//
//  Author      : Dung Vu
//  Created date: 8/18/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import SnapKit
import FwiCore
import FwiCoreRX
import RxSwift
import RxCocoa


protocol DestinationDisplayProtocol {
    var icon: UIImage? { get }
    var description: String { get }
    var title: String { get }
    var originalDestination: AddressProtocol? { get }
}

final class DestinationView: UIControl {
    /// Class's public properties.
    let iconView: UIImageView
    private let lblTitle: UILabel
    private let lblDescription: UILabel
    private let btnTouchUp: UIButton
    var touchUp: Observable<Void> {
        return btnTouchUp.rx.tap.asObservable()
    }

    /// Class's private properties.
    override init(frame: CGRect) {
        iconView = UIImageView(frame: .zero)
        btnTouchUp = UIButton(frame: .zero)
        lblTitle = UILabel(frame: .zero)
        lblDescription = UILabel(frame: .zero)
        super.init(frame: frame)
        visualize()
    }
    
    private func visualize() {
        self.backgroundColor = .white
        iconView >>> self >>> {
            $0.isUserInteractionEnabled = false
            $0.contentMode = .center
            $0.snp.makeConstraints({ (make) in
                make.size.equalTo(CGSize(width: 18, height: 18))
                make.left.equalTo(16)
                make.top.equalTo(16)
            })
        }
        
        let arrowView  = UIImageView(image: UIImage(named: "ic_chevron_right"))
        arrowView >>> self >>> {
            $0.isUserInteractionEnabled = false
            $0.contentMode = .scaleAspectFill
            $0.snp.makeConstraints({ (make) in
                make.centerY.equalToSuperview()
                make.size.equalTo(CGSize(width: 8, height: 12))
                make.right.equalTo(-16)
            })
        }
        
        lblTitle >>> self >>> {
            $0.isUserInteractionEnabled = false
            $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            $0.textColor = .black
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.numberOfLines = 0
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(iconView.snp.right).offset(12)
                make.top.equalTo(iconView.snp.top)
                make.right.equalTo(arrowView.snp.left).offset(-5).priority(.high)
            })
        }
        
        lblDescription >>> self >>> {
            $0.isUserInteractionEnabled = false
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.numberOfLines = 0
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(lblTitle.snp.left)
                make.top.equalTo(lblTitle.snp.bottom).offset(4)
                make.right.equalTo(lblTitle.snp.right)
                make.bottom.equalTo(-16).priority(.high)
            })
        }
        
        btnTouchUp >>> self >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
    }
    
    func setupDisplay(item: DestinationDisplayProtocol) {
        iconView.image = item.icon
        lblTitle.text = item.title
        lblDescription.text = item.description
        
        layoutIfNeeded()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}




