//
//  DeliveryTypeHeaderView.swift
//  Vato
//
//  Created by khoi tran on 11/18/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit
import RxSwift
import FwiCore
import SnapKit

class DeliveryTypeHeaderView: UIView, UpdateDisplayProtocol {
    struct Configs {
        static let fontDeliveryVehicleCell = UIFont.systemFont(ofSize: 12.0, weight: .regular)
        static let heightDeliveryVehicleCell: CGFloat = 92.0
    }
    
    @IBOutlet weak var urbanDeliveryButton: UIButton!
    @IBOutlet weak var domesticDeliveryButton: UIButton!
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var source: [DeliveryVehicle] = []
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var deliveryType: Observable<DeliveryServiceType> {
        return mDeliveryType.asObservable()
    }
    
    private lazy var mDeliveryType = PublishSubject<DeliveryServiceType>()
    private lazy var disposeBag = DisposeBag()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
        setupRX()
    }
   
}

extension DeliveryTypeHeaderView {
    func visualize() {
        
    }
    
    func initialize() {
        self.urbanDeliveryButton.isSelected = true
        self.urbanDeliveryButton.setTitle(DeliveryTypeModel.urban.text(), for: .normal)
        self.domesticDeliveryButton.setTitle(DeliveryTypeModel.cities.text(), for: .normal)
        
        self.collectionView.register(DeliveryVehicleCollectionViewCell.self, forCellWithReuseIdentifier: DeliveryVehicleCollectionViewCell.identifier)
                
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.isUserInteractionEnabled = false
        
        #if DEBUG
        let urban = self.urbanDeliveryButton.rx.tap.map { DeliveryServiceType.URBAN_DELIVERY }
        let domestic = self.domesticDeliveryButton.rx.tap.map { DeliveryServiceType.DOMESTIC_DELIVERY }
        
        Observable.merge([urban, domestic]).subscribe(mDeliveryType).disposed(by: disposeBag)
        #endif
    }
        
    func setupRX() {
        deliveryType.bind {[weak self] (type) in
            guard let me = self else { return }
            var scale: CGFloat = 0
            switch type {
            case .URBAN_DELIVERY:
                me.urbanDeliveryButton.isSelected = true
                me.domesticDeliveryButton.isSelected = false
                scale = 0
            case .DOMESTIC_DELIVERY:
                me.urbanDeliveryButton.isSelected = false
                me.domesticDeliveryButton.isSelected = true
                scale = 1
            }
            
            let deltaY = UIScreen.main.bounds.width / 2
            UIView.animate(withDuration: 0.3) {
                me.indicatorView?.transform = CGAffineTransform(translationX: deltaY * scale , y: 0)
            }
        }.disposed(by: disposeBag)
    }
}


extension DeliveryTypeHeaderView {
    func setupDisplay(item: DeliveryTypeModel?) {
        guard let item = item else {
            return
        }
        
        var x: CGFloat = 0
        switch item {
        case .urban:
            x = 0
            urbanDeliveryButton.setTitleColor(UIColor(red: 239/255, green: 82/255, blue: 34/255, alpha: 1.0), for: .normal)
            urbanDeliveryButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)

            domesticDeliveryButton.setTitleColor(UIColor(red: 99/255, green: 114/255, blue: 128/255, alpha: 1.0), for: .normal)
            domesticDeliveryButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)

        case .cities:
            x = UIScreen.main.bounds.width/2
            domesticDeliveryButton.setTitleColor(UIColor(red: 239/255, green: 82/255, blue: 34/255, alpha: 1.0), for: .normal)
            domesticDeliveryButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)

            urbanDeliveryButton.setTitleColor(UIColor(red: 99/255, green: 114/255, blue: 128/255, alpha: 1.0), for: .normal)
            urbanDeliveryButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)

        }
        
        UIView.animate(withDuration: 0.3) {
            self.indicatorView.transform = CGAffineTransform(translationX: x , y: 0)
        }
        
    }
}


extension DeliveryTypeHeaderView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
//        var _element: DeliveryVehicle?
//        if indexPath.row < self.source.count {
//            _element = self.source[indexPath.row]
//        }
//        guard let element = _element else { return CGSize.zero }
//
//        let attributes: [NSAttributedString.Key: Any] = [
//            NSAttributedString.Key.font: Configs.fontDeliveryVehicleCell
//        ]
//
//        let string = NSAttributedString(string: element.name ?? "", attributes: attributes)
//
//        // Calculate dynamic width
//        var expectedSize = string.size()
//        expectedSize.width = ceil(expectedSize.width + 32)
//
        let w = UIScreen.main.bounds.width / 4
        return CGSize(width: w, height: Configs.heightDeliveryVehicleCell)
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return indexPath.row == 0
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return false
    }

}


extension DeliveryTypeHeaderView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return source.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DeliveryVehicleCollectionViewCell.identifier, for: indexPath) as? DeliveryVehicleCollectionViewCell else {
            fatalError("error")
        }
        let element = source[indexPath.row]
        
        cell.nameLabel.text = element.name
        cell.iconImageView.image = UIImage.init(named: element.imageURL ?? "")
        
        
        return cell
        
    }
    
    
}
