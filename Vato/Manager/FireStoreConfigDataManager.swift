//
//  FireBase+ConfigData.swift
//  Vato
//
//  Created by vato. on 11/14/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation
import FirebaseFirestore
import RxSwift
import RxCocoa

struct PaymentMethodConfig: Codable {
    let cardFee: Float?
    let id: Int?
    let name: String?
    let support_services: Int?
    var direct_payment: Int?
    
    func canApply(serviceId: Int) -> Bool {
        guard let support_services = support_services else { return false }
        return ((support_services & serviceId) == serviceId)
    }
    
    func supportDirect(serviceId: Int) -> Bool {
        guard let support_services = direct_payment else { return false }
        return ((support_services & serviceId) == serviceId)
    }
    
    var cardDetail: PaymentCardDetail? {
        guard let id = id else { return nil }
        switch id {
        case 3, 4:
            return .credit()
        case 5:
            return .atm()
        default:
            return nil
        }
    }
}

struct SuggestService: Codable {
    let id: Int?
    let values: [Int]?
}

final class PaymentCardGroup {
    var list: [PaymentCardDetail] = []
    var valid: Bool = true
    var first: PaymentCardDetail?
    
    func selectDefault() {
        list.sort { (c1, c2) -> Bool in
            return c1.canUse
        }
        first = list.first
    }
    
    func contain(card: PaymentCardDetail) -> Bool {
        guard let idx = list.index(of: card) else {
            return false
        }
        return list[idx].canUse
    }
}

fileprivate struct ConfigsDirectPayment: Codable {
    static let `default` = ConfigsDirectPayment.init(primary: "",
                                                     secondary: "")
    var primary: String
    var secondary: String
    
    func validAddCard() -> (visa: Bool, atm: Bool) {
        let list1 = primary.components(separatedBy: "|")
            .flatMap { $0.components(separatedBy: ",") }
            .filter { $0.contains("token") && !$0.hasPrefix("-") }
        let list2 = secondary.components(separatedBy: "|")
            .flatMap { $0.components(separatedBy: ",") }
            .filter { $0.contains("token") && !$0.hasPrefix("-") }
        
        let total = list1 + list2
        let visa = total.first(where: { $0.contains("master") || $0.contains("visa") || $0.contains("jcb") }) != nil
        let atm = total.first(where: { $0.contains("atm") }) != nil
        return (visa, atm)
    }

    private func calculate(original: String, list: inout [PaymentCardDetail], result: inout [PaymentCardGroup]) {
        let c1 = original.components(separatedBy: "|")
        c1.forEach { (s) in
            let s00 = s.components(separatedBy: ",")
            let item = PaymentCardGroup()
            s00.forEach { (token) in
                let mToken = token.replacingOccurrences(of: "-", with: "")
                var idx: Int? = list.firstIndex (where: { (card) -> Bool in
                    return card.identifier == mToken
                })
                
                while idx != nil {
                    if let v = idx {
                        var new = list.remove(at: v)
                        new.canUse = !token.hasPrefix("-")
                        item.list.append(new)
                    }
                    
                    idx = list.firstIndex (where: { (card) -> Bool in
                        return card.identifier == mToken
                    })
                }
            }
            
            guard !item.list.isEmpty else {
                return
            }
            item.selectDefault()
            result.append(item)
        }
    }
    
    func dividendGroup(from list: [PaymentCardDetail]) -> (s1: [PaymentCardGroup], s2: [PaymentCardGroup], s3: [PaymentCardGroup]) {
        var s1 = [PaymentCardGroup]()
        var s2 = [PaymentCardGroup]()
//        var s3 = [PaymentCardGroup]()
        
        var list = list
        calculate(original: primary, list: &list, result: &s1)
        calculate(original: secondary, list: &list, result: &s2)
        
//        let listInValid = PaymentCardGroup()
//        let news = list.map { (card) -> PaymentCardDetail in
//            var card = card
//            card.canUse = false
//            return card
//        }
//        listInValid.list = news
//        s3.append(listInValid)
        return (s1, s2, [])
    }
}

@objcMembers class FireStoreConfigDataManager: NSObject, Weakifiable, SafeAccessProtocol {
    static let shared = FireStoreConfigDataManager()
    private lazy var paymentMethodConfigs = BehaviorRelay<[PaymentMethodConfig]>(value: [])
    private lazy var suggestServices = BehaviorRelay<[SuggestService]>(value: [])
    var isAllowVisa: Bool = false
    var isAllowAtm: Bool = false
    private (set) lazy var lock: NSRecursiveLock = NSRecursiveLock()
    private lazy var disposeBag = DisposeBag()
    private var _configPaymentsDisplay: [String: ConfigsDirectPayment] = [:]
    private var configPaymentsDisplay: [String: ConfigsDirectPayment] {
        get {
            return excute { return _configPaymentsDisplay }
        }
        
        set {
            excute { _configPaymentsDisplay = newValue }
        }
    }
    private var disposeDirectPayments: Disposable?
    
