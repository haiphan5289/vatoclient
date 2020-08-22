//  File name   : WithdrawConfirmVC.swift
//
//  Author      : Dung Vu
//  Created date: 11/9/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import RxCocoa
import RxSwift
import SnapKit

import Alamofire

struct WithdrawConfirmItem {
    let title: String
    let message: String
}

final class WithdrawConfirmTitleView: UIView {
    convenience init(with item: WithdrawConfirmItem) {
        self.init(frame: .zero)
        layoutDisplay(item: item)
    }
    
    private func layoutDisplay(item: WithdrawConfirmItem) {
        let lblTile = UILabel.create {
            $0.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            $0.textColor = #colorLiteral(red: 0.4623882771, green: 0.5225807428, blue: 0.5743968487, alpha: 1)
            } >>> self >>> {
                $0.snp.makeConstraints({ (make) in
                    make.top.equalToSuperview()
                    make.centerX.equalToSuperview()
                })
        }
        
        lblTile.text = item.title
        
        let lblPrice = UILabel.create {
            $0.font = UIFont.systemFont(ofSize: 32, weight: .bold)
            $0.textColor = EurekaConfig.primaryColor
            } >>> self >>> {
                $0.snp.makeConstraints({ (make) in
                    make.top.equalTo(lblTile.snp.bottom).offset(10)
                    make.left.equalToSuperview()
                    make.right.equalToSuperview()
                    make.bottom.equalToSuperview().priority(.high)
                })
        }
        
        lblPrice.text = item.message
    }
}

final class WithdrawConfirmItemView: UIView {
    enum TypeView {
        case normal
        case total
    }
    
    convenience init(with item: WithdrawConfirmItem, type: TypeView) {
        self.init(frame: .zero)
        layoutDisplay(item: item, type: type)
    }
    
    private func layoutDisplay(item: WithdrawConfirmItem, type: TypeView) {
        var top: CGFloat = 0
        var bottom: CGFloat = 0
        switch type {
        case .normal:
            break
        case .total:
            top = 24
            bottom = -24
           UIView.create {
                $0.backgroundColor = EurekaConfig.separatorColor
            } >>> self >>> {
                $0.snp.makeConstraints({ (make) in
                    make.top.equalTo(top)
                    make.centerX.equalToSuperview()
                    make.width.equalToSuperview().offset(-32).priority(.low)
                    make.height.equalTo(1)
                })
            }
        }
        
        top += 24
        let lblTile = UILabel.create {
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.textColor = #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1)
            } >>> self >>> {
                $0.snp.makeConstraints({ (make) in
                    make.top.equalTo(top)
                    make.left.equalTo(16)
                    make.bottom.equalToSuperview().offset(bottom)
                })
        }
        
        lblTile.text = item.title
        
        let lblMessage = UILabel.create {
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.textColor = #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1)
            $0.textAlignment = .right
            } >>> self >>> {
                $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
                $0.setContentHuggingPriority(.required, for: .vertical)
                $0.numberOfLines = 2
                $0.lineBreakMode = .byWordWrapping
                $0.snp.makeConstraints({ (make) in
                    make.top.equalTo(top)
                    make.right.equalTo(-16)
                    make.left.equalTo(lblTile.snp.right).offset(16)
                })
        }
        
        lblMessage.text = item.message
        
        if case .total = type {
            lblMessage.attributedText = lblMessage.attributedText >>> .color(c: EurekaConfig.primaryColor)
        }
    }
}

enum WithdrawConfirmAction {
    case cancel
    case next
}

final class WithdrawConfirmVC: UIViewController {
    /// Class's public properties.
    let items: [WithdrawConfirmItem]
    private lazy var disposeBag = DisposeBag()
    private lazy var _action = PublishSubject<WithdrawConfirmAction>()
    
    var action: Observable<WithdrawConfirmAction> {
        return _action
    }
    let handler: WithdrawActionHandlerProtocol
    let paymentStream: MutablePaymentStream?
    
