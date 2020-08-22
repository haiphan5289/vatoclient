//  File name   : PhoneCell.swift
//
//  Author      : Vato
//  Created date: 10/19/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Eureka
import UIKit
import FwiCore
import RxSwift
import SnapKit

final class PhoneCell: MasterFieldCell<String>, CellType {
    public override func setup() {
        super.setup()
        height = { 80.0 }
        textField.keyboardType = .phonePad

        borderImageView.snp.removeConstraints()
        titleLabel.snp.removeConstraints()
        textField.snp.removeConstraints()

        flagImageView >>> contentView >>> {
            $0.contentMode = .scaleAspectFit
            $0.snp.makeConstraints {
                $0.leading.equalToSuperview()
                $0.top.equalToSuperview()
                $0.size.equalTo(CGSize(width: 30, height: 40))
            }
        }
        dialCodeLabel >>> contentView >>> {
            $0.text = "(+84)"
            $0.font = EurekaConfig.detailFont
            $0.textColor = EurekaConfig.detailColor
            $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            $0.snp.makeConstraints {
                $0.leading.equalTo(flagImageView.snp.trailing).offset(10.0)
                $0.top.equalTo(flagImageView.snp.top)
                $0.bottom.equalTo(flagImageView.snp.bottom)
            }
        }

        if let field = textField {
            field >>> {
                $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
                $0.snp.makeConstraints {
                    $0.leading.equalTo(dialCodeLabel.snp.trailing).offset(15.0)
                    $0.trailing.equalToSuperview()
                    $0.top.equalTo(flagImageView.snp.top)
                    $0.bottom.equalTo(flagImageView.snp.bottom)
                }
            }

            borderImageView >>> { $0.snp.makeConstraints {
                $0.leading.equalTo(flagImageView.snp.leading)
                $0.trailing.equalTo(field.snp.trailing)
                $0.top.equalTo(field.snp.bottom)
                $0.height.equalTo(2.0)
            }}
        }

        titleLabel >>> {
            $0.textAlignment = .center
            $0.snp.makeConstraints {
                $0.leading.equalTo(borderImageView.snp.leading)
                $0.trailing.equalTo(borderImageView.snp.trailing)
                $0.top.equalTo(borderImageView.snp.bottom).offset(15.0)
                $0.bottom.equalToSuperview()
            }
        }
    }

    /// Class's private properties
    private lazy var flagImageView = UIImageView(image: #imageLiteral(resourceName: "flag_vietnam"))
    private lazy var dialCodeLabel = UILabel()
}
