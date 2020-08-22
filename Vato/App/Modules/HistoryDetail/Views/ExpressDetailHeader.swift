//
//  ExpressDetailHeader.swift
//  Vato
//
//  Created by vato. on 12/23/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit

class ExpressDetailHeader: UIView {
    @IBOutlet weak var qrCodeImage: UIImageView!
    var didSelectQRCode: (() -> Void)?
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    
    override func draw(_ rect: CGRect) {
        qrCodeImage.image = self.generateQRCode(from: "ABC")
    }
    
    @IBAction func didSelectQRCode(_ sender: Any) {
        didSelectQRCode?()
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
    
}
