//  File name   : BookingConfirmInteractorComponent+BookingRequestListener.swift
//
//  Author      : Dung Vu
//  Created date: 1/14/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of BookingConfirmInteractor to provide for the BookingRequestListener scope.

extension BookingConfirmInteractor {
    // thống nhất 1 luồng duy nhất là cancel rồi mới apply code
    func requestBookCancel(revert need: Bool) {
        self.router?.dismissCurrentRoute(completion: { [weak self] in
//            // Request promotion
//            if need {
                self?.reRequestSearchDriver()
                self?.applyPromotionAgain()
//            } else {
//                self?.reUsePromotion()
//            }
        })
    }
    
    private func applyPromotionAgain() {
        guard let promotion = self.component.currentPromotion,
            let promotionToken = promotion.data?.data?.promotionToken
            else {
                return
        }
        
        self.revertPromotion(from: promotionToken).subscribe(onNext: { [weak self](_) in
            printDebug("Success to cancel promotion token.")
            self?.reUsePromotion()
        }, onError: { (e) in
            printDebug(e.localizedDescription)
        }).disposeOnDeactivate(interactor: self)
    }
    
    func bookChangeToInTrip(by tripId: String) {
        self.router?.dismissCurrentRoute(true, completion: { [weak self] in
            guard let wSelf = self else { return }
            wSelf.router?.moveToIntrip(by: tripId)
        })
    }
    
}
