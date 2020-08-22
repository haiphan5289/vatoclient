//
//  ExpHistoryStateVCViewController.swift
//  Vato
//
//  Created by vato. on 12/25/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit

class ExpHistoryStateVC: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView?.delegate = self
        tableView?.rowHeight = UITableView.automaticDimension
        // Do any additional setup after loading the view.
    }
    
}

extension ExpHistoryStateVC {
    
    override func tableView(_: UITableView, viewForFooterInSection _: Int) -> UIView? { return nil }
    override func tableView(_: UITableView, heightForFooterInSection s: Int) -> CGFloat { return 0.1 }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? { return nil }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return 0.1 }
    
}
