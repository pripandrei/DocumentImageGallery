//
//  DataLoader.swift
//  ImageGallery
//
//  Created by Andrei Pripa on 1/30/23.
//

import UIKit

struct CacheManager
{
    let cache = URLCache.shared
    
    func getImage(fromURL url: URL, complitionHandler: @escaping (UIImage) -> Void)
    {
        let request = URLRequest(url: url)
        
        if self.cache.cachedResponse(for: request) != nil {
            loadImageFromCache(withURL: url) { imageFromCache in
                complitionHandler(imageFromCache)
            }
        } else {
            downloadImage(fromURL: url) { downloadedImage in
                complitionHandler(downloadedImage)
            }
        }
    }
    
    func downloadImage(fromURL url: URL, complitionHandler: @escaping (UIImage) -> Void)
    {
        let dataTask = URLSession.shared
        let request = URLRequest(url: url)
        
        let _dataTask = dataTask.dataTask(with: request) { data, response, _ in
            if let data = data, let response = response {
                let cacheData = CachedURLResponse(response: response, data: data)
                self.cache.storeCachedResponse(cacheData, for: request)
                
                if let image = UIImage(data: data) {
                    complitionHandler(image)
                }
            }
        }
        _dataTask.resume()
    }
    
    func loadImageFromCache(withURL url: URL, complitionHandler: @escaping (UIImage) -> Void)
    {
        let request = URLRequest(url: url)
        
        if let data = self.cache.cachedResponse(for: request)?.data, let image = UIImage(data: data) {
            DispatchQueue.main.async {
                complitionHandler(image)
            }
        }
    }
}



// - Light version

//struct ImageLoader
//{
//   static func fetch(_ url: URL, complitionHandler: @escaping (UIImage?) -> Void) {
//        DispatchQueue.global(qos: .userInitiated).async
//        {
//            let urlContent = try? Data(contentsOf: url.imageURL)
//            DispatchQueue.main.async {
//                guard let imageData = urlContent else {
//                    return
//                }
//                if let image = UIImage(data: imageData) {
//                    complitionHandler(image)
//                }
//            }
//        }
//    }
//}
