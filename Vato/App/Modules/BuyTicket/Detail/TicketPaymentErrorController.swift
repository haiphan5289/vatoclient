//
//  TicketPaymentErrorController.swift
//  Vato
//
//  Created by vato. on 10/14/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit
import RxSwift

enum TicketPaymentErrorAction: Int {
    case cancel
    case retry
}

final class TicketPaymentErrorController: UIViewController {
    private lazy var disposeBag = DisposeBag()
    @IBOutlet weak var actionBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    private var state: BuyTicketPaymenState?
    @Published private var mAction: TicketPaymentErrorAction
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Text.informationTicket.localizedText
        setupNavigation()
        setupRX()
        self.updateUI()
    }

    private func updateUI() {
        self.titleLabel.text = self.state?.getTitle()
        self.messageLabel.text = self.state?.getMsg()
        self.actionBtn.setTitle(Text.paymentAgain.localizedText, for: .normal)
    }
    
    func update(state: BuyTicketPaymenState) {
        self.state = state
    }
    
    private func setupRX() {
        actionBtn.rx.tap.bind {[weak self] (_) in
            self?.mAction = .retry
        }.disposed(by: disposeBag)
    }
    
    private func setupNavigation() {
        let navigationBar = navigationController?.navigationBar
        let bgImage = UIImage(named:"bg_navigationbar")?.stretchableImage(withLeftCapWidth: 0, topCapHeight: 0)
        navigationBar?.setBackgroundImage(bgImage, for: .default)
        navigationBar?.barTintColor = Color.orange
        navigationBar?.isTranslucent = false
        navigationBar?.tintColor = .white
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        let image = UIImage(named: "ic_close_white")
        let button = UIButton(frame: CGRect(origin: .zero, size: image?.size ?? .zero))
        button.setImage(image, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
        let barButton = UIBarButtonItem(customView: button)
        navigationItem.leftBarButtonItem = barButton
        navigationItem.hidesBackButton = true
        
        button.rx.tap.bind(onNext: weakify { wSelf in
            wSelf.mAction = .cancel
        }).disposed(by: disposeBag)
    }
    
    static func showFail(on controller: UIViewController?, state: BuyTicketPaymenState) -> Observable<TicketPaymentErrorAction> {
        let storyboard = UIStoryboard(name: "TicketInfo", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "TicketPaymentErrorController") as? TicketPaymentErrorController else {
            fatalError("Please implement!!!")
        }
        vc.update(state: state)
        let navigation = UINavigationController(rootViewController: vc)
        navigation.modalTransitionStyle = .coverVertical
        navigation.modalPresentationStyle = .fullScreen
        return Observable.create { (s) -> Disposable in
            let dispose = vc.$mAction.take(1).subscribe(s)
            controller?.present(navigation, animated: true, completion: nil)
            return Disposables.create {
                navigation.dismiss(animated: true, completion: nil)
                dispose.dispose()
            }
        }.delay(.milliseconds(300), scheduler: MainScheduler.asyncInstance)
        
    }
}
