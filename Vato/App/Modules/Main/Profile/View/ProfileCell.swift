//  File name   : ProfileCell.swift
//
//  Author      : Dung Vu
//  Created date: 9/3/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import Eureka
import FwiCoreRX
import FwiCore
import SnapKit
import RxSwift
import RxCocoa

final class ProfileHeaderCell: Eureka.Cell<UserInfo>, CellType, UpdateDisplayProtocol {
    private (set) lazy var detailView = ProfileDetailView.loadXib()
    private lazy var disposeBag = DisposeBag()
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        visualize()
        setupRX()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func visualize() {
        selectionStyle = .none
        textLabel?.isHidden = true
        detailView >>> contentView >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
    }
    
    func setupDisplay(item: UserInfo?) {
        guard let client = item else {
            return
        }
        detailView.display(client: client)
    }
    
    func setupRX() {
        NotificationCenter.default.rx.notification(.profileUpdatedAvatar, object: nil).map { $0.object as? String }.bind { [weak self](url) in
            self?.detailView.updateAvatar(url: url)
        }.disposed(by: disposeBag)
    }
}

final class ProfileServiceCell: Eureka.Cell<ProfileCellType>, CellType, UpdateDisplayProtocol {
    private var iconView: UIImageView?
    private var lblTitle: UILabel?
    private var dotView: UIView?
    var badgeLabel: UILabel?
    
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
        let iconView = UIImageView(frame: .zero)
        iconView >>> contentView >>> {
            $0.contentMode = .scaleToFill
            $0.snp.makeConstraints({ (make) in
                make.size.equalTo(CGSize(width: 24, height: 24))
                make.centerY.equalToSuperview()
                make.left.equalTo(16)
            })
        }
        
        self.iconView = iconView
        let arrowView = UIImageView(image: UIImage(named: "ic_home_more"))
        arrowView >>> contentView >>> {
            $0.snp.makeConstraints({ (make) in
                make.size.equalTo(CGSize(width: 24, height: 24))
                make.centerY.equalToSuperview()
                make.right.equalTo(-16)
            })
        }
        
        let lblTitle = UILabel(frame: .zero)
        lblTitle >>> contentView >>> {
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.snp.makeConstraints({ (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(iconView.snp.right).offset(16)
                make.right.equalTo(arrowView.snp.left).offset(-16)
            })
        }
        
        self.lblTitle = lblTitle
        
        let dotView = UIView(frame: .zero)
        dotView >>> contentView >>> {
            $0.backgroundColor = .red
            $0.cornerRadius = 5
            $0.snp.makeConstraints({ (make) in
                make.centerY.equalToSuperview()
                make.size.equalTo(CGSize(width: 10, height: 10))
                make.right.equalTo(arrowView.snp.left).offset(-16)
            })
        }
        self.dotView = dotView
        
        let _badgeLabel = UILabel(frame: .zero)
        _badgeLabel >>> contentView >>> {
            $0.backgroundColor = .red
            $0.cornerRadius = 10
            $0.textColor = .white
            $0.font = UIFont.systemFont(ofSize: 10)
            $0.textAlignment = .center
            $0.snp.makeConstraints({ (make) in
                make.centerY.equalToSuperview()
                make.size.equalTo(CGSize(width: 20, height: 20))
                make.right.equalTo(arrowView.snp.left).offset(-16)
            })
        }
        self.badgeLabel = _badgeLabel
        
    }
    
    override func setup() {
        super.setup()
        height = { 56 }
    }
    
    func setupDisplay(item: ProfileCellType?) {
        iconView?.image = item?.image
        lblTitle?.text = item?.title
        dotView?.isHidden = item?.isDotViewHidden ?? true
        badgeLabel?.isHidden = true
    }
}


