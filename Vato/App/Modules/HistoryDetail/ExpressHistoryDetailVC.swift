//  File name   : ExpressHistoryDetailVC.swift
//
//  Author      : vato.
//  Created date: 12/23/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxSwift

protocol ExpressHistoryDetailPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func historyDetailMoveBack()
    func routeQRCode()
}

enum ExpHistoryDetail: Int, CaseIterable {
    case none = -1
    case detail = 0
    case state = 1
}

final class ExpressHistoryDetailVC: UIViewController, ExpressHistoryDetailPresentable, ExpressHistoryDetailViewControllable {
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: ExpressHistoryDetailPresentableListener?

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

    /// Class's private properties.
    private lazy var disposeBag = DisposeBag()
    private var currentIdx: Int = 0
    @IBOutlet var infoView: UIView!
    @IBOutlet var btnDetail: UIButton!
    @IBOutlet var btnState: UIButton!
    @IBOutlet var indicatorView: UIView?
    private var controllers: [UIViewController] = []
    private lazy var pageVC: UIPageViewController = {
           guard let p = self.children.compactMap ({ $0 as? UIPageViewController }).first else {
               fatalError("Please Implement")
           }
           return p
       }()
}

// MARK: View's event handlers
extension ExpressHistoryDetailVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension ExpressHistoryDetailVC {
}

// MARK: Class's private methods
private extension ExpressHistoryDetailVC {
    private func localize() {
        // todo: Localize view's here.
    }
    
    private func visualize() {
        // todo: Visualize view's here.
        title = "Chi tiết đơn"
        setupNavigation()
        self.view.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        
        let storyboard = UIStoryboard(name: "History", bundle: nil)
        guard let historyVC = storyboard.instantiateViewController(withIdentifier: "ExpHistoryDetailVC") as? ExpHistoryDetailVC,
            let historyVC1 = storyboard.instantiateViewController(withIdentifier: "ExpHistoryStateVC") as? ExpHistoryStateVC else {
                fatalError("Please Implement")
        }
        
        
        self.controllers = [historyVC, historyVC1]
        self.pageVC.setViewControllers([controllers[0]], direction: .forward, animated: false, completion: nil)
        
        let header = ExpressDetailHeader.loadXib()
        infoView.addSubview(header)
        header.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        header.didSelectQRCode = { [weak self]  in
            self?.listener?.routeQRCode()
        }
        
    }
    
    private func setupRX() {
        let tap1 = btnDetail.rx.tap.map { _ in ExpHistoryDetail.detail }
        let tap2 = btnState.rx.tap.map { _ in ExpHistoryDetail.state }
        
        Observable.merge([tap1, tap2]).bind(onNext: {[weak self] (type) in
            self?.handler(type: type)
        }).disposed(by: disposeBag)
    }
    
    private func setupNavigation() {
           let navigationBar = self.navigationController?.navigationBar
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
               wSelf.listener?.historyDetailMoveBack()
           }).disposed(by: disposeBag)
       }
    
    func handler(type: ExpHistoryDetail) {
          guard currentIdx != type.rawValue else {
              return
          }
          guard let controller = self.controllers[safe: type.rawValue] else {
              return
          }
          let direction: UIPageViewController.NavigationDirection = currentIdx < type.rawValue ? .forward : .reverse
          pageVC.setViewControllers([controller], direction: direction, animated: true, completion: nil)
          switch type {
          case .detail:
              btnDetail.isSelected = true
              btnState.isSelected = false
          default:
              btnDetail.isSelected = false
              btnState.isSelected = true
          }
          
          currentIdx = type.rawValue
          let deltaY = UIScreen.main.bounds.width / 2
          UIView.animate(withDuration: 0.3) {
              self.indicatorView?.transform = CGAffineTransform(translationX: deltaY * CGFloat(type.rawValue) , y: 0)
          }
      }
}
