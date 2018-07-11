//
//  BoxScoreCollectionViewCell.swift
//  mySports
//
//  Created by Kapil Rathan on 4/20/18.
//  Copyright © 2018 Kapil Rathan. All rights reserved.
//

import UIKit

class BoxScoreCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var teamPosition: UILabel!
    @IBOutlet weak var bottomDivider: UILabel!
    @IBOutlet weak var topDivider: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
