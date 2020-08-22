//  File name   : VatoTabbarRouter.swift
//
//  Author      : Dung Vu
//  Created date: 8/26/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

enum TabbarType: Int, CaseIterable {
    case home = 0
    case history
    case vatoPay
    case notify
    case profile
    
    static var allCases: [TabbarType] {
        return [.home, .vatoPay]
    }
    
    
    var title: String {
        switch self {
        case .home:
            return Text.tabbarHome.localizedText
        case .history:
            return Text.tabbarHistory.localizedText
        case .vatoPay:
            return Text.wallet.localizedText
        case .notify:
            return Text.notification.localizedText
        case .profile:
            return Text.tabbarProfile.localizedText
        }
    }
    
    var icon: (normal: UIImage?, selected: UIImage?) {
        switch self {
        case .home:
            return (UIImage(named: "ic_tabbar_home_n"), UIImage(named: "ic_tabbar_home_h"))
        case .history:
            return (UIImage(named: "ic_tabbar_history_n"), UIImage(named: "ic_tabbar_history_h"))
        case .notify:
            return (UIImage(named: "ic_tabbar_notify_n"), UIImage(named: "ic_tabbar_notify_h"))
        case .vatoPay:
            return (UIImage(named: "ic_tabbar_wallet_n"), UIImage(named: "ic_tabbar_wallet_h"))
        case .profile:
            return (UIImage(named: "ic_tabbar_profile_n"), UIImage(named: "ic_tabbar_profile_h"))
        }
    }
}

typealias TabbarListenerProtocol = WalletListener & VatoMainListener & PromotionDetailListener & PromotionListener & WalletListHistoryListener & ProfileListener & MainDeliveryListener & TicketDestinationListener & MainMerchantListener & FoodMainListener & HistoryListener & NotificationListener & QuickSupportMainListener & TopUpByThirdPartyListener & StoreTrackingListener & TOShortcutListener & SetLocationListener & ShoppingMainListener

protocol VatoTabbarInteractable: Interactable, TabbarListenerProtocol {
    var router: VatoTabbarRouting? { get set }
    var listener: VatoTabbarListener? { get set }
    func usePromotion(code: String, from manifest: PromotionList.Manifest)
    func handleLookupManifestAction(with extra: String)
}

protocol VatoTabbarViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class VatoTabbarRouter: ViewableRouter<VatoTabbarInteractable, VatoTabbarViewControllable> {
    /// Class's constructor.
    init(interactor: VatoTabbarInteractable,
         viewController: VatoTabbarViewControllable,
         vatoMainBuildable: VatoMainBuildable,
         walletBuildable: WalletBuildable,
         promotionDetailBuildable: PromotionDetailBuildable,
         promotionBuildable: PromotionBuildable,
         walletListHistoryBuildable: WalletListHistoryBuildable,
         profileBuildable: ProfileBuildable,
         mainDeliveryBuildable: MainDeliveryBuildable,
         ticketDestinationBuildable: TicketDestinationBuildable,
         mainMerchantBuildable: MainMerchantBuildable,
         foodMainBuildable: FoodMainBuildable,
         historyBuildable: HistoryBuildable,
         notificationBuildable: NotificationBuildable,
         quickSupportBuildable: QuickSupportMainBuildable,
         topUpByThirdPartyBuildable: TopUpByThirdPartyBuildable,
         storeTrackingBuildable: StoreTrackingBuildable,
         shortcutBuildable: TOShortcutBuildable,
         setLocationBuildable: SetLocationBuildable,
         shoppingMainBuildable: ShoppingMainBuildable)
         
    {
        self.historyBuildable = historyBuildable
        self.foodMainBuildable = foodMainBuildable
        self.mainDeliveryBuildable = mainDeliveryBuildable
        self.promotionBuildable = promotionBuildable
        self.vatoMainBuildable = vatoMainBuildable
        self.walletBuildable = walletBuildable
        self.promotionDetailBuildable = promotionDetailBuildable
        self.walletListHistoryBuildable = walletListHistoryBuildable
        self.profileBuildable = profileBuildable
        self.ticketDestinationBuildable = ticketDestinationBuildable
        self.mainMerchantBuildable = mainMerchantBuildable
        self.notificationBuildable = notificationBuildable
        self.quickSupportBuildable = quickSupportBuildable
        self.topUpByThirdPartyBuildable = topUpByThirdPartyBuildable
        self.storeTrackingBuildable = storeTrackingBuildable
        self.shortcutBuildable = shortcutBuildable
        self.setLocationBuildable = setLocationBuildable
        self.shoppingMainBuildable = shoppingMainBuildable

        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
        createAll()
        setupRX()
    }
    
