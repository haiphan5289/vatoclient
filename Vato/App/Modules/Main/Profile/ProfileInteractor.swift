//  File name   : ProfileInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 9/3/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

protocol ProfileRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func routeToReferral()
    func routeToQuickSupport()
    func routeToMainMerchant()
    func routeToListPromotion()
    func routeToNotification()
    func routeToBlockDriver()
}

protocol ProfilePresentable: Presentable {
    var listener: ProfilePresentableListener? { get set }
    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol ProfileListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func doSignOut()
    func routeToListPromotion()
    func routeToMainMerchant()
    func routeToQuickSupport()
    func profileMoveBack()
    func update(model: PromotionModel?)
    func selectNotification(notify: NotificationModel?)
}

final class ProfileInteractor: PresentableInteractor<ProfilePresentable> {
    private struct Config {
       static let groupVato = "https://www.facebook.com/vato.vn"
       static let registerVato = "https://vato.vn/huong-dan-dang-ky-lai-xe-vato/"
    }
    
    /// Class's public properties.
    weak var router: ProfileRouting?
    weak var listener: ProfileListener?

    /// Class's constructor.
    init(presenter: ProfilePresentable, mutableProfile: MutableProfileStream, authenticate: AuthenticatedStream) {
        self.authenticateStream = authenticate
        self.mutableProfile = mutableProfile
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

    private let mutableProfile: MutableProfileStream
    private let authenticateStream: AuthenticatedStream
    @VariableReplay(wrappedValue: 0) private var badgeUnreadQuickSupport: Int?
    /// Class's private properties.
}

// MARK: ProfileInteractable's members
extension ProfileInteractor: ProfileInteractable, Weakifiable {
    func notificationDismiss() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
    func selectNotification(notify: NotificationModel?) {
        self.listener?.selectNotification(notify: notify)
    }
    
    func update(model: PromotionModel?) {
        router?.dismissCurrentRoute(completion: weakify({ (wSelf) in
            wSelf.listener?.update(model: model)
        }))
    }
    
    func promotionMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func merchantMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func referralMoveback() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func quickSupportMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func blockListMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
        
    var user: Observable<UserInfo> {
        return mutableProfile.user
    }
}

// MARK: ProfilePresentableListener's members
extension ProfileInteractor: ProfilePresentableListener {
    var badgeQuicSupport: Observable<Int?> {
        return $badgeUnreadQuickSupport.asObservable()
    }
    
    func profileMoveBack() {
        listener?.profileMoveBack()
    }
    
    func showInviteFriend() {
        router?.routeToReferral()
    }
    
    func showListPromotion() {
        router?.routeToListPromotion()
    }
    
    func doSignOut() {
        listener?.doSignOut()
    }
    
    func didSelectBlock() {
//        if let viewController = FavoriteViewController(view: nil, type: .init(ViewTypeBlock.rawValue)) {
//            let navigation = FacecarNavigationViewController(rootViewController: viewController)
//            navigation.modalPresentationStyle = .fullScreen
//            navigation.modalTransitionStyle = .coverVertical
//
//            self.router?.viewControllable.uiviewController.present(navigation, animated: true, completion: nil)
//        } else {
//            fatalError("Please Implement")
//        }
        router?.routeToBlockDriver()
    }
    
    func didSelectFavoritePlace() {
        let viewController = FavoritePlaceViewController()
        viewController.authenicate = self.authenticateStream
        let navigation = FacecarNavigationViewController(rootViewController: viewController)
        navigation.modalPresentationStyle = .fullScreen
        navigation.modalTransitionStyle = .coverVertical
        self.router?.viewControllable.uiviewController.present(navigation, animated: true, completion: nil)
    }
    
    func didSelectSupport() {
        let viewController = FCHelpViewController()
        let navigation = FacecarNavigationViewController(rootViewController: viewController)
        navigation.modalPresentationStyle = .fullScreen
        navigation.modalTransitionStyle = .coverVertical
        self.router?.viewControllable.uiviewController.present(navigation, animated: true, completion: nil)
    }
    
    func didSelectGroupVato() {
        if let url = URL(string: Config.groupVato) {
            WebVC.loadWeb(on: self.router?.viewControllable.uiviewController, url: url, title: Text.groupVato.localizedText)
        } else {
            fatalError("Please Implement")
        }
    }
    
    func didSelectRegisterVato() {
        if let url = URL(string: Config.registerVato) {
            WebVC.loadWeb(on: self.router?.viewControllable.uiviewController, url: url, title: Text.registerVato.localizedText)
        } else {
            fatalError("Please Implement")
        }
    }
    
    func didSelectRegisterMerchant() {
        router?.routeToMainMerchant()
    }
    
    func didSelectQuickSupport() {
        router?.routeToQuickSupport()
    }
    
    func requestBadgeQuicksupport() {
        QuicksupportHelper.shared.getUnreadMessage { [weak self] (number, error) in
            self?.badgeUnreadQuickSupport = number
        }
    }
    
    func didSelectNotification() {
        router?.routeToNotification()
    }
}

// MARK: Class's private methods
private extension ProfileInteractor {
    
    func routeToMainMerchant() {
        
    }
    private func setupRX() {
        // todo: Bind data stream here.
        
        
        ShortcutItemManager.instance.shortcutItem.bind {[weak self] (type) in
            guard let wSelf = self else { return }
            
            if type == .merchant {
                wSelf.didSelectRegisterMerchant()
            }
        }.disposeOnDeactivate(interactor: self)
    }
}
