//  File name   : TopUpByThirdPartyVC.swift
//
//  Author      : khoi tran
//  Created date: 2/5/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import Eureka
import RxSwift
import FwiCore


protocol TopUpByThirdPartyPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func topUpMoveBack()
    var listTopUpCell: Observable<[TopupCellModel]> { get }
    func selectCard(card: Card?)
    func saveCard()
    var lastSelectedCard: Card? { get }
}

final class TopUpByThirdPartyVC: FormViewController, TopUpByThirdPartyPresentable, TopUpByThirdPartyViewControllable, LoadingAnimateProtocol {
    private struct Config {
        static let paddingLeft: CGFloat = 16
        static let title: String = Text.depositMethod.localizedText
        static let TopUpSection: String = "TopUpSection"
        
        static let ChooseSource: String = "Chọn nguồn tiền"
        static let AmountSection: String = "AmountSection"
        
        static let defaultMinTopUp = 100000
        static let defaultMaxTopUp = 5000000
    }
    
    /// Class's public properties.
    weak var listener: TopUpByThirdPartyPresentableListener?
    
    
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
    
    /// Class's private properties.
    @IBOutlet weak var continueButton: UIButton!
    private var model : TopupCellModel?
    private lazy var disposeBag: DisposeBag = DisposeBag()
    private var paymentStream: MutablePaymentStream?
    private var currentSelectedRow: TopupRow?
    
    
}

