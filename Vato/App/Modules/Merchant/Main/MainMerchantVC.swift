//  File name   : MainMerchantVC.swift
//
//  Author      : khoi tran
//  Created date: 10/18/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxSwift
import FwiCore
import FwiCoreRX
import SnapKit
import Kingfisher
import RxCocoa

struct MerchantResponsePaging<T: Codable>: Codable {
    var content: [T]?
//    var pageable: MerchantPaging?
}

struct MerchantPaging: Codable {
    var offset: Int
    var pageSize: Int
    var pageNumber: Int
}


protocol MainMerchantPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func merchantMoveBack()
    func didSelectedMerchant(merchant: Merchant?)
    func routeToCreateMerchantType()
    func getListMerchant()
    func refresh()
    var listMerchantDisplay: Observable<[ListMerchantDisplay]>? { get }

    var eLoadingObser: Observable<(Bool,Double)> {get}
    var errorObserable: Observable<MerchantState> {get}
    
}

final class MainMerchantVC: UIViewController, MainMerchantPresentable, MainMerchantViewControllable, LoadingAnimateProtocol, DisposableProtocol {
    private struct Config {
    }        
    
    lazy var disposeBag = DisposeBag()

    
    /// Class's public properties.
    weak var listener: MainMerchantPresentableListener?
    @IBOutlet weak var tableView: UITableView!
    private var dataSource: BehaviorRelay<[ListMerchantDisplay]> = BehaviorRelay(value: [])

    private lazy var noItemView = NoItemView(imageName: "merchant_empty",
                                             message: Text.donotConnectMerchant.localizedText,
                                             subMessage: Text.lookingForMerchantToConnect.localizedText,
                                             on: self.tableView,
                                             customLayout: nil)
    private let refreshControl = UIRefreshControl()
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        visualize()
        setupRX()
        
        self.listener?.getListMerchant()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }
    /// Class's private properties.
//    private lazy var noItemView = NoItemView(imageName: "n_promotion", message: PromotionConfig.noItemMessage, on: self.tableView)
    
    
}

// MARK: View's event handlers
extension MainMerchantVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension MainMerchantVC {
}

// MARK: Class's private methods
private extension MainMerchantVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        self.setupNavigation()
        
       
        self.title = Text.selectMerchant.localizedText
        self.registerCell()
        tableView.refreshControl = refreshControl
    }
    
    private func setupRX() {
        self.listener?.listMerchantDisplay?.bind(onNext: { [weak self] (value) in
            self?.dataSource.accept(value)
            self?.tableView.reloadData()
        }).disposed(by: disposeBag)
        
        self.listener?.eLoadingObser.filter({ !$0.0 }) .bind(onNext: { [weak self] (loading, percent) in
            self?.refreshControl.endRefreshing()
        }).disposed(by: disposeBag)
        
        showLoading(use: self.listener?.eLoadingObser)

        
        self.listener?.errorObserable.bind(onNext: { [weak self](err) in
            AlertVC.showError(for: self, message: err.getMsg())
        }).disposed(by: disposeBag)
        
        self.tableView.rx.itemSelected.bind {[weak self] (indexPath) in
            guard let me = self else {
                return
            }
            
            let merchant = me.dataSource.value[indexPath.section].listMerchant?[indexPath.row]
            me.listener?.didSelectedMerchant(merchant: merchant)
            
        }.disposed(by: disposeBag)
        self.refreshControl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] in
            self?.listener?.refresh()
        }).disposed(by: disposeBag)
        
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
        
        let imageRight = UIImage(named: "add")
        let buttonRight = UIButton(frame: CGRect(origin: .zero, size: image?.size ?? .zero))
        buttonRight.setImage(imageRight, for: .normal)
        buttonRight.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -30)
        let barButtonRight = UIBarButtonItem(customView: buttonRight)
        navigationItem.rightBarButtonItem = barButtonRight
        
        button.rx.tap.bind(onNext: weakify { wSelf in
            wSelf.listener?.merchantMoveBack()
        }).disposed(by: disposeBag)
        
        buttonRight.rx.tap.bind(onNext: weakify { wSelf in
            wSelf.listener?.routeToCreateMerchantType()
        }).disposed(by: disposeBag)
    }
    
    func registerCell() {
        tableView?.prefetchDataSource = self
        self.tableView?.register(MerchantItemTableViewCell.nib, forCellReuseIdentifier: MerchantItemTableViewCell.identifier)
    }
}

extension MainMerchantVC: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard let last = indexPaths.last else {
            return
        }
        
        let idx = last.section + last.item
        guard idx >= 10 else {
            return
        }
        
        listener?.getListMerchant()
    }
}



extension MainMerchantVC: UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.create {
            $0.backgroundColor = UIColor.white
        }
        
        let merchantCategory = self.dataSource.value[section].category
        
        UIImageView.create {
            $0.contentMode = .scaleAspectFit
            $0.kf.setImage(with: URL(string: merchantCategory?.catImage?.first ?? ""))
        } >>> view >>> {
            $0.snp.makeConstraints({ (make) in
                make.centerY.equalToSuperview()
                make.size.equalTo(CGSize(width: 24, height: 24))
                make.left.equalToSuperview().offset(20)
            })
        }
        
        let name =  "\(merchantCategory?.name ?? "") (\(self.dataSource.value[section].listMerchant?.count ?? 0))"
        UILabel.create {
            $0.font = UIFont.systemFont(ofSize: 15.0, weight: .medium)
            $0.textColor = UIColor.init(red: 17.0/255.0, green: 17.0/255.0, blue: 17.0/255.0, alpha: 1.0)
            $0.text = name
        } >>> view >>> {
            $0.snp.makeConstraints({ (make) in
                make.centerY.equalToSuperview()
                make.left.equalToSuperview().offset(48)
            })
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }

}

extension MainMerchantVC {
    func checkShowNoitemView(){
        self.dataSource.asObservable().bind { [weak self] (value) in
            if value.count > 0 {
                self?.noItemView.detach()
            } else {
                self?.noItemView.attach()
                self?.noItemView.lblMessage?.font = UIFont.boldSystemFont(ofSize: 18)
                self?.noItemView.lblSub?.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
                self?.noItemView.lblSub?.font = UIFont.systemFont(ofSize: 15)
                self?.noItemView.lblSub?.textColor = #colorLiteral(red: 0.2901960784, green: 0.2901960784, blue: 0.2901960784, alpha: 1)
            }
        }.disposed(by: disposeBag)
    }
}

extension MainMerchantVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.value.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.value[section].listMerchant?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MerchantItemTableViewCell.identifier) as? MerchantItemTableViewCell else {
            fatalError("")
        }
        
        if let merchaint: Merchant = dataSource.value[indexPath.section].listMerchant?[indexPath.row] {
            cell.setupData(from: merchaint.basic)                                    
        }
        return cell
    }
    
    
}
