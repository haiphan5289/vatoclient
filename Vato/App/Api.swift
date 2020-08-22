import Alamofire
import Foundation
import FwiCore
import FwiCoreRX
import RxCocoa
import RxSwift

struct API {
    static let googleDomain = "https://maps.googleapis.com"
    static let vatoDomain: String = {
        #if DEBUG
            return "http://dev.vato.io:9000/api" //"http://vato.myvnc.com:9000/api"
        #else
            return "https://api.vato.io/api"
        #endif
    }()
}

protocol APIRequestProtocol {
    var path: String { get }
    var params: [String: Any]? { get }
    var header: [String: String]? { get }
}

//https://vatoteam.atlassian.net/wiki/spaces/PRO/pages/370081829/API+cho+promotion
enum VatoAPIRouter: APIRequestProtocol {
    case getBalance(authToken: String)
    case searchDriver(authToken: String, coordinate: CLLocationCoordinate2D, service: Int)
    case promotion(authToken: String, code: String)
    case promotionCancel(authToken: String, promotionToken: String)
    case promotionList(authToken: String)
    case promotionDetail(authToken: String, promotionId: Int)
    case promotionSearch(authToken: String, code: String)
    case promotionNow(authToken: String, zoneId: Int)
    case updateDeviceToken(authToken: String, firebaseID: String, phoneNumber: String, deviceToken: String)     // FIX FIX FIX: The same as update account

    var path: String {
        switch self {
        case .getBalance:
            return "\(API.vatoDomain)/balance/get"

        case .searchDriver:
            return "\(API.vatoDomain)/user/search"

        case .promotion:
            return "\(API.vatoDomain)/promotion/apply_code"

        case .promotionCancel:
            return "\(API.vatoDomain)/promotion/cancel_promotion_token"

        case .promotionList:
            return "\(API.vatoDomain)/promotion/list_promotion"
            
        case .promotionDetail:
            return "\(API.vatoDomain)/manifest/get"
        
        case .promotionSearch:
            return "\(API.vatoDomain)/promotion/search"
            
        case .promotionNow:
            return "\(API.vatoDomain)/manifest/now"

        case .updateDeviceToken:
            return "\(API.vatoDomain)/user/update_account"
        }
    }

    var params: [String: Any]? {
        switch self {
        case .getBalance:
            return nil

        case .searchDriver(_, let coordinate, let service):
            return [
                "lat": coordinate.latitude,
                "lon": coordinate.longitude,
                "distance": 5,
                "service": service,
                "isFavorite": false,
                "page": 0,
                "size": 10
            ]

        case .promotion(_, let code):
            return ["code": code]

        case .promotionCancel(_, let promotionToken):
            return ["promotionToken":promotionToken]

        case .promotionList:
            return nil
        
        case .promotionDetail(_ , let promotionId):
            return ["id": promotionId]
            
        case .promotionSearch( _, let code):
            return ["code": code]
            
        case .promotionNow(_ , let zoneId):
            return ["zoneId": zoneId]

        case .updateDeviceToken(_, let firebaseID, let phoneNumber, let deviceToken):
            return [
                "phoneNumber":phoneNumber,
                "firebaseId":firebaseID,
                "deviceToken":deviceToken
            ]
        }
    }

    var header: [String: String]? {
        switch self {
        case .getBalance(let token):
            var h: [String: String] = [:]
            h["x-access-token"] = token
            return h

        case .searchDriver(let token, _, _):
            var h: [String: String] = [:]
            h["x-access-token"] = token
            return h

        case .promotion(let token, _):
            var h: [String: String] = [:]
            h["x-access-token"] = token
            h["Cache-Control"] = "min-fresh=10"
            h["Content-Type"] = "application/json"
            return h

        case .promotionCancel(let token, _):
            var h: [String: String] = [:]
            h["x-access-token"] = token
            h["Content-Type"] = "application/json"
            return h

        case .promotionList(let token):
            var h: [String: String] = [:]
            h["x-access-token"] = token
            h["Cache-Control"] = "min-fresh=10"
            h["Content-Type"] = "application/json"
            return h
        
        case .promotionDetail(let token, _):
            var h: [String: String] = [:]
            h["x-access-token"] = token
            h["Cache-Control"] = "min-fresh=10"
            h["Content-Type"] = "application/json"
            return h
            
        case .promotionSearch(let token, _):
            var h: [String: String] = [:]
            h["x-access-token"] = token
            h["Cache-Control"] = "min-fresh=10"
            h["Content-Type"] = "application/json"
            return h
        
        case .promotionNow(let token, _):
            var h: [String: String] = [:]
            h["x-access-token"] = token
            h["Cache-Control"] = "min-fresh=10"
            h["Content-Type"] = "application/json"
            return h

        case .updateDeviceToken(let token, _, _, _):
            var h: [String: String] = [:]
            h["x-access-token"] = token
            h["Content-Type"] = "application/json"
            return h
        }
    }
}

fileprivate final class VATOCustomServerTrustPolicyManager: ServerTrustPolicyManager {
    override func serverTrustPolicy(forHost host: String) -> ServerTrustPolicy? {
        #if DEBUG
            return super.serverTrustPolicy(forHost: host)
        #else
            guard API.vatoDomain.contains(host) else {
                return super.serverTrustPolicy(forHost: host)
            }
        
            return ServerTrustPolicy.pinPublicKeys(publicKeys: ServerTrustPolicy.publicKeys(), validateCertificateChain: true, validateHost: true)
        #endif
    }
}

struct Requester {
    private static let apiTimeout: TimeInterval = 30
    private static let manager: SessionManager = SessionManager(serverTrustPolicyManager: VATOCustomServerTrustPolicyManager(policies: [:]))
    static func request(using router: APIRequestProtocol,
                        method m: HTTPMethod = .get,
                        encoding e: ParameterEncoding = URLEncoding.default) -> Observable<(HTTPURLResponse, Data)> {
        return Observable.create({ (s) -> Disposable in
            let task = manager.request(router.path, method: m, parameters: router.params, encoding: e, headers: router.header)
            task.responseData { data in
                let result = data.result
                guard let response = data.response else {
                    let e = NSError(domain: NSURLErrorDomain, code: NSURLErrorBadServerResponse, userInfo: nil)
                    s.onError(e)
                    return
                }
                switch result {
                case .success(let value):
                    s.onNext((response, value))
                    s.onCompleted()
                case .failure(let e):
                    s.onError(e)
                }
            }
            task.resume()
            return Disposables.create {
                task.cancel()
            }
        }).observeOn(SerialDispatchQueueScheduler(qos: .background)).timeout(apiTimeout, scheduler: SerialDispatchQueueScheduler(qos: .background))
    }

    static func requestDTO<E: Decodable>(using router: APIRequestProtocol,
                                         method m: HTTPMethod = .get,
                                         encoding e: ParameterEncoding = URLEncoding.`default`,
                                         block: ((JSONDecoder) -> Void)? = nil) -> Observable<(HTTPURLResponse, E)> {
        return self.request(using: router, method: m, encoding: e).map { ($0.0, try E.toModel(from: $0.1, block: block)) }
    }
}
