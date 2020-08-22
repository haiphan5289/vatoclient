//  File name   : WalletVC.swift
//
//  Author      : Dung Vu
//  Created date: 12/3/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import Eureka
import SnapKit
import FwiCore
import FwiCoreRX
import RxSwift
import RxCocoa
import Atributika

protocol WalletPresentableListener: WalletHistoryRequestProtocol {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var walletResponse: Observable<WalletResponse> { get }
    var enableTopUp: Observable<Bool> { get }
    var enableManageCard: Observable<Bool> { get }
    var listCard: Observable<[PaymentCardDetail]> { get }
    var loadingProgress: Observable<ActivityProgressIndicator.Element> { get }
    
    func requestConfig()
    func walletMoveBack()
    func showTopup()
    func showDetail(by item: WalletDetailHistoryType)
    func showWalletListHistory()
    func requestBalance()
    func updateBalance()
    func routeToManageCard()
    func routeToAddCard(card: PaymentCardDetail)
    func refresh()
}

final class WalletVC: FormViewController, WalletPresentable, WalletViewControllable, DisposableProtocol, LoadingAnimateProtocol {

    struct Config {
        struct ButtonTopup {
            static let addMoney = Text.topUpNow.localizedText
            static let manageCard = Text.manageCard.localizedText
        }
    }
    /// Class's public properties.
    weak var listener: WalletPresentableListener?
    internal lazy var disposeBag = DisposeBag()
    private weak var rowList: RowDetailGeneric<WalletListCardCell>? {
        didSet {
            setupActionSeeListCard()
        }
    }
    private lazy var refreshControl: UIRefreshControl = {
        let r = UIRefreshControl(frame: .zero)
        r.tintColor = .white
        return r
    }()
    
    final override var hidesBottomBarWhenPushed: Bool {
        get {
            return navigationController?.viewControllers.last != self
        } set {
            super.hidesBottomBarWhenPushed = newValue
        }
    }
    override func loadView() {
        super.loadView()
        self.tableView = UITableView(frame: .zero, style: .grouped)
        self.tableView.separatorStyle = .none
    }
    
    
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        listener?.requestConfig()
        setupRX()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }

    /// Class's private properties.
    override func tableView(_: UITableView, viewForFooterInSection _: Int) -> UIView? {
        return nil
    }

    override func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat { return 0.1 }

    override func tableView(_: UITableView, heightForFooterInSection _: Int) -> CGFloat { return 0.1 }

    override func tableView(_: UITableView, viewForHeaderInSection _: Int) -> UIView? { return nil }
}


// MARK: Class's public methods
extension WalletVC {
    func showAlertError(message: String) {
        AlertVC.showError(for: self, message: message)
    }
}

