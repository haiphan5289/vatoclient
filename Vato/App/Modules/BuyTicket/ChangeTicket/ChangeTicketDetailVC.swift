//
//  ChangeTicketDetailVC.swift
//  Vato
//
//  Created by MacbookPro on 11/10/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit

protocol ChangeTicketFeeDisplay {
    var ticketCode: String { get }
    func feeMoney(newRoute routeId: Int) -> Int64
    func totalPrice(newRoute routeId: Int) -> Int64
    var route: String { get }
    var totalStr: String { get }
    func isSameRoute(newRoute routeId: Int) -> Bool
    var wayId: Int?   { get }
    func seatsStr() -> String
}

protocol ChangeTicketDetailListener: class {
    func didSelectType(type: TicketInputInfoStep)
}

class ChangeTicketDetailVC: UITableViewController {
    @IBOutlet weak var lbFindRoute: UILabel!
    @IBOutlet weak var lbPickUpLocationText: UILabel!
    @IBOutlet weak var lbPickUpLocation: UILabel!
    @IBOutlet weak var lbDestinationLocationText: UILabel!
    @IBOutlet weak var lbDestinationLocation: UILabel!
    @IBOutlet weak var lbDepartureTimeText: UILabel!
    @IBOutlet weak var lbDepartureTime: UILabel!
    @IBOutlet weak var lbRouteText: UILabel!
    @IBOutlet weak var lbRoute: UILabel!
    @IBOutlet weak var lbStartTimeText: UILabel!
    @IBOutlet weak var lbStartTime: UILabel!
    @IBOutlet weak var lbTranshipMentPointText: UILabel!
    @IBOutlet weak var lbTranshipMent: UILabel!
    @IBOutlet weak var lbSelectSeatsText: UILabel!
    @IBOutlet weak var lbSelectSeats: UILabel!

    // line view
    @IBOutlet var linePickup: [UIView]?
    @IBOutlet var lineDate: [UIView]?
    @IBOutlet var lineRoute: [UIView]?
    @IBOutlet var lineTime: [UIView]?
    @IBOutlet var lineBustop: [UIView]?
    
