//  File name   : MerchantDetailVC.swift
//
//  Author      : khoi tran
//  Created date: 10/21/19
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

enum StoreCommand {
    case addNew
    case edit(store: Store?)
}


struct StroreResponsePaging<T: Codable>: Codable {
    var listStore: [T]?
    var pageable: StorePaging?
}

struct StorePaging: Codable {
    var indexPage: Int
    var sizePage: Int
    var totalPage: Int
}

protocol MerchantDetailPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func backToMainMerchant()
    func excuteStoreCommand(command: StoreCommand)
    func getListStore()
    func routeToCreateMerchantDetail()

    var listStore: Observable<[[Store]]>? { get }
    var eLoadingObserable: Observable<Bool> {get}
    var errorObserable: Observable<MerchantState> {get}
    var currentSelectedMerchant: Observable<Merchant?> { get }

}


final class MerchantDetailVC: UIViewController, MerchantDetailPresentable, MerchantDetailViewControllable {
    private struct Config {
        
    }
    
    /// Class's public properties.
    weak var listener: MerchantDetailPresentableListener?

    
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        self.title = Text.detailMerchant.localizedText
        tableView.delegate = self
        tableView.dataSource = self
        
        visualize()
        setupRX()
        
        self.listener?.getListStore()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }

    /// Class's private properties.
    private lazy var disposeBag = DisposeBag()
    private var createStoreBtn: UIButton?
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var imvMerchantAvatar: UIImageView!
    @IBOutlet weak var lblMerchantName: UILabel!
    @IBOutlet weak var imvStatus: UIImageView!
    @IBOutlet weak var lblStatus: UILabel!
    
    @IBOutlet weak var merchantView: UIView!
    
    private lazy var noItemView: NoItemView = NoItemView(imageName: "merchant_empty",
                                                         message: Text.addNewOutletContent.localizedText,
                                                         on: self.tableView)
    
    private var dataSource: Variable<[[Store]]> = Variable([])
    private lazy var tapGesture: UITapGestureRecognizer = UITapGestureRecognizer()
    private var refreshControl: UIRefreshControl = UIRefreshControl()
    
}


// MARK: View's event handlers
extension MerchantDetailVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension MerchantDetailVC {
}

// MARK: Class's private methods
private extension MerchantDetailVC {
    private func localize() {
        // todo: Localize view's here.                        
    }
    private func visualize() {
        // todo: Visualize view's here.
        self.setupNavigation()
        
        let createStoreBtn = UIButton.create {
            $0.backgroundColor = UIColor.init(red: 239/255, green: 82/255, blue: 34/255, alpha: 1.0)
            $0.setTitle(Text.addNewOutlet.localizedText, for: .normal)
            $0.setTitleColor(.white, for: .normal)
            $0.cornerRadius = 24
            } >>> view >>> {
                $0.snp.makeConstraints({ (make) in
                    make.centerX.equalToSuperview()
                    make.left.equalToSuperview().offset(18)
                    make.right.equalToSuperview().offset(-18)
                    make.height.equalTo(48)
                    make.bottom.equalToSuperview().offset(-42)
                })
        }
        self.createStoreBtn = createStoreBtn
        self.createStoreBtn?.isEnabled = true
        
        self.registerCell()
        
        self.merchantView.addGestureRecognizer(self.tapGesture)
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
        
        let imageRight = UIImage(named: "add")
        let buttonRight = UIButton(frame: CGRect(origin: .zero, size: image?.size ?? .zero))
        buttonRight.setImage(imageRight, for: .normal)
        buttonRight.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -30)
        let barButtonRight = UIBarButtonItem(customView: buttonRight)
        navigationItem.rightBarButtonItem = barButtonRight
        
        button.rx.tap.bind(onNext: weakify { wSelf in
            wSelf.listener?.backToMainMerchant()
        }).disposed(by: disposeBag)
        
        buttonRight.rx.tap.bind(onNext: weakify { wSelf in
            wSelf.listener?.excuteStoreCommand(command: .addNew)
        }).disposed(by: disposeBag)
    }
    
    func setupRX() {
        self.tapGesture.rx.event.bind(onNext: { [weak self] recognizer in
            self?.listener?.routeToCreateMerchantDetail()
        }).disposed(by: disposeBag)
        
        self.listener?.listStore?.bind(onNext: { [weak self] (value) in
            self?.dataSource.value = value
            self?.tableView.reloadData()
        }).disposed(by: disposeBag)
        
        self.listener?.errorObserable.bind(onNext: { [weak self] (err) in
            AlertVC.showError(for: self, message: err.getMsg())
        }).disposed(by: disposeBag)
        
        self.listener?.eLoadingObserable.bind(onNext: { [weak self] (loading) in
            if loading {
                LoadingManager.showProgress()
            } else {
                LoadingManager.dismissProgress()
                self?.refreshControl.endRefreshing()
            }
        }).disposed(by: disposeBag)
        
        self.createStoreBtn?.rx.tap.bind{ [weak self] _ in
            guard let me = self else { return }
            me.listener?.excuteStoreCommand(command: .addNew)
        }.disposed(by: disposeBag)
        
        self.tableView.rx.itemSelected.bind {[weak self] (indexPath) in
            guard let me = self else {
                return
            }
            let store = me.dataSource.value[indexPath.section][indexPath.row]
            
            me.listener?.excuteStoreCommand(command: .edit(store: store))

            
            }.disposed(by: disposeBag)
        
        
        self.listener?.currentSelectedMerchant
            .observeOn(MainScheduler.asyncInstance)
            .bind(onNext: { [weak self](m) in
                guard let me = self, let m = m else {return}
                if let url = URL(string: m.basic?.avatarUrl ?? "") {
                    me.imvMerchantAvatar.kf.setImage(with: url, placeholder: nil)
                }
                if let status = MerchantStatus.init(rawValue: m.basic?.status ?? 0) {
                    me.imvStatus.image = status.getIcon()
                    me.lblStatus.text = status.stringValue()
                    me.lblStatus.textColor = status.getTextColor()
                    
                }
                me.lblMerchantName.text = m.basic?.name
                
                
        }).disposed(by: disposeBag)
        self.refreshControl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] in
            self?.listener?.getListStore()
        }).disposed(by: disposeBag)
    }
    
    func registerCell() {
        self.tableView?.register(DetailMerchantCell.nib, forCellReuseIdentifier: DetailMerchantCell.identifier)
    }
}
extension MerchantDetailVC {
    func checkShowItemView(){
        self.dataSource.asObservable().bind { [weak self] (value) in
            value.count > 0 ? self?.noItemView.detach() : self?.noItemView.attach()
        }.disposed(by: disposeBag)
    }
}

extension MerchantDetailVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return dataSource.value.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataSource.value[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DetailMerchantCell.identifier) as? DetailMerchantCell else {
            fatalError("")
        }
        
        if let store: Store = dataSource.value[indexPath.section][indexPath.row] {
            cell.setupData(from: store)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.dataSource.value[section].first?.zoneName ?? ""
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
}
