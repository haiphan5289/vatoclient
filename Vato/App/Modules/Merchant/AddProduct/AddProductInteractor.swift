//  File name   : AddProductInteractor.swift
//
//  Author      : khoi tran
//  Created date: 11/7/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork
import Alamofire


protocol AddProductRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func routeToAddProductType(listPathCategory: [MerchantCategory]?)
    func openPhotoLibrary(type: UIImagePickerController.SourceType)
    
}

protocol AddProductPresentable: Presentable {
    var listener: AddProductPresentableListener? { get set }
    
    // todo: Declare methods the interactor can invoke the presenter to present data.
    
}

protocol AddProductListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func addProductMoveBack()
}

final class AddProductInteractor: PresentableInteractor<AddProductPresentable> {
    /// Class's public properties.
    weak var router: AddProductRouting?
    weak var listener: AddProductListener?
    
    struct Config {
        static let ErrorMessage = "Lỗi dữ liệu"
    }
    /// Class's constructor.
    init(presenter: AddProductPresentable, authStream: AuthenticatedStream, merchantStream: MerchantDataStream, currentProduct: DisplayProduct?) {
        self.authStream = authStream
        self.merchantStream = merchantStream
        self.currentProduct = currentProduct
        super.init(presenter: presenter)
        presenter.listener = self
    }
    
    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        
        // todo: Implement business logic here.
        self.getListProductAttribute()
    }
    
    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }
    
    /// Class's private properties.
    private var authStream: AuthenticatedStream?
    private var merchantStream: MerchantDataStream?
    
    private var currentProduct: DisplayProduct?
    
    private var currentSelectedCategory: MerchantCategory?
    private var subjectSelectedCategoryFlow: PublishSubject<(String, MerchantCategory)> = PublishSubject<(String, MerchantCategory)>()
    private lazy var trackProgress: ActivityProgressIndicator = ActivityProgressIndicator()
    private let errorSubject = ReplaySubject<MerchantState>.create(bufferSize: 1)
    private let subjectListProductAttribute: PublishSubject<[MerchantAttributeElement]> = PublishSubject()
    private let subjectProductData: PublishSubject<ProductModifyData> = PublishSubject()
    
    private var addImageType: AddImageType?
    private lazy var imageObject: PublishSubject<UploadedImage> = PublishSubject()
    private var listPathCategory: [MerchantCategory]?
    typealias MerchantCategoryResponse = VatoNetwork.Response<OptionalMessageDTO<[MerchantCategory]>>
    
}

// MARK: AddProductInteractable's members
extension AddProductInteractor: AddProductInteractable {
    func setCategory(text: String, category: MerchantCategory) {
        self.currentSelectedCategory = category
        
        subjectSelectedCategoryFlow.onNext((text, category))
    }
    
    func addProductTypeMoveBack() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
    func handler(image: UIImage) {
        
        guard let userId = UserManager.instance.userId else {
            fatalError("userid")
        }
        
        guard let type = self.addImageType else {
            fatalError("Need implement here")
        }
        var uploadedImage = UploadedImage()
        let fileName = String(format: "%.0f.jpeg", Date().timeIntervalSince1970 )
        let resizeImage = image.resize(targetSize: CGSize(width: 400, height: 400))
        
        switch type {
        case .avatar:
            uploadedImage.path = UploadImagePath.merchantAvatar(userId: userId).getPath()
            
        case .banner:
            uploadedImage.path = UploadImagePath.merchantBanner(userId: userId).getPath()
        }
        uploadedImage.fileName = fileName
        uploadedImage.saveImage(image: resizeImage)
        
        imageObject.onNext(uploadedImage)
    }
    
    func handler(error: AddStoreError) {
        //        errorObject.onNext(error)
    }
}

// MARK: AddProductPresentableListener's members
extension AddProductInteractor: AddProductPresentableListener {
    
    var productData: Observable<ProductModifyData> {
        return subjectProductData.asObservable()
    }
    
    var selectedImage: Observable<UploadedImage> {
        return imageObject.asObservable()
    }
    
    var listCategoryAttributes: Observable<[MerchantAttributeElement]> {
        return subjectListProductAttribute.asObservable()
    }
    
    var selectedCategoryFlow: Observable<(String, MerchantCategory)> {
        return subjectSelectedCategoryFlow.asObservable()
    }
    
    func routeToAddProductType() {
        self.router?.routeToAddProductType(listPathCategory: self.listPathCategory)
    }
    
    func addProductMoveBack() {
        self.listener?.addProductMoveBack()
    }
    
    var eLoadingObser: Observable<(Bool, Double)> {
        return trackProgress.asObservable().observeOn(MainScheduler.asyncInstance)
    }
    
    var errorObserable: Observable<MerchantState> {
        return errorSubject.asObserver()
    }
    
