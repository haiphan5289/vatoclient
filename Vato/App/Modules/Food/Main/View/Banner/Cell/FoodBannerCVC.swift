//
//  FoodBannerCVC.swift
//  Vato
//
//  Created by Dung Vu on 10/25/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit
import Kingfisher

final class FoodBannerCVC: UICollectionViewCell, UpdateDisplayProtocol {
    @IBOutlet var bannerImageView: UIImageView?
    private var task: TaskExcuteProtocol?
    override func prepareForReuse() {
        super.prepareForReuse()
        task?.cancel()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupDisplay(item: ImageDisplayProtocol?) {
        task = bannerImageView?.setImage(from: item, placeholder: nil, size: CGSize(width: UIScreen.main.bounds.width, height: 200))
    }
    

}
