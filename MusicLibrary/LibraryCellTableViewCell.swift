//
//  LibraryCellTableViewCell.swift
//  MusicLibrary
//
//  Created by Jena Grafton on 10/11/16.
//  Copyright © 2016 Bella Voce Productions. All rights reserved.
//

import UIKit

class LibraryCellTableViewCell: UITableViewCell {
    
    @IBOutlet var bookImageView: UIImageView!
    @IBOutlet var titleLable: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
