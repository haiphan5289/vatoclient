//  File name   : PromotionDetailRouter.swift
//
//  Author      : Dung Vu
//  Created date: 10/23/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

enum PromotionDetailPresentation {
    case detail(action: AlertAction)
    case recheck(action: AlertAction)
    case notify(actions: [AlertAction])
    
    var iconBack: UIImage {
        switch self {
        case .detail:
           return #imageLiteral(resourceName: "back-w")
        case .recheck, .notify:
            return #imageLiteral(resourceName: "close-g").withRenderingMode(.alwaysTemplate)
        }
    }
    
    var body: [PromotionDetailBody] {
        switch self {
        case .notify:
            return [.header, .title, .decription, .button]
        default:
            return [.header, .title, .code, .decription, .button]
        }
    }
    
    var action: [AlertAction] {
        switch self {
        case .detail(let action):
            return [action]
        case .recheck(let action):
            return [action]
        case .notify(let actions):
            return actions
        }
    }
    
    var hHeader: CGFloat {
        switch self {
        case .notify:
            return 184
        default:
            return 208
        }
    }
    
    var useFullScreen: Bool {
        switch self {
        case .notify:
            return false
        default:
            return true
        }
    }
}

enum PromotionDetailBody {
    case header
    case title
    case code
    case decription
    case button
}

protocol PromotionDetailInteractable: Interactable {
    var router: PromotionDetailRouting? { get set }
    var listener: PromotionDetailListener? { get set }
}

protocol PromotionDetailViewControllable: ViewControllable, ControllableProtocol {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class PromotionDetailRouter: ViewableRouter<PromotionDetailInteractable, PromotionDetailViewControllable>, PromotionDetailRouting {

    weak var currentChild: Routing?
    weak var currentRoute: ViewableRouting?
    
    // todo: Constructor inject child builder protocols to allow building children.
    override init(interactor: PromotionDetailInteractable, viewController: PromotionDetailViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
