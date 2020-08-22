//  File name   : PromotionDetailVC.swift
//
//  Author      : Dung Vu
//  Created date: 10/23/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import UIKit
import Kingfisher

protocol PromotionDetailPresentableListener: class {
    var currentType: PromotionDetailPresentation { get }
    var manifest: PromotionList.Manifest? { get }
    var code: String { get }
    
    func dismissDetail()
}

final class PromotionDetailVC: UIViewController, PromotionDetailPresentable, PromotionDetailViewControllable {

    /// Class's public properties.
    weak var listener: PromotionDetailPresentableListener?
    private weak var lastView: UIView?
    private lazy var disposeBag = DisposeBag()
    weak var container: UIView?
    private lazy var containerHeader: UIView = UIView(frame: .zero)
    private weak var actionButton: UIButton?
    
    struct Config {
        static let bottomDescription: CGFloat = -84
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
        guard let currentType = self.listener?.currentType else {
            return
        }
        
        switch currentType {
        case .notify:
            UIView.animate(withDuration: 0.3) {
                self.container?.alpha = 1
                self.container?.transform = CGAffineTransform.identity
            }
        default:
            self.container?.alpha = 1
        }
    }
    
    deinit {
        printDebug("\(#function)")
    }

    func setupEnableActionButton() {
        self.actionButton?.isEnabled = true
    }
    /// Class's private properties.
}


