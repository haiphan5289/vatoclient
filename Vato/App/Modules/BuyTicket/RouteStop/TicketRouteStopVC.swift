//  File name   : TicketRouteStopVC.swift
//
//  Author      : khoi tran
//  Created date: 4/28/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxSwift
import SnapKit


protocol TicketRouteStopPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    
    var listRouteStop: Observable<[RouteStop]> { get }
    var currentRouteStopId: Int? { get }
    func dismissRouteStop()
    func didSelectRouteStop(routeStop: RouteStop)
}

final class TicketRouteStopVC: UIViewController, TicketRouteStopPresentable, TicketRouteStopViewControllable {
    private struct Config {
        static let rowHeight: CGFloat = 90
    }
    
    /// Class's public properties.
    weak var listener: TicketRouteStopPresentableListener?

    // MARK: View's lifecycle
    override func loadView() {
        super.loadView()
        
        
        tableView.register(TicketRouteStopTVC.nib, forCellReuseIdentifier: TicketRouteStopTVC.identifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let rect = containerView.bounds
        let benzier = UIBezierPath(roundedRect: rect, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 8, height: 8))
        let shape = CAShapeLayer()
        shape.frame = rect
        shape.fillColor = UIColor.blue.cgColor
        shape.path = benzier.cgPath
        containerView.layer.mask = shape
    }
    
    /// Class's private properties.
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var btnClose: UIButton!
    
    @IBOutlet var containerView: UIView!

    private var source: [RouteStop] = []
    private lazy var noItemView = NoItemView(imageName: "ic_food_noItem", message: Text.noStoreFound.localizedText, on: self.tableView)
    private var disposeBag = DisposeBag()
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    
}

// MARK: View's event handlers
extension TicketRouteStopVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension TicketRouteStopVC {
}

// MARK: Class's private methods
private extension TicketRouteStopVC {
    
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        lblTitle.text = Text.listPickupAddress.localizedText
    }
    
    private func setupRX() {
        self.listener?.listRouteStop.observeOn(MainScheduler.asyncInstance).bind(onNext: {[weak self] (listRouteStop) in
            guard let wSelf = self else { return }
            wSelf.source = listRouteStop
            wSelf.tableView.reloadData()
            
            if wSelf.source.isEmpty {
                wSelf.noItemView.attach()
            } else {
                wSelf.noItemView.detach()
            }
                        
            let numDisplayRow = min(max(listRouteStop.count, 3), 6)
            UIView.animate(withDuration: 0.2) {
                wSelf.tableViewHeight.constant = CGFloat(numDisplayRow) * Config.rowHeight
                wSelf.view.layoutIfNeeded()
            }
        }).disposed(by: disposeBag)
        
        self.btnClose.rx.tap.bind { [weak self] in
            guard let wSelf = self else { return }
            wSelf.listener?.dismissRouteStop()
        }.disposed(by: disposeBag)
    }
}


extension TicketRouteStopVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Config.rowHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return source.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TicketRouteStopTVC.identifier, for: indexPath) as? TicketRouteStopTVC else {
            fatalError("Error")
        }
        
        let route = source[indexPath.row]
        cell.setupDisplay(item: route)
        
        if self.listener?.currentRouteStopId == route.id {
            cell.backgroundColor = #colorLiteral(red: 0.9960784314, green: 0.9490196078, blue: 0.937254902, alpha: 1)
            cell.imvSelected.isHidden = false
        } else {
            cell.backgroundColor = .white
            cell.imvSelected.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.listener?.didSelectRouteStop(routeStop: source[indexPath.row])
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    
    
}