    init(_ block: () -> [WithdrawConfirmItem], title: String?, handler: WithdrawActionHandlerProtocol, paymentStream: MutablePaymentStream? = nil) {
        self.items = block()
        self.handler = handler
        self.paymentStream = paymentStream
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        visualize()
        setupRX()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }

    deinit {
        _action.onCompleted()
    }
}

// MARK: Class's private methods
private extension WithdrawConfirmVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        self.view.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        
        let containerView = UIView.create {
            $0.backgroundColor = .clear
            } >>> view >>> {
                $0.snp.makeConstraints({ (make) in
                    make.top.equalToSuperview()
                    make.centerX.equalToSuperview()
                    make.width.equalToSuperview().offset(-32)
                })
        }
        
        
        let stackView = UIStackView.create {
            $0 >>> containerView >>> {
                $0.snp.makeConstraints({ (make) in
                    make.edges.equalToSuperview()
                })
            }
        }
        
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        let number = items.count
        
        guard number > 0 else {
            return
        }
        let top: CGFloat = 40
        var t: CGFloat = 0
        
        items.enumerated().forEach { (i) in
            switch i.offset {
            case 0:
                // Title
                let titleView = WithdrawConfirmTitleView(with: i.element)
                titleView >>> view >>> {
                    $0.snp.makeConstraints({ (make) in
                        make.top.equalTo(top + 24)
                        make.centerX.equalToSuperview()
                    })
                }
                
                let s = titleView.systemLayoutSizeFitting(CGSize(width: CGFloat.infinity, height: CGFloat.infinity), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
                t = 60 + s.height
                
                containerView.snp.updateConstraints({ (make) in
                    make.top.equalTo(t)
                })
            default:
                let type: WithdrawConfirmItemView.TypeView = i.offset == number - 1 ? .total : .normal
                let itemView = WithdrawConfirmItemView(with: i.element, type: type)
                stackView.addArrangedSubview(itemView)
            }
        }
        
        let imageView = UIImageView(image: UIImage(named: "bg_topup"))
        view.insertSubview(imageView, at: 0)
        
        let c = containerView.systemLayoutSizeFitting(CGSize(width: UIScreen.main.bounds.width - 32, height: CGFloat.infinity), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        
        imageView >>> {
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(top - 12)
                make.width.equalToSuperview().offset(-14)
                make.centerX.equalToSuperview()
                make.height.equalTo(c.height + t - 12)
            })
        }
        
        let button = UIButton.create {
            $0.tintColor = Color.orange
            $0.setBackgroundImage(#imageLiteral(resourceName: "bg_button01").withRenderingMode(.alwaysTemplate), for: .normal)
            $0.setTitleColor(.white, for: .normal)
            $0.setTitle(Text.confirm.localizedText, for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 17.0, weight: .semibold)
        } >>> view >>> {
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.height.equalTo(54)
                make.bottom.equalTo(-16)
            })
        }
        
        button.rx.tap.bind { [weak self] in
            self?._action.onNext(.next)
        }
        .disposed(by: disposeBag)

        let item = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_back").withRenderingMode(.alwaysTemplate), landscapeImagePhone: #imageLiteral(resourceName: "ic_back").withRenderingMode(.alwaysTemplate), style: .plain, target: nil, action: nil)
        item.rx.tap.bind { [weak self] in
            self?._action.onNext(.cancel)
        }
        .disposed(by: disposeBag)
        
        self.navigationItem.leftBarButtonItems = [item]
    }
    
    private func setupRX() {
        self.action.bind(to: self.handler.eAction).disposed(by: disposeBag)

        self.handler.eIndicator?.bind(onNext: { [weak self] (isLoading, process) in
            guard let wSelf = self else { return }
            wSelf.view.isUserInteractionEnabled = !isLoading
        }).disposed(by: disposeBag)
    }
}
