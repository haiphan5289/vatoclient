//  File name   : TicketBusStationVC.swift
//
//  Author      : Dung Vu
//  Created date: 10/1/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import SnapKit
import RxSwift
import FwiCoreRX

protocol TicketBusStationPresentableListener: class {
    var listDataObservable: Observable<[Any]>  { get }
    func getListBus(with originCode: String?, destinationCode: String?)
    func getListStop(with routeStopParam: ChooseRouteStopParam?)
    func moveNext(with busStation: TicketRoutes)
    func moveNext(with routeStop: RouteStop)
    func moveBack()
    var eLoadingObser: Observable<(Bool, Double)> { get }
    var error: Observable<BuyTicketPaymenState> {get}
}

final class TicketBusStationVC: UIViewController, TicketBusStationPresentable, TicketBusStationViewControllable, LoadingAnimateProtocol, DisposableProtocol {
    private struct Config {

    }
    
    internal lazy var disposeBag = DisposeBag()
    
    /// Class's public properties.
    weak var listener: TicketBusStationPresentableListener?
    private lazy var contentTableView = UITableView(frame: .zero)
    private lazy var noItemView = NoItemView(imageName: "empty",
                                             message: Text.donotHaveTrip.localizedText,
                                             on: self.contentTableView)
    /// Class's constructors.
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(viewType: BusStationType, busParam: ChooseBusStationParam?, stopParam: ChooseRouteStopParam?) {
        self.viewType = viewType
        self.busStationParam = busParam
        self.routeStopParam = stopParam
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        registerCell()
        setupRX()
        
        if viewType == .ticketRoute {
            self.listener?.getListBus(with: self.busStationParam?.originCode, destinationCode: self.busStationParam?.destinationCode)
        } else if viewType == .routeStop {
            self.listener?.getListStop(with: self.routeStopParam)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
        setupNavigation()
    }

    /// Class's private properties.
    //dataSource
    //1. BusType.ticketRoute -> TicketRoutes
    //2. BusType.routeStop -> RouteStop
    private var busStationParam: ChooseBusStationParam?
    private var routeStopParam: ChooseRouteStopParam?
    private var dataSource = [Any]()
    private var viewType = BusStationType.ticketRoute
    
    private var selectedTicketRoute: TicketRoutes?
    private var selectedRouteStop: RouteStop?
}

// MARK: View's event handlers
extension TicketBusStationVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension TicketBusStationVC {
    func showCheckShowEmtyView() {
        self.dataSource.count > 0 ? noItemView.detach() : noItemView.attach()
    }
}

// MARK: Class's private methods
private extension TicketBusStationVC {
    private func localize() {
        // todo: Localize view's here.
        self.title = (viewType == BusStationType.ticketRoute) ? Text.selectRoute.localizedText : Text.selectLocationPickUp.localizedText
    }
    
    private func visualize() {
        // todo: Visualize view's here.
        
        view.backgroundColor = .white
        
        contentTableView >>> view >>> {
            $0.showsVerticalScrollIndicator = false
            $0.rowHeight = UITableView.automaticDimension
            $0.separatorStyle = .none
            
            
            $0.estimatedRowHeight = 52.0
            $0.rowHeight = UITableView.automaticDimension
            
            $0.snp.makeConstraints({ (make) in
                make.top.left.right.equalToSuperview()
                make.bottom.equalTo(view.layoutMarginsGuide.snp.bottom)
            })
        }
    }
    
    private func registerCell() {
        contentTableView.register(BusStationTableViewCell.self, forCellReuseIdentifier: BusStationTableViewCell.identifier)
    }
    
    private func setupRX() {
        
        self.listener?.listDataObservable.subscribe(onNext: { [weak self] (array) in
            self?.dataSource = array
        }).disposed(by: disposeBag)
    
        self.listener?.listDataObservable.bind(to: contentTableView.rx.items(cellIdentifier: "BusStationTableViewCell", cellType: BusStationTableViewCell.self)) { [weak self] (row, element, cell) in
            if self?.viewType == BusStationType.ticketRoute {
                guard let item = element as? TicketRoutes else { return }
                let isSeleted = item.id == self?.selectedTicketRoute?.id ? true : false
                let title = "\(item.name ?? "") (\(item.price?.currency ?? ""))"
                cell.update(with: title, subTitle: nil, distance: nil, isSeleted: isSeleted)
                
            } else if self?.viewType == BusStationType.routeStop {
                guard let item = element as? RouteStop else { return }
                cell.update(with: item.name, subTitle: item.address, distance: item.distance)
            
                if row % 2 == 0 {
                    cell.backgroundColor = .white
                } else {
                    cell.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.3254901961, blue: 0.1333333333, alpha: 0.04)
                }
            }
            
        }.disposed(by: disposeBag)
        
        contentTableView.rx.itemSelected.bind { [weak self] idx in
            guard let wSelf = self else { return }
            if wSelf.viewType == BusStationType.ticketRoute {
                guard let ticket = wSelf.dataSource[idx.row] as? TicketRoutes else { return }
                wSelf.selectedTicketRoute = ticket
                wSelf.listener?.moveNext(with: ticket)
            } else if self?.viewType == BusStationType.routeStop {
                guard let stop = wSelf.dataSource[idx.row] as? RouteStop else { return }
                wSelf.selectedRouteStop = stop
                wSelf.listener?.moveNext(with: stop)
            }
        }.disposed(by: disposeBag)
        
        listener?.error.bind(onNext: {[weak self] (errorType) in
                   AlertVC.showError(for: self, message: errorType.getMsg())
               }).disposed(by: disposeBag)
        
        showLoading(use: self.listener?.eLoadingObser)

    }
    
    private func setupNavigation() {
        let navigationBar = self.navigationController?.navigationBar
        let bgImage = UIImage(named:"bg_navigationbar")?.stretchableImage(withLeftCapWidth: 0, topCapHeight: 0)
        navigationBar?.setBackgroundImage(bgImage, for: .default)
        navigationBar?.isTranslucent = false
        navigationBar?.tintColor = .white
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        let image = UIImage(named: "ic_arrow_back")
        let leftButton = UIButton(frame: CGRect(origin: .zero, size: image?.size ?? .zero))
        leftButton.setImage(image, for: .normal)
        leftButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
        let leftBarButton = UIBarButtonItem(customView: leftButton)
        navigationItem.leftBarButtonItem = leftBarButton
        leftButton.rx.tap.bind(onNext: weakify { wSelf in
            wSelf.listener?.moveBack()
        }).disposed(by: disposeBag)
    }
}
