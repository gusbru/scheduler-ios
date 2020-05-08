//
//  ListTableViewCell.swift
//  Scheduler
//
//  Created by Gustavo Brunetto on 2020-05-08.
//  Copyright © 2020 Gustavo Brunetto. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {

    @IBOutlet weak var subjectTitleLabel: UILabel!
    @IBOutlet weak var numbeOfCreditsLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
