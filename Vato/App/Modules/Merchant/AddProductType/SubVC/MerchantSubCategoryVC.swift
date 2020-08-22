//
//  MerchantSubCategoryVC.swift
//  Vato
//
//  Created by khoi tran on 11/7/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit

class MerchantSubCategoryVC: UIViewController {

    var tableView: UITableView = UITableView(frame: .zero, style: .plain)
    var source: Tree<MerchantCategory>?
    var currentSelectedSection: Int? = nil
    var currentSelectedLeafNode: IndexPath? = nil
    
    
    private lazy var noItemView: NoItemView = NoItemView(imageName: "merchant_empty",
                                                         message: nil,
                                                         on: self.tableView)
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
        tableView.sectionHeaderHeight = 0.1
        tableView.sectionFooterHeight = 0.1
//        tableView.separatorInset = UIEdgeInsets(top: 0, left: 43, bottom: 0, right: 0)
//        tableView.separatorColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1)
//        
        
        tableView >>> view >>> {
            
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        
        tableView.separatorStyle = .none
        
        tableView.register(MerchantSubCategoryCell.self, forCellReuseIdentifier: MerchantSubCategoryCell.identifier)
        
        tableView.delegate =  self
        tableView.dataSource = self
        
        tableView.reloadData()
    }

    
    func setSelectedData(listMerchantCategory: [MerchantCategory]?) {
        guard let listMerchantCategory = listMerchantCategory, !listMerchantCategory.isEmpty else {
            return
        }
        
        let selectedSectionCategory = listMerchantCategory.last
        if let sectionIndex = self.source?.listChild()?.firstIndex(where: { $0.key == selectedSectionCategory }) {
            self.tableView.selectRow(at: IndexPath(row: 0, section: sectionIndex), animated: true, scrollPosition: .bottom)
            self.tableView(self.tableView, didSelectRowAt: IndexPath(row: 0, section: sectionIndex))
            
            
            if listMerchantCategory.count >= 2 {
                let selectedRowCategory = listMerchantCategory.first
                if let rowIndex = source?.listChild()?[sectionIndex].listChild()?.firstIndex(where: { $0.key == selectedRowCategory }) {
                    
                    self.tableView.selectRow(at: IndexPath(row: rowIndex, section: sectionIndex), animated: true, scrollPosition: .bottom)
                    self.tableView(self.tableView, didSelectRowAt: IndexPath(row: rowIndex, section: sectionIndex))
                }
            }
        }
        
        
    }
}

extension MerchantSubCategoryVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        

        return indexPath
    }
    
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        if let currentSelected = self.currentSelectedSection, currentSelected == indexPath.section, indexPath.row == 0 {
            return nil
        }
        
        if let currentSelectedLeafNode = self.currentSelectedLeafNode, currentSelectedLeafNode == indexPath {
            return nil
        }
        
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let currentSelectedSection = self.currentSelectedSection {
            if indexPath.section != currentSelectedSection {
                let oldSeclected = currentSelectedSection
                self.currentSelectedSection = indexPath.section
                tableView.deselectRow(at: IndexPath(row: 0, section: oldSeclected), animated: true)
                
                let oldIndexes = self.reloadChildNodes(section: oldSeclected, startIndex: 0)
                let newIndexes = self.reloadChildNodes(section: indexPath.section, startIndex: 1)
                
                tableView.beginUpdates()
                UIView.performWithoutAnimation {
                    tableView.reloadRows(at: oldIndexes + newIndexes, with: .none)
                }
                tableView.endUpdates()
                
                self.currentSelectedLeafNode = nil
                
                
            } else {
                if let currentSelectedLeafNode = self.currentSelectedLeafNode {
                    tableView.deselectRow(at: currentSelectedLeafNode, animated: true)
                }
                self.currentSelectedLeafNode = indexPath
                
            }
        } else {
            self.tableView.allowsMultipleSelection = true
            self.currentSelectedSection = indexPath.section
            tableView.beginUpdates()
            tableView.reloadRows(at: self.reloadChildNodes(section: indexPath.section), with: .fade)
            tableView.endUpdates()
        }
        
        
        if let result = self.getMerchantFromIndex(indexPath: indexPath), let type = result.type, let category = result.category {
            if let parent = self.parent as? AddProductTypeVC {
                parent.subProductSelectItem(category: category, type: type)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        printDebug(indexPath)
    }
   
    
    func reloadChildNodes(section: Int, startIndex: Int = 1) -> [IndexPath] {
        let listChild = source?.listChild()?[section].listChild()
        var count = listChild?.count ?? 0
        count = count + 1
        let range = (startIndex..<count).map({ IndexPath(row: $0, section: section) })
        
        return range
        
    }
    
    func getMerchantFromIndex(indexPath: IndexPath) -> (type: MerchantSubCategoryCellType?, category: MerchantCategory?)? {
        
        guard let node = source?.listChild()?[indexPath.section] else {
            return nil
        }
        
        guard let childList = node.listChild(), childList.count > 0 else {
            return .init((type: .leafNode, category: node.key))
        }
        
        if indexPath.row == 0 {
            return .init((type: .node, category: node.key))
        }
        
        return .init((type: .leafNode, category: childList[indexPath.row-1].key))
    }
    
}

extension MerchantSubCategoryVC: UITableViewDataSource {
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
        guard let source = source else {
            return 0
        }
        
        guard let child = source.child else {
            return 0
        }
        
        return child.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let currentSelectedSection = self.currentSelectedSection else {
            if indexPath.row == 0 {
                return UITableView.automaticDimension
            } else {
                return 0.0
            }
        }
        
        if indexPath.section != currentSelectedSection && indexPath.row != 0 {
            return 0
        }
        
        return UITableView.automaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        guard let source = source else {
            return 1
        }
        
        let listChild = source.listChild()?[section].listChild()
        
        let count = listChild?.count ?? 0
        return count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MerchantSubCategoryCell.identifier, for: indexPath) as? MerchantSubCategoryCell else  {
            fatalError("")
        }
        
        var type: MerchantSubCategoryCellType = .leafNode        
        let tree = source?.listChild()?[indexPath.section]
        var isParentCategorySelected = false
        if indexPath.row == 0 {
            if let category = tree?.key {
                if let treeCount = tree?.child?.count, treeCount > 0 {
                    type = .node                }
                
                cell.setupData(category: category, isParentCategorySelected: false, level: 1, type: type)
            }
        } else {
            if let category = tree?.listChild()?[indexPath.row-1].key {
                cell.setupData(category: category, isParentCategorySelected: false, level: 2, type: .leafNode)
            }
        }
        
        return cell
    }
    
}

extension MerchantSubCategoryVC {
    func reloadData(source: Tree<MerchantCategory>?) {
        self.source = source
        if let source = self.source {
            if source.listChild()?.isEmpty ?? true {
                noItemView.attach()
            } else {
                noItemView.detach()
            }
        }
        self.currentSelectedSection = nil
        self.tableView.reloadData()
    }
}
