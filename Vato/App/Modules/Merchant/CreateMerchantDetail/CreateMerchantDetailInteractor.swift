//  File name   : CreateMerchantDetailInteractor.swift
//
//  Author      : khoi tran
//  Created date: 10/19/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork
import FwiCore
import FwiCoreRX
import Alamofire

protocol CreateMerchantDetailRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func openPhotoLibrary(type: UIImagePickerController.SourceType)
    
}

protocol CreateMerchantDetailPresentable: Presentable {
    var listener: CreateMerchantDetailPresentableListener? { get set }
    
    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol CreateMerchantDetailListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func createMerchantDetailMoveBack()
    func reloadListMerchant()
}

final class CreateMerchantDetailInteractor: PresentableInteractor<CreateMerchantDetailPresentable>, ActivityTrackingProtocol {
    /// Class's public properties.
    weak var router: CreateMerchantDetailRouting?
    weak var listener: CreateMerchantDetailListener?
    
    struct Config {
        static let ErrorMessage = "Lỗi dữ liệu"
    }
    /// Class's constructor.
    init(presenter: CreateMerchantDetailPresentable, merchantStream: MerchantDataStream?, authStream: AuthenticatedStream?, category: MerchantCategory?) {
        
        super.init(presenter: presenter)
        self.merchantStream = merchantStream
        self.authStream = authStream
        self.category = category
        presenter.listener = self
    }
    
    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        FireBaseTimeHelper.default.startUpdate()
        
        // todo: Implement business logic here.
        self.getListMerchantType()
    }
    
    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
        FireBaseTimeHelper.default.stopUpdate()
    }
    
    /// Class's private properties.
    
    
    private var merchantStream: MerchantDataStream?
    private var authStream: AuthenticatedStream?
    private var category: MerchantCategory?
    
    private let errorSubject = ReplaySubject<MerchantState>.create(bufferSize: 1)
    
    private let subjectListMerchantAttribute: PublishSubject<[MerchantAttribute]> = PublishSubject()
    private let subjectListMerchantAttributesData: PublishSubject<[MerchantAttributeData]> = PublishSubject()
    
    private lazy var imageObject: PublishSubject<UploadedImage> = PublishSubject()
    private lazy var trackProgress: ActivityProgressIndicator = ActivityProgressIndicator()

    private var addImageType: AddImageType?
    private let mListMerchantType = ReplaySubject<[MerchantType]>.create(bufferSize: 1)
    
    

    
}

