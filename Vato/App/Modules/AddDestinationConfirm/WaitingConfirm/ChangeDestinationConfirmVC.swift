//  File name   : ChangeDestinationConfirmVC.swift
//
//  Author      : Dung Vu
//  Created date: 4/9/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import Eureka
import SnapKit
import FwiCore
import FwiCoreRX
import RxSwift
import RxCocoa
import Atributika

protocol ChangeDestinationConfirmPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var seconds: Observable<Int> { get }
    
    func addEventCancel(e: Observable<Void>)
}

final class ChangeDestinationConfirmVC: UIViewController, ChangeDestinationConfirmPresentable, ChangeDestinationConfirmViewControllable {
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: ChangeDestinationConfirmPresentableListener?
    private lazy var lblCountdown: UILabel = UILabel(frame: .zero)
    private lazy var disposeBag = DisposeBag()
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
        navigationController?.navigationItem.setHidesBackButton(true, animated: true)
    }

    /// Class's private properties.
}

// MARK: View's event handlers
extension ChangeDestinationConfirmVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension ChangeDestinationConfirmVC {
}

// MARK: Class's private methods
private extension ChangeDestinationConfirmVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
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
        
        lblCountdown >>> {
            $0.setContentHuggingPriority(.required, for: .horizontal)
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.numberOfLines = 0
            $0.textAlignment = .center
            $0.snp.makeConstraints { (make) in
                make.width.equalTo(208)
            }
        }
        
        let stackView = UIStackView(arrangedSubviews: [container, lblCountdown])
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
        btnCancel >>> view >>> {
            $0.snp.makeConstraints { make in
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.bottom.equalTo(view.layoutMarginsGuide.snp.bottom)
                make.height.equalTo(48)
            }
        }
        
        listener?.addEventCancel(e: btnCancel.rx.tap.asObservable())
        
    }
    
    func setupRX() {
        listener?.seconds.bind(onNext: weakify({ (seconds, wSelf) in
            let format = Text.waittingAddDestination.localizedText
            let b = Atributika.Style("b").foregroundColor(#colorLiteral(red: 0, green: 0.3803921569, blue: 0.2392156863, alpha: 1))
            let all = Atributika.Style().font(.systemFont(ofSize: 15, weight: .regular)).foregroundColor(#colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1))
            let text = String(format: format, seconds)
            let att = text.style(tags: b).styleAll(all).attributedString
            wSelf.lblCountdown.attributedText = att
        })).disposed(by: disposeBag)
    }
}
