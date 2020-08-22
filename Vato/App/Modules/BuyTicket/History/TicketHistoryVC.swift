//  File name   : TicketHistoryVC.swift
//
//  Author      : Dung Vu
//  Created date: 10/11/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxSwift
import RxCocoa

protocol TicketHistoryPresentableListener: TicketListHistoryHandlerProtocol {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func moveBack()
    func processAction(type: ActionSelectTicket)
}

enum TicketHistory: Int, CaseIterable {
    case none = -1
    case history = 0
    case future = 1
    
    static var allCases: [TicketHistory] {
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

final class TicketHistoryVC: UIViewController, TicketHistoryPresentable, TicketHistoryViewControllable {
    
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: TicketHistoryPresentableListener?
    @IBOutlet var btnFuture: UIButton!
    @IBOutlet var btnHistory: UIButton!
    @IBOutlet var indicatorView: UIView?
    private var currentIdx: Int = 0
    private lazy var disposeBag = DisposeBag()
    private var controllers: [TicketListHistoryRemoveProtocol] = []
    
    private lazy var pageVC: UIPageViewController = {
        guard let p = self.children.compactMap ({ $0 as? UIPageViewController }).first else {
            fatalError("Please Implement")
        }
        return p
    }()

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
    
    func handler(type: TicketHistory) {
        guard currentIdx != type.rawValue else {
            return
        }
        guard let controller = self.controllers[safe: type.rawValue] else {
            return
        }
        let direction: UIPageViewController.NavigationDirection = currentIdx < type.rawValue ? .forward : .reverse
        pageVC.setViewControllers([controller], direction: direction, animated: true, completion: nil)
        switch type {
        case .future:
            btnFuture.isSelected = true
            btnHistory.isSelected = false
        default:
            btnFuture.isSelected = false
            btnHistory.isSelected = true
        }
        
        currentIdx = type.rawValue
        let deltaY = UIScreen.main.bounds.width / 2
        UIView.animate(withDuration: 0.3) {
            self.indicatorView?.transform = CGAffineTransform(translationX: deltaY * CGFloat(type.rawValue) , y: 0)
        }
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let actionVC = segue.destination as? TicketHistoryActionVC,
            let item = sender as? TicketHistoryType {
            actionVC.actionSelectDisplay = item
            actionVC.listener = self
            return
        }
    }
    /// Class's private properties.
}

// MARK: View's event handlers
extension TicketHistoryVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    func option(item: TicketHistoryType, type: TicketHistory) {
        self.performSegue(withIdentifier: "showAction", sender: item)
    }
    
    func removeItem(item: TicketHistoryType, type: TicketHistory) {
        controllers.first(where: { $0.type == type })?.remove(item: item)
    }
    
    func refresh() {
        controllers.forEach({ (vc) in
            vc.refresh()
        })
    }
}

extension TicketHistoryVC: TicketHistoryActionHandlerProtocol {
    func excuteAction(type: ActionSelectTicket) {
        listener?.processAction(type: type)
    }
    
}

// MARK: Class's public methods
extension TicketHistoryVC {
}

// MARK: Class's private methods
private extension TicketHistoryVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        setupNavigation()
        self.title = Text.listTicket.localizedText
        btnFuture.setTitle(Text.departingSoon.localizedText.uppercased(), for: .normal)
        btnHistory.setTitle(Text.oldTicket.localizedText.uppercased(), for: .normal)
        let controllers =  TicketHistory.allCases.map { type -> TicketListHistoryRemoveProtocol in
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "TicketListHistoryVC") as? TicketListHistoryVC else {
                fatalError("Please Implement")
            }
            vc.type = type
            vc.listener = listener
            return vc
        }
        self.controllers = controllers
        self.pageVC.setViewControllers([controllers[0]], direction: .forward, animated: false, completion: nil)
        
    }
    
    func setupRX(){
        let tap1 = btnFuture.rx.tap.map { _ in TicketHistory.future }
        let tap2 = btnHistory.rx.tap.map { _ in TicketHistory.history }
        
        Observable.merge([tap1, tap2]).bind(onNext: weakify({ (type, wself) in
            wself.handler(type: type)
        })).disposed(by: disposeBag)
    }
}
