//  File name   : FoodListCategoryVC.swift
//
//  Author      : Dung Vu
//  Created date: 11/11/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import Eureka
import SnapKit
import FwiCore
import FwiCoreRX
import RxSwift
import RxCocoa

protocol CategoryRequestProtocol {
    var name: String? { get }
    var id: Int? { get }
    var hasChildren: Bool { get }
}

protocol FoodListCategoryPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var current: CategoryRequestProtocol { get }
    var list: Observable<[MerchantCategory]> { get }
    func foodListCategoryMoveBack()
    func routeToListCategory(detail: CategoryRequestProtocol)
    func routeToList(type: FoodListType)
    func refresh()
}

final class FoodListCategoryVC: UIViewController, FoodListCategoryPresentable, FoodListCategoryViewControllable {
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: FoodListCategoryPresentableListener?
    private lazy var mRefreshControl: UIRefreshControl = {
        let f = UIRefreshControl(frame: .zero)
        return f
    }()
    private lazy var disposeBag = DisposeBag()
    private lazy var collectionViewFlowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    
    private lazy var collectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout)
        collection.backgroundColor = .white
        return collection
    }()
    private var source = [MerchantCategory]()

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
}

// MARK: View's event handlers
extension FoodListCategoryVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension FoodListCategoryVC {
}

// MARK: Class's private methods
private extension FoodListCategoryVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        let navigationBar = navigationController?.navigationBar
        let bgImage = UIImage(named:"bg_navigationbar")?.stretchableImage(withLeftCapWidth: 0, topCapHeight: 0)
        navigationBar?.setBackgroundImage(bgImage, for: .default)
        navigationBar?.barTintColor = Color.orange
        navigationBar?.isTranslucent = false
        navigationBar?.tintColor = .white
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        title = listener?.current.name
        if self.tabBarController == nil {
            let image = UIImage(named: "ic_arrow_back")?.withRenderingMode(.alwaysTemplate)
            let button = UIButton(frame: CGRect(origin: .zero, size: image?.size ?? .zero))
            button.setImage(image, for: .normal)
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
            let leftBarButton = UIBarButtonItem(customView: button)
            navigationItem.leftBarButtonItem = leftBarButton
            self.navigationItem.leftBarButtonItem = leftBarButton
            
            UIApplication.setStatusBar(using: .lightContent)
            
            button.rx.tap.bind { [weak self] in
                self?.listener?.foodListCategoryMoveBack()
            }.disposed(by: disposeBag)
        }
        
        collectionView.refreshControl = mRefreshControl
        collectionViewFlowLayout.minimumInteritemSpacing = 14
        collectionViewFlowLayout.minimumLineSpacing = 16
        collectionViewFlowLayout.scrollDirection = .vertical
        collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        let wItem = (UIScreen.main.bounds.width - 64) / 3
        let ratio = UIScreen.main.bounds.width / 375
        collectionViewFlowLayout.itemSize = CGSize(width: wItem, height: 76 * ratio)
        
        collectionView.register(FoodCategoryCVC.nib, forCellWithReuseIdentifier: FoodCategoryCVC.identifier)
        collectionView >>> view >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
    }
    
    func setupRX() {
        listener?.list.bind(onNext: weakify({ (s, wSelf) in
            wSelf.source = s
            guard wSelf.mRefreshControl.isRefreshing else {
                return
            }
            wSelf.mRefreshControl.endRefreshing()
        })).disposed(by: disposeBag)
        
        listener?.list.bind(to: collectionView.rx.items(cellIdentifier: FoodCategoryCVC.identifier, cellType: FoodCategoryCVC.self)) { idx, element, cell in
            cell.setupDisplay(item: element)
        }.disposed(by: disposeBag)
        
        mRefreshControl.rx.controlEvent(.valueChanged).bind(onNext: weakify({ (wSelf) in
            wSelf.mRefreshControl.beginRefreshing()
            wSelf.listener?.refresh()
        })).disposed(by: disposeBag)
        
        collectionView.rx.itemSelected.map { [weak self] in
            return self?.source[safe: $0.item]
            }.filterNil().bind(onNext: weakify({ (item, wSelf) in
                if item.hasChildren {
                    wSelf.listener?.routeToListCategory(detail: item)
                } else {
                    wSelf.listener?.routeToList(type: .category(model: item))
                }
        })).disposed(by: disposeBag)
        
    }
}
