//  File name   : TicketDestinationVC.swift
//
//  Author      : Dung Vu
//  Created date: 10/1/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxSwift
import FwiCoreRX
import VatoNetwork

protocol TicketDestinationPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var ticketObservable: Observable<TicketInformation> { get }
    var returnTicketObservable: Observable<TicketInformation> { get }
    var error: Observable<TicketDestinationError> { get }
    var isRoundTrip: Observable<Bool> { get }
    var popularRoutes: Observable<[PopularRoute]> { get }
    var action: Observable<TicketDestinationAction?> { get }
    var userId: Int { get }
    var loadingProgress: Observable<ActivityProgressIndicator.Element> { get }
    var detailRoute: Observable<DetailRouteInfo> { get }
    
    func ticketMoveBack()
    func routeToStartLocation()
    func swapLocation()
    func routeToDestinationLocation()
    func routeToChooseDate()
    func routeToFillInformation()
    func selectOnOffRoundStrip(isRoudtrip: Bool)
    func routeToChooseDateReturn()
    func routeToHistory()
    func requestList(params: [String: Any]) -> Observable<ResponsePaging<TicketHistoryType>>
    func routeToDepartTicket(item: TicketHistoryType?)
    func didSelectPopularRoute(route: PopularRoute?)
    func loadDefaultPopularRoute()
    func updateAction(item: BusLineHomeItem)
    func moveDetailRoute(_ info: DetailRouteInfo)
    func getRouteId(route: PopularRoute)
    func getRouteInfo(routeId: Int, route: PopularRoute, date: String?, time: String?, wayId: Int?)
    
    func request<T: Codable>(router: APIRequestProtocol, decodeTo: T.Type, block: ((JSONDecoder) -> Void)?) -> Observable<T>
}

enum TypeRoute: String, CaseIterable {
    case all = "POPULAR"
    case promotion
    
    var name: String {
      switch self {
        case .all: return Text.all.localizedText
        case .promotion: return Text.promotion.localizedText
      }
    }
    
    var next: TypeRoute {
        switch self {
        case .all:
            return .promotion
        case .promotion:
            return .all
        }
    }
}

final class TicketDestinationVC: UIViewController, TicketDestinationPresentable, TicketDestinationViewControllable {
    /// Class's public properties.
    weak var listener: TicketDestinationPresentableListener?
    
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        controllerDetail?.listener = self
        findRouteBtn.isEnabled = false
        findRouteBtn.backgroundColor = #colorLiteral(red: 0.7529411765, green: 0.7764705882, blue: 0.8, alpha: 1)
        controllerDetail?.setupRX()
        visualize()
        setupRX()
        self.listener?.selectOnOffRoundStrip(isRoudtrip: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
        requestList()
    }
    
    /// Class's private properties.
    internal lazy var disposeBag = DisposeBag()
    @IBOutlet weak var findRouteBtn: UIButton!
    private var guideView: VatoGuideControl?
    
    var controllerDetail: TicketDestinationDetailVC? {
        return children.compactMap { $0 as? TicketDestinationDetailVC }.first
    }
    private var disposeRequest: Disposable?
    
    func updateSelectedPopularRoute(type: DestinationType, point: TicketLocation?) {
        self.controllerDetail?.updateSelectedPopularRoute(type: type, point: point)
    }
}

// MARK: View's event handlers
extension TicketDestinationVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    func showAlertFail(message: String?) {
        AlertVC.showError(for: self.uiviewController, message: message ?? "")
    }
}

// MARK: Class's public methods
extension TicketDestinationVC {
    func requestList() {
        guard let userId = UserManager.instance.userId else { return }
        disposeRequest?.dispose()
        var params: [String: Any] = [:]
        params["page"] = 1
        params["pageSize"] = 5
        params["type"] = TicketHistory.future.value
        params["userId"] = userId
        disposeRequest = listener?.requestList(params: params)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: weakify({ (res, wSelf) in
                let data = res.data ?? []
                wSelf.controllerDetail?.updateData(model: data, totalTicket: res.total)
            }), onError: { [weak self] (e) in
                self?.controllerDetail?.updateData(model: nil, totalTicket: 0)
            })
    }
}

