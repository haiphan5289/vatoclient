//  File name   : BookingConfirmDirectionFares.swift
//
//  Author      : Dung Vu
//  Created date: 6/12/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import RIBs
import RxSwift
import RxCocoa
import VatoNetwork
import Alamofire

struct BookingConfirmDirectionFares: Codable {
    struct Direction: Codable {
        var distance: Double
        var duration: Double
        
        var overviewPolyline: String
        
        var route: RouteTrip {
            let i1 = RouteInformation(text: "", value: distance)
            let i2 = RouteInformation(text: "", value: duration)
            let r = RouteTrip(distance: i1, duration: i2)
            return r
        }
    }
    
    var direction_info: Direction
    var service_fares: FareCalculatedGroup?
}

fileprivate struct API {
    static let url: (String) -> String = {
        let rootURL: String
        #if DEBUG
           rootURL = "https://api-dev.vato.vn/api"
        #else
           rootURL = "https://api.vato.vn/api"
        #endif
        return rootURL + $0
    }
}

extension BookingDependencyProtocol where Self: Interactor, Self: ActivityTrackingProgressProtocol {
    var network: NetworkRequester {
        return NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
    }
    
    func preparePrice() {
        findGroupService(group: groupServiceName)
            .observeOn(MainScheduler.asyncInstance)
            .do(onNext: { [weak self](group) in
                guard let wSelf = self else { return }
                wSelf.mComponent.transportStream.update(serviceGroups: group.data ?? [])
            }).subscribe { [weak self](event) in
               guard let wSelf = self else { return }
                switch event {
                case .next(let g):
                    if g.fail {
                        let message = g.message
                        wSelf.presentMessage(message: message ?? "")
                    } else {
                        wSelf.findDirectionFares(groups: g.data)
                    }
                case .error(let e):
                    wSelf.presentMessage(message: e.localizedDescription)
                default:
                    break
                }
        }.disposeOnDeactivate(interactor: self)
    }
    
    func findGroupService(group: String) -> Observable<OptionalMessageDTO<[ServiceGroup]>> {
        let router = VatoAPIRouter.getListServices(authToken: "", sericeGroup: group)
        return network.request(using: router, decodeTo: OptionalMessageDTO<[ServiceGroup]>.self).trackProgressActivity(indicator).map { try $0.get() }
    }
    
    func findDirectionFares(groups: [ServiceGroup]?) {
        guard let groups = groups else { return }
        let startCoord = currentBook?.originAddress.coordinate
        let endCoord = currentBook?.destinationAddress1?.coordinate
        let ids = Set(groups.compactMap { $0.serviceId })
        var params: JSON = JSON()
        params["addition_price"] = 0
        params["start_address"] = currentBook?.originAddress.secondaryText
        params["end_address"] = currentBook?.destinationAddress1?.secondaryText
        params["start_place_id"] = currentBook?.originAddress.placeId
        params["end_place_id"] = currentBook?.destinationAddress1?.placeId
        params["end_lat"] = endCoord?.latitude
        params["end_lon"] = endCoord?.longitude
        params["start_lat"] = startCoord?.latitude
        params["start_lon"] = startCoord?.longitude
        params["trip_type"] = currentBook?.tripType
        params["service_ids"] = Array(ids)
        
        let p = API.url("/products/services/direction-fares")
        let router = VatoAPIRouter.customPath(authToken: "", path: p , header: nil , params: params, useFullPath: true)
        
        network.request(using: router,
                        decodeTo: OptionalMessageDTO<BookingConfirmDirectionFares>.self,
                        method: .post,
                        encoding: JSONEncoding.default).trackProgressActivity(indicator).bind { [weak self](result) in
            guard let wSelf = self else { return }
            switch result {
            case .success(let r):
                if r.fail {
                    let message = r.message
                    wSelf.presentMessage(message: message ?? "")
                } else {
                    guard let data = r.data else {
                        return
                    }
                    wSelf.directionFares.onNext(data)
                }
            case .failure(let e):
                #if DEBUG
                assert(false, e.localizedDescription)
                #endif
                wSelf.presentMessage(message: e.localizedDescription)
            }
        }.disposeOnDeactivate(interactor: self)
    }
    
    func registerHandlerFares() {
        let groups = self.mComponent.confirmStream.serviceGroup//.take(1)
        let fares = self.directionFares//.take(1)
    
        Observable.zip(groups, fares) {
            return (servicesGroup: $0, fares: $1)
        }.bind { [weak self](item) in
            guard let wSelf = self else { return }
            wSelf.handler(item.servicesGroup, fares: item.fares)
        }.disposeOnDeactivate(interactor: self)
    }
    
    private func handler(_ servicesGroup: [ServiceGroup], fares: BookingConfirmDirectionFares) {
        let g = fares.service_fares ?? [:]
        let zoneId = self.mComponent.confirmStream.model.zone
        let route = fares.direction_info.route
        
        var new: [FareCalculatedSetting] = []
        if let s = self.segment {
            new = servicesGroup
                .filter { $0.segment == s }
                .compactMap { s -> FareCalculatedSetting? in
                    guard let id = s.serviceId else { return nil }
                    let group = g["\(id)"]
                    return FareCalculatedSetting(name: s.displayName, groupName: s.transport, active: s.active, zoneId: zoneId?.id ?? 0, service: id, isGroupService: true, groupsService: group)
            }
        } else {
            #if DEBUG
               assert(false, "please check!!!!")
            #endif
        }
        
        let listDisplay = new.map { FareDisplay(with: $0, trip: route) }
        self.mComponent.transportStream.updateList(listFare: listDisplay)
        
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
        self.mComponent.transportStream.update(listAdditionalServices: Array(setAdditionalServices))
    }
}
