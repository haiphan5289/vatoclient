//
//  DomesticBookingView.swift
//  Vato
//
//  Created by khoi tran on 12/26/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit
import RxSwift
import FwiCore
import SnapKit
import FwiCoreRX

class DomesticBookingView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var scheduleButton: UIButton!
    @IBOutlet weak var bookingButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.scheduleButton.isHidden = true
        
        let viewBG = HeaderCornerView(with: 7)
        viewBG.containerColor = .white
        containerView.insertSubview(viewBG, at: 0)
        viewBG >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        
    }
    
    
    private (set) var showing: Bool = true

    func show() {
        guard !showing else {
            return
        }
        showing = true
        self.backgroundView.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.backgroundView.alpha = 1
            self.containerView.transform = .identity
        }
    }
    
    func dimiss(_ animated: Bool) {
        guard showing else {
            return
        }
        showing = false
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                self.backgroundView.alpha = 0
                self.containerView.transform = CGAffineTransform(translationX: 0, y: 1000)
            }) { (_) in
                self.backgroundView.isHidden = true
            }
        } else {
            self.backgroundView.alpha = 0
            self.backgroundView.isHidden = true
            self.containerView.transform = CGAffineTransform(translationX: 0, y: 1000)
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let v = super.hitTest(point, with: event) else {
            return nil
        }

        guard (v is UIControl) || self.containerView.frame.contains(point) == true else {
            self.dimiss(true)
            return nil
        }
        
        return v
    }
    
}
