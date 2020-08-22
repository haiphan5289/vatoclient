//  File name   : LocationPickerInteractor.swift
//
//  Author      : khoi tran
//  Created date: 11/13/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork

protocol LocationPickerRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func moveToPin(defautPlace: AddressProtocol?, isOrigin: Bool)
}

protocol LocationPickerPresentable: Presentable {
    var listener: LocationPickerPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
    func showError(msg: String)
}

protocol LocationPickerListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func pickerDismiss(currentAddress: AddressProtocol?)
    func didSelectModel(model: AddressProtocol)
}

final class LocationPickerInteractor: PresentableInteractor<LocationPickerPresentable>, ActivityTrackingProgressProtocol {
    struct Configs {
        static let hostMap: String = {
            #if DEBUG
                return "https://map-dev.vato.vn/api"
            #else
                return "https://map.vato.vn/api"
            #endif
        }()
    }
    
    /// Class's public properties.
    weak var router: LocationPickerRouting?
    weak var listener: LocationPickerListener?

    /// Class's constructor.
    init(presenter: LocationPickerPresentable,
         authStream: AuthenticatedStream,
         placeModel: AddressProtocol?,
         searchType: SearchType,
         typeLocationPicker: LocationPickerDisplayType) {
        
        self.searchType = searchType
        self.isOrigin = searchType.isOrigin()
        self.typeLocationPicker = typeLocationPicker

        super.init(presenter: presenter)
        self.presenter.listener = self
        self.authStream = authStream
        self.placeModel.onNext(placeModel ?? MapInteractor.Config.defaultMarker.address)
        self.currentAddress = placeModel
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
    private var searchDisposable: Disposable?
    private let listDataSubject = ReplaySubject<[AddressProtocol]>.create(bufferSize: 1)
    private let listDataFavoriteSubject = ReplaySubject<[PlaceModel]>.create(bufferSize: 1)
    private let placeModel = ReplaySubject<AddressProtocol>.create(bufferSize: 1)
    internal let typeLocationPicker: LocationPickerDisplayType
    internal let searchType: SearchType
    internal let isOrigin: Bool
    private var currentAddress: AddressProtocol?
    private lazy var session_id: String = "\(Date().timeIntervalSince1970)"
}

// MARK: LocationPickerInteractable's members
extension LocationPickerInteractor: LocationPickerInteractable {
    func pinAddressDismiss() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
    func pinDidselect(model: MapModel.Place) {
        
        let location = CLLocationCoordinate2D(latitude: model.location?.lat ?? 0, longitude: model.location?.lon ?? 0)
        
        let address = Address(
            placeId: nil,
            coordinate: location,
            name: model.primaryName ?? "",
            thoroughfare: "",
            locality: "",
            subLocality: model.address ?? "",
            administrativeArea: "",
            postalCode: "",
            country: "",
            lines: [],
            zoneId: 0,
            isOrigin: self.isOrigin,
            counter: 0,
            distance: model.distance,
            favoritePlaceID: 0)
        
        self.listener?.didSelectModel(model: address)
    }
}

// MARK: LocationPickerPresentableListener's members
extension LocationPickerInteractor: LocationPickerPresentableListener, Weakifiable {
    func moveToPin() {
        let isOrigin = searchType.isOrigin()
        self.placeModel.take(1).timeout(.milliseconds(300), scheduler: MainScheduler.instance).subscribe(onNext: {[weak self] (model) in
            self?.router?.moveToPin(defautPlace: model, isOrigin: isOrigin)
            }, onError: { [weak self]e in
                let `default` = MapInteractor.Config.defaultMarker
                self?.router?.moveToPin(defautPlace: `default`.address, isOrigin: isOrigin)
        }).disposeOnDeactivate(interactor: self)
    }
    
    var placeModelObservable: Observable<AddressProtocol> {
        return self.placeModel.asObserver()
    }
    
    func didSelectModel(indexPath: IndexPath) {
        listDataSubject
            .take(1)
            .flatMap({[weak self] (l) -> Observable<AddressProtocol> in
                guard let wSelf = self else { return Observable.empty() }
                return wSelf.checkReturnLocation(model: l[indexPath.row])
            })
            .trackProgressActivity(self.indicator)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {[weak self] (r) in
                let model = PlacesHistoryManager.instance.add(value: r, increase: false)
//                model.isOrigin = self?.searchType.isOrigin() ?? false
                self?.listener?.didSelectModel(model: model)
                
                }, onError: {[weak self] (e) in
                    let code = (e as NSError).code
                    if code == NSURLErrorNotConnectedToInternet || code == NSURLErrorBadServerResponse {
                        self?.presenter.showError(msg: Text.networkDownDescription.localizedText)
                    } else {
                        self?.presenter.showError(msg: Text.thereWasAnErrorFunction.localizedText)
                    }
            }).disposeOnDeactivate(interactor: self)
    }
    
