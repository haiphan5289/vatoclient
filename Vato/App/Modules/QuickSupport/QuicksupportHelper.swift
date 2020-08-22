//
//  QuicksupportHeper.swift
//  FC
//
//  Created by vato. on 2/11/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation
import RxSwift
import FirebaseFirestore

@objcMembers
class QuicksupportHelper: NSObject {
    static let shared = QuicksupportHelper()
    private lazy var disposeBag: DisposeBag = DisposeBag()
    
    func getUnreadMessage(completion: ((Int, Error?) -> ())?) {
        let userId = UserManager.instance.getUserId() ?? 0
        
        let collectionRef = Firestore.firestore().collection(collection: .quickSupport)
        let query = collectionRef
            .whereField("createdBy", isEqualTo: userId)
            .whereField("userType", isEqualTo: UserType.client.rawValue)
            .whereField("numberOfUnread", isGreaterThan: 0)
        query
            .getDocuments()
            .take(1)
            .map {  $0?.compactMap { try? $0.decode(to: QuickSupportModel.self) }
        }.subscribe(onNext: { (m) in
            var number = 0
            m?.forEach { number += ($0.numberOfUnread ?? 0) }
            completion?(number, nil)
        }, onError: { (e) in
            completion?(0, e)
            }).disposed(by: disposeBag)
    }
}
