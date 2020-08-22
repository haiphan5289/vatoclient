//
//  ExpHistoryDetailVCViewController.swift
//  Vato
//
//  Created by vato. on 12/25/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit

class ExpHistoryDetailVC: UITableViewController {
    private var footer = ExpressDetailFooter.loadXib()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView?.register(ExpressLocationCell.nib, forCellReuseIdentifier: "ExpressLocationCell")
        tableView?.dataSource = self
        tableView?.delegate = self
        
        self.view.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        
        self.tableView?.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        
        // Do any additional setup after loading the view.
    }
}
