//  File name   : CachedResourceManager.swift
//
//  Author      : Dung Vu
//  Created date: 6/11/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import Realm
import RealmSwift
import RxSwift
import RxCocoa
import FwiCore

// MARK: - Model Cache
@objcMembers
final class LisResourceItem: Object {
    dynamic var key = ""
    dynamic var value = ""
}

@objcMembers
final class CachedResourceItem: Object {
    dynamic var key = ""
    dynamic var rootURL: String = ""
    dynamic var source: List<LisResourceItem> = List()
    dynamic var sourceType: String = ""
    dynamic var expired: TimeInterval = 0
    dynamic var createdAt: TimeInterval = 0
    override class func primaryKey() -> String? {
        return "key"
    }
    
    func updateSourceType(s: String) {
        do {
            try realm?.write({
                self.sourceType = s
            })
        } catch {
            #if DEBUG
            assert(false, error.localizedDescription)
            #endif
        }
    }
    
    func updateRootURL(rootURL: String) {
        do {
            try realm?.write({
                self.rootURL = rootURL
            })
        } catch {
            #if DEBUG
            assert(false, error.localizedDescription)
            #endif
        }
    }
    
    func update(key: String, sourcePath: String?) {
        do {
            if let s = sourcePath {
                let new = LisResourceItem()
                new.key = key
                new.value = s
                guard !source.contains(new) else { return }
                try realm?.write({
                    source.append(new)
                })
                
            } else {
                guard let idx = source.firstIndex (where: { $0.key == key }) else { return }
                try realm?.write({
                    source.remove(at: idx)
                })
            }
        } catch {
            #if DEBUG
            assert(false, error.localizedDescription)
            #endif
        }
    }
}

// MARK: - Main class
final class CachedResourceManager: SafeAccessProtocol {
    static let instance = CachedResourceManager()
    private lazy var documentPath = URL.documentDirectory()?.appendingPathComponent("CachedResource")
    private static let ext = "tmp"
    let lock: NSRecursiveLock = NSRecursiveLock()
    private let queueIO = DispatchQueue(label: "com.vato.cached", qos: .background)
    private let queueConvert = DispatchQueue(label: "com.vato.convert", qos: .background)
    private var cachedMemory: NSCache<NSString, UIImage> = NSCache()
    private var cachedNameKey: NSCache<NSString, NSString> = NSCache()
    
    private lazy var disposeBag = DisposeBag()
    @UserDefault("Removed_File", defaultValue: false) private var removed: Bool
    private var realm: Realm? {
        do {
            return try Realm()
        } catch {
            defer {
                LogEventHelper.log(key: "Open_Realm_Database_Error", params: ["reason": error.localizedDescription])
            }
            
            #if DEBUG
                assert(false, error.localizedDescription)
            #endif
            return nil
        }
    }
    
    private func removeResourceOldIfNeeded() {
        guard !removed else {
            return
        }
        do {
            guard FileManager.default.directoryExists(documentPath) else {
                removed = true
                return
            }
            try FileManager.default.removeDirectory(documentPath)
        } catch {
           #if DEBUG
               assert(false, error.localizedDescription)
           #endif
        }
        removed = true
    }
    
    private init() {
        setupRX()
        removeResourceOldIfNeeded()
        guard let documentPath = documentPath, !FileManager.default.directoryExists(documentPath) else { return }
        do {
           try FileManager.default.createDirectory(documentPath)
        } catch {
           #if DEBUG
               assert(false, error.localizedDescription)
           #endif
        }
    }
        
    private func cleanupMemory(_ notification: Notification) {
        excute(block: { cachedMemory.removeAllObjects(); cachedNameKey.removeAllObjects() })
    }
    
    private func setupRX() {
        NotificationCenter.default.rx
            .notification(UIApplication.didReceiveMemoryWarningNotification)
            .bind(onNext: cleanupMemory)
            .disposed(by: disposeBag)
    }
    
