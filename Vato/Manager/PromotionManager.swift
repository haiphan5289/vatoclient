//
//  FavoritePlaceManager.swift
//  Vato
//
//  Created by vato. on 7/19/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import RIBs
import Foundation
import RxSwift
import Firebase
import VatoNetwork
import Alamofire

final class PromotionManager: SafeAccessProtocol {
    struct Config {
        static let timeRequestList: Int = 600
    }
    private (set) lazy var lock: NSRecursiveLock = NSRecursiveLock()
    static fileprivate(set) var shared = PromotionManager()
    private var _mlist: PromotionList?
    private var disposeAbleCheck: Disposable?
    private var disposeAbleRequest: Disposable?
    var promotionList: PromotionList? {
        return excute {
           return _mlist
        }
    }
    private lazy var disposeBag = DisposeBag()
        
    func update(list: PromotionList) {
        excute(block: {
            _mlist = list
        })
    }
    
    func checkPromotion(coordinate: CLLocationCoordinate2D?) {
        let coordinate = coordinate ?? VatoLocationManager.shared.location?.coordinate
        disposeAbleRequest?.dispose()
        disposeAbleRequest = requestListPromotion(coordinate: coordinate).subscribe { [unowned self](e) in
            switch e {
            case .error(let e):
                #if DEBUG
                   print(e.localizedDescription)
                #endif
                self.excute(block: {
                    self._mlist = nil
                })
            case .next(let new):
                self.excute(block: {
                    self._mlist = new.data
                })
            default:
                break
            }
        }
    }
    
    private func requestListPromotion(coordinate: CLLocationCoordinate2D?) -> Observable<MessageDTO<PromotionList>> {
        return FirebaseTokenHelper.instance
            .eToken
            .filterNil()
            .take(1)
            .flatMap { key -> Observable<(HTTPURLResponse, MessageDTO<PromotionList>)> in
                Requester.requestDTO(using: VatoAPIRouter.promotionList(authToken: key, coordinate: coordinate),
                    block: { $0.dateDecodingStrategy = .customDateFireBase })
        }.observeOn(SerialDispatchQueueScheduler(qos: .default))
            .map {
                let data = $0.1
                guard data.status == 200 else {
                    throw NSError(domain: NSURLErrorDomain, code: data.status, userInfo: [NSLocalizedDescriptionKey: data.errorCode ?? ""])
                }
                return data
        }
    }
    
    func requestPromotionData(from code: String) -> Observable<PromotionData> {
        return FirebaseTokenHelper.instance
            .eToken
            .filterNil()
            .take(1)
            .flatMap { key -> Observable<(HTTPURLResponse, PromotionData)> in
                Requester.requestDTO(using: VatoAPIRouter.promotion(authToken: key, code: code), method: .post, encoding: JSONEncoding.default, block: { $0.dateDecodingStrategy = .customDateFireBase })
            }.map {
                let data = $0.1
                guard data.status == 200 else {
                    let m = data.errorCode?.components(separatedBy: ".").last ?? ""
                    let message: String
                    switch m {
                    case "MasterCodeDayExceedException", "TodayExceedException", "UserCodeExceedTodayException":
                        message = PromotionConfig.promotionExceedDay
                    default:
                        message = PromotionConfig.promotionApplyForAllError
                    }
                    
                    throw NSError(domain: NSURLErrorDomain, code: data.status, userInfo: [NSLocalizedDescriptionKey: message])
                }
                return data
        }
    }
    
    
    func fillter(listDefault arr: [PromotionDisplayProtocol]?, filterBy service: ServiceCanUseProtocol?) -> [PromotionDisplayProtocol]? {
        let s = service
        let result = arr?.filter({ item -> Bool in
            guard let sU = s else {
                return true
            }
            let valid = item.predicate?.serviceCanUse()
            let c = sU.service
            let canUse = valid?.contains(c.serviceType) == true
            return canUse
        })
        
        return result
    }
}

