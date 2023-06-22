//
//  ImageGalleryDocument.swift
//  DocumentImageGallery
//
//  Created by Andrei Pripa on 6/13/23.
//

import UIKit

class ImageGalleryDocument: UIDocument {
    
    var imageGallery: ImageGallery?
    
    var thumbnail: UIImage?
    
    override func contents(forType typeName: String) throws -> Any {
        // Encode your document with an instance of NSData or NSFileWrapper
        return imageGallery?.json ?? Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        // Load your document from contents
        guard let json = contents as? Data else {
            return
        }
        imageGallery = ImageGallery(json: json)
    }
    
    override func fileAttributesToWrite(to url: URL, for saveOperation: SaveOperation) throws -> [AnyHashable : Any] {
        var attributes = try super.fileAttributesToWrite(to: url, for: saveOperation)
        if let thumbnail = self.thumbnail {
            attributes[URLResourceKey.thumbnailDictionaryKey] = [URLThumbnailDictionaryItem.NSThumbnail1024x1024SizeKey:thumbnail]
        }
        return attributes
    }
    
}
