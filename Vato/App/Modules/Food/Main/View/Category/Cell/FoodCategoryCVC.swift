//
//  FoodCategoryCVC.swift
//  Vato
//
//  Created by Dung Vu on 10/25/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit
import Kingfisher

protocol FoodCategoryDisplayProtocol: ImageDisplayProtocol {
    var name: String? { get }
    var local: Bool { get }
}

extension FoodCategoryItem: FoodCategoryDisplayProtocol, CategoryRequestProtocol {
    var hasChildren: Bool {
        let c = children ?? []
        return c.isEmpty == false
    }
}
extension MerchantCategory: FoodCategoryDisplayProtocol, CategoryRequestProtocol {
    var local: Bool {
        return false
    }
    
    var hasChildren: Bool {
        let c = children ?? []
        return c.isEmpty == false
    }
    
    var imageURL: String? {
        return catImage?.first
    }
    
    var cacheLocal: Bool { return false }
}


class FoodCategoryCVC: UICollectionViewCell, UpdateDisplayProtocol {
    @IBOutlet var imageView: UIImageView?
    @IBOutlet var lblName: UILabel?
    var currentItem: FoodCategoryDisplayProtocol?
    private var task: TaskExcuteProtocol?
    override func prepareForReuse() {
        task = nil
        super.prepareForReuse()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupDisplay(item: FoodCategoryDisplayProtocol?) {
        currentItem = item
        let f = imageView?.bounds ?? .zero
        task = imageView?.setImage(from: item, placeholder: nil, size: f.size)
        lblName?.text = item?.name
    }

}


final class FoodCategoryParentCVC: FoodCategoryCVC {
    override func setupDisplay(item: FoodCategoryDisplayProtocol?) {
        if let item = item, item.local {
            lblName?.textColor = #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1)
            lblName?.text = "Xem Thêm"
            imageView?.image = UIImage(named: "ic_more_f_service")
            currentItem = item
        } else {
            lblName?.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
            super.setupDisplay(item: item)
        }
        
        
    }
}
