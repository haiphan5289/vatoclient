//
//  AddDestinationCommunication.swift
//  FC
//
//  Created by khoi tran on 3/27/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation
import VatoNetwork
import RxSwift
import FirebaseFirestore

@objcMembers
final class AddDestinationCommunication: NSObject, SafeAccessProtocol, ManageListenerProtocol {
    var lock: NSRecursiveLock = NSRecursiveLock()
    
    var listenerManager: [Disposable] = []
    
    static let shared = AddDestinationCommunication()
    

    private lazy var network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
    
    struct Configs {
        static let url: (String) -> String = { p in
            #if DEBUG
            return "https://api-dev.vato.vn\(p)"
            #else
            return "https://api.vato.vn\(p)"
            #endif
        }
        
        static let genError: (String?) -> NSError = { messge in
            return NSError(domain: NSURLErrorDomain,
                           code: NSURLErrorUnknown,
                           userInfo: [NSLocalizedDescriptionKey: messge ?? "Chức năng tạm thời gián đoạn. Vui lòng thử lại sau."])
        }
    }
     func listenChangeDestination() {
        guard let userId = UserManager.instance.userId else { return }
        let collectionRef = Firestore.firestore().collection(collection: .custom(id: "Notifications"), .custom(id: "\(userId)"), .custom(id: "driver"))
        let dispose = collectionRef.listenNotificationTaxi().skip(1).subscribe(onNext: { [weak self] (l) in
            
            let add = (l.documentsAdd?.compactMap { try? $0.decode(to: AddDestinationNotification.self) } ?? []).sorted { (a1, a2) -> Bool in
                return a1.created_at ?? 0 > a2.created_at ?? 0
            }
            
            if !add.isEmpty, let first = add.first {
            }
        })
        add(dispose)
    }
    
    func stopListenNotification() {
        self.cleanUpListener()
    }
    

    
    func requestDestinationOrder(orderId: Int) {
//        let url = Configs.url("/api/destination-order/\(orderId)")
//        let router = VatoAPIRouter.customPath(authToken: "", path: url, header: nil, params: nil, useFullPath: true)
//        let dispose = network.request(using: router, decodeTo: OptionalMessageDTO<AddDestinationRequestDetail>.self).bind {[weak self] (result) in
//                   guard let wSelf = self else { return }
//                   switch result {
//                   case .success(let s):
//                        if let data = s.data {
//                        }
//                   case .failure(let e):
//                       print(e.localizedDescription)
//                   }
//               }
//        add(dispose)
        
    }
}

