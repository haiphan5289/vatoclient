//  File name   : FoodDescriptionTVC.swift
//
//  Author      : Dung Vu
//  Created date: 10/30/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit

protocol DisplayStoreShortProtocol: DisplayDistanceProtocol {
    var lblOpen: UILabel? { get }
}

extension DisplayStoreShortProtocol {
    func display(item: DisplayShortDescriptionProtocol?) {
        displayDistance(item: item)
        guard let today = FoodWeekDayType.today() else { return }
        if let time = item?.workingHours?.daily?[today] {
            lblOpen?.text = time.openText
            lblOpen?.textColor = time.color
        } else {
            lblOpen?.text = "--"
            lblOpen?.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
        }
    }
}

final class FoodDescriptionTVC: UITableViewCell, UpdateDisplayProtocol, DisplayStoreShortProtocol {
    /// Class's public properties.
    @IBOutlet var lblTitle: UILabel?
    @IBOutlet var lblCategory: UILabel?
    @IBOutlet var lblDistance: UILabel?
    @IBOutlet var lblTime: UILabel?
    @IBOutlet var lblOpen: UILabel?
    
    @IBOutlet var viewDiscount: UIStackView?
    @IBOutlet var lblDiscount: UILabel?
    
    var lineView: UIView?

    /// Class's private properties.
    func setupDisplay(item: FoodExploreItem?) {
        lblTitle?.text = item?.name
        lblCategory?.text = item?.descriptionCat
        display(item: item)
        
    }
}

// MARK: Class's public methods
extension FoodDescriptionTVC {
    override func awakeFromNib() {
        super.awakeFromNib()
        visualize()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        localize()
    }
}

// MARK: Class's private methods
private extension FoodDescriptionTVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        lineView = contentView.addSeperator(with: .zero, position: .bottom)
    }
}
