//
//  Group.swift
//  AppForVK
//
//  Created by Mikhail Semerikov on 07/02/2019.
//  Copyright © 2019 Семериков Михаил. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

class Group: Object {
    
    //MARK: - Basic fields
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var screen_name: String = ""
    @objc dynamic var is_closed: Int = 0
    @objc dynamic var deactivated: String = ""
    @objc dynamic var type: String = ""
    @objc dynamic var is_admin: Int = 0
    @objc dynamic var is_member: Int = 0
    @objc dynamic var is_advertiser: Int = 0
    @objc dynamic var photo_50: String = ""
    @objc dynamic var photo_100: String = ""
    @objc dynamic var photo_200: String = ""
    
    convenience init(json: JSON) {
        self.init()
        self.id = json["id"].intValue
        self.name = json["name"].stringValue
        self.screen_name = json["screen_name"].stringValue
        self.deactivated = json["deactivated"].stringValue
        self.is_closed = json["is_closed"].intValue
        self.type = json["type"].stringValue
        self.is_admin = json["is_admin"].intValue
        self.is_member = json["is_member"].intValue
        self.is_advertiser = json["is_advertiser"].intValue
        self.photo_50 = json["photo_50"].stringValue
        self.photo_100 = json["photo_100"].stringValue
        self.photo_200 = json["photo_200"].stringValue
    }
}
