//
//  VatoLocationHeaderView.swift
//  Vato
//
//  Created by khoi tran on 11/14/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit
import CoreLocation

class VatoLocationHeaderView: UIView, UpdateDisplayProtocol {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var btnSearchAddress: UIButton?
    @IBOutlet weak var mapLabel: UILabel!
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        mapLabel.text = Text.map.localizedText
    }

    func setupDisplay(item: AddressProtocol?) {
        let isFavorite = item?.isFavoritePlace == true && item?.active == true
        let text = isFavorite ? item?.nameFavorite : item?.name?.orEmpty(item?.subLocality ?? "")
        nameLabel.text = text
    }
}
