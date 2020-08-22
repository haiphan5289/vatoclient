//  File name   : PromotionVC.swift
//
//  Author      : Dung Vu
//  Created date: 10/19/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import UIKit

import FwiCoreRX

protocol PromotionPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var eLoading: Observable<(Bool,Double)> {get}
    var eSource: PromotionDataStream { get }
    
    var command: PublishSubject<PromotionCommand> { get }
    
    func detachCurrentChild()
    func detachCurrentRoute()
    
    func promotionMoveBack()
    func routeToSearch()
    
    func loadData()
    func search(by keyword: String?)
}

final class PromotionVC: UIViewController, PromotionPresentable, LoadingAnimateProtocol, DisposableProtocol {
    /// Class's public properties.
    weak var listener: PromotionPresentableListener?
    @IBOutlet weak var btnBack: UIButton?
    @IBOutlet weak var mainView: UIView?
    @IBOutlet weak var lblTitle: UILabel?
    @IBOutlet weak var hHeaderConstraint: NSLayoutConstraint?
    private(set) lazy var disposeBag = DisposeBag()
    private lazy var noItemView = NoItemView(imageName: "n_promotion", message: PromotionConfig.noItemMessage, on: self.tableView)
    private lazy var refreshControl = UIRefreshControl(frame: .zero)
    @IBOutlet weak var searchView: UIView?
    @IBOutlet weak var headerView: UIView?
    @IBOutlet weak var bgSearchView: UIView?
    @IBOutlet weak var leftBGSearchView: NSLayoutConstraint?
    @IBOutlet weak var textField: UITextField?
    @IBOutlet weak var btnCancel: UIButton?
    @IBOutlet weak var tableView: UITableView?
    
    weak var containerView: UIView?
    
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
        self.listener?.loadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.textField?.resignFirstResponder()
    }

    /// Class's private properties.
    private(set) lazy var eSateSearch: Observable<Bool> = {
        let eBeginSearch = textField?.rx.controlEvent(UIControl.Event.editingDidBegin).map { _ in true }
        let eEndSearch = textField?.rx.controlEvent(UIControl.Event.editingDidEnd).map { _ in false }
        
        let eSate = Observable.merge([eBeginSearch, eEndSearch].compactMap{ $0 })
        return eSate
    }()
}

