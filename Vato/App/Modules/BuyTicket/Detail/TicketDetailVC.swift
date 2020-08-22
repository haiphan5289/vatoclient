//  File name   : TicketDetailVC.swift
//
//  Author      : Dung Vu
//  Created date: 10/1/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit

protocol TicketDetailPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
}

final class TicketDetailVC: UIViewController, TicketDetailPresentable, TicketDetailViewControllable {
    private struct Config {
    }
    
    @IBOutlet weak var tableView: UITableView!
    /// Class's public properties.
    weak var listener: TicketDetailPresentableListener?

    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }

    /// Class's private properties.
}

// MARK: View's event handlers
extension TicketDetailVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension TicketDetailVC {
}

// MARK: Class's private methods
private extension TicketDetailVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        self.tableView.delegate = self
        setupNavigation()
        title = Text.informationTicket.localizedText
    }
    private func setupNavigation(){
        UIApplication.setStatusBar(using: .lightContent)
        let navigaitonBar = self.navigationController?.navigationBar
        navigaitonBar?.isTranslucent = false
        navigaitonBar?.tintColor = .white
        navigaitonBar?.barTintColor = UIColor(red: 255/255, green: 87/255, blue: 0/255, alpha: 1)
        navigaitonBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let btBack: UIButton = UIButton(type: .custom)
        btBack.setImage(UIImage(named: "back-w")?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: btBack)
        let lbRight: UILabel = UILabel()
        lbRight.textColor = UIColor.white
        lbRight.font = UIFont.systemFont(ofSize: 16)
        lbRight.text = "10:00"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: lbRight)
        
    }
}
extension TicketDetailVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        }
        return 8
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let arSection = ["Thông tin hành khách",
                         "Thông tin lượt đi",
                         "Thông tin lượt về"]
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 56))
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
        let footerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 56))
        footerView.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        return footerView
    }    
}

