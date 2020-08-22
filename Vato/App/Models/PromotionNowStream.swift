//  File name   : PromotionNowStream.swift
//
//  Author      : Vato
//  Created date: 10/29/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import RxSwift

// MARK: Immutable stream
protocol PromotionNowStream: class {
    var isDisplayed: Observable<Bool> { get }
    var allManifests: Observable<[PromotionList.Manifest]> { get }
    var allPredicates: Observable<[PromotionList.ManifestPredicate]> { get }
}

// MARK: Mutable stream
protocol MutableDisplayPromotionNowStream: PromotionNowStream {
    func update(displayed: Bool)
}

protocol MutablePromotionNowStream: MutableDisplayPromotionNowStream {
    func update(newManifests: [PromotionList.Manifest])
    func update(newManifestPredicates: [PromotionList.ManifestPredicate])
}

// MARK: Default stream implementation
final class PromotionNowStreamImpl: MutablePromotionNowStream {
    /// Class's public properties.
    var isDisplayed: Observable<Bool> {
        return isDisplayedSubject.asObservable()
    }
    var allManifests: Observable<[PromotionList.Manifest]> {
        return manifestsSubject.asObservable()
    }
    var allPredicates: Observable<[PromotionList.ManifestPredicate]> {
        return predicatesSubject.asObservable()
    }

    // MARK: Class's public methods
    func update(displayed: Bool) {
        isDisplayedSubject.onNext(displayed)
    }
    
    func update(newManifests: [PromotionList.Manifest]) {
        guard newManifests.count > 0 else {
            return
        }
        manifestsSubject.on(.next(newManifests))
    }

    func update(newManifestPredicates: [PromotionList.ManifestPredicate]) {
        guard newManifestPredicates.count > 0 else {
            return
        }
        predicatesSubject.on(.next(newManifestPredicates))
    }

    /// Class's private properties.
    private let isDisplayedSubject = ReplaySubject<Bool>.create(bufferSize: 1)
    private let manifestsSubject = ReplaySubject<[PromotionList.Manifest]>.create(bufferSize: 1)
    private let predicatesSubject = ReplaySubject<[PromotionList.ManifestPredicate]>.create(bufferSize: 1)
}
