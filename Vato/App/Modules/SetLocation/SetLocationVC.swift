//  File name   : SetLocationVC.swift
//
//  Author      : khoi tran
//  Created date: 3/4/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxSwift

protocol SetLocationPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var latestLocation: Observable<AddressProtocol> { get }
    var displayName: Observable<String> { get }
    
    func routeToChangeLocation()
    func setDefaultLocation()
    func openSetting()
}

final class SetLocationVC: UIViewController, SetLocationPresentable, SetLocationViewControllable {
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: SetLocationPresentableListener?

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
    @IBOutlet private var lblAddress: UILabel!
    @IBOutlet private var lblUsername: UILabel!
    @IBOutlet private var lblDescription: UILabel!
    @IBOutlet private var btnChangeLocation: UIButton!
    @IBOutlet private var btnSetLocation: UIButton!
    @IBOutlet private var btnSetting: UIButton!
    @IBOutlet private var lblPreviousLocation: UILabel!
    
    private var disposeBag = DisposeBag()
}

// MARK: View's event handlers
extension SetLocationVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension SetLocationVC {
}

// MARK: Class's private methods
private extension SetLocationVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        self.lblDescription.text = Text.setLocationDescription.localizedText
        self.btnChangeLocation.setTitle(Text.change.localizedText, for: .normal)
        self.btnSetLocation.setTitle(Text.useThisLocation.localizedText, for: .normal)
        self.btnSetting.setTitle(Text.allowAccessLocation.localizedText, for: .normal)
        self.lblPreviousLocation.text = Text.previousLocation.localizedText
    }
    
    func setupRX() {
        self.listener?.latestLocation.bind(onNext: weakify({ (location, wSelf) in
            wSelf.lblAddress.text = location.isFavoritePlace == true && location.active == true ? location.nameFavorite : location.name?.orEmpty(location.subLocality)
        })).disposed(by: disposeBag)
                
        self.btnChangeLocation.rx.tap.bind(onNext: weakify({ (wSelf) in
            wSelf.listener?.routeToChangeLocation()
        })).disposed(by: disposeBag)
        
        self.btnSetLocation.rx.tap.bind(onNext: weakify({ (wSelf) in
            wSelf.listener?.setDefaultLocation()
        })).disposed(by: disposeBag)
        
        self.btnSetting.rx.tap.bind(onNext: weakify({ (wSelf) in
            wSelf.listener?.openSetting()
                        
        })).disposed(by: disposeBag)
        
        self.listener?.displayName.bind(onNext: { (name) in
            self.lblUsername.text = String(format: Text.greeting.localizedText, name)
        }).disposed(by: disposeBag)
        
    }
}
