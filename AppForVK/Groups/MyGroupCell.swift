//
//  MyGroupCell.swift
//  AppForVK
//
//  Created by Семериков Михаил on 26.12.2018.
//  Copyright © 2018 Семериков Михаил. All rights reserved.
//

import UIKit
import Kingfisher

class MyGroupCell: UITableViewCell {

    @IBOutlet weak var myGroupName: UILabel!
    @IBOutlet weak var myGroupImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    public func configure(with group: Group) {
        myGroupName.text = group.name
        let iconUrl = group.photo_50
        myGroupImage.kf.setImage(with: URL(string: iconUrl))
    }

}
