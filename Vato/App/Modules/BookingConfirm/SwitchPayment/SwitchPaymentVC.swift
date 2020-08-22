//  File name   : SwitchPaymentVC.swift
//
//  Author      : Dung Vu
//  Created date: 3/12/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import UIKit
import RxCocoa
import Kingfisher
import FwiCoreRX
import FwiCore
import Atributika

final class SwitchPaymentCell: UITableViewCell {
    private var iconView: UIImageView?
    private var lblTitle: UILabel?
    private var iconCheck: UIImageView?
    private var task: DownloadTask?
    
    override var isSelected: Bool {
        didSet {
            iconCheck?.isHighlighted = isSelected
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        visualize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.task?.cancel()
        self.iconView?.image = nil
        
    }
    
    private func visualize() {
        self.selectionStyle = .none
        let iconView = UIImageView(frame: .zero) >>> contentView >>> {
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(16)
                make.size.equalTo(CGSize(width: 46, height: 36))
                make.centerY.equalToSuperview()
            })
        }
        
        self.iconView = iconView
        
        let iconCheck = UIImageView.create {
            $0.highlightedImage = UIImage(named: "ic_payment_check")
            } >>> contentView >>> {
                $0.snp.makeConstraints({ (make) in
                    make.right.equalTo(-16)
                    make.size.equalTo(CGSize(width: 20, height: 20))
                    make.centerY.equalToSuperview()
                })
        }
        self.iconCheck = iconCheck
        
        let lblTitle = UILabel.create {
            $0.textColor = .black
            $0.font = UIFont.systemFont(ofSize: 16)
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            } >>> contentView >>> {
                $0.snp.makeConstraints({ (make) in
                    make.left.equalTo(74)
                    make.centerY.equalToSuperview()
                    make.right.equalTo(iconCheck.snp.left).offset(-5)
                })
        }
        self.lblTitle = lblTitle
    }
    
    func setupDisplay(by card: PaymentCardDetail) {
        let p = UIImage(named: card.placeHolder)
        self.iconView?.image = p
        let url = URL(string: card.iconUrl.orNil(""))
        self.task = self.iconView?.kf.setImage(with: url, placeholder: p)
        let brand = card.brand.orNil("")
        let number = card.number.orNil("")
        var text: String = brand
        if number.count > 0 {
            let last = number.suffix(4)
            text = text + " ***\(last)"
        }
        self.lblTitle?.text = text
    }
}

protocol SwitchPaymentPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var source: Observable<[PaymentDetailSection]> { get }
    var currentSelect: PaymentCardDetail? { get }
    var eLoadingObser: Observable<(Bool, Double)> { get }
    var error: Observable<Error> { get }
    var switchPaymentType: SwitchPaymentType { get }

    
    func switchPaymentMoveBack()
    func switchPaymentSelect(payment: PaymentCardDetail)
    func routeToAddPaymentMethod()
    func paymentAddCard()
}

final class SwitchPaymentVC: UIViewController, SwitchPaymentPresentable, SwitchPaymentViewControllable, LoadingAnimateProtocol, DisposableProtocol {

    struct Config {
        static let title = Text.paymentMethod.localizedText
        static let header = Text.selectPaymentMethod.localizedText.capitalized
        
        struct Error {
            static let title = Text.error.localizedText
            static let messageError = Text.thereWasAnError.localizedText
            static let close = Text.dismiss.localizedText
        }
    }
    
    /// Class's public properties.
    weak var listener: SwitchPaymentPresentableListener?
    private var mSource:[PaymentDetailSection] = [] {
        didSet {
            setupFooter()
        }
    }
    lazy var disposeBag = DisposeBag()
    
