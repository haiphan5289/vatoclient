//  File name   : VatoPaymentMainCell.swift
//
//  Author      : Dung Vu
//  Created date: 8/26/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import FwiCore
import FwiCoreRX
import SnapKit
import Eureka
import RxSwift
import RxCocoa
import Kingfisher

// MARK: - Payment
final class VatoPaymentMainCell: Eureka.Cell<HomeResponse>, CellType, UpdateDisplayProtocol {
    private var paymentView: VatoHomePaymentTopView?
    private lazy var disposeBag = DisposeBag()
    
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        visualize()
    }
    private var callBack: BlockAction<VatoPayAction>?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func visualize() {
        selectionStyle = .none
        textLabel?.isHidden = true
        let paymentView = VatoHomePaymentTopView.loadXib()
        contentView.backgroundColor = .clear
        contentView.clipsToBounds = true
        paymentView.lblPrice?.textColor = #colorLiteral(red: 0, green: 0.3803921569, blue: 0.2392156863, alpha: 1)
        paymentView >>> contentView >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        self.paymentView = paymentView
        self.paymentView?.lblPrice?.text = 0.currency
        self.paymentView?.btnWallet?.rx.tap.bind(onNext: { [weak self] in
            self?.callBack?(VatoPayAction.wallet)
        }).disposed(by: disposeBag)
        paymentView.showProfile.bind { [weak self] in
            self?.callBack?(.profile)
        }.disposed(by: disposeBag)
    }
    
    func update(user: UserInfo) {
        self.paymentView?.update(user: user)
    }
    
    func setCallBack(_ block: BlockAction<VatoPayAction>?) {
        self.callBack = block
    }
    
    override func setup() {
        super.setup()
        height = { 68 }
    }
    
    func setupDisplay(item: HomeResponse?) {
        let items = item?.items ?? []
        guard let stackView = self.paymentView?.stackView else { return }
        if self.paymentView?.stackView?.arrangedSubviews.isEmpty == false {
            let views = stackView.arrangedSubviews
            views.forEach {
                stackView.removeArrangedSubview($0)
                $0.removeFromSuperview()
            }
        }
        
        struct Value {
            var type: VatoPayAction
            var title: String?
        }
        
        let types = items.compactMap { (item) -> Value? in
            guard let type = VatoPayAction(rawValue: item.id ?? 0) else { return nil }
            return Value(type: type, title: item.title)
        }
        
        types.forEach { type in
            let button = UIButton(frame: .zero)
            
            SettingImage: if type.type == .support {
                let listImage = UIImage.loadListImage(from: "ic_vato_list_animate")
                guard !listImage.isEmpty else { break SettingImage }
                let imageView = UIImageView(frame: .zero)
                imageView >>> button >>> {
                    $0.isUserInteractionEnabled = false
                    $0.contentMode = .scaleAspectFit
                    $0.animationImages = listImage
                    $0.animationDuration = 1.5
                    $0.startAnimating()
                    $0.snp.makeConstraints { (make) in
                        make.edges.equalTo(UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0))
                    }
                }
            } else {
                let view = IconTitlePaymentView(frame: .zero)
                view.imageView.image = type.type.image
                view.lblTitle.text = type.title
                let s = view.systemLayoutSizeFitting(CGSize(width: CGFloat.infinity, height: CGFloat.infinity), withHorizontalFittingPriority: .fittingSizeLevel, verticalFittingPriority: .fittingSizeLevel)
                view >>> button >>> {
                    $0.snp.makeConstraints({ (make) in
                        make.size.equalTo(s)
                        make.center.equalToSuperview()
                    })
                }
            }
            
            
            button.rx.tap.bind(onNext: { [weak self] in
                self?.callBack?(type.type)
            }).disposed(by: disposeBag)
            
            stackView.addArrangedSubview(button)
        }
        stackView.layoutIfNeeded()
    }
}

// MARK: - Service
final class VatoServiceCollectionCell: UICollectionViewCell {
    private (set) var iconTitleServiceView: IconTitleServiceView?
    var service: VatoServiceAction?
    var actived: Bool = true
    private var containerNumberItem: UIView?
    private var lblNumber: UILabel?
    override init(frame: CGRect) {
        super.init(frame: frame)
        visualize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func visualize() {
        let iconTitleServiceView = IconTitleServiceView(frame: .zero)
        iconTitleServiceView >>> contentView >>> {
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.snp.makeConstraints({ (make) in
                make.left.right.equalToSuperview()
                make.top.equalToSuperview()
            })
        }
        
        self.iconTitleServiceView = iconTitleServiceView
        let containerNumberItem = UIView(frame: .zero)
        containerNumberItem >>> iconTitleServiceView >>> {
            $0.isHidden = true
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 8
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.white.cgColor
            $0.backgroundColor = #colorLiteral(red: 0.9450980392, green: 0, blue: 0, alpha: 1)
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(iconTitleServiceView.iconNew.snp.top)
                make.right.equalTo(iconTitleServiceView.iconNew.snp.right)
            }
        }
        self.containerNumberItem = containerNumberItem
        
        let label: UILabel = UILabel(frame: .zero)
        label >>> containerNumberItem >>> {
            $0.font = UIFont.systemFont(ofSize: 10, weight: .bold)
            $0.textColor = .white
            $0.snp.makeConstraints { (make) in
                make.edges.equalTo(UIEdgeInsets(top: 2, left: 7, bottom: 2, right: 7))
            }
        }
        self.lblNumber = label
    }
    
   
    
