//  File name   : PromotionStream.swift
//
//  Author      : Dung Vu
//  Created date: 10/22/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import RxSwift
import RxCocoa

enum ResponseResult<T> {
    case success(items: T)
    case fail(error: Error)
}

enum PromotionDataSearchCommand {
    case new(list: ListPromotion)
    case update(list: ListPromotion)
    case error(e: Error)
    case errorUpdate(e: Error)
    case reset
}


typealias ListPromotion = [PromotionDisplayProtocol]

// MARK: - Current data
protocol PromotionDataStream {
    var currentSelect: PromotionDisplayProtocol? { get }
    var listDefault: Observable<ListPromotion> { get }
    var eListError: Observable<Error> { get}
}

protocol MutablePromotionDataStream: PromotionDataStream {
    func resetListSearchDefault()
    func update(listDefault result: ResponseResult<PromotionList>, filterBy service: ServiceCanUseProtocol?)
    func update(select obj: PromotionDisplayProtocol)
}

// MARK: - Search
protocol PromotionSearchStream {
    var listSearch: Observable<ListPromotion> { get }
    var eSearchCommand: Observable<PromotionDataSearchCommand> { get }
}

protocol MutablePromotionSearchStream: PromotionSearchStream {
    func resetListSearch()
    func new(listSearch result: ResponseResult<ListPromotion>)
    func update(listSearch result: ResponseResult<ListPromotion>)
}

// MARK: - Detail
protocol PromotionDetailStream {}

// MARK: - Main
final class PromotionStreamImpl {
    private lazy var searchDefault: Variable<ListPromotion> = Variable([])
    private lazy var search: Variable<ListPromotion> = Variable([])
    private lazy var searchCommand = PublishSubject<PromotionDataSearchCommand>()
    private lazy var mErrorList = PublishSubject<Error>()
    private(set) var currentSelect: PromotionDisplayProtocol?
}

extension PromotionStreamImpl: MutablePromotionDataStream {
    var eListError: Observable<Error> {
        return mErrorList
    }
    
    var listDefault: Observable<ListPromotion> {
        return searchDefault.asObservable()
    }
    
    func resetListSearchDefault() {
        searchDefault.value = []
    }

    func update(select obj: PromotionDisplayProtocol) {
        currentSelect = obj
    }
    
    func update(listDefault result: ResponseResult<PromotionList>, filterBy service: ServiceCanUseProtocol?) {
        switch result {
        case .success(let item):
            let s = service
            let next = item.listDisplay().filter({ item -> Bool in
                guard let sU = s else {
                    return true
                }
                let valid = item.predicate?.serviceCanUse()
                let c = sU.service
                let canUse = valid?.contains(c.serviceType) == true
                return canUse
            })
            searchDefault.value = next
        case .fail(let error):
            printDebug(error.localizedDescription)
            mErrorList.onNext(error)
            resetListSearchDefault()
        }
    }
}

extension PromotionStreamImpl: MutablePromotionSearchStream {
    var eSearchCommand: Observable<PromotionDataSearchCommand> {
        return searchCommand
    }
    
    var listSearch: Observable<ListPromotion> {
        return search.asObservable()
    }
    
    func resetListSearch() {
        search.value = []
        searchCommand.onNext(.reset)
    }
    
    func update(listSearch result: ResponseResult<ListPromotion>) {
        switch result {
        case .success(let items):
            search.value += items
            searchCommand.onNext(.update(list: items))
        case .fail(let error):
            printDebug(error.localizedDescription)
            searchCommand.onNext(.errorUpdate(e: error))
        }
    }
    
    func new(listSearch result: ResponseResult<ListPromotion>) {
        switch result {
        case .success(let items):
            search.value = items
            searchCommand.onNext(.new(list: items))
        case .fail(let error):
            searchCommand.onNext(.error(e: error))
            printDebug(error.localizedDescription)
        }
    }
}
