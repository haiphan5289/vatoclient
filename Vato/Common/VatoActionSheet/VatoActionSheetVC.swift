//  File name   : VatoActionSheetVC.swift
//
//  Author      : Dung Vu
//  Created date: 7/23/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import FwiCore

enum VatoActionSheetCellType {
    case `class`
    case nib
}

class VatoActionSheetVC<C: UITableViewCell>: UIViewController, UITableViewDelegate where C: UpdateDisplayProtocol, C.Value: Equatable {
    /// Class's public properties.
    typealias D = C.Value
    typealias Cell = C
    
    private (set) lazy var tableView = UITableView(frame: .zero, style: .plain)
    private lazy var lblTitle: UILabel = UILabel(frame: .zero)
    private lazy var btnClose: UIButton = UIButton(frame: .zero)
    private (set) lazy var mContainerView: UIView = {
        let v = HeaderCornerView(with: 8)
        v.containerColor = .white
        return v
    }()
    internal let source: Observable<[D]>
    private let currentSelect: Observable<D>
    @VariableReplay internal var mSource: [D] = []
    @Published internal var selected: D?
    internal lazy var disposeBag = DisposeBag()
    private let type: VatoActionSheetCellType
    private let heightCell: CGFloat
    private let mTitle: String?
    
    // MARK: Constructor
    required init(from source: Observable<[D]>, currentSelect: Observable<D>,
         type: VatoActionSheetCellType,
         heightCell: CGFloat,
         title: String?)
    {
        self.currentSelect = currentSelect
        self.source = source
        self.type = type
        self.mTitle = title
        self.heightCell = heightCell
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    /// Class's private properties.
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first else {
            return
        }

        let p = point.location(in: self.view)
        guard self.mContainerView.frame.contains(p) == false else {
            return
        }
        selected = nil
    }
    
    internal func selectDefaultRow() {
        Observable.combineLatest($mSource, currentSelect, resultSelector: { ($0, $1) }).bind(onNext: weakify({ (items, wSelf) in
            guard let idx = items.0.index(of: items.1) else {
                return
            }
            wSelf.tableView.selectRow(at: IndexPath(item: idx, section: 0), animated: false, scrollPosition: .none)
        })).disposed(by: disposeBag)
    }
    
    // MARK: -- Setup Display
    func visualize() {
        switch type {
        case .class:
            tableView.register(C.self, forCellReuseIdentifier: C.identifier)
        case .nib:
            tableView.register(C.nib, forCellReuseIdentifier: C.identifier)
        }
        
        self.view.backgroundColor = Color.black40
        tableView.separatorStyle = .none
        tableView.rowHeight = heightCell
        tableView.estimatedRowHeight = 100
        tableView.separatorColor = .clear
        
        mContainerView >>> view >>> {
            $0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
        
        lblTitle >>> mContainerView >>> {
            $0.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            $0.text = mTitle
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(24)
                make.centerX.equalToSuperview()
            }
        }
        
        btnClose >>> mContainerView >>> {
            $0.setImage(UIImage(named: "ic_close"), for: .normal)
            $0.snp.makeConstraints { (make) in
                make.top.right.equalToSuperview()
                make.size.equalTo(CGSize(width: 56, height: 44))
            }
        }
        
        tableView >>> mContainerView >>> {
            $0.snp.makeConstraints { (make) in
                make.left.right.bottom.equalToSuperview()
                make.top.equalTo(lblTitle.snp.bottom).offset(17)
            }
        }
        
        mContainerView.transform = CGAffineTransform(translationX: 0, y: 1500)
    }
    
    // MARK: -- Setup Event Handler
    func setupRX() {
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        source.bind(to: $mSource).disposed(by: disposeBag)
        btnClose.rx.tap.bind(onNext: weakify({ (wSelf) in
            wSelf.selected = nil
        })).disposed(by: disposeBag)
        
        setupDisplayCell()
        
        $mSource.filter { !$0.isEmpty }.delay(.milliseconds(200), scheduler: MainScheduler.asyncInstance).bind(onNext: weakify({ (_, wSelf) in
            let r = wSelf.tableView.rectForFooter(inSection: 0)
            let n = wSelf.tableView.convert(r, to: wSelf.mContainerView)
            let y = UIScreen.main.bounds.height - n.minY - 80
            let transform: CGAffineTransform = y > 0 ? CGAffineTransform(translationX: 0, y: y ) : .identity
            UIView.animate(withDuration: 0.1) {
                wSelf.mContainerView.transform = transform
            }
            wSelf.selectDefaultRow()
        })).disposed(by: disposeBag)
        setupEventSelect()
    }
    
    private func setupDisplayCell() {
        $mSource.bind(to: tableView.rx.items(cellIdentifier: C.identifier, cellType: C.self)) { [unowned self] idx, element, cell in
            self.updateDisplay(index: idx, element: element, cell: cell)
        }.disposed(by: disposeBag)
    }
    
    func updateDisplay(index: Int, element: D, cell: C) {
        cell.setupDisplay(item: element)
    }

    func setupEventSelect() {
        tableView.rx.itemSelected.flatMap { [weak self](index) -> Observable<D?> in
            guard let wSelf = self else { return Observable.empty() }
            return wSelf.source.take(1).map { (list) -> D? in
                let item = list[safe: index.item]
                return item
            }
        }
        .filterNil()
        .bind(to: $selected)
        .disposed(by: disposeBag)
    }
    
    // MARK: -- Table Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightCell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {}
    
    // MARK: -- Display
    static func showUse(source: Observable<[D]>,
                        on controller: UIViewController?,
                        currentSelect: Observable<D>,
                        type: VatoActionSheetCellType = .class,
                        heightCell: CGFloat = UITableView.automaticDimension,
                        title: String? = nil) -> Observable<D?>
    {
        return Observable.create { (s) -> Disposable in
            let selectVC = self.init(from: source, currentSelect: currentSelect, type: type, heightCell: heightCell, title: title)
            selectVC.modalPresentationStyle = .overCurrentContext
            selectVC.modalTransitionStyle = .crossDissolve
            let disposable = selectVC.$selected.take(1).subscribe(s)
            controller?.present(selectVC, animated: true, completion: nil)
            return Disposables.create {
                selectVC.dismiss(animated: true, completion: nil)
                disposable.dispose()
            }
        }
    }
}



