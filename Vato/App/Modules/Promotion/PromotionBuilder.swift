//  File name   : PromotionBuilder.swift
//
//  Author      : Dung Vu
//  Created date: 10/19/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency
protocol PromotionDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authenticatedStream: AuthenticatedStream { get }
    var pTransportStream: MutableTransportStream? { get }
}

final class PromotionComponent: Component<PromotionDependency> {
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
    init(dependency: PromotionDependency, promotionVC: PromotionViewControllable) {
        self.promotionVC = promotionVC
        super.init(dependency: dependency)
    }
    
    var promotionStream: PromotionStreamImpl {
        return shared{ PromotionStreamImpl() }
    }
    
    let promotionVC: PromotionViewControllable
}

enum PromotionListType: Int {
    case home
    case booking
}

// MARK: Builder
protocol PromotionBuildable: Buildable {
    func build(withListener listener: PromotionListener, type: PromotionListType, coordinate: CLLocationCoordinate2D?) -> PromotionRouting
}

final class PromotionBuilder: Builder<PromotionDependency>, PromotionBuildable {

    override init(dependency: PromotionDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: PromotionListener,
               type: PromotionListType,
               coordinate: CLLocationCoordinate2D?) -> PromotionRouting {
        
        let viewController = PromotionVC()
        let component = PromotionComponent(dependency: dependency, promotionVC: viewController)

        let interactor = PromotionInteractor(presenter: viewController,
                                             authenticatedStream: component.dependency.authenticatedStream,
                                             promotionDataStream: component.promotionStream,
                                             promotionSearchStream: component.promotionStream,
                                             transportStream: component.dependency.pTransportStream,
                                             typeList: type,
                                             coordinate: coordinate)
        interactor.listener = listener
        
        let searchPromotionBuilder = PromotionSearchBuilder(dependency: component)
        let promotionDetailBuilder = PromotionDetailBuilder(dependency: component)
        
        return PromotionRouter(interactor: interactor, viewController: viewController, promotionSearchBuilder: searchPromotionBuilder, promotionDetailBuilder: promotionDetailBuilder)
    }
}
