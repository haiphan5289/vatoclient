//
//  FavoritePlaceManager.swift
//  Vato
//
//  Created by vato. on 7/19/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import RIBs
import Foundation
import RxSwift
import RxCocoa
import Firebase
import VatoNetwork

final class FavoritePlaceManager: Weakifiable {
    static let shared = FavoritePlaceManager()
    var result: Observable<[PlaceModel]> {
        return mResult.observeOn(MainScheduler.asyncInstance)
    }
    
    private lazy var mResult: BehaviorRelay<[PlaceModel]> = BehaviorRelay(value: [])
    var source: [PlaceModel] { return mResult.value }
    
    weak var listener: RequestInteractorProtocol?
    private var disposeRequest: Disposable?
    private var ready: Bool = false
    private lazy var disposeBag = DisposeBag()
    private init() { setupRX() }
    
    private func setupRX() {
        mResult.filter { [unowned self] _ in self.ready }.bind(onNext: weakify({ (list, wSelf) in
            PlacesHistoryManager.instance.addFavoritePlace(places: list)
        })).disposed(by: disposeBag)
    }
    
    func reload() {
        guard let listener = listener else {
            assert(false, "Check dependency !!!!")
            return
        }
        disposeRequest?.dispose()
        disposeRequest = listener
            .request(map: { Requester.responseDTO(decodeTo: OptionalMessageDTO<[PlaceModel]>.self, using: VatoAPIRouter.getFavPlaceList(authToken: $0, isDriver: false)) })
            .subscribe(weakify({ (event, wSelf) in
            switch event {
            case .error(let e):
                print(e.localizedDescription)
                wSelf.mResult.accept([])
            case .next(let res):
                wSelf.ready = true
                if let e = res.response.error {
                    print(e.localizedDescription)
                    wSelf.mResult.accept([])
                } else {
                    let list = res.response.data.orNil([])
                    wSelf.mResult.accept(list.sorted(by: >))
                }
            default: break
            }
        }))
    }
}
