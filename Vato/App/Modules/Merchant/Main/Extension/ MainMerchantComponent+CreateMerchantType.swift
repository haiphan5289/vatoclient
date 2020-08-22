
//
//   MainMerchantComponent+CreateMerchantType.swift
//  Vato
//
//  Created by khoi tran on 10/21/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation
import RIBs


extension MainMerchantComponent: CreateMerchantTypeDependency {
    var authenStream: AuthenticatedStream {
        return dependency.authenticatedStream
    }
    
    
}