// MARK: CreateMerchantDetailInteractable's members
extension CreateMerchantDetailInteractor: CreateMerchantDetailInteractable {
    var listMerchantAttributes: Observable<[MerchantAttribute]> {
        return subjectListMerchantAttribute.asObservable()
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
        let resizeImage = image.resize(targetSize: CGSize(width: 200, height: 200))
        
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

// MARK: CreateMerchantDetailPresentableListener's members
extension CreateMerchantDetailInteractor: CreateMerchantDetailPresentableListener {
    var errorObserable: Observable<MerchantState> {
        return errorSubject.asObservable()
    }
    
    var listMerchantType: Observable<[MerchantType]> {
        return mListMerchantType.asObservable()
    }
    
    var eLoadingObser: Observable<(Bool, Double)> {
        return trackProgress.asObservable().observeOn(MainScheduler.asyncInstance)
    }
    
    var currentSelectedMerchant: Merchant? {
        return merchantStream?.currentSelectedMerchant
    }
    var listMerchantAttributesData: Observable<[MerchantAttributeData]> {
        return subjectListMerchantAttributesData.asObservable()
    }
    
    func backToMainMerchant() {
        self.listener?.createMerchantDetailMoveBack()
    }
    
    func choosePhoto(type: UIImagePickerController.SourceType, imageType: AddImageType) {
        self.addImageType = imageType
        self.router?.openPhotoLibrary(type: type)
    }
    
    var selectedImage: Observable<UploadedImage> {
        return imageObject.asObservable()
    }
    
    var currentCategory: MerchantCategory? {
        return self.category
    }

    
    func getListMerchantType() {
        if let authenStream = self.authStream {
            authenStream.firebaseAuthToken
                .take(1)
                .flatMap({ token in
                    return Requester.responseDTO(decodeTo: VatoNetwork.OptionalMessageDTO<MerchantResponsePaging<MerchantType>>.self,
                                               using: VatoFoodApi.listMerchantType(authToken: token, params: nil),
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
                        self?.mListMerchantType.onNext(r.response.data?.content ?? [])
                    }
                    }, onError: {[weak self] (e) in
                        printDebug(e.localizedDescription)
                        self?.errorSubject.onNext(.errorSystem(err: e))
                }).disposeOnDeactivate(interactor: self)
        }
    }
    
    
    func getListMerchantAttribute(code: String?) {
        
        var categoryId = merchantStream?.currentSelectedMerchant?.categoryId
        
        if categoryId == nil {
            categoryId = currentCategory?.id
        }
        
        guard let catId = categoryId else {
            return
        }
        
        guard let code = code else { return }
        
        if let authenStream = self.authStream {
            authenStream.firebaseAuthToken
                .take(1)
                .flatMap({ token in
                    return Requester.responseDTO(decodeTo: VatoNetwork.OptionalMessageDTO<MerchantResponsePaging<MerchantAttribute>>.self,
                                               using: VatoFoodApi.merchantAttributeType(authToken: token, categoryId: "\(catId)", typeCode: code, params: nil),
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
                        self?.subjectListMerchantAttribute.onNext(r.response.data?.content ?? [])
                        
                        if let currentSelectedMerchant = self?.merchantStream?.currentSelectedMerchant {
                            if let listMerchantAttributes = currentSelectedMerchant.attributes {
                                self?.subjectListMerchantAttributesData.onNext(listMerchantAttributes)
                            }
                        }
                    }
                    }, onError: {[weak self] (e) in
                        printDebug(e.localizedDescription)
                        self?.errorSubject.onNext(.errorSystem(err: e))
                }).disposeOnDeactivate(interactor: self)
        }
    }
    
   
    func updateMerchant(merchantId: Int, params: [String: Any]) {
        
        if let authenStream = self.authStream, let ownerId = UserManager.instance.userId {
            authenStream.firebaseAuthToken
                .take(1)
                .flatMap({key -> Observable<(HTTPURLResponse, OptionalMessageDTO<Int>)> in
                    Requester.requestDTO(using: VatoFoodApi.updateMerchant(authToken: key, ownerId: ownerId, merchantId: merchantId, params: params),
                                         method: .put,
                                         encoding: JSONEncoding.default)
                })
                .trackProgressActivity(self.trackProgress)
                .observeOn(MainScheduler.asyncInstance)
                .subscribe(onNext: { [weak self] (r) in
                    if  r.1.fail == true {
                        let errType = MerchantState.generalError(status: r.1.status, message: r.1.message ?? Config.ErrorMessage)
                        self?.errorSubject.onNext(errType)
                    } else {
                        printDebug(r)
                        self?.listener?.reloadListMerchant()
                        self?.listener?.createMerchantDetailMoveBack()
                    }
                    }, onError: {[weak self] (e) in
                        printDebug(e.localizedDescription)
                        self?.errorSubject.onNext(.errorSystem(err: e))
                }).disposeOnDeactivate(interactor: self)
        }
    }
    
    
    func createMerchant(params: [String: Any]) {
        if let authenStream = self.authStream {
            authenStream.firebaseAuthToken
                .take(1)
                .flatMap({key -> Observable<(HTTPURLResponse, OptionalMessageDTO<Int>)> in
                    Requester.requestDTO(using: VatoFoodApi.createMerchant(authToken: key, params: params),
                                         method: .post,
                                         encoding: JSONEncoding.default)
                })
                .trackProgressActivity(self.trackProgress)
                .observeOn(MainScheduler.asyncInstance)
                .subscribe(onNext: { [weak self] (r) in
                    if  r.1.fail == true {
                        let errType = MerchantState.generalError(status: r.1.status, message: r.1.message ?? Config.ErrorMessage)
                        self?.errorSubject.onNext(errType)
                    } else {
                        printDebug(r)
                        self?.listener?.reloadListMerchant()
                        self?.listener?.createMerchantDetailMoveBack()
                    }
                    }, onError: {[weak self] (e) in
                        printDebug(e.localizedDescription)
                        self?.errorSubject.onNext(.errorSystem(err: e))
                }).disposeOnDeactivate(interactor: self)
        }
    }
    
    func uploadMerchantAttributes(code: String, listImage: [UploadedImage]) -> Observable<MerchantAttributeData> {
        return FileStorageUploadManager.instance.uploadMerchantAttributes(code: code, listImage: listImage).trackProgressActivity(self.trackProgress)

    }
}

// MARK: Class's private methods
private extension CreateMerchantDetailInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
        
      
    }
    
    
}

extension CreateMerchantDetailInteractor: RequestInteractorProtocol {
    var token: Observable<String> {
        return authStream?.firebaseAuthToken.take(1) ?? Observable.empty()
    }
}
