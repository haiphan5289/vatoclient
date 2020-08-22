//
//  ActionTicketTableView.swift
//  Vato
//
//  Created by HaiPhan on 10/10/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit
import MessageUI
import RxSwift


protocol ActionTicketDetailLisnters: class {
    func changeTicket()
    func cancelTicket()
    func rebookTicket()
    func supportTicket()
    func shareTicket()
}
class ActionTicketDetailVC: UITableViewController {
    @IBOutlet weak var lbChangeTicket: UILabel!
    @IBOutlet weak var lbCancelTicket: UILabel!
    @IBOutlet weak var lbRebookTicket: UILabel!
    @IBOutlet weak var lbSupportHotline: UILabel!
    @IBOutlet weak var lbShareTicket: UILabel!
    private lazy var disposeBag = DisposeBag()
    weak var listener: ActionTicketDetailLisnters?
    override func viewDidLoad() {
        super.viewDidLoad()
        localize()
        setupRX()
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    private func localize(){
        lbChangeTicket.text = Text.changeTicket.localizedText
        lbCancelTicket.text = Text.cancelTicket.localizedText
        lbRebookTicket.text = Text.reset.localizedText
        lbSupportHotline.text = Text.supportTicket.localizedText
        lbShareTicket.text = Text.nameShare.localizedText
    }
    private func setupRX(){
        tableView.rx.itemSelected.bind { [weak self] idx in
            if let type = ActionSelectTicket(rawValue: idx.row) {
                switch type {
                case .routeInfo:
                    fatalError("Please implement!!!")
                case .changeTicket:
                    self?.listener?.changeTicket()
                case .cancelTicket:
                    self?.listener?.cancelTicket()
                case .rebookTicket:
                    self?.listener?.rebookTicket()
                case .supportTicket:
                    self?.listener?.supportTicket()
                case .shareTicket:
                    self?.listener?.shareTicket()
                }
            }
        }.disposed(by: disposeBag)
    }
}
