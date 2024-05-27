//
//  NotTODOTableViewCell.swift
//  NotTODO

import UIKit

class NotTODOTableViewCell: UITableViewCell {
    @IBOutlet  var titleLabel: UILabel!
    @IBOutlet  var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