    func setupDisplay(item: VatoServiceCell.Service) {
        self.service = item.type
        iconTitleServiceView?.lblTitle.text = item.title
        iconTitleServiceView?.imageView.image = item.type?.image
        iconTitleServiceView?.iconNew.isHidden = !item.isNew
        iconTitleServiceView?.stackView?.layoutIfNeeded()
        self.actived = item.actived
        let alpha: CGFloat = actived ? 1 : 0.6
        iconTitleServiceView?.alpha = alpha
        
        guard let erp = item.erpItem else { return }
        self.updateNumberCount(number: erp.new_notifications)
    }
    
    func updateNumberCount(number: Int) {
        self.containerNumberItem?.isHidden = !(number > 0)
        self.lblNumber?.text = number > 99 ? "99+" : "\(number)"
    }
}


final class VatoServiceCell: Eureka.Cell<[HomeItems]>, CellType, UpdateDisplayProtocol {
    struct Service {
        var title: String?
        let type: VatoServiceAction?
        let actived: Bool
        var isNew: Bool
        var erpItem: ERPItem?
    }
    
    struct Config {
        static let hItem = 100
        static let numberItemRow = 4
        static let numberItemColumn = 2
        static let numberItemPerPage = numberItemRow * numberItemColumn
    }
    
    
    private let collectionView: UICollectionView
    private lazy var disposeBag = DisposeBag()
    private var source: [Service] = []
    var callBack: BlockAction<VatoServiceCell.Service>?
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.collectionView.backgroundColor = .white
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.showsVerticalScrollIndicator = false
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
        self.collectionView.register(VatoServiceCollectionCell.self, forCellWithReuseIdentifier: VatoServiceCollectionCell.identifier)
        collectionView >>> contentView >>> {
            $0.snp.makeConstraints({ (make) in
                make.top.right.left.equalToSuperview()
                make.height.equalTo(0)
                make.bottom.equalToSuperview().priority(.high)
            })
        }
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
        collectionView.rx.setDataSource(self).disposed(by: disposeBag)
    }
    
    func setupDisplay(item: [HomeItems]?) {
        guard let item = item else {
            return
        }
        
        // cache
        let items = item.map {
            Service(title: $0.title, type: VatoServiceAction(rawValue: $0.id ?? 0), actived: $0.isActived, isNew: $0.isNew ?? false, erpItem: $0.erp)
        }
        source = items
        let number = items.count
        var rows = number / Config.numberItemRow
        if number % Config.numberItemRow != 0 {
            rows += 1
        }
        
        let h = rows * Config.hItem + (rows - 1) * 5 + 32
        self.collectionView.snp.updateConstraints { (make) in
            make.height.equalTo(h)
        }
        
        self.collectionView.reloadData()
    }
    
    private func setupRX() {
        self.collectionView.rx.itemSelected.map { [unowned self] index -> Service? in
            return self.source[safe: index.item]
        }
        .filterNil()
        .bind { [weak self](s) in
            guard s.actived else {
                return
            }
            self?.callBack?(s)
        }.disposed(by: disposeBag)
    }
}

extension VatoServiceCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = (UIScreen.main.bounds.width - 32) / CGFloat(Config.numberItemRow)
        return CGSize(width: max(w, 0), height: CGFloat(Config.hItem))
    }
}

extension VatoServiceCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return source.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VatoServiceCollectionCell.identifier, for: indexPath) as? VatoServiceCollectionCell else {
            fatalError("Please Implement")
        }
        if let item = source[safe: indexPath.item] {
            cell.setupDisplay(item: item)
        }
        return cell
    }
}

