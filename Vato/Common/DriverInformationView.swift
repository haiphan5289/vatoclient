//  File name   : DriverInformationView.swift
//
//  Author      : Dung Vu
//  Created date: 1/10/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import Kingfisher

enum DriverInformationStyle {
    case left
    case center
}

final class DriverInformationView: UIView {
    /// Class's public properties.
    private var rating: Int = 0
    
    private var starView: UIStackView?
    private (set) var lblName: UILabel?
    private (set) var avatarImageView: UIImageView?
    private (set) var lblTransport: UILabel?
    private let style: DriverInformationStyle
    private let sizeAvatar: CGSize
    private let sizeStar: CGSize
    private lazy var placeHolderImage = UIImage(named: "avatar-holder")

    /// Class's private properties.
    init(by style: DriverInformationStyle,
         sizeAvatar: CGSize = CGSize(width: 56, height: 56),
         sizeStar: CGSize = CGSize(width: 14, height: 14))
    {
        self.style = style
        self.sizeAvatar = sizeAvatar
        self.sizeStar = sizeStar
        super.init(frame: .zero)
        prepareLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func prepareLayout() {
        let avatarImageView = UIImageView.create {
            $0.cornerRadius = sizeAvatar.width / 2
            $0.layer.borderColor = Color.orange.cgColor
            $0.layer.borderWidth = 1.0
            $0.image = placeHolderImage
        } >>> self
        
        self.avatarImageView = avatarImageView
        
        let lblName = UILabel.create {
            $0.font = UIFont.systemFont(ofSize: 16)
            $0.textColor = .black
            $0.text = " "
        } >>> self
        
        self.lblName = lblName
        
        let lblTransport = UILabel.create {
            $0.font = UIFont.systemFont(ofSize: 14)
            $0.textColor = #colorLiteral(red: 0.3843137255, green: 0.4431372549, blue: 0.4980392157, alpha: 1)
            $0.text = " "
        } >>> self
        
        self.lblTransport = lblTransport
        
        let starView = UIStackView(arrangedSubviews: [])
        starView.axis = .horizontal
        starView.distribution = .fillProportionally
        starView.spacing = 5
        
        starView.snp.makeConstraints { (make) in
            make.height.equalTo(sizeStar.height)
        }
        
        self.starView = starView
        
        let container: UIStackView
        switch style {
        case .center:
            avatarImageView.snp.makeConstraints({ (make) in
                make.size.equalTo(sizeAvatar)
            })
            
            container = UIStackView(arrangedSubviews: [avatarImageView, lblName, lblTransport, starView])
            container.axis = .vertical
            container.distribution = .fillProportionally
            container.alignment = .center
            container.spacing = 12
            
            container >>> self >>> {
                $0.snp.makeConstraints({ (make) in
                    make.top.equalToSuperview()
                    make.left.equalToSuperview()
                    make.right.equalToSuperview()
                    make.bottom.equalToSuperview()
                })
            }
        case .left:
            avatarImageView.snp.makeConstraints { (make) in
                make.size.equalTo(sizeAvatar)
                make.centerY.equalToSuperview()
                make.left.equalTo(16)
            }
            
            container = UIStackView(arrangedSubviews: [lblName, lblTransport, starView])
            container.axis = .vertical
            container.alignment = .leading
            container.spacing = 6
            
            container >>> self >>> {
                $0.snp.makeConstraints({ (make) in
                    make.left.equalTo(avatarImageView.snp.right).offset(12)
                    make.top.equalTo(22.5)
                    make.bottom.equalTo(-16.4)
                })
            }
        }
    }
    
    func update(rating numberStar: Int) {
        precondition(numberStar >= 0 , " Please send correct data")
        let current = self.starView?.arrangedSubviews.count ?? 0
        guard current != numberStar, let starView = self.starView else {
            return
        }
        
        let range = numberStar - current
        if range > 0 {
            (0..<range).forEach { (idx) in
                let imageView = UIImageView() >>> {
                    $0.backgroundColor = .yellow
                    $0.snp.makeConstraints({ (make) in
                        make.width.equalTo(sizeStar.width)
                    })
                }
                
                starView.insertArrangedSubview(imageView, at: current + idx)
            }
        } else {
            let next = abs(range)
            (0..<next).forEach { (_) in
                let v = starView.arrangedSubviews[0]
                starView.removeArrangedSubview(v)
                v.removeFromSuperview()
            }
        }
        
    }
    
    func update(name fullName: String?) {
        self.lblName?.text = fullName
    }
    
    func update(transportNumber number: String?) {
        self.lblTransport?.text = number
    }
    
    func update(avatarUrl url: URL?) {
        self.avatarImageView?.kf.setImage(with: url, placeholder: placeHolderImage)
    }
}
