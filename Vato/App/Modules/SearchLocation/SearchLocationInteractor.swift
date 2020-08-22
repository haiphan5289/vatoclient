//  File name   : SearchLocationInteractor.swift
//
//  Author      : Vato
//  Created date: 9/12/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Alamofire
import CoreLocation
import RealmSwift
import RIBs
import RxSwift
import VatoNetwork

protocol SearchLocationRouting: Routing {
    func cleanupViews()
}

protocol SearchLocationListener: class {
    func beginConfirmBooking()
}

final class SearchLocationInteractor: Interactor {
    weak var router: SearchLocationRouting?
    weak var listener: SearchLocationListener?

    /// Class's constructor.
    init(bookingStream: MutableBookingStream,
         authStream: AuthenticatedStream,
         currentLocation: CLLocationCoordinate2D,
         googleAPIKey: String,
         state: BookingState) {
        self.mutableBooking = bookingStream
        self.authStream = authStream
        self.state = state
        self.currentLocation = currentLocation
        self.googleAPIKey = googleAPIKey
        super.init()
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
    }

    override func willResignActive() {
        super.willResignActive()
        router?.cleanupViews()
    }

    /// Class's private properties.
    private let state: BookingState
    private var mode = LocationType.origin
    private let mutableBooking: MutableBookingStream
    private let authStream: AuthenticatedStream

    private let googleAPIKey: String
    private let currentLocation: CLLocationCoordinate2D

    private let originAddressSubject = ReplaySubject<String>.create(bufferSize: 1)
    private let destination1AddressSubject = ReplaySubject<String>.create(bufferSize: 1)
    private let addressSuggestionsSubject = ReplaySubject<[MapModel.Place]>.create(bufferSize: 1)

    private var autoCompletePlaceDisposable: Disposable?
    private var updatePlaceDisposable: Disposable?
    private lazy var disposeBag = DisposeBag()
    
    private let favoritePlacesSubject = ReplaySubject<[PlaceModel]>.create(bufferSize: 1)
}

// MARK: SearchLocationInteractable's members
extension SearchLocationInteractor: SearchLocationInteractable {
    var originAddress: Observable<String> {
        return originAddressSubject.asObservable()
    }

    var destination1Address: Observable<String> {
        return destination1AddressSubject.asObservable()
    }

    var addressSuggestions: Observable<[MapModel.Place]> {
        return addressSuggestionsSubject.asObservable()
    }
    
    var favoritePlaces: Observable<[PlaceModel]> {
        return favoritePlacesSubject.asObservable()
    }

    func handleDismiss() {
        switch state {
        case .searchLocation:
            mutableBooking.changeMode(mode: .home)

        case .editQuickBookingSearchLocation:
            mutableBooking.changeMode(mode: .quickBookingConfirm)

        case .editSearchLocation:
            listener?.beginConfirmBooking()

        default:
            break
        }
    }

    func handlePickLocation() {
        switch state {
        case .searchLocation:
            mutableBooking.changeMode(mode: .pickLocation(suggestMode: mode))

        case .editSearchLocation:
            mutableBooking.changeMode(mode: .editPickLocation(suggestMode: mode))

        case .editQuickBookingSearchLocation:
            mutableBooking.changeMode(mode: .editQuickBookingPickLocation)

        default:
            break
        }
    }

    func change(mode: LocationType) {
        self.mode = mode
    }
    
    private func loadFiveLatestHistory() -> Observable<[MapModel.Place]> {
        let instance = PlacesHistoryManager.instance
        let run = { () -> [AddressProtocol] in
            return self.mode != .origin ? instance.latestFiveDestination() : instance.latestFiveOrigin()
        }
        
        let result = run()
            .map { MapModel.Place(name: $0.primaryText,
                                  address: $0.secondaryText,
                                  location: MapModel.Location(lat: $0.coordinate.latitude, lon: $0.coordinate.longitude),
                                  placeId: nil) }
        return Observable.just(result)
    }
    
    private func findSuggestionDatabaseHistory(by keyword: String) -> Observable<[MapModel.Place]> {
        let instance = PlacesHistoryManager.instance
        let suggestions = instance.searchMarker(with: keyword, isOrigin: (mode == .origin))
            .map { MapModel.Place(name: $0.primaryText,
                                  address: $0.secondaryText,
                                  location: MapModel.Location(lat: $0.coordinate.latitude, lon: $0.coordinate.longitude),
                                  placeId: nil) }
        
        return Observable.just(suggestions)
    }
    
