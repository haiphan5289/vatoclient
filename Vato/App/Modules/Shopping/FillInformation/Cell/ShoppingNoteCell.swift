//
//  ShoppingNoteCell.swift
//  Vato
//
//  Created by khoi tran on 4/4/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation
import Eureka
import RxSwift
import FwiCore

class ShoppingNoteCell: Eureka.Cell<String>, CellType, UpdateDisplayProtocol {
    
    private var titleLabel: UILabel = UILabel(frame: .zero)
    var noteTextView: UITextView = UITextView(frame: .zero)
    var lblStar: UILabel?
    private var lblPlaceHolder: UILabel = UILabel(frame: .zero)

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        visualize()
        setupRX()
    }
    
    func visualize() {
        selectionStyle = .none
        textLabel?.isHidden = true
        
        contentView.addSeperator(with: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), position: .top)

        titleLabel >>> contentView >>> {
            $0.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            $0.text = Text.orderDetail.localizedText
            $0.snp.makeConstraints({ (make) in
                make.top.left.equalTo(16)
            })
        }
        
        let _lblStar = UILabel(frame: .zero)
        _lblStar >>> contentView >>> {
            $0.textColor = Color.orange
            $0.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            $0.text = "*"
            $0.snp.makeConstraints({ (make) in
                make.centerY.equalTo(titleLabel.snp.centerY)
                make.left.equalTo(titleLabel.snp.right).offset(4)
            })
        }
        self.lblStar = _lblStar
        
        noteTextView >>> contentView >>> {
            $0.borderColor = #colorLiteral(red: 0.8666666667, green: 0.8862745098, blue: 0.9098039216, alpha: 1)
            $0.borderWidth = 1.0
            $0.cornerRadius = 8
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(4)
                make.left.equalTo(10)
                make.right.equalTo(-10)
                make.height.equalTo(80)
            })
        }
        
        lblPlaceHolder >>> contentView >>> {
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            $0.isUserInteractionEnabled = false
            $0.textColor = .lightGray
            $0.numberOfLines = 0
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(noteTextView).offset(8)
                make.left.equalTo(noteTextView).offset(4)
                make.right.equalTo(noteTextView)
            })
        }
    }
    
    override func setup() {
        super.setup()
        height = { 130 }
    }
    
    func setupRX() {
        noteTextView.delegate = self
    }
    
    override func cellResignFirstResponder() -> Bool {
        return noteTextView.resignFirstResponder()
    }
    
    @discardableResult func cellBecomeFirstResponder() -> Bool {
        return noteTextView.becomeFirstResponder()
    }
}

extension ShoppingNoteCell {
    func setupDisplay(item: String?) {
        
        self.noteTextView.text = item
//        self.textChanged(sender: self.noteTextView)
        
        if let text = item,
            text.count > 0 {
            lblPlaceHolder.isHidden = true
        } else {
            lblPlaceHolder.isHidden = false
        }
    }
    
    func updatePlaceHolder(_ placeHolder: String?) {
        lblPlaceHolder.text = placeHolder
    }
}

extension ShoppingNoteCell {
    func getNote() -> String {
        return noteTextView.text
    }
}

extension ShoppingNoteCell: UITextViewDelegate {
    
    func textChanged(sender: UITextView?) {
        if let text = sender?.text,
            text.count > 0 {
            lblPlaceHolder.isHidden = true
        } else {
            lblPlaceHolder.isHidden = false
        }
        row.value = sender?.text
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        noteTextView.borderView(with: #colorLiteral(red: 0.8666666667, green: 0.8862745098, blue: 0.9098039216, alpha: 1) , width: 1, andRadius: 8)
        textChanged(sender: textView)
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        noteTextView.borderView(with: Color.orange.withAlphaComponent(0.5) , width: 1, andRadius: 8)
        textChanged(sender: textView)
    }
        
    func textViewDidChange(_ textView: UITextView) {
        textChanged(sender: textView)
    }
}
