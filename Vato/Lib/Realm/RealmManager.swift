//  File name   : RealmManager.swift
//
//  Author      : Phuc Tran
//  Created date: 8/26/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import Locksmith
import RealmSwift

@objcMembers
public final class RealmManager: NSObject, RealmAdapter {
    /// Class's public properties.
    private static let _encryptionKey: String = {
        func generateKey() -> String {
            let length = 64
            var bytes = [UInt8](repeating: 0, count: length)
            _ = SecRandomCopyBytes(kSecRandomDefault, length, &bytes)
            
            let key = Data(bytes: bytes)
            let encryptionKey = key.base64EncodedString()
            defer {
                try? Locksmith.saveData(data: ["key": encryptionKey], forUserAccount: "realm_encryption_key")
            }
            return encryptionKey
        }
        
        func load() -> String? {
            let info = Locksmith.loadDataForUserAccount(userAccount: "realm_encryption_key") as? [String: String]
            let key = info?["key"]
            return key
        }
        
        return load() ?? generateKey()
    }()
    
    private static var _schemaVersion: UInt64 {
        return 24
    }
    
    static func setupConfig() {
        let config = RealmManager.config
        Realm.Configuration.defaultConfiguration = config
    }
    
    
    public lazy var encryptionKey: String = RealmManager._encryptionKey

    public var schemaVersion: UInt64 {
        return RealmManager._schemaVersion
    }
    
    static var config: Realm.Configuration {
        let version = _schemaVersion
        let homePath = URL.documentDirectory()
        let fFile = homePath?.appendingPathComponent("vato.realm")
        
        let config = Realm.Configuration.init(fileURL: fFile, schemaVersion: version)
            //Realm.Configuration(schemaVersion: version,
                                         
                                         // Set the block which will be called automatically when opening a Realm with a schema
                                         // version lower than the one set above.
//                                         migrationBlock: { migration, oldSchemaVersion in
//                                             if oldSchemaVersion < version {
//                                                 // Nothing to do! Realm will automatically detect new properties and removed
//                                                 // properties And will update the schema on disk automatically.
//                                             }
//        })
//        #if DEBUG
//        #else
//            config.encryptionKey = Data(base64Encoded: _encryptionKey)
//        #endif
//        config.deleteRealmIfMigrationNeeded = false
        return config
    }
    
    public lazy var mainConfig: Realm.Configuration? = {
        return RealmManager.config
    }()

    public lazy var readonlyConfig: Realm.Configuration? = {
        var config = mainConfig
        config?.readOnly = true
        return config
    }()

    public lazy var newRealm: Realm? = {
        guard let config = mainConfig else {
            return nil
        }

        var realm: Realm?
        do {
            realm = try Realm(configuration: config)
        } catch let err as NSError {
            realm = nil
            print(err)
        }
        return realm
    }()

    public lazy var mainRealm: Realm? = {
        guard let config = mainConfig else {
            return nil
        }

        var realm: Realm?
        do {
            realm = try Realm(configuration: config)
        } catch let err as NSError {
            realm = nil
            print(err)
        }
        return realm
    }()

    public lazy var readonlyRealm: Realm? = {
        guard let config = readonlyConfig else {
            return nil
        }

        var realm: Realm?
        do {
            realm = try Realm(configuration: config)
        } catch let err as NSError {
            realm = nil
            print(err)
        }
        return realm
    }()
    
    /// Class's private properties.
}

// MARK: Class's private methods
private extension RealmManager {}
