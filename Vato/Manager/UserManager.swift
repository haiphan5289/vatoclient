//  File name   : UserManager.swift
//
//  Author      : Dung Vu
//  Created date: 9/12/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import RxSwift
import VatoNetwork
import Alamofire
import CoreLocation

@objcMembers
final class UserManager: NSObject {
    static let instance = UserManager()
    internal lazy var disposeBag = DisposeBag()
    var userId: Int? {
        if let id = info?.id {
            return Int(id)
        }
        return nil
    }
    
    @ThreadSafe var info: UserInfo?
    @ThreadSafe var currentLocation: CLLocationCoordinate2D?
    
    func updateEmail(token: String, currentUser: UserInfo, email: String) {
        Database.database().reference().updateEmail(email: email, firebaseId: currentUser.firebaseId)
        UserDataHelper.shareInstance().updateEmail(email)
        updateProfileApi(token: token, currentUser: currentUser, email: email)
    }
    
    private func updateProfileApi(token: String, currentUser: UserInfo, email: String) {
        Requester.request(using: VatoAPIRouter.updateAccount(authToken: token, firebaseID: currentUser.firebaseId, phoneNumber: currentUser.phone, deviceToken: nil, fullName: nil, nickname: nil, email: email, birthday: nil, zoneID: nil, avatarURL: nil), method: .post, encoding: JSONEncoding.default)
            .subscribe(onNext: {(r) in
                NotificationCenter.default.post(name: NSNotification.Name.profileUpdated, object: nil)
            }, onError: {
                print($0)
            }).disposed(by: disposeBag)
    }
    
    func cache(user: [String: Any]?) {
        do {
            let user = try UserInfo.toModel(from: user)
            self.cache(info: user)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func cache(info: UserInfo) {
        self.info = info
    }
    
    func update(coordinate: CLLocationCoordinate2D) {
        self.currentLocation = coordinate
    }
    
    func removeInfo() {
        self.info = nil
    }
    
    func getAvatarUrl() -> URL? {
        guard let user = UserDataHelper.shareInstance().getCurrentUser(),
            let avatar = user.user.avatarUrl else {
                return nil
        }
        return URL(string: avatar)
    }
    
    func getCurrentUser() -> FCClient? {
        return UserDataHelper.shareInstance().getCurrentUser()
    }
    
    func getUserId() -> Int? {
        return UserDataHelper.shareInstance().getCurrentUser()?.user.id
    }
    
    func getCurrentLocation() -> CLLocationCoordinate2D {
        let currentLoc = GoogleMapsHelper.shareInstance().currentLocation?.coordinate
        return currentLoc ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }
}