// MARK: Class's private methods
private extension PromotionDetailVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        UIApplication.setStatusBar(using: .lightContent)
        guard let currentType = self.listener?.currentType else {
            return
        }
        
        let containerView: PromotionDetailView = PromotionDetailView(body: currentType.body) { [weak self](type, view) in
            self?.setupBody(type: type, view: view)
        }
        
        
        let block: (PromotionDetailView) -> () = currentType.useFullScreen ?
        {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        } : {
            self.view.backgroundColor = Color.black40
            $0.cornerRadius = 6
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(88)
                make.bottom.equalTo(-88)
                make.left.equalTo(16)
                make.right.equalTo(-16)
            })
        }
        
        containerView >>> view >>> block
        containerView.alpha = 0
        containerView.backgroundColor = .white
        switch currentType {
        case .notify:
            self.container?.transform = CGAffineTransform(translationX: 0, y: 1000)
        default:
            break
        }
        self.container = containerView
        containerView.setupDisplay()
    }
    
    private func setupBody(type: PromotionDetailBody, view: PromotionDetailView) {
        guard let currentType = self.listener?.currentType else {
            return
        }
        let manifest = listener?.manifest
        let wContainerHeader: CGFloat = UIScreen.main.bounds.width + (currentType.useFullScreen ? 0 : -32)
        // Use for calculate container
        let f: (CGRect, CGFloat) -> CGRect = { f, delta in
            var f = f
            f.size.width = wContainerHeader
            f.size.height += delta
            return f
        }
        
        switch type {
        case .header:
            let path = manifest?.banner
            let url = path?.url
            let imageView = UIImageView(frame: .zero)
            
            // image View
            imageView >>> view >>> {
                $0.snp.makeConstraints({ (make) in
                    make.top.equalToSuperview()
                    make.left.equalToSuperview()
                    make.right.equalToSuperview()
                    make.height.equalTo(currentType.hHeader)
                })
            }
            
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFill
            imageView.kf.indicatorType = .activity
//            let options: KingfisherOptionsInfo
            let s = CGSize(width: wContainerHeader, height: currentType.hHeader)
//            let processor = ImageProcessorDisplay(target: s, key: <#String#>)
//            options = [.processor(processor)]
            imageView.setImage(from: url?.absoluteString, placeholder: nil, size: s)
//            imageView.kf.setImage(with: url, placeholder: nil, options: options)

            // Button
            let inset = currentType.useFullScreen ? { () -> (UIEdgeInsets) in
                var result = (UIApplication.shared.keyWindow?.edgeSafe ?? .zero)
                result.top = result.top > 0 ? result.top : result.top + 20
                return result
            }() : .zero
            // 17
            let gradientView = BookingConfirmGradientView.init(frame: .zero)
            gradientView.colors = [#colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 0.6).cgColor , UIColor.clear.cgColor]
            gradientView >>> view >>> {
                $0.snp.makeConstraints({ (make) in
                    make.left.equalToSuperview()
                    make.right.equalToSuperview()
                    make.top.equalToSuperview()
                    make.height.equalTo(50 + inset.top)
                })
            }
            
            let button = UIButton(frame: .zero)
            button.tintColor = .white
            button >>> view >>> {
                $0.snp.makeConstraints({ (make) in
                    if currentType.useFullScreen {
                       make.left.equalTo(16)
                    } else {
                        make.right.equalTo(-16)
                    }
                    make.top.equalTo(inset.top + 17)
                })
            }
            
            button.setImage(currentType.iconBack, for: .normal)
            button.rx.tap.bind { [weak self] in
                self?.listener?.dismissDetail()
            }.disposed(by: disposeBag)
            
//            self.lastView = imageView
            
        case .title:
            let label = UILabel(frame: .zero)
            label.textColor = #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1)
            let p = NSMutableParagraphStyle()
            p.lineSpacing = 5
            p.alignment = .left
            let att = manifest?.title?.attribute.add(attribute: .paragraph(p: p)).add(attribute: .font(f: .systemFont(ofSize: 20, weight: .bold)))
            label.attributedText = att
            label.preferredMaxLayoutWidth = wContainerHeader - 32
            label.numberOfLines = 0
            let top: CGFloat = 39
            label >>> containerHeader >>> {
                $0.snp.makeConstraints({ (make) in
                    make.width.equalTo(wContainerHeader - 32)
                    make.centerX.equalToSuperview()
                    make.top.equalTo(self.lastView?.snp.bottom ?? 0).offset(top)
                })
            }
            let s = label.sizeThatFits(CGSize(width: wContainerHeader - 32, height: CGFloat.greatestFiniteMagnitude))
            self.containerHeader.frame = f(self.containerHeader.frame, (top + s.height))
            self.lastView = label
        case .code:
            let button = UIButton(frame: .zero)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
            button.setTitleColor(#colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1), for: .normal)
            let code = listener?.code ?? ""
            let empty = code.trimmingCharacters(in: .whitespacesAndNewlines).count == 0
            let top: CGFloat = empty ? 0 : 16
            let h: CGFloat = empty ? 0 : 40
            
            button >>> containerHeader >>> {
                $0.snp.makeConstraints({ (make) in
                    make.size.equalTo(CGSize(width: 136, height: h))
                    make.top.equalTo(self.lastView?.snp.bottom ?? 0).offset(top)
                    make.centerX.equalToSuperview()
                })
            }
            
            button.setTitle(listener?.code, for: .normal)
            button.cornerRadius = 6
            button.borderColor = #colorLiteral(red: 0.9137254902, green: 0.9215686275, blue: 0.9450980392, alpha: 1)
            button.borderWidth = 1
            button.backgroundColor = #colorLiteral(red: 0.9607843137, green: 0.9647058824, blue: 0.9803921569, alpha: 1)
            self.containerHeader.frame = f(self.containerHeader.frame, (top + h))
            self.lastView = button
            
        case .button:
            let gV = BookingConfirmGradientView(frame: .zero) >>> view >>> {
                $0.snp.makeConstraints({ (make) in
                    make.top.equalTo(currentType.hHeader)
                    make.centerX.equalToSuperview()
                    make.width.equalTo(wContainerHeader - 32)
                    make.height.equalTo(10)
                })
            }
            gV.colors = [UIColor.white.cgColor, UIColor(white: 1, alpha: 0).cgColor]
            
            let buttons = currentType.action.map { (action) -> UIButton in
                let b = UIButton(frame: .zero)
                b.applyButton(style: action.style)
                b.setTitle(action.title, for: .normal)
                b.rx.tap.bind { [weak self] in
                    self?.actionButton = b
                    b.isEnabled = false
                    action.handler()
                }.disposed(by: self.disposeBag)
                return b
            }
            
            UIStackView(arrangedSubviews: buttons) >>> {
                $0.axis = .horizontal
                $0.distribution = .fillEqually
                $0.spacing = ButtonConfig.spaceButton
                } >>> view >>> {
                    $0.snp.makeConstraints({ make in
                        make.left.equalTo(16)
                        make.right.equalTo(-16)
                        make.height.equalTo(48)
                        make.bottom.equalTo(-16)
                    })
            }
            
            BookingConfirmGradientView(frame: .zero) >>> view >>> {
                $0.snp.makeConstraints({ (make) in
                    make.width.equalTo(wContainerHeader - 32)
                    make.centerX.equalToSuperview()
                    make.bottom.equalTo(Config.bottomDescription)
                    make.height.equalTo(10)
                })
            }
        case .decription:
            // Distance 84
            let tableView = UITableView(frame: .zero, style: .plain)
            >>> view >>> {
                $0.separatorColor = .clear
                $0.separatorStyle = .none
                $0.rowHeight = UITableView.automaticDimension
                $0.estimatedRowHeight = 44
            } >>> {
                $0.snp.makeConstraints({ (make) in
                    make.top.equalTo(currentType.hHeader)
                    make.bottom.equalTo(Config.bottomDescription)
                    make.left.equalToSuperview()
                    make.right.equalToSuperview()
                })
            }
            
            self.containerHeader.frame = f(self.containerHeader.frame, 16)
            tableView.tableHeaderView = self.containerHeader
            
            tableView.register(PromotionDetailCell.nib, forCellReuseIdentifier: PromotionDetailCell.identifier)
            let list = [manifest?.headline, manifest?.description].compactMap { $0 }.filter{ !$0.isEmpty }
        
            Observable.just(list)
                .bind(to: tableView.rx.items(cellIdentifier: PromotionDetailCell.identifier, cellType: PromotionDetailCell.self)) { (row, element, cell) in
                    cell.set(element)
                }
            .disposed(by: disposeBag)
            
        }
    }
    
    private func setupRX() {
        // todo: Bind data to UI here.
    }
}