extension TicketDestinationVC: TicketDestinationDetailVCListener, LoadingAnimateProtocol, DisposableProtocol {
    func request<T>(router: APIRequestProtocol, decodeTo: T.Type, block: ((JSONDecoder) -> Void)?) -> Observable<T> where T : Decodable, T : Encodable {
        guard let listener = listener  else {
            return Observable.empty()
        }
        return listener.request(router: router, decodeTo: OptionalMessageDTO<T>.self, block: {
            $0.dateDecodingStrategy = .customDateFireBase
        }).map { $0.data }.filterNil()
    }
        
    var popularRoutes: Observable<[PopularRoute]>? {
        return listener?.popularRoutes
    }
    
    var ticketObservable: Observable<TicketInformation>? {
        return listener?.ticketObservable
    }

    func didSelectItemDepart(item: TicketHistoryType?) {
        listener?.routeToDepartTicket(item: item)
    }
    
    func routeToChooseDateReturn() {
        listener?.routeToChooseDateReturn()
    }
    
    var isRoundTrip: Observable<Bool>? {
        return listener?.isRoundTrip
    }
    
    func selectOnOffRoundStrip(isRoudtrip: Bool) {
        listener?.selectOnOffRoundStrip(isRoudtrip: isRoudtrip)
    }
    
    func routeToStartLocation() {
        listener?.routeToStartLocation()
    }
    
    func routeToDestinationLocation() {
        listener?.routeToDestinationLocation()
    }
    
    func routeToChooseDate() {
        listener?.routeToChooseDate()
    }
    
    func routeToHistory() {
        listener?.routeToHistory()
    }
    
    func swapLocation() {
        listener?.swapLocation()
    }
    
    func routeToFillInformation() {
        listener?.routeToFillInformation()
    }
     
    func didSelectPopularRoute(route: PopularRoute?) {
        listener?.didSelectPopularRoute(route: route)
    }
    
    func selectPopularRouteAtIndex(index: Int) {
        self.controllerDetail?.selectPopularRouteAtIndex(index: index)
    }
        
    func getRouteId(route: PopularRoute) {
       listener?.getRouteId(route: route)
    }
    
    func getRouteInfo(routeId: Int, route: PopularRoute, date: String?, time: String?, wayId: Int?) {
        listener?.getRouteInfo(routeId: routeId, route: route, date: date, time: time, wayId: wayId)
    }
}

// MARK: Class's private methods
private extension TicketDestinationVC {
    private func localize() {
        // todo: Localize view's here.
    }
    
