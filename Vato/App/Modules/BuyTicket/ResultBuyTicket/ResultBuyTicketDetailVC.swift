//
//  ResultBuyTicketDetailVC.swift
//  Vato
//
//  Created by vato. on 10/13/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift

protocol ResultBuyTicketDetailListener: class {
    func didSeletctPayment()
}


class ResultBuyTicketDetailVC: UITableViewController {
    @IBOutlet weak var msgResultLabel: UILabel!
    @IBOutlet var ticketCodeLabel: [UILabel]?
    @IBOutlet var ticketCodeTextLabel: [UILabel]?
    @IBOutlet var statusTextLabel: [UILabel]?
    @IBOutlet var pendingWarningMessageLabel: [UILabel]?
    @IBOutlet var qrCodeImage: [UIImageView]?
    @IBOutlet var noteLabel: [UILabel]?
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var resultHeaderView: UIView!
    @IBOutlet weak var resultSuccessHeaderView: UIView!
    @IBOutlet var resultPendingHeaderView: [UIView]?
    
    
    @IBOutlet var historyHeaderView: UIView!
    
    @IBOutlet weak var paymentBtn: UIButton!
    
    @IBOutlet weak var nameTextLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var phoneTextLabel: UILabel!
    @IBOutlet weak var routNameLabel: UILabel!
    @IBOutlet weak var routNameTextLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeTextLabel: UILabel!
    @IBOutlet weak var pickupLabel: UILabel!
    @IBOutlet weak var pickupTextLabel: UILabel!
    @IBOutlet weak var pickupContentLabel: UILabel!
    @IBOutlet weak var numberSeatsLabel: UILabel!
    @IBOutlet weak var numberSeatsTextLabel: UILabel!
    @IBOutlet weak var seatsNameLabel: UILabel!
    @IBOutlet weak var seatsNameTextLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var totalPriceTextLabel: UILabel!

    @IBOutlet weak var lblPriceTicketText: UILabel!
    @IBOutlet weak var lblPriceTicket: UILabel!
    @IBOutlet weak var lblChargeFeeText: UILabel!
    @IBOutlet weak var lblChargeFee: UILabel!
    @IBOutlet weak var lbPromotionText: UILabel!
    @IBOutlet weak var lbPromotion: UILabel!
    
    private var totalPromotion: Double?
    private lazy var disposeBag = DisposeBag()
    weak var listener: ResultBuyTicketDetailListener?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        ticketCodeLabel?.forEach { $0.text = "" }
        localize()
        setupRX()
    }
    private func localize() {
        ticketCodeTextLabel?.forEach { $0.text = Text.ticketCodeTitle.localizedText }
        statusTextLabel?.forEach { $0.text = Text.status.localizedText }
        nameTextLabel.text = Text.fullname.localizedText
        phoneTextLabel.text = Text.phoneNumber.localizedText
        routNameTextLabel.text = Text.nameTrip.localizedText
        timeTextLabel.text = Text.timeTrip.localizedText
        pickupTextLabel.text = Text.locationPickup.localizedText
        numberSeatsTextLabel.text = Text.numberOfSeats.localizedText
        seatsNameTextLabel.text = Text.seats.localizedText
        totalPriceTextLabel.text = Text.totalAmountTicket.localizedText
        
        msgResultLabel.text = Text.buyTicketSuccess.localizedText

        noteLabel?.forEach { $0.text = Text.wrarningMessagePendingTicket.localizedText }
        paymentBtn.setTitle(Text.payNow.localizedText, for: .normal)
        
        lblPriceTicketText.text = Text.priceTicket.localizedText
        lblChargeFeeText.text = Text.paymentFees.localizedText
        lbPromotionText.text = Text.promotion.localizedText
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 11
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 8 && self.totalPromotion == 0 {
            return 0.1
        }
        return UITableView.automaticDimension
    }
    
    func updateUI(ticketModel: HistoryDetailDisplay?)  {
        let status = ticketModel?.status ?? .success
        switch status {
        case .pending:
            msgResultLabel.text = Text.bookingTicketSuccess.localizedText
            resultSuccessHeaderView.isHidden = true
        case .processing:
            msgResultLabel.text = status.title
            resultPendingHeaderView?.forEach { $0.isHidden = true }
        default:
            msgResultLabel.text = Text.buyTicketSuccess.localizedText
            resultPendingHeaderView?.forEach { $0.isHidden = true }
        }
        let s = resultHeaderView.systemLayoutSizeFitting(CGSize(width: UIScreen.main.bounds.width, height: .infinity), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        resultHeaderView.frame = CGRect(origin: .zero, size: s)
        
        self.tableView.tableHeaderView = resultHeaderView
        bindingData(ticketModel: ticketModel)
        self.tableView.reloadData()
    }
    
    func updateUIFromHistory(ticketModel: HistoryDetailDisplay?)  {
        let status = ticketModel?.status ?? .success
        switch status {
        case .pending:
            break
        default:
            resultPendingHeaderView?.forEach { $0.isHidden = true }
        }
        let s = historyHeaderView.systemLayoutSizeFitting(CGSize(width: UIScreen.main.bounds.width, height: .infinity), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        historyHeaderView.frame = CGRect(origin: .zero, size: s)
        
        self.tableView.tableHeaderView = historyHeaderView
        bindingData(ticketModel: ticketModel)
    }
    
    func setupRX() {
        paymentBtn.rx.tap.bind { [weak self] (_) in
            self?.listener?.didSeletctPayment()
        }.disposed(by: disposeBag)
    }
    
    private func bindingData(ticketModel: HistoryDetailDisplay?) {
        nameLabel.text = ticketModel?.userName
        phoneLabel.text = ticketModel?.phone
        routNameLabel.text = ticketModel?.routName
        timeLabel.text = ticketModel?.time
        pickupLabel.text = ticketModel?.pickup
        pickupContentLabel.text = ticketModel?.pickupAddress
        numberSeatsLabel.text = ticketModel?.numberSeats
        seatsNameLabel.text = ticketModel?.seatsName
        
        ticketCodeLabel?.forEach { $0.text = ticketModel?.ticketsCode }
        
        let wrarningPendingTicket = String(format: Text.wrarningPendingTicket.localizedText, ticketModel?.timeExpiredPaymentStr ?? "12")
        pendingWarningMessageLabel?.forEach { $0.text = wrarningPendingTicket  }
        
        if let status = ticketModel?.status {
            statusLabel.text = status.title
            statusLabel.textColor = status.color
        }
        
        if let ticketCode = ticketModel?.ticketsCode {
            let image = ticketCode.generateQRCode()
            qrCodeImage?.forEach { $0.image = image }
        }
        
        lblChargeFeeText.text = "\(Text.paymentFees.localizedText) \(ticketModel?.paymentCardType?.generalName ?? "")"
        
        lblPriceTicket.text = ticketModel?.originPriceHistory?.currency
        lblChargeFee.text = ticketModel?.cardFee ?? ""
        

        self.totalPromotion = ticketModel?.seatDiscountsHistory?.reduce(0, { (x, y) -> Double in
            return x + y
        })
        lbPromotion.text = self.totalPromotion?.currency ?? ""
        totalPriceLabel.text = ticketModel?.totalPriceStr ?? ""
    }
}

