//  File name   : SearchLocationRouter.swift
//
//  Author      : Vato
//  Created date: 9/12/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork

protocol SearchLocationInteractable: Interactable {
    var router: SearchLocationRouting? { get set }
    var listener: SearchLocationListener? { get set }

    var originAddress: Observable<String> { get }
    var destination1Address: Observable<String> { get }
    var addressSuggestions: Observable<[MapModel.Place]> { get }
    
    var favoritePlaces: Observable<[PlaceModel]> { get }

    func handleDismiss()
    func handlePickLocation()

    func change(mode: LocationType)
    func suggestPlaces(for keyword: String?)
    func updateLocation(place: MapModel.Place, completion: @escaping (_ mode: LocationType) -> Void)
    func updateLocation(primaryText: String, completion: @escaping (_ mode: LocationType) -> Void)
    func getLocation(placeID: String, completion: @escaping (_ location: MapModel.PlaceDetail) -> Void)
}

protocol SearchLocationViewControllable: ViewControllable {
    func bind(searchLocationView: SearchLocationView)

    func animateFullscreen(for searchLocationView: SearchLocationView, completion: @escaping (Bool) -> Void)
    func animateMinimize(for searchLocationView: SearchLocationView, completion: @escaping (Bool) -> Void)
}

final class SearchLocationRouter: Router<SearchLocationInteractable>, SearchLocationRouting, NetworkTrackingProtocol {
    init(interactor: SearchLocationInteractable, viewController: SearchLocationViewControllable, state: BookingState) {
        self.viewController = viewController
        self.state = state
        super.init(interactor: interactor)
        interactor.router = self
    }

