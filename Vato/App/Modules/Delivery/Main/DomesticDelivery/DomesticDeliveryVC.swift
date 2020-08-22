//
//  DomesticDeliveryVCViewController.swift
//  Vato
//
//  Created by khoi tran on 12/17/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit
import Eureka
import RxSwift
import FwiCore
import SnapKit
import FwiCoreRX

protocol DomesticDeliveryVCProtocol: class {
    func routeToFillInfomation(item: DeliveryInputInformation?)
    func removeDeliveryItem(item: DeliveryInputInformation?)
    func showBookingView()
}


class DomesticDeliveryVC: FormViewController, DisposableProtocol {
    internal var disposeBag: DisposeBag = DisposeBag()
    

    private struct Config {
        static let DeliveryCellIdentifier = "DeliveryCellIdentifier"
    }
    
    
    override func loadView() {
        super.loadView()
        self.tableView = UITableView(frame: .zero, style: .grouped)
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
        tableView.showsVerticalScrollIndicator = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        visualize()
        setupRX()
    }
    
    
    private lazy var sourceBanner: ReplaySubject<[BannerProtocol]> = ReplaySubject.create(bufferSize: 1)
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    private lazy var footerView: FoodBannerView = {
        let view = FoodBannerView.loadXib()
        view.roundAll = true
        return view
    }()
    
    weak var listener: DomesticDeliveryVCProtocol?
    private var btnNext: UIButton?

}

extension DomesticDeliveryVC {
    private func visualize() {
        view.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        
        
        let button = UIButton(frame: .zero)
        button >>> view >>> {
            $0.setBackground(using: Color.orange, state: .normal)
            $0.setTitleColor(.white, for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            $0.layer.cornerRadius = 8
            $0.clipsToBounds = true
            $0.setTitle(Text.continue.localizedText, for: .normal)
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.bottom.equalTo(-20)
                make.height.equalTo(48)
            })
        }
        button.isEnabled = false
        button.rx.tap.bind(onNext: weakify({ (wSelf) in
            wSelf.listener?.showBookingView()
        })).disposed(by: disposeBag)
        self.btnNext = button
        
        tableView >>> view >>> {
            $0.snp.makeConstraints({ (make) in
                make.top.left.right.equalToSuperview()
                make.bottom.equalTo(btnNext!.snp.top).offset(-10)
            })
        }
    }
    
    private func setupRX() {
        BannerManager.instance.requestBanner(type: VatoServiceAction.delivery.rawValue).bind(onNext: weakify({ (list, wSelf) in
            wSelf.sourceBanner.onNext(list)
        })).disposed(by: disposeBag)
        
        sourceBanner.observeOn(MainScheduler.asyncInstance).bind(onNext: weakify({ (list, wSelf) in
            guard !list.isEmpty else {
                wSelf.tableView.tableFooterView = nil
                return
            }
            
            let v = UIView(frame: .zero)
            v.backgroundColor = .white
            
            wSelf.footerView >>> v >>> {
                $0.setupDisplay(item: list)
                $0.snp.makeConstraints({ (make) in
                    make.top.equalToSuperview()
                    make.left.equalTo(16)
                    make.right.equalTo(-16)
                    make.height.equalTo(FoodBannerView.height)
                    make.bottom.equalTo(-16).priority(.high)
                })
                
                $0.callback = { [weak self] item in
                    guard let item = item as? BannerProtocol, let url = item.url else {
                        return
                    }
                    WebVC.loadWeb(on: self, url: url, title: nil)
                }
            }
            v.addSeperator(with: .zero, position: .top)
            v.addSeperator(with: .zero, position: .bottom)
            
            let s = v.systemLayoutSizeFitting(CGSize(width: UIScreen.main.bounds.width, height: .infinity), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
            v.frame = CGRect(origin: .zero, size: s)
            
            wSelf.tableView.tableFooterView = v
        })).disposed(by: disposeBag)
    }
}


extension DomesticDeliveryVC {
    public func applyDelivery(d: [DestinationDisplayProtocol]) {
        
        self.btnNext?.isEnabled = !d.isEmpty
        
        UIView.performWithoutAnimation {
            self.form.removeAll()
        }
        
        let section = Section() { (s) in
            s.tag = "Section"
        }
        // first row
        section <<< self.createAddingDeliveryCell(item: DeliveryInputInformation.init(type: .receiver) as DestinationDisplayProtocol)
        
        for item in d {
            section <<< self.createDeliveryCell(item: item)
        }
        
        UIView.performWithoutAnimation {
            self.form += [section]
        }
        
        tableView.tableFooterView?.isHidden = d.count >= 1
    }
    
    private func createAddingDeliveryCell(item: DestinationDisplayProtocol) -> RowDetailGeneric<DeliveryInformationCell> {
        return RowDetailGeneric<DeliveryInformationCell>.init(Config.DeliveryCellIdentifier , { [weak self] (row) in
            row.value = item as? DeliveryInputInformation
            row.onCellSelection({ [weak self] (cell, row) in
                guard let me = self, let listener = me.listener else { return }
                listener.routeToFillInfomation(item: row.value)
            })
            row.cell.updateData(item: item)
        })
    }
    
    private func createDeliveryCell(item: DestinationDisplayProtocol) -> RowDetailGeneric<DomesticDeliveryInformationCell> {
        return RowDetailGeneric<DomesticDeliveryInformationCell>.init(Config.DeliveryCellIdentifier , { [weak self] (row) in
            row.cell.contentView.addSeperator(with: UIEdgeInsets(top: 0, left: 48, bottom: 0, right: 0), position: .bottom)
            row.value = item as? DeliveryInputInformation
            row.onCellSelection({ [weak self] (cell, row) in
                guard let me = self, let listener = me.listener else { return }
                listener.routeToFillInfomation(item: row.value)
            })
            row.cell.updateData(item: item)
            guard let me = self else { return }
            row.cell.rightIconButton.rx.tap.bind(onNext: { [weak self] in
                guard let me = self else { return }
                me.listener?.removeDeliveryItem(item: item as? DeliveryInputInformation)
            }).disposed(by: me.disposeBag)
        })
    }
}


