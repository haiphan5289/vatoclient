//
//  TrackingHeaderView.swift
//  Vato
//
//  Created by khoi tran on 12/14/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation
import RxSwift
import FwiCore
import SnapKit
import FwiCoreRX

typealias OrderStatus = (status: SalesOrder, description: String?)

enum TrackingHeaderViewType {
    case full
    case compact
    
    var radius: CGFloat {
        switch self {
        case .full:
            return 0
        case .compact:
            return 8
        }
    }
}

public class TrackingHeaderView: UIView {
    private var progressView: VatoProgressView?
    private lazy var statusLabel = UILabel(frame: .zero)
    private lazy var lblCodeOrder = UILabel(frame: .zero)
    private lazy var mStatus  = PublishSubject<OrderStatus>()
    private var type: TrackingHeaderViewType = .compact
    private (set) lazy var btnBack = UIButton(frame: .zero)
    private lazy var lineView = UIView(frame: .zero)
    public override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }
    
    private var mLayer: CAShapeLayer? {
        return layer as? CAShapeLayer
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeBenzierPath() -> UIBezierPath {
        return UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: type.radius * 2, height: type.radius * 2))
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let path = makeBenzierPath()
        mLayer?.path = path.cgPath
    }
    
    func update(type: TrackingHeaderViewType) {
        self.type = type
        switch type {
        case .full:
            btnBack.isHidden = false
            lblCodeOrder.isHidden = false
            lineView.isHidden = true
            let edge = UIApplication.shared.keyWindow?.edgeSafe ?? .zero
            progressView?.snp.updateConstraints({ (make) in
                make.top.equalTo(edge.top + 16)
            })
        case .compact:
            btnBack.isHidden = true
            lblCodeOrder.isHidden = true
            lineView.isHidden = false
            progressView?.snp.updateConstraints({ (make) in
                make.top.equalTo(24)
            })
        }
    }
    
}

extension TrackingHeaderView {
    private func initialize() {
        clipsToBounds = true
        mLayer?.fillColor = #colorLiteral(red: 0.9490196078, green: 0.4588235294, blue: 0.3058823529, alpha: 1).cgColor
        self.backgroundColor = .clear
        lineView >>> self >>> {
            $0.cornerRadius = 2
            $0.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.3)
            $0.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 40, height: 4))
                make.centerX.equalToSuperview()
                make.top.equalTo(4)
            }
        }
        
        
        let progressView = VatoProgressView(steps: 4, sizeStep: CGSize(width: 16, height: 16), spacing: 40, imageH: UIImage(named: "ic_status_delivery_h"), imageN: UIImage(named: "ic_status_delivery_n"))
        progressView >>> self >>> {
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(24)
                make.centerX.equalToSuperview()
            }
        }
        self.progressView = progressView
        
        statusLabel >>> self >>> {
            $0.textColor = .white
            $0.text = ""
            $0.textAlignment = .center
            $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            
            $0.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.top.equalTo(progressView.snp.bottom).offset(8)
            }
        }
        
        lblCodeOrder >>> self >>> {
            $0.isHidden = true
            $0.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.8)
            $0.text = ""
            $0.textAlignment = .center
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(statusLabel.snp.bottom).offset(6)
                make.centerX.equalToSuperview()
            }
        }
        
        btnBack >>> self >>> {
            $0.tintColor = .white
            $0.setImage(UIImage(named: "ic_arrow_back"), for: .normal)
            $0.snp.makeConstraints { (make) in
                make.left.equalToSuperview()
                make.centerY.equalTo(progressView.snp.centerY)
                make.size.equalTo(CGSize(width: 56, height: 44))
            }
        }
    }
}


extension TrackingHeaderView: UpdateDisplayProtocol {
    
    func setupDisplay(item: OrderStatus?) {
        guard let status = item?.status.status else {
            return
        }
        let progress: CGFloat
        switch status {
        case .FIND_DRIVER:
            progress = 0.5
        case .PAYMENT_SUCCESS, .PENDING_PAYMENT, .MERCHANT_ACCEPTED, .NEW:
            progress = 0.25
        case .COMPLETE:
            progress = 1
        default:
            progress = 0.75
        }
        lblCodeOrder.text = "Mã đơn: \(item?.status.code ?? "")"
        progressView?.update(progress: progress)
        statusLabel.text = item?.description
        
    }
}
