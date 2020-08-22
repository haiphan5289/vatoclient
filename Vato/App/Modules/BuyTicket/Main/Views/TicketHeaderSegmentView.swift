//
//  TicketHeaderSegmentView.swift
//  Vato
//
//  Created by khoi tran on 5/5/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation
import SnapKit
import RxSwift
import RxCocoa

final class TicketHeaderSegmentView: UIView, Weakifiable {
    private let lblTitle = UILabel(frame: .zero)
    private let scrollView = UIScrollView(frame: .zero)
    
    private (set) lazy var segmentView = VatoSegmentView<TicketHeaderView, TicketDetailModel>(edges: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16), spacing: 8, axis: .horizontal) { (idx, t) -> TicketHeaderView in
        return self.createItemView(idx: idx, item: t)
    }
    private lazy var mDetail: PublishSubject<TicketDetailModel?> = PublishSubject()
    var eDetail: Observable<TicketDetailModel?> {
       return mDetail
    }
    weak var listener: TicketHeaderViewListener?
    private lazy var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        visualize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createItemView(idx: Int, item: TicketDisplayProtocol) -> TicketHeaderView {
        let v = TicketHeaderView.loadXib()
        v.setupDislay(for: item, type: .future)
        v.snp.makeConstraints { (make) in
            make.width.equalTo(UIScreen.main.bounds.width - 32)
        }
        v.btnShowDetail?.rx.tap.bind(onNext: weakify({ (wSelf) in
            wSelf.mDetail.onNext(item as? TicketDetailModel)
        })).disposed(by: disposeBag)
        return v
    }

    func visualize() {
        self.backgroundColor = .white
        
        lblTitle >>> self >>> {
            $0.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            $0.textColor = #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1)
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(16)
                make.left.equalTo(16)
                make.height.equalTo(20)
            }
        }
        
        scrollView >>> self >>> {
            $0.backgroundColor = .white
            $0.showsHorizontalScrollIndicator = false
            $0.showsVerticalScrollIndicator = false
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(lblTitle.snp.bottom).offset(5)
                make.left.bottom.right.equalToSuperview()
                make.height.equalTo(150)
            }
        }
        
        segmentView >>> scrollView >>> {
            $0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
                make.height.equalTo(scrollView)
            }
        }
        
        segmentView.scrollView = scrollView
    }
    
    func setupDisplayTitle(totalTicket: Int) {
        lblTitle.text = totalTicket > 0 ? (Text.ticketAboutToDepart.localizedText + " (\(totalTicket))") : Text.ticketAboutToDepart.localizedText
    }
}
