//
//  CreateMerchantTypeDetailVC.swift
//  Vato
//
//  Created by HaiPhan on 10/22/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit

class CreateMerchantTypeDetailVC: UIViewController {

    var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView = UITableView.init(frame: .zero, style: .grouped)
        tableView.sectionHeaderHeight = 0.1
        tableView.sectionFooterHeight = 0.1
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 72, bottom: 0, right: 0)
        tableView >>> view >>> {
            $0.snp.makeConstraints({ (make) in
                make.left.top.right.bottom.equalToSuperview()
            })
        }
        tableView.register(UINib(nibName: "CreateMerchantTypeCell", bundle: nil),
                           forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        // Do any additional setup after loading the view.
    }

}
extension CreateMerchantTypeDetailVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