    private lazy var tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .grouped)
        t.rowHeight = 69
        t.separatorInset = UIEdgeInsets(top: 0, left: 74, bottom: 0, right: 0)
        return t
    }()
    
    
    private var addNewBtn = UIButton(frame: .zero)
    private var isAgreeCondition: Bool = true

    // MARK: View's lifecycle
    override func loadView() {
        super.loadView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SwitchPaymentCell.self, forCellReuseIdentifier: SwitchPaymentCell.identifier)
        tableView.register(CheckOutPaymentTVC.nib, forCellReuseIdentifier: CheckOutPaymentTVC.identifier)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }
    
    private func setupFooter() {
        if mSource.count > 1 {
            let contentView = UIView(frame: .zero)
            contentView.backgroundColor = .white

            let lblTerm = contentConditionLabel()
            lblTerm >>> contentView >>> {
                $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
                $0.setContentHuggingPriority(.required, for: .vertical)
                $0.snp.makeConstraints { (make) in
                    make.left.top.equalTo(16)
                    make.right.equalTo(-16)
                }
            }

            let btnAgree = UIButton(frame: .zero)
            btnAgree >>> contentView >>> {
                $0.setImage(UIImage(named: "ic_unchecked_napas"), for: .normal)
                $0.setImage(UIImage(named: "ic_checked_napas"), for: .selected)
                $0.setTitle(Text.addCardAgreeTerm.localizedText, for: .normal)
                $0.setTitleColor(#colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1), for: .normal)
                $0.isSelected = true
                isAgreeCondition = true
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
            
            btnAgree.rx.tap.scan(true) { (old, _) -> Bool in
                return !old
            }.bind(onNext: weakify({ (v, wSelf) in
                wSelf.isAgreeCondition = v
                btnAgree.isSelected = v
            })).disposed(by: disposeBag)

            let size = contentView.systemLayoutSizeFitting(CGSize(width: UIScreen.main.bounds.width, height: .infinity), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
            contentView.frame = CGRect(origin: .zero, size: size)
            
            tableView.tableFooterView = contentView
        } else {
            tableView.tableFooterView = nil
        }
    }
    
    private func contentConditionLabel() -> AttributedLabel {
        let lblTerm = AttributedLabel()
        lblTerm.numberOfLines = 0

        let s = "<b>\(Text.byPress.localizedText)\(Text.argreeWith.localizedText) <a href=\"https://vato.vn/thoa-thuan-su-dung-vatopay/\">\(Text.termOfUse.localizedText)</a>\(Text.ofVatoPay.localizedText)</b>"
        let text = [s, Text.onlyPayVisa.localizedText, Text.addCardSupport3.localizedText, FwiLocale.localized("Đồng ý cho VATO thực hiện các thanh toán tự động cho chuyến đi khi chọn thanh toán qua thẻ")].joined(separator: "\n- ")

        let p = NSMutableParagraphStyle()
        p.lineSpacing = 5
        p.alignment = .left
        let a = Atributika.Style("a").foregroundColor(#colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1), .normal).foregroundColor(#colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1), .highlighted).underlineStyle(.single)
        let b = Atributika.Style("b").foregroundColor(#colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)).font(.systemFont(ofSize: 15, weight: .medium))
        let all = Atributika.Style.foregroundColor(#colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)).font(.systemFont(ofSize: 15, weight: .regular)).paragraphStyle(p)
        let att = text.style(tags: a, b).styleAll(all)
        
        lblTerm.attributedText = att
        lblTerm.onClick = { [weak self] label, detection in
            switch detection.type {
            case .tag(let tag):
                if tag.name == "a", let href = tag.attributes["href"], let url = URL(string: href) {
                    let n = UIApplication.topViewController(controller: self)
                    WebVC.loadWeb(on: n, url: url, title: nil)
                }
            default:
                break
            }
        }
        
        return lblTerm
    }
    
    private func showValidCondition(card: PaymentCardDetail) {
        if isAgreeCondition {
            self.showAlertConfirmPaymentMethod(payment: card)
        } else {
            let lblTerm = contentConditionLabel()
            
            var argument: AlertArguments = [.title: AlertLabelValue(text: Text.termOfConnectCard.localizedText, style: .titleDefault)]
            argument[.customView] = lblTerm
            let button = AlertAction(style: .newDefault, title: Text.addCardAgreeTerm.localizedText) { [weak self] in
                self?.showAlertConfirmPaymentMethod(payment: card)
            }
            AlertCustomVC.show(on: self, option: [.title, .customView], arguments: argument, buttons: [button], orderType: .horizontal)
        }
    }

    /// Class's private properties.
    
    func showAlertConfirmPaymentMethod(payment: PaymentCardDetail) {
        var arguments: AlertArguments = [:]

        let titleStyle = AlertLabelValue(text: Text.notification.localizedText, style: AlertStyleText(color: #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1), font: UIFont.systemFont(ofSize: 18, weight: .medium), numberLines: 1, textAlignment: .center))
        arguments[.title] = titleStyle

        let messagerStyle = AlertLabelValue(text: Text.paymentAlertConfirm.localizedText, style: AlertStyleText(color: #colorLiteral(red: 0.3621281683, green: 0.3621373773, blue: 0.3621324301, alpha: 1), font: UIFont.systemFont(ofSize: 15, weight: .regular), numberLines: 0, textAlignment: .center))
        arguments[.message] = messagerStyle

        let cancelStyleBtn = StyleButton(view: .newDefault, textColor: #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1), font: .systemFont(ofSize: 15, weight: .medium), cornerRadius: 8, borderWidth: 0, borderColor: .clear)

        let cancelButton = AlertAction(style: cancelStyleBtn, title: Text.no.localizedText, handler: { [weak self] in
            var new = PaymentCardDetail.clone(old: payment)
            new.params?["storeToken"] = false
            self?.listener?.switchPaymentSelect(payment: new)
        })

        let acceptStyleBtn = StyleButton(view: .newDefault, textColor: #colorLiteral(red: 0.9588660598, green: 0.4115985036, blue: 0.1715823114, alpha: 1), font: .systemFont(ofSize: 15, weight: .medium), cornerRadius: 8, borderWidth: 0, borderColor: .clear)

        let acceptButton = AlertAction(style: acceptStyleBtn, title: Text.saveMerchant.localizedText, handler: { [weak self] in
            var new = PaymentCardDetail.clone(old: payment)

            new.params?["storeToken"] = true
            self?.listener?.switchPaymentSelect(payment: new)

        })

        let buttons: [AlertAction] = [cancelButton, acceptButton]

        AlertCustomVC.show(on: self, option: [.title, .message], arguments: arguments, buttons: buttons, orderType: .horizontal)
    }
}

// MARK: View's event handlers
extension SwitchPaymentVC {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}


// MARK: Class's public methods
extension SwitchPaymentVC {
}

// MARK: Class's private methods
private extension SwitchPaymentVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        UIApplication.setStatusBar(using: .lightContent)
        self.view.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        let navigationBar = self.navigationController?.navigationBar
        navigationBar?.barTintColor = Color.orange
        navigationBar?.isTranslucent = false
        navigationBar?.tintColor = .white
        self.title = Config.title
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        self.tableView.backgroundColor = .clear
        
        let image = UIImage(named: "ic_close")?.withRenderingMode(.alwaysTemplate)
        let rightBarItem = UIBarButtonItem(image: image, landscapeImagePhone: image, style: .plain, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem = rightBarItem
        
        rightBarItem.rx.tap.bind { [unowned self] in
            self.listener?.switchPaymentMoveBack()
        }.disposed(by: disposeBag)
        
        
        tableView >>> view >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        
        addNewBtn >>> view >>> {
            $0.cornerRadius = 24
            $0.backgroundColor = UIColor(red: 239/255, green: 82/255, blue: 34/255, alpha: 1.0)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            $0.setTitleColor(.white, for: .normal)
            $0.setTitle(Text.addVisaMaster.localizedText, for: .normal)
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.bottom.equalTo(-42)
                make.height.equalTo(48)
            })
        }
        addNewBtn.isHidden = !(listener?.switchPaymentType.isAllowAddNapas() ?? true)
        let current = tableView.contentInset
        tableView.contentInset = UIEdgeInsets(top: current.top, left: current.left, bottom: current.bottom + 95, right: current.right)
    }
    
    private func setupRX() {
        // todo: Bind data to UI here.
        self.listener?.source.observeOn(MainScheduler.asyncInstance).bind(onNext: {[weak self] (sections) in
            guard let wSelf = self else { return }
            wSelf.mSource = sections
            wSelf.tableView.reloadData()
            
        }).disposed(by: disposeBag)
        
        self.tableView.rx.itemSelected.bind { [weak self] idx in
            guard let wSelf = self else { return }
            if let select = wSelf.mSource[safe: idx.section]?.values[safe: idx.row] {
                if select.params != nil {
                    wSelf.showValidCondition(card: PaymentCardDetail.clone(old: select))
                } else {
                    wSelf.listener?.switchPaymentSelect(payment: select)
                }
            }
        }.disposed(by: disposeBag)
        
        self.addNewBtn.rx.tap.bind { [weak self] in
            self?.alertAddCard()
        }.disposed(by: disposeBag)
        
        showLoading(use: self.listener?.eLoadingObser)
        
        self.listener?.error.subscribe(onNext: { [weak self] _ in
            self?.alertError()
        }).disposed(by: disposeBag)
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

extension SwitchPaymentVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mSource[section].values.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return mSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let paymentSection = self.mSource[indexPath.section]
        let element = paymentSection.values[indexPath.row]
        
        if paymentSection.type == .existing {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SwitchPaymentCell.identifier, for: indexPath) as? SwitchPaymentCell else {
                fatalError("Error")
            }
            cell.setupDisplay(by: element)
            cell.isSelected = self.listener?.currentSelect == element
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CheckOutPaymentTVC.identifier, for: indexPath) as? CheckOutPaymentTVC else {
                fatalError("Error")
            }
            cell.setupDisplay(item: element)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.create {
            $0.backgroundColor = .clear
        }
        
        let paymentSection = self.mSource[section]
        
        UILabel.create {
            $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            $0.textColor = #colorLiteral(red: 0.3843137255, green: 0.4431372549, blue: 0.4980392157, alpha: 1)
            $0.text = paymentSection.type.description
            } >>> view >>> {
                $0.snp.makeConstraints({ (make) in
                    make.left.equalTo(16)
                    make.bottom.equalTo(-8)
                })
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}
