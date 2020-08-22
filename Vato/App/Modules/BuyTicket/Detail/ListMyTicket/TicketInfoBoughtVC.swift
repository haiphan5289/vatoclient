//
//  TicketInfoBoughtVC.swift
//  Vato
//
//  Created by HaiPhan on 10/11/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit

class TicketInfoBoughtVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }


}
