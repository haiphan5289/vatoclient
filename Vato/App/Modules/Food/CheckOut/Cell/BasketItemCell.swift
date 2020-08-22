//
//  BasketItemCell.swift
//  Vato
//
//  Created by khoi tran on 12/12/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation
import Eureka
import RxSwift
import FwiCore

final class BasketItemCell: Eureka.Cell<QuoteItem>, CellType, UpdateDisplayProtocol {
    private lazy var lblTitle: UILabel = UILabel(frame: .zero)
    private lazy var lblDescription: UILabel = UILabel(frame: .zero)
    private lazy var lblPrice: UILabel = UILabel(frame: .zero)
    private lazy var lblNumber: UILabel = UILabel(frame: .zero)
    private lazy var imageShopView: UIImageView = UIImageView(frame: .zero)
    private (set) lazy var btnDelete: UIButton = UIButton(frame: .zero)
    private (set) lazy var editView: StoreEditControl = StoreEditControl(frame: .zero)
    
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        visualize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func visualize() {
        selectionStyle = .none
        textLabel?.isHidden = true
        imageView?.isHidden = true
        
        imageShopView >>> contentView >>> {
            $0.layer.cornerRadius = 4
            $0.clipsToBounds = true
            $0.contentMode = .scaleAspectFill
            $0.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 48, height: 48))
                make.top.left.equalTo(16)
            }
        }
        
        lblTitle >>> {
            $0.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        }
        
        lblDescription >>> {
            $0.numberOfLines = 2
            $0.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        }
        
        let priceView = UIView(frame: .zero)
        priceView >>> {
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.setContentCompressionResistancePriority(.required, for: .vertical)
        }
        
        lblPrice >>> priceView >>> {
            $0.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.setContentCompressionResistancePriority(.required, for: .vertical)
            $0.snp.makeConstraints({ (make) in
                make.left.top.bottom.equalToSuperview()
            })
        }
        
        lblNumber >>> priceView >>> {
            $0.textColor = #colorLiteral(red: 0, green: 0.3803921569, blue: 0.2392156863, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(lblPrice.snp.right).offset(12)
                make.bottom.equalToSuperview()
            })
        }
        
        
        editView.isSelected = true
        editView >>> priceView >>> {
            $0.snp.makeConstraints { (make) in
                make.right.equalTo(-40)
                make.bottom.equalTo(priceView).priority(.high)
                make.height.equalTo(24)
            }
        }
        
        btnDelete >>> priceView >>> {
            $0.setImage(UIImage(named: "ic_delete_ecom"), for: .normal)
            $0.snp.makeConstraints { (make) in
                make.right.equalToSuperview()
                make.centerY.equalTo(editView.snp.centerY)
                make.size.equalTo(CGSize(width: 24, height: 24))
            }
        }
        
        let stackView = UIStackView(arrangedSubviews: [lblTitle, lblDescription, priceView])
        
        stackView >>> contentView >>> {
            $0.axis = .vertical
            $0.distribution = .fill
            $0.spacing = 8
            
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(imageShopView.snp.right).offset(12)
                make.right.equalTo(-16)
                make.top.equalTo(imageShopView.snp.top)
                make.bottom.equalTo(-16).priority(.high)
            })
        }
        
        contentView.addSeperator(with: UIEdgeInsets(top: 0, left: 16, bottom: 0.5, right: 0), position: .bottom)
    }
    
    func setupDisplay(item: QuoteItem?) {
        guard let quoteItem = item else {
            return
        }
        imageShopView.setImage(from: item?.images?.components(separatedBy: ";").first, placeholder: nil, size: CGSize(width: 48, height: 48))
        lblTitle.text = quoteItem.name
        lblDescription.text = quoteItem.description
        let p = quoteItem.basePriceInclTax ?? 0
        let quantity = quoteItem.qty ?? 0
        lblPrice.text = p.currency
        lblNumber.text = "x\(quantity)"
    }
}



final class BasketItemHeaderCell: Eureka.Cell<String>, CellType, UpdateDisplayProtocol {
    
    private lazy var lblTitle: UILabel = UILabel(frame: .zero)
    var addButton: UIButton = UIButton(frame: .zero)
    
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        visualize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func visualize() {
        selectionStyle = .none
        textLabel?.isHidden = true
        imageView?.isHidden = true
        
        lblTitle >>> contentView >>> {
            $0.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            $0.text = "Món đã chọn"
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(16)
                make.top.equalTo(16)
                make.bottom.equalTo(-16)
            })
        }
        
        
        addButton >>> contentView >>> {
            $0.setTitleColor(#colorLiteral(red: 0.9588660598, green: 0.4115985036, blue: 0.1715823114, alpha: 1), for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
            $0.setTitle("Thêm món", for: .normal)
            $0.snp.makeConstraints({ (make) in
                make.centerY.equalToSuperview()
                make.right.equalTo(-16)
            })
        }
    }
    
    func setupDisplay(item: String?) {
        
    }
}
