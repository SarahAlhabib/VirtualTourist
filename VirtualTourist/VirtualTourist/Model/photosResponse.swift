//
//  photosResponse.swift
//  VirtualTourist
//
//  Created by Nadyah Abdulrahman on 22/12/1441 AH.
//  Copyright © 1441 Sarah Alhabib. All rights reserved.
//

import Foundation

struct PhotoResponse: Decodable{
    let photos:photos
    let stat:String
}
struct photos: Decodable{
    let page:Int
    let pages:Int
    let perpage:Int
    let total: String
    let photo:[photo]
}

struct photo: Decodable{
    let id:String
    let owner:String
    let secret:String
    let server:String
    let farm:Int
    let title:String
    let ispublic:Int
    let isfriend:Int
    let isfamily:Int
}

extension photo{
    var url:URL {
        return URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_q.jpg")!
    }
}