// MARK: - Promotion
final class VatoPromotionCollectionCell: UICollectionViewCell {
    lazy var imageView = UIImageView(frame: .zero)
    lazy var lblTitle = UILabel(frame: .zero)
    lazy var lblDescription = UILabel(frame: .zero)
    private var task: DownloadTask?
    override init(frame: CGRect) {
        super.init(frame: frame)
        visualize()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        task?.cancel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func visualize() {
        let containerView = UIView(frame: .zero)
        containerView >>> contentView >>> {
            $0.layer.cornerRadius = 6
            $0.clipsToBounds = true
            $0.layer.borderWidth = 1
            $0.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        
        imageView >>> containerView >>> {
            $0.kf.indicatorType = .activity
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.snp.makeConstraints({ (make) in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(120)
            })
        }
        
        lblTitle >>> containerView >>> {
            $0.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(12)
                make.right.equalTo(-12)
                make.top.equalTo(imageView.snp.bottom).offset(12)
            })
        }
        
        lblDescription >>> containerView >>> {
            $0.numberOfLines = 2
            $0.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(lblTitle.snp.bottom).offset(8)
                make.left.equalTo(12)
                make.right.equalTo(-12)
            })
        }
    }
    
    func setupDisplay(item: HomeItems) {
        imageView.setImage(from: item, placeholder: nil, size: CGSize(width: 260, height: 120))
        lblTitle.text = item.title
        lblDescription.text = item.description
    }
}

final class VatoPromotionCell: Eureka.Cell<HomeResponse>, CellType, UpdateDisplayProtocol {
    private let collectionView: UICollectionView
    private lazy var lblTitle: UILabel = UILabel(frame: .zero)
    private lazy var disposeBag = DisposeBag()
    var callBack: BlockAction<Int>?
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.itemSize = CGSize(width: 260, height: 200)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.collectionView.backgroundColor = .white
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.showsVerticalScrollIndicator = false
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        visualize()
        setupRX()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        super.setup()
        height = { 296 }
    }
    
    private func setupRX() {
        collectionView.rx.itemSelected.bind { [weak self](idx) in
            self?.callBack?(idx.item)
        }.disposed(by: disposeBag)
    }
    
    
    private func visualize() {
        selectionStyle = .none
        textLabel?.isHidden = true
        lblTitle >>> contentView >>> {
            $0.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 20, weight: .regular)
            $0.snp.makeConstraints({ (make) in
                make.left.top.equalTo(16)
            })
        }
        
        self.collectionView.register(VatoPromotionCollectionCell.self, forCellWithReuseIdentifier: VatoPromotionCollectionCell.identifier)
        collectionView >>> contentView >>> {
            $0.snp.makeConstraints({ (make) in
                make.left.right.equalToSuperview()
                make.top.equalTo(lblTitle.snp.bottom).offset(16)
                make.height.equalTo(205)
            })
        }
        contentView.addSeperator(position: .top)
    }
    
    
    func setupDisplay(item: HomeResponse?) {
        lblTitle.text = item?.name
        guard let item = item?.items else {
            return
        }
        Observable.just(item).bind(to: self.collectionView.rx.items(cellIdentifier: VatoPromotionCollectionCell.identifier, cellType: VatoPromotionCollectionCell.self)) {
            idx, element, cell in
            cell.setupDisplay(item: element)
        }.disposed(by: disposeBag)
    }
}

final class VatoItemDisplayCell: Eureka.Cell<HomeItems>, CellType, UpdateDisplayProtocol {
    private var contentImageView: UIImageView?
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        visualize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        super.setup()
        height = { 168 }
    }
    
    private func visualize() {
       textLabel?.isHidden = true
       selectionStyle = .none
       let contentImageView = UIImageView(frame: .zero)
       contentImageView >>> contentView >>> {
            $0.kf.indicatorType = .activity
            $0.layer.cornerRadius = 6
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(16)
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.bottom.equalToSuperview()
            })
       }
       self.contentImageView = contentImageView
    }
    
    func setupDisplay(item: HomeItems?) {
        contentImageView?.setImage(from: item, placeholder: nil, size: CGSize(width: UIScreen.main.bounds.width - 32, height: 152))
    }
}

final class VatoItemBannerCell: Eureka.Cell<[HomeItems]>, CellType, UpdateDisplayProtocol {
    private lazy var view = FoodBannerView.loadXib()
    var callBack: BlockAction<HomeItems>?
    
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
        view >>> contentView >>> {
            $0.roundAll = true
            $0.snp.makeConstraints({ (make) in
                make.top.equalToSuperview()
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.bottom.equalTo(-2).priority(.high)
            })
        }
        
        view.callback = { [weak self] item in
            guard let i = item as? HomeItems else {
                return
            }
            self?.callBack?(i)
        }
    }
    
    func setupDisplay(item: [HomeItems]?) {
        view.setupDisplay(item: item)
    }
    
    override func setup() {
        super.setup()
        height = { 232 }
    }
}

