//  File name   : ProductMenuVC.swift
//
//  Author      : khoi tran
//  Created date: 12/9/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import Eureka
import RxSwift

protocol ProductMenuPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var item: ProductMenuItem? { get }
    var minValue: Int { get }
    
    func productMenuMoveBack()
    func productMenuConfirm(basketItem: BasketStoreValueProtocol?)
    
}

final class ProductMenuVC: FormViewController, ProductMenuPresentable, ProductMenuViewControllable {
    private struct Config {
        static let ProductMenuInfoCell = "ProductInfoCell"
        static let ProductMenuNoteCell = "ProductMenuCell"
    }
    
    /// Class's public properties.
    weak var listener: ProductMenuPresentableListener?

    // MARK: View's lifecycle
    override func loadView() {
        super.loadView()
        self.tableView = UITableView(frame: .zero, style: .grouped)
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
        tableView.showsVerticalScrollIndicator = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.setStatusBar(using: .lightContent)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        localize()
    }

    /// Class's private properties.
    private lazy var disposeBag = DisposeBag()
    
    lazy var headerView = ProductMenuHeaderView.loadXib()
    lazy var confirmButton = UIButton(frame: .zero)
    lazy var backButton = UIButton(frame: .zero)
    
    private var quantity: Int = 0
    
    override func tableView(_: UITableView, viewForFooterInSection _: Int) -> UIView? { return nil }
    override func tableView(_: UITableView, heightForFooterInSection s: Int) -> CGFloat { return 0.1 }
    
    override func tableView(_: UITableView, viewForHeaderInSection s : Int) -> UIView? {
        let view = s == 0 ?  nil : UIView.create{ $0.backgroundColor = .clear }
        return view
    }
    override func tableView(_: UITableView, heightForHeaderInSection s: Int) -> CGFloat {
        let height:CGFloat = s == 0 ?  0.1 :  10
        return height
    }
}

// MARK: View's event handlers
extension ProductMenuVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension ProductMenuVC {
}

// MARK: Class's private methods
private extension ProductMenuVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        tableView >>> {
            $0?.snp.makeConstraints({ (make) in
                make.top.equalToSuperview()
                make.left.right.bottom.equalToSuperview()
            })
        }

        let v =  UIView(frame: .zero)
        v.backgroundColor = .white
        headerView >>> v >>> {
            $0.snp.makeConstraints({ (make) in
               make.edges.equalToSuperview()
            })
        }
        headerView.setupDisplay(item: self.listener?.item?.product)
        
        let size = v.systemLayoutSizeFitting(CGSize(width: UIScreen.main.bounds.width, height: 200), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        
        v.frame = CGRect(origin: .zero, size: size)
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        tableView.tableHeaderView = v
        

        let section1 = Section() { (s) in
            s.tag = "Section1"
        }
        
        section1 <<< RowDetailGeneric<MenuInfoCell>.init(Config.ProductMenuInfoCell , { [weak self] (row) in
            guard let wSelf = self else { return }
            row.value = wSelf.listener?.item?.product
        })
        
        
        let section2 = Section() { (s) in
            s.tag = "Section2"
        }
        
        section2 <<< RowDetailGeneric<MenuNoteCell>.init(Config.ProductMenuNoteCell , { [weak self] (row) in
            guard let wSelf = self, let listener = wSelf.listener else { return }
            row.value = wSelf.listener?.item
            wSelf.quantity = wSelf.listener?.item?.basketItem?.quantity ?? 0
            row.cell.updateMinValue(listener.minValue)
            row.cell.editView!.value.bind(onNext: { (value) in
                 wSelf.quantity = value
            }).disposed(by: wSelf.disposeBag)
            
        })
        
        UIView.performWithoutAnimation {
            self.form += [section1, section2]
        }
        
        
        confirmButton >>> view >>> {
            $0.cornerRadius = 24
            $0.backgroundColor = #colorLiteral(red: 0.9588660598, green: 0.4115985036, blue: 0.1715823114, alpha: 1)
            $0.setTitle(Text.addToBasket.localizedText, for: .normal)
            $0.titleLabel?.textColor = .white
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.bottom.equalTo(-42)
                make.height.equalTo(48)
            })
        }
        
        backButton >>> view >>> {
            $0.snp.makeConstraints({ (make) in
                make.left.equalToSuperview()
                make.top.equalTo(44)
                make.width.equalTo(56)
                make.height.equalTo(44)
            })
            $0.setTitle("", for: .normal)
            $0.setImage(UIImage(named: "ic_food_menu_back"), for: .normal)
        }
        
    }
    
    private func setupRX() {
        backButton.rx.tap.bind { [weak self] () in
            guard let wSelf = self else { return }
            wSelf.listener?.productMenuMoveBack()
        }.disposed(by: disposeBag)
        
        confirmButton.rx.tap.bind {[weak self] () in
            guard let wSelf = self else { return }
            guard let row = wSelf.form.rowBy(tag: Config.ProductMenuNoteCell) as? RowDetailGeneric<MenuNoteCell> else {
                return
            }
            
            let basketItem = BasketProductIem(note: row.cell.getNote(), quantity: wSelf.quantity)
            
            wSelf.listener?.productMenuConfirm(basketItem: basketItem)
        }.disposed(by: disposeBag)
    }
}
