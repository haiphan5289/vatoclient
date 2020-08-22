//  File name   : AddDestinationConfirmVC.swift
//
//  Author      : Dung Vu
//  Created date: 3/20/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import Eureka
import RxSwift
import RxCocoa
import FwiCoreRX

protocol AddDestinationConfirmPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var points: Observable<[DestinationPoint]> { get }
    var details: Observable<[PriceInfoDisplayStyle]> { get }
    var type: AddNewDestinationType { get }
    var loadingProgress: Observable<ActivityProgressIndicator.Element> { get }
    
    func addDestinationMoveBack()
    
    func submitAddDestination()
    func dismissAddDestination()
}

final class AddDestinationConfirmVC: FormViewController, AddDestinationConfirmPresentable, AddDestinationConfirmViewControllable, LoadingAnimateProtocol, DisposableProtocol {
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: AddDestinationConfirmPresentableListener?
    internal lazy var disposeBag = DisposeBag()
    
    override func loadView() {
        super.loadView()
        self.tableView = UITableView(frame: .zero, style: .grouped)
        let w = UIScreen.main.bounds.width / 2
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: w, bottom: 0, right: w)
        self.tableView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
    }
    
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationItem.setHidesBackButton(true, animated: true)
    }

    /// Class's private properties.
    let btnCancel: UIButton = UIButton(frame: .zero)
    let btnAgree: UIButton = UIButton(frame: .zero)
    
    override func tableView(_: UITableView, viewForFooterInSection _: Int) -> UIView? {
        return nil
    }
    override func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat { return 0.1 }

    override func tableView(_: UITableView, heightForFooterInSection _: Int) -> CGFloat { return 0.1 }

    override func tableView(_: UITableView, viewForHeaderInSection _: Int) -> UIView? { return nil }
}

// MARK: View's event handlers
extension AddDestinationConfirmVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension AddDestinationConfirmVC {
    func showAlert(error message: String) {
        let dismissAction = AlertAction(style: .cancel, title: Text.cancel.localizedText, handler: weakify({ (wSelf) in
            wSelf.listener?.addDestinationMoveBack()
        }))
        
        AlertVC.show(on: self,
                     title: Text.error.localizedText,
                     message: message,
                     from: [dismissAction],
                     orderType: .horizontal)
    }
    
    func resetUI() {
        guard let section = self.form.sectionBy(tag: "Detail") else { return }
        section.removeAll()
    }
}

// MARK: Class's private methods
private extension AddDestinationConfirmVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        let navigationBar = self.navigationController?.navigationBar
        let bgImage = UIImage(named:"bg_navigationbar")?.stretchableImage(withLeftCapWidth: 0, topCapHeight: 0)
        navigationBar?.setBackgroundImage(bgImage, for: .default)
        navigationBar?.barTintColor = Color.orange
        navigationBar?.isTranslucent = false
        navigationBar?.tintColor = .white
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        title = listener?.type.title
        view.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        let image = UIImage(named: "ic_arrow_back")
        let leftButton = UIButton(frame: CGRect(origin: .zero, size: image?.size ?? .zero))
        leftButton.setImage(image, for: .normal)
        leftButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
        let leftBarButton = UIBarButtonItem(customView: leftButton)
        navigationItem.leftBarButtonItem = leftBarButton
        leftButton.rx.tap.bind(onNext: weakify { wSelf in
            wSelf.listener?.dismissAddDestination()
        }).disposed(by: disposeBag)
        
        // Add button
        let text = listener?.type.titleButton
        btnCancel.applyButton(style: StyleButton(view: .cancel, textColor: #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1), font: .systemFont(ofSize: 16, weight: .medium), cornerRadius: 24, borderWidth: 1, borderColor: #colorLiteral(red: 0.7529411765, green: 0.7764705882, blue: 0.8, alpha: 1)))
        btnCancel.setTitle(text?.cancel, for: .normal)
        
        btnAgree.applyButton(style: StyleButton(view: .default, textColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), font: .systemFont(ofSize: 16, weight: .medium), cornerRadius: 24, borderWidth: 1, borderColor: .clear))
        btnAgree.setTitle(text?.accept, for: .normal)
        
        let stackView = UIStackView(arrangedSubviews: [btnCancel, btnAgree])
        stackView >>> view >>> {
            $0.distribution = .fillEqually
            $0.axis = .horizontal
            $0.spacing = 16
            $0.snp.makeConstraints { (make) in
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.bottom.equalTo(view.layoutMarginsGuide.snp.bottom).offset(-16)
                make.height.equalTo(48)
            }
        }
        
        // Table view
        tableView >>> view >>> {
            $0.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.bottom.equalTo(stackView.snp.top)
            }
        }
        let section = Section.init { (s) in
            s.tag = "Detail"
        }
        UIView.performWithoutAnimation {
            self.form += [section]
        }
    }
    
    func setupRX() {
        showLoading(use: listener?.loadingProgress)
        listener?.points.bind(onNext: weakify({ (points, wSelf) in
            guard let section = wSelf.form.sectionBy(tag: "Detail") else { return }
            points.enumerated().forEach { (p) in
                let cell = RowDetailGeneric<AddDestinationCell>.init("AddDestinationCell\(p.offset)") { (row) in
                    row.value = p.element
                    row.cell.setupDisplay(item: p.element)
                }
                section <<< cell
            }
        })).disposed(by: disposeBag)
        
        listener?.details.bind(onNext: weakify({ (details, wSelf) in
            guard let section = wSelf.form.sectionBy(tag: "Detail") else { return }
            let cell = RowDetailGeneric<AddDestinationPriceCell>.init("AddDestinationPriceCell") { (row) in
                row.value = details
                row.cell.setupDisplay(item: details)
            }
            section <<< cell
        })).disposed(by: disposeBag)
                        
        btnCancel.rx.tap.bind(onNext: weakify({ (wSelf) in
            wSelf.listener?.dismissAddDestination()
        })).disposed(by: disposeBag)
        
        btnAgree.rx.tap.bind(onNext: weakify({ (wSelf) in
            wSelf.listener?.submitAddDestination()
        })).disposed(by: disposeBag)
    }
}
