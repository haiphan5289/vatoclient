//
//  QSRequestTVC.swift
//  FC
//
//  Created by khoi tran on 1/15/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit
import Kingfisher

class QSRequestTVC: UITableViewCell, UpdateDisplayProtocol {
    @IBOutlet weak var requesTitleLabel: UILabel!
    @IBOutlet weak var createdDateLabel: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusLabel: UILabel!    
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var requestMessageLabel: UILabel!
    
    @IBOutlet weak var imageStackView: UIStackView!
    @IBOutlet weak var requestImageView: UIView!
    
    @IBOutlet weak var responseStackView: UIStackView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupDisplay(item: QuickSupportModel?) {
        requesTitleLabel.text = item?.request?.title
        if let createdDate = item?.request?.createdAt {
            let date = Date(timeIntervalSince1970: createdDate)
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm dd/MM/yyyy"
            let dateString = formatter.string(from: date)
            createdDateLabel.text = dateString
        }
        
        requestMessageLabel.text = item?.request?.description
        statusLabel.text = item?.request?.status?.string()
        statusLabel.textColor = item?.request?.status?.titleColor()
        statusView.backgroundColor = item?.request?.status?.bgColor()
        
        if let images = item?.request?.images, !images.isEmpty {
            requestImageView.isHidden = false
            for view in imageStackView.arrangedSubviews {
                imageStackView.removeArrangedSubview(view)
                view.removeFromSuperview()
            }
            
            for image in images {
                let options: KingfisherOptionsInfo = [.fromMemoryCacheOrRefresh, .transition(.fade(0.3))]
                let imageView = UIImageView.create {
                    $0.contentMode = .scaleAspectFill
                    $0.clipsToBounds = true
                    $0.cornerRadius = 6
                    $0.kf.setImage(with: URL(string: image), placeholder: nil, options: options)
                    $0.snp.makeConstraints { (make) in
                        make.width.equalTo(80)
                    }
                }
                
                imageStackView.addArrangedSubview(imageView)
            }
        } else {
            requestImageView.isHidden = true
        }
        
        if let responses = item?.response, !responses.isEmpty, let type = item?.type {
            responseStackView.isHidden = false
            for view in responseStackView.arrangedSubviews {
                imageStackView.removeArrangedSubview(view)
                view.removeFromSuperview()
            }
            
            switch type {
            case .home:
                let view = QSResponseView.loadXib()
                view.setupDisplay(item: responses.first!)
                responseStackView.addArrangedSubview(view)
            case .detail:
                for response in responses {
                    let view = QSResponseView.loadXib()
                    view.setupDisplay(item: response)
                    responseStackView.addArrangedSubview(view)
                }
            }
            
        } else {
            responseStackView.isHidden = true
        }
    }
}

