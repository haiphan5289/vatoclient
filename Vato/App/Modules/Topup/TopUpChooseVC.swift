//  File name   : TopUpChooseVC.swift
//
//  Author      : Dung Vu
//  Created date: 11/19/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import RxCocoa
import RxSwift
import Eureka
import FwiCore

protocol DummyMethodProtocol {}
class DummyTopupMethod: NSObject, TopupLinkConfigureProtocol, DummyMethodProtocol {
    func clone() -> TopupLinkConfigureProtocol {
        let clone = DummyTopupMethod()
        clone.type = self.type
        clone.name = self.name
        clone.url = self.url
        clone.auth = self.auth
        clone.active = self.active
        clone.iconURL = self.iconURL
        clone.min = self.min
        clone.max = self.max
        clone.options = self.options
        return clone
    }
    
    var type: Int = -1
    var name: String?
    var url: String?
    var auth: Bool = false
    var active: Bool = false
    var iconURL: String?
    var min: Int = 0
    var max: Int = 0
    var options: [Double]?
}

protocol TopUpHandlerResultProtocol: AnyObject {
    func topHandlerResult()
}

@objcMembers
final class TopUpChooseVC: FormViewController {
    struct TopUpConfig {
        static let title: String = Text.depositMethod.localizedText
    }
    
    /// Class's public properties.
    private var items: [TopupCellModel] = []
    private lazy var disposeBag: DisposeBag = DisposeBag()
    weak var listener: TopUpHandlerResultProtocol?
    private var paymentStream: MutablePaymentStream?
    convenience init(with items: [TopupLinkConfigureProtocol], paymentStream: MutablePaymentStream? = nil) {

        self.init(style: .grouped)
        var currentItems = items
            .filter({ $0.active })
        
        self.items = currentItems
            .map({ TopupCellModel.init(item: $0) })
        self.paymentStream = paymentStream

    }

    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = .clear
        self.view.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        visualize()
        
        NotificationCenter.default.rx.notification(.topupSuccess).bind(onNext: weakify({ (_, wSelf) in
            guard let listener = wSelf.listener else {
                return
            }
            listener.topHandlerResult()
        })).disposed(by: disposeBag)
    }
    
    private func visualize() {
        self.title = TopUpConfig.title
        self.tableView.separatorStyle = .none
        self.navigationController?.navigationBar.tintColor = .white
        let item = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_back").withRenderingMode(.alwaysTemplate), landscapeImagePhone: #imageLiteral(resourceName: "ic_back").withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: nil)
        self.navigationItem.leftBarButtonItem = item
        item.rx.tap.bind { [weak self] in
            let count = self?.navigationController?.viewControllers.count ?? 0
            if count > 1 {
                self?.navigationController?.popViewController(animated: true)
            } else {
                self?.dismiss(animated: true, completion: nil)
            }
            
        }.disposed(by: disposeBag)
        
        let section = Section()
        self.form +++ section
        
        self.items.enumerated().forEach { (idx, model) in
            section <<< TopupRow("row at \(idx)", {
                $0.value = model
                $0.onCellSelection({ [weak self](cell, row) in
                    self?.handler(select: row.value)
                })
            })
        }
    }
    
    private func handler(select: TopupCellModel?) {
        guard let model = select, let type = model.item.topUpType else {
            return
        }
        defer {
            TrackingHelper.trackEvent("ToupChannel", value: ["Channel": type.name])
        }
        switch type {
        case .napas:
//            let webVC = FCNewWebViewController()
//            self.navigatiotopnController?.present(webVC, animated: true, completion: {
//                webVC.loadWebview(withConfigure: model.item)
//            })
//            let topupThirdPartyVC = TopUpByThirdPartyVC(model: model, paymentStream: paymentStream)
//            self.navigationController?.pushViewController(topupThirdPartyVC, animated: true)
            break
        case .zaloPay:
//            let topupThirdPartyVC = TopUpByThirdPartyVC(model: model)
//            self.navigationController?.pushViewController(topupThirdPartyVC, animated: true)
            break
        case .momoPay:
//            let topupThirdPartyVC = TopUpByThirdPartyVC(model: model)
//            self.navigationController?.pushViewController(topupThirdPartyVC, animated: true)
            break
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    /// Class's private properties.
}



