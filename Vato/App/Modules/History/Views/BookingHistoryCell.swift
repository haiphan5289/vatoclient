//
//  BookingHistoryCell.swift
//  Vato
//
//  Created by vato. on 12/26/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit
import SnapKit

class BookingHistoryCell: UITableViewCell, UpdateDisplayProtocol {
    @IBOutlet private var timeLabel: UILabel?
    @IBOutlet private var statusLabel: UILabel?
    @IBOutlet private var serviceLabel: UILabel?

    @IBOutlet private var lblReport: UILabel?
    @IBOutlet var btnReport: UIButton?
    
    @IBOutlet private var pointsStackView: UIStackView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        lblReport?.text = Text.feedback.localizedText
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupDisplay(item: BookingHistoryModel?) {
        display(model: item)
    }
    
    func display(model: BookingHistoryProtocol?) {
        guard let model = model else { return }
        self.timeLabel?.text = (model.dateCreate?.string(from: "HH:mm dd/MM/yyyy") ?? "") + " • " + (model.code ?? "")
        self.statusLabel?.text = model.statusStr
        self.statusLabel?.textColor = model.statusColor
        self.serviceLabel?.text = (model.serviceName ?? "") + " • " + (model.priceStr ?? "")
        
        for view in pointsStackView.arrangedSubviews {
            pointsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        
        if let wps = model.waypoints {
            var index = 0
            for p in wps {
                let v = PointView(frame: .zero)
                v.snp.makeConstraints { (make) in
                    make.height.equalTo(20)
                }
                v.setupDisplay(item: p)
                pointsStackView.addArrangedSubview(v)
                
                
                if index < wps.count-1 {
                    pointsStackView.addArrangedSubview(self.generateVerticalLineView())
                }
                index += 1
            }
        }
    }
    
    
    func generateVerticalLineView() -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.snp.makeConstraints { (make) in
            make.height.equalTo(10)
        }
        let image = UIImageView(image: UIImage(named: "ic_vertical_4dots"))
        image.contentMode = .scaleAspectFit
        view.addSubview(image)
        image.snp.makeConstraints { (make) in
            make.width.equalTo(2);
            make.top.equalTo(0);
            make.bottom.equalTo(0);
            make.left.equalTo(7);
        }
        return view
    }
}
