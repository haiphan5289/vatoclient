//  File name   : BookingRequestInteractor+FindDriver.swift
//
//  Author      : Dung Vu
//  Created date: 1/18/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import RxSwift
import FwiCore
import VatoNetwork

// MARK: Codable
extension BookingRequestInteractor {
    func findDriver() {
        let currentModelBook = dependency.currentModelBook
        let favorite = currentModelBook.useFavoriteService
        let price = currentModelBook.service?.fare?.price ?? 0
        let tip = currentModelBook.tip.orNil(0)
        let farePrice = currentModelBook.informationPrice?.originalPrice ?? 0
        let fare = max((farePrice > 0 && price != 0) ? farePrice : price, 30000)
        let radius = self.radius
        let page = self.page
        let s = currentModelBook.service?.service
        let coorOrigin = currentModelBook.booking?.originAddress.coordinate
        let coordDestination = currentModelBook.booking?.destinationAddress1?.coordinate
        
        var _start = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        if let _startPrivate = coorOrigin {
            _start = _startPrivate
        }

        guard let id = s?.id else {
            fatalError("Miss Choose service")
        }
        
        dependency.authenticated.firebaseAuthToken.take(1).map {
            VatoAPIRouter.findDriverForBook(authToken: $0,
                                            distance: radius + 1,
                                            fare: (Double(fare) + tip),
                                            isFavorite: favorite,
                                            originCoor: _start,
                                            destinationCoor: coordDestination,
                                            page: page,
                                            service: id,
                                            size: Config.numberDriverRequest)
            }.flatMap {
                Requester.responseDTO(decodeTo: OptionalMessageDTO<[DriverSearch]>.self, using: $0)
            }.subscribe { [weak self](e) in
                guard let wSelf = self else { return }
                switch e {
                case .next(let r):
                    if let error = r.response.error {
                        printDebug(error.localizedDescription)
                        wSelf._eError.onNext(error)
                    } else {
                        let list = r.response.data ?? []
                        let result = list.filter { $0.service == id }
                        wSelf.handlerListResponse(from: result)
                    }
                case .error(let e):
                    wSelf._eError.onNext(e)
                default:
                    break
                }
            }.disposeOnDeactivate(interactor: self)
    }
    
    func handlerListResponse(from result: [DriverSearch]) {
        guard result.count > 0 else {
            self._eError.onNext(BookingError.noDriver)
            return
        }
        
        listDriver = result
        requestToDriver()
    }
    
