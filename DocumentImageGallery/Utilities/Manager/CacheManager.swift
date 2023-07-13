//
//  DataLoader.swift
//  ImageGallery
//
//  Created by Andrei Pripa on 5/30/23.
//

import UIKit

struct CacheManager
{
    static var shared = CacheManager()
    
    private let cache = URLCache.shared
    
    private init() {}
    
    func getImage(fromURL url: URL, complitionHandler: @escaping (UIImage) -> Void)
    {
        let request = URLRequest(url: url)
        
        if self.cache.cachedResponse(for: request) != nil {
            loadImageFromCache(withURL: url) { imageFromCache in
                complitionHandler(imageFromCache)
            }
        } else {
            downloadImage(fromURL: url) { result in
                switch result {
                case .success(let image): complitionHandler(image)
                case .failure(let error): print("Couldn't download image. Error: \(error.localizedDescription.description)")
                }
            }
        }
    }
    
    func downloadImage(fromURL url: URL, complitionHandler: @escaping (Result<UIImage,Error>) -> Void)
    {
        let dataTask = URLSession.shared
        let request = URLRequest(url: url)
        
        let _dataTask = dataTask.dataTask(with: request) { data, response, error in
            
            if let error = error {
                complitionHandler(.failure(error))
                return
            }

            guard let response = response as? HTTPURLResponse else {
                print("Error: HTTPURLResponse is nil")
                return
            }
            
            guard let data = data, response.statusCode >= 200 && response.statusCode < 300, let image = UIImage(data: data) else {
                return complitionHandler(.failure(error!))
            }
            
            let cacheData = CachedURLResponse(response: response, data: data)
            self.cache.storeCachedResponse(cacheData, for: request)
            complitionHandler(.success(image))
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
