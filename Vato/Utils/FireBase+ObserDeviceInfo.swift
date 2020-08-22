//
//  FireBase+Extension.swift
//  FaceCar
//
//  Created by Dung Vu on 11/8/18.
//  Copyright © 2018 Vato. All rights reserved.
//

import Foundation
import Firebase
import RxSwift

extension DatabaseReference {
    func addListenerDeviceInfo(from firebaseId: String) -> Observable<DeviceInfo> {
        let node = FireBaseTable.client >>> .custom(identify: firebaseId) >>> .custom(identify: "deviceInfo")
        return self.find(by: node, type: .childChanged) {
            $0.keepSynced(true)
            return $0
            }.flatMap { (snapshot) -> Observable<DeviceInfo> in
                let deviceInfo = try DeviceInfo.create(from: snapshot)
                return Observable.just(deviceInfo)
        }
    }
}