    func getConfigPayemnt() {
        let collectionRef = Firestore.firestore().collection(collection: .configData, .client, .paymentMethods)
        collectionRef.documents()
            .filterNil()
            .map { $0.compactMap { try? $0.decode(to: PaymentMethodConfig.self) }}
            .bind { [weak self](list) in
                self?.paymentMethodConfigs.accept(list)
        }.disposed(by: disposeBag)
    }
    
    func getPercentFee(paymentMethod: PaymentMethod) -> Float {
        let all = paymentMethodConfigs.value
        return all.filter { $0.id == paymentMethod.rawValue }.first?.cardFee ?? 0.0
    }
    
    func listPaymentMethodAllow(serviceId: Int) -> [NSInteger] {
        let all = paymentMethodConfigs.value
        return all.filter { $0.canApply(serviceId: serviceId) }.compactMap { $0.id }
    }
    
    func allowPaymentDirect(service: VatoServiceType) -> [PaymentCardDetail] {
        let all = paymentMethodConfigs.value
        let list = all.filter { $0.supportDirect(serviceId: service.rawValue) }.compactMap { $0.cardDetail }
        let s = Set(list)
        return Array(s)
    }
    
    func getConfigSuggestService() {
        let collectionRef = Firestore.firestore().collection(collection: .suggestServices)
        collectionRef.documents()
            .filterNil()
            .map { $0.compactMap { try? $0.decode(to: SuggestService.self) }}
            .bind { [weak self](list) in
                self?.suggestServices.accept(list)
            }.disposed(by: disposeBag)
    }
    
    private func requestConfigsDirectPayment() -> Observable<[DocumentSnapshot]> {
        let collectionRef = Firestore.firestore().collection("/ConfigData/Client/DirectPayments")
        let e1 = collectionRef.documents().filterNil()
        return e1
    }
    
    private func loadConfigsDirectPayment() {
        disposeDirectPayments?.dispose()
        let collectionRef = Firestore.firestore().collection("/ConfigData/Client/DirectPayments")
        let e1 = requestConfigsDirectPayment()
        let e2 = collectionRef.listenChanges().flatMap { (_)  in
            self.requestConfigsDirectPayment()
        }
        
        disposeDirectPayments = Observable.merge([e1, e2]).bind(onNext: weakify({ (list, wSelf) in
            var news = [String: ConfigsDirectPayment]()
            list.forEach { (snapshot) in
                news[snapshot.documentID] = try? ConfigsDirectPayment.toModel(from: snapshot.data())
            }
            wSelf.configPaymentsDisplay = news
        }))
    }
    
    func getSuggestServices(from serviceId: Int) -> [Int] {
        let all = suggestServices.value
        return all.filter { $0.id == serviceId }.first?.values ?? []
    }
    
    func getDefautConfig() {
        self.getConfigPayemnt()
        self.getConfigSuggestService()
        self.getConfigVisaAtm()
        self.loadConfigsDirectPayment()
    }
    
    func getConfigVisaAtm() {
        let documentRef = Firestore.firestore().documentRef(collection: .configData, storePath: .custom(path: "Client") , action: .read)
        documentRef
            .find(action: .get, json: nil, source: .server)
            .filterNil()
            .map { try? $0.decode(to: ConfigVisaATM.self) }
            .bind { (data) in
                guard let data = data else { return }
                self.isAllowVisa = data.allowAddCardVisaMaster
                self.isAllowAtm = data.allowAddCardAtm
        }.disposed(by: disposeBag)
    }
    
    func canAddCard(type: SwitchPaymentType) -> (visa: Bool, atm: Bool) {
        let dict = self.configPaymentsDisplay
        let config: ConfigsDirectPayment
        switch type {
        case .service(let service):
            config = dict["\(service.rawValue)"] ?? .default
        default:
            config = .default
        }
        return config.validAddCard()
    }
    
    func filterSource(from list:[PaymentCardDetail], type: SwitchPaymentType) -> (s1: [PaymentCardGroup], s2: [PaymentCardGroup], s3: [PaymentCardGroup]) {
        // Dividend list
        let dict = self.configPaymentsDisplay
        let config: ConfigsDirectPayment
        switch type {
        case .service(let service):
            config = dict["\(service.rawValue)"] ?? .default
        default:
            config = .default
        }
        
        let result = config.dividendGroup(from: list)
        return result
    }
}
