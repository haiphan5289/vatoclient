//
//  PopularRouteTVC.swift
//  Vato
//
//  Created by khoi tran on 5/4/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit
import Atributika

struct PopularRoute: Codable, Hashable {
    static func == (lhs: PopularRoute, rhs: PopularRoute) -> Bool {
        let c1 = lhs.promotion?.code
        let c2 = rhs.promotion?.code
        return lhs.destCode == rhs.destCode && lhs.originCode == rhs.originCode && c1 == c2
    }
    
    let description: String?
    let destCode: String?
    let destName: String?
    let originCode: String?
    let originName: String?
    let promotion: PromotionTicket?
    
    let distance: Double?
    let duration: Double?
    let name: String?
    let price: Double?
    let totalSchedule: Int?
    
    var discount: Double {
        let p = price.orNil(0)
        guard let type = promotion?.type else {
            return 0
        }
        switch type {
        case .PERCENT:
            let ratio = Double((promotion?.value).orNil(0)) / 100
            return p * ratio
        case .FLAT:
            let v = promotion?.valueResize ?? 0
            return Double(v)
        }
        
    }
    
    var destLocation: TicketLocation? {
        guard let destCode = destCode, let destName = destName else {
            return nil
        }
        
        return TicketLocation(code: destCode, name: destName)
    }
    
    var originLocation: TicketLocation? {
        guard let originCode = originCode, let originName = originName else {
            return nil
        }
        
        return TicketLocation(code: originCode, name: originName)
    }
    
    var valid: Bool {
        let items = [destCode, destName, originCode, originName].compactMap { $0 }.filter{ !$0.isEmpty }
        return items.count == 4
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(destCode ?? "")
        hasher.combine(originCode ?? "")
        hasher.combine(promotion?.code ?? "")
    }
    
    func compare(route: (origin: String?, destination: String?)?) -> Bool {
        guard let route = route else { return false }
        guard let originCode = originCode,
            let destCode = destCode,
            !originCode.isEmpty,
            !destCode.isEmpty else { return false }
        return route.origin == originCode && route.destination == destCode
    }
}

protocol RouteDelegate: class {
    func moveToDetailRoute(route: PopularRoute)
}

final class PopularRouteTVC: UITableViewCell, UpdateDisplayProtocol {

    @IBOutlet private var lblOrigin: UILabel!
    @IBOutlet private var lblDestination: UILabel!
    @IBOutlet private var lblInformation: UILabel!
    @IBOutlet private var imvPromotion: UIImageView!
    @IBOutlet private var containerView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var viewPromotion: UIView!
    @IBOutlet weak var lblPromotion: UILabel!
    
    private var route: PopularRoute?
    weak var delegate: RouteDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state

        updateSelect(selected: selected)
    }
    
    func setupDisplay(item: PopularRoute?) {
        guard let item = item else { return }
        self.lblOrigin.text = item.originName
        self.lblDestination.text = item.destName

        let seconds = item.duration ?? 0.0
        let hour: Double = Double(seconds / 3600.0)

        var t = Text.hour.localizedText
        t = (t == "hour") ? "h" : t
        var description = (item.distance ?? 0).convertToKm()
        description    += "    •    \(hour.round(to: 1).cleanValue) \(t)"
        
        let p = NSMutableParagraphStyle()
        p.lineSpacing = 5
        p.alignment = .left
               
        imvPromotion.isHidden = true
        if let price = item.price {
            description    += String(format: "    •    ")
            if let promotion = item.promotion, let percent = promotion.value, percent > 0, let type = promotion.type {
                viewPromotion.isHidden = false
                lblPromotion.text = "-" + String(percent) + "%"
                lblPromotion.text = "-" + ((type == .PERCENT) ? String(percent) + "%" : percent.currency)
                
                description    += String(format: "<st>%@</st>", price.currency)

                var discountPrice = (type == .PERCENT) ? price*(Double(percent) / 100.0) : Double(percent)
                discountPrice = price - discountPrice
                description += String(format: "    <d>%@</d>", discountPrice.currency)
                
            } else {
                viewPromotion.isHidden = true
                description    += price.currency
            }
        }
        
        if let des = item.description, !des.isEmpty {
            description    += "\n\(des)"
        }
        
        p.lineBreakMode = lblInformation.lineBreakMode
        let all = Style.foregroundColor(#colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)).paragraphStyle(p)
        let st = Style("st").strikethroughStyle(.single)
        let d = Style("d").foregroundColor(#colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1)).paragraphStyle(p)
        let att = description.style(tags: [st,d]).styleAll(all).attributedString
        lblInformation.attributedText = att
        lblInformation.adjustsFontSizeToFitWidth = true
        lblInformation.minimumScaleFactor = 0.8
        
        route = item
    }

    func setupDisplayContainerView(idx: Int) {
        containerView.backgroundColor = idx % 2 == 0 ? #colorLiteral(red: 0.9215686275, green: 0.9529411765, blue: 0.9411764706, alpha: 1) : #colorLiteral(red: 0.9921568627, green: 0.9294117647, blue: 0.9098039216, alpha: 1)
    }
    
    func updateSelect(selected: Bool) {
        if selected {
            containerView.borderColor = #colorLiteral(red: 0.9490196078, green: 0.4588235294, blue: 0.3058823529, alpha: 1)
            containerView.borderWidth = 2
        } else {
            containerView.borderWidth = 0
        }
    }
    
    @IBAction func goToDetailRoute(_ sender: Any) {
        guard let r = route else { return }
        delegate?.moveToDetailRoute(route: r)
    }
}
