//
//  ImageVC.swift
//  ImageGallery
//
//  Created by Andrei Pripa on 1/23/23.
//

import UIKit
import AVFoundation

class ImageVC: UIViewController, UIScrollViewDelegate {
    
    var galleryImage = UIImageView()
    
    var image: UIImage? {
        get {
            return galleryImage.image
        }
        set {
            
            galleryImage.image = newValue
//            let shrinkedView = scrollView.frame.insetBy(dx: 100, dy: 100)
            galleryImage.frame = AVMakeRect(aspectRatio: newValue!.size, insideRect: self.view.frame)
            galleryImage.frame.origin = CGPoint.zero
//            galleryImage.frame.origin = CGPoint(x: originX, y: originY)
//            galleryImage.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: scrollView.frame.width , height: scrollView.frame.height))
            scrollView.backgroundColor = .brown
            scrollView.contentSize = galleryImage.frame.size
            scrollView.addSubview(galleryImage)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        image = galleryImage.image
        splitViewController?.presentsWithGesture = false
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.view.layoutSubviews()
        adjustContentSizeToBeCentered()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        splitViewController?.presentsWithGesture = true
    }
    
    private func adjustContentSizeToBeCentered() {
        let originX = max((self.scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0.0)
        let originY = max((self.scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0.0)
        scrollView.contentInset = UIEdgeInsets(top: originY, left: originX, bottom: 0.0, right: 0.0)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return galleryImage
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        adjustContentSizeToBeCentered()
    }
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.minimumZoomScale = 0.2
            scrollView.maximumZoomScale = 5.0
            scrollView.delegate = self
//            scrollView.addSubview(galleryImage)
        }
    }
}

