//  File name   : TicketUserInfomationInteractor.swift
//
//  Author      : vato.
//  Created date: 10/9/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import Alamofire
import VatoNetwork

protocol TicketUserInfomationRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func routeToBusStation(originLocation: TicketLocation, destLocation: TicketLocation, streamType: BuslineStreamType)
    func openTermOfTicket(url: URL, title: String)
}

protocol TicketUserInfomationPresentable: Presentable {
    var listener: TicketUserInfomationPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
    func showPopupUpdateEmail(email: String)
}

protocol TicketUserInfomationListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func ticketUserInfomationMoveBack()
    func moveBackRoot()
    func moveManagerTicket()
    
}

final class TicketUserInfomationInteractor: PresentableInteractor<TicketUserInfomationPresentable> {
    struct Config {
        static let urlTermBuyTicket = "https://vato.vn/quy-dinh-mua-ve-xe-phuong-trang-tren-ung-dung-vato"
    }
    /// Class's public properties.
    weak var router: TicketUserInfomationRouting?
    weak var listener: TicketUserInfomationListener?

    /// Class's constructor.
    init(presenter: TicketUserInfomationPresentable,
         profileStream: ProfileStream,
         buyTicketStream: BuyTicketStreamImpl,
         authenticatedStream: AuthenticatedStream) {
        
        self.profileStream = profileStream
        self.buyTicketStream = buyTicketStream
        self.authentStream = authenticatedStream
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        
        // todo: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }

    /// Class's private properties.
    private var ticketUser: TicketUser? {
        didSet {
            if let model = ticketUser {
                ticketUserSubject.onNext(model)
            }
        }
    }
    private lazy var ticketUserSubject = ReplaySubject<TicketUser>.create(bufferSize: 1)
    private let profileStream: ProfileStream
    private let buyTicketStream: BuyTicketStreamImpl
    private var isBuyForCurrentUser: Bool = true
    private var currentUser: UserInfo?
    private let authentStream: AuthenticatedStream
    
}

// MARK: TicketUserInfomationInteractable's members
extension TicketUserInfomationInteractor: TicketUserInfomationInteractable {
    
    func moveManagerTicket() {
        listener?.moveManagerTicket()
    }
    
    func moveBackRoot() {
        listener?.moveBackRoot()
    }
    
    func chooseTicketBusStationMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func chooseTicketBusStationMoveNext(with busStation: TicketRoutes) {}
    
    func chooseTicketBusStationMoveNext(with routeStop: RouteStop) {}
    
    func ticketBusDidSelect(ticketRoute: TicketRoutes) {}
    
    func ticketBusDidSelect(routeStop: RouteStop) {}
}

// MARK: TicketUserInfomationPresentableListener's members
extension TicketUserInfomationInteractor: TicketUserInfomationPresentableListener {
    
    var dateStart: Date {
        return buyTicketStream.ticketModel.date ?? Date()
    }
    
    var originLocation: TicketLocation? {
        return buyTicketStream.ticketModel.originLocation
    }
    
    var destLocation: TicketLocation? {
        return buyTicketStream.ticketModel.destinationLocation
    }
    
    func nextWithoutUpdateEmail() {
        excuteNext()
    }
    
    func updateEmailToApi() {
        updateEmail()
        excuteNext()
    }
    
    func didTouchNext() {
        // check update email
        if isBuyForCurrentUser,
            let currentUser = self.currentUser,
            (currentUser.email ?? "").isEmpty == true ,
            let email = ticketUser?.email {
            presenter.showPopupUpdateEmail(email: email)
        } else {
            excuteNext()
        }
    }
    
    func openTermOfTicket() {
        guard let url = URL(string: Config.urlTermBuyTicket) else { return }
        router?.openTermOfTicket(url: url, title: "")
    }
    
    var ticketUserModel: TicketUser? {
        get {
            return ticketUser
        }
        
        set {
            ticketUser = newValue
        }
    }
    
    var ticketUserObser: Observable<TicketUser> {
        return ticketUserSubject.asObserver()
    }
    
    func resetInfoToCurrent() {
        isBuyForCurrentUser = true
        profileStream.user.take(1).bind {[weak self] (user) in
            self?.currentUser = user
            let ticketUser = TicketUser(phone: user.phone, name: user.fullName, email: user.email, phoneSecond: nil, identifyCard: "")
            
            
            if let userSaved = TicketLocalStore.shared.loadDefautUser() {
                if (ticketUser.email ?? "").isEmpty == true {
                    ticketUser.email = userSaved.email
                }
                if (ticketUser.identifyCard ?? "").isEmpty == true {
                    ticketUser.identifyCard = userSaved.identifyCard
                }
            }
            self?.ticketUser = ticketUser
            }.disposeOnDeactivate(interactor: self)
    }
    
    func resetInfo() {
        isBuyForCurrentUser = false
        let ticketUser = TicketUser(phone: "", name: "", email: "", phoneSecond: "", identifyCard: "")
        self.ticketUser = ticketUser
    }
    
    func ticketUserInfomationMoveBack() {
        listener?.ticketUserInfomationMoveBack()
    }
}

// MARK: Class's private methods
private extension TicketUserInfomationInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
    
    private func excuteNext() {
        buyTicketStream.update(user: ticketUser, type: .startTicket)
        guard let originLocation = buyTicketStream.ticketModel.originLocation,
            let destLocation = buyTicketStream.ticketModel.destinationLocation else { return }
        router?.routeToBusStation(originLocation: originLocation, destLocation: destLocation, streamType: .buyNewticket)
        
        if isBuyForCurrentUser,
            let user = ticketUser {
            TicketLocalStore.shared.save(user: user)
        }
    }
    
    private func updateEmail() {
        guard let email = self.ticketUser?.email,
            let currentAccount = self.currentUser else { return }
        
        authentStream
            .firebaseAuthToken
            .take(1)
            .subscribe(onNext: { (token) in
                self.currentUser?.email = email
                UserManager.instance.updateEmail(token: token, currentUser: currentAccount, email: email)
            }).disposeOnDeactivate(interactor: self)
    }
}
