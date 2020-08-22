//  File name   : ConfirmBuyTicketVC.swift
//
//  Author      : vato.
//  Created date: 10/10/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxSwift

protocol ConfirmBuyTicketPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func moveBack()
    func ticketModel() -> TicketInformation?
    var ticketModelObser: Observable<TicketInformation> { get }
    var titleButtonContinue: String { get }
    func routeToBuyTicketPayment()
    
    func routeSelectDate()
    func routeSelectRoute()
    func routeSelectTime()
    func routeSelectBusStop()
    func routeSelectSeats()
}

final class ConfirmBuyTicketVC: UIViewController, ConfirmBuyTicketPresentable, ConfirmBuyTicketViewControllable {
    @IBOutlet weak var buyTicketBtn: UIButton!
    
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: ConfirmBuyTicketPresentableListener?

    // MARK: View's lifecycle
    override func viewDidLoad() {
        controllerDetail?.listener = self
        super.viewDidLoad()
        visualize()
        setupRX()
        controllerDetail?.updateUI(ticketModel: self.listener?.ticketModel())
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }

    /// Class's private properties.
    var controllerDetail: BuyTicketConfirmDetail? {
        return children.compactMap { $0 as? BuyTicketConfirmDetail }.first
    }
    
    private lazy var disposeBag = DisposeBag()
}

// MARK: View's event handlers
extension ConfirmBuyTicketVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension ConfirmBuyTicketVC {
}

// MARK: Class's private methods
private extension ConfirmBuyTicketVC {
    private func localize() {
        // todo: Localize view's here.
    }
    
    private func visualize() {
        // todo: Visualize view's here.
        view.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        setupNavigation()
        buyTicketBtn.setTitle(listener?.titleButtonContinue ?? "", for: .normal)
    }
    
    private func setupRX() {
        buyTicketBtn.rx.tap.bind {[weak self] (_) in
            self?.listener?.routeToBuyTicketPayment()
        }.disposed(by: disposeBag)
        
        listener?.ticketModelObser.bind(onNext: {[weak self] (model) in
            self?.controllerDetail?.updateUI(ticketModel: model)
        }).disposed(by: disposeBag)
    }
    
    private func setupNavigation() {
        let navigationBar = self.navigationController?.navigationBar
        let bgImage = UIImage(named:"bg_navigationbar")?.stretchableImage(withLeftCapWidth: 0, topCapHeight: 0)
        navigationBar?.setBackgroundImage(bgImage, for: .default)
        navigationBar?.barTintColor = Color.orange
        navigationBar?.isTranslucent = false
        navigationBar?.tintColor = .white
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        let image = UIImage(named: "ic_arrow_back")
        let leftButton = UIButton(frame: CGRect(origin: .zero, size: image?.size ?? .zero))
        leftButton.setImage(image, for: .normal)
        leftButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
        let leftBarButton = UIBarButtonItem(customView: leftButton)
        navigationItem.leftBarButtonItem = leftBarButton
        leftButton.rx.tap.bind(onNext: weakify { wSelf in
            wSelf.listener?.moveBack()
        }).disposed(by: disposeBag)
        
        let originName = self.listener?.ticketModel()?.originLocation?.name ?? ""
        let destName = self.listener?.ticketModel()?.destinationLocation?.name ?? ""
        let viewNavigation = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))
        let titleNavigation = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 22))
        let subTitleNavigation = UILabel(frame: CGRect(x: 0, y: 22, width: UIScreen.main.bounds.size.width, height: 22))
        viewNavigation.addSubview(titleNavigation)
        titleNavigation.text = "\(originName) - \(destName)"
        titleNavigation.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        titleNavigation.textColor = .white
        viewNavigation.addSubview(subTitleNavigation)
        subTitleNavigation.text = Text.informationTrip.localizedText
        subTitleNavigation.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        subTitleNavigation.textColor = .white
        navigationItem.titleView = viewNavigation
        
    }
}

extension ConfirmBuyTicketVC: BuyTicketConfirmDetailListener {
    func routeSelectDate() {
        listener?.routeSelectDate()
    }
    func routeSelectRoute() {
        listener?.routeSelectRoute()
    }
    func routeSelectTime() {
        listener?.routeSelectTime()
    }
    func routeSelectBusStop() {
        listener?.routeSelectBusStop()
    }
    func routeSelectSeats() {
        listener?.routeSelectSeats()
    }
}
