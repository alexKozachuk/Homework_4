//
//  CollectionViewCell.swift
//  Homework_4
//
//  Created by Sasha on 20/01/2021.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dayTempLabel: UILabel!
    @IBOutlet weak var nightTempLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
