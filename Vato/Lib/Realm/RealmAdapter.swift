import Foundation
import RealmSwift

/// RealmAdapter defines characteristic of realm's decorator object.
public protocol RealmAdapter: NSObjectProtocol {
    /// Realm's encryption key that will be used to encrypt database.
    var encryptionKey: String { get }

    /// Realm's schema version that will be used for migration.
    var schemaVersion: UInt64 { get }

    /// Should be used on main thread only.
    var mainConfig: Realm.Configuration? { get }

    /// Should be used when only need to read data from realm.
    var readonlyConfig: Realm.Configuration? { get }

    /// Should be used on an thread beside main thread.
    var newRealm: Realm? { get }

    /// Should be used only on main thread.
    var mainRealm: Realm? { get }

    /// Should be used when only need to read data from realm.
    var readonlyRealm: Realm? { get }

    /// Wrapper func to write data into main realm. This func should only be called on main thread.
    ///
    /// - parameter closure: {closure} (business closure)
    func writeMainRealm(withClosure c: @escaping (_ realm: Realm) -> Void)

    /// Wrapper func to write data into new realm.
    ///
    /// - parameter closure: {closure} (business closure)
    func writeNewRealm(withClosure c: @escaping (_ realm: Realm) -> Void)

    /// Wrapper func to write data into realm.
    ///
    /// - parameters:
    ///   - realm: {Realm} (realm's instance)
    ///   - closure: {closure} (business closure)
    func writeRealm(withRealm r: Realm?, closure c: @escaping (_ realm: Realm) -> Void)
}

/// Default implementation for RealmAdapter.
public extension RealmAdapter {
    /// Wrapper func to write data into main realm. This func should only be called on main thread.
    ///
    /// - parameter closure: {closure} (business closure)
    func writeMainRealm(withClosure c: @escaping (_ realm: Realm) -> Void) {
        guard mainRealm != nil else {
            debugPrint("Main realm could not be created. Please check your realm's config or realm's schema.")
            return
        }
        writeRealm(withRealm: mainRealm, closure: c)
    }

    /// Wrapper func to write data into new realm.
    ///
    /// - parameter closure: {closure} (business closure)
    func writeNewRealm(withClosure c: @escaping (_ realm: Realm) -> Void) {
        writeRealm(withRealm: newRealm, closure: c)
    }

    /// Wrapper func to write data into realm.
    ///
    /// - parameters:
    ///   - realm: {Realm} (realm's instance)
    ///   - closure: {closure} (business closure)
    func writeRealm(withRealm r: Realm?, closure c: @escaping (_ realm: Realm) -> Void) {
        guard let realm = r else {
            debugPrint("Your realm instance is nil. This action will be skipped.")
            return
        }

        do {
            try realm.write {
                c(realm)
            }
        } catch let err as NSError {
            debugPrint(err.localizedDescription)
        }
    }
}
