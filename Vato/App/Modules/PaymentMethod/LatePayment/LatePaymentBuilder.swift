//  File name   : LatePaymentBuilder.swift
//
//  Author      : Futa Corp
//  Created date: 3/6/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol LatePaymentDependency: LatePaymentDependencyPaymentMethodManage, LatePaymentDependencyWallet {
    var authenticated: AuthenticatedStream { get }
    var profileStream: ProfileStream { get }

    var payment: PaymentStream { get }
}

final class LatePaymentComponent: Component<LatePaymentDependency> {
    /// Class's public properties.
    var authenticated: AuthenticatedStream {
        return dependency.authenticated
    }
    var profileStream: ProfileStream {
        return dependency.profileStream
    }

    let latePaymentVC: LatePaymentVC
    
    /// Class's constructor.
    init(dependency: LatePaymentDependency, latePaymentVC: LatePaymentVC) {
        self.latePaymentVC = latePaymentVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
     fileprivate var payment: PaymentStream {
        return dependency.payment
    }
}

// MARK: Builder
protocol LatePaymentBuildable: Buildable {
    func build(withListener listener: LatePaymentListener, debtInfo: UserDebtDTO) -> LatePaymentRouting
}

final class LatePaymentBuilder: Builder<LatePaymentDependency>, LatePaymentBuildable {
    /// Class's constructor.
    override init(dependency: LatePaymentDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: LatePaymentBuildable's members
    func build(withListener listener: LatePaymentListener, debtInfo: UserDebtDTO) -> LatePaymentRouting {
        let vc = LatePaymentVC(nibName: LatePaymentVC.identifier, bundle: nil, debtInfo: debtInfo)
        let component = LatePaymentComponent(dependency: dependency, latePaymentVC: vc)

        let interactor = LatePaymentInteractor(presenter: component.latePaymentVC,
                                               authenticated: component.authenticated,
                                               profile: component.profileStream,
                                               payment: component.payment,
                                               debtInfo: debtInfo)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        let paymentMethodManageBuilder = PaymentMethodManageBuilder(dependency: component)
        let walletBuilder = WalletBuilder(dependency: component)

        return LatePaymentRouter(interactor: interactor,
                                 viewController: component.latePaymentVC,
                                 paymentMethodManageBuilder: paymentMethodManageBuilder,
                                 walletBuilder: walletBuilder)
    }
}
