//  File name   : PaymentMethodManageVC.swift
//
//  Author      : Dung Vu
//  Created date: 3/5/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import RxCocoa
import UIKit
import FwiCore
import Kingfisher

enum PaymentCardType: Int, CaseIterable, Comparable {
    static func ==(lhs: PaymentCardType, rhs: PaymentCardType) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    
    static func <(lhs: PaymentCardType, rhs: PaymentCardType) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    case none = -1
    case cash = 0
    case vatoPay = 1
    case visa = 3
    case master = 4
    case atm = 5
    case momo = 6
    case zaloPay = 7
    case addCardVisaMaster = 8
    case addCardATM = 9
    
    var icon: UIImage? {
        switch self {
        case .visa, .addCardVisaMaster:
            return UIImage(named: "ic_method_0")
        case .master:
            return UIImage(named: "ic_method_1")
        case .atm, .addCardATM:
            return UIImage(named: "ic_method_3")
        default:
            return nil
        }
    }
    
    var identifier: String? {
        switch self {
        case .cash:
            return "cash"
        case .vatoPay:
            return "vatopay"
        case .zaloPay:
            return "zalopay"
        case .momo:
            return "momo"
        case .atm:
            return "atm"
        default:
            return nil
        }
    }
    
    var method: PaymentMethod? {
        return PaymentMethod(rawValue: self.rawValue)
    }
    
    var color: UIColor {
        switch self {
        case .vatoPay:
            return #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1)
        default:
            return #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
        }
    }
    
    var generalName: String {
        switch self {
        case .none:
            return ""
        case .cash:
            return Text.cash.localizedText
        case .vatoPay:
            return Text.wallet.localizedText
        case .visa:
            return "Visa/MasterCard"
        case .master:
            return "Visa/MasterCard"
        case .atm:
            return "ATM"
        case .zaloPay:
            return "ZaloPay"
        case .momo:
            return "Momo"
        case .addCardVisaMaster:
            return FwiLocale.localized("Thêm Visa/Master")
        case .addCardATM:
            return FwiLocale.localized("Thêm ATM")
        }
    }
}

protocol PaymentCardDisplay {
    var name: String { get }
    var iconUrl: String? { get }
    var placeHolder: String { get }
    var type: PaymentCardType { get }
    var brand: String? { get }
}

final class PaymentManageCardCell: UITableViewCell {
    private var iconView: UIImageView?
    private var lblTitle: UILabel?
    private var currentTask: DownloadTask?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        common()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func common() {
        let iconView = UIImageView(frame: .zero) >>> contentView >>> {
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(16)
                make.centerY.equalToSuperview()
                make.size.equalTo(CGSize(width: 46, height: 36))
            })
        }
        
        self.iconView = iconView
        
        let arrow = UIImageView(image: UIImage(named: "ic_chevron_right")) >>> contentView >>> {
            $0.contentMode = .scaleAspectFit
            $0.snp.makeConstraints({ (make) in
                make.right.equalTo(-25)
                make.size.equalTo(CGSize(width: 8, height: 14))
                make.centerY.equalToSuperview()
            })
        }
        
        let lblTitle = UILabel.create {
            $0.font = UIFont.systemFont(ofSize: 16)
            $0.textColor = .black
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            } >>> contentView >>> {
                $0.snp.makeConstraints({ (make) in
                    make.left.equalTo(74)
                    make.right.equalTo(arrow.snp.left).offset(-5).priority(.high)
                    make.centerY.equalToSuperview()
                })
        }
        
        self.lblTitle = lblTitle
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.currentTask?.cancel()
        self.iconView?.image = nil
    }
    
    func setupDisplay(by item: PaymentCardDisplay) {
        let b = item.brand ?? ""
        self.lblTitle?.text = "\(b) **** \(item.name.suffix(4))"
        if let url = URL(string: item.iconUrl.orNil("")) {
            self.currentTask = self.iconView?.kf.setImage(with: url)
        } else {
            self.iconView?.image = item.type.icon
        }
    }
}


