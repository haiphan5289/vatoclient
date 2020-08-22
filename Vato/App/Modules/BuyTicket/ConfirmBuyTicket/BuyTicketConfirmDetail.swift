//
//  BuyTicketConfirmDetail.swift
//  Vato
//
//  Created by vato. on 10/10/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit
import RxSwift

enum BuyTicketConfirmCellType: Int {
    case date = 0
    case route = 1
    case time = 2
    case busStop = 3
    case seats = 4
}

protocol BuyTicketConfirmDetailListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func routeSelectDate()
    func routeSelectRoute()
    func routeSelectTime()
    func routeSelectBusStop()
    func routeSelectSeats()
}


class BuyTicketConfirmDetail: UITableViewController {

    @IBOutlet weak var dateTextLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var routeTextLabel: UILabel!
    @IBOutlet weak var routeLabel: UILabel!
    @IBOutlet weak var timeTextLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var originTextLabel: UILabel!
    @IBOutlet weak var originLabel: UILabel!
    @IBOutlet weak var seatsTextLabel: UILabel!
    @IBOutlet weak var seatsLabel: UILabel!
    
    private lazy var disposeBag = DisposeBag()
    weak var listener: BuyTicketConfirmDetailListener?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        localize()
        setupRX()
    }
   
    private func localize(){
        dateTextLabel.text = Text.dateDeparture.localizedText
        routeTextLabel.text = Text.nameTrip.localizedText
        timeTextLabel.text = Text.departureTime.localizedText
        originTextLabel.text = Text.locationPickup.localizedText
        seatsTextLabel.text = Text.seats.localizedText
        
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }

    func updateUI(ticketModel: TicketInformation?) {
        dateLabel.text = ticketModel?.date?.string(from: "EEEE, MM/d, yyyy") ?? ""
        routeLabel.text = "\(ticketModel?.routeName ?? "") (\((ticketModel?.totalPrice ?? 0).currency))"
        
        timeLabel.text = "\(ticketModel?.scheduleTime ?? "") (\(ticketModel?.scheduleKind ?? ""))"
        originLabel.text = ticketModel?.routeStopName
        
        seatsLabel.text = ticketModel?.getSeatsStr()
    }
    
    private func setupRX() {
        self.tableView.rx.itemSelected.bind {[weak self](indexPath) in
            if let cellType = BuyTicketConfirmCellType(rawValue: indexPath.row) {
                switch cellType {
                case .date:
                    self?.listener?.routeSelectDate()
                case .route:
                    self?.listener?.routeSelectRoute()
                case .time:
                    self?.listener?.routeSelectTime()
                case .busStop:
                    self?.listener?.routeSelectBusStop()
                case .seats:
                    self?.listener?.routeSelectSeats()
                }
            }
            }.disposed(by: disposeBag)
    }
}
