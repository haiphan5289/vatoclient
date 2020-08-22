//  File name   : CreditPointsVC.swift
//
//  Author      : Dung Vu
//  Created date: 10/24/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import RxSwift
import RxCocoa

final class CreditPointsVC: UIViewController {
    /// Class's public properties.
    private lazy var disposeBag = DisposeBag()
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }

    /// Class's private properties.
    @IBOutlet weak var lblFutaDescription: UILabel!
}

// MARK: View's event handlers
extension CreditPointsVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's private methods
private extension CreditPointsVC {
    private func localize() {
        // todo: Localize view's here.
        self.title = Text.royalPoints.localizedText
        
        createTextDescription()
    }
    
    private func visualize() {
        // todo: Visualize view's here.
        let navigationBar = navigationController?.navigationBar
        let bgImage = UIImage(named:"bg_navigationbar")?.stretchableImage(withLeftCapWidth: 0, topCapHeight: 0)
        navigationBar?.setBackgroundImage(bgImage, for: .default)
        navigationBar?.barTintColor = Color.orange
        navigationBar?.isTranslucent = false
        navigationBar?.tintColor = .white
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        
        if self.tabBarController == nil {
            let image = UIImage(named: "ic_arrow_back")?.withRenderingMode(.alwaysTemplate)
            let button = UIButton(frame: CGRect(origin: .zero, size: image?.size ?? .zero))
            button.setImage(image, for: .normal)
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
            let leftBarButton = UIBarButtonItem(customView: button)
            navigationItem.leftBarButtonItem = leftBarButton
            self.navigationItem.leftBarButtonItem = leftBarButton
            
            UIApplication.setStatusBar(using: .lightContent)
            
            button.rx.tap.bind { [weak self] in
               self?.dismiss(animated: true, completion: nil)
            }.disposed(by: disposeBag)
        }
    }
    
    private func createTextDescription() {
        let languageID = Locale.current.languageCode ?? "en"
        var myText = "- Use service in app (Delivery, Food, COD, buy ticket FUTA Bus Lines, ...)"
        var greenRange = NSRange(location:54,length:4)
        var orangeRange = NSRange(location:59,length:9)
        
        if languageID == "vi" {
            myText = "- Mua dịch vụ đảm bảo trên ứng dụng (Giao hàng, Gọi đồ ăn, COD, Vé FUTA Bus Lines, ...)"
            greenRange = NSRange(location:67,length:4)
            orangeRange = NSRange(location:72,length:9)
        }
        
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .regular), NSAttributedString.Key.foregroundColor: Color.battleshipGrey]
        let attributedText = NSMutableAttributedString(string: myText, attributes: attributes)
        attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: #colorLiteral(red: 0, green: 0.3803921569, blue: 0.2392156863, alpha: 1), range: greenRange)
        attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: Color.orange, range: orangeRange)
        
        lblFutaDescription.attributedText = attributedText
    }
}