    private func loadRealm() -> Observable<Realm?> {
        return Observable.create { (s) -> Disposable in
            let task = Realm.asyncOpen(configuration: RealmManager.config) { (r, e) in
                if let e = e {
                    defer {
                        LogEventHelper.log(key: "Open_Realm_Database_Error", params: ["reason": e.localizedDescription])
                    }
                    #if DEBUG
                    assert(false, e.localizedDescription)
                    #endif
                    return s.onError(e)
                }
                s.onNext(r)
                s.onCompleted()
            }
            return Disposables.create {
                task.cancel()
            }
        }.take(1).observeOn(MainScheduler.asyncInstance)
    }
    
    private func loadObject(key: String) -> Observable<CachedResourceItem?> {
        return loadRealm().map { $0?.object(ofType: CachedResourceItem.self, forPrimaryKey: key) }.catchErrorJustReturn(nil)
    }
    
    private func add(key: String, nameSource: String, value: Data, isRoot: Bool, sourceType: String) {
        loadObject(key: key).bind { (o) in
            let object: CachedResourceItem
            if let o = o {
                object = o
                object.updateSourceType(s: sourceType)
            } else {
                let new = CachedResourceItem()
                new.key = key
                new.sourceType = sourceType
                new.createdAt = Date().timeIntervalSince1970
                do {
                    try self.realm?.write {
                        self.realm?.add(new, update: .all)
                    }
                } catch {
                    #if DEBUG
                        assert(false, error.localizedDescription)
                    #endif
                }
                object = new
            }
            let sets = CharacterSet.letters.union(CharacterSet.decimalDigits)
            let v = String((key.addingPercentEncoding(withAllowedCharacters: sets) ?? "").suffix(40))
            guard let p = self.write(data: value, name: nameSource.replacingOccurrences(of: ".", with: "").orEmpty(v)) else {
                return
            }
            
            if isRoot {
                object.updateRootURL(rootURL: p)
            } else {
                assert(!nameSource.isEmpty, "!!! Not Empty")
                object.update(key: nameSource, sourcePath: p)
            }
        }.disposed(by: disposeBag)
    }
    
    private func write(data: Data, name: String) -> String? {
        let mPath = "\(name).\(CachedResourceManager.ext)"
        guard let p = documentPath?.appendingPathComponent(mPath) else {
            return nil
        }
        defer {
            queueIO.async {
                do {
                    try data.write(to: p)
                } catch {
                    #if DEBUG
                        assert(false, error.localizedDescription)
                    #endif
                }
            }
        }
        
        return mPath
    }
}

// MARK: - Process Image
extension CachedResourceManager {
    private func convertImage(fileURL: URL, suggestName: String?) -> Observable<Data?> {
        return Observable.create { (s) -> Disposable in
            self.queueConvert.async {
                defer {
                    try? FileManager.default.removeFile(fileURL)
                }
                do {
                    let data = try Data(contentsOf: fileURL)
                    let image = UIImage(data: data)
                    let d: Data?
                    if let s = suggestName {
                        d = s.lowercased().contains("png") ? image?.pngData() : image?.jpegData(compressionQuality: 0.9)
                    } else {
                        d = image?.jpegData(compressionQuality: 0.9)
                    }
                    s.onNext(d)
                    s.onCompleted()
                } catch {
                    #if DEBUG
                        assert(false, error.localizedDescription)
                    #endif
                    s.onNext(nil)
                    s.onCompleted()
                }
            }
            return Disposables.create()
        }.observeOn(MainScheduler.asyncInstance)
    }
    
    private func loadImage(from p: String) -> UIImage? {
        guard let url = self.documentPath?.appendingPathComponent(p) else {
            return nil
        }
        do {
            let data = try Data(contentsOf: url)
            let r = UIImage(data: data)
            return r
        } catch {
            return nil
        }
    }
    
    func cacheImage(url: URL, fileURL: URL, suggestName: String?) -> Observable<Data> {
        let sType = suggestName?.contains("png") == true ? "png" : "jpg"
        return convertImage(fileURL: fileURL, suggestName: suggestName).filterNil().do(onNext: { (data) in
            self.add(key: url.absoluteString, nameSource: "\(Date().timeIntervalSince1970)", value: data, isRoot: true, sourceType: sType)
        })
    }
    
