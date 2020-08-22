//
//  SearchLocationSuggestionCVC.swift
//  Vato
//
//  Created by Thai Le Quang on 7/23/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit

final class SearchLocationSuggestionCVC: UITableViewCell {
    /// Class's public properties.
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var addButton: UIButton!
    
    /// Class's private properties.
}

// MARK: Class's public methods
extension SearchLocationSuggestionCVC {
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        visualize()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        localize()
    }
}

// MARK: Class's private methods
private extension SearchLocationSuggestionCVC {
    private func localize() {
        // todo: Localize view's here.
    }
    
    private func visualize() {
    }
}