    typealias ProductDetailResponse = VatoNetwork.Response<OptionalMessageDTO<ProductModifyData>>
    func fetchProductData() {
        guard let productId = self.currentProduct?.productId else {
            return
        }
        
        self.request { (token) -> Observable<ProductDetailResponse> in
            return Requester.responseDTO(decodeTo: OptionalMessageDTO<ProductModifyData>.self,
                                         using: VatoFoodApi.productDetail(authToken: token, productId: productId, params: nil),
                                         progress: nil)
        }
        .trackProgressActivity(self.trackProgress)
        .subscribe(onNext: { [weak self] (r) in
            if r.response.fail == true {
                guard let message = r.response.message else { return }
                let errType = MerchantState.generalError(status: r.response.status,
                                                         message: message)
                self?.errorSubject.onNext(errType)
            } else {
                if let result = r.response.data {
                    printDebug(result)
                    self?.subjectProductData.onNext(result)
                }
            }
            }, onError: {[weak self] (e) in
                self?.errorSubject.onNext(.errorSystem(err: e))
        }).disposeOnDeactivate(interactor: self)
    }
    
    
    func getListProductAttribute() {
        if let authenStream = self.authStream {
            authenStream.firebaseAuthToken
                .take(1)
                .flatMap({
                    Requester.responseDTO(decodeTo: VatoNetwork.OptionalMessageDTO<MerchantResponsePaging<MerchantAttributeElement>>.self,
                                          using: VatoFoodApi.getProductAttributeTemplate(authToken: $0, eavEntitySetId: 1),
                                          method: .get)
                })
                .trackProgressActivity(self.trackProgress)
                .observeOn(MainScheduler.asyncInstance)
                .subscribe(onNext: { [weak self] (r) in
                    if r.response.fail == true {
                        guard let message = r.response.message else { return }
                        let errType = MerchantState.generalError(status: r.response.status,
                                                                 message: message)
                        self?.errorSubject.onNext(errType)
                    } else {
                        self?.subjectListProductAttribute.onNext(r.response.data?.content ?? [])
                        self?.fetchProductData()
                    }
                    }, onError: {[weak self] (e) in
                        printDebug(e.localizedDescription)
                        self?.errorSubject.onNext(.errorSystem(err: e))
                }).disposeOnDeactivate(interactor: self)
        }
    }
    
    func choosePhoto(type: UIImagePickerController.SourceType, imageType: AddImageType) {
        self.addImageType = imageType
        self.router?.openPhotoLibrary(type: type)
    }
    
    func uploadMerchantAttributes(code: String, listImage: [UploadedImage]) -> Observable<MerchantAttributeData> {
        return FileStorageUploadManager.instance.uploadMerchantAttributes(code: code, listImage: listImage).trackProgressActivity(self.trackProgress)
        
    }
    
    func createProduct(attributes: [MerchantAttributeData]) {
        var params:[String:Any] = [:]
        
        guard let storeId = self.merchantStream?.currentSelectedStore?.id else {
            return
        }
        
        let attributesJSON = attributes.map({ (m) -> [String:Any]? in
            do {
                let json = try m.toJSON()
                return json
            } catch {
                return nil
            }
        }).compactMap({ $0 })
        
        params["attributes"] = attributesJSON
        params["eavAttributeSetId"] = 1
        params["storeId"] = storeId
        params["type"] = ProductType.SIMPLE.rawValue
        
        let productId = self.currentProduct?.productId
        if let authenStream = self.authStream {
            authenStream.firebaseAuthToken
                .take(1)
                .flatMap({key -> Observable<(HTTPURLResponse, OptionalIgnoreMessageDTO<Int>)> in
                    if let productId = productId {
                        return Requester.requestDTO(using: VatoFoodApi.productDetail(authToken: key, productId: productId, params: params),
                                                           method: .put,
                                                           encoding: JSONEncoding.default)
                    } else {
                        return Requester.requestDTO(using: VatoFoodApi.createProduct(authToken: key, params: params),
                                                    method: .post,
                                                    encoding: JSONEncoding.default)
                    }
                })
                .trackProgressActivity(self.trackProgress)
                .observeOn(MainScheduler.asyncInstance)
                .subscribe(onNext: { [weak self] (r) in
                    if  r.1.fail == true {
                        printDebug(r)
                        let errType = MerchantState.generalError(status: r.1.status, message: r.1.message ?? Config.ErrorMessage)
                        self?.errorSubject.onNext(errType)
                    } else {
                        printDebug(r)
                        self?.addProductMoveBack()
                    }
                    }, onError: {[weak self] (e) in
                        printDebug(e.localizedDescription)
                        self?.errorSubject.onNext(.errorSystem(err: e))
                }).disposeOnDeactivate(interactor: self)
        }
    }
    
    func requestPathCategory(id: Int?) {
        guard let catId = id else { return }
        
        self.request { (token) -> Observable<MerchantCategoryResponse> in
            return Requester.responseDTO(decodeTo: OptionalMessageDTO<[MerchantCategory]>.self,
                                         using: VatoFoodApi.getMerchantPathCategory(authenToken: token, params: ["childId": catId]),
                                         progress: nil)
        }
        .trackProgressActivity(self.trackProgress)
        .subscribe(onNext: { [weak self] (r) in
            if r.response.fail == true {
                guard let message = r.response.message else { return }
                let errType = MerchantState.generalError(status: r.response.status,
                                                         message: message)
                self?.errorSubject.onNext(errType)
            } else {
                if let result = r.response.data {                    
                    self?.listPathCategory = result
                    printDebug(result)
                    if let category = result.first, category.id ?? 0 == catId, let ancestry = category.ancestry {
                        
                        let pickedAncestry = ancestry.split(";").count - 2
                        if pickedAncestry <= 0 {
                            self?.setCategory(text: category.name ?? "", category: category)
                        } else {
                            self?.setCategory(text: result.getAncestryName() , category: category)
                        }
                    } else {
                        let errType = MerchantState.generalError(status: r.response.status, message: Config.ErrorMessage)
                        self?.errorSubject.onNext(errType)
                    }
                    
                } else {
                    let errType = MerchantState.generalError(status: r.response.status, message: Config.ErrorMessage)
                    self?.errorSubject.onNext(errType)
                }
            }
            }, onError: {[weak self] (e) in
                self?.errorSubject.onNext(.errorSystem(err: e))
        }).disposeOnDeactivate(interactor: self)
        
    }
}

// MARK: Class's private methods
private extension AddProductInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
}


extension AddProductInteractor: RequestInteractorProtocol {
    var token: Observable<String> {
        return authStream?.firebaseAuthToken.take(1) ?? Observable.empty()
    }
}
