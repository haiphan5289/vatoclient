//  File name   : AlertCustomVC.swift
//
//  Author      : Dung Vu
//  Created date: 12/19/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import FwiCore

// MARK: - Options
public struct OptionSetIterator<Element: OptionSet>: IteratorProtocol where Element.RawValue == Int {
    private let value: Element

    public init(element: Element) {
        self.value = element
    }

    private lazy var remainingBits = value.rawValue
    private var bitMask = 1

    public mutating func next() -> Element? {
        while remainingBits != 0 {
            defer { bitMask = bitMask &* 2 }
            if remainingBits & bitMask != 0 {
                remainingBits = remainingBits & ~bitMask
                return Element(rawValue: bitMask)
            }
        }
        return nil
    }
}

extension OptionSet where Self.RawValue == Int {
   public func makeIterator() -> OptionSetIterator<Self> {
      return OptionSetIterator(element: self)
   }
}

struct AlertCustomOption: OptionSet, Hashable, Sequence  {
    let rawValue: Int
    
    static let image: AlertCustomOption = AlertCustomOption(rawValue: 1 << 0) // Option image_name
    static let title: AlertCustomOption = AlertCustomOption(rawValue: 1 << 1)// Option AlertStyleText
    static let customView: AlertCustomOption = AlertCustomOption(rawValue: 1 << 2)
    static let message: AlertCustomOption = AlertCustomOption(rawValue: 1 << 3) // Option AlertStyleText
    
    static let all: AlertCustomOption = [.image, .title, .message]
}

// MARK: - Styles
protocol AlertApplyStyleProtocol {
    func apply(view: UIView)
}

extension UIView: AlertApplyStyleProtocol {
    func apply(view: UIView) {}
}

// MARK: -- Label
struct AlertStyleText: AlertApplyStyleProtocol {
    let color: UIColor
    let font: UIFont
    let numberLines: Int
    let textAlignment: NSTextAlignment
    
    static let titleDefault = AlertStyleText(color: #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1), font: .systemFont(ofSize: 18, weight: .medium), numberLines: 0, textAlignment: .center)
    static let messageDefault = AlertStyleText(color: #colorLiteral(red: 0.2901960784, green: 0.2901960784, blue: 0.2901960784, alpha: 1), font: .systemFont(ofSize: 15, weight: .regular), numberLines: 0, textAlignment: .center)
    func apply(view: UIView) {
        guard let label = view as? UILabel else {
            assert(false, "Check!!!!")
            return
        }
        label.textColor = color
        label.font = font
        label.numberOfLines = numberLines
        label.textAlignment = textAlignment
    }
}

struct AlertLabelValue: AlertApplyStyleProtocol {
    let text: String?
    let style: AlertStyleText
    func apply(view: UIView) {
        guard let label = view as? UILabel else {
            assert(false, "Check!!!!")
            return
        }
        style.apply(view: label)
        label.text = text
    }
}

struct AlertAttributeTextValue: AlertApplyStyleProtocol {
    let attributedText: NSAttributedString
    var numberOfLines = 0
    func apply(view: UIView) {
        guard let label = view as? UILabel else {
            assert(false, "Check!!!!")
            return
        }
        label.attributedText = attributedText
        label.numberOfLines = numberOfLines
    }
}

// MARK: -- Image
struct AlertImageStyle: AlertApplyStyleProtocol {
    let contentMode: UIView.ContentMode
    let size: CGSize
    
    func apply(view: UIView) {
        guard let imgView = view as? UIImageView else {
            assert(false, "Check!!!!")
            return
        }
        imgView.contentMode = contentMode
        imgView.snp.makeConstraints { (make) in
            make.size.equalTo(size)
        }
    }
}

struct AlertImageValue: AlertApplyStyleProtocol {
    let imageName: String?
    let style: AlertImageStyle
    
    func apply(view: UIView) {
        guard let imgView = view as? UIImageView else {
            assert(false, "Check!!!!")
            return
        }
        style.apply(view: imgView)
        imgView.image = UIImage(named: imageName ?? "")
    }
}

// MARK: - Alert
typealias AlertArguments = [AlertCustomOption: AlertApplyStyleProtocol]

final class AlertCustomVC: UIViewController {
    /// Class's public properties.
    struct Configs {
        static let paddingX: CGFloat = 48
        static let spacing: CGFloat = 20
        static let hButton: CGFloat = 48
        static let spaceButton: CGFloat = 0
    }
    
    private var buttons: [AlertActionProtocol]
    private let option: AlertCustomOption
    private let orderType: NSLayoutConstraint.Axis
    private let alignment: UIStackView.Alignment
    private var containerView: UIView?
    private lazy var disposeBag = DisposeBag()
    private let arguments: AlertArguments
    
    init(with option: AlertCustomOption,
         arguments: [AlertCustomOption: AlertApplyStyleProtocol],
         buttons: [AlertActionProtocol],
         orderType: NSLayoutConstraint.Axis,
         alignment: UIStackView.Alignment)
    {
        self.arguments = arguments
        self.orderType = orderType
        self.buttons = buttons
        self.option = option
        self.alignment = alignment
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
        UIView.animate(withDuration: 0.5) {
            self.containerView?.transform = .identity
        }
    }

    /// Class's private properties.
}

// MARK: View's event handlers
extension AlertCustomVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's private methods
private extension AlertCustomVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        self.view.backgroundColor = Color.black40
        
        // MARK: - Container
        let containerView = UIView(frame: .zero)
        containerView >>> view >>> {
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 12
            $0.clipsToBounds = true
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.snp.makeConstraints { (make) in
                make.width.equalTo(UIScreen.main.bounds.width - Configs.paddingX)
                make.center.equalToSuperview()
            }
        }
        self.containerView = containerView
        
        // MARK: - Check
        var childViews: [UIView] = []
        
        // Custom View
        option.forEach { (o) in
            switch o {
            case .customView:
                guard let customView = arguments[.customView] as? UIView else {
                    assert(false, "Check !!!")
                    return
                }
                childViews.append(customView)
            case .image:
                guard let style = arguments[.image] else {
                    assert(false, "Check !!!")
                    return
                }
                let imageView = UIImageView(frame: .zero)
                style.apply(view: imageView)
                childViews.append(imageView)
            case .title:
                guard let style = arguments[.title]  else {
                    assert(false, "Check !!!")
                    return
                }
                let label = UILabel(frame: .zero)
                label.setContentHuggingPriority(.defaultLow, for: .horizontal)
                style.apply(view: label)
                childViews.append(label)
            case .message:
                guard let style = arguments[.message] else {
                    assert(false, "Check !!!")
                    return
                }
                let label = UILabel(frame: .zero)
                style.apply(view: label)
                label.setContentHuggingPriority(.defaultLow, for: .horizontal)
                childViews.append(label)
            default:
                fatalError("Please Implement")
            }
        }
        
        // MARK: - Content
        assert(!childViews.isEmpty, "Check !!!")
        
        let stackView = UIStackView(arrangedSubviews: childViews)
        stackView >>> containerView >>> {
            $0.spacing = 20
            $0.distribution = .fill
            $0.alignment = alignment
            $0.axis = .vertical
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(20)
                make.left.equalTo(20)
                make.right.equalTo(-20)
            }
        }
        
