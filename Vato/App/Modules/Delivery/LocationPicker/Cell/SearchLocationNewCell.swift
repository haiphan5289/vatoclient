//
//  SearchLocationNewCell.swift
//  Vato
//
//  Created by khoi tran on 11/13/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit

class SearchLocationNewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func updateData(model: AddressProtocol, typeLocationPicker: LocationPickerDisplayType) {
        let name = model.isFavoritePlace == true && model.active == true ? model.nameFavorite : model.name
        self.nameLabel.text = name?.orEmpty(model.subLocality) ?? model.subLocality
        self.addressLabel.text = model.subLocality.isEmpty ? "  " : model.subLocality
        
        if let distance = model.distance {
            let km = distance / 1000
            let text = String(format: "%.1f km", km)
            self.distanceLabel.text = text
        } else {
            let current = UserManager.instance.currentLocation ?? MapInteractor.Config.defaultMarker.address.coordinate
            let coor = model.coordinate
            if (coor != kCLLocationCoordinate2DInvalid) && (coor.latitude != 0 && coor.longitude != 0) {
                let d = current.distance(other: coor)
                let km = d / 1000
                let text = String(format: "%.1f km", km)
                self.distanceLabel.text = text
            } else {
                self.distanceLabel.text = "--"
            }
        }
        
        switch typeLocationPicker {
        case .updatePlaceMode:
            self.addButton.isHidden = true
        case .full:
            self.addButton.isHidden = model.isDatabaseLocal
        }
        guard model.isDatabaseLocal else { return }
        if model.counter > 100 {
            self.counterLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
            self.counterLabel.text = "99+"
        } else {
            self.counterLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            self.counterLabel.text = "\(model.counter)"
        }
    }
}
