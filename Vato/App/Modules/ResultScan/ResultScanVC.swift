//  File name   : ResultScanVC.swift
//
//  Author      : vato.
//  Created date: 9/30/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxSwift

protocol ResultScanPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    
    func resultScanMoveBack()
    func resultScanShowPromotions()
    var resultScanType: Observable<ResultScanType> { get }
}

final class ResultScanVC: UIViewController, ResultScanPresentable, ResultScanViewControllable {
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: ResultScanPresentableListener?

    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigation()
        localize()
    }

    /// Class's private properties.
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subTitleLabel: UILabel!
    @IBOutlet private weak var seePromotion: UIButton!
    @IBOutlet private weak var promotionCode: UIButton!
    @IBOutlet weak var checkPromotionListLabel: UILabel!
    
    private lazy var disposeBag = DisposeBag()
}

// MARK: View's event handlers
extension ResultScanVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension ResultScanVC {
}

// MARK: Class's private methods
private extension ResultScanVC {
    private func localize() {
        // todo: Localize view's here.
        checkPromotionListLabel.text = "(\(Text.checkPromotionList.localizedText))"
        title = Text.scanQR.localizedText
    }
    
    private func visualize() {
        // todo: Visualize view's here.
        setupNavigation()
    }
    
    private func setupNavigation() {
        let navigationBar = self.navigationController?.navigationBar
        navigationBar?.barTintColor = Color.orange
        navigationBar?.isTranslucent = false
        navigationBar?.tintColor = .white
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        let image = UIImage(named: "ic_close_white")
        let rightButton = UIButton(frame: CGRect(origin: .zero, size: image?.size ?? .zero))
        rightButton.setImage(image, for: .normal)
        let rightBarButton = UIBarButtonItem(customView: rightButton)
        navigationItem.rightBarButtonItem = rightBarButton
        navigationItem.hidesBackButton = true
        rightButton.rx.tap.bind(onNext: weakify { wSelf in
            wSelf.listener?.resultScanMoveBack()
        }).disposed(by: disposeBag)
    }
    
    func setupRX() {
        listener?.resultScanType.bind(onNext: {[weak self] (type) in
            self?.bindView(type: type)
        }).disposed(by: disposeBag)
        
        seePromotion.rx.tap.bind { [weak self] _ in
            guard let self = self else { return }
            self.listener?.resultScanShowPromotions()
        }.disposed(by: disposeBag)
    }
    
    private func bindView(type: ResultScanType) {
        imageView.image = type.getImage()
        titleLabel.text = type.getTitle()
        subTitleLabel.text = type.getMessage()
        switch type {
            case .success(let resultScal):
                promotionCode.setTitle(resultScal.code, for: .normal)
            seePromotion.isHidden = false
            promotionCode.isHidden = false
            checkPromotionListLabel.isHidden = false
        default:
            seePromotion.isHidden = true
            promotionCode.isHidden = true
            checkPromotionListLabel.isHidden = true
        }
    }
}