    /// Class's private properties.
    private let vatoMainBuildable: VatoMainBuildable
    private let walletBuildable: WalletBuildable
    private let promotionDetailBuildable: PromotionDetailBuildable
    private let promotionBuildable: PromotionBuildable
    private let walletListHistoryBuildable: WalletListHistoryBuildable
    private let profileBuildable: ProfileBuildable
    private let mainDeliveryBuildable: MainDeliveryBuildable
    private let ticketDestinationBuildable: TicketDestinationBuildable
    private let mainMerchantBuildable: MainMerchantBuildable
    private let foodMainBuildable: FoodMainBuildable
    private let historyBuildable: HistoryBuildable
    private let notificationBuildable: NotificationBuildable
    
    private let quickSupportBuildable: QuickSupportMainBuildable
    private let topUpByThirdPartyBuildable: TopUpByThirdPartyBuildable
    private let storeTrackingBuildable: StoreTrackingBuildable
    
    private let shortcutBuildable: TOShortcutBuildable
    private let setLocationBuildable: SetLocationBuildable
    private let shoppingMainBuildable: ShoppingMainBuildable
    private lazy var handler: VatoHandlerObjC = VatoHandlerObjC()
}

// MARK: - Change Route
extension VatoTabbarRouter {
    
    func routeToHistory(selected: HistoryItemType?) {
        let route = historyBuildable.build(withListener: interactor, selected: selected)
        let segue = RibsRouting(use: route, transitionType: .presentNavigation , needRemoveCurrent: false )
        perform(with: segue, completion: nil)
    }
    
    
    func routeToShortcut() {
        let route = shortcutBuildable.build(withListener: interactor, type: .default)
        let segue = RibsRouting(use: route, transitionType: .presentNavigation , needRemoveCurrent: false )
        perform(with: segue, completion: nil)
    }
    
    func routeToBooking(dependency: VatoDependencyMainServiceProtocol, data: VatoMainData) {
        // -> Home and set value need
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let home = storyboard.instantiateViewController(withIdentifier: "HomeBridgeVC") as? HomeBridgeVC else {
            return
        }
        home.modalPresentationStyle = .fullScreen
        home.modalTransitionStyle = .coverVertical
        home.dependency = dependency
        home.data = data
        DispatchQueue.main.async {
            self.viewControllable.uiviewController.present(home, animated: true, completion: nil)
        }
    }
}

// MARK: VatoTabbarRouting's members
extension VatoTabbarRouter: VatoTabbarRouting {
    
    func routeToShopping() {
        let route = shoppingMainBuildable.build(withListener: interactor)
        let segue = RibsRouting(use: route, transitionType: .presentNavigation , needRemoveCurrent: false )
        perform(with: segue, completion: nil)
    }
    
    func routeToEcomTracking(saleOderId: String) {
        let route = storeTrackingBuildable.build(withListener: interactor, order: nil, id: saleOderId)
        let segue = RibsRouting(use: route, transitionType: .presentNavigation , needRemoveCurrent: false )
        perform(with: segue, completion: nil)
    }
    
    func routeToWallet() {
        let route = walletBuildable.build(withListener: interactor, source: .home)
        let segue = RibsRouting(use: route, transitionType: .presentNavigation , needRemoveCurrent: false )
        perform(with: segue, completion: nil)
    }
    
    func routeToProfile() {
        let route = profileBuildable.build(withListener: interactor)
        let segue = RibsRouting(use: route, transitionType: .presentNavigation , needRemoveCurrent: false )
        perform(with: segue, completion: nil)
    }
    
