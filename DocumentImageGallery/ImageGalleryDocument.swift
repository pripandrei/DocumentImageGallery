//
//  ImageGalleryDocument.swift
//  DocumentImageGallery
//
//  Created by Andrei Pripa on 6/13/23.
//

import UIKit

class ImageGalleryDocument: UIDocument {
    
    var imageGallery: ImageGallery?
    
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
}

