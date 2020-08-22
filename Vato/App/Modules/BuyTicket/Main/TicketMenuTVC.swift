//
//  TicketMenuTVC.swift
//  Vato
//
//  Created by an.nguyen on 7/23/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import FwiCore
import SnapKit

// MARK: -- TableView Cell
final class TicketMenuTVC: UITableViewCell, UpdateDisplayProtocol {
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        let imgName = selected ? "ic_checkedbox" : "ic_uncheckedbox"
        imageView?.image = UIImage(named: imgName)
        let bgColor = selected ? #colorLiteral(red: 0.9921568627, green: 0.9294117647, blue: 0.9098039216, alpha: 1) : .white
        contentView.backgroundColor = bgColor
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        visualize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupDisplay(item: TypeRoute?) {
        textLabel?.text = item?.name
    }

    private func visualize() {
        imageView?.snp.makeConstraints { (make) in
            make.right.equalTo(-16)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 22, height: 22))
        }
        
        textLabel?.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.centerY.equalToSuperview()
        }
        
        separatorInset = UIEdgeInsets.init(top: 0, left: 16, bottom: 0, right: 0)
    }
}
