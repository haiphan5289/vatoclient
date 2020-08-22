//
//  ChooseSeatViewController.swift
//  Vato
//
//  Created by THAI LE QUANG on 10/8/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit

let cell_margin: CGFloat = 24

protocol ChooseSeatViewControllerListener: class {
    func didSelect(seats: [SeatModel])
}

class ChooseSeatViewController: UIViewController {

    struct Config {
        static let isBigScreenSize = Device.init().diagonal > 4.7
        static let cellWidth: CGFloat = Config.isBigScreenSize ? 42 : 38
        static let sectionSpace: CGFloat = Config.isBigScreenSize ? 10 : 4
    }
    
    @IBOutlet weak var contentCollectionView: UICollectionView!
    /// Class's public properties.
    weak var listener: ChooseSeatViewControllerListener?
    
    var dataSource: [[SeatModel?]] = [] {
        didSet {
            DispatchQueue.main.async {
                let height = self.contentCollectionView.bounds.size.height
                let cellHeight = (height - CGFloat((self.dataSource.count-1))*Config.sectionSpace)/CGFloat(self.dataSource.count)
                self.cellHeight = min(cellHeight, Config.cellWidth)
                self.contentCollectionView.reloadData()
            }
        }
    }
    
    var arraySelected: [SeatModel] = []
    var maxColumn:CGFloat = 5
    var cellHeight = Config.cellWidth
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let safe = UIApplication.shared.keyWindow?.edgeSafe ?? .zero
//        let contentInset = contentCollectionView.contentInset
//        contentCollectionView.contentInset = UIEdgeInsets(top: contentInset.top - safe.top, left: contentInset.left, bottom: contentInset.bottom, right: contentInset.right)
    }
}

extension ChooseSeatViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChooseSeatCVC", for: indexPath) as? ChooseSeatCVC else {
            fatalError("Please implement!!!")
        }
        
        let item = dataSource[indexPath.section][indexPath.item]
        var isSelected = false
        if let itemVal = item,
            arraySelected.contains(where: { $0.id == itemVal.id }) {
            isSelected = true
        }
        
        cell.visulizeCell(with: item, isSelected: isSelected)
        
        return cell
    }
}

extension ChooseSeatViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        return CGSize(width: Config.cellWidth, height: self.cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
                
        let width = Config.cellWidth * maxColumn + cell_margin * 2
        let totalMargin = UIScreen.main.bounds.width - CGFloat(width)
        let margin = (totalMargin / CGFloat(maxColumn - 1))

        return margin
    }
}

extension ChooseSeatViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource[indexPath.section][indexPath.item] else { return false }
        
        let bookStatus = item.bookStatus ?? 0
        let lockChair = item.lockChair ?? 0
        let inSelect = item.inSelect ?? 0
        
        return bookStatus == 0 && lockChair == 0 && inSelect == 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let item = dataSource[indexPath.section][indexPath.item] {
            if arraySelected.contains(where: { $0.id == item.id }) {
                arraySelected.removeAll(where: { $0.id == item.id })
            } else {
                arraySelected.append(item)
            }
            
            contentCollectionView.reloadItems(at: [indexPath])
            listener?.didSelect(seats: arraySelected)
        }
    }
}
