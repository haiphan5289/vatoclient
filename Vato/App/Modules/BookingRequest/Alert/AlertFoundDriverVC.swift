//  File name   : AlertFoundDriverVC.swift
//
//  Author      : Dung Vu
//  Created date: 1/18/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import RxCocoa
import RxSwift
import Firebase

final class AlertFoundDriverVC: UIViewController {
    
    struct Config {
        static let titleOK = "ĐỒNG Ý"
        static let title = "Yeah! Đã tìm được tài xế cho bạn"
    }
    /// Class's public properties.
    private var driver: Driver?
    private var firebaseId: String!
    private lazy var firebaseDatabaseReference = Database.database().reference()
    private lazy var disposeBag = DisposeBag()
    private lazy var eNext = PublishSubject<Void>()
    private var containerView: UIView?
    
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRX()
        requestInformationDriver()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }
    
    private func requestInformationDriver() {
        let node = FireBaseTable.user >>> .custom(identify: firebaseId)
        firebaseDatabaseReference.find(by: node, type: .value, using: {
            $0.keepSynced(true)
            return $0
        }).take(1).subscribe { [weak self] (event) in
            guard let wSelf = self else { return }
            switch event {
            case .next(let value):
                let user = try? FirebaseUser.create(from: value)
                wSelf.visualize(by: user)
            case .error(let e):
                printDebug(e)
                // Fail auto move next
                DispatchQueue.main.async {
                    wSelf.eNext.onNext(())
                    wSelf.eNext.onCompleted()
                }
            default:
                break
            }
            
        }.disposed(by: disposeBag)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first else {
            return
        }
        
        let p = point.location(in: self.view)
        guard self.containerView?.frame.contains(p) == false else {
            return
        }
        DispatchQueue.main.async {
            self.eNext.onNext(())
            self.eNext.onCompleted()
        }
    }
    
    deinit {
        printDebug("\(#function)")
    }

    /// Class's private properties.
}

// MARK: View's event handlers
extension AlertFoundDriverVC {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    
    static func show(on controller: UIViewController?, firebaseId: String?, driver: Driver?) -> Observable<Void> {
        guard let firebaseId = firebaseId, let controller = controller else {
            fatalError("Recheck")
        }
        
        let alertVC = AlertFoundDriverVC(nibName: nil, bundle: nil)
        alertVC.driver = driver
        alertVC.firebaseId = firebaseId
        alertVC.modalTransitionStyle = .crossDissolve
        alertVC.modalPresentationStyle = .overCurrentContext
        controller.present(alertVC, animated: true, completion: nil)
        return alertVC.eNext
    }
}

// MARK: Class's private methods
private extension AlertFoundDriverVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize(by user: FirebaseUser?) {
        // todo: Visualize view's here.\
        view.backgroundColor = Color.black40
        let containerView = UIView.create{
            $0.backgroundColor = .white
            $0.cornerRadius = 8
        }
        let w = UIScreen.main.bounds.width - 48
        containerView >>> view >>> {
            $0.snp.makeConstraints({ (make) in
                make.width.equalTo(w)
                make.center.equalToSuperview()
            })
        }
        
        self.containerView = containerView
        
        let lblTitle = UILabel.create {
            $0.textColor = .black
            $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            $0.text = Config.title
            $0.textAlignment = .center
        }
        
        
        let space0 = UIView.create {
            $0.backgroundColor = .white
            } >>> {
            $0.snp.makeConstraints({ (make) in
                make.height.equalTo(16)
            })
        }
        
        
        // Information
        let vInformation = DriverInformationView(by: .center)
        vInformation.update(name: user?.displayName)
        vInformation.update(avatarUrl: user?.avatarUrl?.url)
        
        let brand = driver?.vehicle?.brand
        let plate = driver?.vehicle?.plate
        vInformation.update(transportNumber: "\(brand.orNil(default: "")) . \(plate.orNil(default: ""))")
//        vInformation.update(rating: 5)
        
        let space1 = UIView.create {
            $0.backgroundColor = .white
            } >>> {
                $0.snp.makeConstraints({ (make) in
                    make.height.equalTo(24)
                })
        }
        space1.addSeperator()
        
        let button = UIButton.create({
            $0.backgroundColor = .clear
            $0.setTitleColor(Color.orange, for: .normal)
            $0.setTitle(Config.titleOK, for: .normal)
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
        }) >>> {
            $0.snp.makeConstraints({ (make) in
                make.height.equalTo(48.5)
            })
        }
        
        
        button.rx.tap.bind { [unowned self] in
            self.eNext.onNext(())
            self.eNext.onCompleted()
        }.disposed(by: disposeBag)

        UIStackView(arrangedSubviews: [lblTitle, space0, vInformation, space1, button]) >>> containerView >>> {
            $0.axis = .vertical
            $0.distribution = .fillProportionally
            } >>> {
                $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
                $0.snp.makeConstraints({ (make) in
                    make.top.equalTo(24)
                    make.bottom.equalToSuperview()
                    make.left.equalToSuperview()
                    make.right.equalToSuperview()
                })
        }
        
        containerView.transform = CGAffineTransform(translationX: 0, y: 1000)
        UIView.animate(withDuration: 0.7) {
            containerView.transform = .identity
        }
        
    }
    private func setupRX() {
        // todo: Bind data to UI here.
        self.eNext.subscribe(onCompleted: { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)
    }
}
