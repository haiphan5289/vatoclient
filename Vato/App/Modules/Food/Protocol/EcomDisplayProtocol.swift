//  File name   : EcomDisplayProtocol.swift
//
//  Author      : Dung Vu
//  Created date: 6/10/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit

// MARK: - Display Distance
protocol DisplayDistanceProtocol {
    var lblDistance: UILabel? { get }
    var lblTime: UILabel? { get }
    var viewDiscount: UIStackView? { get }
    var lblDiscount: UILabel? { get }
    
    func displayDistance(item: DisplayShortDescriptionProtocol?)
}

extension DisplayDistanceProtocol {
    func getTextDistance(item: DisplayShortDescriptionProtocol?) -> (distance: String, time: String) {
        let current = UserManager.instance.currentLocation
        let coor = item?.coordinate ?? kCLLocationCoordinate2DInvalid
        let d = current?.distance(other: coor) ?? 0
        let km = d / 1000
        let distance = String(format: "%.2fkm", km)
        
        let time: String
        let seconds = ((km / 20) * 3600).rounded(.awayFromZero)
        let hours = Int(seconds) / 3600
        let minutes = ((Int(seconds) - (hours * 3600))) / 60
        let remain = Int(seconds) - hours * 3600 - minutes * 60
        if hours > 0 {
            time = String(format: "%dhrs%dph", hours, minutes)
            return (distance, time)
        }
        
        if minutes > 0 {
            time = String(format: "%dph", minutes + (remain > 0 ? 1 : 0))
            return (distance, time)
        }
        return (distance, "\(1)ph")
    }
    
    func displayDistance(item: DisplayShortDescriptionProtocol?) {
        viewDiscount?.isHidden = item?.salesRule == nil
        lblDiscount?.text = item?.salesRule?.name
        let result = getTextDistance(item: item)
        lblDistance?.text = result.distance
        lblTime?.text = result.time
    }
}

// MARK: - Display promotion
protocol DisplayPromotionProtocol {
    var imagePromotionView: UIImageView? { get }
    func displayPromotion(item: StoreProductDiscountInformation?)
}

extension DisplayPromotionProtocol {
    func displayPromotion(item: StoreProductDiscountInformation?) {
        let show = item?.valid ?? false
        imagePromotionView?.backgroundColor = .clear
        imagePromotionView?.isHidden = !show
        imagePromotionView?.setImage(from: item, placeholder: nil, size: CGSize(width: 74, height: 20))
    }
}
