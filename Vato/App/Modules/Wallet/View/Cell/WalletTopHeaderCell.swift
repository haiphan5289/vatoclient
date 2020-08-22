//  File name   : WalletTopHeaderCell.swift
//
//  Author      : Dung Vu
//  Created date: 4/27/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import Eureka
import SnapKit
import Atributika
import RxSwift
import RxCocoa
import GSKStretchyHeaderView
import FwiCore

// MARK: -- Header
final class WalletTopHeaderView: GSKStretchyHeaderView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        visualize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func visualize() {
        minimumContentHeight = 0
        let view = UIImageView(image: UIImage(named:"bg_navigationbar"))
        view >>> contentView >>> {
            $0.contentMode = .scaleToFill
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
    }
}

final class WalletTopHeaderCell: Eureka.Cell<String>, CellType, UpdateDisplayProtocol {
    private lazy var lblWallet: UILabel = UILabel(frame: .zero)
    private lazy var bgView: UIImageView = UIImageView(frame: .zero)
    private (set) lazy var btnTopUp: UIButton = UIButton(frame: .zero)
    
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
        let bgImage = UIImage(named:"bg_navigationbar")?.stretchableImage(withLeftCapWidth: 0, topCapHeight: 0)
        bgView >>> contentView >>> {
            $0.image = bgImage
            $0.contentMode = .scaleAspectFill
            $0.snp.makeConstraints { (make) in
                make.left.top.right.equalToSuperview()
                make.height.equalTo(83)
            }
        }
        
        lblWallet >>> contentView >>> {
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.font = UIFont.systemFont(ofSize: 32, weight: .medium)
            $0.textAlignment = .center
            $0.textColor = .white
            $0.snp.makeConstraints { (make) in
                make.left.top.right.equalToSuperview()
            }
        }
        
        btnTopUp >>> contentView >>> {
            $0.backgroundColor = .white
            $0.setImage(UIImage(named: "ic_topup_wallet"), for: .normal)
            $0.setTitle(Text.topUpNow.localizedText, for: .normal)
            $0.setTitleColor(#colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1), for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 7, bottom: 0, right: 0)
            $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            $0.layer.cornerRadius = 24
            $0.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.24)
            $0.shadowOpacity = 1
            $0.shadowRadius = 2
            $0.shadowOffset = CGSize(width: -1, height: 1)
            $0.snp.makeConstraints { (make) in
                make.centerY.equalTo(bgView.snp.bottom)
                make.centerX.equalToSuperview()
                make.width.equalTo(UIScreen.main.bounds.width - 32)
                make.height.equalTo(48)
                make.bottom.equalTo(-16).priority(.high)
            }
        }
    }
    
    func setupDisplay(item: String?) {
        lblWallet.text = item
    }
    
}

// MARK: -- Title Napas
final class WalletTitleNapasCell: Eureka.Cell<String>, CellType {
    struct Configs {
        static let titleText = Text.addCardByGateway.localizedText
    }
    
    private lazy var lblTitle: UILabel = UILabel(frame: .zero)
    private lazy var iconView: UIImageView = UIImageView(frame: .zero)
    
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
        lblTitle >>> {
            $0.text = Configs.titleText
            $0.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            $0.setContentHuggingPriority(.required, for: .horizontal)
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
            let w = UIScreen.main.bounds.width - 123
            $0.snp.makeConstraints { (make) in
                make.width.lessThanOrEqualTo(w)
            }
        }
        
        iconView >>> {
            $0.contentMode = .scaleAspectFill
            $0.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 91, height: 24))
            }
        }
        
        let stackView = UIStackView(arrangedSubviews: [lblTitle, iconView])
        stackView >>> contentView >>> {
            $0.axis = .horizontal
            $0.spacing = 8
            $0.distribution = .fill
            
            $0.snp.makeConstraints { (make) in
                make.left.equalTo(16)
                make.top.equalToSuperview()
                make.bottom.equalTo(-16)
            }
        }
    }
}

// MARK: -- Cell Method Napas
final class WalletMethodNapasCell: Eureka.Cell<String>, CellType, UpdateDisplayProtocol {
    private (set) lazy var iconView: UIImageView = UIImageView(frame: .zero)
    private lazy var lblTitle: UILabel = UILabel(frame: .zero)
    private lazy var arrowView: UIImageView = UIImageView(frame: .zero)
    
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
        
