//
//  CancellationTicketDetail.swift
//  Vato
//
//  Created by HaiPhan on 10/9/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit

class CancellationPayment: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func ShowPaymentDetail(_ sender: UITapGestureRecognizer) {
        let screenDetail = UIStoryboard.init(name: "CancellationTicket", bundle: nil).instantiateViewController(withIdentifier: "CancellationPaymentDetail") as! CancellationPaymentDetail
        self.present(screenDetail, animated: true, completion: nil)
    }
    
}
