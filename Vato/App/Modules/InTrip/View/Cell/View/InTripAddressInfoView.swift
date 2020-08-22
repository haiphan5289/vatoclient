//  File name   : InTripAddressInfoView.swift
//
//  Author      : Dung Vu
//  Created date: 3/16/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import FwiCore
import SnapKit

enum InTripAddressViewType {
    case original
    case destination
    case other(idx: Int)
    
    var icon: UIImage? {
        switch self {
        case .original:
            return UIImage(named: "ic_origin")
        case .destination:
            return UIImage(named: "ic_destination")
        case .other:
            return UIImage(named: "ic_destination")
        }
    }
}

fileprivate final class InTripAddressDetailView: UIView {
    private (set) lazy var iconView: UIImageView = UIImageView(frame: .zero)
    private (set) lazy var lblAdress: UILabel = UILabel(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        visualize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func visualize() {
        let cView = UIView(frame: .zero)
        cView.backgroundColor = .white
        cView.setContentHuggingPriority(.required, for: .horizontal)
        iconView >>> cView >>> {
            $0.contentMode = .scaleAspectFit
            $0.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 16, height: 18))
                make.left.top.right.equalToSuperview()
            }
        }
        
        lblAdress >>> {
            $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            $0.numberOfLines = 0
            $0.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentHuggingPriority(.required, for: .vertical)
        }
        
        let stackView = UIStackView(arrangedSubviews: [cView, lblAdress])
        stackView >>> self >>> {
            $0.distribution = .fill
            $0.axis = .horizontal
            $0.spacing = 12
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
    
    func update(type: InTripAddressViewType, address: String?) {
        iconView.image = type.icon
        lblAdress.text = address
    }
}

final class InTripAddressInfoView: UIView, UpdateDisplayProtocol {
    /// Class's public properties.
    private lazy var stackView = UIStackView(frame: .zero)

    /// Class's private properties.
    override init(frame: CGRect) {
        super.init(frame: frame)
        visualize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func visualize() {
        stackView >>> self >>> {
            $0.distribution = .fill
            $0.axis = .vertical
            $0.spacing = 16
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.snp.makeConstraints { (make) in
                make.edges.equalTo(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
            }
        }
    }
    
    func setupDisplay(item: [String]?) {
        guard let items = item, !items.isEmpty else {
            return assert(false, "Check !!!")
        }
        
        var f: InTripAddressDetailView?
        items.enumerated().forEach { (element) in
            let v = InTripAddressDetailView(frame: .zero)
            switch element.offset {
            case 0:
                v.update(type: .original, address: element.element)
                stackView.addArrangedSubview(v)
            default:
                guard let b = f else { fatalError("wrong logic") }
                v.update(type: .destination, address: element.element)
                stackView.addArrangedSubview(v)
                let lineView = UIImageView(image: UIImage(named: "ic_intrip_line"))
                lineView.contentMode = .scaleAspectFill
                lineView.clipsToBounds = true
                lineView >>> self >>> {
                    $0.setContentHuggingPriority(.defaultLow, for: .vertical)
                    $0.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
                    $0.snp.makeConstraints { (make) in
                        make.top.equalTo(b.iconView.snp.bottom).offset(4)
                        make.width.equalTo(2)
                        make.centerX.equalTo(b.iconView.snp.centerX)
                        make.bottom.equalTo(v.iconView.snp.top).offset(-4)
                    }
                }
            }
            f = v
        }
    }
}