        iconView >>> {
            $0.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 40, height: 40))
            }
        }
        
        lblTitle >>> {
            $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentHuggingPriority(.defaultLow, for: .vertical)
        }
        
        arrowView >>> contentView >>> {
            $0.image = UIImage(named: "ic_form_more")
            $0.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.right.equalTo(-8)
                make.size.equalTo(CGSize(width: 24, height: 24))
            }
        }
        
        let stackView = UIStackView(arrangedSubviews: [iconView, lblTitle])
        stackView >>> contentView >>> {
            $0.distribution = .fill
            $0.axis = .horizontal
            $0.spacing = 12
            $0.snp.makeConstraints { (make) in
                make.left.top.equalTo(16)
                make.bottom.equalTo(-16).priority(.high)
                make.right.equalTo(arrowView.snp.left).offset(-16)
            }
        }
        
        contentView.addSeperator(with: UIEdgeInsets(top: 0, left: 74, bottom: 0, right: 0))
        
    }
    
    func setupDisplay(item: String?) {
        lblTitle.text = item
    }
}

// MARK: -- Wallet Term
final class WalletTermCell:Eureka.Cell<Bool>, CellType, Weakifiable, UpdateDisplayProtocol {
    private (set)lazy var lblTerm: AttributedLabel = AttributedLabel(frame: .zero)
    private lazy var btnAgree: UIButton = UIButton(frame: .zero)
    private lazy var disposeBag = DisposeBag()
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        visualize()
        setupRX()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func visualize() {
        selectionStyle = .none
        textLabel?.isHidden = true
        
        lblTerm >>> contentView >>> {
            $0.numberOfLines = 0
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.snp.makeConstraints { (make) in
                make.left.top.equalTo(16)
                make.right.equalTo(-16)
            }
        }
        
        btnAgree >>> contentView >>> {
            $0.setImage(UIImage(named: "ic_unchecked_napas"), for: .normal)
            $0.setImage(UIImage(named: "ic_checked_napas"), for: .selected)
            $0.setTitle(Text.addCardAgreeTerm.localizedText, for: .normal)
            $0.setTitleColor(#colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1), for: .normal)
            $0.isSelected = true
            $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 7, bottom: 0, right: 0)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            $0.contentHorizontalAlignment = .left
            $0.snp.makeConstraints { (make) in
                make.left.equalTo(16)
                make.height.equalTo(56)
                make.right.equalTo(-16)
                make.top.equalTo(lblTerm.snp.bottom)
                make.bottom.equalToSuperview().priority(.high)
            }
        }
        let s = "<b>\(Text.byPress.localizedText)\(Text.argreeWith.localizedText) <a href=\"https://vato.vn/thoa-thuan-su-dung-vatopay/\">\(Text.termOfUse.localizedText)</a>\(Text.ofVatoPay.localizedText)</b>"
        let text = [s, Text.onlyPayVisa.localizedText, Text.addCardSupport4.localizedText, Text.addCardSupport3.localizedText, FwiLocale.localized("Đồng ý cho VATO thực hiện các thanh toán tự động cho chuyến đi khi chọn thanh toán qua thẻ")].joined(separator: "\n- ")

        let p = NSMutableParagraphStyle()
        p.lineSpacing = 5
        p.alignment = .left
        let a = Atributika.Style("a").foregroundColor(#colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1), .normal).foregroundColor(#colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1), .highlighted).underlineStyle(.single)
        let b = Atributika.Style("b").foregroundColor(#colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)).font(.systemFont(ofSize: 15, weight: .medium))
        let all = Atributika.Style.foregroundColor(#colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)).font(.systemFont(ofSize: 15, weight: .regular)).paragraphStyle(p)
        let att = text.style(tags: a, b).styleAll(all)
        
        lblTerm.attributedText = att
        contentView.addSeperator()
    }
    
    func setupDisplay(item: Bool?) {
        btnAgree.isSelected = item ?? false
    }
    
    private func setupRX() {
        btnAgree.rx.tap.scan(true) { (old, _) -> Bool in
            return !old
        }.bind(onNext: weakify({ (v, wSelf) in
            wSelf.row.value = v
        })).disposed(by: disposeBag)
    }
}

// MARK: -- List Card
final class WalletListCardCVC: UICollectionViewCell, UpdateDisplayProtocol {
    private lazy var bgView: UIView = UIView(frame: .zero)
    private lazy var iconView: UIImageView = UIImageView(frame: .zero)
    private lazy var lblTitleCard: UILabel = UILabel(frame: .zero)
    private lazy var lblNumberCard: UILabel = UILabel(frame: .zero)
    
    override var isSelected: Bool {
        didSet {
            let colorBorder = isSelected ? #colorLiteral(red: 0.9725490196, green: 0.7450980392, blue: 0.6705882353, alpha: 1) : #colorLiteral(red: 0.9215686275, green: 0.9294117647, blue: 0.9333333333, alpha: 1)
            let colorBg = isSelected ? #colorLiteral(red: 0.9921568627, green: 0.9294117647, blue: 0.9098039216, alpha: 1) : #colorLiteral(red: 0.9725490196, green: 0.9764705882, blue: 0.9764705882, alpha: 1)
            bgView.backgroundColor = colorBg
            bgView.layer.borderColor = colorBorder.cgColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        visualize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func visualize() {
        bgView >>> contentView >>> {
            $0.backgroundColor = #colorLiteral(red: 0.9725490196, green: 0.9764705882, blue: 0.9764705882, alpha: 1)
            $0.layer.borderColor = #colorLiteral(red: 0.9215686275, green: 0.9294117647, blue: 0.9333333333, alpha: 1)
            $0.layer.cornerRadius = 8
            $0.clipsToBounds = true
            $0.layer.borderWidth = 1
            $0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
        
        iconView >>> contentView >>> {
            $0.snp.makeConstraints { (make) in
                make.left.top.equalTo(10)
                make.size.equalTo(CGSize(width: 40, height: 40))
            }
        }
        
        lblTitleCard >>> {
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
        }
        
        lblNumberCard >>> {
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            $0.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
        }
        
        let stackView = UIStackView(arrangedSubviews: [lblTitleCard, lblNumberCard])
        stackView >>> contentView >>> {
            $0.axis = .vertical
            $0.spacing = 4
            $0.distribution = .fill
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(iconView.snp.top)
                make.left.equalTo(iconView.snp.right).offset(8)
                make.right.equalTo(-16)
            }
        }
    }
    
    func setupDisplay(item: PaymentCardDetail?) {
        lblTitleCard.text = item?.brand
        let number = item?.number ?? ""
        let last = number.suffix(4)
        let text = "**** \(last)"
        lblNumberCard.text = text
        iconView.setImage(from: item, placeholder: UIImage(named: item?.placeHolder ?? ""), size: CGSize(width: 40, height: 40))
    }
}

final class WalletListCardCell: Eureka.Cell<[PaymentCardDetail]>, CellType, UpdateDisplayProtocol {
    private let collectionView: UICollectionView
    private lazy var lblTitle: UILabel = UILabel(frame: .zero)
    private (set) lazy var btnMore: UIButton = UIButton(frame: .zero)
    private lazy var events: PublishSubject<[PaymentCardDetail]> = PublishSubject()
    private lazy var disposeBag = DisposeBag()
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 204, height: 60)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        visualize()
        setupRX()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupRX() {
        events.bind(to: collectionView.rx.items(cellIdentifier: WalletListCardCVC.identifier, cellType: WalletListCardCVC.self)) { idx, element, cell in
            cell.setupDisplay(item: element)
        }.disposed(by: disposeBag)
    }
    
    private func visualize() {
        selectionStyle = .none
        textLabel?.isHidden = true
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        lblTitle >>> contentView >>> {
            $0.text = Text.listCard.localizedText
            $0.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            $0.snp.makeConstraints { (make) in
                make.left.equalTo(16)
                make.top.equalToSuperview()
            }
        }
        
        btnMore >>> contentView >>> {
            $0.setTitleColor(#colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1), for: .normal)
            $0.setTitle(Text.seeMore.localizedText, for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
            $0.snp.makeConstraints { (make) in
                make.right.equalTo(-16)
                make.centerY.equalTo(lblTitle.snp.centerY)
            }
        }
        
        collectionView >>> contentView >>> {
            $0.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.top.equalTo(lblTitle.snp.bottom).offset(14).priority(.high)
                make.height.equalTo(65)
            }
        }
        
        let lineView = UIView(frame: .zero)
        lineView >>> contentView >>> {
            $0.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(collectionView.snp.bottom).offset(14)
                make.left.right.equalToSuperview()
                make.height.equalTo(10)
                make.bottom.equalTo(-16).priority(.high)
            }
        }
        lineView.addSeperator(position: .top)
        lineView.addSeperator()
        
        collectionView.register(WalletListCardCVC.self, forCellWithReuseIdentifier: WalletListCardCVC.identifier)
    }
    
    func setupDisplay(item: [PaymentCardDetail]?) {
        events.onNext(item ?? [])
    }
}


