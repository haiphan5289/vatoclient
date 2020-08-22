//  File name   : LoggedOutWrapper.swift
//
//  Author      : Futa Corp
//  Created date: 12/26/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import FirebaseDatabase
import RIBs
import RxSwift

final class LoggedOutWrapperDependency: Component<EmptyDependency>, LoggedOutDependency {
    var firebaseDatabase: DatabaseReference {
        return Database.database().reference()
    }

    var referralCode: Observable<URLComponents> {
        return referralCodeSubject.asObservable()
    }

    /// Class's constructors.
    init() {
        super.init(dependency: EmptyComponent())

        NotificationCenter.default.rx.notification(Notification.Name.init("deepLink"))
            .map { $0.object as? String }
            .filterNil()
            .observeOn(MainScheduler.asyncInstance)
            .bind { [weak self] (link) in
                guard let url = URLComponents(string: link) else {
                    return
                }
                self?.referralCodeSubject.onNext(url)
            }
            .disposed(by: disposeBag)
    }

    /// Class's private properties.
    private lazy var disposeBag = DisposeBag()
    private let referralCodeSubject = ReplaySubject<URLComponents>.create(bufferSize: 1)
}

@objcMembers
final class LoggedOutWrapper: NSObject {
    /// Class's public properties.
    weak var delegate: LoggedOutWrapperDelegate?

    /// Class's constructors.
    override init() {
        super.init()
    }

    /// Class's private properties.
    private var router: LoggedOutRouting?
}

// MARK: Class's public methods
extension LoggedOutWrapper {
    func presentLoggedOut() -> UIViewController {
        let dependency = LoggedOutWrapperDependency()
        let loggedOutBuilder: LoggedOutBuildable = LoggedOutBuilder(dependency: dependency)
        let r = loggedOutBuilder.build(withListener: self)
        defer { router = r }

        r.interactable.activate()
        r.load()

        let viewController = r.viewControllable.uiviewController
//        viewController.rx.deallocated
//            .bind { [weak self] (_) in
//
//            }
//            .disposed(by: disposeBag)

        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }
}

// MARK: Class's private methods
private extension LoggedOutWrapper {
}

// MARK: LoggedOutListener's members
extension LoggedOutWrapper: LoggedOutListener {
    func authenticatedWith(client: ClientProtocol, user: UserProtocol) {
        guard let controller = router?.viewControllable.uiviewController else {
            return
        }
        
        router?.interactable.deactivate()
        router = nil
        controller.dismiss(animated: false, completion: delegate?.finishLoggedIn)
    }
}

@objc protocol LoggedOutWrapperDelegate: NSObjectProtocol {
    func finishLoggedIn()
}
