//  File name   : ScanQRVC.swift
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
import SnapKit
import AVFoundation


enum ScanQRStep: Equatable {
    case showInputCode
    case loading(load: Bool, progress: Double)
    case showAlert
    case result
    case none
    
    static func ==(lhs: ScanQRStep, rhs: ScanQRStep) -> Bool {
        switch (lhs, rhs) {
        case (.loading(let s1, _), .loading(let s2, _)):
            return s1 == s2
        case (.result, .result):
            return true
        default:
            return false
        }
    }
}

final class CameraLiveView: UIView {
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var previewLayer: AVCaptureVideoPreviewLayer? {
        return self.layer as? AVCaptureVideoPreviewLayer
    }
}

protocol ScanQRPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var error: Observable<ScanQRError> { get }
    var stepProcessing: Observable<ScanQRStep> { get }
    func scanQRMoveBack()
    func openPhotoLibrary()
    func inputCodeQR()
    func handler(qrCode: String?)
    func handler(scanQRStep: ScanQRStep)
}

final class ScanQRVC: UIViewController, ScanQRPresentable, ScanQRViewControllable {
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: ScanQRPresentableListener?
    @IBOutlet var containerView: UIView!
    @IBOutlet var cameraView: CameraLiveView!
    @IBOutlet var overlayView: UIView!
    @IBOutlet var btnFlash: UIButton!
    @IBOutlet var lblGuide: UILabel?
    @IBOutlet var btnInputCode: UIButton?
    @IBOutlet var btnPhoto: UIButton?
    private lazy var disposeBag = DisposeBag()
    private lazy var captureSession = AVCaptureSession()
    
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupCamera()
        setupRX()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
        captureSession.startRunning()
        setupNavigation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }
    
    private func setupCamera() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        captureSession.beginConfiguration()
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            return
        }
        captureSession.commitConfiguration()
        view.layoutSubviews()
        let previewLayer = self.cameraView.previewLayer
        previewLayer?.session = captureSession
        previewLayer?.videoGravity = .resizeAspectFill
        
    }
    /// Class's private properties.
    
    func presentWebVC(url: URL?, title: String?, accessToken: String) {
        WebVC.loadWeb(on: self, url: url, title: title)
    }
}

// MARK: View's event handlers
extension ScanQRVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    func handler(error: ScanQRError) {
        var message: String?
        switch error {
        case .permissionPhoto:
            message = Text.authorizeOpenPhotoGetTicket.localizedText
        case .permissionCamera:
            message = Text.authorizeOpenCameraScanTicket.localizedText
        case .noPhoto:
            message = Text.cannotFindValidQRCode.localizedText
        case .noQRCode:
            message = Text.cannotFindValidQRCode.localizedText
        case .orther(let msg):
            message = msg
        }
        
        if let message = message {
            self.presentAlert(message: message)
        }
    }
}

// MARK: Class's public methods
extension ScanQRVC: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            return
        }
        
        // Get the metadata object.
        guard let metadataObj = metadataObjects.first as? AVMetadataMachineReadableCodeObject else {
            return
        }
        
        let type = metadataObj.type
        switch type {
        case .qr:
            guard let code = metadataObj.stringValue else {
                return
            }
            listener?.handler(qrCode: code)
            
        default:
            break
        }
    }
}

// MARK: Class's private methods
private extension ScanQRVC {
    private func localize() {
        // todo: Localize view's here.
    }
    
    private func visualize() {
        // todo: Visualize view's here.
        setupNavigation()
        title = Text.scanQR.localizedText
        lblGuide?.text = Text.moveCamera.localizedText
        btnInputCode?.setTitle(Text.inputCodeQR.localizedText, for: .normal)
        btnPhoto?.setTitle(Text.inputPhotoQR.localizedText, for: .normal)
    }
    
    private func setupNavigation() {
        let navigationBar = self.navigationController?.navigationBar
        navigationBar?.barTintColor = .black
        navigationBar?.isTranslucent = false
        navigationBar?.tintColor = .white
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        let image = UIImage(named: "ic_arrow_back")
        let leftButton = UIButton(frame: CGRect(origin: .zero, size: image?.size ?? .zero))
        leftButton.setImage(image, for: .normal)
        leftButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
        let leftBarButton = UIBarButtonItem(customView: leftButton)
        navigationItem.leftBarButtonItem = leftBarButton
        leftButton.rx.tap.bind(onNext: weakify { wSelf in
            wSelf.listener?.scanQRMoveBack()
        }).disposed(by: disposeBag)
    }
    
    private func presentAlert(message: String) {
        let actionCancel = AlertAction(style: .default, title: Text.dismiss.localizedText, handler: { [weak self] in
            self?.listener?.handler(scanQRStep: .none)
        })
        captureSession.stopRunning()
        listener?.handler(scanQRStep: .showAlert)
        AlertVC.show(on: self, title: "Vato", message: message, from: [actionCancel], orderType: .horizontal)
    }

    func configFlash() {
        let isFlashed = self.btnFlash.isSelected
        guard let device = (captureSession.inputs.first as? AVCaptureDeviceInput)?.device else {
            return
        }
        do {
            try device.lockForConfiguration()
            defer {
                device.unlockForConfiguration()
            }
            
            guard device.hasTorch else {
                return
            }
            device.torchMode = isFlashed ? .off : .on
            self.btnFlash.isSelected = !isFlashed
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func setupRX() {
        btnFlash.rx.tap.bind(onNext: weakify({ (wself) in
            wself.configFlash()
        })).disposed(by: disposeBag)
        
        btnPhoto?.rx.tap.bind(onNext: weakify({ (wSelf) in
            wSelf.listener?.openPhotoLibrary()
        })).disposed(by: disposeBag)
        
        btnInputCode?.rx.tap.bind(onNext: weakify({ (wSelf) in
            wSelf.listener?.inputCodeQR()
        })).disposed(by: disposeBag)
        
        self.listener?.stepProcessing.bind(onNext: {[weak self] (stepProcessing) in
            switch stepProcessing {
            case .showInputCode:
                self?.captureSession.stopRunning()
            case .loading(let load, let progress):
                load ? self?.captureSession.stopRunning() : self?.captureSession.startRunning()
            case .none:
                self?.captureSession.startRunning()
            case .showAlert:
                self?.captureSession.stopRunning()
            case .result:
                self?.captureSession.stopRunning()
            }
        }).disposed(by: disposeBag)

        
        self.listener?.error.bind(onNext: {[weak self] (scanQRError) in
           self?.handler(error: scanQRError)
        }).disposed(by: disposeBag)
    }
}

