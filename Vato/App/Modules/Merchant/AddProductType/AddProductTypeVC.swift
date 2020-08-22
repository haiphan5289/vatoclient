//  File name   : AddProductTypeVC.swift
//
//  Author      : khoi tran
//  Created date: 11/7/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxSwift
import FwiCoreRX
import KeyPathKit

protocol AddProductTypePresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var listCategoryObservable: Observable<[MerchantCategory]?> { get }
    var errorObserable: Observable<MerchantState>{ get }
    var eLoadingObser: Observable<(Bool, Double)> { get }
    
    func addProductTypeMoveBack()
    func getListMainCategory()
    func setCategory(text: String, category: MerchantCategory)
    var listPathCategory: [MerchantCategory]? { get }
}

final class AddProductTypeVC: UIViewController, AddProductTypePresentable, AddProductTypeViewControllable, LoadingAnimateProtocol, DisposableProtocol {
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: AddProductTypePresentableListener?

    var mainCategoryVC: MerchantMainCategoryVC? {
        return children.compactMap { $0 as? MerchantMainCategoryVC }.first
    }
    
    var subCategoryVC: MerchantSubCategoryVC? {
        return children.compactMap { $0 as? MerchantSubCategoryVC }.first
    }
    
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
        self.listener?.getListMainCategory()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }

    /// Class's private properties.
    internal lazy var disposeBag = DisposeBag()
    var source:[MerchantCategory: Tree<MerchantCategory>] = [:]

    @IBOutlet weak var categoryValueLabel: UILabel!
    @IBOutlet weak var categoryTitleLabel: UILabel!
    
    @IBOutlet weak var saveButton: UIButton!
    
    var currentSelectedMainCategory: MerchantCategory?
    var currentNodeName: String?
    var currentSelectedSubCategory: MerchantCategory?
}

// MARK: View's event handlers
extension AddProductTypeVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension AddProductTypeVC {
    
    func mainProductSelectItem(indexPath: IndexPath, catetory: MerchantCategory) {
        self.saveButton.isEnabled = false
        self.currentSelectedSubCategory = nil

        let subProducts = source[catetory]
        self.currentSelectedMainCategory = catetory
            
        subCategoryVC?.reloadData(source: subProducts)
        self.categoryValueLabel.text = catetory.name
        
        if subProducts?.listChild()?.isEmpty ?? true {
            self.currentSelectedSubCategory = catetory
            self.saveButton.isEnabled = true
        }
        
        if let listPathCategory = self.listener?.listPathCategory, listPathCategory.count > 3 {
            let listSubPathCategory = Array(listPathCategory[0..<listPathCategory.count-3])
            self.subCategoryVC?.setSelectedData(listMerchantCategory: listSubPathCategory)
        }
    }
    
    

    
    func subProductSelectItem(category: MerchantCategory, type: MerchantSubCategoryCellType) {
        guard let currentSelectedMainCategory = self.currentSelectedMainCategory else {
            fatalError("")
        }
        
        self.saveButton.isEnabled = false
        if type == .node {
            currentNodeName = category.name
            categoryValueLabel.text = (currentSelectedMainCategory.name ?? "") + " - " + (currentNodeName ?? "")
            currentSelectedSubCategory = nil
            
        } else {
            currentSelectedSubCategory = category
            let nodeText = currentNodeName == nil ? "" : (" - " + currentNodeName!)
            let mainCategoryText = currentSelectedMainCategory.name ?? ""
            
            categoryValueLabel.text = mainCategoryText + nodeText + " - " + (self.currentSelectedSubCategory?.name ?? "")
            self.saveButton.isEnabled = true
        }
    }
}

// MARK: Class's private methods
private extension AddProductTypeVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        self.setupNavigation()
        self.categoryTitleLabel.text = Text.categories.localizedText + ":"
        self.saveButton.setTitle(Text.saveMerchant.localizedText, for: .normal)
        self.saveButton.isEnabled = false
    }
    
    func setupRX() {
        self.listener?.listCategoryObservable.bind(onNext: { [weak self] listCategory in
            guard let me = self, let listCategory = listCategory else { return }
            
            me.preProcessData(listCategory: listCategory)
            me.mainCategoryVC?.source = Array(me.source.keys).sorted(by: <)
            me.mainCategoryVC?.tableView.reloadData()
            
            
            if let listPathCategory = me.listener?.listPathCategory, listPathCategory.count > 2 {
                me.mainCategoryVC?.setSelectedCategory(selectedCagtegory: listPathCategory[listPathCategory.count-3])
            }
            
        }).disposed(by: disposeBag)
        
        showLoading(use: self.listener?.eLoadingObser)
        
        self.saveButton.rx.tap.bind(onNext: weakify { wSelf in
            guard let text = wSelf.categoryValueLabel.text, let category = wSelf.currentSelectedSubCategory else {
                return
            }
            
            wSelf.listener?.setCategory(text: text, category: category)
        }).disposed(by: disposeBag)
        
    }
    
    func preProcessData(listCategory: [MerchantCategory]) {
        
        let listCategory = listCategory.compactMap({$0})
        for category in listCategory {
            source[category] = category.toTree()
        }
        
    }
    
    private func setupNavigation() {
        self.title  = "Danh mục"
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
            wSelf.listener?.addProductTypeMoveBack()
        }).disposed(by: disposeBag)
    }

    
}
