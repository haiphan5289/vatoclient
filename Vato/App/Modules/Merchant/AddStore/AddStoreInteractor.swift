//  File name   : AddStoreInteractor.swift
//
//  Author      : khoi tran
//  Created date: 10/21/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import FwiCore
import FwiCoreRX
import VatoNetwork
import Alamofire

protocol AddStoreRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func openPhotoLibrary(type: UIImagePickerController.SourceType)
    func routeToSearchAddress(model: AddressProtocol?) 
}

protocol AddStorePresentable: Presentable {
    var listener: AddStorePresentableListener? { get set }
    
    // todo: Declare methods the interactor can invoke the presenter to present data.
    func didSelectAddress(model: MapModel.Place)
}

protocol AddStoreListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func addStoreMoveBack()
    func reloadListStore()
}

enum AddStoreError {
    case photoPermission
    case cameraPermission
    case noPhoto
    case other(msg: String)
    
}

final class AddStoreInteractor: PresentableInteractor<AddStorePresentable>, ActivityTrackingProtocol {
    /// Class's public properties.
    weak var router: AddStoreRouting?
    weak var listener: AddStoreListener?
    
    /// Class's constructor.
    init(presenter: AddStorePresentable, authStream: AuthenticatedStream, merchantStream: MerchantDataStream) {
        super.init(presenter: presenter)
        self.authStream = authStream
        self.merchantStream = merchantStream
        presenter.listener = self
    }
    
    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        FireBaseTimeHelper.default.startUpdate()
        
        // todo: Implement business logic here.
        
        self.displayCurrentStore()
        self.getLeafCategory()
    }
    
    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
        FireBaseTimeHelper.default.stopUpdate()
    }
    
    /// Class's private properties.
    private lazy var imageObject: PublishSubject<UploadedImage> = PublishSubject()
    
    
    private lazy var storeObject: ReplaySubject<Store?> = ReplaySubject.create(bufferSize: 1)
    
    private lazy var listUploadedImage:[UploadedImage] = []
    
    private var merchantStream: MerchantDataStream?
    private var authStream: AuthenticatedStream?
    private let errorSubject = ReplaySubject<MerchantState>.create(bufferSize: 1)
    private lazy var trackProgress: ActivityProgressIndicator = ActivityProgressIndicator()
    
    private var subjectListLeafCategory = ReplaySubject<[MerchantCategory]>.create(bufferSize: 1)
    
    private var mListSelectedCategory: [MerchantCategory] = []
}

// MARK: AddStoreInteractable's members
extension AddStoreInteractor: AddStoreInteractable, Weakifiable {
    func handler(image: UIImage) {
        
        guard let currentMerchant = self.merchantStream?.currentSelectedMerchant, let merchantId = currentMerchant.basic?.id else {
            fatalError("Invalid merchant")
        }
        
        var uploadedImage = UploadedImage()
        let fileName = String(format: "%.0f.jpeg", Date().timeIntervalSince1970 )
        let resizeImage = image.resize(targetSize: CGSize(width: 343, height: 174))
        
        uploadedImage.path = UploadImagePath.storeBanner(merchantId: merchantId).getPath()
        uploadedImage.fileName = fileName
        uploadedImage.saveImage(image: resizeImage)
        
        imageObject.onNext(uploadedImage)
    }
    
    
    
    func handler(error: MerchantState) {
        errorSubject.onNext(error)
    }
    
    func dismiss() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
    func didSelectModel(model: MapModel.Place) {
        self.presenter.didSelectAddress(model: model)
        self.router?.dismissCurrentRoute(completion: nil)
    }
}

// MARK: AddStorePresentableListener's members
extension AddStoreInteractor: AddStorePresentableListener {
    
    var listLeafCategory: Observable<[MerchantCategory]> {
        return subjectListLeafCategory.asObservable()
    }
    
    var eLoadingObser: Observable<(Bool, Double)> {
        return trackProgress.asObservable().observeOn(MainScheduler.asyncInstance)
    }
    
    var errorObserable: Observable<MerchantState> {
        return errorSubject.asObservable()
    }
    
    var selectedImage: Observable<UploadedImage> {
        return imageObject.asObservable()
    }
    
    var currentStore: Observable<Store?> {
        return storeObject.asObservable()
    }
    
    func backToMerchantDetail() {
        self.listener?.addStoreMoveBack()
    }
    
    func choosePhoto(type: UIImagePickerController.SourceType) {
        self.router?.openPhotoLibrary(type: type)
    }
    
    func getCurrentSelectedStore()-> Store? {
        return merchantStream?.currentSelectedStore
    }
    