    private func generateImageCacheName(_ url: URL, size: CGSize) -> Observable<String> {
        return Observable.create { (s) -> Disposable in
            self.queueIO.async {
                let key = "\(url.absoluteString)_\(size)" as NSString
                let name: String
                if let cached = self.excute (block: { self.cachedNameKey.object(forKey: key) }) {
                    name = cached as String
                } else {
                    var u = url
                    u.deletePathExtension()
                    let asciiName = u.absoluteString.asciiArray.map { "\($0)" }.joined().suffix(80)
                    name = "\(asciiName)" + "_\(Int(size.width))_\(Int(size.height))"
                    self.excute { self.cachedNameKey.setObject(name as NSString, forKey: key) }
                }
                
                s.onNext(name)
                s.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    private func loadRootImage(from object: CachedResourceItem, rootURL: String, tS: String ,name: String, size: CGSize) -> UIImage? {
        let image = self.loadImage(from: rootURL)
        guard let i = image else {
            return nil
        }
        
        let new = i.resize(targetSize: size)
        defer {
            self.excute(block: { self.cachedMemory.setObject(new, forKey: name as NSString) })
            let d = tS.contains("jpg") ? new.compressJPG(quality: 1) : new.compressPNG()
            if let p = self.write(data: d, name: name) {
                DispatchQueue.main.async {
                    object.update(key: name, sourcePath: p)
                }
            }
        }
        return new
    }
    
    
    private func findImage(from object: CachedResourceItem, name: String, size: CGSize) -> Observable<UIImage?> {
        let path = object.source.first(where: { $0.key == name })?.value
        let rootURL = object.rootURL
        let tS = object.sourceType
        
        return Observable.create { (s) -> Disposable in
            self.queueIO.async {
                let result: (UIImage?) -> () = {
                    s.onNext($0)
                    s.onCompleted()
                }
                
                if let p = path {
                    let i = self.loadImage(from: p) ?? self.loadRootImage(from: object,
                                                                          rootURL: rootURL,
                                                                          tS: tS,
                                                                          name: name,
                                                                          size: size)
                    result(i)
                } else {
                    let new = self.loadRootImage(from: object,
                                                 rootURL: rootURL,
                                                 tS: tS,
                                                 name: name,
                                                 size: size)
                    result(new)
                }
            }
            return Disposables.create()
        }
    }
    private func loadCacheImage(name: String, url: URL, size: CGSize) -> Observable<UIImage?> {
        if let r = excute(block: { cachedMemory.object(forKey: name as NSString) }) {
            return Observable.just(r)
        }
        
        return self.loadObject(key: url.absoluteString).flatMap { (object) -> Observable<UIImage?> in
            guard let object = object else {
                return Observable.just(nil)
            }
            return self.findImage(from: object, name: name, size: size)
        }
    }
    
    func loadImage(url: URL, size: CGSize) -> Observable<UIImage?> {
        return generateImageCacheName(url, size: size).flatMap { (name) in
            return self.loadCacheImage(name: name, url: url, size: size)
        }
    }
}

// MARK: - Object function
extension CachedResourceManager {
    func add<T: Encodable>(key: String, nameSource: String, value: T, isRoot: Bool = true) {
        do {
            let data = try value.toData()
            add(key: key, nameSource: nameSource, value: data, isRoot: isRoot, sourceType: "")
        } catch {
            #if DEBUG
                assert(false, error.localizedDescription)
            #endif
        }
    }
    
    private func findObject<T: Decodable>(from object: CachedResourceItem) -> Observable<T?> {
        let rootURL = object.rootURL
        return Observable.create { (s) -> Disposable in
            self.queueIO.async {
                guard let url = self.documentPath?.appendingPathComponent(rootURL) else {
                    s.onNext(nil)
                    return s.onCompleted()
                }
                
                do {
                    let data = try Data(contentsOf: url)
                    let result = try T.toModel(from: data)
                    s.onNext(result)
                    s.onCompleted()
                } catch {
                    s.onNext(nil)
                    s.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
    
    func load<T: Decodable>(key: String, type: T.Type) -> Observable<T?> {
        return loadObject(key: key).flatMap { (object) -> Observable<T?> in
            guard let object = object else {
                return Observable.just(nil)
            }
            return self.findObject(from: object)
        }
    }
}
