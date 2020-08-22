//  File name   : BookingStream.swift
//
//  Author      : Vato
//  Created date: 9/20/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import RxSwift

enum BookingState: Equatable {
    case none
    case home
    case bookingConfirm
    case quickBookingConfirm

    case searchLocation(suggestMode: LocationType)
    case pickLocation(suggestMode: LocationType)

    case editSearchLocation(suggestMode: LocationType)
    case editPickLocation(suggestMode: LocationType)

    case editQuickBookingSearchLocation
    case editQuickBookingPickLocation
    
    case homeMapSearch(suggestMode: LocationType)
    case searchAddress(type: SearchType, address: AddressProtocol?)
    
    var next: BookingState? {
        switch self {
        case .searchLocation(let suggestMode):
            switch suggestMode{
            case .destination1:
                return .bookingConfirm
            case .origin:
                return .home
            }
        case .searchAddress(let type, _):
            switch type {
            case .booking(let origin, _, _, _):
                return origin ? .home : .bookingConfirm
            default:
                #if DEBUG
                    assert(false, "Please implement")
                #else
                    return nil
                #endif
            }
        case .editSearchLocation:
            return .bookingConfirm
        default:
            return nil
        }
        return nil
    }
    
    var previous: BookingState? {
        switch self {
        case .searchLocation:
            return .home
        case .editSearchLocation:
            return .bookingConfirm
        default:
            return nil
        }
    }
    
    
    static func ==(lhs: BookingState, rhs: BookingState) -> Bool {
        switch (lhs, rhs) {
        case (.home, .home):
            return true
        case (.homeMapSearch(let t1), .homeMapSearch(let t2)):
            return t1 == t2
        default:
            return false
        }
    }
}

enum LocationType: Int {
    case origin
    case destination1
}

// MARK: Immutable stream
protocol BookingStream: class {
    var mode: Observable<BookingState> { get }
    var booking: Observable<Booking> { get }
    var shouldReloadPromotion: Observable<Bool> { get }

    var promotion: Observable<PromotionModel?> { get }
    var onlineDrivers: Observable<[SearchDriver]> { get }
    
    func updateBookByService(book: Booking)
    func updateDefaultNote(note: String?)
    func updateDefaultServiceMore(list: [AdditionalServices]?)
}

// MARK: Mutable stream
protocol MutableBookingStateStream: class {
    /// Allow to switch between each mode.
    ///
    /// - Parameter mode: next mode to switch
    func changeMode(mode: BookingState)
}

protocol MutableBookingStream: BookingStream, MutableBookingStateStream {
    func reset()

    func updatePromotion(promotion: PromotionModel?)
    func reloadPromotion()
    func updateBooking(onlineDrivers: [SearchDriver])

    func updateBooking(originAddress: AddressProtocol)
    func updateBooking(destinationAddress1: AddressProtocol)
    
    
    func updateDefaultService(service: ServiceCanUseProtocol)
}

// MARK: Default stream implementation
final class BookingStreamImpl: MutableBookingStream {
    func updateBookByService(book: Booking) {
        self.serviceDefault = book.defaultSelect.service
        self.booking_ = book
    }
    
    /// Class's public properties.
    var mode: Observable<BookingState> {
        return modeSubject.asObservable()
    }

    var booking: Observable<Booking> {
        return bookingSubject.asObservable().observeOn(MainScheduler.instance)
    }

    var promotion: Observable<PromotionModel?> {
        return promotionSubject.asObservable()
    }
    var shouldReloadPromotion: Observable<Bool> {
        return reloadPublisher.asObservable()
    }

    var onlineDrivers: Observable<[SearchDriver]> {
        return onlineDriversSubject.asObservable()
    }
    
    var serviceDefault: VatoServiceType?

    private let disposeBag = DisposeBag()
    init() {
        bookingSubject.bind { b in
            printDebug(" Next value \(b.originAddress.coordinate.value)")
        }.disposed(by: disposeBag)
    }

    // MARK: MutableBookingStream's members
    func changeMode(mode: BookingState) {
        switch mode {
        case .quickBookingConfirm:
            guard let booking = booking_ else {
                return
            }
            booking_ = Booking(tripType: BookService.quickBook, originAddress: booking.originAddress, destinationAddress1: nil)
            modeSubject.onNext(.quickBookingConfirm)

        default:
            modeSubject.onNext(mode)
        }
    }

