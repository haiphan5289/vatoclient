//
//  FavoritePlaceTableViewCell.swift
//  Vato
//
//  Created by vato. on 7/18/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit
import VatoNetwork

enum ImageFavoritePlacesEdit: String {
    case edit = "ic_add_favorite_place_edit"
    case searchPlaces = "ic_booking_place"
    
    func getImage() -> UIImage? {
        switch self {
        case .edit:
            return UIImage(named: rawValue)
        case .searchPlaces:
            return UIImage(named: rawValue)
        }
    }
}

class FavoritePlaceTableViewCell: UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var widthOfViewIcon: NSLayoutConstraint!
    @IBOutlet weak var widthOfViewAccessory: NSLayoutConstraint!
    @IBOutlet weak var btEdit: UIButton!
    var buttonAction: ((_ sender: Any) -> Void)?
    @IBOutlet weak var lbContent: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc static func newCell(reuseIdentifier: String) -> FavoritePlaceTableViewCell {
        let cell = Bundle.main.loadNibNamed(String(describing: self), owner: self, options: nil)?.first as! FavoritePlaceTableViewCell
        cell.setValue(reuseIdentifier, forKey: "reuseIdentifier")
        return cell
    }
    func displayData(model: PlaceModel?) {
        self.widthOfViewIcon.constant = 40
        self.titleLabel.text = model?.name
        self.subTitleLabel.text = model?.address
        if let imageName = model?.getIconName() {
            self.iconImageView.image = UIImage(named: imageName)
        }
//        self.accessoryType = .disclosureIndicator
        self.widthOfViewAccessory.constant = 50
        self.lbContent.text = Text.edit.localizedText
        btEdit.setImage(ImageFavoritePlacesEdit.edit.getImage(), for: .normal)
    }
    
    func displayDataMapPlaceModel(model: MapModel.Place?) {
        self.widthOfViewIcon.constant = 0
        self.titleLabel.text = model?.primaryName
        self.subTitleLabel.text = model?.address
        self.iconImageView.image = nil
        self.accessoryType = .none
        btEdit.setImage(ImageFavoritePlacesEdit.searchPlaces.getImage(), for: .normal)
        self.lbContent.text = nil
        self.widthOfViewAccessory.constant = 50
        
    }
    @IBAction func buttonPress(_ sender: Any) {
        self.buttonAction?(sender)
    }
    
    
}
