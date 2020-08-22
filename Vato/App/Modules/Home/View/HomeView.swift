//  File name   : HomeView.swift
//
//  Author      : Vato
//  Created date: 9/14/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit

final class HomeView: UIView {
    /// Class's public properties.
    @IBOutlet weak var currentLocationButton: UIButton!
    /// Origin location.
    @IBOutlet weak var originLocationTagLabel: UILabel!
    @IBOutlet weak var originLocationLabel: UILabel!
    @IBOutlet weak var originLocationButton: UIButton!
    /// Destination1 location.
    @IBOutlet weak var destination1LocationLabel: UILabel!
    @IBOutlet weak var destination1LocationButton: UIButton!
    /// Destination1 suggestion.
    @IBOutlet weak var suggestionCollectionView: UICollectionView!
    
    /// Contain origin and destination.
    @IBOutlet weak var destinationView: UIView!
    @IBOutlet weak var btnDelivery: UIButton?
    @IBOutlet weak var lblDelivery: UILabel?

    
    /// Class's private properties.
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let v = super.hitTest(point, with: event)
        guard v is UIControl || destinationView.frame.contains(point) else {
            return nil
        }
        return v
    }
}

// MARK: Class's public methods
extension HomeView {
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
private extension HomeView {
    private func initialize() {
        originLocationTagLabel.text = Text.yourCurrentLocation.localizedText
        originLocationLabel.text = Text.pickupAddress.localizedText

        destination1LocationLabel.text = Text.whereDoYouGo.localizedText
        
    }

    private func visualize() {
        // todo: Visualize view's here.
        lblDelivery?.text = Text.delivery.localizedText
    }
}