    func didSelectFavoriteModel(model: PlaceModel) {
        
        let blockProcessSelectFavoriteModel:(PlaceModel) -> Void = {[weak self] model in
            guard var value = model.value else { return }
            value.isOrigin = self?.searchType.isOrigin() ?? false
            self?.listener?.didSelectModel(model: value)
        }
        
        if model.typeId == .AddNew {
            let viewController = FavoritePlaceViewController()
            viewController.authenicate = self.authStream
            viewController.viewModel.isFromFavorite = true
            let navigation = FacecarNavigationViewController(rootViewController: viewController)
            navigation.modalTransitionStyle = .coverVertical
            navigation.modalPresentationStyle = .fullScreen

            self.router?.viewControllable.uiviewController.present(navigation, animated: true, completion: nil)
            viewController.didSelectModel = { model in
                blockProcessSelectFavoriteModel(model)
            }
            return
        }
        blockProcessSelectFavoriteModel(model)
    }
    
    func didSelectAddFavorite(item: AddressProtocol) {
        self.checkReturnLocation(model: item)
            .trackProgressActivity(self.indicator)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {[weak self] (c) in
                let placeModel = PlaceModel(id: nil, name: nil, address: c.subLocality, typeId: .Orther, lat: "\(c.coordinate.latitude)", lon: "\(c.coordinate.longitude)", lastUse: FireBaseTimeHelper.default.currentTime)
                self?.moveToAddFavorite(with: placeModel)
            }, onError: { [weak self] (e) in
                let code = (e as NSError).code
                if code == NSURLErrorNotConnectedToInternet || code == NSURLErrorBadServerResponse {
                    self?.presenter.showError(msg: Text.networkDownDescription.localizedText)
                } else {
                    self?.presenter.showError(msg: Text.thereWasAnErrorFunction.localizedText)
                }
            }).disposeOnDeactivate(interactor: self)
    }
    
    func moveToAddFavorite(with model: PlaceModel) {
        let viewController = UpdatePlaceViewController(mode: .quickCreate, viewModel: UpdatePlaceVM(model: model))
        viewController.needReloadData = FavoritePlaceManager.shared.reload
        
        let navigation = FacecarNavigationViewController(rootViewController: viewController)
        navigation.modalTransitionStyle = .coverVertical
        navigation.modalPresentationStyle = .fullScreen

        self.router?.viewControllable.uiviewController.present(navigation, animated: true, completion: nil)
    }
    
    func checkReturnLocation(model: AddressProtocol) -> Observable<AddressProtocol> {
        guard model.isValidCoordinate() == false, let placeId = model.placeId else {
                return Observable.just(model)
        }
        
        return self.getLocation(model: model, placeId: placeId)
    }
    
    func getLocation(model: AddressProtocol, placeId: String) -> Observable<AddressProtocol> {
        var params = [String: Any]()
        params["placeid"] = placeId
        params["session_id"] = session_id
        let router = VatoAPIRouter.customPath(authToken: "", path: "\(Configs.hostMap)/placedetail", header: nil, params: params, useFullPath: true)
        
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        return network.request(using: router, decodeTo: OptionalMessageDTO<MapModel.PlaceDetail>.self).map { (result) -> AddressProtocol in
            switch result {
            case .failure(let e):
                throw e
            case .success(let res):
                if res.error != nil {
                    throw NSError(use: res.message)
                } else {
                    guard let c = res.data else {
                        throw NSError(use: "Unknown!!")
                    }
                    let coor = CLLocationCoordinate2D(latitude: c.location?.lat ?? 0, longitude: c.location?.lon ?? 0)
                    var t = model
                    t.update(name: c.name)
                    t.update(coordinate: coor)
                    t.update(subLocality: c.fullAddress)
                    t.update(placeId: c.placeId)
                    return t
                }
            }
        }
    }
    
    var listFavoriteObservable: Observable<[PlaceModel]> {
        return listDataFavoriteSubject.asObserver()
    }
    
    var listDataObservable: Observable<[AddressProtocol]> {
        return listDataSubject.asObservable()
    }
    
    func moveBack() {
        listener?.pickerDismiss(currentAddress: currentAddress)
    }
    
    func searchLocation(keyword: String) {
        self.searchDisposable?.dispose()
        self.searchDisposable = nil
        
        let keywordTrim = keyword.trim()
        guard keywordTrim.count > 0 else {
            // load history
            self.getLatestLocations()
//                .map { $0.filter { !($0.isFavoritePlace && $0.active) } }
                .subscribe(onNext: { [weak self] (listData) in
                self?.listDataSubject.onNext(listData)
            }).disposeOnDeactivate(interactor: self)
            return
        }
        // search google
    
        self.searchDisposable = self.placeModel.take(1).timeout(.microseconds(300), scheduler: MainScheduler.instance).catchErrorJustReturn(MapInteractor.Config.defaultMarker.address).subscribe(onNext: {[weak self] (model) in
            self?.searchAddressBy(model: model, keywordTrim: keywordTrim)
        })
    }
    
    func searchAddressBy(model: AddressProtocol, keywordTrim: String) {
        var params = [String: Any]()
        params["query"] = keywordTrim
        params["lat"] = model.coordinate.latitude
        params["lon"] = model.coordinate.longitude
        params["session_id"] = session_id
        let router = VatoAPIRouter.customPath(authToken: "", path: "\(Configs.hostMap)/placesearch", header: nil, params: params, useFullPath: true)
        
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        self.searchDisposable = network
            .request(using: router, decodeTo: OptionalMessageDTO<[MapModel.Place]>.self)
            .bind(onNext: weakify({ (result, wSelf) in
                switch result {
                case .success(let res):
                    guard let data = res.data else {
                        return
                    }
                    let markers = data.map({ (m) -> AddressProtocol in
                            var model = MarkerHistory.init(with: m).address
                            model.update(placeId: m.placeId)
                            model.distance = m.distance
                            model.isOrigin = wSelf.searchType.isOrigin()
                            return model
                        }).sorted(by: { (a1, a2) -> Bool in
                            return a1.distance ?? Double.greatestFiniteMagnitude < a2.distance ?? Double.greatestFiniteMagnitude
                        })
                    
                    wSelf.listDataSubject.onNext(markers)
                case .failure(let e):
                    #if DEBUG
                    print(e.localizedDescription)
                    #endif
                }
            }))
    }
    
    func getListFavorite() {
        let origin = searchType.isOrigin()
        PlacesHistoryManager.instance.favoritePlaces.map { $0.filter ({ $0.isOrigin == origin }).map(PlaceModel.init(address:)) }.map { list -> [PlaceModel] in
            let modelAddNew = PlaceModel(id: nil, name: Text.favoritePlace.localizedText, address: nil, typeId: .AddNew, lat: nil, lon: nil, lastUse: FireBaseTimeHelper.default.currentTime)
            return [modelAddNew] + list
        }.bind(to: listDataFavoriteSubject).disposeOnDeactivate(interactor: self)
    }
    
    var eLoadingObser: Observable<(Bool,Double)> {
        return self.indicator.asObservable()
    }
}

