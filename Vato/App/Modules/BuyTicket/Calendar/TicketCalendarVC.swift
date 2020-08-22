//  File name   : TicketCalendarVC.swift
//
//  Author      : Dung Vu
//  Created date: 10/1/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import FSCalendar
import RxSwift

protocol TicketCalendarPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var dateSelectedObser: Observable<Date> { get }
    func ticketCalendarMoveBack()
    func ticketCalendarSelectedDate(date: Date)
}

final class TicketCalendarVC: UIViewController, TicketCalendarPresentable, TicketCalendarViewControllable {
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: TicketCalendarPresentableListener?

    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }

    /// Class's private properties.
    @IBOutlet private weak var calendar: FSCalendar!
    private lazy var disposeBag = DisposeBag()
    @IBOutlet private weak var contiuneBtn: UIButton!
}

// MARK: View's event handlers
extension TicketCalendarVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension TicketCalendarVC {
}

// MARK: Class's private methods
private extension TicketCalendarVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        title = Text.dateDeparture.localizedText
        setupNavigation()
        
        // setup Calendar
        calendar.dataSource = self
        calendar.select(Date(), scrollToDate: false)
        calendar.appearance.titleFont = UIFont.systemFont(ofSize: 14, weight: .regular)
        calendar.appearance.headerTitleFont = UIFont.systemFont(ofSize: 14, weight: .medium)
        calendar.appearance.weekdayFont = UIFont.systemFont(ofSize: 14, weight: .medium)
        
        // button Countinue
        contiuneBtn.setTitle(Text.continue.localizedText, for: .normal)
    }
    
    private func setupRX() {
        contiuneBtn.rx.tap.bind { [weak self] in
            if let date = self?.calendar.selectedDate {
                self?.listener?.ticketCalendarSelectedDate(date: date)
            } else {
                AlertVC.showError(for: self, message: Text.chooseDateToContinue.localizedText)
            }
            }.disposed(by: disposeBag)
        
        self.listener?.dateSelectedObser
            .subscribe(onNext: {[weak self] (date) in
                self?.calendar.select(date, scrollToDate: true)
            }).disposed(by: disposeBag)
    }
    
    private func setupNavigation() {
        let navigationBar = navigationController?.navigationBar
        let bgImage = UIImage(named:"bg_navigationbar")?.stretchableImage(withLeftCapWidth: 0, topCapHeight: 0)
        navigationBar?.setBackgroundImage(bgImage, for: .default)
        navigationBar?.barTintColor = Color.orange
        navigationBar?.isTranslucent = false
        navigationBar?.tintColor = .white
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        let image = UIImage(named: "ic_arrow_back")
        let leftButton = UIButton(frame: CGRect(origin: .zero, size: image?.size ?? .zero))
        leftButton.setImage(image, for: .normal)
        leftButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
        let leftBarButton = UIBarButtonItem(customView: leftButton)
        navigationItem.leftBarButtonItem = leftBarButton
        leftButton.rx.tap.bind(onNext: weakify { wSelf in
            wSelf.listener?.ticketCalendarMoveBack()
        }).disposed(by: disposeBag)
    }
}

extension TicketCalendarVC: FSCalendarDataSource {
    func minimumDate(for calendar: FSCalendar) -> Date {
        return Date()
    }
}
