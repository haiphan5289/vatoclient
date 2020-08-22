//
//  ExpressHistoryFilter.swift
//  Vato
//
//  Created by vato. on 12/30/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit

class ExpressHistoryFilter: UIViewController {
    @IBOutlet weak var contentView: UIView?

    lazy var panGesture: UIPanGestureRecognizer? = {
          let p = UIPanGestureRecognizer(target: nil, action: nil)
          contentView?.addGestureRecognizer(p)
          return p
      }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRX()
        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
          guard let point = touches.first else {
              return
          }
          
          let p = point.location(in: self.view)
          guard self.contentView?.frame.contains(p) == false else {
              return
          }
          self.dismiss(animated: true, completion: nil)
      }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: 0.3) {
            self.contentView?.transform = .identity
        }
    }
    
    func setupRX() {
        contentView?.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.size.height)
        let viewBG = HeaderCornerView(with: 7)
        viewBG.containerColor = .white
        contentView?.insertSubview(viewBG, at: 0)
        viewBG >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
    }
}
