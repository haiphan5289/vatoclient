//
//  ViewCheckUI.swift
//  Vato
//
//  Created by HaiPhan on 10/21/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit

class TimeWorkVC: UIViewController {

    @IBOutlet weak var containerView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerView.backgroundColor = .clear
        let viewBG = HeaderCornerView(with: 7)
        viewBG.containerColor = .white
        containerView?.insertSubview(viewBG, at: 0)
        viewBG >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
    }

}
