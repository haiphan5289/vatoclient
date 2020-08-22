//  File name   : AddDestinationConfirmInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 3/20/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork
import Alamofire
import CoreLocation

protocol AddDestinationConfirmRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func routeToWaiting(request: InTripRequestChangeDestination, tripId: String)
    func routeToAlert(type: ChangeDestinationUpdateType) -> Observable<AddDestinationAlertType>
}

protocol AddDestinationConfirmPresentable: Presentable {
    var listener: AddDestinationConfirmPresentableListener? { get set }
    func resetUI()
    func showAlert(error message: String)
    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol AddDestinationConfirmListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func dismissAddDestination()
    func addDestinationSuccess(points: [DestinationPoint], newPrice: AddDestinationNewPrice)
}

struct DestinationPoint: Equatable {
    let type: AddDestinationType
    let address: AddressProtocol
    let showDots: Bool
    
    static func ==(lhs: DestinationPoint, rhs: DestinationPoint) -> Bool {
        return lhs.address.coordinate == rhs.address.coordinate
    }
}

struct InTripRequestChangeDestination: Codable {
    let expired_at: TimeInterval
    let id: Int
}

final class AddDestinationConfirmInteractor: PresentableInteractor<AddDestinationConfirmPresentable> {
    /// Class's public properties.
    weak var router: AddDestinationConfirmRouting?
    weak var listener: AddDestinationConfirmListener?
    let type: AddNewDestinationType
    let tripId: String
    /// Class's constructor.
    init(presenter: AddDestinationConfirmPresentable, type: AddNewDestinationType, tripId: String) {
        self.type = type
        self.tripId = tripId
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        requestTripDetail()
        // todo: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }
    
   
    /// Class's private properties.
    @Replay(queue: MainScheduler.asyncInstance) private var mPoints: [DestinationPoint]
    @Replay(queue: MainScheduler.asyncInstance) private var mDetails: [PriceInfoDisplayStyle]
    @Replay(queue: MainScheduler.asyncInstance) var info: AddDestinationTripInfo?
    @Replay(queue: MainScheduler.asyncInstance) private var newPrice: AddDestinationNewPrice?
    @Replay(queue: MainScheduler.asyncInstance) private var addDestinationSuccess: Bool?
    @Replay(queue: MainScheduler.asyncInstance) var currentRequest: InTripRequestChangeDestination

    private lazy var networkRequester = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
}

// MARK: AddDestinationConfirmInteractable's members
extension AddDestinationConfirmInteractor: AddDestinationConfirmInteractable {
    private func showAlert(type: ChangeDestinationUpdateType) {
        router?.routeToAlert(type: type).delay(.milliseconds(300), scheduler: MainScheduler.asyncInstance).bind(onNext: weakify({ (t, wSelf) in
            switch t {
            case .cancel:
                wSelf.listener?.dismissAddDestination()
            case .request:
                wSelf.presenter.resetUI()
                wSelf.refresh()
            }
        })).disposeOnDeactivate(interactor: self)
    }
    
    func changeDestinationHandlerUpdate(type: ChangeDestinationUpdateType) {
        switch type {
        case .reject, .timeout:
            router?.dismissCurrentRoute(completion: weakify({ (wSelf) in
                wSelf.showAlert(type: type)
            }))
            
        default:
            listener?.dismissAddDestination()
        }
    }
    
    var points: Observable<[DestinationPoint]> {
        return $mPoints
    }
    
    var details: Observable<[PriceInfoDisplayStyle]> {
        return $mDetails
    }
}

// MARK: AddDestinationConfirmPresentableListener's members
extension AddDestinationConfirmInteractor: AddDestinationConfirmPresentableListener {
    func updateRoute() {
        
    }
    
    func addDestinationMoveBack() {
        listener?.dismissAddDestination()
    }
}

// MARK: Request Trip Info
extension AddDestinationConfirmInteractor: Weakifiable, ActivityTrackingProgressProtocol {
    private func requestTripDetail() {
        let router = VatoAPIRouter.customPath(authToken: "", path: "trip/trip_detail", header: nil, params: ["id": tripId], useFullPath: false)
        networkRequester.request(using: router, decodeTo: OptionalMessageDTO<AddDestinationTripInfo>.self).bind(onNext: weakify({ (result, wSelf) in
            switch result {
            case .success(let r):
                wSelf.info = r.data
            case .failure(let e):
                print(e.localizedDescription)
            }
        })).disposeOnDeactivate(interactor: self)
    }
    
