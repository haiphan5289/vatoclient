//  File name   : ChangeTicketVC.swift
//
//  Author      : MacbookPro
//  Created date: 11/10/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxSwift

protocol ChangeTicketPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func changeTicketMoveBack()
    func didSelectType(type: TicketInputInfoStep)
    var ticketObservable: Observable<TicketInformation> { get }
    func routeToConfirmPayment()
    var ticketInputInfoStep: Observable<TicketInputInfoStep> { get }
}

final class ChangeTicketVC: UIViewController, ChangeTicketPresentable, ChangeTicketViewControllable {

    private struct Config {
    }
    
    /// Class's public properties.
    @IBOutlet weak var btConfirmChangeTicket: UIButton!
    weak var listener: ChangeTicketPresentableListener?
    
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
        controllerDetail?.listener = self
        btConfirmChangeTicket.backgroundColor = Color.reddishOrange60
        btConfirmChangeTicket.isEnabled = false
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }
    var controllerDetail: ChangeTicketDetailVC? {
        return children.compactMap { $0 as? ChangeTicketDetailVC }.first
    }

    /// Class's private properties.
    private lazy var disposeBag = DisposeBag()
}

// MARK: View's event handlers
extension ChangeTicketVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension ChangeTicketVC {
}

// MARK: Class's private methods
private extension ChangeTicketVC {
    
    private func setupRX() {
        listener?.ticketObservable.subscribe(onNext: { [weak self] (model) in
            self?.controllerDetail?.updateUI(ticketModel: model)
            if model.isReadyChangeTicket() == true {
                self?.btConfirmChangeTicket.backgroundColor = Color.orange
                self?.btConfirmChangeTicket.isEnabled = true
            } else {
                self?.btConfirmChangeTicket.backgroundColor = Color.reddishOrange60
                self?.btConfirmChangeTicket.isEnabled = false
            }
        }).disposed(by: disposeBag)
        
        listener?.ticketInputInfoStep.subscribe(onNext: { [weak self] (step) in
            self?.controllerDetail?.updateUI(currentStep: step)
        }).disposed(by: disposeBag)
        
        btConfirmChangeTicket.rx.tap.bind { [weak self] _ in
            self?.listener?.routeToConfirmPayment()
        }.disposed(by: disposeBag)
    }
    
    private func localize() {
        // todo: Localize view's here.
        self.btConfirmChangeTicket.setTitle(Text.confirmChangeTicket.localizedText, for: .normal)
    }
   
    private func visualize() {
        // todo: Visualize view's here.
        self.setupNavigation()
    }
    
    private func setupNavigation() {
        self.title = Text.ticket.localizedText
        
        let navigationBar = navigationController?.navigationBar
        let bgImage = UIImage(named:"bg_navigationbar")?.stretchableImage(withLeftCapWidth: 0, topCapHeight: 0)
        navigationBar?.setBackgroundImage(bgImage, for: .default)
        navigationBar?.barTintColor = Color.orange
        navigationBar?.isTranslucent = false
        navigationBar?.tintColor = .white
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        
        // left button
        let image = UIImage(named: "ic_arrow_back")
        let button = UIButton(frame: CGRect(origin: .zero, size: image?.size ?? .zero))
        button.setImage(image, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
        let leftBarButton = UIBarButtonItem(customView: button)
        navigationItem.leftBarButtonItem = leftBarButton
        navigationItem.hidesBackButton = true
        button.rx.tap.bind(onNext: weakify { wSelf in
            wSelf.listener?.changeTicketMoveBack()
        }).disposed(by: disposeBag)
     
    }
}

extension ChangeTicketVC: ChangeTicketDetailListener {
    func didSelectType(type: TicketInputInfoStep) {
        self.listener?.didSelectType(type: type)
    }
}
