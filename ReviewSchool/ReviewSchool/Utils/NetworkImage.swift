//
//  ImageLoader.swift
//  ReviewSchool
//
//  Created by Cao Phúc on 16/01/2021.
//

import UIKit

class NetworkImage {
    static let shared = NetworkImage()
    var cache = NSCache<NSString, UIImage>()
    
    private init(){}
    
    func download(url: URL, completion: @escaping (UIImage?) -> ()){
        if let cachedImage = cache.object(forKey: url.absoluteString as NSString) {
            completion(cachedImage)
            return
        }
        URLSession.shared.dataTask(with: url) {(data, response, error) in
            if let data = data, let image = UIImage(data: data) {
                self.cache.setObject(image, forKey: url.absoluteString as NSString)
                completion(image)
            } else {
                completion(nil)
            }
        }.resume()
    }
}