// MARK: Class's private methods
private extension LocationPickerInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
    
    private func loadFiveLatestHistory() -> Observable<[AddressProtocol]> {
        let run = { () -> [AddressProtocol] in
            return PlacesHistoryManager.instance.latestFiveDestination()
        }
        
        let result = run()
        
        return Observable.just(result)
    }
    
    private func getLatestLocations() -> Observable<[AddressProtocol]> {
        let latestLocation = PlacesHistoryManager.instance.searchLatest(isOrigin: searchType.isOrigin())
        let listMostUsedLocation = PlacesHistoryManager.instance.searchCounter(isOrigin: searchType.isOrigin())
        
        func refilterDistance(list: [AddressProtocol], maxItem: Int) -> [AddressProtocol] {
            var result = [AddressProtocol]()
            var idx: Int = 0
            while result.count < maxItem && idx < list.count {
                defer {
                    idx += 1
                }
                
                guard let item = list[safe: idx] else { continue }
                guard let idx = result.firstIndex (where: { (i) -> Bool in
                    let delta = abs(item.coordinate.distance(to: i.coordinate))
                    return delta <= 30
                }) else {
                    result.append(item)
                    continue
                }
                let old = result[idx]
                guard old.counter < item.counter else {
                    continue
                }
                
                result.remove(at: idx)
                result.append(item)
            }
            
            return result
        }
        
        return Observable.zip(latestLocation, listMostUsedLocation).map { (latestLocation, listMostUsedLocation) -> [AddressProtocol] in
            guard let latestLocation = latestLocation else {
                return refilterDistance(list: listMostUsedLocation, maxItem: Int.max)
            }
            
            let tempArray = [latestLocation] +  listMostUsedLocation.filter({ $0.coordinate != latestLocation.coordinate })
            return refilterDistance(list: tempArray.filter({$0.counter > 0 }), maxItem: Int.max)
        }
    }
}