protocol PaymentMethodManagePresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var source: Observable<[PaymentCardDisplay]> { get }
    var enableAddCard: Observable<Bool> { get }
    var loading: Observable<(Bool, Double)> { get }
    var error: Observable<Error> { get }
    func paymentCardDetail(at idx: IndexPath)
    func paymentManageMoveBack()
    func paymentAddCard()
    func loadData()
}

final class PaymentMethodManageVC: UIViewController, PaymentMethodManagePresentable, PaymentMethodManageViewControllable {
    
    struct Config {
        struct Button {
            static let add = Text.addVisaMaster.localizedText
        }
        
        struct NoItem {
            static let icon = "ic_cardEmpty"
            static let message = Text.listCardEmpty.localizedText
        }
        
        struct Title {
            static let name = Text.paymentMethod.localizedText
            static let list = Text.listCard.localizedText
        }
        
        struct Error {
            static let title = Text.error.localizedText
            static let messageError = Text.thereWasAnError.localizedText
            static let close = Text.dismiss.localizedText
        }
    }
    /// Class's public properties.
    weak var listener: PaymentMethodManagePresentableListener?
    private lazy var tableView: UITableView = UITableView(frame: .zero, style: .grouped)
    private lazy var noItemView = NoItemView(imageName: Config.NoItem.icon, message: Config.NoItem.message, on: tableView)
    private var source: [PaymentCardDisplay] = []
    private lazy var refreshControl: UIRefreshControl = {
        let r = UIRefreshControl(frame: .zero)
        self.tableView.addSubview(r)
        return r
    }()
    private lazy var disposeBag = DisposeBag()
    private var btnAdd: UIButton?

    // MARK: View's lifecycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        visualize()
        setupRX()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }
    
    deinit {
        printDebug("\(#function)")
    }

    /// Class's private properties.
}

// MARK: View's event handlers
extension PaymentMethodManageVC {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .`default`
    }
}


// MARK: Class's public methods
extension PaymentMethodManageVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        guard source.count > 0 else {
//            return nil
//        }
//        let view = UIView.create {
//            $0.backgroundColor = .clear
//        }
//
//        UILabel.create {
//            $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
//            $0.textColor = #colorLiteral(red: 0.3843137255, green: 0.4431372549, blue: 0.4980392157, alpha: 1)
//            $0.text = Config.Title.list
//            } >>> view >>> {
//                $0.snp.makeConstraints({ (make) in
//                    make.left.equalTo(16)
//                    make.bottom.equalTo(-4)
//                })
//        }
//        return view
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return self.source.count > 0 ? 40 : 0.1
        return 0.1
    }
}

