//  File name   : CreateMerchantTypeVC.swift
//
//  Author      : khoi tran
//  Created date: 10/19/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxSwift
import RxCocoa
import KeyPathKit
import Kingfisher
import FwiCoreRX

protocol CreateMerchantTypePresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func backToMainMerchant()
    func createMerchantDetail(indexPath: IndexPath)
    func getListCategories()
    var listCategoriesObserable: Observable<MerchantCategory> { get }
    var errorObserable: Observable<MerchantState>{ get }
    var eLoadingObser: Observable<(Bool, Double)> { get }
}

final class CreateMerchantTypeVC: UIViewController, CreateMerchantTypePresentable, CreateMerchantTypeViewControllable, LoadingAnimateProtocol, DisposableProtocol {
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: CreateMerchantTypePresentableListener?
    internal lazy var disposeBag = DisposeBag()
    private var dataSource: [MerchantCategory] = []
    private var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        return tableView
    }()
    private lazy var noItemView = NoItemView(imageName: "merchant_empty",
                                             message: Text.donotConnectMerchant.localizedText,
                                             on: self.tableView)
    private let refreshControl = UIRefreshControl()
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Text.typeMerchant.localizedText
        visualize()
        setupRX()
        self.listener?.getListCategories()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }
    
    var controllerDetail: CreateMerchantDetailVC? {
        return children.compactMap { $0 as? CreateMerchantDetailVC }.first
    }

    /// Class's private properties.
}

// MARK: View's event handlers
extension CreateMerchantTypeVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension CreateMerchantTypeVC {
    func checkShowEmptyView(){
        DispatchQueue.main.async {
            self.dataSource.count > 0 ? self.noItemView.detach() : self.noItemView.attach()
        }
    }
}

// MARK: Class's private methods
private extension CreateMerchantTypeVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {

        // todo: Visualize view's here.
        self.setupNavigation()
        tableView.sectionHeaderHeight = 0.1
        tableView.sectionFooterHeight = 0.1
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 72, bottom: 0, right: 0)
        tableView.separatorColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1)
        tableView >>> view >>> {
            $0.snp.makeConstraints({ (make) in
                make.left.top.right.bottom.equalToSuperview()
            })
        }
        tableView.register(CreateMerchantTypeCell.nib,
                           forCellReuseIdentifier: CreateMerchantTypeCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = true
        tableView.refreshControl = refreshControl
    }
    
    private func setupNavigation() {
        
        let navigationBar = navigationController?.navigationBar
        let bgImage = UIImage(named:"bg_navigationbar")?.stretchableImage(withLeftCapWidth: 0, topCapHeight: 0)
        navigationBar?.setBackgroundImage(bgImage, for: .default)
        navigationBar?.barTintColor = Color.orange
        navigationBar?.isTranslucent = false
        navigationBar?.tintColor = .white
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        
        let image = UIImage(named: "ic_arrow_back")
        let button = UIButton(frame: CGRect(origin: .zero, size: image?.size ?? .zero))
        button.setImage(image, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
        let barButton = UIBarButtonItem(customView: button)
        navigationItem.leftBarButtonItem = barButton
        
        button.rx.tap.bind(onNext: weakify { wSelf in
            wSelf.listener?.backToMainMerchant()
        }).disposed(by: disposeBag)
        
    }
    
    func setupRX() {
        self.listener?.listCategoriesObserable
            .observeOn(MainScheduler.asyncInstance)
            .bind(onNext: { [weak self] (value) in
            guard let data = value.children else {return}
            self?.dataSource = data
            self?.tableView.reloadData()
        }).disposed(by: disposeBag)
        
        self.listener?.errorObserable.bind(onNext: { [weak self] (err) in
            AlertVC.showError(for: self, message: err.getMsg())
        }).disposed(by: disposeBag)
        
        self.listener?.eLoadingObser.filter({ !$0.0 }) .bind(onNext: { [weak self] (loading, percent) in
            self?.refreshControl.endRefreshing()
        }).disposed(by: disposeBag)
        
        showLoading(use: self.listener?.eLoadingObser)

        self.refreshControl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] in
            self?.listener?.getListCategories()
        }).disposed(by: disposeBag)

    }
}
extension CreateMerchantTypeVC:  UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.listener?.createMerchantDetail(indexPath: indexPath)
    }
    
}
extension CreateMerchantTypeVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CreateMerchantTypeCell.identifier, for: indexPath) as? CreateMerchantTypeCell else {
            fatalError("")
        }
        let element = self.dataSource[indexPath.row]
        cell.nameCategories.text = element.name
        if let imgUrl = element.catImage?.first {
            let url = URL.init(string: imgUrl)
            cell.imgCategories.kf.setImage(with: url)
        } else {
            cell.imgCategories.backgroundColor = #colorLiteral(red: 0.6352941176, green: 0.6705882353, blue: 0.7019607843, alpha: 0.3)
        }
        return cell
    }
    
    
}
