//
//  FCTripManagerViewController.swift
//  Vato
//
//  Created by vato. on 8/21/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit



@objc class FCTripManagerViewController: UIViewController {
   private struct Config {
    static let colorDeactive = UIColor(red: 99/255, green: 114/255, blue: 128/255, alpha: 1)
    static let colorActive = Color.orange
    static let fontDeactive = UIFont.systemFont(ofSize: 14)
    static let fontActive = UIFont.boldSystemFont(ofSize: 14)
    }
    
    var pageViewController: UIPageViewController!
    
    @IBOutlet private weak var bookingButton: UIButton!
    @IBOutlet private weak var deliveryButton: UIButton!
    @IBOutlet private weak var leftTraillingIndicator: NSLayoutConstraint!
    @IBOutlet private weak var contentView: UIView!
    private lazy var disposeBag = DisposeBag()
    private var listController: [UIViewController] = [FCTripHistoryViewController(type: TripHistoryBooking), FCTripHistoryViewController(type: TripHistoryExpress)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = Text.tripHistories.localizedText
        if self.tabBarController == nil {
            if let image = UIImage(named: "close-w") {
                let itemLeft = UIBarButtonItem(image: image.withRenderingMode(.alwaysTemplate), landscapeImagePhone: image.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: nil)
                self.navigationItem.leftBarButtonItem = itemLeft
                self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
                itemLeft.rx.tap.bind { [weak self] in
                    self?.dismiss(animated: true, completion: nil)
                }.disposed(by: disposeBag)
            }
        }
        
        // pageViewController
        self.pageViewController = UIPageViewController.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.view.frame = self.view.bounds
        pageViewController.setViewControllers([listController.first!], direction: UIPageViewController.NavigationDirection.forward, animated: true, completion: nil)
        self.contentView.addSubview(pageViewController.view)
        pageViewController.view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        self.addChild(pageViewController)
        self.pageViewController.didMove(toParent: self)
        
        self.bookingButton.setTitle(Text.booking.localizedText, for: .normal)
        self.deliveryButton.setTitle(Text.delivery.localizedText, for: .normal)
        setSelectedButton(button: bookingButton, isAnimation: false)
        
        setupRX()
        
    }
    private func setSelectedButton(button: UIButton?, isAnimation: Bool = true) {
        resetButton()
        button?.setTitleColor(Config.colorActive, for: .normal)
        button?.titleLabel?.font = Config.fontActive
        self.leftTraillingIndicator.constant = button?.frame.origin.x ?? 0
        if isAnimation == true {
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        } else {
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    deinit {
        print("\(type(of: self)) \(#function)")
    }
        
    private func resetButton() {
        self.bookingButton.setTitleColor(Config.colorDeactive, for: .normal)
        self.bookingButton.titleLabel?.font = Config.fontDeactive
        self.deliveryButton.setTitleColor(Config.colorDeactive, for: .normal)
        self.deliveryButton.titleLabel?.font = Config.fontDeactive
    }
    
    private func setupRX() {
        self.bookingButton.rx.tap.bind(onNext: weakify({ (wSelf) in
            let button = wSelf.bookingButton
            let controller = wSelf.listController.first
            wSelf.setSelectedButton(button: button)
            wSelf.scrollTo(viewController: controller)
        })).disposed(by: disposeBag)
        
        
        self.deliveryButton.rx.tap.bind(onNext: weakify({ (wSelf) in
            let button = wSelf.deliveryButton
            let controller = wSelf.listController.last
            wSelf.setSelectedButton(button: button)
            wSelf.scrollTo(viewController: controller)
        })).disposed(by: disposeBag)
    }
    
    private func scrollTo(viewController: UIViewController?) {
        guard let viewController = viewController else { return }
        var indexCurrentPage = 0
        if let currentPage = self.pageViewController.viewControllers?.first {
            indexCurrentPage = self.getIndexViewController(viewController: currentPage)
        }
        let indexScrollTo = self.getIndexViewController(viewController: viewController)
        
        var direction = UIPageViewController.NavigationDirection.reverse
        if indexCurrentPage < indexScrollTo {
            direction = UIPageViewController.NavigationDirection.forward
        }
        
        self.pageViewController.setViewControllers([viewController], direction: direction, animated: true, completion: nil)
    }
    
    private func getIndexViewController(viewController: UIViewController) -> Int {
        return self.listController.index(of: viewController) ?? 0
    }

}
