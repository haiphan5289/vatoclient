//  File name   : LatePaymentVC.swift
//
//  Author      : Futa Corp
//  Created date: 3/6/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxSwift
import RxCocoa


protocol LatePaymentPresentableListener: class {
    var cards: Observable<[PaymentCardDetail]> { get }
    var errorMessage: Observable<String> { get }
    var isLoading: Observable<Bool> { get }

    func handleVATOPayAction()

    func handlePayWithCard(at index: Int)

    func handleCardManagementAction()
}

final class LatePaymentVC: UIViewController, LatePaymentPresentable, LatePaymentViewControllable {
    private struct Config {
        static let headerTitle = "Thanh toán %@ cho chuyến đi trước"
        static let headerBody = "Đã xảy ra vấn đề với việc thanh toán cho chuyến đi gần đây với thẻ %@ của bạn. Vui lòng kiểm tra lại và thanh toán để tiếp tục sử dụng các dịch vụ của VATO"
        static let headerFooter = Text.selectPaymentMethod.localizedText

        static let vatoPay = "VATOPay"

        static let headerWidth = UIScreen.main.bounds.width - 32    // LeftPadding(16) + RightPadding(16)
        static let perferWidth = UIScreen.main.bounds.width - 64    // LeftPadding(16 + 16) + RightPadding(16 + 16)
    }

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cardButton: UIButton!

    /// Class's public properties.
    weak var listener: LatePaymentPresentableListener?

    /// Class's constructors.
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, debtInfo info: UserDebtDTO) {
        self.debtInfo = info
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()

        tableView.register(SwitchPaymentCell.self, forCellReuseIdentifier: SwitchPaymentCell.identifier)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }

    /// Class's private properties.
    private var disposeBag = DisposeBag()

    private var cards: [Card] = []
    private let debtInfo: UserDebtDTO

    private lazy var headerTitleLabel = UILabel()
    private lazy var headerbodyLabel = UILabel()
    private lazy var headerFooterLabel = UILabel()
    private lazy var headerView = UIView(frame: CGRect(x: 0, y: 0, width: Config.headerWidth, height: 10))
}

// MARK: View's event handlers
extension LatePaymentVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension LatePaymentVC {
}

// MARK: Class's private methods
private extension LatePaymentVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        headerTitleLabel >>> headerView >>> {
            $0.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            $0.lineBreakMode = .byWordWrapping
            $0.numberOfLines = 0
            $0.preferredMaxLayoutWidth = Config.perferWidth
            $0.snp.makeConstraints {
                $0.top.equalToSuperview().inset(16)
                $0.leading.equalToSuperview().inset(16)
                $0.trailing.equalToSuperview().inset(16)
            }
        }

        headerbodyLabel >>> headerView >>> {
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.lineBreakMode = .byWordWrapping
            $0.numberOfLines = 0
            $0.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
            $0.preferredMaxLayoutWidth = Config.perferWidth
            $0.snp.makeConstraints {
                $0.top.equalTo(headerTitleLabel.snp.bottom).offset(20)
                $0.leading.equalTo(headerTitleLabel.snp.leading)
                $0.trailing.equalTo(headerTitleLabel.snp.trailing)
                $0.height.greaterThanOrEqualTo(20)
            }
        }

        headerFooterLabel >>> headerView >>> {
            $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            $0.lineBreakMode = .byWordWrapping
            $0.numberOfLines = 0
            $0.preferredMaxLayoutWidth = Config.perferWidth
            $0.snp.makeConstraints {
                $0.top.equalTo(headerbodyLabel.snp.bottom).offset(20)
                $0.leading.equalTo(headerTitleLabel.snp.leading)
                $0.trailing.equalTo(headerTitleLabel.snp.trailing)
                $0.bottom.equalToSuperview()
                $0.height.equalTo(40)
            }
        }

        headerView >>> {
            tableView.tableHeaderView = headerView
            $0.snp.makeConstraints {
                $0.centerX.equalTo(tableView.snp.centerX)
                $0.top.equalTo(tableView.snp.top)
                $0.width.equalTo(tableView.snp.width)
                $0.height.greaterThanOrEqualTo(10)
            }
        }
    }

    private func setupRX() {
        listener?.cards.observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] (cards) in
                guard cards.count >= 1, let wSelf = self else {
                    return
                }
                wSelf.cards = cards

                if
                    let cardID = wSelf.debtInfo.failCards.first,
                    let card = cards.first(where: { $0.id == cardID }),
                    let brand = card.brand,
                    let number = card.number?.suffix(4)
                {
                    wSelf.headerbodyLabel.text = String(format: Config.headerBody, "\(brand) ***\(number)")
                } else {
                    wSelf.headerbodyLabel.text = String(format: Config.headerBody, "Visa / MasterCard")
                }

                wSelf.headerTitleLabel.text = String(format: Config.headerTitle, wSelf.debtInfo.amount.currency)
                wSelf.headerFooterLabel.text = Config.headerFooter
                wSelf.tableView.layoutIfNeeded()
                wSelf.tableView.layoutSubviews()

                wSelf.tableView.dataSource = self
                wSelf.tableView.delegate = self

                wSelf.tableView.reloadData()
                wSelf.tableView.layoutIfNeeded()
            })
            .disposed(by: disposeBag)

        cardButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.listener?.handleCardManagementAction()
        })
        .disposed(by: disposeBag)

        listener?.isLoading
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { (isLoading) in
                if isLoading {
                    LoadingManager.showProgress()
                } else {
                    LoadingManager.dismissProgress()
                }
            })
            .disposed(by: disposeBag)

        listener?.errorMessage
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] (message) in
                let dismissAction = AlertAction(style: .cancel,
                                                title: Text.dismiss.localizedText,
                                                handler: {})

                AlertVC.show(on: self,
                             title: Text.notification.localizedText,
                             message: message,
                             from: [dismissAction],
                             orderType: .vertical)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: UITableViewDataSource's members
extension LatePaymentVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cards.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SwitchPaymentCell.dequeueCell(tableView: self.tableView)
        let card = cards[indexPath.row]
        cell.setupDisplay(by: card)

        if cell.contentView.subviews.first(where: { $0.tag == 1000 }) == nil {
            UIView() >>> cell.contentView >>> {
                $0.backgroundColor = UIColor.black.withAlphaComponent(0.3)
                $0.tag = 1000
                $0.snp.makeConstraints {
                    $0.leading.equalToSuperview().inset(74)
                    $0.trailing.equalToSuperview()
                    $0.bottom.equalToSuperview()
                    $0.height.equalTo(0.5)
                }
            }
        }
        return cell
    }
}

// MARK: UITableViewDelegate's members
extension LatePaymentVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68.0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            listener?.handleVATOPayAction()
        } else {
            listener?.handlePayWithCard(at: indexPath.row)
        }
    }
}
