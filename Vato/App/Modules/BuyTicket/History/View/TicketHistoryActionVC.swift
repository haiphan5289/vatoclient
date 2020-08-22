//  File name   : TicketHistoryActionVC.swift
//
//  Author      : Dung Vu
//  Created date: 10/14/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import RxSwift
import RxCocoa
import FwiCore
import FwiCoreRX

protocol ActionSelectDisplay {
    var title: String? { get }
    var isAllowChangeTicket: Bool { get }
    var isAllowCancelTicket: Bool { get }
    var isAllowRebookTicket: Bool { get }
    var isAllowShareTicket: Bool { get }
}

enum ActionSelectTicket: Int, CaseIterable {
    case changeTicket , cancelTicket , rebookTicket , supportTicket , shareTicket, routeInfo
    
    var title: String {
        switch self {
        case .routeInfo:
            return FwiLocale.localized("Lịch trình")
        case .changeTicket:
            return Text.changeTicket.localizedText
        case .cancelTicket:
            return Text.cancelTicket.localizedText
        case .rebookTicket:
            return Text.rebookTicket.localizedText
        case .supportTicket:
            return Text.supportTicket.localizedText
        case .shareTicket:
            return Text.nameShare.localizedText
        }
    }
}

protocol TicketHistoryActionHandlerProtocol: AnyObject {
    func excuteAction(type: ActionSelectTicket)
}

final class TicketHistoryActionVC: UIViewController {
    /// Class's public properties.
    struct Config {
        static let phone = "1900 6667"
        static let phoneValue = "19006667"
    }
    weak var listener: TicketHistoryActionHandlerProtocol?
    @IBOutlet var containerView: UIView?
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet var btnChangeTicket: UIButton!
    @IBOutlet var btnCancelTicket: UIButton!
    @IBOutlet var btnReorderTicket: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet var buttons: [UIButton]?
    internal lazy var disposeBag = DisposeBag()
    @IBOutlet var lblTitle: UILabel?
    @IBOutlet var btnClose: UIButton?
    
    lazy var panGesture: UIPanGestureRecognizer? = {
        let p = UIPanGestureRecognizer(target: nil, action: nil)
        containerView?.addGestureRecognizer(p)
        return p
    }()
    
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
        reloadLayout()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
        
        UIView.animate(withDuration: 0.3) {
            self.containerView?.transform = .identity
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first else {
            return
        }
        
        let p = point.location(in: self.view)
        guard self.containerView?.frame.contains(p) == false else {
            return
        }
        self.dismiss(animated: true, completion: nil)
    }

    /// Class's private properties.
    var actionSelectDisplay: ActionSelectDisplay?
    var buyNew: Bool = false
    
    private func reloadLayout() {
        guard let actionSelectDisplay = self.actionSelectDisplay else { return }
        self.lblTitle?.text = actionSelectDisplay.title
        var removeViews = [UIView]()
        
        if !actionSelectDisplay.isAllowChangeTicket { removeViews += [ self.btnChangeTicket] }
        if !actionSelectDisplay.isAllowCancelTicket || buyNew { removeViews += [ self.btnCancelTicket] }
        if !actionSelectDisplay.isAllowRebookTicket { removeViews += [ self.btnReorderTicket] }
        if !actionSelectDisplay.isAllowShareTicket { removeViews += [ self.btnShare] }
        
        removeViews.forEach { (v) in
            v.isHidden = true
//            stackView.removeArrangedSubview(v)
//            v.removeFromSuperview()
        }
        stackView.layoutIfNeeded()
    }
}

// MARK: View's event handlers
extension TicketHistoryActionVC: DraggableViewProtocol {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: Class's private methods
private extension TicketHistoryActionVC {
    private func localize() {
        // todo: Localize view's here.
    }
    
    func setupRX() {
        setupDraggable()
        
        btnClose?.rx.tap.bind(onNext: weakify({ (wSelf) in
            wSelf.dismiss(animated: true, completion: nil)
        })).disposed(by: disposeBag)
    }
    
    private func visualize() {
        // todo: Visualize view's here.
        let viewBG = HeaderCornerView(with: 7)
        viewBG.containerColor = .white
        containerView?.insertSubview(viewBG, at: 0)
        viewBG >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        containerView?.transform = CGAffineTransform(translationX: 0, y: 1000)
        ActionSelectTicket.allCases.forEach { (type) in
            let button = self.buttons?[safe: type.rawValue]
            switch type {
            case .supportTicket:
                let a1 = "\(type.title): ".attribute >>> AttributeStyle.color(c: #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)) >>> AttributeStyle.font(f: UIFont.systemFont(ofSize: 16, weight: .regular))
                let a2 = Config.phone.attribute >>> AttributeStyle.color(c: #colorLiteral(red: 0, green: 0.3803921569, blue: 0.2392156863, alpha: 1)) >>> AttributeStyle.font(f: UIFont.systemFont(ofSize: 16, weight: .medium))
                let att = a1.add(from: a2)
                button?.setAttributedTitle(att, for: .normal)
            case .changeTicket:
                 #warning("tksu - temp hide change ticket in this version")
                button?.setTitle(type.title, for: .normal)
                button?.setTitleColor(.gray, for: .normal)
                button?.isUserInteractionEnabled = false
            default:
                button?.setTitle(type.title, for: .normal)
            }
            
            button?.rx.tap.bind(onNext: weakify({ (wSelf) in
                wSelf.excute(type: type)
            })).disposed(by: disposeBag)
            
        }
    }
    
    private func excute(type: ActionSelectTicket) {
        switch type {
        case .supportTicket:
            guard let url = URL(string: "tel://\(Config.phoneValue)") else {
                return
            }
            guard UIApplication.shared.canOpenURL(url) else {
                return
            }
            UIApplication.shared.open(url, options: [:], completionHandler: { _ in })
        default:
            self.dismiss(animated: true, completion: { [weak self] in
                self?.listener?.excuteAction(type: type)
            })
        }
    }
}
