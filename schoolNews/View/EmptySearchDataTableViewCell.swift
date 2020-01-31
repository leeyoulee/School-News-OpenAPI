//
//  EmptySearchDataTableViewCell.swift
//  schoolNews
//
//  Created by 이유리 on 29/01/2020.
//  Copyright © 2020 이유리. All rights reserved.
//

import UIKit

class EmptySearchDataTableViewCell: UITableViewCell {
    static let identifier = String(describing: EmptySearchDataTableViewCell.self)
    
    @IBOutlet weak var resultLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .none
    }
    
}
