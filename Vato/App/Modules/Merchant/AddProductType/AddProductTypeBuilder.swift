//  File name   : AddProductTypeBuilder.swift
//
//  Author      : khoi tran
//  Created date: 11/7/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol AddProductTypeDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authenStream: AuthenticatedStream {get}
    var merchantDataStream: MerchantDataStream { get }
}

final class AddProductTypeComponent: Component<AddProductTypeDependency> {
    /// Class's public properties.
    let AddProductTypeVC: AddProductTypeVC
    
    /// Class's constructor.
    init(dependency: AddProductTypeDependency, AddProductTypeVC: AddProductTypeVC) {
        self.AddProductTypeVC = AddProductTypeVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol AddProductTypeBuildable: Buildable {
    func build(withListener listener: AddProductTypeListener, listPathCategory: [MerchantCategory]?) -> AddProductTypeRouting
}

final class AddProductTypeBuilder: Builder<AddProductTypeDependency>, AddProductTypeBuildable {
    /// Class's constructor.
    override init(dependency: AddProductTypeDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: AddProductTypeBuildable's members
    func build(withListener listener: AddProductTypeListener, listPathCategory: [MerchantCategory]?) -> AddProductTypeRouting {
        let vc = UIStoryboard(name: "AddProductTypeVC", bundle: nil).instantiateViewController(withIdentifier: "AddProductTypeVC") as! AddProductTypeVC
       
        
        let component = AddProductTypeComponent(dependency: dependency, AddProductTypeVC: vc)

        let interactor = AddProductTypeInteractor(presenter: component.AddProductTypeVC, authStream: component.dependency.authenStream, merchantStream: component.dependency.merchantDataStream, listPathCategory: listPathCategory)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        
        return AddProductTypeRouter(interactor: interactor, viewController: component.AddProductTypeVC)
    }
}
