//  File name   : ShoppingFillInformationRouter.swift
//
//  Author      : khoi tran
//  Created date: 4/3/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import Contacts
import ContactsUI

protocol ShoppingFillInformationInteractable: Interactable, LocationPickerListener, PinAddressListener {
    var router: ShoppingFillInformationRouting? { get set }
    var listener: ShoppingFillInformationListener? { get set }
    
    func update(phone: String?)
    func update(name: String?)
}

protocol ShoppingFillInformationViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class ShoppingFillInformationRouter: ViewableRouter<ShoppingFillInformationInteractable, ShoppingFillInformationViewControllable>, Weakifiable {
    /// Class's constructor.
    private lazy var mDelegate = FillInformationContactDelegate()

    init(interactor: ShoppingFillInformationInteractable, viewController: ShoppingFillInformationViewControllable, searchAddressBuildable: LocationPickerBuildable, pinAddressBuildable: PinAddressBuildable) {
        self.searchAddressBuildable = searchAddressBuildable
        self.pinAddressBuildable = pinAddressBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
        setupRX()
    }
    
    /// Class's private properties.
    private let searchAddressBuildable: LocationPickerBuildable
    private let pinAddressBuildable: PinAddressBuildable
}

// MARK: ShoppingFillInformationRouting's members
extension ShoppingFillInformationRouter: ShoppingFillInformationRouting {
   
    
    func routeToChangeAdress(model: AddressProtocol?, searchType: SearchType) {
        let router = searchAddressBuildable.build(withListener: self.interactor,
                                                          placeModel: model,
                                                          searchType: searchType,
                                                          typeLocationPicker: .full)
               let segue = RibsRouting(use: router, transitionType: .presentNavigation, needRemoveCurrent: false)
               perform(with: segue, completion: nil)
    }
    
    func routeToPinAddress(model: AddressProtocol?, isOrigin: Bool) {
        let router = pinAddressBuildable.build(withListener: self.interactor, defautPlace: model, isOrigin: isOrigin)
        let segue = RibsRouting(use: router, transitionType: .push, needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
    func routeToContact() {
        guard let i = interactor as? Interactor else { return }
        requestAuthorizeContact().observeOn(MainScheduler.asyncInstance).bind(onNext: weakify({ (access, wSelf) in
            guard access else {
                AlertVC.showMessageAlert(for: wSelf.viewController.uiviewController, title: Text.warning.localizedText, message: Text.cannotAccessContact.localizedText, actionButton1: Text.cancel.localizedText, actionButton2: Text.ok.localizedText, handler2: {
                    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                })
                return
            }
                
                let contactVC = CNContactPickerViewController()
                contactVC.delegate = wSelf.mDelegate
                wSelf.viewController.uiviewController.present(contactVC, animated: true, completion: nil)
            
        })).disposeOnDeactivate(interactor: i)
    }
    
    private func requestAuthorizeContact() -> Observable<Bool> {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        switch status {
        case .authorized:
            return Observable.just(true)
        case .denied, .restricted:
            return Observable.just(false)
        case .notDetermined:
            return Observable.create { (s) -> Disposable in
                CNContactStore().requestAccess(for: .contacts) { (access, error) in
                    s.onNext(access)
                    s.onCompleted()
                }
                return Disposables.create()
            }
        }
    }

}

// MARK: Class's private methods
private extension ShoppingFillInformationRouter {
    func setupRX() {
        guard let i = interactor as? Interactor else { return }
        mDelegate.eAction.bind { [weak self](action) in
            switch action {
            case .contact(let current):
                finding: for phone in current.phoneNumbers {
                    var p = phone.value.stringValue
                    if !p.isEmpty {
                        self?.interactor.update(name: current.familyName)
                        var characters = [String]()
                        p.forEach { (c) in
                            let s = String(c)
                            guard Int(s) != nil else { return }
                            characters.append(s)
                        }
                        p = characters.joined(separator: "")
                        #if DEBUG
                        guard let url = URL(string: "tel://\(p)"), UIApplication.shared.canOpenURL(url) else {
                            return assert(false, "Check phone")
                        }
                        #endif
                        self?.interactor.update(phone: p)
                        break finding
                    }
                }
                
            default: break
            }
        }.disposeOnDeactivate(interactor: i)
    }
}
