//
//  OCInformation.swift
//  Vato
//
//  Created by Phan Hai on 18/08/2020.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit

enum OrderContractType {
    case seeMore
    case other
    case explain
}
class OCInformation: UIView {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var viewStatus: UIView!
    @IBOutlet weak var viewLocation: UIView!
    @IBOutlet weak var viewButton: UIView!
    @IBOutlet weak var btChat: UIButton!
    @IBOutlet weak var btSeeMore: UIButton!
    @IBOutlet weak var viewBill: UIView!
    @IBOutlet weak var viewInforUser: UIView!
    @IBOutlet weak var viewRestPrice: UIView!
    @IBOutlet weak var viewAvatar: UIView!
    @IBOutlet weak var viewDeposit: UIView!
    @IBOutlet weak var stackViewButton: UIStackView!
    
    private var type: OrderContractType?
    override func awakeFromNib() {
        super.awakeFromNib()
        visualize()
    }
    
}
extension OCInformation {
    private func visualize() {
        let viewBG = HeaderCornerView(with: 7)
        viewStatus.backgroundColor = .clear
        viewBG.containerColor = .white
        viewStatus.insertSubview(viewBG, at: 0)
        viewBG >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
    }
    func updateUI(type: OrderContractType) {
        let views = [viewLocation, viewBill, viewInforUser, viewRestPrice, viewAvatar, viewDeposit]
        switch type {
        case .seeMore:
            self.stackViewButton.isHidden = true
            views.forEach { (v) in
                v?.isHidden = true
            }
        case .explain:
            views.forEach { (v) in
                v?.isHidden = false
            }
        default:
            break
        }
    }
}
