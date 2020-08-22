//  File name   : FoodDetailPromotionVC.swift
//
//  Author      : Dung Vu
//  Created date: 6/5/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import SnapKit
import FwiCore
import FwiCoreRX
import RxSwift
import RxCocoa

enum EcomDetailPromotionAction: Int {
    case back
    case apply
    case remove
}

final class FoodDetailPromotionVC: UIViewController {
    /// Class's public properties.

    // MARK: View's lifecycle
    @IBOutlet weak var containerHeader: UIView?
    @IBOutlet weak var lblNamePromotion: UILabel?
    @IBOutlet weak var lblExpireDate: UILabel?
    @IBOutlet weak var lblTitlePromotion: UILabel?
    @IBOutlet weak var lblDescriptionPromotion: UILabel?
    @IBOutlet weak var btnBack: UIButton?
    @IBOutlet weak var btnAction: UIButton?
    @IBOutlet weak var hButton: NSLayoutConstraint?
    
    @Published private var action: EcomDetailPromotionAction
    
    private var removed: Bool = false
    private lazy var disposeBag = DisposeBag()
    private lazy var bannerView = VatoScrollView<VatoBannerView<String>>.init(edge: .zero, sizeItem: CGSize(width: UIScreen.main.bounds.width, height: 208), spacing: 0, type: .banner)
    private var foodSales: PromotionEcomProtocol?
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        lblNamePromotion?.text = foodSales?.alias_name ?? foodSales?.name
        lblTitlePromotion?.text = foodSales?.name
        lblDescriptionPromotion?.text = foodSales?.description
        
        let canApply = foodSales?.canApply ?? false
        hButton?.constant = canApply ? 48 : 0
        var type: EcomDetailPromotionAction?
        if canApply {
            btnAction?.setTitle(FwiLocale.localized("Sử dụng ngay"), for: .normal)
            type = .apply
        }
        
        if removed {
            btnAction?.setTitle(FwiLocale.localized("Sử dụng sau"), for: .normal)
            type = .remove
        }
        
        if let t = type {
            btnAction?.rx.tap.bind(onNext: weakify({ (wSelf) in
                wSelf.action = t
            })).disposed(by: disposeBag)
        }
        
        if let expire = foodSales?.toDate {
            let date = Date(timeIntervalSince1970: expire / 1000)
            lblExpireDate?.text = "HSD: \(date.string(from: "dd/MM/yyyy"))"
        } else {
            lblExpireDate?.text = ""
        }
          
        bannerView.setupDisplay(item: foodSales?.campaignImages)
        btnBack?.rx.tap.bind(onNext: weakify({ (wSelf) in
            wSelf.action = .back
        })).disposed(by: disposeBag)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }

    /// Class's private properties.
}

// MARK: View's event handlers
extension FoodDetailPromotionVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    static func showDetailPromotion(on controllerVC: UIViewController?,
                                    foodSales: PromotionEcomProtocol?,
                                    removed: Bool = false) -> Observable<EcomDetailPromotionAction>
    {
        return Observable.create { (s) -> Disposable in
            let vc = FoodDetailPromotionVC.init(nibName: FoodDetailPromotionVC.identifier, bundle: nil)
            vc.foodSales = foodSales
            vc.removed = removed
            if #available(iOS 13, *) {
                vc.modalPresentationStyle = .automatic
            } else {
                vc.modalPresentationStyle = .fullScreen
            }
            vc.modalTransitionStyle = .coverVertical
            let dispose = vc.$action.take(1).subscribe(s)
            controllerVC?.present(vc, animated: true, completion: nil)
            return Disposables.create {
                dispose.dispose()
                vc.dismiss(animated: true, completion: nil)
            }
        }.delay(.milliseconds(300), scheduler: MainScheduler.asyncInstance)
    }
}

// MARK: Class's private methods
private extension FoodDetailPromotionVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        bannerView >>> containerHeader >>> {
            $0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
}