    func updateListSelectedCategory(listSelectedCategory:  [MerchantCategory]) {
        mListSelectedCategory = listSelectedCategory
    }
    
    var listSelectedCategory: [MerchantCategory] {
        return mListSelectedCategory
    }
    
    typealias ProductDetailResponse = VatoNetwork.Response<OptionalMessageDTO<[MerchantCategory]>>
    private func getLeafCategory() {
        guard let categoryId = self.merchantStream?.currentSelectedMerchant?.categoryId else { return }
        var params = [String: Any]()
        params["rootId"] = categoryId
        self.request { (token) -> Observable<ProductDetailResponse> in
            let router = VatoFoodApi.leafCategory(authToken: token, params: params)
            return Requester.responseDTO(decodeTo: OptionalMessageDTO<[MerchantCategory]>.self, using: router)
            }
            .trackProgressActivity(self.trackProgress)
            .subscribe(onNext: { [weak self] (r) in
                if r.response.fail == true {
                    guard let message = r.response.message else { return }
                    self?.errorSubject.onNext(.other(message: message))
                } else {
                    let result = r.response.data ?? []
                    self?.subjectListLeafCategory.onNext(result)
                    
                }
                }, onError: {[weak self] (e) in
                    self?.errorSubject.onNext(.other(message: e.localizedDescription))
            }).disposeOnDeactivate(interactor: self)
    }
    
    func updateStore(command: MerchantActionCommand, params: [String: Any], bannerImage: [URL:String]?, listOtherImage: [UploadedImage]?) {
        
        var newParams = params
        
        guard let listOtherImage = listOtherImage,
            let merchantId = self.merchantStream?.currentSelectedMerchant?.basic?.id,
            let categoryId = self.merchantStream?.currentSelectedMerchant?.categoryId else { return }
        
        
        
        FileStorageUploadManager.instance.uploadUploadImage(listImage: listOtherImage).trackProgressActivity(self.trackProgress)
            .subscribe { [weak self] (e) in
                switch e {
                case .next(let url):
                    newParams[Store.CodingKeys.bannerImage.rawValue] = url
                    self?.creareNewStore(command: command, merchantId: merchantId, params: newParams)
                    break
                case .error(let e):
                    printDebug(e.localizedDescription)
                case .completed:
                    printDebug("Completed!!!!!!")
                }
                
            }.disposeOnDeactivate(interactor: self)
    }
    
    func creareNewStore(command: MerchantActionCommand, merchantId: Int, params: [String: Any]?) {
        
        var method:Alamofire.HTTPMethod = .post
        switch command {
        case .create:
            method = .post
        case .update:
            method = .put
        }
        
        if let authenStream = self.authStream {
            authenStream.firebaseAuthToken
                .take(1)
                .flatMap({key -> Observable<(HTTPURLResponse, OptionalMessageDTO<Store>)> in
                    Requester.requestDTO(using: VatoFoodApi.createUpdateStore(authToken: key, merchantId: merchantId, param: params),
                                         method: method,
                                         encoding: JSONEncoding.default
                    )
                })
                .trackProgressActivity(self.trackProgress)
                .observeOn(MainScheduler.asyncInstance)
                .subscribe(onNext: { [weak self] (r) in
                    if  r.1.fail == true {
                        self?.errorSubject.onNext(.other(message: r.1.message ?? ""))
                    } else {
                        printDebug(r)
                        self?.listener?.reloadListStore()                        
                    }
                    }, onError: {[weak self] (e) in
                        self?.errorSubject.onNext(.errorSystem(err: e))
                }).disposeOnDeactivate(interactor: self)
        }
    }
    
    func routeToSearchAddress() {
        var address: AddressProtocol?
        if let location = UserManager.instance.currentLocation {
            address = Address(placeId: nil, coordinate: location, name: "", thoroughfare: "", locality: "", subLocality: "", administrativeArea: "", postalCode: "", country: "", lines: [], zoneId: 0, isOrigin: false, counter: 0, distance: nil, favoritePlaceID: 0)
            
        } else {
            address = MapInteractor.Config.defaultMarker.address
        }
        self.router?.routeToSearchAddress(model: address)
    }
    
}


// MARK: Class'ss private methods
private extension AddStoreInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
        self.trackProgress.asObservable().bind(onNext: { (isLoading, value) in
            //            printDebug("Track progress --- ", isLoading, value)
        }).disposeOnDeactivate(interactor: self)
    }
    
    func displayCurrentStore() {
        storeObject.onNext(merchantStream?.currentSelectedStore)
    }
}


extension AddStoreInteractor: RequestInteractorProtocol {
    var token: Observable<String> {
        return authStream?.firebaseAuthToken.take(1) ?? Observable.empty()
    }
}
