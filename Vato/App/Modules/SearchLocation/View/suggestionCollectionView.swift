//  File name   : SearchLocationView.swift
//
//  Author      : Vato
//  Created date: 9/17/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RxCocoa
import RxSwift
import UIKit

final class SearchLocationView: UIView {
    /// Class's public properties.
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var bottomImageView: UIImageView!

    @IBOutlet weak var locationInputView: UIView!
    @IBOutlet weak var originAddressLabel: UILabel!
    @IBOutlet weak var originAddressTextField: UITextField!

    @IBOutlet weak var destinationAddressTextField: UITextField!

//    @IBOutlet weak var mapImageView: UIImageView!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var suggestionTableView: UITableView!
    
    @IBOutlet weak var suggestionView: UIView!
    @IBOutlet weak var suggestionCollectionView: UICollectionView!
    

    /// Class's private properties.
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
}

// MARK: Class's public methods
extension SearchLocationView {
    override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        localize()

        if let text = originAddressTextField.placeholder {
            let attributed = [NSAttributedString.Key.foregroundColor: Color.battleshipGrey]
            originAddressTextField.attributedPlaceholder = NSAttributedString(string: text, attributes: attributed)
        }

        if let text = destinationAddressTextField.placeholder {
            let attributed = [NSAttributedString.Key.foregroundColor: Color.battleshipGrey]
            destinationAddressTextField.attributedPlaceholder = NSAttributedString(string: text, attributes: attributed)
        }
    }
}

// MARK: Class's private methods
private extension SearchLocationView {
    private func initialize() {
        if #available(iOS 11.0, *) {
            // Do nothing
        } else {
            topConstraint.constant = UIApplication.shared.statusBarFrame.height
        }
    }

    private func localize() {
        originAddressLabel.text = Text.yourCurrentLocation.localizedText
        originAddressTextField.placeholder = Text.pickupAddress.localizedText

        destinationAddressTextField.placeholder = Text.whereDoYouGo.localizedText
    }
}
