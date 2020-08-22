//  File name   : VatoPaymentSelectOrtherVC.swift
//
//  Author      : Dung Vu
//  Created date: 7/17/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import RxSwift
import RxCocoa
import FwiCore
import SnapKit

// MARK: -- TableView Cell
final class VatoPaymentSelectTVC: UITableViewCell, UpdateDisplayProtocol {
    private lazy var iconView: UIImageView = UIImageView(frame: .zero)
    private lazy var lblTitle: UILabel = UILabel(frame: .zero)
    private lazy var iconCheck: UIImageView = UIImageView(frame: .zero)
    private var canUse = true
    
    override var isSelected: Bool {
        didSet {
            let color: UIColor = self.isSelected ? #colorLiteral(red: 0.9921568627, green: 0.9294117647, blue: 0.9098039216, alpha: 1) : .white
            contentView.backgroundColor = color
            iconCheck.isHidden = !isSelected
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        guard canUse else { return }
        let color: UIColor = selected ? #colorLiteral(red: 0.9921568627, green: 0.9294117647, blue: 0.9098039216, alpha: 1) : .white
        contentView.backgroundColor = color
        iconCheck.isHidden = !selected
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        visualize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupDisplay(item: PaymentCardDetail?) {
        guard let i = item else { return }
        iconView.image = i.iconSmall
        lblTitle.text = i.localPayment ? i.type.generalName : i.shortDescription
        contentView.alpha = i.canUse ? 1 : 0.5
        canUse = i.canUse
    }
    
    private func visualize() {
        self.selectionStyle = .none
        iconView >>> contentView >>> {
            $0.snp.makeConstraints { (make) in
                make.left.equalTo(16)
                make.size.equalTo(CGSize(width: 40, height: 40))
                make.centerY.equalToSuperview()
            }
        }
        
        lblTitle >>> contentView >>> {
            $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            $0.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
            $0.snp.makeConstraints { (make) in
                make.left.equalTo(iconView.snp.right).offset(16)
                make.centerY.equalToSuperview()
                make.right.equalTo(-62)
            }
        }
        
        iconCheck >>> contentView >>> {
            $0.contentMode = .scaleAspectFit
            $0.image = UIImage(named: "ic_payment_check")
            $0.isHidden = true
            $0.snp.makeConstraints { (make) in
                make.right.equalTo(-16)
                make.size.equalTo(CGSize(width: 22, height: 22))
                make.centerY.equalToSuperview()
            }
        }
        
        contentView.addSeperator(with: UIEdgeInsets(top: 0, left: 72, bottom: 0, right: 0))
    }
}

// MARK: -- Controller
final class VatoPaymentSelectOrtherVC: VatoActionSheetVC<VatoPaymentSelectTVC> {
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard let item = mSource[safe: indexPath.item], item.canUse else {
            return nil
        }
        return indexPath
    }
}


