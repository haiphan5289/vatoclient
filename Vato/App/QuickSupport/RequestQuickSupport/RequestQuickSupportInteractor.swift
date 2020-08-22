//  File name   : RequestQuickSupportInteractor.swift
//
//  Author      : vato.
//  Created date: 1/15/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

protocol RequestQuickSupportRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func openPhoto()
    func openCamera()
    func routeToListSupport()
}

protocol RequestQuickSupportPresentable: Presentable {
    var listener: RequestQuickSupportPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
    func showError(eror: Error)
    func showAlertSuccess()
    func showAlertFail() 
}

protocol RequestQuickSupportListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func requestSupportMoveBack()
}

final class RequestQuickSupportInteractor: PresentableInteractor<RequestQuickSupportPresentable> {
    /// Class's public properties.
    weak var router: RequestQuickSupportRouting?
    weak var listener: RequestQuickSupportListener?

    /// Class's constructor.
    init(presenter: RequestQuickSupportPresentable,
         requestModel: QuickSupportRequest) {
        self.requestModel = requestModel
        super.init(presenter: presenter)
        presenter.listener = self
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
    @VariableReplay private var images: [UIImage] = []
    internal let requestModel: QuickSupportRequest
}

// MARK: RequestQuickSupportInteractable's members
extension RequestQuickSupportInteractor: RequestQuickSupportInteractable {
    func quickSupportListMoveBack() {
        listener?.requestSupportMoveBack()
    }
    
    func addPhoto(image: UIImage?) {
        guard let image = image else { return }
        images.append(image)
    }
}

// MARK: RequestQuickSupportPresentableListener's members
extension RequestQuickSupportInteractor: RequestQuickSupportPresentableListener {
    
    func routeToListSupport() {
        router?.routeToListSupport()
    }
    
    func submit() {
        guard self.images.isEmpty == false else {
            self.presenter.showAlertSuccess()
            return
        }
        LoadingManager.instance.show()
        FirebaseUploadImage.upload(self.images, withPath: "QuickSupport") {[weak self] (urls, error) in
            DispatchQueue.main.async {
                if error != nil,
                    let _error = error as NSError? {
                    // show error
                    self?.presenter.showError(eror: _error)
                } else {
                    self?.presenter.showAlertSuccess()
                }
                LoadingManager.instance.dismiss()
            }
        }
    }
    
    func requestSupportMoveBack() {
        listener?.requestSupportMoveBack()
    }
    
    
    func removePhoto(index: Int) {
        guard index >= 0,
            index < images.count else { return }
        images.remove(at: index)
    }
    
    var imagesObser: Observable<[UIImage]> {
        return $images.asObservable()
    }
    
    func openPhoto() {
        router?.openPhoto()
    }
    
    func openCamera() {
        router?.openCamera()
    }
}

// MARK: Class's private methods
private extension RequestQuickSupportInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
}
