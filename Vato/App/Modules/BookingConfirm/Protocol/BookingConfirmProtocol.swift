//  File name   : BookingConfirmProtocol.swift
//
//  Author      : Dung Vu
//  Created date: 8/15/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import Firebase
import RxSwift
import RxCocoa
import VatoNetwork
import Alamofire
import RIBs

protocol BookingConfirmSecurityProtocol {
    var authenticated: AuthenticatedStream { get }
}

protocol BookingConfirmComponentProtocol: AnyObject {
    var confirmStream: ConfirmStreamImpl { get }
    var currentModelBook: BookingConfirmInformation { get }
    var firebaseDatabase: DatabaseReference  { get }
}

protocol BookingConfirmDependencyChangeState: AnyObject {
    var mutableBookingState: MutableBookingStateStream { get }
    var mutableBooking: MutableBookingStream { get}
    var json: [String: Any] { get }
}

protocol BookingConfirmProfileProtocol {
    var profileStream: MutableProfileStream { get }
}

protocol BookingConfirmPointsProtocol {
    var bookingPoints: BookingStream { get }
}

protocol BookingConfirmPaymentProtocol {
    var mutablePaymentStream: MutablePaymentStream { get }
}

extension BookingConfirmComponentProtocol {
    var currentPromotion: PromotionModel? {
        return confirmStream.currentPromotion
    }
    
    var noteStream: MutableNoteStream {
        return self.confirmStream
    }
    
    var transportStream: MutableTransportStream {
        return self.confirmStream
    }
    
    var priceUpdate: MutablePriceStream {
        return self.confirmStream
    }
    
    var tipStream: MutableTip {
        return self.confirmStream
    }
    
    var errorStream: MutableErrorBooking {
        return self.confirmStream
    }
    
    var tipConfig: TipConfig? {
        return confirmStream.tipConfig
    }
    
    var promotionStream: MutablePromotion {
        return self.confirmStream
    }
}

// MARK: - Dependency
extension BookingConfirmComponentProtocol where Self: ConfirmDetailDependency {
    var mPromotionStream: PromotionStream {
        return self.promotionStream
    }
    
    var mPriceUpdate: PriceStream {
        return self.priceUpdate
    }
    
    var mTransportStream: TransportStream {
        return self.transportStream
    }
}

// MARK: - Type alias
typealias BookingConfirmServicesType = BookingConfirmComponentProtocol & BookingConfirmPointsProtocol & BookingConfirmSecurityProtocol & BookingConfirmDependencyChangeState & BookingConfirmPaymentProtocol & BookingConfirmProfileProtocol


//// MARK: - Finding price
protocol BookingDependencyProtocol: AnyObject {
    var mComponent: BookingConfirmComponentProtocol & BookingConfirmSecurityProtocol { get }
    var currentBook: Booking? { get set }
    var listFare: PublishSubject<[FareDisplay]> { get }
    var directionFares: ReplaySubject<BookingConfirmDirectionFares> { get }
    var network: NetworkRequester { get }
    var groupServiceName: String { get }
    var segment: String? { get }
    
    // group: none: all, TAXI, DELIVERY
    func preparePrice()
    func findGroupService(group: String) -> Observable<OptionalMessageDTO<[ServiceGroup]>>
    func findDirectionFares(groups: [ServiceGroup]?)
    // Show alert
    func presentMessage(message: String)
}

struct FareCombine: Codable {
    var additionalServices: [AdditionalServices]?
    var settings: [FareSetting]?
    var predicates: [FarePredicate]?
    var modifiers: [FareModifier]?
}

extension BookingDependencyProtocol where Self: Interactor {
    var firebaseDatabase: DatabaseReference {
        return mComponent.firebaseDatabase
    }
    
