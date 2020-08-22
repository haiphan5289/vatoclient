//
//  BusStationCell.swift
//  Vato
//
//  Created by khoi tran on 4/24/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation
import Eureka
import FwiCoreRX
import FwiCore
import SnapKit


final class BusStationCell: Eureka.Cell<TicketRoutes>, CellType, UpdateDisplayProtocol {
    
    let segmentView = VatoSegmentView<BusStationView, TicketRoutes>(edges: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), spacing: 0, axis: .vertical) { (idx, t) -> BusStationView in
        let bgColor = idx % 2 == 0 ?  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) : #colorLiteral(red: 0.9921568627, green: 0.9294117647, blue: 0.9098039216, alpha: 1)
        let v = BusStationView(frame: .zero, bgColor: bgColor)
        v.setupDisplay(item: t)
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
        textLabel?.isHidden = true
        selectionStyle = .none
        
        self.backgroundColor = .white
        
        segmentView >>> self >>> {
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.bottom.equalToSuperview().priority(.high)
            }
        }
    }
    
    
    func setupDisplay(item: TicketRoutes?) {
    }
    
    func updateView(index: Int) {
        
    }
    
    func updateView() {
        
    }
    
    
    func updateSelected(isSelected: Bool) {
        
    }
    
}
