//
//  MainDeliveryInteractor+DomesticDelivery.swift
//  Vato
//
//  Created by khoi tran on 12/23/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation


extension MainDeliveryInteractor {
    
    
    
    
    func loadDefaultDomesticReceiver() {
        self.mDomesticReceiver.onNext(domesticInfoReceiver)
    }
    
    
    
}