    func routeToTopup() {
        let router = topUpByThirdPartyBuildable.build(withListener: interactor)
        let segue = RibsRouting(use: router, transitionType: .presentNavigation, needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
    func routeToQuickSupport() {
        let router = quickSupportBuildable.build(withListener: interactor)
        let segue = RibsRouting(use: router, transitionType: .presentNavigation, needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
    func selectNotification(notify: NotificationModel?) {
        self.handler.selectNotification(notify: notify)
    }
    
    func routeToMainMerchant() {
        let router = mainMerchantBuildable.build(withListener: interactor)
        let segue = RibsRouting(use: router, transitionType: .presentNavigation, needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
    func routeToServiceCategory(type: ServiceCategoryType, action: ServiceCategoryAction?) {
        let router = foodMainBuildable.build(withListener: interactor, type: type, action: action)

        let segue = RibsRouting(use: router, transitionType: .presentNavigation , needRemoveCurrent: false )
        perform(with: segue, completion: nil)
    }
    
    func routeToDelivery() {
        let router = mainDeliveryBuildable.build(withListener: interactor)
        let segue = RibsRouting(use: router, transitionType: .presentNavigation, needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
    func routeToTicket(action: TicketDestinationAction?) {
        let router = ticketDestinationBuildable.build(withListener: interactor, action: action)
        let segue = RibsRouting(use: router, transitionType: .presentNavigation, needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
    func doSignOut() {
        handler.events.onNext(.signout)
    }
    
    func showListWalletHistory() {
        let router = walletListHistoryBuildable.build(withListener: self.interactor, balanceType: 3)
        let transition = RibsRouting(use: router, transitionType: .presentNavigation, needRemoveCurrent: false)
        self.perform(with: transition, completion: nil)
    }
    
    func routeToListPromotion() {
        let router = promotionBuildable.build(withListener: interactor, type: .home, coordinate: nil)
        let segue = RibsRouting(use: router, transitionType: .modal(type: .coverVertical, presentStyle: .fullScreen), needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
    func routeToPromotionDetail(with type: ManifestAction, extra: String) {
        switch type {
        case .web:
            guard let url = URL(string: extra) else { return }
            let controller = self.viewController.uiviewController
            WebVC.loadWeb(on: controller, url: url, title: "")
            
        case .manifest:
            self.interactor.handleLookupManifestAction(with: extra)
        default: break
        }
    }
    
    private func signOut() {
        guard let appDelegate = UIApplication.shared.delegate as? ApplicationDelegateProtocol else {
            return
        }
        appDelegate.cleanUp()
        handler.events.onNext(.signout)
    }
    
    func routeToNotifySignedOtherDevice() {
        let title = Text.notification.localizedText
        let message = Text.signOutMessage.localizedText
        let actionOK = AlertAction(style: .cancel, title: Text.dismiss.localizedText) { [weak self] in
            self?.signOut()
        }
        AlertVC.show(on: self.viewController.uiviewController, title: title, message: message, from: [actionOK], orderType: .horizontal)
    }
    
    func presentAlert(message: String) {
        let actionCancel = AlertAction(style: .default, title: Text.retry.localizedText, handler: {})
        AlertVC.show(on: viewController.uiviewController, title: "Vato", message: message, from: [actionCancel], orderType: .horizontal)
    }
    
    func presentAlert(title: String, message: String, cancelAction: String) {
        let actionCancel = AlertAction(style: .default, title: cancelAction, handler: {})
        AlertVC.show(on: viewController.uiviewController, title: title, message: message, from: [actionCancel], orderType: .horizontal)
    }
    
    
    func routeToPromotionDetail(manifest: PromotionList.Manifest) {
        guard let code = manifest.code else {
            return
        }
        
        let actionOkay = AlertAction(style: .default, title: Text.quickBooking.localizedText, handler: { [weak self] in
            self?.dismissCurrentRoute(completion: {
                self?.interactor.usePromotion(code: code, from: manifest)
            })
        })
        
        let router = promotionDetailBuildable.build(withListener: interactor, mode: .detail(action: actionOkay), manifest: manifest, code: code)
        let remove = self.viewControllable.uiviewController.presentedViewController != nil
        let segue = RibsRouting(use: router, transitionType: .modal(type: .coverVertical, presentStyle: .currentContext), needRemoveCurrent: remove)
        perform(with: segue, completion: nil)
    }
    
    func routeToPromotionDetail(predicate: PromotionList.ManifestPredicate, manifest: PromotionList.Manifest) {
        guard let type = ManifestAction(rawValue: predicate.type), type != .ecom else {
            return
        }
        let actions: [AlertAction]
        
        switch type {
        case .web:
            let actionOkay = AlertAction(style: .default, title: Text.seeMore.localizedText, handler: { [weak self] in
                guard let url = URL(string: predicate.extra),
                    let controller = self?.viewController.uiviewController
                    else {
                        return
                }
                
                self?.dismissCurrentRoute(completion: nil)
                WebVC.loadWeb(on: controller, url: url, title: "")
            })
            actions = [actionOkay]
            
        case .manifest:
            let actionCancel = AlertAction(style: .cancel, title: Text.dismiss.localizedText, handler: { [weak self] in
                self?.dismissCurrentRoute(completion: nil)
            })
            let actionOkay = AlertAction(style: .default, title: Text.seeMore.localizedText, handler: { [weak self] in
                self?.interactor.handleLookupManifestAction(with: predicate.extra)
            })
            actions = [actionCancel, actionOkay]
        default:
            return
            
        }
        
        let router = promotionDetailBuildable.build(withListener: interactor, mode: .notify(actions: actions), manifest: manifest, code: "")
        
        let segue = RibsRouting(use: router, transitionType: .modal(type: .crossDissolve, presentStyle: .overCurrentContext), needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
    private func generateRoute(routing: @autoclosure () -> Routing, type: TabbarType, useNavi: Bool = true) -> RibsTransitionInformationProtocol {
        let route = routing()
        let segue = RibsRouting(use: route, transitionType: .tabbar(customVC: { current in
            let tabbar = UITabBarItem(title: type.title, image: type.icon.normal, selectedImage: type.icon.selected)
            tabbar.setTitleTextAttributes([.foregroundColor: Color.battleshipGrey], for: .normal)
            tabbar.setTitleTextAttributes([.foregroundColor: Color.orange], for: .selected)
            if useNavi {
                let nav = UINavigationController(rootViewController: current)
                nav.tabBarItem = tabbar
                return nav
            } else {
                current.tabBarItem = tabbar
                return current
            }
        }), needRemoveCurrent: false)
        return segue
    }
    
    func createAll() {
        TabbarType.allCases.forEach { (type) in
//            let controller: UIViewController?
            var segue: RibsTransitionInformationProtocol?
            
            switch type {
            case .home:
                segue = self.generateRoute(routing: vatoMainBuildable.build(withListener: interactor), type: .home, useNavi: false)
            case .vatoPay:
                segue = self.generateRoute(routing: walletBuildable.build(withListener: interactor, source: .home), type: .vatoPay)
            case .history:
                segue = self.generateRoute(routing: historyBuildable.build(withListener: interactor, selected: nil), type: .history, useNavi: true)
                
                //                let historyVC = FCTripManagerViewController()
            //                controller = FacecarNavigationViewController(rootViewController: historyVC)
            case .notify:
                //                if let notifyVC = FCNotifyViewController(view: ()) {
                //                    notifyVC.delegate = handler
                //                    controller = FacecarNavigationViewController(rootViewController: notifyVC)
                //                }
                segue = self.generateRoute(routing: notificationBuildable.build(withListener: interactor), type: .notify, useNavi: true)
            case .profile:
                segue = self.generateRoute(routing: profileBuildable.build(withListener: interactor), type: .profile, useNavi: false)
            }
            
            if let s = segue {
                self.perform(with: s, completion: nil)
            }
//            else if let vc = controller {
//                let tabbar = UITabBarItem(title: type.title, image: type.icon.normal, selectedImage: type.icon.selected)
//                tabbar.setTitleTextAttributes([.foregroundColor: Color.battleshipGrey], for: .normal)
//                tabbar.setTitleTextAttributes([.foregroundColor: Color.orange], for: .selected)
//                vc.tabBarItem = tabbar
//                let tabbarVC = (self.viewControllable.uiviewController as? UITabBarController)
//                var current = tabbarVC?.viewControllers
//                current?.append(vc)
//                tabbarVC?.setViewControllers(current, animated: false)
//            }
        }
    }
}

// MARK: Class's private methods
private extension VatoTabbarRouter {
    func setupRX() {
        guard let i = interactor as? Interactor else {
            return
        }
        
        handler.events.bind { (action) in
            switch action {
            case .signout:
                let excute = {
                    FirebaseTokenHelper.instance.stopUpdate()
                    guard let appDelegate = UIApplication.shared.delegate as? ApplicationDelegateProtocol else {
                        return
                    }
                    appDelegate.signOut()
                }
                excute()
            case .routeNotifyDetail(let data):
                guard
                    let extra = data?.extra,
                    let type = data?.type?.rawValue,
                    let action = ManifestAction(rawValue: type) else { return }
                
                self.routeToPromotionDetail(with: action, extra: extra)
            }
            
        }.disposeOnDeactivate(interactor: i)
    }
}
