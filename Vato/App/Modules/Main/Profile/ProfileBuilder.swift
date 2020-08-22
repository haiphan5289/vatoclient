//  File name   : ProfileBuilder.swift
//
//  Author      : Dung Vu
//  Created date: 9/3/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol ProfileDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var mutableProfile: MutableProfileStream { get }
    var authenticated: AuthenticatedStream { get }
    var pTransportStream: MutableTransportStream? { get }
}

final class ProfileComponent: Component<ProfileDependency> {
    /// Class's public properties.
    let ProfileVC: ProfileVC
    
    /// Class's constructor.
    init(dependency: ProfileDependency, ProfileVC: ProfileVC) {
        self.ProfileVC = ProfileVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol ProfileBuildable: Buildable {
    func build(withListener listener: ProfileListener) -> ProfileRouting
}

final class ProfileBuilder: Builder<ProfileDependency>, ProfileBuildable {
    /// Class's constructor.
    override init(dependency: ProfileDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: ProfileBuildable's members
    func build(withListener listener: ProfileListener) -> ProfileRouting {
        let vc = ProfileVC()
        let component = ProfileComponent(dependency: dependency, ProfileVC: vc)

        let interactor = ProfileInteractor(presenter: component.ProfileVC,
                                           mutableProfile: component.dependency.mutableProfile,
                                           authenticate: component.dependency.authenticated)
        interactor.listener = listener
        let referralBuilder = ReferralBuilder(dependency: component)
        // todo: Create builder modules builders and inject into router here.
        let promotionBuilder = PromotionBuilder(dependency: component)
        let quickSupportBuilder = QuickSupportMainBuilder(dependency: component)
        let mainMerchantBuilder = MainMerchantBuilder(dependency: component)
        let notificationBuilder = NotificationBuilder(dependency: component)
        let blockDriverBuilder = BlockDriverBuilder(dependency: component)
        return ProfileRouter(interactor: interactor, viewController: component.ProfileVC, referralBuildable: referralBuilder, promotionBuildable: promotionBuilder, quickSupportBuildable: quickSupportBuilder, mainMerchantBuildable: mainMerchantBuilder, notificationBuildable: notificationBuilder, blockDriverBuildable: blockDriverBuilder)
    }
}
