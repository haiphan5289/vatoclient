//  File name   : AddStoreRouter.swift
//
//  Author      : khoi tran
//  Created date: 10/21/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxSwift
import Photos

protocol AddStoreInteractable: Interactable, SearchDeliveryListener {
    var router: AddStoreRouting? { get set }
    var listener: AddStoreListener? { get set }
    
    func handler(error: MerchantState)
    func handler(image: UIImage)
}

protocol AddStoreViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

public final class MerchantPickerImageHandler: PickerImageHandler {
    override public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) { [weak self] in
            let i = info[.editedImage] as? UIImage
            self?.events.onNext(.image(i: i))
        }
    }
}

final class AddStoreRouter: ViewableRouter<AddStoreInteractable, AddStoreViewControllable> {
    /// Class's constructor.
    init(interactor: AddStoreInteractable, viewController: AddStoreViewControllable, searchDeliveryBuildable: SearchDeliveryBuildable) {
        self.searchDeliveryBuildable = searchDeliveryBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
        setupRX()
    }
    
    /// Class's private properties.
    private lazy var pickerImageHandler = MerchantPickerImageHandler()
    private var searchDeliveryBuildable: SearchDeliveryBuildable

    
    
    private func setupRX() {
        guard let i = interactor as? Interactor else { return }
        pickerImageHandler.events.bind { [weak self](type) in
            guard let wSelf = self else { return}
            switch type {
            case .image(let i):
                print("select image")
                guard let i = i else {
                    wSelf.interactor.handler(error: .other(message: "No photo selected"))
                    return
                }
                wSelf.interactor.handler(image: i)
            case .cancel:
                break
            }
            }.disposeOnDeactivate(interactor: i)
    }
}


// MARK: AddStoreRouting's members
extension AddStoreRouter: AddStoreRouting {
    private func chooseImage(type: UIImagePickerController.SourceType) {
        let pickerVC = UIImagePickerController()
        pickerVC.delegate = pickerImageHandler
        pickerVC.sourceType = type
        pickerVC.allowsEditing = true
        self.viewController.uiviewController.present(pickerVC, animated: true, completion: nil)
    }
    
    func openPhotoLibrary(type: UIImagePickerController.SourceType) {
        switch type {
        case .photoLibrary:
            requestPhotoPermisson(type: type)
        case .camera:
            requestCameraPermission(type: type)
        default:
            self.interactor.handler(error: .other(message: "Error"))
        }        
    }
    
    
    func requestPhotoPermisson(type: UIImagePickerController.SourceType) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            chooseImage(type: type)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self](s) in
                DispatchQueue.main.async {
                    switch s {
                    case .authorized:
                        self?.chooseImage(type: type)
                    default:
                        self?.interactor.handler(error: .other(message: "No photo permission"))
                        return
                    }
                }
            }
        default:
            self.interactor.handler(error: .other(message: "No photo permission"))
            return
        }
    }
    
    func requestCameraPermission(type: UIImagePickerController.SourceType) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            chooseImage(type: type)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: {[weak self] (grant) in
                if grant {
                    self?.chooseImage(type: type)
                } else {
                    self?.interactor.handler(error: .other(message: "No camera permission"))
                }
            })
        default:
            self.interactor.handler(error: .other(message: "No camera permission"))
            
        }
    }
    
    func routeToSearchAddress(model: AddressProtocol?) {
        let router = searchDeliveryBuildable.build(withListener: self.interactor, placeModel: model, searchType: .none)
        let segue = RibsRouting(use: router, transitionType: .push, needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
}

// MARK: Class's private methods
private extension AddStoreRouter {
    
    
}
