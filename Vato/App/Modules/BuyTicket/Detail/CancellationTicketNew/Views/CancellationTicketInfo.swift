//
//  CancellationTicketInfo.swift
//  Vato
//
//  Created by HaiPhan on 10/9/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit

enum CancellationSection: Int {
    case route = 0
    case infoCancelTrip = 1
    case note = 2
}

class CancellationTicketInfo: UITableViewController {

    @IBOutlet weak var moneyValueLbl: UILabel!
    @IBOutlet weak var moneyLbl: UILabel!
    @IBOutlet weak var lbNoteContent: UILabel!
    @IBOutlet weak var lbNote: UILabel!
    @IBOutlet weak var lbDoNotCancel: UILabel!
    @IBOutlet weak var lbTimeAfter24h: UILabel!
    @IBOutlet weak var After24h: UILabel!
    @IBOutlet weak var lbTimeBefore24h: UILabel!
    @IBOutlet weak var lbBefore24h: UILabel!
    @IBOutlet weak var lbCancelFee: UILabel!
    @IBOutlet weak var lbTimeCancel: UILabel!
    @IBOutlet weak var lbCancellationPolicy: UILabel!
    @IBOutlet weak var lbPriceData: UILabel!
    @IBOutlet weak var lbPrice: UILabel!
    @IBOutlet weak var lbTimeTripData: UILabel!
    @IBOutlet weak var lbTimeTrip: UILabel!
    @IBOutlet weak var lbNameTripData: UILabel!
    @IBOutlet weak var lbNameTrip: UILabel!
    @IBOutlet weak var lbPercentDiscount: UILabel!
    
    var item: TicketHistoryType?
    override func viewDidLoad() {
        super.viewDidLoad()
        localize()
        self.tableView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
    }
    private func localize(){
        lbNameTrip.text = Text.nameTrip.localizedText
        lbTimeTrip.text = Text.timeTrip.localizedText
        lbPrice.text = Text.priceTicket.localizedText
        lbCancellationPolicy.text = Text.policyCancel.localizedText
        lbTimeCancel.text = Text.cancellationTimeTicket.localizedText
        lbCancelFee.text = Text.cancellationPriceTicket.localizedText
        lbDoNotCancel.text = Text.impossibleCancellationTicket.localizedText
        lbNote.text = Text.noteTicket.localizedText
        moneyLbl.text = Text.cancellationMoneyRefund.localizedText
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == CancellationSection.route.rawValue {
            if item?.status == .pending,
                item?.paymentMethod == PaymentMethodCash.rawValue {
                return 3
            } else {
                return 4
            }
        } else if section == CancellationSection.infoCancelTrip.rawValue {
            return 3
        } else if section == CancellationSection.note.rawValue {
            return 1
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }

    func setupUI(item: TicketHistoryType?) {
        self.item = item
        lbNameTripData.text = item?.routeName
        lbTimeTripData.text = "\(item?.departureTime ?? "") \(item?.departureDate ?? "")"
        lbPriceData.text = "\(item?.price?.currency ?? "")"
        
        let price = item?.price ?? 0
        let feeCancel = (item?.feeCancel ?? 0)/100
        let moneyFee = Float(price) * feeCancel
        let mFee = moneyFee / 1000
        let moneyReturn = price - Int64(mFee * 1000)
        
        moneyValueLbl.text = "\(Int64(moneyReturn).currency)"
        lbPercentDiscount.text = "\(Int(item?.feeCancel ?? 0))%"
        lbNoteContent?.text = Text.cancellationFeeContent.localizedText
        
        if var timeAcceptCancel = item?.timeAcceptCancel {
            timeAcceptCancel = timeAcceptCancel/1000
            let dateAllowCancel = Date(timeIntervalSince1970: timeAcceptCancel)
            
            let formatterHour = DateFormatter()
            formatterHour.dateFormat = "HH:mm"
            let hourString = formatterHour.string(from: dateAllowCancel)
            
            lbBefore24h.text = String(format: Text.timeBeforeCancel.localizedText, hourString)
            After24h.text = String(format: Text.timeAfterCancel.localizedText, hourString)
            
            let formatterDate = DateFormatter()
            formatterDate.dateFormat = "dd/MM/yyyy"
            let dateString = formatterDate.string(from: dateAllowCancel)
            
            lbTimeBefore24h.text = dateString
            lbTimeAfter24h.text = dateString
        } else {
            lbBefore24h.text = ""
            After24h.text = ""
            lbTimeBefore24h.text = ""
            lbTimeAfter24h.text = ""
            
        }    
    }
}
