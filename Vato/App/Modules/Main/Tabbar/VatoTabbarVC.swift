//  File name   : VatoTabbarVC.swift
//
//  Author      : Dung Vu
//  Created date: 8/26/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxSwift
import FwiCoreRX


protocol VatoTabbarPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var loading: Observable<(Bool, Double)> { get }
}

final class VatoTabbarVC: UITabBarController, VatoTabbarPresentable, VatoTabbarViewControllable, LoadingAnimateProtocol, DisposableProtocol {
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: VatoTabbarPresentableListener? {
        didSet {
            setupRX()
        }
    }
    lazy var disposeBag = DisposeBag()

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
    
    deinit {
        print("\(type(of: self)) \(#function)")
    }
    
    func cleanUp() {
//        let typesRemoves = [TabbarType.history/*, TabbarType.notify*/].map(\.rawValue).compactMap { (idx) -> UIViewController? in
//            return viewControllers?[safe: idx]
//        }
//
//        typesRemoves.forEach { (vc) in
//            guard let idx = viewControllers?.firstIndex(of: vc) else { return }
//            viewControllers?.remove(at: idx)
//        }
    }

    /// Class's private properties.
}

// MARK: View's event handlers
extension VatoTabbarVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension VatoTabbarVC: UITabBarControllerDelegate {
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        item.setTitleTextAttributes([.foregroundColor: Color.orange], for: .selected)
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
    }
}

// MARK: Class's private methods
private extension VatoTabbarVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        if #available(iOS 13, *) {
            let appearance = self.tabBar.standardAppearance
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: Color.battleshipGrey]
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: Color.orange]
        }
        self.tabBar.unselectedItemTintColor = Color.battleshipGrey
        self.tabBar.tintColor = Color.orange
        setHiddenTabbar()
    }
    
    func setupRX() {
        showLoading(use: self.listener?.loading)
    }
    
    func setHiddenTabbar() {
        let t = self.tabBar.frame
        var f = view.frame
        f.size.height += t.height
        view.frame = f
        tabBar.isHidden = true
    }
}
