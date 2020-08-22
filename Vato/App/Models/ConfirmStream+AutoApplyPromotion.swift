//
//  ConfirmStream+AutoApplyPromotion.swift
//  Vato
//
//  Created by vato. on 11/8/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation
import VatoNetwork
import RxSwift
import Alamofire

enum StateAutoApplyPromotion {
    case success(promotion: PromotionModel)
    case noPromotionApply
}

// ConfirmStream+AutoApplyPromotion
extension ConfirmStreamImpl {
    
    func reCalculatePromotionWithAutoApplyPromotion() {
        processAutoApplyPromotion()
    }
        
    func processAutoApplyPromotion() {
        self.cancelPromotion(promotionToken: self.model.promotionModel?.data?.data?.promotionToken)
            .flatMap { (_) -> Observable<StateAutoApplyPromotion> in
                self.autoApplyPromotionCode()
            }.trackProgressActivity(self.trackProgress)
            .timeout(30, scheduler: MainScheduler.instance)
            .subscribe(onNext: { (state) in
                switch state {
                case .success(let promotion):
                    self.update(promotion: promotion)
                case .noPromotionApply:
                    self.endAutoAplyPromotionCodeNotFound()
                }
            }, onError: { (e) in
                self.endAutoAplyPromotionCodeNotFound()
            }).disposed(by: disposeBag)
        
        //        self.cancelPromotion(promotionToken: self.model.promotionModel?.data?.data?.promotionToken)
        //            .bind { (_) in
        //            self.autoApplyPromotionCode()
        //        }.disposed(by: disposeBag)
    }
    
    
    private func cancelPromotion(promotionToken: String?) -> Observable<Bool> {
        guard
            let promotionToken = promotionToken,
            promotionToken.isEmpty == false else {
                return Observable.just(false)
        }
        
        return FirebaseTokenHelper.instance
            .eToken
            .filterNil()
            .take(1)
            .flatMap { (authToken) -> Observable<(HTTPURLResponse, Data)> in
                return Requester.request(using: VatoAPIRouter.promotionCancel(authToken: authToken, promotionToken: promotionToken),
                                     method: .post, encoding: JSONEncoding.default)
            }.observeOn(MainScheduler.instance)
            .map { _ in true }
            .catchErrorJustReturn(false)
        
    }
    
    private func autoApplyPromotionCode() -> Observable<StateAutoApplyPromotion> {
        guard let listDataFull = PromotionManager.shared.promotionList?.listDisplay(),
            let listDataFilter = PromotionManager.shared.fillter(listDefault: listDataFull, filterBy: self.model.service),
            !listDataFilter.isEmpty else {
                self.resetPromotion()
                return Observable.empty()
        }
        
        return self.reUsePromotion(listData: listDataFilter, index: 0)
    }
    
    private func reUsePromotion(listData: [PromotionDisplayProtocol], index: Int) -> Observable<StateAutoApplyPromotion> {
        guard index < listData.count,
            let model = listData[safe: index] else {
                return Observable.just(.noPromotionApply)
        }
        let code = model.state.code
        // check valib
        guard let predicate = model.predicate, let method = self.model.paymentMethod?.type.method else {
            return self.reUsePromotion(listData: listData, index: index + 1)
        }
        let promotionModel = PromotionModel(with: code)
        promotionModel.paymentMethod = method
        let predicateData = PromotionData.Data.PromotionPredicate(promotionPredicate: predicate)
        let data = PromotionData.Data(promotionPredicate: predicateData)
        let promotionData = PromotionData(data: data)
        promotionModel.data = promotionData
        if self.precheckPredicate(promotion: promotionModel, listData: listData, index: index) == false {
            return self.reUsePromotion(listData: listData, index: index + 1)
        }
        
        return requestApplyPromotion(listData: listData, index: index)
    }
    
    private func requestApplyPromotion(listData: [PromotionDisplayProtocol], index: Int) -> Observable<StateAutoApplyPromotion> {
        return Observable.create({ (s) -> Disposable in
            if  index < listData.count,
                let model = listData[safe: index] {
                let code = model.state.code
                
                let manifest = model.manifest
                
                PromotionManager.shared.requestPromotionData(from: code).map{ data -> PromotionModel in
                    let model = PromotionModel(with: code)
                    model.data = data
                    //                model.paymentMethod = payment
                    model.mainfest = manifest
                    return model
                    }.observeOn(MainScheduler.instance)
                    .subscribe(onNext: { (promotion) in
                         if self.doubleCheckPromotion(promotion: promotion, listData: listData, index: index) == true {
                            s.onNext(.success(promotion: promotion))
                            s.onCompleted()
                         } else {
                            let e = NSError(domain: NSURLErrorDomain, code: -1999, userInfo: nil)
                            s.onError(e)
                        }
                    }, onError: { (error) in
                        s.onError(error)
                    }).disposed(by: self.disposeBag)
            } else {
                s.onNext(.noPromotionApply)
                s.onCompleted()
            }
            return Disposables.create()
        }).catchError({ (e) in
            return self.reUsePromotion(listData: listData, index: index + 1)
        })
        
    }

    private func precheckPredicate(promotion: PromotionModel?, listData: [PromotionDisplayProtocol], index: Int) -> Bool {
        guard let promotion = promotion else { return false }
        do {
            let s = self.model.service?.service.serviceType ?? .none
            promotion.paymentMethod = model.paymentMethod?.type.method ?? PaymentMethodCash
            try promotion.checkPredicatePromotion(from: model.booking, price: model.informationPrice, serviceType: s)
            return true
        } catch {
            return false
        }
    }
    
    private func endAutoAplyPromotionCodeNotFound() {
        self.resetPromotion()
        if isEnableMessagePromotionStatus == false {
            self.update(from: PromotionError.notFoundPromotionForAutoApply)
        }
        isEnableMessagePromotionStatus = false
    }
    
    private func doubleCheckPromotion(promotion: PromotionModel?, listData: [PromotionDisplayProtocol], index: Int) -> Bool{
        guard let promotion = promotion else { return false }
        do {
            let method = model.paymentMethod?.type.method ?? PaymentMethodCash
            let s = self.model.service?.service.serviceType ?? .none
            try promotion.calculateDiscount(from: model.booking, paymentType: method, price: model.informationPrice, serviceType: s)
            return true
        } catch {
            return false
        }
    }
    
}
