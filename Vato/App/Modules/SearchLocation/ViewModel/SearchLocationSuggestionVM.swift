//  File name   : SearchLocationSuggestionVM.swift
//
//  Author      : Vato
//  Created date: 9/19/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import FwiCore
import FwiCoreRX
import RxSwift
import UIKit
import VatoNetwork

final class SearchLocationSuggestionVM: GenericTableViewCellVM<SearchLocationSuggestionCVC, MapModel.Place> {
    
    /// Class's public properties.
   var cellPress: ((MapModel.Place) -> Void)?
    var itemSubject = PublishSubject<MapModel.Place>()
    override func setupRX() {
        super.setupRX()
    }
    
    // MARK: Class's public override methods
    override func configure(forCell cell: SearchLocationSuggestionCVC, with item: MapModel.Place) {
        cell.addButton?.rx.tap
            .takeUntil(cell.rx.methodInvoked(#selector(UITableViewCell.prepareForReuse)))
            .subscribe(onNext: { [weak self] in
                self?.itemSubject.onNext(item)
            })
            .disposed(by: disposeBag)
        
        cell.titleLabel?.text = item.primaryName
        cell.subtitleLabel?.text = item.address
        
        
    }

    /// Class's private properties.
}

// MARK: Class's public methods
extension SearchLocationSuggestionVM {
    func reset() {
        items?.removeAll()

        if Thread.current.isMainThread {
            tableView?.reloadData()
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.tableView?.reloadData()
            }
        }
    }

    func update(newItems items: [MapModel.Place]) {
        self.items = ArraySlice<MapModel.Place>(items)
        tableView?.reloadData()
    }
}
