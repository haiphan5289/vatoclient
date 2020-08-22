//
//  TicketInfo.swift
//  Vato
//
//  Created by HaiPhan on 10/9/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit
import Atributika
import FwiCore

class TicketInfoVC: UITableViewController {
    @IBOutlet weak var lbReturnInfo: UILabel!
    @IBOutlet weak var lbEmailAddressText: UILabel!
    @IBOutlet weak var lbPhoneNumberText: UILabel!
    @IBOutlet weak var lbFullNameText: UILabel!
    @IBOutlet weak var lbPassengerInfo: UILabel!
    @IBOutlet weak var lbFirstInfo: UILabel!
    @IBOutlet weak var lbTotalPriceReturn: UILabel!
    @IBOutlet weak var lbTotalPriceReturnText: UILabel!
    @IBOutlet weak var lbSeatsReturnText: UILabel!
    @IBOutlet weak var lbSeatsReturn: UILabel!
    @IBOutlet weak var lbNumberOfSeatsReturn: UILabel!
    @IBOutlet weak var lbNoOfSeatsReturnText: UILabel!
    @IBOutlet weak var lbContentLocationReturn: UILabel!
    @IBOutlet weak var lbLocationPickUpReturn: UILabel!
    @IBOutlet weak var lbLocationPickUpReturnText: UILabel!
    @IBOutlet weak var lbTimeReturn: UILabel!
    @IBOutlet weak var lbTimeReturnText: UILabel!
    @IBOutlet weak var lbNameTripReturn: UILabel!
    @IBOutlet weak var lbNameTripReturnText: UILabel!
    @IBOutlet weak var lbTotalPriceFirst: UILabel!
    @IBOutlet weak var lblTotalPriceFirstText: UILabel!
    @IBOutlet weak var lbSeatsFirst: UILabel!
    @IBOutlet weak var lbSeatsFirstText: UILabel!
    @IBOutlet weak var lbNumberOfSeatsFirst: UILabel!
    @IBOutlet weak var lbNoOfSeatsFirstText: UILabel!
    @IBOutlet weak var lbContentLocationPickUpFirst: UILabel!
    @IBOutlet weak var lbLocationPickUpFirst: UILabel!
    @IBOutlet weak var lbLocationPickUpFirstText: UILabel!
    @IBOutlet weak var lbTimeFirst: UILabel!
    @IBOutlet weak var lbTimeFirstText: UILabel!
    @IBOutlet weak var lbNameTripFirst: UILabel!
    @IBOutlet weak var lbNameTripFirstText: UILabel!
    @IBOutlet weak var lbEmailAddress: UILabel!
    @IBOutlet weak var lbFullName: UILabel!
    @IBOutlet weak var lbPhoneNumber: UILabel!
    
    @IBOutlet var viewChangeTicketFee: UIView!
    @IBOutlet weak var changeTicketFeeTitle: UILabel?
    @IBOutlet weak var changeTicketFeeContent: UILabel?
    private var newTicketInformation: TicketInformation?
    private var returnTicketInformation: TicketInformation?
    
    @IBOutlet weak var qrDepartImageView: UIImageView?
    @IBOutlet weak var qrReturnImageView: UIImageView?
    @IBOutlet weak var lblTitleDepartTicketCode: UILabel?
    @IBOutlet weak var lblTitleReturnTicketCode: UILabel?
    @IBOutlet weak var lblDepartTicketCode: UILabel?
    @IBOutlet weak var lblReturnTicketCode: UILabel?
    @IBOutlet weak var lblDepartStatus: UILabel?
    @IBOutlet weak var lblReturnStatus: UILabel?
    
    @IBOutlet weak var btnDetailDepart: UIButton?
    @IBOutlet weak var btnDetailReturn: UIButton?
    
    private var numberSections: Int = 2
    private lazy var footerView: DetailPriceView = DetailPriceView(frame: .zero)
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        tableView.showsVerticalScrollIndicator = false
        localize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func localize(){
        lbPassengerInfo.text = Text.passengerInformation.localizedText
        lbFullNameText.text = Text.fullname.localizedText
        lbPhoneNumberText.text = Text.phoneNumber.localizedText
        lbEmailAddressText.text = Text.addressEmail.localizedText
        lbFirstInfo.text = FwiLocale.localized("Thông tin lượt đi")
        lbNameTripFirstText.text = Text.nameTrip.localizedText
        lbTimeFirstText.text = Text.timeTrip.localizedText
        lbLocationPickUpFirstText.text = Text.locationPickup.localizedText
        lbLocationPickUpReturnText.text = Text.locationPickup.localizedText
        lbNoOfSeatsFirstText.text = Text.numberOfSeats.localizedText
        lbSeatsFirstText.text = Text.seats.localizedText
    
        lbReturnInfo.text = Text.returnInformation.localizedText
        lbNameTripReturnText.text = Text.nameTrip.localizedText
        lbTimeReturnText.text = Text.timeTrip.localizedText

        lbNoOfSeatsReturnText.text = Text.numberOfSeats.localizedText
        lbSeatsReturnText.text = Text.seats.localizedText
        lblTotalPriceFirstText.text = FwiLocale.localized("Tồng tiền lượt đi")
        lbTotalPriceReturnText.text = FwiLocale.localized("Tồng tiền lượt về")
        changeTicketFeeTitle?.text = Text.confirmChangeTicket.localizedText
        changeTicketFeeContent?.text = Text.contentChangeTicketFee.localizedText
        
        lblTitleDepartTicketCode?.text = FwiLocale.localized("Mã vé")
        lblTitleDepartTicketCode?.text = FwiLocale.localized("Mã vé")
        
    }

