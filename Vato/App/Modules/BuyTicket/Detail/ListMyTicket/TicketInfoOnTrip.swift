//
//  TicketInfoOnTrip.swift
//  Vato
//
//  Created by HaiPhan on 10/11/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import RxSwift

class TicketInfoOnTrip: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
}
