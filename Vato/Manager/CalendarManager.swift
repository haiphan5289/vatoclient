//  File name   : CalendarManager.swift
//
//  Author      : Dung Vu
//  Created date: 10/15/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import EventKit
import RxSwift

final class CalendarManager {
    static let shared = CalendarManager()
    private lazy var eventStore : EKEventStore = EKEventStore()
    private func requestPermission(for type: EKEntityType) -> Observable<Void> {
        let status = EKEventStore.authorizationStatus(for: type)
        let createError: () -> Error = {
            let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorResourceUnavailable, userInfo: [NSLocalizedDescriptionKey: "Don't have permission"])
            return error
        }
        switch status {
        case .authorized:
            return Observable.just(())
        case .notDetermined:
            return Observable.create({ (s) -> Disposable in
                self.eventStore.requestAccess(to: type, completion: { (granted, e) in
                    if let e = e {
                        s.onError(e)
                    } else {
                        guard granted else {
                            return s.onError(createError())
                        }
                        
                        s.onNext(())
                        s.onCompleted()
                    }
                })
                return Disposables.create()
            })
        default:
            return Observable.error(createError())
        }
    }
    
    func setEvent(date: Date, title: String, notes: String?) -> Observable<Void> {
        return self.requestPermission(for: .event).flatMap({
            return Observable.create({ [weak self](s) -> Disposable in
                if let wSelf = self {
                    let event: EKEvent = EKEvent(eventStore: wSelf.eventStore)
                    event.title = title
                    event.startDate = date
                    event.endDate = date
                    event.notes = notes
                    event.calendar = wSelf.eventStore.defaultCalendarForNewEvents
                    do {
                        try wSelf.eventStore.save(event, span: .thisEvent)
                        s.onNext(())
                        s.onCompleted()
                    } catch {
                        s.onError(error)
                    }
                } else {
                    s.onCompleted()
                }
                
                return Disposables.create()
            })
        })
    }
    
    func remove(date: Date) -> Observable<Void>{
        return self.requestPermission(for: .event).flatMap({
            return Observable.create({ [weak self](s) -> Disposable in
                if let wSelf = self {
                    let p = wSelf.eventStore.predicateForEvents(withStart: date, end: date, calendars: nil)
                    let events = wSelf.eventStore.events(matching: p)
                    do {
                        try events.forEach {
                            try wSelf.eventStore.remove($0, span: .thisEvent)
                        }
                        s.onNext(())
                        s.onCompleted()
                    } catch {
                        s.onError(error)
                    }
                } else {
                    s.onCompleted()
                }
                return Disposables.create()
            })
        })
        
    }
}
