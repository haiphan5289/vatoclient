//
//  TicketSwitchCell.swift
//  Vato
//
//  Created by khoi tran on 4/28/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation
import Eureka
import RxSwift
import UIKit

final class TicketSwitchCell: Eureka.Cell<Bool>, CellType, UpdateDisplayProtocol {
    var lblTitle: UILabel = UILabel(frame: .zero)
    var valueSwitch: UISwitch = UISwitch(frame: .zero)
    private lazy var disposeBag = DisposeBag()
    @VariableReplay var switchValue: Bool = false
    
    
    var changed: Observable<Bool> {
        return $switchValue.distinctUntilChanged().observeOn(MainScheduler.asyncInstance)
    }
    
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        visualize()
        setupRX()
    }
    
    override func setup() {
        super.setup()
        height = { 56 }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func visualize() {
        selectionStyle = .none
        textLabel?.isHidden = true
        imageView?.isHidden = true
        
        self.backgroundColor = .white
        
        valueSwitch >>> contentView >>> {
            $0.isOn = true
            $0.onTintColor = UIColor(red: 239/255, green: 82/255, blue: 34/255, alpha: 0.8)
            $0.snp.makeConstraints({ (make) in
                make.centerY.equalToSuperview()
                make.right.equalTo(-16)
            })
        }
        
        lblTitle >>> contentView >>> {
            $0.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            $0.numberOfLines = 2
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(20)
                make.left.equalTo(16)
                make.right.equalTo(valueSwitch.snp.left).offset(-16)
            })
        }
    }
    
    func setupRX() {
        valueSwitch.rx.controlEvent(.valueChanged).bind { [weak self] in
            guard let wSelf = self else { return }
            let current = wSelf.switchValue
            wSelf.switchValue = !current
        }.disposed(by: disposeBag)
    }
    
    func setupDisplay(item: Bool?) {
        guard let item = item else {
            return
        }
        
        valueSwitch.setOn(item, animated: false)
    }
    
    func update(title: String) {
        lblTitle.text = title
    }
    
    func getValue() -> Bool {
        return valueSwitch.isOn
    }
}
