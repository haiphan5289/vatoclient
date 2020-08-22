
//
//  MenuNoteView.swift
//  Vato
//
//  Created by khoi tran on 12/9/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation
import RxSwift
import FwiCore
import SnapKit
import Eureka

class MenuNoteCell: Eureka.Cell<ProductMenuItem>, CellType, UpdateDisplayProtocol {
    
    var editView: StoreEditMenuView?
    private var titleLabel: UILabel = UILabel(frame: .zero)
    var noteTextView: UITextView = UITextView(frame: .zero)
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        visualize()
    }
    
    func visualize() {
        selectionStyle = .none
        textLabel?.isHidden = true
        
        contentView.addSeperator(with: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), position: .top)

        titleLabel >>> contentView >>> {
            $0.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            $0.text = "Lưu ý về món"
            $0.snp.makeConstraints({ (make) in
                make.top.left.equalTo(16)
            })
        }
        
        noteTextView >>> contentView >>> {
            $0.borderColor = #colorLiteral(red: 0.8666666667, green: 0.8862745098, blue: 0.9098039216, alpha: 1)
            $0.borderWidth = 1.0
            $0.cornerRadius = 8
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(16)
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.height.equalTo(80)
            })
        }
        
        let editView = StoreEditMenuView(frame: .zero)
        editView >>> contentView >>> {
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(noteTextView.snp.bottom).offset(16)
                make.centerX.equalToSuperview()
                make.height.equalTo(40)
                make.width.equalTo(120)
            })
        }
        self.editView = editView
        
    }
    
    
    override func setup() {
        super.setup()
        height = { 196 }
    }
}

extension MenuNoteCell {
    func updateMinValue(_ minValue: Int) {
        editView?.minValue = minValue
    }
    
    func setupDisplay(item: ProductMenuItem?) {
        self.noteTextView.text = item?.basketItem?.note ?? ""
        self.editView?.update(value: item?.basketItem?.quantity ?? 1)
    }
}


extension MenuNoteCell {
    func getNote() -> String {
        return noteTextView.text
    }
}

