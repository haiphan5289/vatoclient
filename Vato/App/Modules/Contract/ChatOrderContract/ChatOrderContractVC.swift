//  File name   : ChatOrderContractVC.swift
//
//  Author      : Phan Hai
//  Created date: 21/08/2020
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxSwift
import FwiCore
import FwiCoreRX

protocol ChatOrderContractPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func moveBackOC()
}

final class ChatOrderContractVC: UIViewController, ChatOrderContractPresentable, ChatOrderContractViewControllable {
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: ChatOrderContractPresentableListener?

    @IBOutlet weak var btSend: UIButton!
    @IBOutlet weak var tfTyping: UITextField!
    @IBOutlet weak var tableView: UITableView!
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
        self.tableView.sectionHeaderHeight = UITableView.automaticDimension
        self.tableView.estimatedSectionHeaderHeight = 1000
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ChatOrderContractCell.nib, forCellReuseIdentifier: ChatOrderContractCell.identifier)
        self.view.addGestureRecognizer(tap)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }
    
    @IBOutlet weak var hViewTyping: NSLayoutConstraint!
    private let tap: UITapGestureRecognizer = UITapGestureRecognizer()
    private let viewOCInfo: OCInformation = OCInformation.loadXib()
    private let disposeBag = DisposeBag()

    /// Class's private properties.
}

// MARK: View's event handlers
extension ChatOrderContractVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension ChatOrderContractVC {
}

// MARK: Class's private methods
private extension ChatOrderContractVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        let buttonLeft = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 44, height: 44)))
        buttonLeft.setImage(UIImage(named: "ic_arrow_back"), for: .normal)
        buttonLeft.contentEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        let leftBarButton = UIBarButtonItem(customView: buttonLeft)
        navigationItem.leftBarButtonItem = leftBarButton
        buttonLeft.rx.tap.bind { _ in
            self.listener?.moveBackOC()
        }.disposed(by: disposeBag)
        title = "Chat với VATO"
        
        let buttonRight = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 44, height: 44)))
        buttonRight.setImage(UIImage(named: "ic_close_vato"), for: .normal)
        let rightBarButton = UIBarButtonItem(customView: buttonRight)
        navigationItem.rightBarButtonItem = rightBarButton
        
        self.viewOCInfo.updateUI(type: .seeMore)
    }
    private func setupRX() {
        let showEvent = NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification).map (KeyboardInfo.init)
        let hideEvent = NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification).map (KeyboardInfo.init)
        
        Observable.merge([showEvent, hideEvent]).filterNil().bind { [weak self] d in
            guard let wSelf = self else { return }
            UIView.animate(withDuration: d.duration, animations: {
                wSelf.hViewTyping.constant = d.height
                wSelf.view.layoutIfNeeded()
            }, completion: { _ in
//                guard let v = wSelf.tableView.findFirstResponder() else {
//                    return
//                }
//                let rect = v.convert(v.bounds, to: wSelf.tableView)
//                wSelf.tableView.scrollRectToVisible(rect, animated: true)
                let indexPath = IndexPath(row: 4, section: 0)
                wSelf.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            })
        }.disposed(by: disposeBag)
        
        self.tfTyping.rx.text.orEmpty.map { (value) -> Bool in
            return value.count > 0
        }.bind { [weak self] (isValid) in
            guard let wSelf = self else { return }
            wSelf.btSend.isEnabled = isValid
            wSelf.btSend.backgroundColor = (isValid) ? .red : .gray
            wSelf.tableView.reloadData()
            wSelf.view.layoutIfNeeded()
        }.disposed(by: disposeBag)
        
        self.tap.rx.event.bind(onNext: weakify({ (_, wSelf) in
            wSelf.view.endEditing(true)
        })).disposed(by: disposeBag)
        
        self.viewOCInfo.btSeeMore.rx.tap.bind(onNext: weakify({ (wSelf) in
            wSelf.viewOCInfo.updateUI(type: .explain)
            UIView.animate(withDuration: 0.5) {
                wSelf.tableView.reloadData()
            }
        })).disposed(by: disposeBag)
    }
}
extension ChatOrderContractVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v: UIView = UIView()
        v.addSubview(self.viewOCInfo)
        self.viewOCInfo.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview().inset(10)
            make.top.equalToSuperview().inset(-20)
        }
        return v
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatOrderContractCell.identifier) as! ChatOrderContractCell
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
