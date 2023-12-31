//
//  ImageCollectionViewCell.swift
//  ImageGallery
//
//  Created by Andrei Pripa on 1/13/23.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    var imageUrl: URL? { didSet { setImage() } }
    
    var loader = CacheManager.shared
}

extension ImageCollectionViewCell
{
    private func setImage() {
        guard let url = imageUrl else {
            return
        }
        self.cellImageView.image = nil
        self.spinner.isHidden = false
        self.spinner.startAnimating()
        
        loader.getImage(fromURL: url, complitionHandler: { [weak self] image in
            DispatchQueue.main.async {
                if self?.imageUrl == url {
                    self?.cellImageView.image = image
                    self?.spinner.isHidden = true
                    self?.spinner.stopAnimating()
                }
            }
        })
    }
}