    @IBOutlet var imageStatusPickup: UIImageView?
    @IBOutlet var imageStatusDate: UIImageView?
    @IBOutlet var imageStatusRoute: UIImageView?
    @IBOutlet var imageStatusTime: UIImageView?
    @IBOutlet var imageStatusBustop: UIImageView?
    @IBOutlet var imageStatusSeat: UIImageView?
    
    
    weak var listener: ChangeTicketDetailListener?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localize()
    }
    
    private func localize(){
        lbFindRoute.text = Text.findTrip.localizedText
        lbPickUpLocationText.text = Text.locationPickup.localizedText
        lbDestinationLocationText.text = Text.destination.localizedText
        lbDepartureTimeText.text = Text.dateDeparture.localizedText
        lbRouteText.text = Text.nameTrip.localizedText
        lbStartTimeText.text = Text.timeToDepart.localizedText
        lbTranshipMentPointText.text = Text.transhipmentPoint.localizedText
        lbSelectSeatsText.text = Text.selectSeatsChangeTicket.localizedText
        
    }
    
    @IBAction func didTouchChangeOriginLocation(_ sender: Any) {
        self.listener?.didSelectType(type: .origin)
    }
    
    @IBAction func didTouchChangeDestinationLocation(_ sender: Any) {
        self.listener?.didSelectType(type: .destination)
    }
    
    func updateUI(ticketModel: TicketInformation) {
        let colorTitleEnable = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
        let colorTitleDisable = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 0.4)
        
        if let originLocation = ticketModel.originLocation?.code {
            lbPickUpLocation.text = originLocation
            lbPickUpLocation.textColor = colorTitleEnable
        } else {
            lbPickUpLocation.textColor = colorTitleDisable
            lbPickUpLocation.text = Text.selectLocationPickUp.localizedText
        }
        
        if let destinationLocation = ticketModel.destinationLocation?.code {
            lbDestinationLocation.text = destinationLocation
            lbDestinationLocation.textColor = colorTitleEnable
        } else {
            lbDestinationLocation.textColor = colorTitleDisable
            lbDestinationLocation.text = Text.selectDestinationLocation.localizedText
        }
        
        if let date = ticketModel.date {
            lbDepartureTime.text = date.string(from: "dd-MM-yyyy")
            lbDepartureTime.textColor = colorTitleEnable
        } else {
            lbDepartureTime.textColor = colorTitleDisable
            lbDepartureTime.text = Text.pickADay.localizedText
        }
        
        if let routeName = ticketModel.routName,
            routeName.isEmpty == false {
            lbRoute.text = routeName + "  " + "(\(ticketModel.priceStr ?? ""))"
            lbRoute.textColor = colorTitleEnable
        } else {
            lbRoute.textColor = colorTitleDisable
            lbRoute.text = Text.whichRouteYouGo.localizedText
        }
        
        if let scheduleTime = ticketModel.scheduleTime,
            scheduleTime.isEmpty == false {
            lbStartTime.text = scheduleTime
            lbStartTime.textColor = colorTitleEnable
        } else {
            lbStartTime.textColor = colorTitleDisable
            lbStartTime.text = Text.whatTimeYouGo.localizedText
        }
        
        if let routeStopName = ticketModel.routeStopName,
            routeStopName.isEmpty == false{
            lbTranshipMent.text = routeStopName
            lbTranshipMent.textColor = colorTitleEnable
        } else {
            lbTranshipMent.textColor = colorTitleDisable
            lbTranshipMent.text = Text.whereYourPickUp.localizedText
        }
        
        if let arrSeat = ticketModel.seats,
            arrSeat.count > 0 {
            let arrSeatName = arrSeat.compactMap { $0.chair ?? "" }
            lbSelectSeats.text = arrSeatName.joined(separator: ",")
            lbSelectSeats.textColor = colorTitleEnable
        } else {
            lbSelectSeats.textColor = colorTitleDisable
            lbSelectSeats.text = Text.whichChairYouChoose.localizedText
        }
    }
    
    func updateUI(currentStep: TicketInputInfoStep) {
        let arrLineView = [linePickup,
                           [UIView()],
                           lineDate,
                           lineRoute,
                           lineTime,
                           lineBustop]
        
        let arrImageStatus = [imageStatusPickup,
                              UIImageView(),
                              imageStatusDate,
                              imageStatusRoute,
                              imageStatusTime,
                              imageStatusBustop,
                              imageStatusSeat]
        
        let colorActive = #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.168627451, alpha: 0.2)
        let colorFilled = #colorLiteral(red: 0.2980392157, green: 0.7098039216, blue: 0.03137254902, alpha: 0.2)
        let colorNotFill = #colorLiteral(red: 0.6352941176, green: 0.6705882353, blue: 0.7019607843, alpha: 0.3)
        var currentColor = colorFilled
        
        let imageFilled = UIImage(named: "ic_note_done")
        let imageNotFill = UIImage(named: "ic_status_input_not_fill")
        let imageActive = UIImage(named: "ic_status_input_active")
        var currentImage = imageFilled
        //        ic_status_input_active.pdf. ic_note_doneic_timeline_do
        
        TicketInputInfoStep.allCases.enumerated().forEach({ (offset, value) in
            
            var index = offset
            if currentStep == .origin,
                value == .destination { index = 0 }
            
            if let view = arrLineView[safe: index] as? [UIView]{
                view.forEach({ $0.backgroundColor = currentColor })
            }
            
            if let imageView = arrImageStatus[safe: index] {
                imageView?.image = currentImage
            }
            
            if currentColor == colorActive {
                currentImage = imageNotFill
                currentColor = colorNotFill
            }
            
            if currentStep == value {
                currentColor = colorActive
                currentImage = imageActive
            }
        })
    }
}

extension ChangeTicketDetailVC {
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            return
        }
        if indexPath.row == 1 {
            self.listener?.didSelectType(type: .dateDepparture)
        }
        if indexPath.row == 2 {
            self.listener?.didSelectType(type: .route)
        }
        if indexPath.row == 3 {
            self.listener?.didSelectType(type: .time)
        }
        if indexPath.row == 4 {
            self.listener?.didSelectType(type: .locationPickup)
        }
        if indexPath.row == 5 {
            self.listener?.didSelectType(type: .seats)
        }
    }
}
