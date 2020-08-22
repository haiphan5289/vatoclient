//
//  TicketUserInfomationDetail.swift
//  Vato
//
//  Created by vato. on 10/9/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit
import RxSwift

class TicketUserInfomationDetail: UITableViewController {
    
    @IBOutlet weak var nameTextLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var mailLabel: UILabel!
    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var phone2Label: UILabel!
    @IBOutlet weak var phone2TextField: UITextField!
    @IBOutlet weak var agreeConditionLabel: UILabel!
    @IBOutlet weak var buyTicketForOtherLabel: UILabel!
    
    private lazy var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localize()
        visualize()

    }

    // MARK: - Table view data source, delegate
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }

}

private extension TicketUserInfomationDetail {
    
    private func localize() {
        nameTextLabel.text = Text.fullname.localizedText
        nameTextField.placeholder = Text.inputFullname.localizedText
        phoneLabel.text = Text.phoneNumber.localizedText
        phoneTextField.placeholder = Text.inputPhoneNumber.localizedText
        mailLabel.text = Text.email.localizedText
        mailTextField.placeholder = Text.inputEmailAdress.localizedText
        phone2Label.text = Text.phoneNumberSecond.localizedText
        phone2TextField.placeholder = Text.inputPhoneNumberSecond.localizedText
        agreeConditionLabel.text = Text.haveAcceptTermWhenPressContinue.localizedText
        buyTicketForOtherLabel.text = Text.buyTicketSomeoneElse.localizedText
    }
    
    private func visualize() {
        // todo: Visualize view's here.
        title = Text.buyTicket.localizedText
        tableView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
    }
    
    private func setupRX() {
    }
}
