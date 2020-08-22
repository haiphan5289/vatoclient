//  File name   : VatoManageDeepLink.swift
//
//  Author      : Dung Vu
//  Created date: 5/21/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import RxSwift

extension URLComponents {
    init?(optional url: URL?, resolvingAgainstBaseURL: Bool) {
        guard let url = url else { return nil }
        self.init(url: url, resolvingAgainstBaseURL: resolvingAgainstBaseURL)
    }
}

struct VatoDeepLinkItem: Codable {
    var storeId: Int?
    var rootCategoryId: Int?
    var serviceId: Int?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let s = try values.decodeIfPresent(String.self, forKey: .storeId) {
            storeId = Int(s)
        }
        
        if let r = try values.decodeIfPresent(String.self, forKey: .rootCategoryId) {
            rootCategoryId = Int(r)
        }
        
        if let sId = try values.decodeIfPresent(String.self, forKey: .serviceId) {
            serviceId = Int(sId)
        }
    }
    
    var ecomService: ServiceCategoryType? {
       return ServiceCategoryType.loadEcom(category: rootCategoryId)
    }
}

@objcMembers
final class VatoManageDeepLink: NSObject {
    static let instance = VatoManageDeepLink()
    @Replay(queue: MainScheduler.asyncInstance) private var mNewDeepLink: VatoDeepLinkItem?
    var newDeepLink: Observable<VatoDeepLinkItem> {
        return $mNewDeepLink.filterNil()
    }
    
    func reset() {
        mNewDeepLink = nil
    }
    
    func trackLaunchOption(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        guard let userActivityDictionary = launchOptions?[.userActivityDictionary] as? [String : Any],
            let userActivity = userActivityDictionary["UIApplicationLaunchOptionsUserActivityKey"] as? NSUserActivity else {
                return
        }
        
        handlerDeepLink(userActivity.webpageURL)
    }
    
    func handlerDeepLink(_ url: URL?) {
        guard let components = URLComponents(optional: url, resolvingAgainstBaseURL: false) else { return }
        let queries = components.queryItems?.reduce(into: [String: String](), { (r, item) in
            r[item.name] = item.value
        }) ?? [:]
        
        do {
            let data = try JSONSerialization.data(withJSONObject: queries)
            let item = try VatoDeepLinkItem.toModel(from: data)
            mNewDeepLink = item
        } catch {
            #if DEBUG
            assert(false, error.localizedDescription)
            #endif
        }
    }
}


