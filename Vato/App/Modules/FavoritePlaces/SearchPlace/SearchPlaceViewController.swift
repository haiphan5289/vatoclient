//
//  SearchPlaceViewController.swift
//  Vato
//
//  Created by vato. on 7/18/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import VatoNetwork


typealias HandlerLocationFavorite = (MapModel.Place?, Error?) -> Void
class SearchPlaceViewController: UIViewController {
    var didSelect: ((MapModel.Place?) -> Void)?
    var didSelectDetail: ((MapModel.PlaceDetail) -> Void)?
    
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var constraintTopHeader: NSLayoutConstraint!
    
    // MARK: - property
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var mapButton: UIButton!
    
    private lazy var disposeBag = DisposeBag()
    
    
    var viewModel: SearchPlaceVM!
    
    private var listData = [MapModel.Place]()
    private let listDataSubject = ReplaySubject<[MapModel.Place]>.create(bufferSize: 1)
    
    convenience init(viewModel: SearchPlaceVM) {
        self.init()
        self.viewModel = viewModel
    }
    
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.setStatusBar(using: .default)

        // fix bug in iphone 5 ios 10.3.3 (header overwrite to status bar)
        DispatchQueue.main.async {
//            var topSafeAreaInsets: CGFloat = 0
//            if #available(iOS 11.0, *) {
//                let window = UIApplication.shared.keyWindow
//                topSafeAreaInsets = window?.safeAreaInsets.bottom ?? 0
//            }
//            topSafeAreaInsets = topSafeAreaInsets + UIApplication.shared.statusBarFrame.height
            self.constraintTopHeader.constant = UIApplication.shared.statusBarFrame.height
        }
        
        
        setupView()
        setRX()
        self.textField.placeholder = Text.enterTheSearchAddress.localizedText
        self.textField.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        super.viewWillAppear(animated)
        UIApplication.setStatusBar(using: .default)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.setStatusBar(using: .lightContent)
    }
    
    // MARK: - Private method
    
    func setupView() {
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 50
        self.tableView.separatorStyle = .none
        let backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        self.view.backgroundColor = backgroundColor
        self.tableView.backgroundColor = backgroundColor
        self.tableView.tableFooterView = UIView()
        self.tableView.keyboardDismissMode = .onDrag
        self.tableView.register(UINib(nibName: "PlaceTableHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "PlaceTableHeaderView")
        // self.tableView.register(UINib(nibName: "FavoritePlaceTableViewCell", bundle: nil), forCellReuseIdentifier: "FavoritePlaceTableViewCell")
    }
    
    private var disposeSearch: Disposable?
    func setRX(){
        self.backButton.rx.tap.bind { [weak self] in
            self?.navigationController?.popViewController(animated: true)
            }.disposed(by: disposeBag)
        
        // self.tableView.rx.setDelegate(self).disposed(by: disposeBag)
        // self.tableView.rx.setDataSource(self).disposed(by: disposeBag)
        
        self.listDataSubject
            // .bind(to: tableView.rx.items(cellIdentifier: "FavoritePlaceTableViewCell", cellType: FavoritePlaceTableViewCell.self))
            .bind(to: tableView.rx.items) { (tableView, row, element) in
                let identifier = "FavoritePlaceTableViewCell"
                var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? FavoritePlaceTableViewCell
                if cell == nil {
                    cell = FavoritePlaceTableViewCell.newCell(reuseIdentifier: identifier)
                }
                cell?.displayDataMapPlaceModel(model: element)
                return cell!
            } .disposed(by: disposeBag)
        
        self.textField.rx.text
            .filter { [weak self] _ in
                self?.textField.isFirstResponder == true
            }
        .debounce(RxTimeInterval.milliseconds(30), scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] keyword in
                self?.disposeSearch?.dispose()
                
                let observable = self?.viewModel.findSuggestion(by: keyword)
                self?.disposeSearch = observable?.subscribe(onNext: { [weak self] values in
                    self?.listDataSubject.onNext(values)
                })
            })
            .disposed(by: disposeBag)
        
        self.listDataSubject.subscribe(onNext: { [weak self] values in
            self?.listData = values
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }).disposed(by: disposeBag)
        
        self.tableView.rx.itemSelected.bind { [weak self] indexPath in
            guard let self = self else { return }
            let model = self.listData[indexPath.row]
            LoadingManager.showProgress()
            self.viewModel.getDetailLocation(place: model, completion: {[weak self] newModel, e in
                guard let self = self else { return }
                if let error = e {
                    var message = error.localizedDescription
                    if (error as NSError).code == NSURLErrorBadServerResponse {
                        message = Text.networkDownDescription.localizedText
                    }
                    AlertVC.showError(for: self, message: message)
                } else {
                    self.didSelect?(newModel)
                    self.navigationController?.popViewController(animated: true)
                }
                LoadingManager.dismissProgress()
            })
            }.disposed(by: disposeBag)

        self.mapButton.rx.tap.bind { [weak self] in
            let vc = PinLocationViewController()
            vc.didSelect = {[weak self] model in
                self?.didSelectDetail?(model)
                self?.popToViewUpdate()
            }
            self?.navigationController?.pushViewController(vc, animated: true)
            }.disposed(by: disposeBag)
    }
    
    func popToViewUpdate() {
        var previousVC: UIViewController? = self.navigationController?.viewControllers.first
        self.navigationController?.viewControllers.forEach({ (vc) in
            if vc == self,
                let previousVC = previousVC {
                
                self.navigationController?.popToViewController(previousVC, animated: true)
                return
            }
            previousVC = vc
        })
    }
}
