//  File name   : ScanQRRouter.swift
//
//  Author      : Dung Vu
//  Created date: 9/26/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxSwift
import RxCocoa
import Photos
import FwiCore
import FwiCoreRX

protocol ScanQRInteractable: ResultScanListener {
    var router: ScanQRRouting? { get set }
    var listener: ScanQRListener? { get set }
    
    func handler(error: ScanQRError)
    func handler(qrCode: String?)
    func handler(scanQRStep: ScanQRStep)
}

protocol ScanQRViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

//enum PickerImageAction {
//    case image(i: UIImage?)
//    case cancel
//}
//
//typealias PickerImageDelegate = (UIImagePickerControllerDelegate & UINavigationControllerDelegate)
//public class PickerImageHandler: NSObject, PickerImageDelegate {
//    lazy var events: PublishSubject<PickerImageAction> = PublishSubject()
//    open func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        picker.dismiss(animated: true) { [weak self] in
//            let i = info[.originalImage] as? UIImage
//            self?.events.onNext(.image(i: i))
//        }
//    }
//
//    open func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        picker.dismiss(animated: true) { [weak self] in
//            self?.events.onNext(.cancel)
//        }
//    }
//}

final class ScanQRRouter: ViewableRouter<ScanQRInteractable, ScanQRViewControllable> {
    /// Class's constructor.
    private lazy var pickerImageHandler = PickerImageHandler()
    
    init(interactor: ScanQRInteractable,
                  viewController: ScanQRViewControllable,
                  resultScanBuilder: ResultScanBuildable) {
        self.resultScanBuilder = resultScanBuilder
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
        setupRX()
    }
    
    private func handlerQR(image: UIImage) {
        guard let ciImage = CIImage(image: image) else {
            interactor.handler(error: .noPhoto)
            return
        }
        guard let detector = CIDetector(ofType: CIDetectorTypeQRCode,
                                        context: nil,
                                        options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        else {
            interactor.handler(error: .noPhoto)
            return
        }
        
        let features = detector.features(in: ciImage)
        let code = features.compactMap ({ $0 as? CIQRCodeFeature }).first?.messageString
        interactor.handler(qrCode: code)
    }
    
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
                wSelf.handlerQR(image: i)
            case .cancel:
                wSelf.interactor.handler(scanQRStep: .none)
                break
            }
        }.disposeOnDeactivate(interactor: i)
    }
    
    /// Class's private properties.
    private var resultScanBuilder: ResultScanBuildable
}

// MARK: ScanQRRouting's members
extension ScanQRRouter: ScanQRRouting {
    private func chooseImage() {
        let pickerVC = UIImagePickerController()
        pickerVC.delegate = pickerImageHandler
        pickerVC.sourceType = .photoLibrary
        pickerVC.modalTransitionStyle = .coverVertical
        pickerVC.modalPresentationStyle = .fullScreen

        self.viewController.uiviewController.present(pickerVC, animated: true, completion: nil)
    }
    
    func openPhotoLibrary() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            chooseImage()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self](s) in
                DispatchQueue.main.async {
                    switch s {
                    case .authorized:
                        self?.chooseImage()
                    default:
                        self?.interactor.handler(error: .permissionPhoto)
                    }
                }
            }
        default:
            self.interactor.handler(error: .permissionPhoto)
        }
    }
    
    func routeToResultScsan(type: ResultScanType) {
        let router = resultScanBuilder.build(withListener: interactor, resultScanType: type)
        let segue = RibsRouting(use: router, transitionType: .push, needRemoveCurrent: true)
        perform(with: segue, completion: nil)
    }
    
    func inputCodeQR() {
        let inputCodeVC = InputCodeVC()
        inputCodeVC.modalPresentationStyle = .overCurrentContext
        inputCodeVC.modalTransitionStyle = .crossDissolve
        self.interactor.handler(scanQRStep: .showInputCode)
        inputCodeVC.didSelectCode = { [weak self] code in
            inputCodeVC.dismiss(animated: true, completion: nil)
            self?.interactor.handler(qrCode: code)
        }
        
        inputCodeVC.inputCodeQRDismiss = { [weak self] in
            self?.interactor.handler(scanQRStep: .none)
            inputCodeVC.dismiss(animated: true, completion: nil)
        }
        
        self.viewControllable.uiviewController.present(inputCodeVC, animated: true, completion: nil)
    }
}

// MARK: Class's private methods
private extension ScanQRRouter {
}
