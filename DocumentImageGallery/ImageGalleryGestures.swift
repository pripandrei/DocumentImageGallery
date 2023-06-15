//
//  CollectionViewGestures.swift
//  ImageGallery
//
//  Created by Andrei Pripa on 1/22/23.
//

import UIKit

extension ImageGalleryViewController {
    
    func addImageGalleryGestureRecognizers(to collectionView: UICollectionView) {
        collectionView.isUserInteractionEnabled = true
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(resizeCollectionView(by:)))
        collectionView.addGestureRecognizer(pinch)
    }
    
    
    @objc func resizeCollectionView(by recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .changed, .ended:
            scaleFactor *= recognizer.scale
            recognizer.scale = 1.0
            imageGalleryCollectionView.collectionViewLayout.invalidateLayout()
//            documentChange()
        default: break
        }
    }
}
