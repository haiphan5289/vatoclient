//
//  MerchantMainCategoryVC.swift
//  Vato
//
//  Created by khoi tran on 11/7/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit
import FwiCore
import FwiCoreRX
import RxSwift
import SnapKit
import RxCocoa

class MerchantMainCategoryVC: UIViewController {

    var tableView: UITableView  = UITableView(frame: .zero, style: .plain)
    var source:[MerchantCategory] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        visualize()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    private func visualize() {
        self.view.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1.0)
        tableView.sectionHeaderHeight = 0.1
        tableView.sectionFooterHeight = 0.1
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 43, bottom: 0, right: 0)
        tableView.separatorColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1)
        
        
        tableView >>> view >>> {
            
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        
        tableView.register(MerchantMainCategoryCell.self, forCellReuseIdentifier: MerchantMainCategoryCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setSelectedCategory(selectedCagtegory: MerchantCategory?) {
        guard let selectedCagtegory = selectedCagtegory else {
            return
        }
        
        
        guard let index = self.source.firstIndex(where: { $0.id == selectedCagtegory.id }) else {
            return
        }
        
        self.tableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .bottom)
        
        
        self.tableView(self.tableView, didSelectRowAt: IndexPath(row: index, section: 0))
    }
    
    
}


extension MerchantMainCategoryVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let parent = self.parent as? AddProductTypeVC {
            parent.mainProductSelectItem(indexPath: indexPath, catetory: source[indexPath.row])
        }
    }
    
    
}

extension MerchantMainCategoryVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return source.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MerchantMainCategoryCell.identifier, for: indexPath) as? MerchantMainCategoryCell else  {
            fatalError("")
        }
        
        cell.setupData(category: source[indexPath.row])
        
        
    
        return cell
    }
    
    
    
}
