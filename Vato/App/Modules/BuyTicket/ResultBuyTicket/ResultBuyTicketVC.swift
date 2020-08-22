//  File name   : ResultBuyTicketVC.swift
//
//  Author      : vato.
//  Created date: 10/13/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxSwift
import FwiCore
import FwiCoreRX
protocol ResultBuyTicketPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var ticketModel: TicketInformation { get }
    var streamType: BuslineStreamType { get }
    var ticketModelDetail: TicketHistoryType? { get }
    var buyTicketStream: BuyTicketStreamImpl { get }
    var loadingProgress: Observable<ActivityProgressIndicator.Element> { get }
    
    func requestDetailTicketRoute(item: TicketHistoryType?)
    func moveBack()
    func moveBackBuyNewTicket()
    func moveManagerTicket()
}

final class ResultBuyTicketVC: UIViewController, ResultBuyTicketPresentable, ResultBuyTicketViewControllable, DisposableProtocol, LoadingAnimateProtocol {
    @IBOutlet weak var buyNewTicketBtn: UIButton!
    @IBOutlet weak var manageTicketBtn: UIButton!
    
    /// Class's public properties.
    weak var listener: ResultBuyTicketPresentableListener?
    private var current: TicketHistoryType?
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        controllerDetail?.updateUI(model: listener?.buyTicketStream.ticketModel)
        if listener?.buyTicketStream.isRoundTrip == true {
            controllerDetail?.updateReturnUI(model: listener?.buyTicketStream.returnTicketModel)
        }
        setupRX()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }

    /// Class's private properties.
    internal lazy var disposeBag = DisposeBag()
    
    var controllerDetail: TicketInfoVC? {
        return children.compactMap { $0 as? TicketInfoVC }.first
    }
}

// MARK: View's event handlers
extension ResultBuyTicketVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let actionVC = segue.destination as? TicketHistoryActionVC,
            let item = sender as? TicketHistoryType {
            current = item
            actionVC.buyNew = true
            actionVC.actionSelectDisplay = item
            actionVC.listener = self
            return
        }
    }
}

extension ResultBuyTicketVC: TicketHistoryActionHandlerProtocol {
    func excuteAction(type: ActionSelectTicket) {
        switch type {
        case .routeInfo:
            listener?.requestDetailTicketRoute(item: current)
        default:
            break
        }
    }
}

// MARK: Class's public methods
extension ResultBuyTicketVC {}

// MARK: Class's private methods
private extension ResultBuyTicketVC {
    private func setupRX() {
        showLoading(use: listener?.loadingProgress)
        self.buyNewTicketBtn.rx.tap.bind {[weak self] (_) in
            self?.listener?.moveBackBuyNewTicket()
        }.disposed(by: disposeBag)
        
        self.manageTicketBtn.rx.tap.bind {[weak self] (_) in
            self?.listener?.moveManagerTicket()
        }.disposed(by: disposeBag)
        //showAction
        
        var events = [Observable<TicketHistoryType?>?]()
        let e1 = controllerDetail?.btnDetailDepart?.rx.tap.map { [weak self] in
            return self?.listener?.buyTicketStream.ticketModel.detail
        }
        let e2 = controllerDetail?.btnDetailReturn?.rx.tap.map { [weak self] in
            return self?.listener?.buyTicketStream.returnTicketModel.detail
        }
        events.append(e1)
        events.append(e2)
        
        Observable.merge(events.compactMap { $0 }).bind(onNext: weakify({ (i, wSelf) in
            wSelf.performSegue(withIdentifier: "showAction", sender: i)
        })).disposed(by: disposeBag)
    }
    
    private func localize() {
        // todo: Localize view's here.
        manageTicketBtn.setTitle(Text.ticketManage.localizedText, for: .normal)
        buyNewTicketBtn.setTitle(Text.newTicket.localizedText, for: .normal)
    }
    
    private func visualize() {
        title = Text.informationTicket.localizedText    
        setupNavigation()
        // todo: Visualize view's here.
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
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let rightBarButton = UIBarButtonItem(customView: button)
        navigationItem.rightBarButtonItem = rightBarButton
        navigationItem.hidesBackButton = true
        
        button.rx.tap.bind(onNext: weakify { wSelf in
            wSelf.listener?.moveBack()
        }).disposed(by: disposeBag)
    }
}
