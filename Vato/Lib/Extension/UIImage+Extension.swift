//  File name   : UIImage+Extension.swift
//
//  Author      : Vato
//  Created date: 10/2/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit

extension UIImage {
    func scaleImage(toRatio aspectRatio: CGFloat) -> UIImage? {
        var scaledImageRect = CGRect.zero
        scaledImageRect.size.width = size.width * aspectRatio
        scaledImageRect.size.height = size.height * aspectRatio

        UIGraphicsBeginImageContextWithOptions(scaledImageRect.size, false, UIScreen.main.scale)
        draw(in: scaledImageRect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return scaledImage
    }
}
