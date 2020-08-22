//  File name   : PaymentMethodDetailVC.swift
//
//  Author      : Dung Vu
//  Created date: 3/6/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import UIKit
import SnapKit

protocol PaymentMethodDetailPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var cardDetail: PaymentCardDetail { get }
    var eError: Observable<Error> { get }
    func paymentDetailDeleteCard()
    func paymentDetailMoveback()
}

final class PaymentMethodDetailVC: UIViewController, PaymentMethodDetailPresentable, PaymentMethodDetailViewControllable {

    struct Config {
        static let title = Text.cardDetail.localizedText
        static let expireDate = "Expire Date"
        
        struct Button {
            static let delete = Text.removeCard.localizedText.uppercased()
            static let agree = Text.agree.localizedText
            static let cancel = Text.dismiss.localizedText
            static let close = Text.dismiss.localizedText
        }
        
        struct Card {
            static let prefix = "**** **** **** "
        }
        
        struct Background {
            static let imageName = "bg_payment_detail"
        }
        
        struct Layout {
            static let left: CGFloat = 24
        }
        
        struct Alert {
            
            static let title = Text.confirmRemoveCard.localizedText
            static let message = Text.confirmRemoveCardDetail.localizedText
        }
        
        struct Error {
            static let title = Text.removeCard.localizedText
            static let message = Text.removeCardFail.localizedText
        }
    }
    /// Class's public properties.
    weak var listener: PaymentMethodDetailPresentableListener?
    private lazy var disposeBag = DisposeBag()
    
    private var mCard: PaymentCardDetail? {
        return self.listener?.cardDetail
    }
    
    private var iconCardView: UIImageView?
    private var lblCardNumber: UILabel?
    private var lblExpireDate: UILabel?
    private var btnDelete: UIButton?
    private var lastDigit: String?
    private var lblExpireDateTitle: UILabel?
    private var lblCardOwnerName: UILabel?

    
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
}

// MARK: View's event handlers
extension PaymentMethodDetailVC {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .`default`
    }
}

// MARK: Class's private methods
private extension PaymentMethodDetailVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        self.view.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        self.title = Config.title
        let item = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_back").withRenderingMode(.alwaysTemplate), landscapeImagePhone: #imageLiteral(resourceName: "ic_back").withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: nil)
        self.navigationItem.leftBarButtonItem = item
        item.rx.tap.bind { [weak self] in
            self?.listener?.paymentDetailMoveback()
        }.disposed(by: disposeBag)
        
        
        // view
        let containerView = UIView.create {
            $0.backgroundColor = .clear
            } >>> view >>> {
                $0.snp.makeConstraints({ (make) in
                    make.top.equalTo(16)
                    make.left.equalTo(16)
                    make.right.equalTo(-16)
                    make.height.equalTo(180)
                })
        }
        
        UIImageView(image: UIImage(named: Config.Background.imageName)) >>> containerView >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        
        let iconCardView = UIImageView(frame: .zero) >>> containerView >>> {
            $0.contentMode = .scaleAspectFit
            $0.image = mCard?.type.icon
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(16)
                make.right.equalTo(-16)
                make.size.equalTo(CGSize(width: 46, height: 22))
            })
        }
        self.iconCardView = iconCardView
        
        let lblCardNumber = UILabel.create {
            $0.font = UIFont.systemFont(ofSize: 32, weight: .medium)
            $0.textColor = .white
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            } >>> containerView >>> {
                $0.snp.makeConstraints({ (make) in
                    make.left.equalTo(24)
                    make.right.equalTo(-24)
                    make.top.equalTo(30)
                })
        }
        self.lblCardNumber = lblCardNumber
        
        let lblCardOwnerName = UILabel.create {
            $0.font = UIFont.systemFont(ofSize: 25, weight: .medium)
            $0.textColor = .white
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            } >>> containerView >>> {
                $0.snp.makeConstraints({ (make) in
                    make.left.equalTo(24)
                    make.right.equalTo(-24)
                    make.top.equalTo(lblCardNumber.snp.bottom).offset(5)
                })
        }
        self.lblCardOwnerName = lblCardOwnerName
        
        let lblExpireDate = UILabel.create {
            $0.font = UIFont.systemFont(ofSize: 20, weight: .medium)
            $0.textColor = .white
            } >>> containerView >>> {
                $0.snp.makeConstraints({ (make) in
                    make.left.equalTo(Config.Layout.left)
                    make.bottom.equalTo(-16)
                })
        }
        self.lblExpireDate = lblExpireDate
        
        let lblExpireDateTitle = UILabel.create {
            $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            $0.textColor = .white
            } >>> containerView >>> {
                $0.snp.makeConstraints({ (make) in
                    make.bottom.equalTo(lblExpireDate.snp.top).offset(-6).priority(.medium)
                    make.left.equalTo(Config.Layout.left)
                })
                $0.text = Config.expireDate
        }
        self.lblExpireDateTitle = lblExpireDateTitle
        
        let btnDelete = UIButton.create {
            $0.applyButton(style: .cancel)
            $0.setTitleColor(#colorLiteral(red: 0.8823529412, green: 0.1411764706, blue: 0.1411764706, alpha: 1), for: .normal)
            $0.setTitle(Config.Button.delete, for: .normal)
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            } >>> view >>> {
                $0.snp.makeConstraints({ (make) in
                    make.left.equalTo(16)
                    make.right.equalTo(-16)
                    make.bottom.equalTo(-25)
                    make.height.equalTo(48)
                })
        }
        self.btnDelete = btnDelete
        
        updateDisplay()
    }
    
    private func setupRX() {
        // todo: Bind data to UI here.
        self.btnDelete?.rx.tap.bind { [unowned self] in
            self.deleteCard()
        }.disposed(by: disposeBag)
        
        self.listener?.eError.subscribe(onNext: { [weak self](e) in
            printDebug(e)
            guard let wSelf = self else { return }
            wSelf.showAlertErrorRemove()
        }).disposed(by: disposeBag)
    }
    
    private func updateDisplay() {
        guard let card = self.mCard else {
            return
        }
        let s = card.name
        let range = NSMakeRange(s.count - 4, 4)
        let name = (s as NSString).substring(with: range)
        let text = "\(Config.Card.prefix)\(name)"
        self.lastDigit = name
        self.lblCardNumber?.text = text
        self.lblExpireDate?.text = card.issueDate
        self.lblCardOwnerName?.text = card.nameOnCard
        
        let isAtm = card.type == .atm
        
        self.lblExpireDateTitle?.isHidden = isAtm
        self.lblExpireDate?.isHidden = isAtm
        self.lblCardOwnerName?.isHidden = !isAtm
        
        
    }
    
    func deleteCard() {
        let alertActionOK = AlertAction.init(style: .default, title: Config.Button.agree) { [weak self] in
            self?.listener?.paymentDetailDeleteCard()
        }
        
        let alertActionCancel = AlertAction.init(style: .cancel, title: Config.Button.cancel) {}
        let m = "\(Config.Alert.message)\(self.lastDigit ?? "")"
        AlertVC.show(on: self, title: Config.Alert.title, message: m, from: [alertActionCancel, alertActionOK], orderType: .horizontal)
    }
    
    private func showAlertErrorRemove() {
        let alertActionCancel = AlertAction.init(style: .cancel, title: Config.Button.close) {}
        AlertVC.show(on: self, title: Config.Error.title, message: Config.Error.message, from: [alertActionCancel], orderType: .horizontal)
    }
}