        let bottomView = UIView(frame: .zero)
        
        let height: CGFloat
        switch self.orderType {
        case .horizontal:
            height = Configs.hButton
        case .vertical:
            let number = CGFloat(self.buttons.count)
            height = Configs.hButton * number + (number - 1) * Configs.spaceButton
        }
        
        bottomView >>> containerView >>> {
            $0.backgroundColor = .white
            $0.addSeperator(with: .zero, position: .top)
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(stackView.snp.bottom).offset(20)
                make.left.right.equalToSuperview()
                make.height.equalTo(height)
                make.bottom.equalToSuperview().priority(.high)
            }
        }
        
        let style: SeperatorPositon = orderType == .horizontal ? .right : .bottom
        let count = self.buttons.count
        
        let buttons = self.buttons.enumerated().map { (idx, action) -> UIButton in
            let b = UIButton(frame: .zero)
            action.apply(button: b)
            
            action.invokedDismissMethod.bind(onNext: weakify({ (wSelf) in
                wSelf.dismiss(animated: true, completion: nil)
            })).disposed(by: self.disposeBag)
            
            b.rx.tap.bind { [weak self] in
                guard action.autoDismiss else {
                    return action.handler()
                }
                self?.dismiss(animated: true, completion: action.handler)
            }.disposed(by: self.disposeBag)
            if idx < count - 1 {
                b.addSeperator(with: .zero, position: style)
            }
            return b
        }

        
        UIStackView(arrangedSubviews: buttons) >>> {
            $0.axis = self.orderType
            $0.distribution = .fillEqually
            $0.spacing = Configs.spaceButton
        } >>> bottomView >>> {
            $0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
                
            }
        }
        bottomView.addSeperator(with: .zero, position: .top)
        containerView.transform = CGAffineTransform(translationX: 0, y: 1000)
        self.containerView = containerView
    }
}

// MARK: -- Protocol Action
protocol AlertActionProtocol {
    var handler: AlertBlock { get }
    var autoDismiss: Bool { get }
    var invokedDismissMethod: Observable<Void> { get }
    func apply(button: UIButton)
}

extension AlertActionProtocol {
    var autoDismiss: Bool {
        return true
    }
}

// MARK: -- Show
extension AlertCustomVC {
    static func show(on vc: UIViewController?,
                     option: AlertCustomOption,
                     arguments: AlertArguments,
                     buttons: [AlertActionProtocol],
                     orderType: NSLayoutConstraint.Axis,
                     alignment: UIStackView.Alignment = .center)
    {
        guard let vc = vc else {
            assert(false, "Check")
            return
        }
        let alertVC = AlertCustomVC(with: option, arguments: arguments, buttons: buttons, orderType: orderType, alignment: alignment)
        alertVC.modalTransitionStyle = .crossDissolve
        alertVC.modalPresentationStyle = .overCurrentContext
        vc.present(alertVC, animated: true, completion: nil)
    }
}

