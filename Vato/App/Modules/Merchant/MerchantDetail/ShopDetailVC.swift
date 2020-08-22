//
//  ShopDetailVC.swift
//  Vato
//
//  Created by HaiPhan on 10/22/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit

class ShopDetailVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
}
