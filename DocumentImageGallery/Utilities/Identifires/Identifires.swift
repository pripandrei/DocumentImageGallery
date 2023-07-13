//
//  Cellidentifire.swift
//  ImageGallery
//
//  Created by Andrei Pripa on 1/27/23.
//

import Foundation

protocol Reusable {
    static var identifire: String { get }
}

// MARK: - Identifires for reusable cells

class ImageCollectionViewCellPlaceholder: Reusable {}

class TextEditingCell: Reusable {}

extension ImageCollectionViewCell: Reusable {}

extension Reusable {
    static var identifire: String {
        return String(describing: self)
    }
}

// MARK: - Identifire for storyboard

class DocumentNavigationRoot: Reusable {}