// MARK: Class's private methods
private extension PromotionVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        let edge = UIApplication.shared.keyWindow?.edgeSafe ?? .zero
        // Update
        if let constraint = hHeaderConstraint {
            constraint.constant += (edge.top > 0 ? edge.top : edge.top + 20)
        }
        
        self.tableView?.rowHeight = 144
        self.registerCell()
        self.lblTitle?.text = PromotionConfig.title
        
        searchView?.backgroundColor = Color.orange
        headerView?.backgroundColor = Color.orange
        UIApplication.setStatusBar(using: .lightContent)
        btnCancel?.setTitle(PromotionConfig.cancelText, for: .normal)
        btnCancel?.titleLabel?.adjustsFontSizeToFitWidth = true
        let att = PromotionConfig.placeHolderSearch.attribute >>> .color(c: UIColor.init(white: 1, alpha: 0.6))
        textField >>> {
            $0?.tintColor = .white
            $0?.attributedPlaceholder = att
        }
        
        let clearButton = textField?.value(forKey: "clearButton") as? UIButton
        clearButton?.tintColor = .white
        let imgClear = #imageLiteral(resourceName: "ic_delete")
        clearButton?.setImage(imgClear.withRenderingMode(.alwaysTemplate), for: .normal)
        
    }
    
    private func setupRX() {
        // todo: Bind data to UI here.
        self.btnBack?.rx.tap.bind { [weak self] in
            // Move back
            self?.listener?.promotionMoveBack()
        }.disposed(by: disposeBag)
        
        btnCancel?.rx.tap.bind { [weak self] in
            // detach search
            // 1. reset test
            self?.textField?.text = ""
            self?.textField?.sendActions(for: .valueChanged)
            
            // 2. resign
            self?.textField?.resignFirstResponder()
            self?.listener?.detachCurrentChild()
            }.disposed(by: disposeBag)
        
        eSateSearch.bind { [weak self] b in
            UIView.animate(withDuration: 0.3, animations: {
                self?.leftBGSearchView?.constant = b ? 55 : 16
                self?.bgSearchView?.layoutIfNeeded()
            })
            self?.btnCancel?.isHidden = !b
            }.disposed(by: disposeBag)
        
        eSateSearch.filter{ $0 }.bind { [weak self](_) in
            self?.listener?.routeToSearch()
        }.disposed(by: disposeBag)
        
        self.setupKeyboardAnimation()
        self.listener?.eLoading.asObservable().observeOn(MainScheduler.asyncInstance).subscribe(onNext: { [weak self](loading, percent) in
            let block = loading ? {
            } : {
                self?.refreshControl.endRefreshing()
            }
            block()
            self?.mainView?.isUserInteractionEnabled = !loading
        }).disposed(by: disposeBag)
        
        showLoading(use: self.listener?.eLoading)
        
        self.textField?.rx.text
            .asObservable()
            .throttle(0.3, latest: true, scheduler: MainScheduler.instance)
            .bind { [weak self] text in
            self?.listener?.search(by: text)
        }.disposed(by: disposeBag)
        
        guard let tableView = self.tableView, let listener = self.listener else {
            assert(false, "Recheck this")
            return
        }
        
        tableView.addSubview(self.refreshControl)
        self.refreshControl.rx.controlEvent(UIControl.Event.valueChanged).bind { [weak self] in
            self?.refreshControl.beginRefreshing()
            self?.listener?.loadData()
        }.disposed(by: disposeBag)
        
        self.listener?.eSource.listDefault.bind(to: tableView.rx.items(cellIdentifier: PromotionTableViewCell.identifier, cellType: PromotionTableViewCell.self)) { [weak self](row, element, cell) in
                cell.setup(from: element)
                self?.setupActionBook(at: row, for: cell)
            }
        .disposed(by: disposeBag)
        
        self.listener?.eSource.eListError.observeOn(MainScheduler.instance).subscribe(onNext: { [weak self](e) in
            self?.noItemView.attach()
        }).disposed(by: disposeBag)
        
        self.listener?.eSource.listDefault.map { $0.count > 0 }.skip(1).subscribe(onNext: { [weak self](v) in
            v ? self?.noItemView.detach() : self?.noItemView.attach()
        }).disposed(by: disposeBag)
        
        
        tableView.rx.itemSelected
            .map { PromotionCommand.detailList(index: $0) }
            .bind(to: listener.command)
            .disposed(by: disposeBag)
    }
    
    private func setupActionBook(at row: Int, for cell: PromotionTableViewCell) {
        cell.btnAction?.rx.tap
            .takeUntil(cell.rx.methodInvoked(#selector(UITableViewCell.prepareForReuse)))
            .map { PromotionCommand.actionList(index: IndexPath(item: row, section: 0)) }.subscribe(onNext: { [weak self] in
                self?.listener?.command.onNext($0)
            })
            .disposed(by: disposeBag)
    }
    
    private func registerCell() {
        self.tableView?.register(PromotionTableViewCell.nib, forCellReuseIdentifier: PromotionTableViewCell.identifier)
    }
}

// MARK: Text Field Delegate
extension PromotionVC: UITextFieldDelegate {}

// MARK: Extension Search
extension PromotionVC: PromotionViewControllable {
    func focusSearch() {
        self.textField?.becomeFirstResponder()
    }
    
    func attach(searchView: PromotionSearchView) {
        searchView >>> self.mainView >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        self.containerView = searchView.tableView
        guard let listener = self.listener else {
            return
        }
        
        searchView.eSelect.bind(to: listener.command).disposed(by: disposeBag)
    }
}

extension PromotionVC: KeyboardAnimationProtocol {}