    private func generateParams(info: AddDestinationTripInfo, price: UInt64? = nil) -> JSON {
//        let c = info.trip?.startLocation
        var params = JSON()
        params["service_id"] = info.trip?.serviceId
        params["addition_price"] = info.trip?.additionPrice
        var departure = JSON()
        departure["address"] = info.trip?.startAddress
        departure["lat"] = info.trip?.startLat //c?.lat
        departure["lon"] = info.trip?.startLon //c?.lng
        departure["name"] = info.trip?.startName
        params["departure"] = departure
        var destination = JSON()
        destination["address"] = type.address.subLocality.orEmpty(type.address.name ?? "")
        destination["lat"] = type.address.coordinate.latitude
        destination["lon"] = type.address.coordinate.longitude
        destination["name"] = type.address.name?.orEmpty(type.address.subLocality) ?? type.address.subLocality
        params["destination"] = destination
        params["fare"] = price ?? info.trip?.fPrice
        params["trip_type"] = info.trip?.type
        var points: [TripWayPoint] = []
        switch type {
        case .edit:
            points = info.trip?.wayPoints?.suffix(1) ?? []
        case .new:
            points = info.trip?.wayPoints ?? []
        }
        if info.trip?.endLocation?.valid == true {
            let end = info.trip
            let new = TripWayPoint(lat: end?.endLat ?? 0, lon: end?.endLon ?? 0, address: info.trip?.endAddress ?? "")
            points.append(new)
        }
        
        do {
            let p = try points.map { try $0.toJSON() }
            params["way_points"] = p
        } catch {
            printDebug(error.localizedDescription)
        }
 
        return params
    }
        
    private func requestPrice() {
        let e = $info.filterNil().take(1).map { [unowned self] in
            self.generateParams(info: $0) }
            .flatMap { [weak self](p) -> Observable<Swift.Result<OptionalMessageDTO<AddDestinationNewPrice>, Error>> in
            guard let wSelf = self else { return Observable.empty() }
            let router = VatoAPIRouter.customPath(authToken: "", path: "products/routes/prices", header: ["token_type":"user"], params: p, useFullPath: false)
            return wSelf.networkRequester.request(using: router, decodeTo: OptionalMessageDTO<AddDestinationNewPrice>.self, method: .post, encoding: JSONEncoding.default)
        }
        
        e.bind(onNext: weakify({ (result, wSelf) in
            switch result {
            case .success(let s):
                if let data = s.data {
                    wSelf.newPrice = data
                    wSelf.updatePrice(price: data)
                } else {
                    guard let m = s.message else { return }
                    wSelf.presenter.showAlert(error: m)
                }
            case .failure(let e):
                wSelf.presenter.showAlert(error: e.localizedDescription)
            }
        })).disposeOnDeactivate(interactor: self)
    }
    
    private func generateUI() {
        $info.filterNil().take(1).bind(onNext: weakify({ (info, wSelf) in
            switch wSelf.type {
            case .new(let destination):
                var items = [DestinationPoint]()
                var current: Int = 0
                info.trip?.wayPoints?.enumerated().forEach({ (p) in
                    current += 1
                    var address = AddDestinationInfo()
                    address.name = p.element.address
                    address.subLocality = p.element.address
                    let t = DestinationPoint(type: .index(idx: current, last: false), address: address, showDots: true)
                    items.append(t)
                })
                
                if info.trip?.endLocation?.valid == true {
                    current += 1
                    var endAddress = AddDestinationInfo()
                    endAddress.name = info.trip?.endName ?? info.trip?.endAddress
                    endAddress.subLocality = info.trip?.endAddress ?? ""
                    let s1 = DestinationPoint(type: .index(idx: current, last: false), address: endAddress, showDots: true)
                    items.append(s1)
                }
                
                current += 1
                let d = DestinationPoint(type: .index(idx: current, last: true), address: destination, showDots: false)
                items.append(d)
                wSelf.mPoints = items
            default:
                fatalError("Please Implement")
            }
        })).disposeOnDeactivate(interactor: self)
    }
    
