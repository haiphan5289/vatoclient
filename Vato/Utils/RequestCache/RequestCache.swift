//  File name   : RequestCache.swift
//
//  Author      : Dung Vu
//  Created date: 10/10/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import VatoNetwork
import RxSwift
import RxCocoa
import Alamofire

final class VatoCacheRequest: SafeAccessProtocol {
    private (set) lazy var lock: NSRecursiveLock = NSRecursiveLock()
    
    struct Config {
        static let expire: TimeInterval = 600
    }
    
    struct VatoCacheItem {
        let response: Any
        let created_at: Date
        let timeCache: TimeInterval
    }
    
    static let shared = VatoCacheRequest()
    private var cache: [String: VatoCacheItem] = [:]
    private lazy var disposeBag = DisposeBag()
    init() {
        setupRX()
    }
    
    private func setupRX() {
        NotificationCenter.default.rx.notification(UIApplication.didReceiveMemoryWarningNotification).bind { [weak self](_) in
            guard let wSelf = self else { return }
            wSelf.excute(block: { wSelf.cache.removeAll() })
        }.disposed(by: disposeBag)
    }
    
    func cache(response: Any, router: APIRequestProtocol, timeCache: TimeInterval) {
        let key = router.path + (router.params?.compactMap { "\($0.key)_\($0.value)" }.joined() ?? "")
        let item = VatoCacheItem(response: response, created_at: Date(), timeCache: timeCache)
        excute(block: { cache[key] = item })
        
    }
    
    func load<T>(for type: T.Type, router: APIRequestProtocol) -> T? {
        let key = router.path + (router.params?.compactMap { "\($0.key)_\($0.value)" }.joined() ?? "")
        guard let item = excute(block: { cache[key] }), abs(item.created_at.timeIntervalSinceNow) < item.timeCache else {
            return nil
        }
        return item.response as? T
    }
}


extension Requester {
    static func responseCacheDTO<E>(decodeTo type: E.Type,
                                    using router: APIRequestProtocol,
                                    method m: HTTPMethod = .get,
                                    encoding e: ParameterEncoding = URLEncoding.default,
                                    progress: ProgressHandler? = nil,
                                    block: ((JSONDecoder) -> Void)? = nil,
                                    timeCache: TimeInterval = VatoCacheRequest.Config.expire) -> Observable<VatoNetwork.Response<E>> where E : Decodable {
        // Only cache get
        guard m == .get else {
            return self.responseDTO(decodeTo: type, using: router, method: m, encoding: e, progress: progress, block: block)
        }
        
        guard let cache = VatoCacheRequest.shared.load(for: VatoNetwork.Response<E>.self, router: router) else {
            return self.responseDTO(decodeTo: type, using: router, method: m, encoding: e, progress: progress, block: block).do(onNext: { (res) in
                // Cache
                VatoCacheRequest.shared.cache(response: res, router: router, timeCache: timeCache)
            })
        }
        
        return Observable.just(cache)
    }
}
 

