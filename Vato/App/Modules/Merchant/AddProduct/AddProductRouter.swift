//  File name   : AddProductRouter.swift
//
//  Author      : khoi tran
//  Created date: 11/7/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import Photos

protocol AddProductInteractable: Interactable, AddProductTypeListener {
    var router: AddProductRouting? { get set }
    var listener: AddProductListener? { get set }
    
    func handler(error: AddStoreError)
    func handler(image: UIImage)
}

protocol AddProductViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class AddProductRouter: ViewableRouter<AddProductInteractable, AddProductViewControllable> {
    /// Class's constructor.
    init(interactor: AddProductInteractable, viewController: AddProductViewControllable, addProductTypeBuildable: AddProductTypeBuildable) {
        self.addProductTypeBuildable = addProductTypeBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
        setupRX()
    }
    
    /// Class's private properties.
    
    private let addProductTypeBuildable: AddProductTypeBuildable
    
    private lazy var pickerImageHandler = MerchantPickerImageHandler()
    
    
    private func setupRX() {
        guard let i = interactor as? Interactor else { return }
        pickerImageHandler.events.bind { [weak self](type) in
            guard let wSelf = self else { return}
            switch type {
            case .image(let i):
                print("select image")
                guard let i = i else {
                    wSelf.interactor.handler(error: .noPhoto)
                    return
                }
                wSelf.interactor.handler(image: i)
            case .cancel:
                break
            }
            }.disposeOnDeactivate(interactor: i)
    }
}

// MARK: AddProductRouting's members
extension AddProductRouter: AddProductRouting {
    func routeToAddProductType(listPathCategory: [MerchantCategory]?) {
        let route = addProductTypeBuildable.build(withListener: interactor, listPathCategory: listPathCategory)
        let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: true)
        perform(with: segue, completion: nil)
    }
    
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
            self.interactor.handler(error: .other(msg: "Error"))
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
                        self?.interactor.handler(error: .photoPermission)
                        return
                    }
                }
            }
        default:
            self.interactor.handler(error: .photoPermission)
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
                    self?.interactor.handler(error: .cameraPermission)
                }
            })
        default:
            self.interactor.handler(error: .cameraPermission)
            
        }
    }
}

// MARK: Class's private methods
private extension AddProductRouter {
}
