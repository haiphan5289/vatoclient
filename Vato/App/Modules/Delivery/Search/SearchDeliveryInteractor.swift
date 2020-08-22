//  File name   : SearchDeliveryInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 8/14/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import RIBs
import RxSwift
import VatoNetwork


enum SearchType {
    case express(origin: Bool, fillInfo: Bool)
    case booking(origin: Bool, placeHolder: String?, icon:UIImage?, fillInfo: Bool)
    case shopping(origin: Bool)
    case none
    
    func string() -> String {
        switch self {
        case .express(let origin, _):
            return origin ? Text.deliveryTitleAdressSender.localizedText : Text.deliveryTitleAdressReceiverPlaceHolder.localizedText
        case .shopping(let origin):
            return origin ? Text.shoppingOriginTitle.localizedText : Text.deliveryTitleAdressReceiverPlaceHolder.localizedText
        default:
            return ""
        }
    }
    
    func isOrigin() -> Bool {
        switch self {
        case .express(let origin, _):
            return origin
        case .booking(let origin, _, _, _):
            return origin
        case .shopping(let origin):
            return origin
        default:
            return true
        }
    }
    
    func placeHolder() -> String? {
        switch self {
            case .shopping(let origin):
                return origin ? Text.shoppingOriginPlaceHolder.localizedText : nil
            default:
                return nil
        }
    }
}

protocol SearchDeliveryRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func moveToPin(defautPlace: AddressProtocol?, isOrigin: Bool)
}

protocol SearchDeliveryPresentable: Presentable {
    // todo: Declare methods the interactor can invoke the presenter to present data.
    var listener: SearchDeliveryPresentableListener? { get set }
}

protocol SearchDeliveryListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func dismiss()
    func didSelectModel(model: MapModel.Place)
}

final class SearchDeliveryInteractor: PresentableInteractor<SearchDeliveryPresentable> {
    /// Class's public properties.
    weak var router: SearchDeliveryRouting?
    weak var listener: SearchDeliveryListener?
    
    /// Class's constructor.
    init(presenter: SearchDeliveryPresentable,
                  authStream: AuthenticatedStream,
                  placeModel: AddressProtocol?,
                  searchType: SearchType) {
        self.searchType = searchType
        super.init(presenter: presenter)
        self.presenter.listener = self
        self.authStream = authStream
        if let placeModel = placeModel {
            self.placeModel.onNext(placeModel)
        }
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
    
    /// Class's public properties.

    /// Class's private properties.
    private var authStream: AuthenticatedStream?
    private var searchDisposable: Disposable?
    private let listDataSubject = ReplaySubject<[MapModel.Place]>.create(bufferSize: 1)
    private let listDataFavoriteSubject = ReplaySubject<[PlaceModel]>.create(bufferSize: 1)
    private let placeModel = ReplaySubject<AddressProtocol>.create(bufferSize: 1)
    private let disposeBag = DisposeBag()
    internal let searchType: SearchType
    
    
}

// MARK: SearchDeliveryInteractable's members
extension SearchDeliveryInteractor: SearchDeliveryInteractable {
    func pinAddressDismiss() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
    func pinDidselect(model: MapModel.Place) {
        self.listener?.didSelectModel(model: model)
    }
}

// MARK: SearchDeliveryPresentableListener's members
extension SearchDeliveryInteractor: SearchDeliveryPresentableListener {
    
    
    func moveToPin() {
        let isOrigin = searchType.isOrigin()
        self.placeModel.take(1).timeout(0.3, scheduler: MainScheduler.instance).subscribe(onNext: {[weak self] (model) in
            self?.router?.moveToPin(defautPlace: model, isOrigin: isOrigin)
        }, onError: { [weak self]e in
            let `default` = MapInteractor.Config.defaultMarker
            self?.router?.moveToPin(defautPlace: `default`.address, isOrigin: isOrigin)
        }).disposed(by: disposeBag)
    }
    
