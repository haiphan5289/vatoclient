//
//  CategoryViewController.swift
//  Vato
//
//  Created by khoi tran on 11/5/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import FwiCore
import FwiCoreRX
import SnapKit


class CategoryViewController<E: CategoryDisplayItemView>: UIViewController {
    
    //    var headerView: CategoryTagsHeaderView = CategoryTagsHeaderView(frame: .zero)
    var categoryView: CategoryTagsView = CategoryTagsView(frame: .zero)
    
    private lazy var bgView: UIView = UIView(frame: .zero)
    private lazy var contentView: UIView = UIView(frame: .zero)
    
    private lazy var titleLabel: UILabel = UILabel(frame: .zero)
    private lazy var updateButton: UIButton = UIButton(frame: .zero)
    
    private lazy var tapGesture: UITapGestureRecognizer = UITapGestureRecognizer()
    
    private lazy var disposeBag = DisposeBag()
    
    var callback: (([E]?) -> Void)?
    var listCategory: [E] = []
    var listSelectedCategory: [E] = []
    
    var allowsMultipleSelection = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.visualize()
        self.setupRX()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.localize()
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension CategoryViewController {
    func localize() {
        
    }
    
    func visualize() {
        bgView >>> self.view >>> {
            $0.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.85)
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        
        contentView >>> self.view >>> {
            $0.backgroundColor = .white
            $0.snp.makeConstraints { (make) in
                make.bottom.left.right.equalToSuperview()
                make.height.equalToSuperview().dividedBy(2)
            }
        }
        
        
        titleLabel >>> contentView >>> {
            $0.text = "Chọn danh mục"
            $0.textColor = #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(24)
                make.left.equalTo(16)
            }
        }
        updateButton >>> contentView >>> {
            $0.cornerRadius = 8.0
            $0.borderWidth = 1.0
            $0.borderColor = #colorLiteral(red: 0.7972653508, green: 0.8179522753, blue: 0.8375228047, alpha: 1)
            $0.setBackground(using: .white, state: .normal)
            $0.setTitle(Text.updateTimeWork.localizedText, for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            $0.setTitleColor(#colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1), for: .normal)
            
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.bottom.equalTo(-16)
                make.height.equalTo(40)
            })
        }
        self.automaticallyAdjustsScrollViewInsets = false
        
        categoryView >>> contentView >>> {
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(16)
                make.right.equalTo(-16)
                
                make.top.equalTo(titleLabel.snp.bottom).offset(24)
                make.bottom.equalTo(updateButton.snp.top).offset(-24)
            })
        }
        
        self.view.bringSubviewToFront(contentView)
        categoryView.updateSelectionStyle(allowsMultipleSelection: self.allowsMultipleSelection)
        categoryView.setupDisplay(item: listCategory, listSelected: listSelectedCategory)
        
        bgView.addGestureRecognizer(tapGesture)
    }
    
    func setupRX() {
        self.tapGesture.rx.event.bind(onNext: { [weak self] recognizer in
            guard let me = self else { return }
            me.dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        self.updateButton.rx.tap.bind { [weak self] in
            guard let me = self else { return }
            let selecteds = me.categoryView.selectedItems
            let result = me.listCategory.filter { (i) -> Bool in
                selecteds?.contains(where: { $0.id == (i.id ?? 0 )}) ?? false
            }
            
            if let callback = me.callback {
                callback(result)
            }
            
            me.dismiss(animated: true, completion: nil)
        }.disposed(by: disposeBag)
    }
}
