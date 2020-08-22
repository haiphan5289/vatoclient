//
//  AddDestinationAlertViewController.swift
//  Vato
//
//  Created by Dung Vu on 4/16/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit
import Eureka
import SnapKit
import FwiCore
import FwiCoreRX
import RxSwift
import RxCocoa

enum AddDestinationAlertType {
    case request
    case cancel
}

final class AddDestinationAlertViewController: UIViewController {
    private lazy var lblDescription = UILabel(frame: .zero)
    @Published private var event: AddDestinationAlertType
    private var message: String?
    private lazy var disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        // Do any additional setup after loading the view.
    }
    
    deinit {
        print("\(type(of: self)) \(#function)")
    }
}

extension AddDestinationAlertViewController {
    static func show(on vc: UIViewController?, message: String?) -> Observable<AddDestinationAlertType> {
        guard let vc = vc else {
            fatalError("Please Implement")
        }
        let alertVC = AddDestinationAlertViewController()
        alertVC.message = message
        let naviVC = UINavigationController(rootViewController: alertVC)
        naviVC.modalPresentationStyle = .fullScreen
        naviVC.modalTransitionStyle = .coverVertical
        return Observable.create { (s) -> Disposable in
            let dispose = alertVC.$event.take(1).subscribe(s)
            vc.present(naviVC, animated: true, completion: nil)
            return Disposables.create {
                dispose.dispose()
                naviVC.dismiss(animated: true, completion: nil)
            }
        }
    }
}

private extension AddDestinationAlertViewController {
    private func visualize() {
        // todo: Visualize view's here.
        let navigationBar = self.navigationController?.navigationBar
        let bgImage = UIImage(named:"bg_navigationbar")?.stretchableImage(withLeftCapWidth: 0, topCapHeight: 0)
        navigationBar?.setBackgroundImage(bgImage, for: .default)
        navigationBar?.barTintColor = Color.orange
        navigationBar?.isTranslucent = false
        navigationBar?.tintColor = .white
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        view.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        title = Text.inTripAddDestination.localizedText
        let container = UIView(frame: .zero)
        let button = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 44, height: 44)))
        navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: button)]
        container >>> {
            $0.backgroundColor = .clear
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentHuggingPriority(.required, for: .vertical)
        }
        
        let imageView = UIImageView(frame: .zero)
        imageView >>> container >>> {
            $0.setContentHuggingPriority(.required, for: .horizontal)
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.contentMode = .scaleAspectFit
            $0.image = UIImage(named: "ic_guide_notify")
            $0.snp.makeConstraints { (make) in
                make.top.equalToSuperview()
                make.size.equalTo(CGSize(width: 126, height: 120))
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview().priority(.high)
            }
        }
        
        lblDescription >>> {
            $0.setContentHuggingPriority(.required, for: .horizontal)
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
            $0.numberOfLines = 0
            $0.textAlignment = .center
            $0.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            $0.text = message
            $0.snp.makeConstraints { (make) in
                make.width.equalTo(208)
            }
        }
        
        let stackView = UIStackView(arrangedSubviews: [container, lblDescription])
        stackView >>> view >>> {
            $0.distribution = .fill
            $0.axis = .vertical
            $0.spacing = 16
            $0.snp.makeConstraints { make in
                make.top.equalTo(159)
                make.centerX.equalToSuperview()
            }
        }
        let btnCancel = UIButton(frame: .zero)
        btnCancel.applyButton(style: StyleButton(view: .cancel, textColor: #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1), font: .systemFont(ofSize: 16, weight: .medium), cornerRadius: 24, borderWidth: 1, borderColor: #colorLiteral(red: 0.7529411765, green: 0.7764705882, blue: 0.8, alpha: 1)))
        btnCancel.setTitle(Text.inTripCancelRequestDestination.localizedText, for: .normal)
        btnCancel.rx.tap.bind(onNext: weakify({ (wSelf) in
            wSelf.event = .cancel
        })).disposed(by: disposeBag)
        
        let btnAgree = UIButton(frame: .zero)
        btnAgree.applyButton(style: StyleButton(view: .default, textColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), font: .systemFont(ofSize: 16, weight: .medium), cornerRadius: 24, borderWidth: 1, borderColor: .clear))
        btnAgree.setTitle(Text.inTripAddDestinationRequestAgain.localizedText, for: .normal)
        btnAgree.rx.tap.bind(onNext: weakify({ (wSelf) in
            wSelf.event = .request
        })).disposed(by: disposeBag)
        
        let stackView1 = UIStackView(arrangedSubviews: [btnCancel, btnAgree])
        stackView1 >>> view >>> {
            $0.distribution = .fillEqually
            $0.axis = .horizontal
            $0.spacing = 16
            $0.snp.makeConstraints { (make) in
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.bottom.equalTo(view.layoutMarginsGuide.snp.bottom).offset(-16)
                make.height.equalTo(48)
            }
        }
        
    }
}
