//  File name   : ConfigManager.swift
//
//  Author      : Dung Vu
//  Created date: 8/26/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import Firebase
import RxSwift
import FwiCore
import VatoNetwork
import Alamofire
import FirebaseRemoteConfig

@objcMembers
final class ConfigManager: NSObject, Weakifiable {
    static let shared = ConfigManager()
    private typealias ConfigData = Data
    private lazy var remoteConfig: RemoteConfig = {
        let remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 5
        remoteConfig.configSettings = settings
        return remoteConfig
    }()
    private lazy var disposeBag = DisposeBag()
    @Replay(queue: MainScheduler.asyncInstance) private var temp: ConfigData
    private lazy var mItems = ReplaySubject<[HomeResponse]>.create(bufferSize: 1)
    var items: Observable<[HomeResponse]> {
        return mItems.observeOn(MainScheduler.asyncInstance).distinctUntilChanged()
    }
    private (set) var radiusDefault: Double = 80
    
    private lazy var cacheURL = URL.cacheDirectory()
    private(set) var useNewHome: Bool = true
    func loadConfig() {
        let keyPlaceHistory = "place_history_distance"
        let key = Text.homePage.localizedText
        let pathCache = self.cacheURL?.appendingPathComponent("\(key).json")
        try? loadCache(pathCache: pathCache, key: key)
        loadRemoteConfig(key: key, keyPlaceHistory: keyPlaceHistory).bind(onNext: { data in
            self.temp = data
        }).disposed(by: disposeBag)
        
        loadConfigFromAPI().catchError { (e) -> Observable<ConfigData> in
            print(e.localizedDescription)
            return self.$temp.take(1)
        }.do(onNext: { (d) in
            self.cacheConfig(url: pathCache, data: d)
        })
        .map { try self.load(from: $0).sorted(by: <) }
        .bind(onNext: weakify({ (items, wSelf) in
            wSelf.mItems.onNext(items)
        })).disposed(by: disposeBag)
    }
    
    private func loadRemoteConfig(key: String, keyPlaceHistory: String) -> Observable<ConfigData> {
        return Observable.create { (s) -> Disposable in
            self.remoteConfig.fetchAndActivate { (status, e) in
                if let e = e {
                    return s.onError(e)
                }
                let values = self.remoteConfig[key]
                let places = self.remoteConfig[keyPlaceHistory]
                self.findPlaceRadius(value: places)
                s.onNext(values.dataValue)
                s.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    struct Configs {
        static let api: (_ path:String) -> String = { p in
            #if DEBUG
                return "https://api-dev.vato.vn\(p)"
            #else
                return "https://api.vato.vn\(p)"
            #endif
        }
    }
    
    private func loadConfigFromAPI() -> Observable<ConfigData> {
        let appId = "CLIENT"
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        let p = Configs.api("/master-data/\(appId)/home-page-config")
        let router = VatoAPIRouter.customPath(authToken: "", path: p, header: nil, params: nil, useFullPath: true)
        return network.request(using: router, decodeTo: MessageDTO<[String: HomeResponse]>.self)
            .map { r -> ConfigData in
            let d = try r.get().data
            let new = d.compactMapValues { try? $0.toJSON() }
            let data = try new.toData()
            return data
        }
    }
        
    private func loadCache(pathCache: URL?, key: String) throws {
        let items: [HomeResponse]
        if FileManager.default.fileExists(pathCache) {
            items = try self.loadFromFile(from: pathCache)
        } else {
            items = try self.loadFromFile(from: Bundle.main.url(forResource: key, withExtension: "json"))
        }
        self.useNewHome = true
        self.mItems.onNext(items)
    }
    
    private func findPlaceRadius(value: RemoteConfigValue) {
        let json = value.json
        guard let d: Double = json?.value(for: "distance_default", defaultValue: 150) else {
            return
        }
        self.radiusDefault = d
    }
    
    private func cacheConfig(url: URL?, data: Data) {
        do {
            try data.write(url)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func loadFromFile(from url: URL?) throws -> [HomeResponse] {
        guard let url = url else {
            return []
        }
        
        let data = try Data(contentsOf: url)
        return try load(from: data)
    }
    
    private func load(from data: Data) throws -> [HomeResponse] {
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        let items = (json as? [String: Any])?.compactMapValues { v -> HomeResponse? in
            guard let data = try? JSONSerialization.data(withJSONObject: v, options: []) else {
                return nil
            }
            let result = try? HomeResponse.toModel(from: data)
            return result
        }
        let homeItems = (items?.map { $0.value } ?? []).sorted(by: <)
        return homeItems
    }
    
}

extension RemoteConfigValue {
    var json: [String: Any]? {
        let j = try? JSONSerialization.jsonObject(with: dataValue, options: [])
        return j as? [String: Any]
    }
}