    struct Vehicle: Codable {
        var taxiBrand: Int?
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            if let v = (try? values.decode(String.self, forKey: .taxiBrand)), let n = Int(v) {
                taxiBrand = n
            } else {
                taxiBrand = try values.decodeIfPresent(Int.self, forKey: .taxiBrand)
            }
        }
        
    }
    
    struct DriverTaxi: Codable {
        var vehicle: Vehicle?
    }
    
    private func requestDriverTaxi(userID: Int) -> Observable<Void> {
        return dependency.authenticated.firebaseAuthToken.take(1).map {
            VatoAPIRouter.findDriverInformation(authToken: $0, userId: "\(userID)")
        }.flatMap {
             Requester.responseDTO(decodeTo: MessageDTO<DriverTaxi>.self, using: $0)
        }.do(onNext: { [weak self](res) in
            let brand = res.response.data.vehicle?.taxiBrand
            self?.updatePriceTaxi(brand: brand)
        }).map { _ in }
    }
    
    private func updatePriceTaxi(brand: Int?) {
        let currentModelBook = self.bookingRequestStream.currentModelBook
        guard let brand = brand,
            let paymentMethodType = currentModelBook.paymentMethod?.type.method,
            let service = self.bookingRequestStream.currentModelBook.informationPrice?.service,
            let vatoServiceType = VatoServiceType(rawValue: service.idService),
            let price = service.groupsService?.first(where: { $0.taxi_brand_id == brand })
        else {
            return
        }
        tripInfor.info.taxiBrand = brand
        tripInfor.info.taxiBrandName = price.taxi_brand_name
        tripInfor.info.fareDriverSupport = UInt32(price.driver_support_fare?.roundPrice() ?? 0)
        let priceRound = price.total_fare?.roundPrice() ?? 0
        tripInfor.info.price = price.origin_fare?.roundPrice() ?? 0
        tripInfor.info.farePrice = priceRound
        tripInfor.info.fareDriverSupport = price.driver_support_fare?.roundPrice() ?? 0
        
        
        let bookingConfirmPrice = BookingConfirmPrice()
        bookingConfirmPrice.originalPrice = priceRound
        bookingConfirmPrice.lastPrice = priceRound
        var discount: UInt32
        do {
            try currentModelBook._promotionModel?.calculateDiscount(from: currentModelBook.booking, paymentType: paymentMethodType , price: bookingConfirmPrice, serviceType: vatoServiceType)
            discount = currentModelBook._promotionModel?.discount ?? 0
        } catch  {
            discount = 0
        }
        tripInfor.info.promotionValue = discount
        let lastOriginal = max(priceRound + UInt32(tripInfor.info.additionPrice) - tripInfor.info.promotionValue, 0)
        self._priceNew.onNext(lastOriginal.currency)
        
    }
    
    private func updateTrip(from next: DriverSearch, taxi: Bool = false) {
        let firebaseId = next.firebaseId
        tripInfor.info.driverFirebaseId = firebaseId
        tripInfor.info.driverUserId = next.id
        tripInfor.extra = FirebaseTrip.Extra.init(with: next, polylineReceive: dependency.currentModelBook.polyline)
        tripInfor.extra?.clientCreditAmount = self.currentCash
        tripInfor.info.clientVersion = AppConfig.default.appInfor?.version
        tripInfor.info.timestamp = FireBaseTimeHelper.default.currentTime
        if !taxi {
            tripInfor.info.fareDriverSupport = self.dependency.currentModelBook.informationPrice?.driverAmount ?? 0
        }
        tripInfor.info.priority = next.priority
        tripInfor.info.favorite = next.favorite
        
        tripInfor.info.startFavoritePlaceId = self.dependency.currentModelBook.booking?.originAddress.favoritePlaceID ?? 0
        tripInfor.info.endFavoritePlaceId = self.dependency.currentModelBook.booking?.destinationAddress1?.favoritePlaceID ?? 0
        
        // Remove
        tripInfor.command.removeAll()
        tripInfor.tracking.removeAll()
        
        checkDriverStatus(from: next).flatMap { [weak self] _ -> Observable<Driver> in
            guard let wSelf = self else { return Observable.empty() }
            return wSelf.findInformation(from: next)
            }.do(onNext: { [weak self] d in
                let model = d.deviceInfo?.model ?? ""
                let version = d.currentVersion ?? ""
                let suffix = (model.contains("iPhone") || model.contains("iPad") == true) ? "I" : "A"
                self?.tripInfor.info.driverVersion = String(format: "%@%@", version, suffix)
                self?.currentDriver = d
            }).flatMap({ [weak self] _ -> Observable<Void> in
                guard let wSelf = self else {
                    return Observable.empty()
                }
                return wSelf.checkDriverHasTrip(from: firebaseId)
            }).subscribe { [weak self](event) in
                guard let wSelf = self else {
                    return
                }
                
                switch event {
                case .next:
                    wSelf.prepareInformationSendToDriver()
                case .error(let e):
                    wSelf.checkErrorTrip(from: e)
                default:
                    break
                }
            }.disposeOnDeactivate(interactor: self)
    }
    
    func requestToDriver() {
        inBookTrip = false
        _eStatus.onNext(BookingRequestVC.Config.HeaderNote.begin)
        cleanUpListener()
        guard listDriver.count > 0 else {
            self._eError.onNext(BookingError.noDriverAccept)
            return
        }
        let next = listDriver.remove(at: 0)
        
        if let service = self.bookingRequestStream.currentModelBook.informationPrice?.service,
            service.isGroupService {
            requestDriverTaxi(userID: next.id).catchErrorJustReturn(()).bind { [weak self](_) in
                self?.updateTrip(from: next, taxi: true)
            }.disposeOnDeactivate(interactor: self)
        } else {
            self.updateTrip(from: next)
        }
        
    }
    
    func requestInformationDriver(from firebaseId: String?) -> Observable<FirebaseUser> {
        guard let firebaseId = firebaseId, !firebaseId.isEmpty else {
            return Observable.empty()
        }
        let firebaseDatabaseReference = dependency.firebaseDatabase
        let node = FireBaseTable.user >>> .custom(identify: firebaseId)
        return firebaseDatabaseReference.find(by: node, type: .value, using: {
            $0.keepSynced(true)
            return $0
        }).take(1).map {
            try FirebaseUser.create(from: $0)
        }
    }
    
}
