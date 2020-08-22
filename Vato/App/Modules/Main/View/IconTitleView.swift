//  File name   : IconTitleView.swift
//
//  Author      : Dung Vu
//  Created date: 8/25/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import SnapKit
import FwiCore
import FwiCoreRX

class IconTitleView: UIView {
    let imageView: UIImageView
    let lblTitle: UILabel
    var stackView: UIStackView?
    
    override init(frame: CGRect) {
        imageView = UIImageView(frame: .zero)
        lblTitle = UILabel(frame: .zero)
        super.init(frame: .zero)
        lblTitle.setContentHuggingPriority(.required, for: .horizontal)
        lblTitle.setContentHuggingPriority(.required, for: .vertical)
        visualize()
        addStackView()
    }
    
    func addStackView() {
        let stackView = UIStackView(arrangedSubviews: [imageView, lblTitle])
        stackView >>> self >>> {
            $0.distribution = .fillProportionally
            $0.alignment = .center
            $0.axis = .vertical
            $0.spacing = 5
            $0.snp.makeConstraints({ (make) in
                make.top.equalToSuperview()
                make.left.equalTo(3)
                make.right.equalTo(-3)
                make.bottom.equalToSuperview().priority(.high)
            })
        }
        
        self.stackView = stackView
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return nil
    }
    
    func visualize() {
        
    }
}

final class IconTitlePaymentView: IconTitleView {
    override func visualize() {
        imageView >>> self >>> {
            $0.snp.makeConstraints({ (make) in
                make.size.equalTo(CGSize(width: 24, height: 24))
            })
        }
        
        lblTitle >>> self >>> {
            $0.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
            $0.textAlignment = .center
            $0.font = UIFont.systemFont(ofSize: 13, weight: .medium)
            $0.snp.makeConstraints({ (make) in
                make.width.greaterThanOrEqualTo(30)
            })
        }
    }
}

final class IconTitleServiceView: IconTitleView {
    private (set) lazy var iconNew: UIImageView = UIImageView(frame: .zero)
    override func visualize() {
        imageView >>> self >>> {
            $0.contentMode = .scaleAspectFit
            $0.snp.makeConstraints({ (make) in
                make.size.equalTo(CGSize(width: 48, height: 48))
            })
        }
        
        lblTitle >>> self >>> {
            $0.text = ""
            $0.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
            $0.textAlignment = .center
            $0.numberOfLines = 2
            $0.font = UIFont.systemFont(ofSize: 13, weight: .medium)
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.setContentCompressionResistancePriority(.required, for: .vertical)
            $0.snp.makeConstraints({ (make) in
                make.width.greaterThanOrEqualTo(54)
            })
        }
        
        iconNew >>> imageView >>> {
            $0.contentMode = .scaleAspectFill
            $0.image = UIImage(named: "ic_new_feature")
            $0.isHidden = true
            $0.snp.makeConstraints { (make) in
                make.top.right.equalToSuperview()
                make.size.equalTo(CGSize(width: 20, height: 20))
            }
        }
    }
    
    override func addStackView() {
        let stackView = UIStackView(arrangedSubviews: [imageView, lblTitle])
        stackView >>> self >>> {
            $0.distribution = .fillProportionally
            $0.alignment = .center
            $0.axis = .vertical
            $0.spacing = 5
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.setContentCompressionResistancePriority(.required, for: .vertical)
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(10)
                make.left.equalTo(3)
                make.right.equalTo(-3).priority(.high)
                make.width.greaterThanOrEqualTo(60)
                make.bottom.equalToSuperview().priority(.high)
            })
        }
        
        self.stackView = stackView
    }
}

final class ButtonIconTitlePayment: UIControl {
    private (set) var iconView: IconTitlePaymentView?
    override init(frame: CGRect) {
        super.init(frame: frame)
        visualize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        visualize()
    }
    
    private func visualize() {
        let iconView = IconTitlePaymentView(frame: .zero)
        iconView >>> self >>> {
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.setContentHuggingPriority(.required, for: .horizontal)
            $0.snp.makeConstraints({ (make) in
                make.center.equalToSuperview()
            })
        }
        self.iconView = iconView
    }
}

