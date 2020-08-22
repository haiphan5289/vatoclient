//
//  ShortcutItemManager.swift
//  Vato
//
//  Created by khoi tran on 1/6/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation
import RxSwift

enum ShortcutItemType: String {
    case quickBooking = "com.client.facecar.quickbooking"
    case barcode = "com.client.facecar.scanbarcode"
    case merchant = "com.client.facecar.merchant"
    case food = "com.client.facecar.food"
}

@objcMembers
public class ShortcutItemManager: NSObject {
    static let instance = ShortcutItemManager()
    private var shortcutItemToProcess: UIApplicationShortcutItem?
    
    @Replay(queue: MainScheduler.asyncInstance) private var shortcutItemSubjet: ShortcutItemType
    var shortcutItem: Observable<ShortcutItemType> {
        return $shortcutItemSubjet
    }
    
    
    func addShortcutItem(shortcutItemToProcess: UIApplicationShortcutItem?) {
        self.shortcutItemToProcess = shortcutItemToProcess
    }
    
    func processShortcutItem() {
        if let shortcutItem = self.shortcutItemToProcess, let type = ShortcutItemType.init(rawValue: shortcutItem.type) {
            self.shortcutItemSubjet = type
        }
        
        self.shortcutItemToProcess = nil
    }
    
    
    func createShortcutManual() -> [UIApplicationShortcutItem] {
        let addMerchantItem = UIApplicationShortcutItem(type: ShortcutItemType.merchant.rawValue,
                                                     localizedTitle: "Add Merchant",
                                                     localizedSubtitle: nil,
                                                     icon: UIApplicationShortcutIcon(type: .add),
                                                     userInfo: nil)
        
        let foddItem = UIApplicationShortcutItem(type: ShortcutItemType.food.rawValue,
                                                    localizedTitle: "Order food",
                                                    localizedSubtitle: nil,
                                                    icon: UIApplicationShortcutIcon(type: .compose),
                                                    userInfo: nil)
        
        return [addMerchantItem, foddItem]
    }
    
}


