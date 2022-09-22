//
//  ClientCell.swift
//  MyToDoList
//
//  Created by user185077 on 3/17/21.
//  Copyright © 2021 ASN GROUP LLC. All rights reserved.
//

import DropDown
import UIKit

class ClientCell: DropDownCell {

    @IBOutlet var clientImage: UIImageView!
    @IBOutlet var clientName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        clientImage.contentMode = .scaleAspectFit
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
