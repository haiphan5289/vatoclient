//  File name   : InTripDriverView.swift
//
//  Author      : Dung Vu
//  Created date: 3/13/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import Kingfisher

final class InTripDriverView: UIView, UpdateDisplayProtocol {
    /// Class's public properties.
    @IBOutlet var lblName : UILabel?
    @IBOutlet var lblDescription : UILabel?
    @IBOutlet var avatarView : UIImageView?
    @IBOutlet var viewTaxi : UIView?
    @IBOutlet var lblTaxiName : UILabel?
    
    private var task: TaskExcuteProtocol?
    /// Class's private properties.
    
    func setupDisplay(item: DriverInfo?) {
        lblName?.text = item?.personal.fullname
        let model = item?.customer.vehicle?.marketName
        let plate = item?.customer.vehicle?.plate
        let text = String.makeStringWithoutEmpty(from: model, plate, seperator: " • ")
        lblDescription?.text = text
        task = avatarView?.setImage(from: item?.personal, placeholder: UIImage(named: "ic_default_avatar"), size: CGSize(width: 56, height: 56))
    }
    
    func updateBrandTaxi(name: String?) {
        guard let n = name, !n.isEmpty else { return }
        viewTaxi?.isHidden = false
        lblTaxiName?.text = n
    }
    
    override func removeFromSuperview() {
        task = nil
        super.removeFromSuperview()
    }
}

// MARK: Class's public methods
extension InTripDriverView {
    override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        visualize()
    }
}

// MARK: Class's private methods
private extension InTripDriverView {
    private func initialize() {
        // todo: Initialize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
    }
}