    func reloadPromotion() {
        reloadPublisher.on(.next(true))
    }

    func reset() {
        guard let booking = booking_ else {
            return
        }
        mode.take(1).bind { [weak self](state) in
            switch state {
            case .home:
                self?.booking_ = Booking(tripType: BookService.fixed, originAddress: booking.originAddress, destinationAddress1: nil)
                self?.promotion_ = nil
                
            default:
                self?.booking_ = booking
            }
        }.disposed(by: disposeBag)
        
    }

    func updatePromotion(promotion: PromotionModel?) {
        promotion_ = promotion

        let data = promotion?.data?.data
        let predecate = data?.promotionPredicates.first

        // Will not execute if there is no booking model
        guard let booking = booking_ else {
            return
        }
        var shouldSendEvent = false

        if let paymentType = predecate?.paymentType {
            let paymentMethod = PaymentMethod(paymentType - 1)
            booking.defaultSelect.paymentMethod = paymentMethod
            shouldSendEvent = true
        }

        if let vatoServiceType = predecate?.serviceCanUse().first {
            booking.defaultSelect.service = vatoServiceType
            shouldSendEvent = true
        }

        if shouldSendEvent {
            let newBooking = Booking(tripType: booking.tripType,
                                     originAddress: booking.originAddress,
                                     destinationAddress1: booking.destinationAddress1)

            newBooking.defaultSelect.copy(from: booking.defaultSelect)
            booking_ = newBooking
        }
    }

    func updateBooking(onlineDrivers: [SearchDriver]) {
        onlineDriversSubject.on(.next(onlineDrivers))
    }

    func updateBooking(originAddress: AddressProtocol) {
        guard let booking = booking_ else {
            booking_ = Booking(tripType: BookService.fixed, originAddress: originAddress, destinationAddress1: nil)
            return
        }
        
        defer {
            UserManager.instance.update(coordinate: booking.originAddress.coordinate)
        }

        let newBooking = Booking(tripType: booking.tripType,
                                 originAddress: originAddress,
                                 destinationAddress1: booking.destinationAddress1)

        newBooking.defaultSelect.copy(from: booking.defaultSelect)
        booking_ = newBooking
    }

    func updateBooking(destinationAddress1: AddressProtocol) {
        guard let booking = booking_ else {
            return
        }
        
        defer {
            UserManager.instance.update(coordinate: booking.originAddress.coordinate)
        }
        
        let newBooking = Booking(tripType: booking.tripType,
                                 originAddress: booking.originAddress,
                                 destinationAddress1: destinationAddress1)
        newBooking.defaultSelect.copy(from: booking.defaultSelect)
        booking_ = newBooking
    }
    
    func updateDefaultService(service: ServiceCanUseProtocol) {
        guard let booking = booking_ else {
            return
        }
        
        let newBooking = Booking(tripType: booking.tripType,
                                 originAddress: booking.originAddress,
                                 destinationAddress1: booking.destinationAddress1)
        
        newBooking.defaultSelect.service = service.service.serviceType
        newBooking.defaultSelect.note = booking.defaultSelect.note
        booking_ = newBooking
    }
    
    func updateDefaultNote(note: String?) {
        booking_?.defaultSelect.note = note
    }
    
    func updateDefaultServiceMore(list: [AdditionalServices]?) {
        booking_?.defaultSelect.arrayServiceMore = list
    }
    
    /// Class's private properties.
    private let reloadPublisher = PublishSubject<Bool>()
    private let onlineDriversSubject = ReplaySubject<[SearchDriver]>.create(bufferSize: 1)
    private let modeSubject = ReplaySubject<BookingState>.create(bufferSize: 1)

    private let bookingSubject = ReplaySubject<Booking>.create(bufferSize: 1)
    private var booking_: Booking? {
        didSet {
            guard let booking = booking_ else {
                return
            }
            if booking.defaultSelect.service == nil,
                let s = self.serviceDefault
            {
                booking.defaultSelect.service = s
            }

            bookingSubject.on(.next(booking))
        }
    }

    private let promotionSubject = ReplaySubject<PromotionModel?>.create(bufferSize: 1)
    private var promotion_: PromotionModel? {
        didSet {
            promotionSubject.onNext(promotion_)
        }
    }
}
