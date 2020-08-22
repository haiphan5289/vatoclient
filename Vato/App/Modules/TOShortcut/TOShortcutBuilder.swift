//  File name   : TOShortcutBuilder.swift
//
//  Author      : khoi tran
//  Created date: 2/17/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import FwiCore

enum TOShortcutType {
    case `default`
    case inTrip
    
    var fileName: String {
        switch self {
        case .default:
            return "shortcut-dummy.json"
        case .inTrip:
            return Text.inTripAddDestinationFile.localizedText
        }
    }
    
    var title: String {
        switch self {
        case .inTrip:
            return Text.shortcutInTrip.localizedText
        case .default:
            return Text.shortcutTitle.localizedText
        }
    }
}

// MARK: Dependency tree
protocol TOShortcutDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authenticated: AuthenticatedStream { get }
    var profile: ProfileStream { get }
    var mutablePaymentStream: MutablePaymentStream { get }
    var mutableBookingStream: MutableBookingStream { get }
}

final class TOShortcutComponent: Component<TOShortcutDependency> {
    /// Class's public properties.
    let TOShortcutVC: TOShortcutVC
    
    /// Class's constructor.
    init(dependency: TOShortcutDependency, TOShortcutVC: TOShortcutVC) {
        self.TOShortcutVC = TOShortcutVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol TOShortcutBuildable: Buildable {
    func build(withListener listener: TOShortcutListener, type: TOShortcutType) -> TOShortcutRouting
}

final class TOShortcutBuilder: Builder<TOShortcutDependency>, TOShortcutBuildable {
    /// Class's constructor.
    override init(dependency: TOShortcutDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: TOShortcutBuildable's members
    func build(withListener listener: TOShortcutListener, type: TOShortcutType) -> TOShortcutRouting {
        let vc = TOShortcutVC(nibName: TOShortcutVC.identifier, bundle: nil)
        let component = TOShortcutComponent(dependency: dependency, TOShortcutVC: vc)

        let interactor =
            TOShortcutInteractor(presenter: component.TOShortcutVC, authenticated: self.dependency.authenticated, type: type, mutableBookingStream: component.dependency.mutableBookingStream)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        let setLocationBuilder = SetLocationBuilder(dependency: component)
        return TOShortcutRouter(interactor: interactor, viewController: component.TOShortcutVC,
                                walletListHistoryBuildable: WalletListHistoryBuilder(dependency: component),
                                historyBuildable: HistoryBuilder(dependency: component),
                                quickSupportMainBuildable: QuickSupportMainBuilder(dependency: component),
                                mainMerchantBuildable: MainMerchantBuilder(dependency: component), referralBuildable: ReferralBuilder(dependency: component),
                                setLocationBuildable: setLocationBuilder)
    }
}
