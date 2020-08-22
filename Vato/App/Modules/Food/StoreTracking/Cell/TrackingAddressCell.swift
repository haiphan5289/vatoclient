//
//  TrackingInfoView.swift
//  Vato
//
//  Created by khoi tran on 12/16/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation
import Eureka
import FwiCore
import RxSwift

final class TrackingAddressCell: Eureka.Cell<SalesOrder>, CellType, UpdateDisplayProtocol {
    private lazy var originImageView = UIImageView(frame: .zero)
    private lazy var originLabel = UILabel(frame: .zero)

    private lazy var destinationImageView = UIImageView(frame: .zero)
    private lazy var destinationLabel = UILabel(frame: .zero)
    
    private lazy var dotView = UIImageView(frame: .zero)

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
                
        originImageView >>> contentView >>> {
            $0.contentMode = .scaleAspectFill
            $0.image = UIImage(named: "ic_origin")
            $0.snp.makeConstraints { (make) in
                make.top.left.equalTo(16)
                make.size.equalTo(CGSize(width: 16, height: 16))
            }
        }
        
        originLabel >>> contentView >>> {
            $0.textColor = #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            $0.snp.makeConstraints { (make) in
                make.left.equalTo(originImageView.snp.right).offset(12).priority(.high)
                make.centerY.equalTo(originImageView.snp.centerY)
                make.right.equalTo(-16)

            }
        }
        
        dotView >>> contentView >>> {
            $0.contentMode = .scaleAspectFill
            $0.image = UIImage(named: "ic_vertical_4dots")
            $0.clipsToBounds = true
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(originImageView.snp.bottom).offset(4).priority(.high)
                make.centerX.equalTo(originImageView.snp.centerX)
                make.size.equalTo(CGSize(width: 2, height: 10))
           }
        }
        
        destinationImageView >>> contentView >>> {
            $0.contentMode = .scaleAspectFill
            $0.image = UIImage(named: "ic_destination_new")
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(dotView.snp.bottom).offset(4).priority(.high)
                make.left.equalTo(16)
                make.size.equalTo(CGSize(width: 16, height: 16))
                make.bottom.equalToSuperview().offset(-16)
            }
        }
        
        destinationLabel >>> contentView >>> {
            $0.textColor = #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.snp.makeConstraints { (make) in
                make.left.equalTo(destinationImageView.snp.right).offset(12)
                make.centerY.equalTo(destinationImageView.snp.centerY)
                make.right.equalTo(-16)
            }
        }
    }
    
    
    func setupDisplay(item: SalesOrder?) {
        originLabel.text = item?.orderItems?.first?.nameStore
        destinationLabel.text = item?.salesOrderAddress?.first?.address
    }
}


final class TrackingInfoCell: Eureka.Cell<String>, CellType, UpdateDisplayProtocol {
    private lazy var titleNoteLabel = UILabel(frame: .zero)
    private lazy var detailDesLabel = UILabel(frame: .zero)

    
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
        
        titleNoteLabel >>> {
            $0.textColor = #colorLiteral(red: 0.4623882771, green: 0.5225807428, blue: 0.5743968487, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.setContentCompressionResistancePriority(.required, for: .vertical)
        }
        
        detailDesLabel >>> {
            $0.textColor = #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            $0.numberOfLines = 2
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.setContentCompressionResistancePriority(.required, for: .vertical)
        }
        
        let stackView = UIStackView(arrangedSubviews: [titleNoteLabel, detailDesLabel])
        stackView >>> contentView >>> {
            $0.axis = .vertical
            $0.spacing = 8
            $0.distribution = .fill
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.snp.makeConstraints { (make) in
                make.edges.equalTo(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)).priority(.high)
            }
        }
    }
    
    func setupDisplay(item: String?) {
        self.detailDesLabel.text = item
    }
    
    func setTitle(title: String) {
        self.titleNoteLabel.text = title
    }
    
    
}







