//  File name   : BannerManager.swift
//
//  Author      : Dung Vu
//  Created date: 11/20/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import RxSwift
import RxCocoa
import FirebaseFirestore

protocol BannerProtocol: ImageDisplayProtocol {
    var url: URL? { get }
}

fileprivate struct BannerItem: Codable, BannerProtocol {
    var id: Int?
    var imageURL: String?
    var url: URL?
    var cacheLocal: Bool { return false }
}

fileprivate struct BannerResponse: Codable {
    var values: [BannerItem]?
}

fileprivate struct BannerCacheItem {
    let values: [BannerProtocol]
    let timeExpire: Date
}

final class BannerManager {
    /// Class's public properties.
    struct Config {
        static let time: TimeInterval = 420
    }
    static let instance = BannerManager()
    private lazy var collectionRef = Firestore.firestore().collection(collection: .bannerConfig)
    private lazy var disposeBag = DisposeBag()
    private var cache: [Int: BannerCacheItem] = [:]
    
    func requestBanner(type service: Int) -> Observable<[BannerProtocol]>{
        if let old = cache[service],  abs(old.timeExpire.timeIntervalSinceNow) <= Config.time {
            return Observable.just(old.values)
        }
        
        let documentRef = collectionRef.document("\(service)")
        return documentRef.find(action: .get, json: nil)
            .filterNil()
            .map ({ (try? $0.decode(to: BannerResponse.self))?.values ?? []}).do(onNext: { [weak self](list) in
                self?.cache[service] = BannerCacheItem(values: list, timeExpire: Date())
            }).catchErrorJustReturn([])
    }
}

