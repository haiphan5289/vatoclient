//  File name   : EcomReceiptCell.swift
//
//  Author      : Dung Vu
//  Created date: 3/31/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import Eureka
import FwiCore
import SnapKit

final class EcomTitleCell: Eureka.Cell<String>, CellType, UpdateDisplayProtocol {
    private lazy var lblTitle: UILabel = UILabel(frame: .zero)
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        visualize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Please Implement")
    }
    
    private func visualize() {
        selectionStyle = .none
        textLabel?.isHidden = true
        
        lblTitle >>> contentView >>> {
            $0.numberOfLines = 0
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            $0.snp.makeConstraints { make in
                make.edges.equalTo(UIEdgeInsets(top: 16, left: 16, bottom: 4, right: 16))
            }
        }
    }
    
    func setupDisplay(item: String?) {
        lblTitle.text = item
    }
}

final class EcomItemCell: Eureka.Cell<OrderItem>, CellType, UpdateDisplayProtocol {
    private lazy var view = EcomItemListView.loadXib()
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        visualize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Please Implement")
    }
    
    private func visualize() {
        selectionStyle = .none
        textLabel?.isHidden = true
        view >>> contentView >>> {
            $0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
        contentView.addSeperator(with: UIEdgeInsets(top: 0, left: 76, bottom: 0, right: 16), position: .bottom)
        
    }
    
    func setupDisplay(item: OrderItem?) {
        view.setupDisplay(item: item)
    }
}

final class AddDestinationPriceCell: Eureka.Cell<[PriceInfoDisplayStyle]>, CellType, UpdateDisplayProtocol {
    private lazy var containerView = UIView(frame: .zero)
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
        
        containerView.backgroundColor = #colorLiteral(red: 0.6352941176, green: 0.6705882353, blue: 0.7019607843, alpha: 0.08)
        containerView >>> contentView >>> {
            $0.layer.cornerRadius = 8
            $0.layer.borderColor = #colorLiteral(red: 0.6352941176, green: 0.6705882353, blue: 0.7019607843, alpha: 0.15)
            $0.layer.borderWidth = 1
            $0.clipsToBounds = true
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.snp.makeConstraints { (make) in
                make.edges.equalTo(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
            }
        }
        
    }
    
    func setupDisplay(item: [PriceInfoDisplayStyle]?) {
        let views = item?.map({ (destination) -> UIView in
            let view = UIView(frame: .zero)
            view.backgroundColor = .clear
            view >>> {
                $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
                $0.setContentHuggingPriority(.required, for: .vertical)
            }
            
            let lblTitle = UILabel(frame: .zero)
            lblTitle >>> {
                $0.attributedText = destination.attributeTitle
                $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
                $0.setContentHuggingPriority(.defaultLow, for: .vertical)
            }
            
            
            let lblPrice = UILabel(frame: .zero)
            lblPrice >>> {
                $0.attributedText = destination.attributePrice
                $0.setContentHuggingPriority(.required, for: .horizontal)
                $0.setContentHuggingPriority(.required, for: .vertical)
            }
            
            let stackView = UIStackView(arrangedSubviews: [lblTitle, lblPrice])
            stackView >>> view >>> {
                $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
                $0.setContentHuggingPriority(.required, for: .vertical)
                $0.distribution = .fill
                $0.axis = .horizontal
                $0.snp.makeConstraints { (make) in
                    make.edges.equalTo(destination.edge)
                }
            }
            
            if destination.showLine {
                view.addSeperator(with: .zero, position: .top)
            }
            return view
        })
        
        
        let stackView = UIStackView(arrangedSubviews: views ?? [])
        stackView >>> containerView >>> {
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.distribution = .fill
            $0.axis = .vertical
            $0.spacing = 8
            $0.snp.makeConstraints { (make) in
                make.edges.equalTo(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)).priority(.high)
            }
        }
    }
}

