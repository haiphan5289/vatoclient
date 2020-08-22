//  File name   : BankSelectControl.swift
//
//  Author      : Dung Vu
//  Created date: 11/8/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vu Dang. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import SnapKit
import Kingfisher

final class BankSelectControl: UIControl {
    /// Class's public properties.
    override var isSelected: Bool {
        didSet {
            imgViewSelect?.isHighlighted = isSelected
            self.sendActions(for: .valueChanged)
        }
    }

    var urlImage: URL? {
        didSet {
            self.iconImg?.kf.setImage(with: urlImage, placeholder: #imageLiteral(resourceName: "ic_bank"), options: [.fromMemoryCacheOrRefresh])
        }
    }

    var title: String? {
        didSet {
            self.lblDescription?.text = title
        }
    }

    /// Class's constructors.
    convenience init(with imgURL: URL?, title: String?, isSelected: Bool = false, arrow hide: Bool = false) {
        self.init(frame: .zero)
        initialize()
        self.iconImg?.image = #imageLiteral(resourceName: "ic_bank")
        self.urlImage = imgURL
        self.title = title
        self.isSelected = isSelected
        self.arrowImg?.isHidden = hide
    }

    // MARK: Class's public methods
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }
    
    /// Class's private properties.
    var iconImg: UIImageView?
    private var imgViewSelect: UIImageView?
    private var lblDescription: UILabel?
    private (set)var arrowImg: UIImageView?
}

// MARK: Class's private methods
private extension BankSelectControl {
    private func initialize() {
        // todo: Initialize view's here.
        let viewBank = UIView.create {
            $0.isUserInteractionEnabled = false
            $0.cornerRadius = 4
            $0.borderWidth = 1
            $0.borderColor = .clear
            } >>> self >>> {
                $0.snp.makeConstraints({ (make) in
                    make.left.equalToSuperview()
                    make.centerY.equalToSuperview()
                    make.size.equalTo(CGSize(width: 64, height: 32))
                })
        }
        
        let imgView = UIImageView.create {
            $0.contentMode = .scaleAspectFit
            $0.isUserInteractionEnabled = false
            $0 >>> viewBank >>> {
                $0.snp.makeConstraints({ (make) in
                    make.center.equalToSuperview()
                    make.size.equalTo(CGSize(width: 60, height: 24))
                })
            }
        }
        iconImg = imgView
        
        let imgArrow = #imageLiteral(resourceName: "next-g")
        let arrowImg = UIImageView.create {
            $0.contentMode = .scaleAspectFit
            $0.image = imgArrow
            $0.isUserInteractionEnabled = false
            } >>> self >>> {
                $0.snp.makeConstraints({ (make) in
                    make.right.equalTo(-16)
                    make.centerY.equalToSuperview()
                    make.size.equalTo(CGSize(width: 16, height: 16))
                })
        }
        
        self.arrowImg = arrowImg
        
        let imgCheck = #imageLiteral(resourceName: "ic_check")
        let checkImg = UIImageView.create {
            $0.contentMode = .scaleAspectFit
            $0.image = nil
            $0.highlightedImage = imgCheck
            $0.image = UIImage(named: "ic_category_deSelected")
            $0.isUserInteractionEnabled = false
        } >>> self >>> {
            $0.snp.makeConstraints({ (make) in
                make.right.equalTo(arrowImg.snp.right)
                make.centerY.equalToSuperview()
                make.size.equalTo(CGSize(width: 16, height: 16))
            })
        }
        
        imgViewSelect = checkImg
        
        let lblDescription = UILabel.create {
            $0.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            $0.textColor = #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1)
            $0.isUserInteractionEnabled = false
            } >>> self >>> {
                $0.snp.makeConstraints({ (make) in
                    make.left.equalTo(imgView.snp.right).offset(8)
                    make.centerY.equalToSuperview()
                    make.right.equalTo(checkImg.snp.left).offset(-5)
                })
        }
        
        self.lblDescription = lblDescription
    }
}
