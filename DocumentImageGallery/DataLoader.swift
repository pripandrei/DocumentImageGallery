//
//  DataLoader.swift
//  ImageGallery
//
//  Created by Andrei Pripa on 1/30/23.
//

import UIKit

struct ImageLoader
{
   static func fetch(_ url: URL, complitionHandler: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async
        {
            let urlContent = try? Data(contentsOf: url.imageURL)
            DispatchQueue.main.async {
                guard let imageData = urlContent else {
                    return
                }
                if let image = UIImage(data: imageData) {
                    complitionHandler(image)
                }
            }
        }
    }
}