// MARK: View's event handlers
extension TopUpByThirdPartyVC {
    override var prefersStatusBarHidden: Bool {
        
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension TopUpByThirdPartyVC {
}

// MARK: Class's private methods
private extension TopUpByThirdPartyVC {
    private func localize() {
        continueButton.setTitle(Text.continue.localizedText, for: .normal)
    }
    
    
    private func visualize() {
        self.setupNavigation()
        
        let imgDisable = UIImage.image(from: #colorLiteral(red: 0.7333333333, green: 0.7333333333, blue: 0.7333333333, alpha: 1), with: CGSize(width: 55, height: 55))
        let imgEnable = UIImage.image(from: Color.orange, with: CGSize(width: 55, height: 55))
        continueButton.cornerRadius = 8
        continueButton.setBackgroundImage(imgDisable, for: .disabled)
        continueButton.setBackgroundImage(imgEnable, for: .normal)
        self.continueButton.isEnabled = false
        // todo: Visualize view's here.
        self.tableView.backgroundColor = .clear
        self.view.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        
        form +++ Section() { section in
            section.tag = Config.AmountSection
            var header = HeaderFooterView<UIView>(.callback {
                let v = UIView()
                let label = UILabel()
                label >>> v >>> {
                    $0.textColor = #colorLiteral(red: 0.4623882771, green: 0.5225807428, blue: 0.5743968487, alpha: 1)
                    $0.font = EurekaConfig.titleFont
                    $0.text = Text.amountToRecharge.localizedText
                    $0.snp.makeConstraints {
                        $0.left.equalTo(Config.paddingLeft)
                        $0.right.equalToSuperview()
                        $0.bottom.equalTo(-8)
                    }
                }
                return v
                })
            header.height = { 50 }
            section.header = header
            
            var footer = HeaderFooterView<UIView>(.callback {
                let view = UIView.create({
                    $0.backgroundColor = .white
                })
                
                let label = UILabel()
                label.backgroundColor = .white
                label >>> view >>> {
                    $0.textColor = #colorLiteral(red: 0.4588235294, green: 0.4588235294, blue: 0.4588235294, alpha: 1)
                    $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
                    $0.text = String(format: FwiLocale.localized("Tối thiểu là %@ và là bội số của %@"), 100000.currency, 10000.currency)
                    $0.snp.makeConstraints {
                        $0.top.equalTo(15)
                        $0.left.equalTo(Config.paddingLeft)
                    }
                }
                
                return view
                })
            
            footer.height = { 59 }
            section.footer = footer
            
            } <<< WithdrawRow("amount") {
                $0.cash = 2000000
                $0.placeholder = Text.otherAmount.localizedText
                $0.update(by: self.model?.item.options)
                let min = self.model?.item.min ?? Config.defaultMinTopUp
                let max = self.model?.item.max ?? Config.defaultMaxTopUp
                $0.add(ruleSet: RulesTopUp.rules(minValue: min, maxValue: max))
                $0.onChange { [weak self]_ in
                    self?.validateForm()
                }
        }
    }
    
    func updateWithdrawRow() {
        if let row = form.rowBy(tag: "amount") as? WithdrawRow  {
            row.update(by: self.model?.item.options)
            let min = self.model?.item.min ?? Config.defaultMinTopUp
            let max = self.model?.item.max ?? Config.defaultMaxTopUp
            row.remove(ruleWithIdentifier: "check_max")
            row.remove(ruleWithIdentifier: "check_min")
            
            row.add(rule: RulesTopUp.checkMaxRule(maxValue: max))
            row.add(rule: RulesTopUp.checkMinRule(minValue: min))
            
            if row.value != nil {
                self.validateForm()
            }
        }
    }
    
    func setupNavigation() {
        self.title = Config.title
        let navigationBar = self.navigationController?.navigationBar
        let bgImage = UIImage(named:"bg_navigationbar")?.stretchableImage(withLeftCapWidth: 0, topCapHeight: 0)
        navigationBar?.setBackgroundImage(bgImage, for: .default)
        navigationBar?.barTintColor = Color.orange
        navigationBar?.isTranslucent = false
        navigationBar?.tintColor = .white
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        
        let image = UIImage(named: "ic_arrow_back")
        let button = UIButton(frame: CGRect(origin: .zero, size: image?.size ?? .zero))
        button.setImage(image, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
        let barButton = UIBarButtonItem(customView: button)
        navigationItem.leftBarButtonItem = barButton
        
        button.rx.tap.bind(onNext: weakify { wSelf in
            wSelf.listener?.topUpMoveBack()
        }).disposed(by: disposeBag)
    }
    
    private func validateForm() {
        
        let errors = self.form.validate()
        self.continueButton.isEnabled = errors.count == 0
    }
    
    private func setupRX() {
        // todo: Bind data to UI here.
        
        // Setup view model
        self.continueButton.rx.tap.bind { [weak self] in
            guard let wSelf = self else {
                return
            }
            wSelf.execute(form: wSelf.form, prefixAction: nil, suffixAction: nil)
        }.disposed(by: disposeBag)
        
        self.listener?.listTopUpCell.bind(onNext: weakify({ (list, wSelf) in
            wSelf.config(list: list)
        })).disposed(by: disposeBag)
    }
    
    private func handler(select: TopupCellModel?) {
        guard let model = select, let type = model.item.topUpType else {
            return
        }
        defer {
            LogEventHelper.log(key: "ToupChannel", params: ["Channel": type.name])
        }
        self.model = model
        
        self.updateWithdrawRow()
        self.listener?.selectCard(card: self.model?.card)
    }
    
    private func config(list: [TopupCellModel]) {
        func createSection() -> Section {
            let new = Section() { (s) in
                s.tag = Config.TopUpSection
                
                var header = HeaderFooterView<UIView>(.callback {
                    let v = UIView()
                    let label = UILabel()
                    label >>> v >>> {
                        $0.textColor = #colorLiteral(red: 0.4623882771, green: 0.5225807428, blue: 0.5743968487, alpha: 1)
                        $0.font = EurekaConfig.titleFont
                        $0.text = Config.ChooseSource
                        $0.snp.makeConstraints {
                            $0.left.equalTo(Config.paddingLeft)
                            $0.right.equalToSuperview()
                            $0.bottom.equalTo(-8)
                        }
                    }
                    return v
                    })
                header.height = { 50 }
                s.header = header
            }
            
            defer { form.append(new) }
            return new
        }
        
        var section = form.sectionBy(tag: Config.TopUpSection) ?? createSection()
        if section.allRows.count > 0 { section.removeAll() }
        
        func row(idx: Int, model: TopupCellModel) -> TopupRow {
            let tag = "row at \(idx)"
            let new = TopupRow(tag, {
                $0.value = model
                
                $0.onCellSelection({ [weak self](cell, row) in
                    guard let wSelf = self else { return}
                    defer {
                        wSelf.handler(select: row.value)
                    }
                    guard row.cell.bankSelectView.isSelected == false else { return }
                    
                    row.cell.bankSelectView.isSelected = true
                    wSelf.currentSelectedRow?.cell.bankSelectView.isSelected = false
                    wSelf.currentSelectedRow = row
                    
                })
                
                Process: if let lastSelectedCard = self.listener?.lastSelectedCard {
                    guard model.card == lastSelectedCard else {
                        break Process
                    }
                    $0.select()
                    $0.didSelect()
                } else {
                    guard idx == 0 else {
                        break Process
                    }
                    $0.select()
                    $0.didSelect()
                }
                
                self.setAmountSelect()                
            })
            return new
        }
       
        let allRows = list.enumerated().map(row)
        section.append(contentsOf: allRows)
    }
    
    private func setAmountSelect() {
        if let row = form.rowBy(tag: "amount") as? WithdrawRow  {
            row.cell.setPriceViewSelected(indexPath: IndexPath(row: 0, section: 0))
        }
    }
    
    
}


extension TopUpByThirdPartyVC: FormHandlerProtocol {
    func cancelForm() {}
    
    func execute(input: [String : Any?]) {
        guard var amount: Int = input.value(for: "amount", defaultValue: nil) else {
            return
        }
        defer {
            var json = [String : Any]()
            json["Amount"] = amount
            json["Channel"] = self.model?.item.topUpType?.name
            
            LogEventHelper.log(key: "TopupContinue", params: json)
        }
        
        guard let name = self.model?.item.topUpType?.name else {
            return
        }
        
        let topUpAction = TopUpAction(with: name, amount: amount, controller: self, topUpItem: self.model)
        let items = [WithdrawConfirmItem(title: Text.topUp.localizedText.uppercased(), message: amount.currency),
                     WithdrawConfirmItem(title: Text.amountOfMoney.localizedText, message: amount.currency),
                     WithdrawConfirmItem(title: Text.paymentMethod.localizedText, message: model?.item.name ?? ""),
                     WithdrawConfirmItem(title: Text.paymentFees.localizedText, message: 0.currency),
                     WithdrawConfirmItem(title: Text.totalTopUp.localizedText, message: amount.currency)]
        let confirmVC = WithdrawConfirmVC({ items }, title: Text.check.localizedText, handler: topUpAction, paymentStream: self.paymentStream)
        topUpAction.callBackTopUpSuccess = { [weak self] in
            guard let wSelf = self  else {
                return
            }
            AlertVC.showMessageAlert(for: self,
                                     title: Text.notification.localizedText,
                                     message: Text.topupZaloSuccess.localizedText,
                                     actionButton1: Text.dismiss.localizedText,
                                     actionButton2: nil,
                                     handler1: {
                                        wSelf.listener?.topUpMoveBack()
            }, handler2: nil)
        }
        self.listener?.saveCard()
        self.navigationController?.pushViewController(confirmVC, animated: true)
        
    }
}

