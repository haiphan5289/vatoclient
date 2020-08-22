//  File name   : VatoEventOnGoingCell.swift
//
//  Author      : Dung Vu
//  Created date: 5/20/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import Eureka
import SnapKit
import FwiCore
import FwiCoreRX
import RxSwift
import RxCocoa

final class VatoEventOnGoingCell: Eureka.Cell<[VatoHomeGroupEventGoing]>, CellType, UpdateDisplayProtocol {
    private (set) lazy var segment = VatoSegmentView<VatoOnGoingServiceView, VatoHomeGroupEventGoing>.init(edges: UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16), spacing: 16, axis: .vertical) { (idx, model) -> VatoOnGoingServiceView in
        let v = VatoOnGoingServiceView(frame: .zero)
        v >>> {
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.snp.makeConstraints { (make) in
                make.height.equalTo(40)
            }
        }
        v.setupDisplay(item: model)
        return v
    }
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
        
        segment >>> contentView >>> {
            $0.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.bottom.equalToSuperview().priority(.high)
            }
        }
    }
    
    func setupDisplay(item: [VatoHomeGroupEventGoing]?) {
        guard let items = item else {
            return
        }
        segment.setupDisplay(item: items)
        
    }
}


