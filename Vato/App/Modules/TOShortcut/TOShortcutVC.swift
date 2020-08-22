//  File name   : TOShortcutVC.swift
//
//  Author      : khoi tran
//  Created date: 2/17/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import FwiCoreRX
import FwiCore
import SnapKit
import RxSwift

protocol TOShortcutPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var type: TOShortcutType { get }
    var dataSource: Observable<[TOShortutModel]> { get }
    var loadingProgress: Observable<ActivityProgressIndicator.Element> { get }
    func requestData()
    func routeToNearbyDriver()
    func routeToReport()
    func routeToItem(item: TOShortutModel)
    func shortcutDismiss()
    
}

final class TOShortcutVC: UIViewController, TOShortcutPresentable, TOShortcutViewControllable, DisposableProtocol, LoadingAnimateProtocol {
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: TOShortcutPresentableListener?
    
    final override var hidesBottomBarWhenPushed: Bool {
        get {
            return navigationController?.viewControllers.last != self
        } set {
            super.hidesBottomBarWhenPushed = newValue
        }
    }
    
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRX()
        visualize()
        self.listener?.requestData()

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }
    
    /// Class's private properties.
    private var tableView: UITableView = UITableView(frame: .zero, style: .grouped)
    var source:[TOShortutModel] = []
    internal var disposeBag = DisposeBag()
    
}

// MARK: View's event handlers
extension TOShortcutVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension TOShortcutVC {
}

// MARK: Class's private methods
private extension TOShortcutVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        self.setupNavigation()
        tableView.sectionHeaderHeight = 0.1
        tableView.sectionFooterHeight = 0.1
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorInset = .zero
        tableView.separatorStyle = .none
        
        tableView.register(TOShortcutTVC.nib, forCellReuseIdentifier: TOShortcutTVC.identifier)
        tableView.rowHeight = 77
        tableView.backgroundColor = .white
        tableView >>> view >>> {
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(8)
                make.left.right.bottom.equalToSuperview()
            }
        }
    }
    
    func setupRX() {
        showLoading(use: listener?.loadingProgress)
        self.listener?.dataSource.bind(onNext: {[weak self] listShortcut in
            guard let me = self else { return }
            
            me.source = listShortcut
            me.tableView.reloadData()
        }).disposed(by: disposeBag)
    }
    
}


extension TOShortcutVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return source.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TOShortcutTVC.identifier, for: indexPath) as? TOShortcutTVC else  {
            fatalError("")
        }
        
        cell.setupDisplayIndex(index: indexPath)
        cell.setupDisplay(item: source[indexPath.row])
                    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.handleSelection(item: self.source[indexPath.row])
    }
    
    private func setupNavigation() {
        let navigationBar = self.navigationController?.navigationBar
        let bgImage = UIImage(named:"bg_navigationbar")?.stretchableImage(withLeftCapWidth: 0, topCapHeight: 0)
        navigationBar?.setBackgroundImage(bgImage, for: .default)
        navigationBar?.barTintColor = Color.orange
        navigationBar?.isTranslucent = false
        navigationBar?.tintColor = .white
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        
        self.title = listener?.type.title
        
        let image = UIImage(named: "ic_arrow_back")
        let leftButton = UIButton(frame: CGRect(origin: .zero, size: image?.size ?? .zero))
        leftButton.setImage(image, for: .normal)
        leftButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
        let leftBarButton = UIBarButtonItem(customView: leftButton)
        navigationItem.leftBarButtonItem = leftBarButton
        leftButton.rx.tap.bind(onNext: weakify { wSelf in
            wSelf.listener?.shortcutDismiss()
        }).disposed(by: disposeBag)
    }
    
    func handleSelection(item: TOShortutModel) {
        self.listener?.routeToItem(item: item)
    }
    
}
    
