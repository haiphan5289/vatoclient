//
//  FireBase+ConfigData.swift
//  Vato
//
//  Created by vato. on 11/14/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation
import FirebaseFirestore
import Firebase
import RxSwift
import RxCocoa
import VatoNetwork

struct TetConfig: Codable {
    var maxTicket: Int?
    var identifierCardRequired: Bool?
    var fromDate: String?
    var toDate: String?
    var routes: [String]?
    
    func isValidateIdentifierId(date: Date, destCode: String) -> Bool {
        guard self.identifierCardRequired == true,
            let fromDate = self.fromDate?.toDate(format: "dd-MM-yyyy HH:mm"),
            let toDate = self.toDate?.toDate(format: "dd-MM-yyyy HH:mm"),
            fromDate.timeIntervalSince1970 < toDate.timeIntervalSince1970 else { return false }
        
        let routes = self.routes ?? []
        if  fromDate.timeIntervalSince1970...toDate.timeIntervalSince1970 ~= date.timeIntervalSince1970,
            routes.first(where: { $0 == destCode }) != nil {
            return true
        }
        return false
    }
}

// MARK: -- BusLine Config
final class BuslineConfigDataManager {
    static let shared = BuslineConfigDataManager()
    private struct Configs {
        static let url: (String) -> String = { p in
            let rootURL: String = {
                #if DEBUG
                    return "https://api-busline-dev.vato.vn/api"
                #else
                    return "https://api-busline.vato.vn/api"
                #endif
            }()
            return "\(rootURL)\(p)"
        }
    }
    
    private var tetConfig: TetConfig?
    private lazy var disposeBag = DisposeBag()
    @Replay(queue: MainScheduler.asyncInstance) var listPopular: [PopularRoute]?
    
    private init() {}
   
    private func getConfigBusline() {
        let documentRef = Firestore.firestore().documentRef(collection: .buslineConfig, storePath: .tetConfig , action: .read)
        return documentRef.find(action: .get, json: nil)
            .filterNil()
            .subscribe(onNext: { (d) in
                let model = try? d.decode(to: TetConfig.self)
                self.tetConfig = model
            }).disposed(by: disposeBag)
    }
    
    func isValidateIdentifierId(date: Date, destLocation: TicketLocation) -> Bool {
        return self.tetConfig?.isValidateIdentifierId(date: date, destCode: destLocation.code) ?? false
    }
    
    func load() {
        getDefautConfig()
//        requestBusLinePopular()
    }
    
    private func getDefautConfig() {
        self.getConfigBusline()
    }
    
    private struct BusLineResponse: Codable {
        var data: [PopularRoute]?
    }
    
    private func requestBusLinePopular() {
        let params: JSON = ["page": 0, "size": 100, "type": "POPULAR"]
        let url = Configs.url("/buslines/futa/routes/customize-routes")
        let router = VatoAPIRouter.customPath(authToken: "", path: url, header: ["token_type":"user"], params: params, useFullPath: true)
                
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        network.request(using: router, decodeTo: OptionalMessageDTO<BusLineResponse>.self).bind { (result) in
            switch result {
            case .success(let r):
                self.listPopular = r.data?.data ?? []
            case .failure(let e):
                #if DEBUG
                
                assert(false, e.localizedDescription)
                #endif
            }
        }.disposed(by: disposeBag)
    }
}
