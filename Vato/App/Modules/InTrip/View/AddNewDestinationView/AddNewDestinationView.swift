//
//  AddNewDestinationView.swift
//  Vato
//
//  Created by khoi tran on 3/31/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation
import FwiCore
import RxSwift
import FwiCoreRX

public class AddNewDestinationView: UIView {
    private (set) var guideView: VatoGuideControl?
    private var imgBgMessage: UIImageView = UIImageView(frame: .zero)
    private var lblMessage: UILabel = UILabel(frame: .zero)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        visualize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func visualize() {
        let guideView = VatoGuideControl()
        guideView >>> self >>> {
            $0.snp.makeConstraints { (make) in
                make.right.equalTo(-16)
                make.size.equalTo(CGSize(width: 72, height: 72))
                make.top.equalToSuperview()
            }
        }
        
        self.guideView = guideView
        
        imgBgMessage >>> self >>> {
            $0.snp.makeConstraints { (make) in
                make.left.equalTo(16)
                make.right.equalTo(guideView.snp.left).offset(-6)
                make.bottom.equalToSuperview()
                make.height.equalTo(66)
            }
            
            $0.image = UIImage.init(named: "bg_messsage")
            $0.contentMode = .scaleAspectFill
        }
        
        lblMessage >>> self >>> {
            $0.snp.makeConstraints { (make) in
                make.left.equalTo(imgBgMessage.snp.left).offset(16)
                make.right.equalTo(imgBgMessage.snp.right).offset(-16)
                make.top.equalTo(imgBgMessage.snp.top).offset(12)
                make.bottom.equalTo(imgBgMessage.snp.bottom).offset(-12)
            }
            
            $0.textColor = #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1)
            $0.font = UIFont.italicSystemFont(ofSize: 15)
            $0.numberOfLines = 2
            $0.text = Text.inTripAddDestinationGuide.localizedText
        }
        
    }
}