    func cleanupViews() {
        UIApplication.setStatusBar(using: .default)

        searchLocationView?.removeFromSuperview()
        searchLocationView?.backButton.removeTarget(self, action: #selector(SearchLocationRouter.handleBackButtonOnPressed(_:)), for: .touchUpInside)
        searchLocationView?.mapButton.removeTarget(self, action: #selector(SearchLocationRouter.handleMapButtonOnPressed(_:)), for: .touchUpInside)

        searchLocationView?.originAddressTextField.delegate = nil
        searchLocationView?.destinationAddressTextField.delegate = nil
    }

    override func didLoad() {
        super.didLoad()
        UIApplication.setStatusBar(using: .default)

        // Load search location view
        guard let searchLocationView = Bundle.main.loadNibNamed("\(SearchLocationView.self)", owner: nil, options: nil)?.first as? SearchLocationView else {
            return
        }
        searchLocationView.backButton.addTarget(self, action: #selector(SearchLocationRouter.handleBackButtonOnPressed(_:)), for: .touchUpInside)
        searchLocationView.mapButton.addTarget(self, action: #selector(SearchLocationRouter.handleMapButtonOnPressed(_:)), for: .touchUpInside)
        searchLocationView.originAddressTextField.delegate = originAddressTextfieldProxy
        searchLocationView.destinationAddressTextField.delegate = destinationAddressTextfieldProxy
        switch self.state {
        case .searchLocation(let suggestMode), .editSearchLocation(let suggestMode):
            if suggestMode == .origin {
                searchLocationView.mapButton.setTitle(Text.confirmPickOriginLocation.localizedText, for: .normal)
            } else {
                searchLocationView.mapButton.setTitle(Text.confirmPickDestinationLocation.localizedText, for: .normal)
            }

        default:
            searchLocationView.mapButton.setTitle(Text.confirmPickOriginLocation.localizedText, for: .normal)
            break
        }

        viewController.bind(searchLocationView: searchLocationView)
        self.searchLocationView = searchLocationView

        // Register xibs
        let nib = UINib(nibName: "SearchLocationSuggestion", bundle: nil)
        searchLocationView.suggestionTableView.register(nib, forCellReuseIdentifier: SearchLocationSuggestionCVC.identifier)

        // Present UI
//        searchLocationView.mapImageView.alpha = 0.0
        searchLocationView.suggestionView.alpha = 0.0
        searchLocationView.mapButton.alpha = 0.0
        searchLocationView.suggestionTableView.alpha = 0.0

        let state = self.state
        viewController.animateFullscreen(for: searchLocationView) { [weak self] isFinished in
            UIView.animate(withDuration: 0.2, animations: {
//                searchLocationView.mapImageView.alpha = 1.0
                searchLocationView.suggestionView.alpha = 1.0
                searchLocationView.mapButton.alpha = 1.0
                searchLocationView.suggestionTableView.alpha = 1.0
            })

            switch state {
            case .searchLocation(let suggestMode), .editSearchLocation(let suggestMode):
                if suggestMode == .origin {
//                    self?.searchLocationView?.mapButton.setTitle(Text.confirmPickOriginLocation.localizedText, for: .normal)
                    self?.searchLocationView?.originAddressTextField.becomeFirstResponder()
                    self?.interactor.suggestPlaces(for: searchLocationView.originAddressTextField.text)
                } else {
//                    self?.searchLocationView?.mapButton.setTitle(Text.confirmPickDestinationLocation.localizedText, for: .normal)
                    self?.searchLocationView?.destinationAddressTextField.becomeFirstResponder()
                }
            case .editQuickBookingSearchLocation:
                self?.searchLocationView?.originAddressTextField.becomeFirstResponder()
                self?.interactor.suggestPlaces(for: searchLocationView.originAddressTextField.text)

            default:
                break
            }
        }
        
        // Register cell
        searchLocationView.suggestionCollectionView.register(HomeSuggestionCVC.self, forCellWithReuseIdentifier: HomeSuggestionCVC.identifier)

        setupRX()
    }

    @objc func handleBackButtonOnPressed(_ sender: Any) {
        guard let view = searchLocationView else {
            return
        }

        view.originAddressTextField.resignFirstResponder()
        view.destinationAddressTextField.resignFirstResponder()

        UIView.animate(withDuration: 0.2, animations: { [weak self] in
//            self?.searchLocationView?.mapImageView.alpha = 0.0
            self?.searchLocationView?.suggestionView.alpha = 0.0
            self?.searchLocationView?.mapButton.alpha = 0.0
            self?.searchLocationView?.suggestionTableView.alpha = 0.0
        }, completion: { [weak self] isFinished in
            self?.viewController.animateMinimize(for: view) { isFinished in
                self?.interactor.handleDismiss()
            }
        })
    }

    @objc func handleMapButtonOnPressed(_ sender: Any) {
        interactor.handlePickLocation()
    }

    /// Class's private properties
    private let viewController: SearchLocationViewControllable
    private let state: BookingState

    private let disposeBag = DisposeBag()

    private var searchLocationView: SearchLocationView?

    private lazy var originAddressTextfieldProxy = TextFieldProxy()
    private lazy var destinationAddressTextfieldProxy = TextFieldProxy()
    private lazy var suggestionVM = SearchLocationSuggestionVM(with: self.searchLocationView?.suggestionTableView)
    private lazy var favoritePlaceVM = HomeSuggestionVM(with: self.searchLocationView?.suggestionCollectionView)
}

// MARK: Class's private methods
private extension SearchLocationRouter {
    private func setupRX() {
        guard let i = interactor as? Interactor else {
            return
        }

        if let searchLocationView = searchLocationView {
            let o1 = interactor.originAddress
                .map { $0 == Text.unnamedRoad.localizedText ? "Vị Trí Đi" : $0 }
                .observeOn(MainScheduler.asyncInstance)

            o1.bind(to: searchLocationView.originAddressTextField.rx.text)
                .disposeOnDeactivate(interactor: i)

            switch state {
            case .searchLocation(_), .editSearchLocation:
                o1.map { $0.count > 0 }
                    .bind(to: searchLocationView.destinationAddressTextField.rx.isEnabled)
                    .disposeOnDeactivate(interactor: i)

            default:
                break
            }

            interactor.destination1Address
                .map { $0 == Text.unnamedRoad.localizedText ? "Vị Trí Đến" : $0 }
                .observeOn(MainScheduler.asyncInstance)
                .bind(to: searchLocationView.destinationAddressTextField.rx.text)
                .disposeOnDeactivate(interactor: i)

            interactor.addressSuggestions.observeOn(MainScheduler.asyncInstance)
                .subscribe(onNext: { [weak self] places in
                    self?.suggestionVM.update(newItems: places)
                })
                .disposeOnDeactivate(interactor: i)

            searchLocationView.originAddressTextField.rx.text
                .filter { [weak searchLocationView] _ in
                    searchLocationView?.originAddressTextField.isFirstResponder == true
                }
                .debounce(RxTimeInterval.seconds(1), scheduler: MainScheduler.asyncInstance)
                .subscribe(onNext: { [weak self] keyword in
                    self?.suggestPlaces(for: keyword)
                })
                .disposeOnDeactivate(interactor: i)

            searchLocationView.destinationAddressTextField.rx.text
                .filter { [weak searchLocationView] _ in
                    searchLocationView?.destinationAddressTextField.isFirstResponder == true
                }
                .debounce(RxTimeInterval.seconds(1), scheduler: MainScheduler.asyncInstance)
                .subscribe(onNext: { [weak self] keyword in
                    self?.suggestPlaces(for: keyword)
                })
                .disposeOnDeactivate(interactor: i)

            originAddressTextfieldProxy.returnPublisher
                .subscribe(onNext: { [weak self] _ in
                    self?.searchLocationView?.originAddressTextField.resignFirstResponder()
                })
                .disposeOnDeactivate(interactor: i)

            destinationAddressTextfieldProxy.returnPublisher
                .subscribe(onNext: { [weak self] _ in
                    self?.searchLocationView?.destinationAddressTextField.resignFirstResponder()
                })
                .disposeOnDeactivate(interactor: i)
        }

        originAddressTextfieldProxy.beginEditPublisher
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] _ in
//                self?.searchLocationView?.mapImageView.tintColor = Color.darkGreen
//                self?.searchLocationView?.mapButton.tintColor = Color.darkGreen
                self?.interactor.change(mode: .origin)
            })
            .disposeOnDeactivate(interactor: i)

        originAddressTextfieldProxy.endEditPublisher
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] _ in
                let text = self?.searchLocationView?.originAddressTextField.text ?? ""
                if text == "" {
                    self?.interactor.originAddress.subscribe(onNext: { originAddress in
                        self?.searchLocationView?.originAddressTextField.text = originAddress
                    })
                        .dispose()
                }
            })
            .disposeOnDeactivate(interactor: i)

        destinationAddressTextfieldProxy.beginEditPublisher
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] _ in
//                self?.searchLocationView?.mapImageView.tintColor = Color.orange
//                self?.searchLocationView?.mapButton.tintColor = Color.orange
                self?.interactor.change(mode: .destination1)
            })
            .disposeOnDeactivate(interactor: i)

        suggestionVM.currentItem
            .subscribe(onNext: { [weak self] item in
                if let _ = item.location {
                    self?.interactor.updateLocation(place: item, completion: { mode in
                        DispatchQueue.main.async {
                            switch mode {
                            case .destination1:
                                self?.searchLocationView?.destinationAddressTextField.resignFirstResponder()
                                
                            default:
                                self?.searchLocationView?.destinationAddressTextField.becomeFirstResponder()
                            }
                        }
                    })
                }
                else if item.placeId == "" {
                    self?.interactor.updateLocation(primaryText: item.primaryName ?? "", completion: { mode in
                        DispatchQueue.main.async {
                            switch mode {
                            case .destination1:
                                self?.searchLocationView?.destinationAddressTextField.resignFirstResponder()

                            default:
                                self?.searchLocationView?.destinationAddressTextField.becomeFirstResponder()
                            }
                        }
                    })
                } else {
                    self?.interactor.updateLocation(place: item, completion: { mode in
                        DispatchQueue.main.async {
                            switch mode {
                            case .destination1:
                                self?.searchLocationView?.destinationAddressTextField.resignFirstResponder()

                            default:
                                self?.searchLocationView?.destinationAddressTextField.becomeFirstResponder()
                            }
                        }
                    })
                }
            })
            .disposeOnDeactivate(interactor: i)
        
        //listen event move to booking view
        NotificationCenter.default.rx.notification(Notification.Name("moveToBookingView"))
            .bind { [weak self] notification in
                guard let item = notification.object as? PlaceModel, let lat = item.lat, let lon = item.lon else { return }
                
                let location = MapModel.Location(lat: Double(lat) ?? 0, lon: Double(lon) ?? 0)
                let place = MapModel.Place(name: item.address ?? "", address: item.address, location: location, placeId: "\(item.id ?? 0)", isFavorite: true)
                self?.interactor.updateLocation(place: place, completion: { (_) in })
            }
            .disposeOnDeactivate(interactor: i)
        
        //bind value for collectionview
        interactor.favoritePlaces.observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] places in
                self?.favoritePlaceVM.update(newItems: places)
            })
            .disposeOnDeactivate(interactor: i)
        
        favoritePlaceVM.currentItem
            .subscribe(onNext: { [weak self] item in
                if item.typeId == .AddNew {
                    let viewController = FavoritePlaceViewController()
                    viewController.viewModel.isFromFavorite = true
                    let navigation = FacecarNavigationViewController(rootViewController: viewController)
                    navigation.modalTransitionStyle = .coverVertical
                    navigation.modalPresentationStyle = .fullScreen

                    self?.viewController.uiviewController.present(navigation, animated: true, completion: nil)
                    viewController.didSelectModel = { model in
                        NotificationCenter.default.post(name: Notification.Name("moveToBookingView"), object: model)
                    }
                    return
                }
                
                guard let lat = item.lat, let lon = item.lon else {
                    return
                }
                
                let location = MapModel.Location(lat: Double(lat) ?? 0, lon: Double(lon) ?? 0)
                let place = MapModel.Place(name: item.address ?? "", address: item.address, location: location, placeId: "\(item.id ?? 0)", isFavorite: true)
                self?.interactor.updateLocation(place: place, completion: { (_) in })
            })
            .disposeOnDeactivate(interactor: i)

        suggestionVM.itemSubject.asObserver().subscribe(onNext: { [weak self] item in
            if let _ = item.location {
                let placeModel = PlaceModel(id: nil, name: nil, address: item.address, typeId: .Orther, lat: "\(item.location?.lat ?? 0)", lon: "\(item.location?.lon ?? 0)", lastUse: FireBaseTimeHelper.default.currentTime)
                let viewController = UpdatePlaceViewController(mode: .quickCreate, viewModel: UpdatePlaceVM(model: placeModel))
                let navigation = FacecarNavigationViewController(rootViewController: viewController)
                navigation.modalTransitionStyle = .coverVertical
                navigation.modalPresentationStyle = .fullScreen

                self?.viewController.uiviewController.present(navigation, animated: true, completion: nil)
            } else {
                guard let placeID = item.placeId else { return }
                self?.interactor.getLocation(placeID: placeID, completion: { (placeDetail) in
                    
                    guard let location = placeDetail.location else { return }
                    
                    let placeModel = PlaceModel(id: nil, name: nil, address: placeDetail.fullAddress, typeId: .Orther, lat: "\(location.lat)", lon: "\(location.lon)", lastUse: FireBaseTimeHelper.default.currentTime)
                    let viewController = UpdatePlaceViewController(mode: .quickCreate, viewModel: UpdatePlaceVM(model: placeModel))
                    let navigation = FacecarNavigationViewController(rootViewController: viewController)
                    self?.viewController.uiviewController.present(navigation, animated: true, completion: nil)
                })
            }
        }).disposeOnDeactivate(interactor: i)
        
        suggestionVM.setupRX()
        favoritePlaceVM.setupRX()
    }

    private func suggestPlaces(for keyword: String?) {
        suggestionVM.reset()

        networkTracking?
            .reachable
            .take(1)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] (isNetworkAvailable) in
                guard let wSelf = self else {
                    return
                }

                if isNetworkAvailable {
                    wSelf.interactor.suggestPlaces(for: keyword)
                } else {
                    AlertVC.presentNetworkDown(for: wSelf.viewController)
                }
            })
            .disposed(by: disposeBag)
    }
}

// MARK: UITextFieldDelegate's members
fileprivate class TextFieldProxy: NSObject, UITextFieldDelegate {
    fileprivate let beginEditPublisher = PublishSubject<Bool>()
    fileprivate let endEditPublisher = PublishSubject<Bool>()
    fileprivate let returnPublisher = PublishSubject<Bool>()

    fileprivate func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        beginEditPublisher.on(.next(true))
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        endEditPublisher.on(.next(true))
    }

    fileprivate func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        returnPublisher.on(.next(true))
        return true
    }
}