    private func visualize() {
        // todo: Visualize view's here.
        setupNavigation()
        findRouteBtn.setTitle(Text.findTrip.localizedText, for: .normal)
        title = Text.buyTicket.localizedText
        view.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        
        let addGuide = { [unowned self] in
            let guideView = VatoGuideControl()
            guideView >>> self.view >>> {
                $0.snp.makeConstraints { (make) in
                    make.right.equalTo(-16)
                    make.size.equalTo(CGSize(width: 72, height: 72))
                    if self.tabBarController?.tabBar.isHidden == true {
                        make.bottom.equalTo(self.view.snp.bottom).offset(-16)
                    } else {
                        if #available(iOS 11, *) {
                            make.bottom.equalTo(self.view.layoutMarginsGuide.snp.bottom).offset(-16)
                        } else {
                            let h = (self.tabBarController?.tabBar.bounds.height ?? 0) + 16
                            make.bottom.equalTo(self.view.layoutMarginsGuide.snp.bottom).offset(-h)
                        }
                    }
                }
            }
            self.guideView = guideView
        }
        addGuide()
    }
    
    func setupRX() {
        self.guideView?.rx.controlEvent(.touchUpInside).bind(onNext: weakify({ (wSelf) in
            WebVC.loadWeb(on: self, url: URL(string: "https://vato.vn/huong-dan-mua-ve-phuong-trang-futa-busline-cho-khach-hang-tren-app-vato/"), title: Text.guideBuyTicket.localizedText)
        })).disposed(by: disposeBag)
        
        showLoading(use: listener?.loadingProgress)
        findRouteBtn.rx.tap.bind {[weak self] _ in
            self?.listener?.routeToFillInformation()
        }.disposed(by: disposeBag)
        
        listener?.ticketObservable
            .bind(onNext: {[weak self] (model) in
                self?.controllerDetail?.updataData(model: model)
                if model.verifyToChooseBusStatus() == false  {
                    self?.findRouteBtn.isEnabled = false
                    self?.findRouteBtn.backgroundColor = #colorLiteral(red: 0.7529411765, green: 0.7764705882, blue: 0.8, alpha: 1)
                } else {
                    self?.findRouteBtn.isEnabled = true
                    self?.findRouteBtn.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1)
                }
            }).disposed(by: disposeBag)
        
        listener?.error.bind(onNext: {[weak self] (errorType) in
            var message: String?
            switch errorType {
            case .notFillFullInfomation:
                message = Text.completeInformationToContinue.localizedText
            case .dateRoundTripMustLasterDateStart:
                message = Text.returnDateMustGreaterThanDepartureDate.localizedText
            }
            if let message = message {
                AlertVC.showMessageAlert(for: self, title: "", message: message, actionButton1: Text.dismiss.localizedText, actionButton2: nil)
            }
        }).disposed(by: disposeBag)
        
        listener?.returnTicketObservable.bind(onNext: weakify({ (ticket, wSelf) in
            wSelf.controllerDetail?.updateReturnData(model: ticket)
        })).disposed(by: disposeBag)
        
        listener?.action.bind(onNext: weakify({ (action, wSelf) in
            guard let action = action else {
                wSelf.listener?.loadDefaultPopularRoute()
                return
            }
            switch action {
            case .history:
                wSelf.listener?.loadDefaultPopularRoute()
                wSelf.listener?.routeToHistory()
            case .select(let i):
                wSelf.listener?.updateAction(item: i)
            }
        })).disposed(by: disposeBag)
        
        listener?.detailRoute.bind(onNext: weakify({ (r, wSelf) in
            wSelf.listener?.moveDetailRoute(r)
        })).disposed(by: disposeBag)
    }
    
    private func setupNavigation() {
        let navigationBar = navigationController?.navigationBar
        let bgImage = UIImage(named:"bg_navigationbar")?.stretchableImage(withLeftCapWidth: 0, topCapHeight: 0)
        navigationBar?.setBackgroundImage(bgImage, for: .default)
        navigationBar?.barTintColor = Color.orange
        navigationBar?.isTranslucent = false
        navigationBar?.tintColor = .white
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        
        navigationBar?.shadowImage = UIImage()
        
        let image = UIImage(named: "ic_arrow_back")
        let button = UIButton(frame: CGRect(origin: .zero, size: image?.size ?? .zero))
        button.setImage(image, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
        let barButton = UIBarButtonItem(customView: button)
        navigationItem.leftBarButtonItem = barButton
        
        let rightView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 56, height: 44)))
        
        let imageRight = UIImage(named: "ic_ticket_history_nav")
        let rightImageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 56, height: 44)))
        
        rightImageView >>> rightView >>> {
            $0.image = imageRight
            $0.contentMode = .scaleAspectFit
            $0.snp.makeConstraints { (make) in
                make.top.equalToSuperview()
                make.centerX.equalToSuperview().offset(14)
                make.width.equalTo(56)
                make.height.equalTo(44)
            }
        }
            
        let label = UILabel(frame: .zero)
        label >>> rightView >>> {
            $0.textColor = .white
            $0.textAlignment = .center
            $0.font = UIFont.systemFont(ofSize: 10, weight: .regular)
            $0.text = Text.selectedBeds.localizedText
            $0.snp.makeConstraints { (make) in
                make.bottom.equalTo(-4)
                make.centerX.equalTo(rightImageView.snp.centerX).priority(.high)
            }
        }
        
        let buttonRight = UIButton(frame: CGRect(origin: .zero, size: image?.size ?? .zero))
        buttonRight >>> rightView >>> {
            $0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
        
        let barButtonRight = UIBarButtonItem(customView: rightView)
        rightView >>> {
            $0.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 56, height: 44))
            }
        }
        navigationItem.rightBarButtonItem = barButtonRight
        
        button.rx.tap.bind(onNext: weakify { wSelf in
            wSelf.listener?.ticketMoveBack()
        }).disposed(by: disposeBag)
        
        buttonRight.rx.tap.bind(onNext: weakify { wSelf in
            wSelf.listener?.routeToHistory()
        }).disposed(by: disposeBag)
    }
}