    private func findSuggestionGoogle(by keyword: String) -> Observable<[MapModel.Place]> {
        
        return self.authStream.firebaseAuthToken
            .flatMap { MapAPI.findPlace(with: keyword, currentLocation: self.currentLocation, authToken: $0) }
            .timeout(30.0, scheduler: SerialDispatchQueueScheduler(qos: .background))
        
        /*
        return GoogleAPI.placeAutoComplete(with: keyword, currentLocation: currentLocation, googleAPIKey: googleAPIKey)
            .timeout(30.0, scheduler: SerialDispatchQueueScheduler(qos: .background)).map {
                let suggestions = $0.compactMap { (prediction) -> SuggestionLocation in
                    let placeID = prediction.placeId
                    let primaryText = prediction.structuredFormatting.mainText
                    let secondaryText = prediction.structuredFormatting.secondaryText
                    return SuggestionLocation(placeID: placeID, primaryText: primaryText, secondaryText: secondaryText)
                }
                return suggestions
        }.catchErrorJustReturn([]) */
    }
    
    private func findSuggestion(by keyword: String) -> Observable<[MapModel.Place]> {
        let s1 = self.findSuggestionDatabaseHistory(by: keyword)
        let s2 = self.findSuggestionGoogle(by: keyword)
        return Observable.zip(s1, s2) { (v1, v2) -> [MapModel.Place] in
            // Remove duplicate
            let r = v1 + v2
            return r.map { $0 }
        }
    }
    
    func suggestPlaces(for keyword: String?) {
        autoCompletePlaceDisposable?.dispose()
        autoCompletePlaceDisposable = nil
        let find: Observable<[MapModel.Place]> = { [unowned self] in
            guard let keyword = keyword?.trim(), keyword.count > 0 else {
                return self.loadFiveLatestHistory()
            }
            
            return self.findSuggestion(by: keyword)
        }()
        autoCompletePlaceDisposable = find.subscribe(onNext: { [weak self] final in
            self?.addressSuggestionsSubject.on(.next(final))
        })
    }

