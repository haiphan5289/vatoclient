//  File name   : VatoMainVC+Actions.swift
//
//  Author      : Dung Vu
//  Created date: 8/13/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import RxSwift
import FwiCore

enum HomeActionSpecificService: Equatable, CustomStringConvertible {
    case location(service: VatoServiceType, coor: Coordinate?)
    case categoryEcom(cat: ServiceCategoryType, store: ServiceCategoryAction?)
    
    var description: String {
        switch self {
        case .location(_ , let coor):
            return coor == nil ? FwiLocale.localized("Tôi muốn đặt xe") : FwiLocale.localized("Tôi muốn đi đến đây")
        case .categoryEcom(_ , let store):
            return store == nil ? FwiLocale.localized("Tôi muốn xem thông tin dịch vụ này") : FwiLocale.localized("Tôi muốn mua hàng ở cửa hàng này")
        }
    }
    
}

extension HomeActionSpecificService {
    static func ==(lhs: HomeActionSpecificService, rhs: HomeActionSpecificService) -> Bool {
        switch (lhs, rhs) {
        case (.location(let s1, let c1), .location(let s2, let c2)):
            return s1 == s2 && c1 == c2
        case (.categoryEcom(let cat1, let store1), .categoryEcom(let cat2, let store2)):
            return cat1 == cat2 && store1 == store2
        default:
            return false
        }
    }
}

protocol ItemDescriptionProtocol: Equatable, CustomStringConvertible {
    var color: UIColor? { get }
}

fileprivate struct HomeItemService: ItemDescriptionProtocol {
    var idx: Int
    var item: HomeActionSpecificService
    
    var description: String {
        return item.description
    }
    
    var color: UIColor? {
       return idx.isMultiple(of: 2) ? #colorLiteral(red: 0.9921568627, green: 0.9294117647, blue: 0.9098039216, alpha: 1) : .white
    }
}

extension HomeActionSpecificService {
    fileprivate static func findingActions(action: VatoHomeLandingItem.Action) -> [HomeItemService] {
        var result = [HomeItemService]()
        guard let data = action.data else {
            return []
        }
        var idx: Int = 0
        if let sId = data.service_ids?.first, let s = VatoServiceType(rawValue: sId) {
            let i = HomeItemService(idx: idx, item: .location(service: s, coor: action.coordinate))
            result.append(i)
        }
        
        if let categoryId = data.category_id, let ecom = ServiceCategoryType.loadEcom(category: categoryId) {
            idx += 1
            var actionEcom: ServiceCategoryAction?
            if let storeId = data.store_id {
                actionEcom = ServiceCategoryAction.storeId(id: storeId)
            }
            let i = HomeItemService(idx: idx, item: .categoryEcom(cat: ecom, store: actionEcom))
            result.append(i)
        }
        
        return result
    }
}

// MARK: -- TableView Cell
final class BaseMenuTVC<T: ItemDescriptionProtocol>: UITableViewCell, UpdateDisplayProtocol {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        visualize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupDisplay(item: T?) {
        textLabel?.text = item?.description
        contentView.backgroundColor = item?.color
    }

    private func visualize() {
        contentView.addSeperator(with: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0))
    }
}
// MARK: Show Options
extension VatoMainVC {
    private func showOptions(in action: VatoHomeLandingItem.Action, title: String?) -> Observable<HomeActionSpecificService> {
        let items = HomeActionSpecificService.findingActions(action: action)
        guard !items.isEmpty else {
            return Observable.empty()
        }
        
        if items.count == 1 {
            return Observable.just(items[0].item)
        } else {
           return VatoActionSheetVC<BaseMenuTVC<HomeItemService>>.showUse(source: Observable.just(items),
                                                                                    on: self,
                                                                                    currentSelect: Observable.empty(),
                                                                                    title: title)
            .filterNil()
            .map { $0.item }
            .delay(.milliseconds(300), scheduler: MainScheduler.asyncInstance)
        }
    }
    
    private func routeToEcom(cat: ServiceCategoryType, store: ServiceCategoryAction?) {
        listener?.checkLocation().bind(onNext: weakify({ (wSelf) in
            wSelf.listener?.routeToServiceCategory(type: cat, action: store)
        })).disposed(by: disposeBag)
    }
    
    func findingService(from item: VatoHomeLandingItem) {
        let action = item.action
        showOptions(in: action, title: item.title).bind(onNext: weakify({ (type, wSelf) in
            switch type {
            case .location(let s, let coor):
                if let coordinate = coor {
                    wSelf.listener?.lookingForDestination(service: s, coordinate: coordinate)
                } else {
                    wSelf.listener?.routeToBooking(data: .service(s: s))
                }
            case .categoryEcom(let cat, let store):
                wSelf.routeToEcom(cat: cat, store: store)
            }
        })).disposed(by: disposeBag)
    }
    
}
