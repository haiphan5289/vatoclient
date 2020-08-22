//
//  ListMyTicketVC.swift
//  Vato
//
//  Created by HaiPhan on 10/8/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit

class ListMyTicketVC: UIViewController {
    @IBOutlet weak var tbListMyTicket: UITableView!
    var btBack: UIButton!
    var btRight: UIButton!
    var navigaitonBar: UINavigationBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
    }
    private func visualize(){
        setupNavigation()
    }
    private func setupNavigation(){
        UIApplication.setStatusBar(using: .lightContent)
        navigaitonBar = self.navigationController?.navigationBar
        navigaitonBar?.isTranslucent = false
        navigaitonBar?.tintColor = .white
        navigaitonBar?.barTintColor = UIColor(red: 255/255, green: 87/255, blue: 0/255, alpha: 1)
        navigaitonBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        btBack = UIButton(type: .custom)
        btBack.setImage(UIImage(named: "back-w")?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: btBack)
        btRight = UIButton(type: .custom)
        btRight.setImage(UIImage(named: "menu"), for: .normal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btRight)
        title = "Danh sách vé"
    }
}
