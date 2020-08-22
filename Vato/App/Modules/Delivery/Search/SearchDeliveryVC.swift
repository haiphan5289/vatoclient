//  File name   : SearchDeliveryVC.swift
//
//  Author      : Dung Vu
//  Created date: 8/14/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxSwift
import VatoNetwork

protocol SearchDeliveryPresentableListener: class {
    func moveBack()
    func moveToPin()
    func searchLocation(keyword: String)
    func getListFavorite()
    func didSelectModel(indexPath: IndexPath)
    func didSelectFavoriteModel(model: PlaceModel)
    func didSelectAddFavorite(item: MapModel.Place)
    var listDataObservable: Observable<[MapModel.Place]>  { get }
    var listFavoriteObservable: Observable<[PlaceModel]>  { get }
    var placeModelObservable: Observable<AddressProtocol>  { get }
    var searchType: SearchType { get }
}

final class SearchDeliveryVC: UIViewController, SearchDeliveryPresentable, SearchDeliveryViewControllable {
    private struct Config {
        static let fontCellFavoritePlace = UIFont.systemFont(ofSize: 13.0, weight: .regular)
        static let heightCellFavoritePlace: CGFloat = 40.0
    }
    
    private lazy var disposeBag = DisposeBag()
    
    /// Class's public properties.
    weak var listener: SearchDeliveryPresentableListener?
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    var listFavoriteSource = [PlaceModel]()
    
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setRX()
        self.listener?.getListFavorite()
    }
    override func viewWillAppear(_ animated: Bool) {
        setupNavigationBar()
        super.viewWillAppear(animated)
        localize()
    }
    
    private func setRX(){
        self.textField.rx.text.debounce(RxTimeInterval.milliseconds(30), scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] (keyWord) in
                self?.listener?.searchLocation(keyword: keyWord ?? "")
            })
            .disposed(by: disposeBag)
        
        self.listener?.listDataObservable.bind(to: tableView.rx.items(cellIdentifier: SearchLocationSuggestionCVC.identifier, cellType: SearchLocationSuggestionCVC.self)) { [weak self](row, element, cell) in
            cell.titleLabel.text = element.primaryName
            cell.subtitleLabel.text = element.address
            
            guard let wSelf = self else { return }
            cell.addButton.rx.tap
                .takeUntil(cell.rx.methodInvoked(#selector(UITableViewCell.prepareForReuse)))
                .subscribe(onNext: { _ in
                    guard let wSelf = self else { return }
                    wSelf.listener?.didSelectAddFavorite(item: element)
                }).disposed(by: wSelf.disposeBag)
            }
            .disposed(by: disposeBag)
        
        self.listener?.listFavoriteObservable.bind(to: self.suggestionCollectionView.rx.items) { (collectionView, row, element) in
            let indexPath = IndexPath(row: row, section: 0)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeSuggestionCVC.identifier, for: indexPath) as! HomeSuggestionCVC
            cell.configure(with: element, fontTitle: Config.fontCellFavoritePlace)
            return cell
            }.disposed(by: disposeBag)
        
        self.listener?.listFavoriteObservable.subscribe(onNext: {[weak self] (listData) in
            self?.listFavoriteSource = listData
        }).disposed(by: disposeBag)
        
        self.tableView.rx.itemSelected.bind {[weak self](indexPath) in
            self?.listener?.didSelectModel(indexPath: indexPath)
            }.disposed(by: disposeBag)
        
//        self.listener?.placeModelObservable.subscribe(onNext: { (model) in
//            self.textField.text = model.name
//        }).disposed(by: disposeBag)
    }
    /// Class's private properties.
    
    @IBOutlet weak var suggestionView: UIView!
    @IBOutlet weak var suggestionCollectionView: UICollectionView!
    
    var favoritePlaceModel = [PlaceModel]()
}

// MARK: View's event handlers
extension SearchDeliveryVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension SearchDeliveryVC {
}

// MARK: Class's private methods
private extension SearchDeliveryVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        UIApplication.setStatusBar(using: .lightContent)
        
        self.setupNavigationBar()
        
        self.textField.placeholder = self.listener?.searchType.placeHolder() ?? Text.enterTheSearchAddress.localizedText
        self.textField.becomeFirstResponder()
        
        let nib = UINib(nibName: "SearchLocationSuggestion", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: SearchLocationSuggestionCVC.identifier)
        self.tableView.backgroundColor = .white
        self.tableView.tableFooterView = UIView()
        
        
        suggestionCollectionView.register(HomeSuggestionCVC.self, forCellWithReuseIdentifier: HomeSuggestionCVC.identifier)
        self.suggestionCollectionView.delegate = self
    }
    
    private func setupNavigationBar() {
        title = self.listener?.searchType.string()
        UIApplication.setStatusBar(using: .default)
        view.backgroundColor = .white
        let navigationBar = self.navigationController?.navigationBar
        navigationBar?.barTintColor = UIColor.white
        navigationBar?.isTranslucent = false
        navigationBar?.tintColor = .white
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        navigationBar?.shadowImage = UIImage()
        
        if #available(iOS 12, *) {
        } else {
            navigationBar?.subviews.flatMap { $0.subviews }.filter{ $0 is UIImageView }.forEach({
                $0.isHidden = true
            })
        }
        
        self.navigationController?.navigationBar.tintColor = .black
        let itemLeft = UIBarButtonItem(image: #imageLiteral(resourceName: "iconBackGrey").withRenderingMode(.alwaysTemplate), landscapeImagePhone: #imageLiteral(resourceName: "ic_back").withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: nil)
        self.navigationItem.leftBarButtonItem = itemLeft
        itemLeft.rx.tap.bind { [weak self] in
            self?.listener?.moveBack()
            }.disposed(by: disposeBag)
        
        let itemRight = UIBarButtonItem(image: #imageLiteral(resourceName: "iconMapGrey").withRenderingMode(.alwaysTemplate), landscapeImagePhone: #imageLiteral(resourceName: "iconMapGrey").withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: nil)
        self.navigationItem.rightBarButtonItem = itemRight
        itemRight.rx.tap.bind { [weak self] in
            self?.listener?.moveToPin()
            }.disposed(by: disposeBag)
    }
}

extension SearchDeliveryVC: UICollectionViewDelegateFlowLayout {
    // MARK: UICollectionViewDelegateFlowLayout's members
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var _item: PlaceModel?
        if indexPath.row < self.listFavoriteSource.count {
            _item = self.listFavoriteSource[indexPath.row]
        }
        guard let item = _item else  { return CGSize.zero }
        
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: Config.fontCellFavoritePlace
        ]
        let string = NSAttributedString(string: item.name ?? "", attributes: attributes)
        
        // Calculate dynamic width
        var expectedSize = string.size()
        expectedSize.width = ceil(expectedSize.width + 64.0)
        
        let width35 = UIScreen.main.bounds.size.width * 3 / 5
        let width = expectedSize.width >= width35 ? width35 : expectedSize.width
        
        return CGSize(width: width , height: Config.heightCellFavoritePlace)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 10.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if indexPath.row < self.listFavoriteSource.count {
            let model = self.listFavoriteSource[indexPath.row]
            self.listener?.didSelectFavoriteModel(model: model)
        }
    }
}
