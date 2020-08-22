//  File name   : FoodHeaderView.swift
//
//  Author      : Dung Vu
//  Created date: 10/25/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit

final class FoodVatoHeaderView: UIView, UpdateDisplayProtocol {
    /// Class's public properties.
    @IBOutlet var lblName: UILabel?
    @IBOutlet var btnSearch: UIButton?
    @IBOutlet var btnBack: UIButton?
    @IBOutlet var btnSearchAddress: UIButton?
    
    func setupDisplay(item: AddressProtocol?) {
        lblName?.text = item?.isFavoritePlace == true && item?.active == true ? item?.nameFavorite : item?.name?.orEmpty(item?.subLocality ?? "")
    }
}

