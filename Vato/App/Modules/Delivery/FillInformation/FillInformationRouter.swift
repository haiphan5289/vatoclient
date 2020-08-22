//  File name   : FillInformationRouter.swift
//
//  Author      : Dung Vu
//  Created date: 8/14/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import Contacts
import ContactsUI
import RxSwift
import RxCocoa

protocol FillInformationInteractable: Interactable, LocationPickerListener, PinAddressListener {
    var router: FillInformationRouting? { get set }
    var listener: FillInformationListener? { get set }
    
    func update(phone: String?)
    func update(name: String?)
    func update(model: DeliveryDateTime?)
}

protocol FillInformationViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

enum ContactAction {
    case cancel
    case contact(current: CNContact)
}

class FillInformationContactDelegate: NSObject, CNContactPickerDelegate {
    lazy var eAction = PublishSubject<ContactAction>()
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        picker.dismiss(animated: true, completion: nil)
        eAction.onNext(.cancel)
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        picker.dismiss(animated: true, completion: nil)
        eAction.onNext(.contact(current: contact))
    }
}

final class FillInformationRouter: ViewableRouter<FillInformationInteractable, FillInformationViewControllable> {
    /// Class's constructor.
    private lazy var mDelegate = FillInformationContactDelegate()
    init(interactor: FillInformationInteractable,
         viewController: FillInformationViewControllable,
         searchDeliveryBuildable: LocationPickerBuildable,
         pinAddressBuildable: PinAddressBuildable) {
        self.pinAddressBuildable = pinAddressBuildable
        self.searchDeliveryBuildable = searchDeliveryBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
        setupRX()
    }
    
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
    
    /// Class's private properties.
    private let searchDeliveryBuildable: LocationPickerBuildable
    private let pinAddressBuildable: PinAddressBuildable
}

// MARK: FillInformationRouting's members
extension FillInformationRouter: FillInformationRouting, Weakifiable {
    
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
    
    func routeToSearchAddress(model: AddressProtocol?, searchType: SearchType) {
        let router = searchDeliveryBuildable.build(withListener: self.interactor,
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
    
    func routeToPickTime(token: Observable<String>) {
        let vc = UIStoryboard(name: "DeliveryPickerTime", bundle: nil).instantiateViewController(withIdentifier: "DeliveryPickerTimeViewController") as! DeliveryPickerTimeViewController
        vc.listener = self
//        vc.defaultModel = model
        vc.token = token
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .fullScreen

        self.viewController.uiviewController.present(vc, animated: true, completion: nil)
    }
    
}

// MARK: Class's private methods
extension FillInformationRouter: DeliveryPickerTimeViewControllerListener {
    func selectTime(model: DeliveryDateTime) {
        self.interactor.update(model: model)
    }
}