    var placeModelObservable: Observable<AddressProtocol> {
        return self.placeModel.asObserver()
    }
    
    func didSelectModel(indexPath: IndexPath) {
        listDataSubject
            .take(1)
            .subscribe(onNext: {[weak self] (listData) in
            if indexPath.row < listData.count {
                let model = listData[indexPath.row]
                self?.checkReturnLocation(place: model)
            }
        }).disposed(by: disposeBag)
    }
    
    func didSelectFavoriteModel(model: PlaceModel) {
        
        let blockProcessSelectFavoriteModel:(PlaceModel) -> Void = {[weak self] model in
            guard let lat = model.lat, let lon = model.lon else { return }
            let location = MapModel.Location(lat: Double(lat) ?? 0, lon: Double(lon) ?? 0)
            let place = MapModel.Place(name: model.address ?? "", address: model.address, location: location, placeId: "\(model.id ?? 0)", isFavorite: true)
            self?.listener?.didSelectModel(model: place)
        }
        
        if model.typeId == .AddNew {
            let viewController = FavoritePlaceViewController()
            viewController.authenicate = self.authStream
            viewController.viewModel.isFromFavorite = true
            let navigation = FacecarNavigationViewController(rootViewController: viewController)
            self.router?.viewControllable.uiviewController.present(navigation, animated: true, completion: nil)
            viewController.didSelectModel = { model in
               blockProcessSelectFavoriteModel(model)
            }
            return
        }
        blockProcessSelectFavoriteModel(model)
    }
    
    func didSelectAddFavorite(item: MapModel.Place) {
        if let _ = item.location {
            let placeModel = PlaceModel(id: nil, name: nil, address: item.address, typeId: .Orther, lat: "\(item.location?.lat ?? 0)", lon: "\(item.location?.lon ?? 0)", lastUse: FireBaseTimeHelper.default.currentTime)
            self.moveToAddFavorite(with: placeModel)
        } else {
            guard let placeID = item.placeId else { return }
            self.getLocation(placeID: placeID, completion: { (placeDetail, e) in
                if let error = e {
                    var message = error.localizedDescription
                    if (error as NSError).code == NSURLErrorBadServerResponse {
                        message = Text.networkDownDescription.localizedText
                    }
                    AlertVC.showError(for: self.router?.viewControllable.uiviewController, message: message)
                } else if let placeDetail = placeDetail,
                    let location = placeDetail.location {
                    let placeModel = PlaceModel(id: nil, name: nil, address: placeDetail.fullAddress, typeId: .Orther, lat: "\(location.lat)", lon: "\(location.lon)", lastUse: FireBaseTimeHelper.default.currentTime)
                    self.moveToAddFavorite(with: placeModel)
                }
            })
        }
    }
    
    func moveToAddFavorite(with model: PlaceModel) {
        let viewController = UpdatePlaceViewController(mode: .quickCreate, viewModel: UpdatePlaceVM(model: model))
        let navigation = FacecarNavigationViewController(rootViewController: viewController)
        self.router?.viewControllable.uiviewController.present(navigation, animated: true, completion: nil)
    }
    
