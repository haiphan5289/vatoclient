//
//  MomoBridge.swift
//  Vato
//
//  Created by Hiep Nguyen on 8/26/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation
import MomoiOSSwiftSdk

class MomoBridge: NSObject {
   @objc static func handleOpenUrl(open url: URL, sourceApplication: String) {
        MoMoPayment.handleOpenUrl(url: url, sourceApp: sourceApplication)
    }
}
