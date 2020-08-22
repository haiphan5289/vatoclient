//
//  SearchPlaceVM.swift
//  Vato
//
//  Created by vato. on 7/20/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import VatoNetwork

struct SearchPlaceVM {
//    private let model: PlaceModel?
    private var updatePlaceDisposable: Disposable?
    
    func findSuggestion(by keyword: String?) -> Observable<[MapModel.Place]> {
        guard let keyword = keyword?.trim(), keyword.count > 0 else {
            return self.loadFiveLatestHistory()
        }
        return self.findSuggestionGoogle(by: keyword)
    }
    
    
    private func findSuggestionGoogle(by keyword: String) -> Observable<[MapModel.Place]> {
        let currentLocation = VatoLocationManager.shared.location.orNil(.zero)
        
        return FirebaseTokenHelper.instance
            .eToken
            .filterNil()
            .take(1)
            .flatMap { MapAPI.findPlace(with: keyword, currentLocation: currentLocation.coordinate, authToken: $0) }
            .timeout(.seconds(30), scheduler: SerialDispatchQueueScheduler(qos: .background))
    }
    
    private func loadFiveLatestHistory() -> Observable<[MapModel.Place]> {
        let run = { () -> [AddressProtocol] in
            return PlacesHistoryManager.instance.latestFiveDestination()
        }
        
        let result = run()
            .map { MapModel.Place(name: $0.primaryText,
                                  address: $0.secondaryText,
                                  location: MapModel.Location(lat: $0.coordinate.latitude, lon: $0.coordinate.longitude),
                                  placeId: nil) }
        return Observable.just(result)
    }
    
    mutating func getDetailLocation(place: MapModel.Place, completion: HandlerLocationFavorite?) {
        if place.location != nil {
            completion?(place, nil)
        } else {
            guard let placeId = place.placeId else {
                let e = NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: [NSLocalizedDescriptionKey: "An error occurred during search address"])
                completion?(nil, e)
                return
            }
            
            self.updatePlaceDisposable?.dispose()
            self.updatePlaceDisposable = nil
            updatePlaceDisposable = FirebaseTokenHelper.instance
                .eToken
                .filterNil()
                .take(1)
                .flatMap { MapAPI.placeDetails(with: placeId, authToken: $0) }
                .timeout(.seconds(15), scheduler: SerialDispatchQueueScheduler(qos: .background))
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { (result) in
                    var newPlace = place
                    newPlace.location = result.location
                    if let address = result.fullAddress,
                        address.count > 0 {
                        newPlace.address = address
                    }
                    completion?(newPlace, nil)
                }, onError: { e in
                    completion?(nil, e)
                })
        }
    }
}
