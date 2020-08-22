
//
//  MerchantStream.swift
//  Vato
//
//  Created by khoi tran on 10/21/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation
import RxSwift


typealias ListMerchant = [MerchantInfoDisplayProtocol]

protocol MerchantDataStream {
    var listMerchant: Observable<[Merchant]> { get }
    var listMerchantCategory: Observable<[MerchantCategory]> { get }
    var currentSelectedMerchant: Merchant? { get }
    var currentSelectedMerchantObservable: Observable<Merchant?> { get }

    var currentSelectedStore: Store? { get }
    var storeCommand: StoreCommand? { get }
    
}

protocol MutableMerchantDataStream: MerchantDataStream {
    func updateListMerchantCategory(listMerchantCategory: [MerchantCategory])
    func updateCurrentSelectedStore(s: Store?)
    func updateStoreCommnand(s: StoreCommand?)
}


final class MerchantDataStreamImpl {
    private var subjectListMerchantCategory = ReplaySubject<[MerchantCategory]>.create(bufferSize: 1)
    private var subjectListMerchant = ReplaySubject<[Merchant]>.create(bufferSize: 1)
    private var subjectCurrentSelectedMerchant = ReplaySubject<Merchant?>.create(bufferSize: 1)
    
    private(set) var _currentSelectedMerchant: Merchant?
    private(set) var _currentSelectedStore: Store?
    private(set) var _storeCommand: StoreCommand?
}

extension MerchantDataStreamImpl: MutableMerchantDataStream {
    var storeCommand: StoreCommand? {
        return _storeCommand
    }
    
    var currentSelectedMerchant: Merchant? {
        return _currentSelectedMerchant
    }
    
    
    var currentSelectedMerchantObservable: Observable<Merchant?>  {
        return subjectCurrentSelectedMerchant.asObservable()
    }

    var currentSelectedStore: Store? {
        return _currentSelectedStore
    }
    
    
    func updateSelectedMerchant( merchant: Merchant? ) {
        subjectCurrentSelectedMerchant.onNext(merchant)
        _currentSelectedMerchant = merchant
        
    }    
    
    var listMerchant: Observable<[Merchant]> {
        return subjectListMerchant.asObserver()
    }
    
    var listMerchantCategory: Observable<[MerchantCategory]> {
        return subjectListMerchantCategory.asObserver()
    }
    
    func updateListMerchantCategory(listMerchantCategory: [MerchantCategory]) {
        subjectListMerchantCategory.onNext(listMerchantCategory)
    }
    
    
    func updateListMerchant(listMerchant: [Merchant]) {
        subjectListMerchant.onNext(listMerchant)
    }
    
    func updateCurrentSelectedStore(s: Store?) {
        _currentSelectedStore = s
    }
    
    func updateStoreCommnand(s: StoreCommand?) {
        _storeCommand = s
    }
}



