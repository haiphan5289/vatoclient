//  File name   : OrderContractVC.swift
//
//  Author      : Phan Hai
//  Created date: 18/08/2020
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxSwift

enum ContractCarOrderType: Int, CaseIterable {
    case none = -1
    case history = 1
    case future = 0
    
    static var allCases: [ContractCarOrderType] {
        return [.history, .future]
    }
    
    var value: Int {
        switch self {
        case .future:
            return 2
        default:
            return 1
        }
    }
    
    var color: UIColor {
        switch self {
        case .future:
            return #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1)
        case .history:
            return #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 0.4)
        default:
            fatalError("Please Implement")
        }
    }
}

protocol OrderContractPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func moveBackCarContract()
    func moveToChatOC()
}

final class OrderContractVC: UIViewController, OrderContractPresentable, OrderContractViewControllable {
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: OrderContractPresentableListener?
    @IBOutlet weak var btFuture: UIButton!
    @IBOutlet weak var btHistory: UIButton!
    @IBOutlet weak var tableView: UITableView!
//    private var viewInformation: OCInformation = OCInformation.init(with: .seeMore)
    
    @IBOutlet weak var indicatorView: UIView!
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
    private let disposeBag = DisposeBag()
    /// Class's private properties.
}

// MARK: View's event handlers
extension OrderContractVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension OrderContractVC {
}

// MARK: Class's private methods
private extension OrderContractVC {
    private func localize() {
        // todo: Localize view's here.
        btFuture.setTitle(Text.departingSoon.localizedText, for: .normal)
        btHistory.setTitle(Text.tabbarHistory.localizedText, for: .normal)
    }
    private func visualize() {
        // todo: Visualize view's here.
        let buttonLeft = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 44, height: 44)))
        buttonLeft.setImage(UIImage(named: "ic_arrow_back"), for: .normal)
        buttonLeft.contentEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        let leftBarButton = UIBarButtonItem(customView: buttonLeft)
        navigationItem.leftBarButtonItem = leftBarButton
        buttonLeft.rx.tap.bind { _ in
            self.listener?.moveBackCarContract()
        }.disposed(by: disposeBag)
        title = Text.contractCarOrder.localizedText
        
        let buttonRight = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 44, height: 44)))
        buttonRight.setImage(UIImage(named: "ic_close_vato"), for: .normal)
        let rightBarButton = UIBarButtonItem(customView: buttonRight)
        navigationItem.rightBarButtonItem = rightBarButton
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(OrderContractCell.nib, forCellReuseIdentifier: OrderContractCell.identifier)
        tableView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
    }
    private func setupRX() {
        let bt1 = btFuture.rx.tap.map { _ in  ContractCarOrderType.future }
        let bt2 = btHistory.rx.tap.map { _ in  ContractCarOrderType.history }
        
        Observable.merge([bt1, bt2]).bind(onNext: weakify({ (type, wSelf) in
            wSelf.handle(type: type)
        })).disposed(by: disposeBag)
    }
    private func handle(type: ContractCarOrderType) {
        switch type {
        case .future:
            btFuture.isSelected = true
            btHistory.isSelected = false
        default:
            btFuture.isSelected = false
            btHistory.isSelected = true
        }
        let width = self.view.bounds.width / 2
        UIView.animate(withDuration: 0.5) {
            self.indicatorView.transform = CGAffineTransform(translationX: CGFloat(type.rawValue) * width, y: 0)
        }
    }
}
extension OrderContractVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: OrderContractCell.identifier) as! OrderContractCell
        cell.btChat = { [weak self] in
            guard let wSelf = self  else {
                return
            }
            wSelf.listener?.moveToChatOC()
        }
        return cell
    }
}
