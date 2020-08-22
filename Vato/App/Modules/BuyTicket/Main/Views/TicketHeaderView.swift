//
//  TicketHeaderView.swift
//  Vato
//
//  Created by THAI LE QUANG on 10/15/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit
import RxSwift

protocol TicketHeaderViewListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func didSelectItemDepart(item: TicketDisplayProtocol?)
}

final class TicketHeaderView: UIView, VatoSegmentChildProtocol {

    /// Class's public properties.
    @IBOutlet var viewContainer: UIView?
    @IBOutlet var lblTitles: [UILabel]?
    @IBOutlet var lblHour: UILabel?
    @IBOutlet var lblDay: UILabel?
    @IBOutlet var lblStatus: UILabel?
    @IBOutlet var lblCode: UILabel?
    @IBOutlet var lblFrom: UILabel?
    @IBOutlet var lblTo: UILabel?
    @IBOutlet var lblChair: UILabel?
    @IBOutlet var lblTime: UILabel?
    @IBOutlet var btnShowDetail: UIButton?
    
    var item: TicketDisplayProtocol?
    var isSelected: Bool = false
}

// MARK: Class's public methods
extension TicketHeaderView {
    override func awakeFromNib() {
        super.awakeFromNib()
        visualize()
        
        localize()
        setupRX()
    }
    
    func setupDislay(for item: TicketDisplayProtocol, type: TicketHistory) {
        self.item = item
        lblHour?.textColor = type.color
        lblHour?.text = item.timeStart
        lblTime?.textColor = TicketHistory.future.color
        lblTime?.text = item.timeEnd
        lblStatus?.textColor = item.status?.color
        lblStatus?.text = item.status?.title
        lblFrom?.text = item.from
        lblTo?.text = item.to
        lblChair?.text = item.seat
        lblDay?.text = item.dateStart
        lblCode?.text = item.code
    }
    
    func updateNumberTickets(num: Int) {
        
//        lblTicket?.text = num > 0 ? (Text.ticketAboutToDepart.localizedText + " (\(num))") : Text.ticketAboutToDepart.localizedText
    }
}

// MARK: Class's private methods
private extension TicketHeaderView {
    private func localize() {
        // todo: Localize view's here.
//        lblTicket?.text = Text.ticketAboutToDepart.localizedText
//        btnSeeMore?.setTitle(Text.seeMore.localizedText, for: .normal)
    }
    private func visualize() {
        // todo: Visualize view's here.
        TicketHistoryTVCTitle.allCases.forEach { (type) in
            let label = lblTitles?[safe: type.rawValue]
            label?.text = type.title
        }
    }
    private func setupRX() {
       
    }
}
