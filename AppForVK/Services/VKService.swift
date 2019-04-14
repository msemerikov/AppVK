//
//  VKService.swift
//  AppForVK
//
//  Created by Mikhail Semerikov on 06/02/2019.
//  Copyright © 2019 Семериков Михаил. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class VKService {
    let baseUrl = "https://api.vk.com"
    let versionAPI = "5.92"
    
    static let sharedManager: SessionManager = {
        let config = URLSessionConfiguration.default
        
        config.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        config.timeoutIntervalForRequest = 40
        
        let manager = Alamofire.SessionManager(configuration: config)
        return manager
    }()
    
    func loadVKFriends(for user: Int, completion: (([User]?, Error?) -> Void)? = nil) {
        let path = "/method/friends.get"
        let parameters: Parameters = [
            "fields": "nickname, domain, online, deactivated, photo_50, sex",
            "access_token": Session.shared.token,
            "v": versionAPI
        ]
        let url = baseUrl + path
        
        VKService.sharedManager.request(url, method: .get, parameters: parameters).responseJSON(queue: .global(qos: .userInteractive)) { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let users = json["response"]["items"].arrayValue.map { User(json: $0) }
                completion?(users, nil)
            case .failure(let error):
                completion?(nil, error)
            }
        }
    }
    
    func loadVKPhotos(for user: Int, completion: (([Photo]?, Error?) -> Void)? = nil) {
        let path = "/method/photos.getAll"
    
        let parameters: Parameters = [
            "owner_id": user,
            "extended": "0",
            "access_token": Session.shared.token,
            "v": versionAPI,
            "offset": "0",
            "count": "20",
            "photo_sizes": "0",
            "no_service_albums": "0",
            "need_hidden": "0",
            "skip_hidden": "1"
        ]
        let url = baseUrl + path
        
        VKService.sharedManager.request(url, method: .get, parameters: parameters).responseJSON(queue: .global(qos: .userInteractive)) { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let photos = json["response"]["items"].arrayValue.map { Photo(json: $0) }
                completion?(photos, nil)
            case .failure(let error):
                completion?(nil, error)
            }
        }
    }
    
    func loadVKGroups(for user: Int, completion: (([Group]?, Error?) -> Void)? = nil) {
        let path = "/method/groups.get"
        let parameters: Parameters = [
            "user_id": user,
            "extended": "1",
            "access_token": Session.shared.token,
            "v": versionAPI
        ]
        let url = baseUrl + path
        
        VKService.sharedManager.request(url, method: .get, parameters: parameters).responseJSON(queue: .global(qos: .userInteractive)) { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let groups = json["response"]["items"].arrayValue.map { Group(json: $0) }
                completion?(groups, nil)
            case .failure(let error):
                completion?(nil, error)
            }
        }
    }
    
    func searchVKGroups(q: String, completion: (([Group]?, Error?) -> Void)? = nil) {
        let path = "/method/groups.search"
        let parameters: Parameters = [
            "q": q,
            "count": 30,
            "access_token": Session.shared.token,
            "v": versionAPI,
            "type": "group"
        ]
        let url = baseUrl + path
        
        VKService.sharedManager.request(url, method: .get, parameters: parameters).responseJSON(queue: .global(qos: .userInteractive)) { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let groups = json["response"]["items"].arrayValue.map { Group(json: $0) }
                completion?(groups, nil)
            case .failure(let error):
                completion?(nil, error)
            }
        }
    }
    
    func leaveGroup(for group: Int) {
        let path = "/method/groups.leave"
        let parameters: Parameters = [
            "group_id": group,
            "access_token": Session.shared.token,
            "v": versionAPI
        ]
        let url = baseUrl + path
        
        VKService.sharedManager.request(url, method: .get, parameters: parameters).responseJSON(queue: .global(qos: .userInteractive)) { response in }
    }
    
    func joinGroup(for group: Int) {
        let path = "/method/groups.join"
        let parameters: Parameters = [
            "group_id": group,
            "access_token": Session.shared.token,
            "v": versionAPI
        ]
        let url = baseUrl + path
        
        VKService.sharedManager.request(url, method: .get, parameters: parameters).responseJSON(queue: .global(qos: .userInteractive)) { response in }
    }
    
    func loadVKNewsFeed(startFrom: String, completion: (([News]?, [Owner]?, [Owner]?, String?, Error?) -> Void)? = nil) {
        let path = "/method/newsfeed.get"
        let parameters: Parameters = [
            "filters": "post,photo",
            "start_from": startFrom,
            "count": 30,
            "access_token": Session.shared.token,
            "v": versionAPI
        ]
        let url = baseUrl + path
        
        VKService.sharedManager.request(url, method: .get, parameters: parameters).responseJSON(queue: .global(qos: .userInteractive)) { response in
            print(VKService.sharedManager.request(url, method: .get, parameters: parameters))
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                var news = [News]()
                var users = [Owner]()
                var groups = [Owner]()
                var nextFrom = ""
                
                let jsonGroup = DispatchGroup()
                DispatchQueue.global().async(group: jsonGroup) {
                    news = json["response"]["items"].arrayValue.map { News(json: $0) }
                }
                DispatchQueue.global().async(group: jsonGroup) {
                    users = json["response"]["profiles"].arrayValue.map { Owner(json: $0) }
                }
                DispatchQueue.global().async(group: jsonGroup) {
                    groups = json["response"]["groups"].arrayValue.map { Owner(json: $0) }
                }
                DispatchQueue.global().async(group: jsonGroup) {
                    nextFrom = json["response"]["next_from"].stringValue
                    Session.shared.nextFrom = nextFrom
                }
                jsonGroup.notify(queue: DispatchQueue.main) {
                    completion?(news, users, groups, nextFrom, nil)
                }
            case .failure(let error):
                completion?(nil, nil, nil, nil, error)
            }
        }
    }
    
    enum likeAction: String {
        case addLike = "/method/likes.add"
        case deleteLike = "/method/likes.delete"
    }
    
    enum likeType: String {
        case post = "post"
    }
    
    func addOrDeleteLike(likeType: likeType, owner_id: Int, item_id: Int, action: likeAction) {
        let path = action.rawValue
        
        let parameters: Parameters = [
            "type": likeType.rawValue,
            "owner_id": owner_id,
            "item_id": item_id,
            "access_token": Session.shared.token,
            "v": versionAPI
        ]
        
        let url = baseUrl + path
        
        VKService.sharedManager.request(url, method: .get, parameters: parameters).responseJSON(queue: .global(qos: .userInteractive)) { response in }
            
    }
    
    func getVideo(q: String, completion: (([Video]?, Error?) -> Void)? = nil) {
        let path = "/method/video.get"
        let parameters: Parameters = [
            "videos": q,
            "access_token": Session.shared.token,
            "v": versionAPI
        ]
        let url = baseUrl + path
        
        VKService.sharedManager.request(url, method: .get, parameters: parameters).responseJSON(queue: .global(qos: .userInteractive)) { response in
            print(VKService.sharedManager.request(url, method: .get, parameters: parameters))
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                var videos = [Video]()
                videos = json["response"]["items"].arrayValue.map { Video(json: $0) }
                completion?(videos, nil)
            case .failure(let error):
                completion?(nil, error)
            }
        }
    }
}
