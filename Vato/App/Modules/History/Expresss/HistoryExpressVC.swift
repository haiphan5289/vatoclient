//  File name   : HistoryExpressVC.swift
//
//  Author      : Dung Vu
//  Created date: 12/26/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import Eureka
import SnapKit
import FwiCore
import FwiCoreRX
import RxSwift
import RxCocoa

final class HistoryExpressVC: UIViewController {
    /// Class's public properties.
    weak var listener: HistoryListenerProtocol?
    private lazy var searchView = FoodSearchHeaderView.loadXib()
    private lazy var tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .plain)
        t.separatorStyle = .none
        t.backgroundColor = .white
        return t
    }()
    private lazy var disposeBag = DisposeBag()
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
    
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
        listener?.history(hiddenBottomLine: true)
    }

    /// Class's private properties.
    private var lableFilter: UILabel?
    private var buttonFilter: UIButton?
}

extension HistoryExpressVC : UITableViewDelegate {
    func tableView(_: UITableView, viewForFooterInSection _: Int) -> UIView? { return nil }

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat { return 0.1 }

    func tableView(_: UITableView, heightForFooterInSection _: Int) -> CGFloat { return 0.1 }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.listener?.detail(item: .express(id: ""))
    }
}

extension HistoryExpressVC : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HistoryExpressTVC.identifier) as? HistoryExpressTVC else {
            fatalError("Please Implement")
        }
        
//        let item = sourceSection[indexPath.section].item.items[safe: indexPath.row]
//        cell.setupDisplay(item: item)
        return cell
    }
}

// MARK: View's event handlers
extension HistoryExpressVC: RequestInteractorProtocol {
    var token: Observable<String> {
        guard let token = listener?.authenticated.firebaseAuthToken else {
            fatalError("Please Implement")
        }
        return token.take(1)
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's private methods
private extension HistoryExpressVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        searchView.removeBtnBack()
        searchView >>> view >>> {
            $0.snp.makeConstraints { (make) in
                make.top.equalToSuperview()
                make.left.equalTo(16)
                make.right.equalTo(5)
                make.height.equalTo(44)
            }
        }
        
        let lineView = UIView(frame: CGRect.zero)
        lineView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        lineView >>> view >>> {
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(searchView.snp.bottom).offset(0)
                make.left.right.equalToSuperview()
                make.height.width.equalTo(10)
            }
        }
        
        let iconFilter = UIImageView(frame: CGRect.zero)
        iconFilter.image = UIImage(named: "ic_filter")
        iconFilter >>> view >>> {
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(lineView.snp.bottom).offset(13)
                make.left.equalTo(16)
                make.height.width.equalTo(24)
            }
        }
        
        let _lableFilter = UILabel(frame: CGRect.zero)
        _lableFilter.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
        _lableFilter.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        _lableFilter.text = "Tất cả(25)"
        _lableFilter >>> view >>> {
            $0.snp.makeConstraints { (make) in
                make.left.equalTo(iconFilter.snp.right).offset(8)
                make.centerY.equalTo(iconFilter.snp.centerY)
            }
        }
        self.lableFilter = _lableFilter
        
        let _buttonFilter = UIButton(frame: CGRect.zero)
        _buttonFilter >>> view >>> {
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(iconFilter.snp.top)
                make.left.equalTo(iconFilter.snp.left)
                make.bottom.equalTo(iconFilter.snp.bottom)
                make.right.equalTo(_lableFilter.snp.right)
            }
        }
        self.buttonFilter = _buttonFilter
        
        tableView >>> view >>> {
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(iconFilter.snp.bottom).offset(16)
                make.left.right.bottom.equalToSuperview()
            }
        }
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        // tableView.register(HistoryExpressTVC.self, forCellReuseIdentifier: HistoryExpressTVC.identifier)
        tableView.register(HistoryExpressTVC.nib, forCellReuseIdentifier: HistoryExpressTVC.identifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
    private func setupRX() {
          // todo: Visualize view's here.
          self.buttonFilter?.rx.tap.bind(onNext: { [weak self] (_) in
            self?.performSegue(withIdentifier: "ExpressShowFilter", sender: nil)
              print("buttonFilter tap")
          }).disposed(by: self.disposeBag)
      }
}
