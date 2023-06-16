//
//  ImageGalleryDocument.swift
//  DocumentImageGallery
//
//  Created by Andrei Pripa on 6/13/23.
//

import UIKit
import QuickLookThumbnailing


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
    
//    func generateThumbnail(for url: URL, completion: @escaping (UIImage?) -> Void) {
//        let thumbnailSize = CGSize(width: 1024, height: 1024)
//        let request = QLThumbnailGenerator.Request(fileAt: url, size: thumbnailSize, scale: UIScreen.main.scale, representationTypes: .thumbnail)
//
//        let generator = QLThumbnailGenerator.shared
//        generator.generateRepresentations(for: request) { thumbnail, _, _ in
//            let image = thumbnail?.uiImage
//            completion(image)
//        }
//    }
//
//    func setThumbnail(_ image: UIImage?) {
//        thumbnail = image
//    }
//
//    override func save(to url: URL, for saveOperation: UIDocument.SaveOperation, completionHandler: ((Bool) -> Void)?) {
//        super.save(to: url, for: saveOperation) { success in
//            if success {
//                if let thumbnail = self.thumbnail {
//                    self.generateThumbnail(for: url) { generatedThumbnail in
//                        if let generatedThumbnail = generatedThumbnail {
//                            // Set the generated thumbnail
//                            self.setThumbnail(generatedThumbnail)
//
//                            // Call the completion handler after setting the thumbnail
//                            completionHandler?(true)
//                        } else {
//                            // Failed to generate thumbnail
//                            completionHandler?(false)
//                        }
//                    }
//                } else {
//                    // No thumbnail to generate
//                    completionHandler?(true)
//                }
//            } else {
//                // Saving failed
//                completionHandler?(false)
//            }
//        }
//    }
    
}