    //// MARK: - Table view data source, delegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return numberSections
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section < numberSections - 1 ? 10 : 0.1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    private func setupFooter() {
        defer {
            self.tableView.tableFooterView = footerView
        }
        
        var total: Double = 0
        var fee: Double = 0
        var styles = [PriceInfoDisplayStyle]()
        
        let allTitle = Atributika.Style.font(.systemFont(ofSize: 15, weight: .regular)).foregroundColor(#colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1))
        let allPrice = Atributika.Style.font(.systemFont(ofSize: 15, weight: .regular)).foregroundColor(#colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1))
        let lastPrice = Atributika.Style.font(.systemFont(ofSize: 20, weight: .medium)).foregroundColor(#colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1))
        let discountPrice = Atributika.Style.font(.systemFont(ofSize: 15, weight: .medium)).foregroundColor(#colorLiteral(red: 0.9333333333, green: 0.3215686275, blue: 0.1333333333, alpha: 1))
        let method = (newTicketInformation?.paymentCardType ?? returnTicketInformation?.paymentCardType)?.generalName
        var addedFee: Bool = false
        if let departTicket = newTicketInformation, departTicket.valid {
            let p = departTicket.totalPrice ?? 0
            total += p
            
            let f = departTicket.totalFeeTicket
            fee += f
            addedFee = true
            let textTitle = FwiLocale.localized(Text.ticketDepartPrice.localizedText).styleAll(allTitle).attributedString
            let textPrice = p.currency.styleAll(allPrice).attributedString
            
            let a = PriceInfoDisplayStyle(attributeTitle: textTitle, attributePrice: textPrice, showLine: false, edge: .zero)
            styles.append(a)
        }
        
        var returnDiscount: Double?
        if let returnTicket = returnTicketInformation, returnTicket.valid {
            let p = returnTicket.totalPrice ?? 0
            total += p
            
            let f = returnTicket.totalFeeTicket
            if !addedFee {
                fee += f
            }
            
            let textTitle = FwiLocale.localized(Text.ticketReturnPrice.localizedText).styleAll(allTitle).attributedString
            let textPrice = p.currency.styleAll(allPrice).attributedString
            
            let a = PriceInfoDisplayStyle(attributeTitle: textTitle, attributePrice: textPrice, showLine: false, edge: .zero)
            styles.append(a)
            
            returnDiscount = returnTicket.seats?.reduce(0, { (x, y) -> Double in
                return x + (y.discount ?? 0)
            })
        }
        
        var totalDiscount: Double = 0
        _ = newTicketInformation?.seats?.filter({ (value) -> Bool in
            
            if let discount = value.discount {
                totalDiscount += discount
            }
            
            return value.promotion?.value != nil
        })
        
        if totalDiscount > 0 || (returnDiscount ?? 0) > 0 {
            let textTitle = FwiLocale.localized(Text.discountTicketSeat.localizedText).styleAll(allTitle).attributedString
            let textPrice = (totalDiscount + (returnDiscount ?? 0)).currency.styleAll(discountPrice).attributedString
            
            let a = PriceInfoDisplayStyle(attributeTitle: textTitle, attributePrice: textPrice, showLine: false, edge: .zero)
            styles.append(a)
        }
        

        let textTitleFee = FwiLocale.localized(Text.paymentFees.localizedText).styleAll(allTitle).attributedString
        let textPriceFee = fee.currency.styleAll(allPrice).attributedString
        
        let a = PriceInfoDisplayStyle(attributeTitle: textTitleFee, attributePrice: textPriceFee, showLine: false, edge: .zero)
        styles.append(a)
        
        let textTitleTotal = FwiLocale.localized(Text.pay.localizedText + " \(method ?? "")").styleAll(allTitle).attributedString
        let textPriceTotal = (total + fee - totalDiscount - (returnDiscount ?? 0)).currency.styleAll(lastPrice).attributedString
        
        let a2 = PriceInfoDisplayStyle(attributeTitle: textTitleTotal, attributePrice: textPriceTotal, showLine: true, edge: UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0))
        styles.append(a2)
        
        footerView.setupDisplay(item: styles)
        let s = footerView.systemLayoutSizeFitting(CGSize(width: UIScreen.main.bounds.width, height: .infinity), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        footerView.frame = CGRect(origin: .zero, size: s)
    }
    
    func updateReturnUI(model: TicketInformation?) {
        guard model?.valid == true else { return }
        defer {
            setupFooter()
        }
        self.returnTicketInformation = model
        numberSections = 3
        self.tableView.reloadData()
        
        lbNameTripReturn.text = model?.routeName
        let dateStr = model?.date?.string(from: "dd/MM/yyyy") ?? ""
        lbTimeReturn.text = "\(model?.scheduleTime ?? "") \(dateStr)"
        
        
        lbLocationPickUpReturn.text = model?.routeStopAddress
        lbContentLocationReturn.text = model?.routeStopName
        lbNumberOfSeatsReturn.text = "\(model?.seats?.count ?? 0)"
        lbSeatsReturn.text = model?.getSeatsStr()

        let lastPrice = model?.totalPrice
        let returnDiscount = model?.seats?.reduce(0, { (x, y) -> Double in
            return x + (y.discount ?? 0)
        })
        lbTotalPriceReturn.text = ((lastPrice ?? 0) - (returnDiscount ?? 0)).currency
        
        lblReturnTicketCode?.text = model?.ticketsCode
        qrReturnImageView?.image = model?.ticketsCode?.generateQRCode()
        self.updateUI(ticketModel: model?.detail, label: lblReturnStatus)
    }
    
    private func updateUI(ticketModel: HistoryDetailDisplay?, label: UILabel?)  {
        let status = ticketModel?.status ?? .success
        switch status {
        case .pending:
            label?.text = FwiLocale.localized("Thành công")
        case .processing:
            label?.text = status.title
        default:
            label?.text = FwiLocale.localized("Thành công")
        }
    }

    func updateUI(model: TicketInformation?,
                  streamType: BuslineStreamType = .buyNewticket) {
        defer {
            setupFooter()
        }
        
        newTicketInformation = model
        switch streamType {
        case .changeTicket(let oldModel):
            
            let ticketCode = oldModel.ticketCode
            let feeMoney = oldModel.feeMoney(newRoute: model?.routeId ?? 0)
            let moneyReturn = oldModel.totalStr
            let route = oldModel.route
            
            if oldModel.isSameRoute(newRoute: model?.routeId ?? 0) {
                changeTicketFeeTitle?.text = Text.confirmChangeTicket.localizedText
                changeTicketFeeContent?.text = Text.changeTicketFee.localizedText + feeMoney.currency
            } else {
                changeTicketFeeTitle?.text = Text.changingTicket.localizedText
                changeTicketFeeContent?.text = String(format: Text.contentChangeTicketFee.localizedText, ticketCode, route, moneyReturn, feeMoney.currency)
            }
            let s = viewChangeTicketFee.systemLayoutSizeFitting(CGSize(width: UIScreen.main.bounds.width, height: .infinity), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
            viewChangeTicketFee.frame = CGRect(origin: .zero, size: s)
            tableView.tableHeaderView = viewChangeTicketFee
        case .buyNewticket, .roundTrip:
            break
        }

        lbEmailAddress.text = model?.user?.email
        lbFullName.text = model?.user?.name
        lbPhoneNumber.text = model?.user?.phone
        
        lbNameTripFirst.text = model?.routeName
        let dateStr = model?.date?.string(from: "dd/MM/yyyy") ?? ""
        lbTimeFirst.text = "\(model?.scheduleTime ?? "") \(dateStr)"
        lbLocationPickUpFirst.text = model?.routeStopName
        lbContentLocationPickUpFirst.text = model?.routeStopAddress
        lbNumberOfSeatsFirst.text = "\(model?.seats?.count ?? 0)"
        lbSeatsFirst.text = model?.getSeatsStr()
        
        
        let lastPrice = model?.totalPrice
        var totalDiscount: Double = 0
        _ = model?.seats?.filter({ (value) -> Bool in
            
            if let discount = value.discount {
                totalDiscount += discount
            }
            
            return value.promotion?.value != nil
        })
        lbTotalPriceFirst.text = ((lastPrice ?? 0) - totalDiscount).currency
        
        lblDepartTicketCode?.text = model?.ticketsCode
        qrDepartImageView?.image = model?.ticketsCode?.generateQRCode()
        self.updateUI(ticketModel: model?.detail, label: lblDepartStatus)
    }
}
