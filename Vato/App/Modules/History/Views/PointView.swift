//
//  PointView.swift
//  Vato
//
//  Created by khoi tran on 4/13/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit
import SnapKit


enum PointViewType {
    case origin(name: String)
    case destination(index: Int?, name: String)
}

class PointView: UIView, UpdateDisplayProtocol {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    private lazy var imvIcon: UIImageView = UIImageView(frame: .zero)
    private lazy var lblAddress: UILabel = UILabel(frame: .zero)
    private lazy var lblIndex: UILabel = UILabel(frame: .zero)
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.visualize()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func visualize() {
        imvIcon >>> self >>> {
            $0.contentMode = .scaleAspectFit
            $0.snp.makeConstraints { (make) in
                make.left.equalTo(0)
                make.width.equalTo(16)
                make.height.equalTo(16)
                make.centerY.equalToSuperview()
            }
        }
        
        lblAddress >>> self >>> {
            $0.textColor = #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            $0.text = ""
            $0.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(imvIcon.snp.right).offset(12)
                make.right.equalTo(-16)

            }
        }
        
        lblIndex >>> self >>> {
            $0.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            $0.text = ""
            $0.font = UIFont.systemFont(ofSize: 12, weight: .bold)
            $0.snp.makeConstraints { (make) in
                make.center.equalTo(imvIcon)
            }
        }
        
    }
    
    
    func setupDisplay(item: PointViewType?) {
        guard let item = item else { return }
        
        switch item {
        case .origin(let name):
            self.imvIcon.image = UIImage(named: "pickup")
            self.lblAddress.text = name
        case .destination(let index, let name):
            self.lblAddress.text = name
            if let index = index {
                self.imvIcon.image = UIImage(named: "ic_destination_edit")
                self.lblIndex.isHidden = false
                self.lblIndex.text = "\(index)"
            } else {
                self.lblIndex.isHidden = true
                self.imvIcon.image = UIImage(named: "destination_ListTicket")
            }
        }
    }
    
}