    func updateZoneAddress() {
        var events = [Observable<Void>]()
        if let original = currentBook?.originAddress {
            currentBook?.originAddress.update(isOrigin: true)
            events.append(findZone(from: original.coordinate).do(onNext: { [weak self](z) in
                self?.currentBook?.originAddress.update(zoneId: z.id)
            }).map ({ _ in }))
        }
        
        if let destination = currentBook?.destinationAddress1 {
            currentBook?.destinationAddress1?.update(isOrigin: false)
            events.append(findZone(from: destination.coordinate).do(onNext: { [weak self](z) in
                self?.currentBook?.destinationAddress1?.update(zoneId: z.id)
            }).map ({ _ in }))
        }
        
        guard !events.isEmpty else {
            return
        }
        
        Observable.zip(events).subscribe { (_) in }.disposeOnDeactivate(interactor: self)
    }
    
    func findZone(from coordinate: CLLocationCoordinate2D) -> Observable<Zone> {
        return self.firebaseDatabase.findZone(with: coordinate).take(1)
    }
    
    func findFareSettingByFirebase(by zone: Zone) -> Observable<[FareSetting]> {
        return firebaseDatabase.findFare(by: zone).take(1)
    }
    
//    func findPrice(by zone: Zone, route: RouteTrip?) {
//        let oFindFareSetting = self.mComponent.tipStream.configs.take(1).flatMap { [weak self](config) -> Observable<[FareSetting]> in
//            guard let wSelf = self else { return Observable.empty() }
//            guard config.api_fare_settings == true else {
//                let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: [NSLocalizedDescriptionKey: "Using Firebase"])
//                return Observable.error(error)
//            }
//            return wSelf.findFareSettingByAPI().observeOn(MainScheduler.instance)
//            }.catchError { [weak self](e) -> Observable<[FareSetting]> in
//                printDebug(e)
//                guard let wSelf = self else { return Observable.empty() }
//                // Retry firebase
//                return wSelf.findFareSettingByFirebase(by: zone)
//        }
//
//        oFindFareSetting.map { $0.map { FareDisplay(with: $0, trip: route) } }.subscribe(onNext: { [weak self](list) in
//            self?.listFare.onNext(list)
//        }).disposeOnDeactivate(interactor: self)
//    }
    
    private func findListFareModifier() {
        self.firebaseDatabase.findListFareModifier().take(1).subscribe(onNext: { [weak self] list in
            self?.mComponent.transportStream.update(listModifiers: list)
            }, onError: { e in
                let error = e as NSError
                printDebug(error)
        }).disposeOnDeactivate(interactor: self)
    }
    
    private func findFarePredicate() {
        self.firebaseDatabase.findListFarePredicate().subscribe(onNext: { [weak self] list in
            self?.mComponent.transportStream.update(listPredicate: list)
            }, onError: { e in
                let error = e as NSError
                printDebug(error)
        }).disposeOnDeactivate(interactor: self)
    }
    
