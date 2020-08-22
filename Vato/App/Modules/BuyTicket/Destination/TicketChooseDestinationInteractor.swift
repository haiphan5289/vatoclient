//  File name   : TicketChooseDestinationInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 10/1/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork
import FwiCoreRX

enum TicketChooseDestinationErrType {
    case noData
    case success
    case err
}
protocol TicketChooseDestinationRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol TicketChooseDestinationPresentable: Presentable {
    var listener: TicketChooseDestinationPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol TicketChooseDestinationListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func updatePoint(type: DestinationType, point: TicketLocation)
    func chooseDestinationMoveBack()
}

final class TicketChooseDestinationInteractor: PresentableInteractor<TicketChooseDestinationPresentable>, ActivityTrackingProgressProtocol {
    /// Class's public properties.
    weak var router: TicketChooseDestinationRouting?
    weak var listener: TicketChooseDestinationListener?

    /// Class's constructor.
    init(presenter: TicketChooseDestinationPresentable, authStream: AuthenticatedStream) {
        super.init(presenter: presenter)
        presenter.listener = self
        self.authStream = authStream
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
    private var authStream: AuthenticatedStream?
    private let listDataPlaces = ReplaySubject<[TicketDestinationPoint]>.create(bufferSize: 1)
    private lazy var disposeBag = DisposeBag()
    private lazy var errorSubjectOriginLocation : PublishSubject<TicketChooseDestinationErrType> = PublishSubject()
    private lazy var errorSubjectDestinationLocation: PublishSubject<TicketChooseDestinationErrType> = PublishSubject()
}

// MARK: TicketChooseDestinationInteractable's members
extension TicketChooseDestinationInteractor: TicketChooseDestinationInteractable {
}

// MARK: TicketChooseDestinationPresentableListener's members
extension TicketChooseDestinationInteractor: TicketChooseDestinationPresentableListener {
    var errorObserableDestinationLocation: Observable<TicketChooseDestinationErrType> {
        return errorSubjectDestinationLocation.asObserver()
    }
    
    var errorObserableOriginLocation: Observable<TicketChooseDestinationErrType> {
        return errorSubjectOriginLocation.asObserver()
    }
    
    func getPoints(with type: DestinationType, originCode: String?) {
        self.authStream?.firebaseAuthToken.take(1).map {
            VatoTicketApi.listOriginPoint(authToken: $0)
            }.flatMap {
                Requester.responseCacheDTO(decodeTo: OptionalMessageDTO<[TicketDestinationPoint]>.self, using: $0)
            }.trackProgressActivity(self.indicator)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {[weak self] (r) in
                var result: [TicketDestinationPoint] = []
                if type == .origin {
                    let listData = r.response.data.orNil(default: [])
                    
                    for item in listData {
                        let isExist = result.filter { $0.originCode == item.originCode }.count == 0 ? false : true
                        if !isExist {
                            result.append(item)
                        }
                    }
                    if result.isEmpty {
                        self?.errorSubjectOriginLocation.onNext(.noData)
                    } else {
                        self?.errorSubjectOriginLocation.onNext(.success)
                    }
                } else {
                    var listData: [TicketDestinationPoint] = r.response.data.orNil(default: [])
                    if let code = originCode {
                        listData = listData.filter{ $0.originCode == code }
                    }
                    
                    for item in listData {
                        let isExist = result.filter { $0.destCode == item.destCode }.count == 0 ? false : true
                        if !isExist {
                            result.append(item)
                        }
                    }
                    if result.isEmpty {
                        self?.errorSubjectDestinationLocation.onNext(.noData)
                    } else {
                        self?.errorSubjectDestinationLocation.onNext(.success)
                    }
                }
                self?.listDataPlaces.onNext(result)
            }, onError: {[weak self] (e) in
                    self?.errorSubjectDestinationLocation.onNext(.err)
            }).disposed(by: self.disposeBag)
    }
    
    var listPlaceObservable: Observable<[TicketDestinationPoint]> {
        return listDataPlaces.asObserver()
    }
    
    func getListPoint(with type: DestinationType, originCode: String?) {
        self.getPoints(with: type, originCode: originCode)
    }
    
    func update(type: DestinationType, point: TicketLocation) {
        listener?.updatePoint(type: type, point: point)
    }
    
    func moveBack() {
        listener?.chooseDestinationMoveBack()
    }
    
    var loading: Observable<(Bool,Double)>  {
        return self.indicator.asObservable()
    }
}

// MARK: Class's private methods
private extension TicketChooseDestinationInteractor {
    private func setupRX() {
        // todo: Bind data stream here
    }
}
