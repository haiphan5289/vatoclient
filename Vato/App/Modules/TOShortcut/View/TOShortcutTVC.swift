//
//  TOShortcutTVC.swift
//  Vato
//
//  Created by khoi tran on 2/17/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit
import FwiCore

enum TOShortcutCellType: Int, Codable {
    case normal = 0
    case badge
}

enum TOShortCutType: Int, Codable {
    case paymentHistory = 0
    case history
    case quickSupport
    case sos
    case merchant
    case inviteFriend
    case uniform
    case booking
    case topup
    case addNewDestination
    case changeDestination
    case other
    
    
    var icon: UIImage? {
        return UIImage(named: "ic_shortcut_\(self.rawValue)")
    }
}

protocol TOShortcutCellDisplay {
    
    var name: String? { get }
    var description: String? { get }
    var cellType: TOShortcutCellType { get }
    var isNew: Bool? { get }
    var badgeNumber: Int? { get }
    var type: TOShortCutType { get }
}



class TOShortcutTVC: UITableViewCell, UpdateDisplayProtocol {
   
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var lblName: UILabel!
    
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var dotView: UIView!
    
    @IBOutlet weak var badgeView: UIView!
    @IBOutlet weak var lblBadgeNumber: UILabel!
    @IBOutlet weak var descriptionView: UIView!
    
    @IBOutlet weak var imvIcon: UIImageView!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupDisplayIndex(index: IndexPath) {
        self.containerView?.backgroundColor = index.row.isMultiple(of: 2) ? UIColor.white : UIColor(red: 254.0/255.0, green: 242.0/255.0, blue: 239.0/255.0, alpha: 1.0)
        
    }
    
    
    func setupDisplay(item: TOShortcutCellDisplay?) {
        
        guard let item = item else { return }
        self.lblName.text = FwiLocale.localized(item.name)
        
        if let description = item.description, !description.isEmpty {
            self.lblDescription.text =  FwiLocale.localized(item.description)
            self.descriptionView.isHidden = false
        } else {
            self.descriptionView.isHidden = true
        }
        
        switch item.cellType {
        case .badge:
            self.dotView.isHidden = true
            self.badgeView.isHidden = false
            if let badgeNumber = item.badgeNumber {
                self.lblBadgeNumber.text = "\(badgeNumber)"
            }
        case .normal:
            self.badgeView.isHidden = true
            let isNew = item.isNew ?? false
            self.dotView.isHidden = !isNew
        }
        
        imvIcon.image = item.type.icon
        
    }
    
}
