//  File name   : ResultScanInteractor.swift
//
//  Author      : vato.
//  Created date: 9/30/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

enum ResultScanType {
    case success(resultScal: ScanQRResult)
    case userCodeWasExist
    case phoneNotMatch
    case ticketWasUsed
    case ticketNotFound
    case masterCodeDayExceed
    case masterCodeExceed
    case masterCodeInactive
    case masterCodeInvalid
    case other
    
    struct Config {
        static let USER_CODE_WAS_EXIST = "USER_CODE_WAS_EXIST"
        static let PHONE_NOT_MATCH = "PHONE_NOT_MATCH"
        static let TICKET_WAS_USED = "TICKET_WAS_USED"
        static let TICKET_NOT_FOUND = "TICKET_NOT_FOUND"
        static let MASTER_CODE_DAY_EXCEED = "MASTER_CODE_DAY_EXCEED"
        static let MASTER_CODE_EXCEED = "MASTER_CODE_EXCEED"
        static let MASTER_CODE_INACTIVE = "MASTER_CODE_INACTIVE"
        static let MASTER_CODE_INVALID = "MASTER_CODE_INVALID"
    }
    
    static func createType(message: String?) -> ResultScanType {
        if Config.USER_CODE_WAS_EXIST == message {
            return .userCodeWasExist
        }
        if Config.PHONE_NOT_MATCH == message {
            return .phoneNotMatch
        }
        if Config.TICKET_WAS_USED == message {
            return .ticketWasUsed
        }
        if Config.TICKET_NOT_FOUND == message {
            return .ticketNotFound
        }
        if Config.MASTER_CODE_DAY_EXCEED == message {
            return .masterCodeDayExceed
        }
        if Config.MASTER_CODE_EXCEED == message {
            return .masterCodeExceed
        }
        if Config.MASTER_CODE_INACTIVE == message {
            return .masterCodeInactive
        }
        if Config.MASTER_CODE_INVALID == message {
            return .masterCodeInvalid
        }
        return .other
    }
    
    func getMessage() -> String {
        switch self {
        case .success(_):
            return Text.congratulationsScanOffer.localizedText
        case .userCodeWasExist:
            return Text.thisUserCreatedUsingCode.localizedText
        case .phoneNotMatch:
            return Text.thePhoneNumberDoesNotMatchTheTicketNumber.localizedText
        case .ticketWasUsed:
            return Text.ticketCodeUsed.localizedText
        case .ticketNotFound:
            return Text.wrongTicketCode.localizedText
        case .masterCodeDayExceed:
            return Text.maximumNumberOfCodesReceived.localizedText
        case .masterCodeExceed:
            return Text.thePromotionCodeHasRunOut.localizedText
        case .masterCodeInactive:
            return Text.promotionTimeout.localizedText
        case .masterCodeInvalid:
            return Text.thereAreNoPromotions.localizedText
        case .other:
            return Text.thereAreNoPromotions.localizedText
        }
    }
    
    func getTitle() -> String {
        switch self {
        case .success(_):
            return Text.scanCodeSuccessful.localizedText
        default:
            return Text.unsuccessful.localizedText
        }
    }
    
    func getImage() -> UIImage? {
        switch self {
        case .success(_):
            return UIImage(named: "ic_qr_promotion")
        default:
            return UIImage(named: "ic_qr_error")
        }
    }
}

protocol ResultScanRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol ResultScanPresentable: Presentable {
    var listener: ResultScanPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol ResultScanListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func resultScanMoveBack()
    func resultScanShowPromotions()
}

final class ResultScanInteractor: PresentableInteractor<ResultScanPresentable> {
    /// Class's public properties.
    weak var router: ResultScanRouting?
    weak var listener: ResultScanListener?

    /// Class's constructor.
    init(presenter: ResultScanPresentable,
                  resultScanType: ResultScanType) {
        super.init(presenter: presenter)
        presenter.listener = self
        _resultScanType.onNext(resultScanType)
    }

    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        // todo: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }

    /// Class's private properties.
    private lazy var _resultScanType = ReplaySubject<ResultScanType>.create(bufferSize: 1)
}

// MARK: ResultScanInteractable's members
extension ResultScanInteractor: ResultScanInteractable {
}

// MARK: ResultScanPresentableListener's members
extension ResultScanInteractor: ResultScanPresentableListener {
    var resultScanType: Observable<ResultScanType> {
        return _resultScanType.asObserver()
    }
    
    func resultScanMoveBack() {
        listener?.resultScanMoveBack()
    }
    
    func resultScanShowPromotions() {
        listener?.resultScanShowPromotions()
    }
    
}

// MARK: Class's private methods
private extension ResultScanInteractor {
    
    private func setupRX() {
        // todo: Bind data stream here.
    }
}
