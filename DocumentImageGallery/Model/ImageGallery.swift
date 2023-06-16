//
//  ImageGallery.swift
//  DocumentImageGallery
//
//  Created by Andrei Pripa on 6/13/23.
//

import Foundation

struct ImageGallery: Codable {
    
    var images = [ImageInfo]()
    
    struct ImageInfo: Equatable, Codable {
        
        var cellURL: URL?
        var cellSize: CGSize?
        var temp: CGSize?
        var selfFirstTimeAccessed = true
        
        var cellAspectRatio: CGSize {
            get {
                    return cellSize ?? CGSize()
                }
            set {
                let cellWidth = newValue.width
                let cellHeight = newValue.height
                let preferredCellWidth = 300.0
                var preferredCellHeight = CGSize().height
                
                let ratio = round((cellWidth / cellHeight) * 100) / 100
                preferredCellHeight = round((preferredCellWidth / ratio) * 100) / 100
                cellSize = CGSize(width: preferredCellWidth, height: preferredCellHeight)
            }
        }
    }
    
    init() {}
    
    init?(json: Data) {
        if let newValue = try? JSONDecoder().decode(ImageGallery.self, from: json) {
            self = newValue
        } else {
//            self = ImageGallery()
            return nil
        }
    }
    
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
}
