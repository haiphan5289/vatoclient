//  File name   : ProfileRouter.swift
//
//  Author      : Dung Vu
//  Created date: 9/3/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol ProfileInteractable: Interactable, ReferralListener, PromotionListener, QuickSupportMainListener, MainMerchantListener, NotificationListener, BlockDriverListener {
    var router: ProfileRouting? { get set }
    var listener: ProfileListener? { get set }
}

protocol ProfileViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class ProfileRouter: ViewableRouter<ProfileInteractable, ProfileViewControllable> {
    /// Class's constructor.
    init(interactor: ProfileInteractable, viewController: ProfileViewControllable,
         referralBuildable: ReferralBuildable,
         promotionBuildable: PromotionBuildable,
         quickSupportBuildable: QuickSupportMainBuildable,
         mainMerchantBuildable: MainMerchantBuildable,
         notificationBuildable: NotificationBuildable,
         blockDriverBuildable: BlockDriverBuildable)
    {
        self.promotionBuildable = promotionBuildable
        self.quickSupportBuildable = quickSupportBuildable
        self.mainMerchantBuildable = mainMerchantBuildable
        self.referralBuildable = referralBuildable
        self.notificationBuildable = notificationBuildable
        self.blockDriverBuildable = blockDriverBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
    private let referralBuildable: ReferralBuildable
    private let promotionBuildable: PromotionBuildable
    private let quickSupportBuildable: QuickSupportMainBuildable
    private let mainMerchantBuildable: MainMerchantBuildable
    private let notificationBuildable: NotificationBuildable
    private let blockDriverBuildable: BlockDriverBuildable
}

// MARK: ProfileRouting's members
extension ProfileRouter: ProfileRouting {
    func routeToReferral() {
        let router = referralBuildable.build(withListener: interactor)
        let segue = RibsRouting(use: router, transitionType: .presentNavigation, needRemoveCurrent: true)
        perform(with: segue, completion: nil)
    }
    
    func routeToQuickSupport() {
        let router = quickSupportBuildable.build(withListener: interactor)
        let segue = RibsRouting(use: router, transitionType: .presentNavigation, needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
    func routeToMainMerchant() {
        let router = mainMerchantBuildable.build(withListener: interactor)
        let segue = RibsRouting(use: router, transitionType: .presentNavigation, needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
    func routeToListPromotion() {
        let router = promotionBuildable.build(withListener: interactor, type: .home, coordinate: nil)
        let segue = RibsRouting(use: router, transitionType: .modal(type: .coverVertical, presentStyle: .fullScreen), needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
    func routeToNotification() {
        let router = notificationBuildable.build(withListener: interactor)
        let segue = RibsRouting(use: router, transitionType: .presentNavigation, needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
    func routeToBlockDriver() {
        let router = blockDriverBuildable.build(withListener: interactor)
        let segue = RibsRouting(use: router, transitionType: .presentNavigation, needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
}

// MARK: Class's private methods
private extension ProfileRouter {
    
}
