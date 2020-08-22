//
//  BookingConfirmView+ListSeverice.swift
//  Vato
//
//  Created by vato. on 11/15/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation
import RxSwift

// BookingConfirmView+ListSeverice

extension BookingConfirmView {
    
    func registerCellSevice() {
        let nib = UINib(nibName: "ServiceNewCell", bundle: nil)
        self.listSevericeTableView?.register(nib, forCellReuseIdentifier: ServiceNewCell.identifier)
    }
    
    func setupRXListService() {
        guard let listSevericeTableView = listSevericeTableView else { return }
        self.listServiceSubject.asObservable()
            .bind(to: listSevericeTableView.rx.items(cellIdentifier: ServiceNewCell.identifier, cellType: ServiceNewCell.self)) { [weak self] (row, element, cell) in
                cell.updateData(model: element, modelPromotion: self?.promotion, currentBook: self?.booking)
            }.disposed(by: disposeBag)
        
        self.heightOfViewSuggestService?.constant = 0
        self.listServiceSubject.asObservable()
            .subscribe(onNext: { [weak self] (listData) in
                self?.heightOfViewSuggestService?.constant = CGFloat(min(listData.count, Config.numberCellDisplay)) * CGFloat(Config.heightOfCellSuggest)
                self?.layoutIfNeeded()
            }).disposed(by: disposeBag)
        
        self.listSevericeTableView?.rx.itemSelected.bind { [weak self] index in
            if let model = self?.listServiceSubject.value[safe: index.row] {
                self?.eSelectedService.onNext(model)
            }
            }.disposed(by: disposeBag)
    }
    
    func reloadCellsVisible() {
        self.listSevericeTableView?
            .visibleCells
            .compactMap { $0 as? ServiceNewCell }
            .forEach({ [weak self] (cell) in
                guard let indexPath = self?.listSevericeTableView?.indexPath(for: cell),
                    let model = listServiceSubject.value[safe: indexPath.row] else { return }
                cell.updateData(model: model, modelPromotion: self?.promotion, currentBook: self?.booking)
            })
    }
    
    func didSelect(service: ServiceCanUseProtocol?) {
        guard let service = service else { return }
        if let index = listServiceSubject.value.firstIndex(where: { $0.service.id == service.service.id }) {
            self.listSevericeTableView?.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .none)
        }
    }
}