    func updateLocation(place: MapModel.Place, completion: @escaping (LocationType) -> Void) {
        if let _ = place.location {
            self.recordNewPlace(place: MapModel.PlaceDetail(name: place.primaryName ?? "", address: place.address, location: place.location, placeId: place.placeId, isFavorite: place.isFavorite ?? false))
        }
        else {
            guard let placeId = place.placeId else {
                return
            }
            
            updatePlaceDisposable?.dispose()
            updatePlaceDisposable = nil
            
            let mode = self.mode
            updatePlaceDisposable = self.authStream.firebaseAuthToken
                .flatMap { MapAPI.placeDetails(with: placeId, authToken: $0) }
                .timeout(30.0, scheduler: SerialDispatchQueueScheduler(qos: .background))
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [weak self] (result) in
                    guard let _ = result.location else {
                        return
                    }
                    
                    guard let _ = result.name else {
                        return
                    }
                    
                    // Record new marker
                    self?.recordNewPlace(place: result)
                    completion(mode)
                })
        }
    }

    func updateLocation(primaryText: String, completion: @escaping (LocationType) -> Void) {
        let instance = PlacesHistoryManager.instance
        guard let markerHistory = instance.search(name: primaryText) else {
            return
        }
        updateBooking(address: markerHistory)
        completion(mode)

//        if !markerHistory.isVerifiedV2 {
//            let address = markerHistory.address
//
//            authStream.firebaseAuthToken
//                .flatMap { MapAPI.geocoding(authToken: $0, lat: address.coordinate.latitude, lng: address.coordinate.longitude) }
//                .timeout(30.0, scheduler: SerialDispatchQueueScheduler(qos: .background))
//                .subscribe(onNext: { (result) in
//                    if let markerHistory = MarkerHistory.search(name: primaryText) {
//                        let r = markerHistory.realm
//                        try? r?.write {
//                            markerHistory.update(place: result)
//                            markerHistory.isVerifiedV2 = true
//                            
//                            if let name = markerHistory.name {
//                                r?.objects(MarkerHistory.self).filter({ $0.markerID != markerHistory.markerID && ($0.name == name) })
//                                    .forEach({ (marker) in
//                                        markerHistory.counter += marker.counter
//                                        r?.delete(marker)
//                                    })
//                            }
//                        }
//                    }
//                }).disposed(by: disposeBag)
//            
//            /*_ = GoogleAPI.reverseGeocode(with: address.coordinate, googleAPIKey: googleAPIKey)
//                .timeout(30.0, scheduler: SerialDispatchQueueScheduler(qos: .background))
//                .filterNil()
//                .subscribe(onNext: { (result) in
//                    if let markerHistory = MarkerHistory.search(name: primaryText) {
//                        let r = markerHistory.realm
//                        try? r?.write {
//                            markerHistory.update(address: result)
//                            markerHistory.isVerifiedV2 = true
//
//                            if let name = markerHistory.name {
//                            r?.objects(MarkerHistory.self).filter({ $0.markerID != markerHistory.markerID && ($0.name == name) })
//                                .forEach({ (marker) in
//                                    markerHistory.counter += marker.counter
//                                    r?.delete(marker)
//                                })
//                            }
//                        }
//                    }
//                })*/
//        }
    }
    
    func getLocation(placeID: String, completion: @escaping (_ location: MapModel.PlaceDetail) -> Void) {
        updatePlaceDisposable = self.authStream.firebaseAuthToken
            .flatMap { MapAPI.placeDetails(with: placeID, authToken: $0) }
            .timeout(30.0, scheduler: SerialDispatchQueueScheduler(qos: .background))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (result) in
                
                completion(result)
            })
    }
    
    func recordNewPlace(place: MapModel.PlaceDetail) {
        // Record new marker
        let instance = PlacesHistoryManager.instance
        if let markerHistory = instance.search(name: place.name ?? "", location: place.location) {
//            let r = markerHistory.realm
//            try? r?.write {
//                markerHistory.update(place: place)
//            }
            
            self.updateBooking(address: markerHistory)
        } else {
            let markerHistory = MarkerHistory(with: place)
            let new = instance.add(value: markerHistory.address)
            self.updateBooking(address: new)
        }
    }
    
    func requestFavoritePlace() {
        let event = PlacesHistoryManager.instance
            .favoritePlaces
            .map { $0.map(PlaceModel.init(address:)) }
        
        event.map { list -> [PlaceModel] in
            let modelAddNew = PlaceModel(id: nil, name: Text.favoriteSaved.localizedText, address: nil, typeId: .AddNew, lat: nil, lon: nil, lastUse: FireBaseTimeHelper.default.currentTime)
            return list + [modelAddNew]
        }.bind(to: favoritePlacesSubject).disposeOnDeactivate(interactor: self)
    }
}

// MARK: Class's private methods
private extension SearchLocationInteractor {
    private func setupRX() {
        mutableBooking.booking
            .map { $0.originAddress }
            .map { $0.primaryText }
            .bind(to: originAddressSubject)
            .disposeOnDeactivate(interactor: self)

        mutableBooking.booking
            .map { $0.destinationAddress1 }
            .filterNil()
            .map { $0.primaryText }
            .bind(to: destination1AddressSubject)
            .disposeOnDeactivate(interactor: self)
        
        
        //insert first item in favorite places
        let favoritePlaces = [PlaceModel(id: nil, name: Text.favoriteSaved.localizedText, address: nil, typeId: .AddNew, lat: nil, lon: nil, lastUse: FireBaseTimeHelper.default.currentTime)]
        favoritePlacesSubject.on(.next(favoritePlaces))
        
        requestFavoritePlace()
    }
    
    private func resetDispose() {
        autoCompletePlaceDisposable?.dispose()
        updatePlaceDisposable?.dispose()
        autoCompletePlaceDisposable = nil
        updatePlaceDisposable = nil
    }

    private func updateBooking(address: AddressProtocol) {
        switch mode {
        case .destination1:
            self.mutableBooking.updateBooking(destinationAddress1: address)
            resetDispose()
            listener?.beginConfirmBooking()

        default:
            self.mutableBooking.updateBooking(originAddress: address)
            switch state {
            case .searchLocation(_):
                mutableBooking.booking.map { $0.destinationAddress1 }.subscribe(onNext: { [weak self] (destination1Address) in
                    if destination1Address != nil {
                        self?.listener?.beginConfirmBooking()
                    }
                })
                .dispose()

            case .editSearchLocation:
                resetDispose()
                listener?.beginConfirmBooking()

            case .editQuickBookingSearchLocation:
                mutableBooking.changeMode(mode: .quickBookingConfirm)

            default:
                break
            }
        }
    }
}
