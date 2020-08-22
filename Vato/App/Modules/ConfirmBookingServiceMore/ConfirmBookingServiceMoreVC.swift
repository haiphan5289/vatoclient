//  File name   : ConfirmBookingServiceMoreVC.swift
//
//  Author      : MacbookPro
//  Created date: 11/15/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxSwift
import RxCocoa

protocol ConfirmBookingServiceMorePresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func dismiss()
    func getListServiceMore(arrayServiceMore: [AdditionalServices])
    var listAdditionalServiceObserable: Observable<[AdditionalServices]> {get}
    var currentSelectedService: [AdditionalServices] { get }
}

final class ConfirmBookingServiceMoreVC: UIViewController, ConfirmBookingServiceMorePresentable, ConfirmBookingServiceMoreViewControllable {
    private struct Config {
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var heightTableView: NSLayoutConstraint!
    @IBOutlet weak var btDismiss: UIButton!
    @IBOutlet weak var btConfirm: UIButton!
    @IBOutlet weak var lbTitleServiceMore: UILabel!
    @IBOutlet weak var viewInfo: UIView!
    private lazy var mContainer: HeaderCornerView = {
        let v = HeaderCornerView(with: 7)
        v.containerColor = .white
        return v
    }()
    /// Class's public properties.
    weak var listener: ConfirmBookingServiceMorePresentableListener?
//    var dataSource: [ServiceMore] = []
    var dataSource: [AdditionalServices] = []
    var arraySelect: [AdditionalServices] = []
    private var disposeBag = DisposeBag()
    private var maxCellDisPlay = 5

    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: ConfirmBookingServiceMoreCell.identifier, bundle: nil), forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.allowsMultipleSelection = true
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
extension ConfirmBookingServiceMoreVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension ConfirmBookingServiceMoreVC {
}

// MARK: Class's private methods
private extension ConfirmBookingServiceMoreVC {
    private func localize() {
        // todo: Localize view's here.
        lbTitleServiceMore.text = Text.serviceMore.localizedText
        btConfirm.setTitle(Text.confirm.localizedText, for: .normal)
    }
    private func visualize() {
        // todo: Visualize view's here.
        self.view.isHidden = true

        UIView.animate(withDuration: 0, animations: {
            self.tableView.layoutIfNeeded()
        }) { (complete) in
            var heightOfTableView: CGFloat = 0.0
            let cells = self.tableView.visibleCells
            let count = min(cells.count, self.maxCellDisPlay)
            for (index, element) in cells.enumerated() {
                if index < count {
                    heightOfTableView += element.frame.height
                }
            }
            self.heightTableView.constant = heightOfTableView
            self.view.isHidden = false
            self.view.layoutIfNeeded()
        }
        
        
        viewInfo.backgroundColor = .clear
        viewInfo.insertSubview(mContainer, at: 0)
        mContainer >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
    }
    
    
    private func setupRX(){
        self.listener?.listAdditionalServiceObserable.subscribe(onNext: { [weak self] (value) in
            guard let me = self else { return }
            me.dataSource = value
            if me.dataSource.count <= me.maxCellDisPlay {
                me.tableView.isScrollEnabled = false
            } else {
                me.tableView.isScrollEnabled = true
            }

            me.arraySelect.removeAll()
            me.tableView.reloadData()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let currentSelectedService = me.listener?.currentSelectedService {
                    var index = 0
                    for selectedService in me.dataSource {
                        if currentSelectedService.contains(where: { (a) -> Bool in
                            a.id == selectedService.id && a.changeable == true
                        }) {
                            me.tableView.selectRow(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .none)
                        }
                        index += 1
                    }
                }
            }
            
        }).disposed(by: disposeBag)
        
        self.listener?.listAdditionalServiceObserable.asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: "cell",cellType: ConfirmBookingServiceMoreCell.self)) { row, model, cell in
                cell.visualizeCell(model: model)
            }.disposed(by: disposeBag)
        
        
        self.btDismiss.rx.tap.bind { [weak self] _ in
            self?.listener?.dismiss()
        }.disposed(by: disposeBag)
        
        self.btConfirm.rx.tap.bind { [weak self] _ in
            guard let me = self else { return }
            me.arraySelect.removeAll()
            
            for item in me.dataSource {
                if item.changeable == false {
                    me.arraySelect.append(item)
                } else {}
            }
//
            let indexPaths = me.tableView.indexPathsForSelectedRows
            
            if let indexPaths = indexPaths {
                let a = indexPaths.map({ (index) -> AdditionalServices in
                    return me.dataSource[index.row]
                })                
                me.arraySelect.append(contentsOf: a)
            }
            me.listener?.getListServiceMore(arrayServiceMore: me.arraySelect)
        }.disposed(by: disposeBag)
    }
    
    
}
extension ConfirmBookingServiceMoreVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if self.dataSource[indexPath.row].changeable == false {
            return nil
        }
        return indexPath
    }
}