    func getLocation(placeID: String, completion: @escaping (_ location: MapModel.PlaceDetail?, _ error: Error?) -> Void) {
        if let authStream = self.authStream {
            authStream.firebaseAuthToken
                .flatMap { MapAPI.placeDetails(with: placeID, authToken: $0) }
                .timeout(15.0, scheduler: SerialDispatchQueueScheduler(qos: .background))
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { (result) in
                    completion(result, nil)
                }, onError: { (e) in
                    completion(nil, e)
                }).disposed(by: disposeBag)
        } else {
            let e = NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: [NSLocalizedDescriptionKey: "An error occurred during search address."])
            completion(nil, e)
        }
    }
    
    var listFavoriteObservable: Observable<[PlaceModel]> {
        return listDataFavoriteSubject.asObserver()
    }
    
    var listDataObservable: Observable<[MapModel.Place]> {
        return listDataSubject.asObservable()
    }
    
    func moveBack() {
        listener?.dismiss()
    }
    
    func searchLocation(keyword: String) {
        self.searchDisposable?.dispose()
        self.searchDisposable = nil
        
        let keywordTrim = keyword.trim()
        guard keywordTrim.count > 0 else {
            // load history
            self.loadFiveLatestHistory().subscribe(onNext: {[weak self] (listData) in
            self?.listDataSubject.onNext(listData)
            }).disposed(by: self.disposeBag)
            return
        }
        // search google
        
        self.placeModel.take(1)
            .timeout(0.3, scheduler: MainScheduler.instance)
            .subscribe(onNext: {[weak self] (model) in
                self?.requesAPI(model: model, keywordTrim: keywordTrim)
                }, onError: { [weak self] (_) in
                    let `default` = MapInteractor.Config.defaultMarker
                    self?.requesAPI(model: `default`.address, keywordTrim: keywordTrim)
            }).disposed(by: self.disposeBag)
    }
    
    private func requesAPI(model: AddressProtocol, keywordTrim: String)  {
        self.searchDisposable = self.authStream?.firebaseAuthToken
            .flatMap {
                MapAPI.findPlace(with: keywordTrim, currentLocation: model.coordinate, authToken: $0)
            }.timeout(30.0, scheduler: SerialDispatchQueueScheduler(qos: .background)).subscribe(onNext: {[weak self] (data) in
                self?.listDataSubject.onNext(data)
            })
    }
    
    func getListFavorite() {
        let origin = searchType.isOrigin()
        let event = PlacesHistoryManager.instance
            .favoritePlaces
            .map { $0.filter ({ $0.isOrigin == origin }).map(PlaceModel.init(address:)) }
        
        event.map { list -> [PlaceModel] in
            let modelAddNew = PlaceModel(id: nil, name: Text.favoritePlace.localizedText, address: nil, typeId: .AddNew, lat: nil, lon: nil, lastUse: FireBaseTimeHelper.default.currentTime)
            return [modelAddNew] + list
        }.bind(to: listDataFavoriteSubject).disposeOnDeactivate(interactor: self)
    }
}

// MARK: Class's private methods
private extension SearchDeliveryInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
    
    private func loadFiveLatestHistory() -> Observable<[MapModel.Place]> {
        let run = { () -> [AddressProtocol] in
            return PlacesHistoryManager.instance.latestFiveOrigin()
        }
        
        let result = run()
            .map { MapModel.Place(name: $0.primaryText,
                                  address: $0.secondaryText,
                                  location: MapModel.Location(lat: $0.coordinate.latitude, lon: $0.coordinate.longitude),
                                  placeId: nil) }
        
        return Observable.just(result)
    }
    
    func checkReturnLocation(place: MapModel.Place) {
        if let _ = place.location {
            self.listener?.didSelectModel(model: place)
        } else {
            guard let placeId = place.placeId else {
                return
            }
            
            if let authStream = self.authStream {
                LoadingManager.showProgress()
                authStream.firebaseAuthToken
                    .take(1)
                    .flatMap { MapAPI.placeDetails(with: placeId, authToken: $0) }
                    .timeout(30.0, scheduler: SerialDispatchQueueScheduler(qos: .background))
                    .observeOn(MainScheduler.instance)
                    .subscribe(onNext: { (result) in
                        var newPlace = place
                        newPlace.location = result.location
                        if let address = result.fullAddress,
                            address.count > 0 {
                            newPlace.address = address
                        }
                        self.listener?.didSelectModel(model: newPlace)
                    }, onError: { (e) in
                        var message = e.localizedDescription
                        if (e as NSError).code == NSURLErrorBadServerResponse {
                            message = Text.networkDownDescription.localizedText
                        }
                        AlertVC.showError(for: self.router?.viewControllable.uiviewController, message: message)
                    }) {
                        LoadingManager.dismissProgress()
                }.disposed(by: disposeBag)
            }
        }
    }
}
