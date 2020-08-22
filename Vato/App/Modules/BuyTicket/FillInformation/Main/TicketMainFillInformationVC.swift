//  File name   : TicketMainFillInformationVC.swift
//
//  Author      : khoi tran
//  Created date: 5/13/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxSwift
import SnapKit
import FwiCore
import FwiCoreRX

protocol TicketMainFillInformationPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var isRoundTrip: Observable<Bool> { get }
    var eLoadingObser: Observable<(Bool, Double)> { get }
    var eventsForm: [Observable<Bool>] { get }
    
    func attachFillInformation(type: TicketRoundTripType)
    func ticketMainFillInformationMoveBack()
    
    func routeToTicketPayment()
    func initChildren()
}

extension TicketRoundTripType {
    var ratioTransform: CGFloat {
        switch self {
        case .startTicket:
            return 0
        case .returnTicket:
            return 0.5
        }
    }
    
    var next: TicketRoundTripType {
        switch self {
        case .startTicket:
            return .returnTicket
        case .returnTicket:
            return .startTicket
        }
    }
}


final class TicketMainFillInformationVC: UIViewController, TicketMainFillInformationPresentable, TicketMainFillInformationViewControllable, LoadingAnimateProtocol, DisposableProtocol {
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: TicketMainFillInformationPresentableListener?
    
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupNavigation()
        setupRX()
        self.listener?.initChildren()
        DispatchQueue.main.async {
            self.setController(at: 0, animated: false, direction: .forward)
        }
    }
    
    func setController(at idx: Int, animated: Bool, direction: UIPageViewController.NavigationDirection) {
        guard let vc = controllers[safe: idx] else { return }
        pageVC.setViewControllers([vc], direction: direction, animated: animated, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }
    
    /// Class's private properties.
    @IBOutlet private var btnStartTrip: UIButton!
    @IBOutlet private var btnReturnTrip: UIButton!
    @IBOutlet private var stvTop: UIStackView!
    @IBOutlet private var stvTopHeight: NSLayoutConstraint!
    @IBOutlet weak var indicatorView: UIView!
    private lazy var pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [:])
    internal var disposeBag = DisposeBag()
    private var btnNext: UIButton?
    private var controllers: [UIViewController] = []
    private var currentPage: TicketRoundTripType = .startTicket
    private var showingKeyboard: Bool = false
    
    func validateBtnNext(isValidate: Bool) {
        self.btnNext?.isEnabled = isValidate
        if isValidate {
            self.btnNext?.backgroundColor = #colorLiteral(red: 0.9588660598, green: 0.4115985036, blue: 0.1715823114, alpha: 1)
        } else {
            self.btnNext?.backgroundColor = #colorLiteral(red: 0.7529411765, green: 0.7764705882, blue: 0.8, alpha: 1)
        }
        
        guard isValidate else {
            return
        }
        
        validateCanMoveToNextPageInput()
    }
    
    deinit {
        print("!!!\(type(of: self)) \(#function)")
    }
    
}

// MARK: View's event handlers
extension TicketMainFillInformationVC {
    func addChildPageController(_ childVC: UIViewController) {
        controllers.append(childVC)
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    func showAlertError(e: BuyTicketPaymenState) {
        let actionCancel = AlertAction(style: .default, title: Text.ok.localizedText) {}
        AlertVC.show(on: self, title: Text.notification.localizedText, message: e.getMsg(), from: [actionCancel], orderType: .horizontal)
    }
}

// MARK: Class's public methods
extension TicketMainFillInformationVC {
}

// MARK: Class's private methods
private extension TicketMainFillInformationVC {
    private func validateCanMoveToNextPageInput() {
        guard !showingKeyboard else { return }
        guard controllers.count > 1 && currentPage == .startTicket else { return }
        
        listener?.eventsForm[safe: currentPage.rawValue]?.take(1).bind(onNext: weakify({ (valid, wSelf) in
            guard valid else { return }
            wSelf.setupChangePage(type: wSelf.currentPage.next)
        })).disposed(by: disposeBag)
    }
    
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        self.view.backgroundColor = #colorLiteral(red: 0.9750739932, green: 0.9750967622, blue: 0.9750844836, alpha: 1)
        btnStartTrip.setTitle(Text.ticketStartTrip.localizedText, for: .normal)
        btnReturnTrip.setTitle(Text.ticketReturnTrip.localizedText, for: .normal)
        
