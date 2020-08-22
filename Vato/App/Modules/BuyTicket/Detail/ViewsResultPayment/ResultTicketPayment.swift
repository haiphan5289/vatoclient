//
//  ResultTicketPayment.swift
//  Vato
//
//  Created by HaiPhan on 10/7/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit

enum paymentTicket {
    case cash, vato, paymentFailure, paymentedit
}

class ResultTicketPayment: UIViewController {

    @IBOutlet weak var viewPaymentEdit: UIView!
    @IBOutlet weak var viewPaymentFailure: UIView!
    @IBOutlet weak var tbPaymentSuccess: UITableView!
    let s = paymentTicket.paymentedit
    override func viewDidLoad() {
        super.viewDidLoad()
        viewPaymentFailure.isHidden = true
        tbPaymentSuccess.isHidden = true
        viewPaymentEdit.isHidden = true
        switch s {
        case .paymentFailure:
            viewPaymentFailure.isHidden = false
        case .paymentedit:
            viewPaymentEdit.isHidden = false
        default:
            tbPaymentSuccess.isHidden = false
        }
        setupViews()
        
    }
    private func setupViews(){
        setupNavigation()
        tbPaymentSuccess.delegate = self
        tbPaymentSuccess.dataSource = self
        tbPaymentSuccess.register(ResultTicketPaymentCell.nib, forCellReuseIdentifier: "cell")
        tbPaymentSuccess.register(ResultTicketPaymentCellInfor.nib, forCellReuseIdentifier: "cellInfor")
        tbPaymentSuccess.register(ResultPaymentCashCell.nib, forCellReuseIdentifier: "cellCash")
    }
    private func setupNavigation(){
        UIApplication.setStatusBar(using: .lightContent)
        let navigaitonBar = self.navigationController?.navigationBar
        navigaitonBar?.isTranslucent = false
        navigaitonBar?.tintColor = .white
        navigaitonBar?.barTintColor = UIColor(red: 255/255, green: 87/255, blue: 0/255, alpha: 1)
        navigaitonBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                                target: self,
                                                                action: nil)
    }

}
extension ResultTicketPayment: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return 8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //create 2 cells
        //Show data with Data Mockup
        let arData = ["Nguyễn Phan Tùng Dương", "0912345678", "Đà Lạt - Lê Hồng Phong", "23:00 12/07/2019",
                      "Đà Lạt", "2", "AAAAAAAAAAAA1 AAAAAAAAAAAA1 AAAAAAAAAAAA1 AAAAAAAAAAAA1 A1 A1 A1 A1 A1 A1 A1 A1 A1 A1 A1 A1 A1 A1", "500,000đ"]
        if indexPath.section == 0 {
            if s == paymentTicket.cash {
                let cell = self.tbPaymentSuccess.dequeueReusableCell(withIdentifier: "cellCash", for: indexPath) as! ResultPaymentCashCell
                return cell
            } else {
                let cell = self.tbPaymentSuccess.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ResultTicketPaymentCell
                return cell
            }
        } else {
            let cell = self.tbPaymentSuccess.dequeueReusableCell(withIdentifier: "cellInfor", for: indexPath) as! ResultTicketPaymentCellInfor
            cell.lbData.text = arData[indexPath.row]
            if indexPath.row == 4 {
                cell.lbLocationPickUp.text = "131 Tô Hiến Thành, P.3, TP.Đà Lạta sd ád á da sd ád ád a sd ád ád a sd ád á á d"
            } else {
                cell.lbLocationPickUp.text = nil
            }
            if indexPath.row == 6 {
                cell.hLbDataInfor?.isActive = false
            } else {
                cell.hLbDataInfor?.isActive = true
            }
            return cell
        }
       
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
}
