//
//  ServerCell.swift
//  VPNDemo1
//
//  Created by MacBook Pro on 1/14/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

import UIKit

class ServerCell: UITableViewCell {

    @IBOutlet weak var connectionButton: UIButton!
    @IBOutlet weak var serverName: UILabel!
   

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}