// MARK: Class's private methods
private extension WalletVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        let navigationBar = self.navigationController?.navigationBar
        let bgImage = UIImage(named:"bg_navigationbar")
        navigationBar?.setBackgroundImage(bgImage, for: .default)
        navigationBar?.barTintColor = Color.orange
        navigationBar?.isTranslucent = false
        navigationBar?.tintColor = .white
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        
        self.title = Text.wallet.localizedText
        
        let image = UIImage(named: "ic_arrow_back")
        let leftButton = UIButton(frame: CGRect(origin: .zero, size: image?.size ?? .zero))
        leftButton.setImage(image, for: .normal)
        leftButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
        let leftBarButton = UIBarButtonItem(customView: leftButton)
        navigationItem.leftBarButtonItem = leftBarButton
        
        let btn = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 44, height: 44)))
        btn.setImage(UIImage(named: "ic_wallet_history"), for: .normal)
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -20)
        let rightView = UIBarButtonItem(customView: btn)
        self.navigationItem.rightBarButtonItem = rightView
        
        
        self.title = Text.wallet.localizedText
        navigationBar?.shadowImage = UIImage()
        
        if #available(iOS 12, *) {
        } else {
            navigationBar?.subviews.flatMap { $0.subviews }.filter{ $0 is UIImageView }.forEach({
                $0.isHidden = true
            })
        }
        self.view.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        leftButton.rx.tap.bind(onNext: weakify({ (wSelf) in
            wSelf.listener?.walletMoveBack()
        })).disposed(by: disposeBag)
        
        btn.rx.tap.bind(onNext: weakify({ (wSelf) in
            wSelf.listener?.showWalletListHistory()
        })).disposed(by: disposeBag)
        
        let imageView = UIImageView(image: UIImage(named: "bg_navigationbar"))
        let cBGView = UIView(frame: .zero)
        cBGView.backgroundColor = .clear
        refreshControl.rx.controlEvent(.valueChanged).bind(onNext: weakify({ (wSelf) in
            wSelf.refreshControl.beginRefreshing()
            wSelf.listener?.refresh()
        })).disposed(by: disposeBag)
        
        imageView >>> cBGView >>> {
            $0.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(UIScreen.main.bounds.height / 3)
            }
        }
        tableView.addSubview(refreshControl)
        tableView.backgroundView = cBGView
        tableView >>> view >>> {
            $0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
        
        setupForm()
    }
    
    private func updateTopup(row: RowDetailGeneric<WalletTopHeaderCell>) {
        listener?.walletResponse.bind(onNext: { [weak row](w) in
            let m = w.cash + w.coin
            row?.value = m.currency
        }).disposed(by: disposeBag)
        
        listener?.enableTopUp.bind(onNext: { [weak row] (enable) in
            row?.cell.btnTopUp.isHidden = !enable
        }).disposed(by: disposeBag)
    }
    
    private func addMethod(section: Section?) {
        guard let section = section else {
            return
        }
        var rows = section.allRows
        let titleCell = Eureka.Row<WalletTitleNapasCell>.init(tag: "titleCell")
        let count = rows.count
        guard self.form.rowBy(tag: "TermCell") != nil else {
            return
        }
        
        var baseRow: [BaseRow] = [BaseRow]()
        baseRow.append(titleCell)
        if FireStoreConfigDataManager.shared.isAllowVisa {
            let m1 = RowDetailGeneric<WalletMethodNapasCell>.init("m1") { (row) in
                row.cell.iconView.image = UIImage(named: "ic_visa")
                row.value = Text.addCardVisa.localizedText
                row.onCellSelection { [weak self](_, _) in
                    let card = PaymentCardDetail.credit()
                    self?.validAdd(card: card)
                }
            }
            baseRow.append(m1)
        }
        
        if FireStoreConfigDataManager.shared.isAllowAtm {
            let m2 = RowDetailGeneric<WalletMethodNapasCell>.init("m2") { (row) in
                row.cell.iconView.image = UIImage(named: "ic_atm")
                row.value = Text.addCardDomestic.localizedText
                row.onCellSelection { [weak self](_, _) in
                    let card = PaymentCardDetail.atm()
                    self?.validAdd(card: card)
                }
            }
            baseRow.append(m2)
        }
        
        rows.insert(contentsOf: baseRow, at: count - 1)
        section.removeAll()
        rows.forEach {
            section <<< $0
        }
    }
    
    private func validAdd(card: PaymentCardDetail) {
        let v = (form.rowBy(tag: "TermCell")?.baseValue as? Bool) ?? false
        if v {
            self.listener?.routeToAddCard(card: card)
        } else {
            let lblTerm = AttributedLabel()
            lblTerm.numberOfLines = 0
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
            
            var argument: AlertArguments = [.title: AlertLabelValue(text: Text.termOfConnectCard.localizedText, style: .titleDefault)]
            argument[.customView] = lblTerm
            let button = AlertAction(style: .newDefault, title: Text.addCardAgreeTerm.localizedText) { [weak self] in
                self?.listener?.routeToAddCard(card: card)
            }
            AlertCustomVC.show(on: self, option: [.title, .customView], arguments: argument, buttons: [button], orderType: .horizontal)
        }
    }
    
    private func setupForm() {
        let section = Section.init { (s) in
            s.tag = "Section 1"
        }
        
        let topCell = RowDetailGeneric<WalletTopHeaderCell>.init("TopCell") { (row) in
            self.updateTopup(row: row)
            row.cell.btnTopUp.rx.tap.bind(onNext: weakify({ (wSelf) in
                wSelf.listener?.showTopup()
            })).disposed(by: disposeBag)
        }
        section <<< topCell
         
        let termCell = RowDetailGeneric<WalletTermCell>.init("TermCell") { (row) in
            row.value = true
            row.cell.lblTerm.onClick = { [weak self] label, detection in
                switch detection.type {
                case .link(let url):
                    WebVC.loadWeb(on: self, url: url, title: nil)
                case .tag(let tag):
                    if tag.name == "a", let href = tag.attributes["href"], let url = URL(string: href) {
                        WebVC.loadWeb(on: self, url: url, title: nil)
                    }
                default:
                    break
                }
            }
        }
        section <<< termCell
        UIView.performWithoutAnimation {
            self.form += [section]
        }
    }
    
    private func setupActionSeeListCard() {
        guard let r = self.rowList else {
            return
        }
        
        r.cell.btnMore.rx.tap.bind(onNext: weakify({ (wSelf) in
            wSelf.listener?.routeToManageCard()
        })).disposed(by: disposeBag)
    }
    
    private func setupRX() {
        showLoading(use: listener?.loadingProgress)
        
        listener?.loadingProgress.map { $0.0 }.filter { !$0 }.bind(onNext: weakify({ (_, wSelf) in
            guard wSelf.refreshControl.isRefreshing else { return }
            wSelf.refreshControl.endRefreshing()
        })).disposed(by: disposeBag)
        
        listener?.enableManageCard.filter { $0 }.bind(onNext: weakify({ (enable, wSelf) in
            let section = wSelf.form.sectionBy(tag: "Section 1")
            wSelf.addMethod(section: section)
        })).disposed(by: disposeBag)
        
        listener?.listCard.bind(onNext: weakify({ (list, wSelf) in
            let section = wSelf.form.sectionBy(tag: "Section 1")
            if list.isEmpty {
                guard let row = wSelf.rowList else {
                    return
                }
                guard let idx = section?.index(of: row) else { return }
                section?.remove(at: idx)
                
            } else {
                if let row = wSelf.rowList {
                    row.value = list
                } else {
                    //TopCell
                    guard let r = wSelf.form.rowBy(tag: "TopCell") else { return }
                    let row = RowDetailGeneric<WalletListCardCell>.init("ListCard") { (row) in
                        row.value = list
                    }
                    self.rowList = row
                    try? section?.insert(row: row, after: r)
                }
            }
        })).disposed(by: disposeBag)
    }
}