    /*
     get all group then remove taxi/Delivery
     */
    func findFareBook(by zone: Zone, route: RouteTrip?) {
        self.mComponent.authenticated.firebaseAuthToken.take(1).flatMap {
            Requester.responseDTO(decodeTo: OptionalMessageDTO<[ServiceGroup]>.self, using: VatoAPIRouter.getListServices(authToken: $0, sericeGroup: ""))
            }.flatMap { [weak self] response -> Observable<(group: FareCalculatedGroup, services: [ServiceGroup])> in
                guard let wSelf = self, let data = response.response.data else {
                    if let error = response.response.error {
                        return Observable.error(error)
                    } else {
                        return Observable.empty()
                    }
                }
                wSelf.mComponent.transportStream.update(serviceGroups: data)
                return wSelf.findFareServices(zone: zone, groups: data, route: route).map { ($0, data) }
            }.subscribe(onNext: { [weak self](item) in
                guard let wSelf = self else { return }
                let services = item.services
                let g = item.group
                
                var new: [FareCalculatedSetting] = []
                if let s = wSelf.mComponent.confirmStream.model.booking?.defaultSelect.service?.segment {
                    new = services
                        .filter { $0.segment == s }
                        .compactMap { s -> FareCalculatedSetting? in
                            guard let id = s.serviceId else { return nil }
                            let group = g["\(id)"]
                            return FareCalculatedSetting(name: s.displayName, groupName: s.transport, active: s.active, zoneId: zone.id, service: id, isGroupService: false, groupsService: group)
                    }
                }
                
                let listDisplay = new.map { FareDisplay(with: $0, trip: route) }
                self?.mComponent.transportStream.updateList(listFare: listDisplay)
                
                
                let listAdditionalServices = g.values.map({ (listFare) -> [AdditionalServices] in
                    return listFare.reduce([], { (result, fare) -> [AdditionalServices] in
                        return result + (fare.additional_services ?? []).map({ (s) -> AdditionalServices in
                            var clone = s
                            clone.service = fare.service_id
                            return clone
                        })
                    })
                }).reduce([], { $0 + $1 })
                
                let setAdditionalServices = Set(listAdditionalServices)
                
                self?.mComponent.transportStream.update(listAdditionalServices: Array(setAdditionalServices))

            }, onError: { (e) in
                print(e.localizedDescription)
            }).disposeOnDeactivate(interactor: self)
    }
    
    private func findFareServices(zone: Zone, groups: [ServiceGroup]?,route: RouteTrip?) -> Observable<FareCalculatedGroup> {
        guard let groups = groups,
            let distance = route?.distance.value,
            let duration = route?.duration.value,
            let startCoord = currentBook?.originAddress.coordinate,
            let endCoord = currentBook?.destinationAddress1?.coordinate
        else {
            return Observable.empty()
        }
        
        let ids = Set(groups.compactMap { $0.serviceId })
        var addInfo = JSON()
        addInfo["start_address"] = currentBook?.originAddress.secondaryText
        addInfo["end_address"] = currentBook?.destinationAddress1?.secondaryText
        addInfo["start_place_id"] = currentBook?.originAddress.placeId
        addInfo["end_place_id"] = currentBook?.destinationAddress1?.placeId
        let params = FareServiceParam(trip_type: BookService.fixed, zone_id: nil, distance: Int(distance), duration: Int(duration), start_lat: startCoord.latitude, start_lon: startCoord.longitude, end_lat: endCoord.latitude, end_lon: endCoord.longitude, service_ids: Array(ids), addInfo: addInfo)
        return self.mComponent.authenticated.firebaseAuthToken.take(1).flatMap {
            Requester.responseDTO(decodeTo: OptionalMessageDTO<FareCalculatedGroup>.self, using: VatoAPIRouter.getFaresServices(authToken: $0, param: params),method: .post, encoding: JSONEncoding.default)
            }.map ({
                $0.response.data
            })
            .filterNil()
    }
    
    func findFareSettingByAPI() -> Observable<[FareSetting]> {
        guard let book = self.currentBook else {
            let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: [NSLocalizedDescriptionKey: "Error Book"])
            return Observable.error(error)
        }
        
        let origin = book.originAddress.coordinate.value
        let destination = book.destinationAddress1?.coordinate.value
        
        return self.mComponent.authenticated.firebaseAuthToken.take(1).map {
            VatoAPIRouter.fareSetting(authToken: $0, origin: origin, destination: destination, version: nil)
            }.flatMap {
                Requester.responseDTO(decodeTo: OptionalMessageDTO<[FareSetting]>.self, using: $0)
            }.flatMap { r -> Observable<[FareSetting]> in
                //Rechecck
                let response = r.response
                Recheck: if let error = response.error {
                    return Observable.error(error)
                } else {
                    guard let list = response.data, list.count > 0 else {
                        let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: [NSLocalizedDescriptionKey: "No Item !!!!"])
                        return Observable.error(error)
                    }
                    return Observable.just(list)
                }
        }
    }
}
