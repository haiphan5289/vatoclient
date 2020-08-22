//  File name   : BuyTicketPaymentBuilder.swift
//
//  Author      : vato.
//  Created date: 10/10/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol BuyTicketPaymentDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    
    var buyTicketStream: BuyTicketStreamImpl { get }
    var authenticatedStream: AuthenticatedStream { get }
    var mutableProfile: MutableProfileStream { get }
    var mutablePaymentStream: MutablePaymentStream { get }
}

final class BuyTicketPaymentComponent: Component<BuyTicketPaymentDependency> {
    /// Class's public properties.
    let buyTicketPaymentVC: BuyTicketPaymentVC
    
    /// Class's constructor.
    init(dependency: BuyTicketPaymentDependency, buyTicketPaymentVC: BuyTicketPaymentVC) {
        self.buyTicketPaymentVC = buyTicketPaymentVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
    
//    var mutablePaymentStream: MutablePaymentStream {
//        return shared { PaymentStreamImpl() }
//    }
    
    var firebaseDatabase: DatabaseReference {
        return shared { Database.database().reference() }
    }
}

// MARK: Builder
protocol BuyTicketPaymentBuildable: Buildable {
    func build(withListener listener: BuyTicketPaymenListener, streamType: BuslineStreamType) -> BuyTicketPaymenRouting
}

final class BuyTicketPaymentBuilder: Builder<BuyTicketPaymentDependency>, BuyTicketPaymentBuildable {
    /// Class's constructor.
    override init(dependency: BuyTicketPaymentDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: BuyTicketPaymentBuildable's members
    func build(withListener listener: BuyTicketPaymenListener, streamType: BuslineStreamType) -> BuyTicketPaymenRouting {
        let storyboard = UIStoryboard(name: "TicketInfo", bundle: nil)
        var buyTicketPaymentVC = BuyTicketPaymentVC()
        if let vc = storyboard.instantiateViewController(withIdentifier: "BuyTicketPaymentVC") as? BuyTicketPaymentVC {
            buyTicketPaymentVC = vc
        }
        let component = BuyTicketPaymentComponent(dependency: dependency, buyTicketPaymentVC: buyTicketPaymentVC)

        let interactor = BuyTicketPaymentInteractor(presenter: component.buyTicketPaymentVC,
                                                    component: component,
                                                    streamType: streamType)
        interactor.listener = listener

        let switchPaymentBuilder = SwitchPaymentBuilder(dependency: component)
        let noteDeliveryBuilder = NoteDeliveryBuilder(dependency: component)
        let resultBuyTicketBuilder = ResultBuyTicketBuilder(dependency: component)
        // todo: Create builder modules builders and inject into router here.
        let topUpByThirdPartyBuilder = TopUpByThirdPartyBuilder(dependency: component)
        let walletBuilder = WalletBuilder(dependency: component)
        return BuyTicketPaymentRouter(interactor: interactor,
                                      viewController: component.buyTicketPaymentVC,
                                      switchPaymentBuildable: switchPaymentBuilder,
                                      noteDeliveryBuildable: noteDeliveryBuilder,
                                      resultBuyTicketBuildable: resultBuyTicketBuilder,
                                      topUpByThirdPartyBuildable: topUpByThirdPartyBuilder,
                                      walletBuildable: walletBuilder)
    }
}