        let att1 = Text.ticketStartTrip.localizedText.attribute >>> .color(c: #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)) >>> .font(f: UIFont.systemFont(ofSize: 14, weight: .regular))
        let att2 = Text.ticketStartTrip.localizedText.attribute >>> .color(c: #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1)) >>> .font(f: UIFont.systemFont(ofSize: 14, weight: .medium))
        btnStartTrip.setAttributedTitle(att1, for: .normal)
        btnStartTrip.setAttributedTitle(att2, for: .selected)
        
        let att3 = Text.ticketReturnTrip.localizedText.attribute >>> .color(c: #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)) >>> .font(f: UIFont.systemFont(ofSize: 14, weight: .regular))
        let att4 = Text.ticketReturnTrip.localizedText.attribute >>> .color(c: #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1)) >>> .font(f: UIFont.systemFont(ofSize: 14, weight: .medium))
        btnReturnTrip.setAttributedTitle(att3, for: .normal)
        btnReturnTrip.setAttributedTitle(att4, for: .selected)
        
        btnStartTrip.isSelected = true
        
        let button = UIButton.create {
            $0.cornerRadius = 24
            $0.backgroundColor = #colorLiteral(red: 0.9588660598, green: 0.4115985036, blue: 0.1715823114, alpha: 1)
            $0.setTitle(Text.continue.localizedText, for: .normal)
            $0.setTitleColor(.white, for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        }
        
        button >>> view >>> {
            $0.snp.makeConstraints { (make) in
                make.height.equalTo(48)
                make.bottom.equalTo(-24)
                make.left.equalTo(16)
                make.right.equalTo(-16)
            }
        }
        
        button.rx.tap.bind(onNext: weakify({ (wSelf) in
            wSelf.validateToPayment()
        })).disposed(by: disposeBag)
        
        self.btnNext = button
        
        guard let topView = view.viewWithTag(200) else {
            return
        }
        
        pageVC.view >>> view >>> {
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(topView.snp.bottom)
                make.left.right.equalToSuperview()
                make.bottom.equalTo(-105)
            }
        }
        
        self.addChild(pageVC)
        pageVC.didMove(toParent: self)
    }
    
    private func validateToPayment() {
        let events = self.listener?.eventsForm.enumerated().map({ (item) -> Observable<(index: Int, value: Bool)> in
            return item.element.map { (item.offset, $0) }
        })
        
        guard let e = events else {
            return
        }
        
        Observable.combineLatest(e).take(1).bind(onNext: weakify({ (items, wSelf) in
            var moveToPayment = true
            MoveInput:for i in items {
                guard i.value == false, let type = TicketRoundTripType(rawValue: i.index)  else {
                    continue
                }
                moveToPayment = false
                switch type {
                case .returnTicket:
                    wSelf.btnReturnTrip?.sendActions(for: .touchUpInside)
                case .startTicket:
                    wSelf.btnStartTrip?.sendActions(for: .touchUpInside)
                }
                break MoveInput
            }
            
            guard moveToPayment else { return }
            wSelf.listener?.routeToTicketPayment()
            
        })).disposed(by: disposeBag)
    }
    
    func setupNavigation() {
        title = Text.chooseBusStation.localizedText
        
        let navigationBar = navigationController?.navigationBar
        let bgImage = UIImage(named:"bg_navigationbar")?.stretchableImage(withLeftCapWidth: 0, topCapHeight: 0)
        navigationBar?.setBackgroundImage(bgImage, for: .default)
        navigationBar?.barTintColor = Color.orange
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
            wSelf.listener?.ticketMainFillInformationMoveBack()
        }).disposed(by: disposeBag)
    }
    
    func setupKeyboardAnimation() {
        let eShowKeyBoard = NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification).map({ KeyboardInfo($0) })
        let eHideKeyBoard = NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification).map({ KeyboardInfo($0) })
        
        Observable.merge([eShowKeyBoard, eHideKeyBoard]).bind { [weak self] in
            self?.showingKeyboard = $0?.hidden == false
        }.disposed(by: disposeBag)
    }
    
    private func setupRX() {
        self.listener?.isRoundTrip.bind(onNext: weakify({ (isRoundTrip, wSelf) in
            wSelf.stvTopHeight.constant = isRoundTrip ? 48 : 0
            wSelf.stvTop.layoutIfNeeded()
            
        })).disposed(by: disposeBag)
        
        showLoading(use: self.listener?.eLoadingObser)
        
        let startTap = self.btnStartTrip.rx.tap.map { _ in TicketRoundTripType.startTicket }
        let returnTap = self.btnReturnTrip.rx.tap.map { _ in TicketRoundTripType.returnTicket }
        
        Observable.merge([startTap, returnTap]).subscribe(onNext: weakify({ (type, wSelf) in
            guard wSelf.currentPage != type else { return }
            wSelf.setupChangePage(type: type)
            wSelf.listener?.attachFillInformation(type: type)
        })).disposed(by: disposeBag)
        
        setupKeyboardAnimation()
    }
    
    
    private func setupChangePage(type: TicketRoundTripType) {
        currentPage = type
        let x: CGFloat = UIScreen.main.bounds.width * type.ratioTransform
        switch type {
        case .startTicket:
            btnStartTrip.isSelected = true
            btnReturnTrip.isSelected = false
            setController(at: 0, animated: true, direction: .reverse)
        case .returnTicket:
            btnStartTrip.isSelected = false
            btnReturnTrip.isSelected = true
            setController(at: 1, animated: true, direction: .forward)
        }
        UIView.animate(withDuration: 0.3) {
            self.indicatorView.transform = CGAffineTransform(translationX: x , y: 0)
        }
    }
}