    private func updatePrice(price: AddDestinationNewPrice) {
        $info.filterNil().take(1).bind(onNext: weakify({ (info, wSelf) in
            guard let originPrice = info.trip?.fPrice else { return }
            
            let d1 = PriceInfoDisplayStyle(attributeTitle: Text.inTripAddDestinationOldPrice.localizedText.attribute >>> .font(f: .systemFont(ofSize: 15, weight: .regular)) >>> .color(c: Color.battleshipGrey), attributePrice: originPrice.currency.attribute >>> .font(f: .systemFont(ofSize: 15, weight: .regular)) >>> .color(c: #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)), showLine: false, edge: .zero)
            var n = price.final_fare + (info.trip?.additionPrice ?? 0)
            let p = (info.trip?.promotionValue ?? 0) + (info.trip?.fareClientSupport ?? 0)
            n = n > p ? n - p : 0
            
            let d2 = PriceInfoDisplayStyle(attributeTitle: Text.inTripAddDestinationNewPrice.localizedText.attribute >>> .font(f: .systemFont(ofSize: 15, weight: .regular)) >>> .color(c: #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)), attributePrice: n.currency.attribute >>> .font(f: .systemFont(ofSize: 18, weight: .medium)) >>> .color(c: #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)), showLine: false, edge: UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0))
            wSelf.mDetails = [d1, d2]
        })).disposeOnDeactivate(interactor: self)
    }
    
    func dismissAddDestination() {
        self.listener?.dismissAddDestination()
    }
    
    func submitAddDestination() {
        createOrdersChangeDestination()
    }
    
}

// MARK: Class's private methods
private extension AddDestinationConfirmInteractor {
    func refresh() {
        generateUI()
        requestPrice()
    }
    
    func handler(item: AddDestinationTripInfo) {
        refresh()
    }
    
    func createOrdersChangeDestination() {
        let e1 = $info.filterNil().take(1)
        let e2 = $newPrice.filterNil().take(1)
        
        let c = Observable.combineLatest(e1, e2) { [weak self](i, p) -> JSON? in
            guard let wSelf = self else { return nil }
            return wSelf.generateParams(info: i, price: UInt64(p.final_fare))
        }.filterNil()
        
        let e = c.flatMap { [weak self](p) -> Observable<Swift.Result<OptionalMessageDTO<InTripRequestChangeDestination>, Error>> in
            guard let wSelf = self else { return Observable.empty() }
                let router = VatoAPIRouter.customPath(authToken: "", path: "trip/\(wSelf.tripId)/destination-orders", header: nil, params: p, useFullPath: false)
            return wSelf.networkRequester.request(using: router, decodeTo: OptionalMessageDTO<InTripRequestChangeDestination>.self, method: .post, encoding: JSONEncoding.default)
        }.trackProgressActivity(indicator)
        
        e.bind(onNext: weakify({ (result, wSelf) in
            switch result {
            case .success(let r):
                if let d = r.data {
                    wSelf.currentRequest = d
                } else {
                    wSelf.presenter.showAlert(error: r.message ?? "")
                }
            case .failure(let e):
                wSelf.presenter.showAlert(error: e.localizedDescription)
            }
        })).disposeOnDeactivate(interactor: self)
    }
    
    
    private func setupRX() {
        // todo: Bind data stream here.
        $info.filterNil().bind(onNext: weakify({ (item, wSelf) in
            wSelf.handler(item: item)
        })).disposeOnDeactivate(interactor: self)
        
        $currentRequest.bind(onNext: weakify({ (r, wSelf) in
            wSelf.router?.routeToWaiting(request: r, tripId: wSelf.tripId)
        })).disposeOnDeactivate(interactor: self)
        
        
        let e1 = $mPoints
        let e2 = $newPrice.filterNil()
        let e3 = $addDestinationSuccess.filterNil().map{ $0 }
        
        Observable.combineLatest(e1, e2, e3)
            .observeOn(MainScheduler.asyncInstance)
            .bind {[weak self] (points, newPrice, isSuccess) in
            guard let wSelf = self else { return }            
            wSelf.listener?.addDestinationSuccess(points: points, newPrice: newPrice)
        }.disposeOnDeactivate(interactor: self)
        
    }
}
