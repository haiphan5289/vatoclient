//  File name   : AlertAddCardVC.swift
//
//  Author      : Dung Vu
//  Created date: 3/5/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import FwiCore
import FwiCoreRX
import RxCocoa
import RxSwift
import SnapKit

fileprivate class AddNoteView: UIView {
    struct Config {
        static let icon = "ic_promotion_check"
    }
    private var lblMessage: UILabel?
    convenience init(with message: String?, font: UIFont) {
        self.init(frame: .zero)
        common()
        self.lblMessage?.font = font
        self.lblMessage?.text = message
    }
    
    private func common() {
        let image = UIImage(named: Config.icon)
        let s = image?.size ?? .zero
        UIImageView(image: image) >>> self >>> {
            $0.snp.makeConstraints({ (make) in
                make.top.equalToSuperview()
                make.left.equalToSuperview()
                make.size.equalTo(s)
            })
        }
        
        let lblMessage = UILabel.create {
            $0.textColor = #colorLiteral(red: 0.3843137255, green: 0.4431372549, blue: 0.4980392157, alpha: 1)
            $0.numberOfLines = 0
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            } >>> self >>> {
                $0.snp.makeConstraints({ (make) in
                    make.left.equalTo(s.width + 8)
                    make.top.equalToSuperview().offset(-3)
                    make.right.equalToSuperview()
                    make.bottom.equalToSuperview()
                })
        }
        
        self.lblMessage = lblMessage
    }
    
    deinit {
        printDebug("\(#function)")
    }
}

enum AlertAddState {
    case cancel
    case agree
}

final class AlertAddCardVC: UIViewController {
    /// Class's public properties.

    struct Config {
        struct Button {
            static let cancel = Text.back.localizedText
            static let agree = Text.continue.localizedText
        }
        
        struct Link {
            static let url: URL = "https://vato.vn/quy-che-hoat-dong-va-dieu-khoan"
        }
    }
    
    private lazy var eState: PublishSubject<AlertAddState> = PublishSubject()
    private var btnLink: UIButton?
    private lazy var disposeBag = DisposeBag()
    private var containerView: UIView?
    
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
        
        UIView.animate(withDuration: 0.5) {
            self.containerView?.transform = .identity
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first else {
            return
        }
        
        let p = point.location(in: self.view)
        guard self.containerView?.frame.contains(p) == false else {
            return
        }
        self.eState.onCompleted()
    }
    
    deinit {
        printDebug("\(#function)")
    }
}

// MARK: View's event handlers
extension AlertAddCardVC {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension AlertAddCardVC {
    static func show(onVC viewController: UIViewController?) -> Observable<AlertAddState> {
        guard let vc = viewController else {
            fatalError("Check")
        }
        
        let alert = AlertAddCardVC(nibName: nil, bundle: nil)
        alert.modalTransitionStyle = .crossDissolve
        alert.modalPresentationStyle = .overCurrentContext
        vc.present(alert, animated: true, completion: nil)
        return alert.eState
    }
}

// MARK: Class's private methods
private extension AlertAddCardVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        view.backgroundColor = Color.black40
        let container = UIView.create {
            $0.backgroundColor = .white
            $0.cornerRadius = 6
            } >>> view >>> {
                $0.snp.makeConstraints({ (make) in
                    make.centerY.equalToSuperview()
                    make.left.equalTo(16)
                    make.right.equalTo(-16)
                })
        }
        
        
        var att = Text.byPress.localizedText.attribute
            >>> .color(c: #colorLiteral(red: 0.3843137255, green: 0.4431372549, blue: 0.4980392157, alpha: 1))
            >>> .font(f: UIFont.systemFont(ofSize: 14.0, weight: .regular))
        
        let s1 = Text.continue.localizedText.attribute >>> .color(c: .black) >>> .font(f: UIFont.systemFont(ofSize: 14.0, weight: .regular))
        let s2 = Text.argreeWith.localizedText.attribute
            >>> .color(c: #colorLiteral(red: 0.3843137255, green: 0.4431372549, blue: 0.4980392157, alpha: 1))
            >>> .font(f: UIFont.systemFont(ofSize: 14.0, weight: .regular))
        let s3 = Text.termOfUse.localizedText.attribute
            >>> .color(c: Color.orange)
            >>> .font(f: UIFont.systemFont(ofSize: 14.0, weight: .regular))
        let s4 = Text.ofVatoPay.localizedText.attribute
            >>> .color(c: #colorLiteral(red: 0.3843137255, green: 0.4431372549, blue: 0.4980392157, alpha: 1))
            >>> .font(f: UIFont.systemFont(ofSize: 14.0, weight: .regular))
        
        att = att >>> s1 >>> s2 >>> s3 >>> s4
        
        let lblTitle = UILabel.create {
            $0.isUserInteractionEnabled = true
            $0.numberOfLines = 0
            $0.attributedText = att
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
        }
        
        let btnLink = UIButton.create {
            $0.backgroundColor = .clear
            } >>> lblTitle >>> {
                $0.snp.makeConstraints({ (make) in
                    make.edges.equalToSuperview().priority(.medium)
                })
        }
        self.btnLink = btnLink
        
        
        let strings = [Text.onlyPayVisa.localizedText,
//                       Text.dontSupportATMLocalYet.localizedText,
                       Text.addCardSupport1.localizedText,
                       Text.addCardSupport2.localizedText]
        var views: [UIView] = strings.map { AddNoteView(with: $0, font: UIFont.systemFont(ofSize: 14.0, weight: .regular)) >>> {
                $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            } }
        views.insert(lblTitle, at: 0)
        
        let stackView = UIStackView(arrangedSubviews: views)
        stackView.spacing = 8
        stackView.axis = .vertical
        stackView.distribution = .fill
        
        stackView >>> container >>> {
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(34)
                make.left.equalTo(16)
                make.right.equalTo(-16)
            })
        }
        
        let btnCancel = UIButton.create {
            $0.applyButton(style: .cancel)
            $0.setTitle(Config.Button.cancel, for: .normal)
        }
        
        let btnAgree = UIButton.create {
            $0.applyButton(style: .default)
            $0.setTitle(Config.Button.agree, for: .normal)
        }
        
         Observable<AlertAddState>
            .merge([btnCancel.rx.tap.map {_ in AlertAddState.cancel }, btnAgree.rx.tap.map {_ in AlertAddState.agree } ])
            .take(1)
            .bind(to: self.eState)
            .disposed(by: disposeBag)
        
        UIStackView(arrangedSubviews: [btnCancel, btnAgree]) >>> {
            $0.axis = .horizontal
            $0.spacing = 7
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.distribution = .fillEqually
            } >>> container >>> {
                $0.snp.makeConstraints({ (make) in
                    make.left.equalTo(stackView.snp.left)
                    make.right.equalTo(stackView.snp.right)
                    make.top.equalTo(stackView.snp.bottom).offset(24)
                    make.height.equalTo(48)
                    make.bottom.equalTo(-24)
                })
        }
        
        container.transform = CGAffineTransform(translationX: 0, y: 1000)
        containerView = container
    }
    
    private func setupRX() {
        // todo: Bind data to UI here.
        self.eState.subscribe(onDisposed: { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        
        self.btnLink?.rx.tap.bind { [weak self] in
            WebVC.loadWeb(on: self, url: Config.Link.url, title: nil)
        }.disposed(by: disposeBag)
    }
    
    
}