// MARK: Class's private methods
private extension PaymentMethodManageVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        self.view.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        let navigationBar = self.navigationController?.navigationBar
        navigationBar?.barTintColor = Color.orange
        navigationBar?.isTranslucent = false
        navigationBar?.tintColor = .white
        self.title = Config.Title.list
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        self.tableView.backgroundColor = .clear
        
        let image = UIImage(named: "ic_close")?.withRenderingMode(.alwaysTemplate)
        let rightBarItem = UIBarButtonItem(image: image, landscapeImagePhone: image, style: .plain, target: nil, action: nil)
        self.navigationItem.leftBarButtonItem = rightBarItem
        
        rightBarItem.rx.tap.bind { [unowned self] in
            self.listener?.paymentManageMoveBack()
        }.disposed(by: disposeBag)
        
        let buttonAdd = UIButton.create {
            $0.applyButton(style: .default)
            $0.setTitle(Config.Button.add, for: .normal)
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentHuggingPriority(.defaultLow, for: .vertical)
            } >>> {
                $0.snp.makeConstraints({ (make) in
                    make.width.equalTo(UIScreen.main.bounds.width - 32)
                })
        }
        buttonAdd.isHidden = true
        self.btnAdd = buttonAdd
        
        let imgViews = (0...3).map { (idx) -> UIImageView in
            let name = idx == 3 ? "ic_atm_gray" : "ic_method_\(idx)"
            let image = UIImage(named: name)
            let imgView = UIImageView(image: image) >>> {
                $0.contentMode = .center
            }
            
            return imgView
        }
        
        let s = UIStackView(arrangedSubviews: imgViews)
        s.spacing = 20
        s.distribution = .fill
        s.axis = .horizontal
        
        let container = UIStackView(arrangedSubviews: [buttonAdd, s])
        
        container.axis = .vertical
        container.alignment = .center
        container.spacing = 0
        container.distribution = .fillEqually
        
        container >>> view >>> {
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.height.equalTo(96)
                make.bottom.equalToSuperview()
            })
        }
        
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 74, bottom: 0, right: 0)
        tableView.rowHeight = 69
        tableView.register(PaymentManageCardCell.self, forCellReuseIdentifier: PaymentManageCardCell.identifier)
        tableView >>> view >>> {
            $0.snp.makeConstraints({ (make) in
                make.top.equalToSuperview()
                make.left.equalToSuperview()
                make.right.equalToSuperview()
                make.bottom.equalTo(container.snp.top)
            })
        }
        
    }
    private func setupRX() {
        // todo: Bind data to UI here.
        self.tableView.rx.setDelegate(self).disposed(by: disposeBag)
        self.listener?.source.do(onNext: { [weak self](list) in
            guard let wSelf = self else { return }
            wSelf.source = list
        })
            .bind(to: tableView.rx.items(cellIdentifier: PaymentManageCardCell.identifier, cellType: PaymentManageCardCell.self))
        { (row, element, cell) in
            cell.setupDisplay(by: element)
        }.disposed(by: disposeBag)
        
        self.tableView.rx.itemSelected.bind { [unowned self] index in
            self.listener?.paymentCardDetail(at: index)
        }.disposed(by: disposeBag)
        
        self.listener?.source.map { $0.count > 0 }.subscribe(onNext: { [weak self] in
            guard let wSelf = self else { return }
            $0 ? wSelf.noItemView.detach() : wSelf.noItemView.attach()
        }).disposed(by: disposeBag)
        
        self.listener?.error.subscribe(onNext: { [weak self] _ in
            self?.alertError()
        }).disposed(by: disposeBag)
        
        refreshControl.rx.controlEvent(.valueChanged).bind { [unowned self](_) in
            self.refreshControl.beginRefreshing()
            self.listener?.loadData()
        }.disposed(by: disposeBag)
        
        self.listener?.loading.subscribe(onNext: { [weak self] (loading, progress) in
            guard let wSelf = self, wSelf.refreshControl.isRefreshing, !loading else { return }
            wSelf.refreshControl.endRefreshing()
        }).disposed(by: disposeBag)
        
        self.btnAdd?.rx.tap.bind { [unowned self] in
            self.alertAddCard()
        }.disposed(by: disposeBag)
        
//        guard let btnAdd = self.btnAdd else {
//            return
//        }
//
//        self.listener?.enableAddCard.bind(to: btnAdd.rx.isHidden).disposed(by: disposeBag)
        
    }
    
    private func alertAddCard() {
        AlertAddCardVC.show(onVC: self).delay(0.3, scheduler: MainScheduler.asyncInstance).bind { [weak self](state) in
            switch state {
            case .agree:
                self?.listener?.paymentAddCard()
            default: break
            }
        }.disposed(by: disposeBag)
    }
    
    private func alertError() {
        let action = AlertAction.init(style: .cancel, title: Config.Error.close) {}
        AlertVC.show(on: self, title: Config.Error.title, message: Config.Error.messageError, from: [action], orderType: .horizontal)
    }
}


