//  File name   : TicketHistoryTVC.swift
//
//  Author      : Dung Vu
//  Created date: 10/11/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import FwiCore

enum TicketHistoryTVCTitle: Int, CaseIterable {
    case timeStart
    case code
    case numberChair
    case timeEnd
    
    var title: String {
        switch self {
        case .timeStart:
            return Text.timeToDepart.localizedText
        case .code:
            return Text.ticketCodeTitle.localizedText
        case .numberChair:
            return Text.chairTicket.localizedText
        case .timeEnd:
            return Text.endTimeTicket.localizedText
        }
    }
}

protocol TicketDisplayProtocol {
    var timeStart: String? { get }
    var dateStart: String? { get }
    var status: TicketStatus? { get }
    var code: String? { get }
    var from: String? { get }
    var to: String? { get }
    var timeEnd: String? { get }
    var seat: String? { get }
    var statusInt: Int? { get }
}

final class TicketHistoryTVC: UITableViewCell {
    /// Class's public properties.
    @IBOutlet var lblTitles: [UILabel]?
    @IBOutlet var lblHour: UILabel?
    @IBOutlet var lblDay: UILabel?
    @IBOutlet var lblStatus: UILabel?
    @IBOutlet var lblCode: UILabel?
    @IBOutlet var lblFrom: UILabel?
    @IBOutlet var lblTo: UILabel?
    @IBOutlet var lblChair: UILabel?
    @IBOutlet var lblTime: UILabel?
    @IBOutlet var btnOption: UIButton?
    @IBOutlet var btnDetailRoute: UIButton?
    /// Class's private properties.
}

// MARK: Class's public methods
extension TicketHistoryTVC {
    override func awakeFromNib() {
        super.awakeFromNib()
        visualize()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        localize()
    }
    
    func setupDislay(for item: TicketDisplayProtocol, type: TicketHistory) {
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
        
        if item.statusInt == 11 {
            lblStatus?.text = FwiLocale.localized("Thất bại")
        }
    }
}

// MARK: Class's private methods
private extension TicketHistoryTVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        TicketHistoryTVCTitle.allCases.forEach { (type) in
            let label = lblTitles?[safe: type.rawValue]
            label?.text = type.title
        }
    }
}
