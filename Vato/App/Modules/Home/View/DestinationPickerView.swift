//
//  DestinationPickerView.swift
//  Vato
//
//  Created by khoi tran on 11/14/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit
import RxSwift
import FwiCore
import FwiCoreRX
import SnapKit

final class DestinationPickerView: UIView {

    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var locationTypeImageView: UIImageView!
    @IBOutlet weak var suggestionCollectionView: UICollectionView!
    
    @IBOutlet weak var locationTableView: UITableView!
    @IBOutlet weak var mapButton: UIButton!
    
    private var eUpdatedHeight: PublishSubject<CGFloat> = PublishSubject()
    
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    
    var isEmpty: Bool = false
    var updatedHeight: Observable<CGFloat> {
        return eUpdatedHeight.asObservable()
    }
    
    var noItemView: NoItemView?
    
//    var heightStream: Observa
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
extension DestinationPickerView {
    override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        visualize()
    }
    
    func updateHeight(state: MapState) {
        var height: CGFloat = 0
        let bottom = UIApplication.shared.keyWindow?.edgeSafe.bottom ?? 0
        
        let minHeight = 64 + 64 + 64 + bottom + 48
        
        let viewHeight: CGFloat = 64 + 64 * 2 + 64 + bottom + 48 // UIScreen.main.bounds.height < 667 ? 318 : 442
        
        switch state {
        case .moving:
            if isEmpty {
                height = minHeight
            } else {
                height = viewHeight
            }
        case .idle:
            height = viewHeight
        }
        
        eUpdatedHeight.onNext(height)
        
        UIView.animate(withDuration: 0.1) {
            self.snp.updateConstraints { (make) in
                make.height.equalTo(height)
            }
            self.layoutIfNeeded()
        }
    }
    
    func updateEmptyView(isEmpty: Bool) {
        self.isEmpty = isEmpty
        if isEmpty {
            noItemView?.attach()
        } else {
            noItemView?.detach()
        }
    }
}

// MARK: Class's private methods
private extension DestinationPickerView {
    private func initialize() {
        textField.placeholder = Text.whereDoYouGo.localizedText
        let emptyViewSize: (NoItemView) -> () = { v in
            v.iconView?.contentMode = .scaleAspectFit
            v.iconView?.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview().offset(10)
                make.size.equalTo(CGSize.init(width: 80, height: 106))
            }
            v.layoutSubviews()
        }

        noItemView = NoItemView(imageName: "location_empty",
                                message: nil,
                                on: locationTableView, customLayout:  emptyViewSize)
        let bottom = UIApplication.shared.keyWindow?.edgeSafe.bottom ?? 0
        
        bottomViewHeight.constant = bottom + 64
        self.layoutSubviews()
    }
    
    private func visualize() {
        // todo: Visualize view's here.
    }
}
