//  File name   : StoreParentListVC.swift
//
//  Author      : Dung Vu
//  Created date: 11/29/19
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

protocol StoreParentListPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var source: Observable<[FoodCategoryItem]> { get }
    func storeParentListMoveBack()
    func select(at idx: Int)
    var trackLoading: Observable<(Bool, Double)> { get }
}

final class StoreParentListVC: UIViewController, StoreParentListPresentable, StoreParentListViewControllable, LoadingAnimateProtocol, DisposableProtocol {
    private struct Config {
        static let title = "Danh mục"
        static let numberItemRow: CGFloat = 4
        static let spacing: CGFloat = 8
        static let padding: CGFloat = 16
        static let hItem: CGFloat = 96
    }
    
    /// Class's public properties.
    weak var listener: StoreParentListPresentableListener?
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let maxItem = Config.numberItemRow
        let spacing = Config.spacing
        let padding = Config.padding
        
        let w = ((UIScreen.main.bounds.width - padding * 2) - (maxItem - 1) * spacing) / maxItem
        layout.itemSize = CGSize(width: w, height: Config.hItem)
        layout.minimumLineSpacing = 14
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        let c = UICollectionView(frame: .zero, collectionViewLayout: layout)
        c.backgroundColor = .clear
        return c
    }()
    
    lazy var disposeBag = DisposeBag()
    
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
extension StoreParentListVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension StoreParentListVC {
}

// MARK: Class's private methods
private extension StoreParentListVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        view.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        let navigationBar = navigationController?.navigationBar
        let bgImage = UIImage(named:"bg_navigationbar")?.stretchableImage(withLeftCapWidth: 0, topCapHeight: 0)
        navigationBar?.setBackgroundImage(bgImage, for: .default)
        navigationBar?.barTintColor = Color.orange
        navigationBar?.isTranslucent = false
        navigationBar?.tintColor = .white
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        title = Config.title
        
        let image = UIImage(named: "ic_arrow_back")?.withRenderingMode(.alwaysTemplate)
        let button = UIButton(frame: CGRect(origin: .zero, size: image?.size ?? .zero))
        button.setImage(image, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
        let leftBarButton = UIBarButtonItem(customView: button)
        navigationItem.leftBarButtonItem = leftBarButton
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        UIApplication.setStatusBar(using: .lightContent)
        
        button.rx.tap.bind { [weak self] in
            self?.listener?.storeParentListMoveBack()
        }.disposed(by: disposeBag)
        
        collectionView >>> view >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        collectionView.register(FoodCategoryParentCVC.nib, forCellWithReuseIdentifier: FoodCategoryParentCVC.identifier)
    }
    
    func setupRX() {
        listener?.source.bind(to: collectionView.rx.items(cellIdentifier: FoodCategoryParentCVC.identifier, cellType: FoodCategoryParentCVC.self)) { idx, element, cell in
            cell.setupDisplay(item: element)
        }.disposed(by: disposeBag)
        
        collectionView.rx.itemSelected.bind(onNext: weakify({ (idx, wSelf) in
            wSelf.listener?.select(at: idx.item)
        })).disposed(by: disposeBag)
        
        showLoading(use: self.listener?.trackLoading)
    }
}



