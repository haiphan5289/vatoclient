//  File name   : ChangeDestinationConfirmInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 4/9/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import Alamofire
import VatoNetwork
import FirebaseFirestore

enum ChangeDestinationUpdateType: Int {
    case accept
    case reject
    case timeout
    case cancel
    
    var message: String? {
        switch self {
        case .reject:
            return Text.inTripAddDestinationReject.localizedText
        case .timeout:
            return Text.inTripAddDestinationTimeout.localizedText
        default:
            return nil
        }
    }
}

protocol ChangeDestinationConfirmRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol ChangeDestinationConfirmPresentable: Presentable {
    var listener: ChangeDestinationConfirmPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol ChangeDestinationConfirmListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func changeDestinationHandlerUpdate(type: ChangeDestinationUpdateType)
}

final class ChangeDestinationConfirmInteractor: PresentableInteractor<ChangeDestinationConfirmPresentable> {
    /// Class's public properties.
    weak var router: ChangeDestinationConfirmRouting?
    weak var listener: ChangeDestinationConfirmListener?
    private let request: InTripRequestChangeDestination
    private let tripId: String
    private let time = FireBaseTimeHelper.default.currentTime
    internal lazy var lock: NSRecursiveLock = NSRecursiveLock()
    internal lazy var listenerManager: [Disposable] = []
    private let dateExpire: Date
    private var isLoading: Bool = false
    @Replay(queue: MainScheduler.asyncInstance) var type: ChangeDestinationUpdateType
    @Replay(queue: MainScheduler.asyncInstance) private var mSeconds: Int
    
    /// Class's constructor.
    init(presenter: ChangeDestinationConfirmPresentable,
         request: InTripRequestChangeDestination,
         tripId: String)
    {
        
        self.request = request
        self.tripId = tripId
        self.dateExpire = Date(timeIntervalSince1970: request.expired_at / 1000)
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        listenUpdateRequest()
        // todo: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }
    
    private func listenUpdateRequest() {
        guard let userId = UserManager.instance.userId else { return }
        let collectionRef = Firestore.firestore().collection(collection: .custom(id: "Notifications"), .custom(id: "\(userId)"), .custom(id: "client"))
        collectionRef.listenChanges().debug("!!!! Notifications").map { $0[.added] }.filterNil().bind(onNext: weakify({ (snapshots, wSelf) in
            var items = snapshots.compactMap { try? $0.decode(to: AddDestinationNotification.self) }.filter { ($0.created_at ?? 0) >= (wSelf.time - 300) }
            items.sort(by: >)
            guard let i = items.first else { return }
            wSelf.handler(notify: i)
        })).disposeOnDeactivate(interactor: self)
    }
    
    private func handler(notify: AddDestinationNotification) {
        guard let status = notify.payload?.status else { return }
        switch status {
        case .accept:
            type = .accept
        case .reject:
            type = .reject
        default:
            break
        }
    }

    /// Class's private properties.
    private lazy var networkRequester = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
}

// MARK: ChangeDestinationConfirmInteractable's members
extension ChangeDestinationConfirmInteractor: ChangeDestinationConfirmInteractable, Weakifiable, ManageListenerProtocol {
    var seconds: Observable<Int> {
        return $mSeconds
    }
    
    func addEventCancel(e: Observable<Void>) {
        let dispose = e.bind(onNext: weakify({ (wSelf) in
            wSelf.requestCancel()
        }))
        add(dispose)
    }
}

// MARK: ChangeDestinationConfirmPresentableListener's members
extension ChangeDestinationConfirmInteractor: ChangeDestinationConfirmPresentableListener, ActivityTrackingProgressProtocol {
}

// MARK: Class's private methods
private extension ChangeDestinationConfirmInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
        $type.bind(onNext: weakify({ (update, wSelf) in
            wSelf.cleanUpListener()
            wSelf.listener?.changeDestinationHandlerUpdate(type: update)
        })).disposeOnDeactivate(interactor: self)
        
        let dispose = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.asyncInstance).startWith(-1).bind(onNext: weakify({ (_, wSelf) in
            let remain = wSelf.dateExpire.timeIntervalSinceNow
            guard remain >= 0 else {
                wSelf.type = .timeout
                return
            }
            wSelf.mSeconds = Int(remain)
        }))
        add(dispose)
        
        self.loadingProgress.map { $0.0 }.bind(onNext: weakify({ (load, wSelf) in
            wSelf.isLoading = load
        })).disposeOnDeactivate(interactor: self)
    }
    
    func requestCancel() {
        guard !isLoading else { return }
        let id = self.request.id
        let params = ["reason": "Khách hàng huỷ", "status": "CANCEL"]
        let router = VatoAPIRouter.customPath(authToken: "", path: "user/destination-orders/\(id)", header: nil, params: params, useFullPath: false)
        let dispose = networkRequester.request(using: router, decodeTo: OptionalIgnoreMessageDTO<String>.self, method: .put, encoding: JSONEncoding.default)
            .trackProgressActivity(indicator)
            .bind(onNext: weakify({ (result, wSelf) in
            switch result {
            case .success:
                wSelf.type = .cancel
            case .failure(let e):
                print(e.localizedDescription)
            }
        }))
        add(dispose)
    }
    
}
