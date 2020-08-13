//
//  Network.swift
//  VirtualTourist
//
//  Created by Nadyah Abdulrahman on 22/12/1441 AH.
//  Copyright © 1441 Sarah Alhabib. All rights reserved.
//

import Foundation

class Network{
    
    static let key = "b99fe34c4a1fb29b280c306c2ab18889"
    
    static var random: UInt32 {
        return arc4random_uniform(5)+1
    }
    
    class func RequestPhotosURLs(lat: Double, lon: Double, completion: @escaping ([photo]?,Error?)->Void ){
        let urlString = "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(key)&tags=%20%20&accuracy=11&lat=\(lat)&lon=\(lon)&per_page=15&page=\(random)&format=json&nojsoncallback=1"
        let url = URL(string: urlString)
        
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil,error)
                }
                return
            }
            let decoder = JSONDecoder()
            do{
                let response = try decoder.decode(PhotoResponse.self, from: data)
                DispatchQueue.main.async {
                    if response.photos.photo.count>0{
                        completion(response.photos.photo,nil)
                    }else {
                        completion(nil,nil)
                    }
                }
                
            }
            catch{
                DispatchQueue.main.async {
                    completion(nil,error)
                    return
                }
            }
        }
        task.resume()
    }
    
    class func getPhotosData(lat: Double, lon: Double, completion: @escaping ([Data]?,Error?)->Void){
        var photosData:[Data] = []
        
        RequestPhotosURLs(lat: lat, lon: lon) { (photo, error) in
            guard let photos = photo else {
                DispatchQueue.main.async {
                    completion(nil,error)
                }
                return
            }
            let group = DispatchGroup()
            for photo in photos {
                group.enter()
                let task = URLSession.shared.dataTask(with: photo.url) { (data, response, error) in
                    if let data = data {
                        photosData.append(data)
                    }
                    group.leave()
                }
                task.resume()
            }
            group.notify(queue: .main) {
                if photosData.count > 0{
                    completion(photosData,nil)
                } else{
                    completion(nil,nil)
                }
            }
        }
    }
}



