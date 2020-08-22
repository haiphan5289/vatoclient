//  File name   : PromotionSearchView.swift
//
//  Author      : Dung Vu
//  Created date: 10/23/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import RxSwift
import RxCocoa
import FwiCore

enum PromotionCommand {
    case detailSearch(obj: PromotionDisplayProtocol?)
    case actionSearch(obj: PromotionDisplayProtocol?)
    
    case detailList(index: IndexPath)
    case actionList(index: IndexPath)
    
    // Add for pull to refresh
    case reload
    // Use for next page
    case updateData
    
    case applyPromotion
}

final class PromotionSearchView: UIView {
    /// Class's public properties.
    let tableView: UITableView
    private(set) lazy var eSelect = PublishSubject<PromotionCommand>()
    private lazy var disposeBag: DisposeBag! = DisposeBag()
    private let eSource: Observable<ListPromotion>
    private let eSourceUpdateCommand: Observable<PromotionDataSearchCommand>
    private var mSource = ListPromotion()
    
    private lazy var lblDescription: UIView = {
       return self.createViewDescription()
    }()
    
    /// Class's private properties.
    init(using eSource: Observable<ListPromotion>,
         eSourceUpdateCommand: Observable<PromotionDataSearchCommand>)
    {
        self.tableView = UITableView(frame: .zero, style: .plain)
        self.eSource = eSource
        self.eSourceUpdateCommand = eSourceUpdateCommand
        super.init(frame: .zero)
        self.common()
    }
    
    private func createViewDescription() -> UIView {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.text = PromotionConfig.searchNotFound
        label.textColor = #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1)
        label.numberOfLines = 0
        label.textAlignment = .center
        let s = label.sizeThatFits(CGSize(width: 240, height: CGFloat.greatestFiniteMagnitude))
        label.frame = CGRect(origin: .zero, size: CGSize(width: s.width, height: s.height + 10))
        
        let container = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: label.frame.height + 15))
        label >>> container >>> {
            $0.snp.makeConstraints({ (make) in
                make.centerX.equalToSuperview()
                make.top.equalTo(15)
                make.bottom.equalToSuperview()
                make.size.equalTo(label.frame.size)
            })
        }
        
        
        return container
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func removeFromSuperview() {
        disposeBag = nil
        super.removeFromSuperview()
    }
    
    deinit {
        printDebug("\(#function)")
    }
}

// MARK: Class's public methods
extension PromotionSearchView {
    override func layoutSubviews() {
        super.layoutSubviews()
        visualize()
    }
}

// MARK: Class's private methods
private extension PromotionSearchView {
    private func common() {
        self.tableView >>> self >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        self.tableView.separatorStyle = .none
        self.tableView.rowHeight = 144
        self.registerCell()
        self.tableView.backgroundColor = .clear
        self.backgroundColor = #colorLiteral(red: 0.8980392157, green: 0.8980392157, blue: 0.8980392157, alpha: 1)
        setupRX()
    }
    
    private func setupRX() {
        self.tableView.rx.setDataSource(self).disposed(by: disposeBag)
        
        // Use for need use old data
//        self.eSource.take(1).bind { [weak self](new) in
//           self?.mSource = new
//           self?.tableView.reloadData()
//        }.disposed(by: disposeBag)
        
        self.tableView.rx.itemSelected
            .map({[weak self] in PromotionCommand.detailSearch(obj: self?.mSource[safe: $0.item] ) })
            .bind(to: self.eSelect)
            .disposed(by: disposeBag)
        
        self.eSourceUpdateCommand
            .bind
        { [weak self](command) in
            guard let wSelf = self else {
                return
            }
            
            switch command {
            case .new(let list):
                wSelf.mSource = list
                wSelf.tableView.reloadData()
                wSelf.tableView.tableHeaderView = nil
                if list.count == 0 {
                    self?.tableView.tableHeaderView = wSelf.lblDescription
                }
                
            case .update(let list):
                let lastIndex = wSelf.mSource.count
                let next = lastIndex + list.count
                wSelf.mSource += list
                let indexs = (lastIndex..<next).map{ IndexPath(item: $0, section: 0) }
                wSelf.tableView.beginUpdates()
                
                defer { wSelf.tableView.endUpdates() }
                
                wSelf.tableView.insertRows(at: indexs, with: .none)
            case .error(let e):
                printDebug(e.localizedDescription)
                wSelf.mSource = []
                wSelf.tableView.reloadData()
                wSelf.tableView.tableHeaderView = nil
                wSelf.tableView.tableHeaderView = wSelf.lblDescription
            case .errorUpdate(let e):
                // Not define for this case yet
                printDebug(e.localizedDescription)
            case .reset:
                wSelf.mSource = []
                wSelf.tableView.reloadData()
                wSelf.tableView.tableHeaderView = nil
            }
        }.disposed(by: disposeBag)
    }
    
    private func initialize() {
        // todo: Initialize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
    }
    
    private func registerCell() {
        self.tableView.register(PromotionTableViewCell.nib, forCellReuseIdentifier: PromotionTableViewCell.identifier)
    }
}

extension PromotionSearchView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = PromotionTableViewCell.dequeueCell(tableView: tableView)
        cell.setup(from: mSource[indexPath.item])
        cell.btnAction?.rx
            .tap
            .takeUntil(cell.rx.methodInvoked(#selector(UITableViewCell.prepareForReuse))).bind { [weak self] in
            self?.eSelect.onNext(.actionSearch(obj: self?.mSource[safe: indexPath.item]))
        }.disposed(by: disposeBag)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mSource.count
    }
}

