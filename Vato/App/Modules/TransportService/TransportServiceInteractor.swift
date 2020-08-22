//  File name   : TransportServiceInteractor.swift
//
//  Author      : Vato
//  Created date: 9/12/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

enum GroupTransport {
    private struct Config {
        static let taxi: [VatoServiceType] = [.taxi, .taxi7]
        static let delivery: [VatoServiceType] = [.delivery]
        static let car: [VatoServiceType] = [.car, .carPlus, .car7]
        static let bike: [VatoServiceType] = [.moto, .motoPlus]
    }
    
    case taxi
    case delivery
    case car
    case bike
    case other
    
    var name: String {
        switch self {
        case .taxi:
            return "Taxi"
        case .delivery:
            return Text.delivery.text
        case .car:
            return "Car"
        case .bike:
            return "Bike"
        case .other:
            return "Other"
        }
    }
    
    static func check(idService: Int) -> GroupTransport {
        guard let serviceType = VatoServiceType(rawValue: idService) else { return .other }
        if Config.taxi.contains(serviceType) { return .taxi }
        if Config.delivery.contains(serviceType) { return .delivery }
        if Config.car.contains(serviceType) { return .car }
        if Config.bike.contains(serviceType) { return .bike }
        
        return .other
    }
}


protocol TransportServiceRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol TransportServicePresentable: Presentable {
    var listener: TransportServicePresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol TransportServiceListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func closeTransPortService()
    func updateSelect(service: ServiceCanUseProtocol)
}

final class TransportServiceInteractor: PresentableInteractor<TransportServicePresentable>, TransportServiceInteractable, TransportServicePresentableListener {
    weak var router: TransportServiceRouting?
    weak var listener: TransportServiceListener?
    private let transportStream: TransportStream
    private let promotionStream: PromotionStream
    private let subjectData = ReplaySubject<[TransportGroup]>.create(bufferSize: 1)
    private let mSubjectType = ReplaySubject<Bool>.create(bufferSize: 1)
    private(set) var currentPromotion: PromotionModel?
    private(set) var currentBook: Booking?
    
    var eFixedBook: Observable<Bool> {
        return mSubjectType.asObserver()
    }

    var source: Observable<[TransportGroup]> {
        return subjectData.asObserver()
    }

    var selectdEvent: Observable<ServiceCanUseProtocol> {
        return transportStream.selectedService
    }

    // todo: Add additional dependencies to constructor. Do not perform any logic in constructor.
    init(presenter: TransportServicePresentable, transportStream: MutableTransportStream, promotionStream: PromotionStream) {
        self.transportStream = transportStream
        self.promotionStream = promotionStream
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        prepareData()
    }

    func updateSelect(service: ServiceCanUseProtocol) {
        self.listener?.updateSelect(service: service)
    }

    private func prepareData() {
        promotionStream.ePromotion.take(1).bind { [weak self](m) in
            self?.currentPromotion = m
        }.disposeOnDeactivate(interactor: self)
        
        transportStream.booking.take(1).bind { [weak self](b) in
            self?.currentBook = b
        }.disposeOnDeactivate(interactor: self)
        
//        TransportGroup
        

        transportStream.booking
            .map { $0.tripType == BookService.fixed }
            .bind(to: mSubjectType)
            .disposeOnDeactivate(interactor: self)
        self.findGroup().subscribe(subjectData).disposeOnDeactivate(interactor: self)
        
    }
    
    private func findGroup() -> Observable<[TransportGroup]> {
        let listFare = transportStream.listFare
    
        let source: Observable<[TransportGroup]> = listFare.map({ list -> [TransportGroup] in
            let items = list.map { item -> ServiceCanUseProtocol in
                let idService = item.setting.service
                let car = Car(id: idService, choose: true, name: item.setting.name ?? "", description: nil)
                let service = ServiceChooseGroup(idService: idService, service: car, fare: item)
                return service
            }
            let values = Dictionary(grouping: items, by: { GroupTransport.check(idService: $0.idService).name })
            return values.compactMap { TransportGroup(name: $0.key, services: $0.value) }
        })
        return source
        
        /*
        return transportStream.selectedService.map { $0.isGroupService }.flatMap ({ flag -> Observable<[TransportGroup]> in
            return flag ? source2 : source1
        })
 */
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }

    func closeTransPortService() {
        listener?.closeTransPortService()
    }
}
