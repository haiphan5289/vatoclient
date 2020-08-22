//
//  OrderContractCell.swift
//  Vato
//
//  Created by Phan Hai on 20/08/2020.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit
import RxSwift

class OrderContractCell: UITableViewCell {

    var btChat: (() -> Void)?
    var viewInfor: OCInformation = OCInformation.loadXib()
    private let disposeBag = DisposeBag()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.addSubview(viewInfor)
        viewInfor.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview().inset(10)
            
        }
        self.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        setupRX()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupRX() {
        self.viewInfor.btChat.rx.tap.bind { [weak self] in
            guard let wSelf = self else { return }
            wSelf.btChat?()
        }.disposed(by: disposeBag)
    }
    
}
