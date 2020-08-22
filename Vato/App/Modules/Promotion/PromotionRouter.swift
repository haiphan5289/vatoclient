//  File name   : PromotionRouter.swift
//
//  Author      : Dung Vu
//  Created date: 10/19/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import SnapKit
import RxSwift

protocol PromotionInteractable: Interactable,  PromotionSearchListener, PromotionDetailListener {
    var router: PromotionRouting? { get set }
    var listener: PromotionListener? { get set }
    
    var command: PublishSubject<PromotionCommand> { get }
    var manifest: PromotionList.Manifest? { get }
    var code: String { get }
}

protocol PromotionViewControllable: PromotionSearchViewControllable, ControllableProtocol {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
    func focusSearch()
}

final class PromotionRouter: ViewableRouter<PromotionInteractable, PromotionViewControllable>, PromotionRouting {
    weak var currentChild: Routing?
    weak var currentRoute: ViewableRouting?
    

    // todo: Constructor inject child builder protocols to allow building children.
    init(interactor: PromotionInteractable,
         viewController: PromotionViewControllable,
         promotionSearchBuilder: PromotionSearchBuildable,
         promotionDetailBuilder: PromotionDetailBuildable)
    {
        self.promotionSearchBuilder = promotionSearchBuilder
        self.promotionDetailBuilder = promotionDetailBuilder
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    func routeToSearch() {
        guard currentChild == nil else {
            return
        }
        self.attach(newChild: promotionSearchBuilder.build(withListener: self.interactor))
    }
    
    func routeFocusSearch() {
        guard currentChild != nil else {
            return
        }
        self.viewController.focusSearch()
    }
    
    func routeToDetail() {
        let action = AlertAction.init(style: .default, title: PromotionConfig.bookTitle) { [weak self] in
            self?.interactor.command.onNext(.applyPromotion)
        }
        
        let transition = TransitonType.addChild { (v, vc) in
            guard let v = v else {
                return
            }
            v >>> vc?.view >>> {
                $0.snp.makeConstraints({ (make) in
                    make.edges.equalToSuperview()
                })
            }
            
            v.transform = CGAffineTransform(translationX: UIScreen.main.bounds.size.width, y: 0)
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .allowUserInteraction, animations: {
                v.transform = .identity
            }, completion: nil)
        }
        
        let route = promotionDetailBuilder.build(withListener: self.interactor, mode: . detail(action: action), manifest: self.interactor.manifest, code: self.interactor.code)
        self.attach(newRoute: route, transitionType: transition)
        
    }
    
    func showAlert(_ error: Error) {
        guard let type = error as? PromotionError else {
            return
        }
        
        switch type {
        case .applyCode(let e):
            let action = AlertAction.init(style: .cancel, title: PromotionConfig.ok) {}
            AlertVC.show(on: self.viewControllable.uiviewController, title: PromotionConfig.noticeTitle, message: e.localizedDescription, from: [action], orderType: .horizontal)
        default:
            break
        }
    }
    
    func showToast() -> Observable<Void> {
        return Toast.show(using: PromotionConfig.copy, on: self.viewController.uiviewController.view) { (v) in
            v.snp.makeConstraints({ (make) in
                make.centerX.equalToSuperview()
                make.bottom.equalTo(-75)
            })
        }
    }
    
    private let promotionSearchBuilder: PromotionSearchBuildable
    private let promotionDetailBuilder: PromotionDetailBuildable
}
