//
//  CancellationTicket.swift
//  Vato
//
//  Created by HaiPhan on 10/8/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit

enum cancellation {
    case success, failure
}

class CancellationTicket: UIViewController {

    @IBOutlet weak var viewCancelFeeDetail: UIView!
    @IBOutlet weak var viewBackGround: UIView!
    @IBOutlet weak var lbPrice: UILabel!
    @IBOutlet weak var hViewConfirm: NSLayoutConstraint!
    @IBOutlet weak var viewConfirmCancel: UIView!
    @IBOutlet weak var hViewTextTicketFailure: NSLayoutConstraint!
    @IBOutlet weak var lbCancelTicketFailure: UILabel!
    @IBOutlet weak var tbCancelTicket: UITableView!
    var navigaitonBar: UINavigationBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        lbCancelTicketFailure.text = nil
        self.viewBackGround.isHidden = true
        self.viewCancelFeeDetail.isHidden = true
        let checkShow = cancellation.success
        switch checkShow {
        case .success:
            lbCancelTicketFailure.text = nil
            hViewTextTicketFailure.constant = 0
            viewConfirmCancel.isHidden = false
            hViewConfirm.constant = 167
        default:
            lbCancelTicketFailure.text = "Quý khách không thể huỷ vé này vì đã hết thời gian huỷ vé."
            hViewTextTicketFailure.constant = 60
            viewConfirmCancel.isHidden = true
            hViewConfirm.constant = 0
        }
        visualize()

    }
    //Animation when view Detail appears
    @IBAction func DisplayDetailCancellationFee(_ sender: UITapGestureRecognizer) {
        self.viewCancelFeeDetail.frame.origin.y = self.view.frame.height + 10
        UIView.animate(withDuration: 0.5) {
            self.navigaitonBar?.alpha = 0.4
            self.viewBackGround.isHidden = false
            self.viewCancelFeeDetail.isHidden = false
            self.viewCancelFeeDetail.frame.origin.y = self.view.frame.height - 344
        }
    }
    //Animation when view Detail hide
    @IBAction func HideDetailCancellationFee(_ sender: UITapGestureRecognizer) {
        self.viewCancelFeeDetail.frame.origin.y = self.view.frame.height - 344
        UIView.animate(withDuration: 0.5) {
            self.navigaitonBar?.alpha = 1
            self.viewBackGround.isHidden = true
            self.viewCancelFeeDetail.isHidden = true
        }
    }
    private func visualize(){
        setupNavigation()
        self.tbCancelTicket.delegate = self
        self.tbCancelTicket.dataSource = self
        self.tbCancelTicket.register(CancellationTicketCell.nib, forCellReuseIdentifier: "cell")
        
    }
    private func setupNavigation(){
        UIApplication.setStatusBar(using: .lightContent)
        navigaitonBar = self.navigationController?.navigationBar
        navigaitonBar?.isTranslucent = false
        navigaitonBar?.tintColor = .white
        navigaitonBar?.barTintColor = UIColor(red: 255/255, green: 87/255, blue: 0/255, alpha: 1)
        navigaitonBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        //Setup button Back
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back-w"),
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(MovetoPreviousScreen))
        title = "Huỷ vé"
    }
    @objc func MovetoPreviousScreen(){
        self.navigationController?.popViewController(animated: true)
    }

}
extension CancellationTicket: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return 1
        }
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let arInfor = [["Tuyến xe", "Thời gian", "Giá ve"],
                       ["Thời gian huỷ", "Trước 24:00", "Sau 24:20"],
                       ["Thời gian huỷ", "Trước 24:00", "Sau 24:20"]]
        let b = [["Lê Hồng Phong - Đà Lạt", "23:00 10/07/2019", "500,000đ"],
                 ["Phí huỷ", "10%", "Không thể huỷ"],
                 ["Phí huỷ", "10%", "Không thể huỷ"]]
        let cell = self.tbCancelTicket.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CancellationTicketCell
        cell.lbRoute.text = arInfor[indexPath.section][indexPath.row]
        cell.lbNameRoute.text = b[indexPath.section][indexPath.row]
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                cell.lbDateFee.text = nil
                cell.lbNameRoute.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
            } else if indexPath.row == 2 {
                cell.lbNameRoute.textColor = #colorLiteral(red: 0.9529411765, green: 0.1882352941, blue: 0.2078431373, alpha: 1)
                cell.lbDateFee.text = "10/07/2019"
                cell.lbRoute.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
            }else {
                cell.lbDateFee.text = "10/07/2019"
                cell.lbRoute.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
            }
        } else if indexPath.section == 2 {
            cell.lbNameRoute.text = nil
            cell.wLbRout?.isActive = false
            cell.hLbRoute?.isActive = false
            cell.lbRoute.textColor = #colorLiteral(red: 0.3176470588, green: 0.3019607843, blue: 0.2941176471, alpha: 1)
            cell.lbRoute.text = "Phí huỷ sẽ được tính trên giá gốc, không giảm trừ khuyến mãi hoặc giảm giá. \n \nSố tiền sẽ được cộng vào tài khoản VATOPay của quý khách."
        }
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let arSection = ["","Chính sách", "Lưu ý"]
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 51))
        let label = UILabel()
        label.frame = CGRect.init(x: 17, y: 0, width: headerView.frame.width, height: headerView.frame.height)
        label.text = arSection[section]
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
        headerView.addSubview(label)
        headerView.backgroundColor = .white
        return headerView
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 56))
        headerView.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 35
    }
    
    
}
