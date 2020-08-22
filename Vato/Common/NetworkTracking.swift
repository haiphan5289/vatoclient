//  File name   : NetworkTracking.swift
//
//  Author      : Dung Vu
//  Created date: 1/24/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import RxSwift

final class NetworkTracking {
    var reachable: Observable<Bool> {
        return _reachable.asObserver()
    }
    private let defaultReachabilityService: DefaultReachabilityService
    fileprivate lazy var _reachable = ReplaySubject<Bool>.create(bufferSize: 1)
    private lazy var disposeBag = DisposeBag()
    
    init() throws {
        defaultReachabilityService = try DefaultReachabilityService()
        setupRX()
    }
    
    func setupRX() {
        let reachability = defaultReachabilityService.reachability.map { $0.reachable }
            .buffer(timeSpan: .milliseconds(150), count: 2, scheduler: MainScheduler.instance)
            .filter { $0.count > 0}.map{ $0.last }
            .filterNil()
        
        reachability.bind(to: self._reachable).disposed(by: disposeBag)
    }
    
    deinit {
        printDebug("\(#function)")
    }
}

protocol NetworkTrackingProtocol {
    var networkTracking: NetworkTracking? { get set }
}
fileprivate struct NetworkTrackingInformation {
    static var name = "NetworkTrackingInformation"
}

extension NetworkTrackingProtocol {
    fileprivate func createNetworkTracking() -> NetworkTracking? {
        do {
            return try NetworkTracking()
        } catch {
            printDebug(error)
            return nil
        }
    }
    
    var networkTracking: NetworkTracking? {
        get {
            guard let r = objc_getAssociatedObject(self, &NetworkTrackingInformation.name) as? NetworkTracking else {
                let new = self.createNetworkTracking()
                objc_setAssociatedObject(self, &NetworkTrackingInformation.name, new, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return new
            }
            return r
        }
        
        set {
            objc_setAssociatedObject(self, &NetworkTrackingInformation.name, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

