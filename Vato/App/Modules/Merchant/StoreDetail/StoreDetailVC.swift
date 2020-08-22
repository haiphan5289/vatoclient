//  File name   : StoreDetailVC.swift
//
//  Author      : khoi tran
//  Created date: 11/6/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxSwift
import RxCocoa
import FwiCore
import FwiCoreRX
import SnapKit

protocol StoreDetailPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    
    func storeDetailMoveBack()
    func routeToNextScreen(command: StoreDetailCommand)
    
    var currentStore: Store? { get }
}

enum StoreDetailCommand: Int {
    case storeInfo = 0
    case productInfo = 1
}

struct StoreDetailCellData {
    var image: String?
    var name: String?
    var status: Int?
}

final class StoreDetailVC: UIViewController, StoreDetailPresentable, StoreDetailViewControllable {
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: StoreDetailPresentableListener?

    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }

    /// Class's private properties.
    private lazy var disposeBag = DisposeBag()
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    private var source: [StoreDetailCellData] = [StoreDetailCellData(image: "ic_information_merchant", name: Text.storeInformation.localizedText, status: 1), StoreDetailCellData(image: "ic_menu_merchant", name: Text.menu.localizedText, status: 1)]
}

// MARK: View's event handlers
extension StoreDetailVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension StoreDetailVC {
}

// MARK: Class's private methods
private extension StoreDetailVC {
    private func localize() {
        // todo: Localize view's here.
        
    }
    private func visualize() {
        // todo: Visualize view's here.
        setupNavigation()
    
        self.view.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1.0)
        tableView.sectionHeaderHeight = 0.1
        tableView.sectionFooterHeight = 0.1
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 72, bottom: 0, right: 0)
        tableView.separatorColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1)
        
        
        tableView >>> view >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(StoreDetailTypeCell.nib,
                           forCellReuseIdentifier: StoreDetailTypeCell.identifier)
        
    }
    
    private func setupNavigation() {
        
        self.title = self.listener?.currentStore?.name ?? ""
        
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
            wSelf.listener?.storeDetailMoveBack()
        }).disposed(by: disposeBag)
        
    }
    
    func setupRX() {
        
    }
    
}


extension StoreDetailVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return source.count
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
        if let command = StoreDetailCommand.init(rawValue: indexPath.row) {
            self.listener?.routeToNextScreen(command: command)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StoreDetailTypeCell.identifier, for: indexPath) as? StoreDetailTypeCell else {
            fatalError("")
        }
        let data = self.source[indexPath.row]
        cell.setupData(data: data)
        return cell
    }
    
    
}
