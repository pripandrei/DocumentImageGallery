//
//  ImageGalleryViewController.swift
//  ImageGallery
//
//  Created by Andrei Pripa on 1/12/23.
//

import UIKit

class ImageGalleryViewController: UIViewController {
    
    var imageGallery: ImageGallery?
    var document: ImageGalleryDocument?
    var scaleFactor: CGFloat = 1.0

    @IBOutlet weak var imageGalleryCollectionView: UICollectionView! {
        didSet {
            imageGalleryCollectionView.dataSource = self
            imageGalleryCollectionView.delegate = self
            imageGalleryCollectionView.dropDelegate = self
            imageGalleryCollectionView.dragDelegate = self
            addImageGalleryGestureRecognizers(to: imageGalleryCollectionView)
        }
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        
        document?.imageGallery = imageGallery
        if document?.imageGallery != nil {
            document?.updateChangeCount(.done)
        }
        
        dismiss(animated: true) {
            self.document?.close()
        }
    }
    
    private func configureTrashButton() {
        let trashButton = UIButton(type: .system)
        let image = UIImage(systemName: "trash")
        let dropInteraction = UIDropInteraction(delegate: self)
        trashButton.frame = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: CGSize(width: 45.0, height: 45.0))
        trashButton.setImage(image, for: .normal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: trashButton)
        trashButton.isSpringLoaded = true
        trashButton.addInteraction(dropInteraction)
//        trashButton.addTarget(self, action: #selector(testAction), for: .touchUpInside)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTrashButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        document?.open() { success in
            if success {
                self.title = self.document?.localizedName
                
                guard let imageGallery = self.document?.imageGallery else {
                    self.imageGallery = ImageGallery()
                    return
                }
                
                //                if self.document?.imageGallery == nil {
                //                    self.imageGallery = ImageGallery()
                //                }
                self.imageGallery = imageGallery
            }
        }
    }
}

// MARK: - UIDropInteractionDelegate

extension ImageGalleryViewController: UIDropInteractionDelegate {
 
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.hasItemsConforming(toTypeIdentifiers: ["public.image"])
//        return session.canLoadObjects(ofClass: UIImage.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .move)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        for item in session.items {
            guard let indexPath = item.localObject as? IndexPath else {
                return
            }
            imageGalleryCollectionView.performBatchUpdates({
                imageGallery?.images.remove(at: indexPath.item)
                imageGalleryCollectionView.deleteItems(at: [indexPath])
            })
        }
    }
}


//MARK: - UICollectionViewDataSource

extension ImageGalleryViewController: UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageGallery?.images.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.identifire, for: indexPath)
                as? ImageCollectionViewCell else {
            fatalError("Unable to dequeu reusable cell")
        }

        cell.imageUrl = imageGallery?.images[indexPath.item].cellURL
    
        return cell
    }
}

//MARK: - UICollectionViewDelegate

extension ImageGalleryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

//MARK: - UICollectionViewDragDelegate

extension ImageGalleryViewController: UICollectionViewDragDelegate
{
    func collectionView(_ collectionView: UICollectionView,
                        itemsForBeginning session: UIDragSession,
                        at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView
        return dragItem(at: indexPath)
    }
    
    private func dragItem(at indexPath: IndexPath) -> [UIDragItem] {
        guard let image = (imageGalleryCollectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell)?.cellImageView.image else {
            return [] 
        }
        let dragItem = UIDragItem(itemProvider: NSItemProvider(object: image))

        dragItem.localObject = indexPath

        return [dragItem]
    }
}

//MARK: - UICollectionViewDropDelegate

extension ImageGalleryViewController: UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSURL.self) || session.canLoadObjects(ofClass: UIImage.self)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        dropSessionDidUpdate session: UIDropSession,
                        withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal
    {
        let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        return UICollectionViewDropProposal(operation: isSelf ? .move : .copy, intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator)
    {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        
        for item in coordinator.items {
            guard let sourceIndexPath = item.sourceIndexPath else {
                handleDropFromGlobalSource(with: item, usingCoordinator: coordinator)
                continue
            }
            collectionView.performBatchUpdates({
                guard let removedImgCell = imageGallery?.images.remove(at: sourceIndexPath.item) else {
                    return
                }
//                let removedImgCell = imageGallery!.images.remove(at: sourceIndexPath.item)
                imageGallery?.images.insert(removedImgCell, at: destinationIndexPath.item)
                collectionView.deleteItems(at: [sourceIndexPath])
                collectionView.insertItems(at: [destinationIndexPath])
            })
            coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
        }
    }
    
    private func handleDropFromGlobalSource(with item: UICollectionViewDropItem,
                                            usingCoordinator coordinator: UICollectionViewDropCoordinator)
    {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        let placeHolder = coordinator.drop(item.dragItem, to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: ImageCollectionViewCellPlaceholder.identifire))
        let newImage = ImageGallery.ImageInfo()
        
        imageGallery?.images.insert(newImage, at: destinationIndexPath.item)
        
        coordinator.session.loadObjects(ofClass: UIImage.self, completion: { image in
            if let image = image.first as? UIImage {
                self.imageGallery?.images[destinationIndexPath.item].cellAspectRatio = image.size
            }
        })
        
        item.dragItem.itemProvider.loadObject(ofClass: NSURL.self, completionHandler: { provider, error in
                DispatchQueue.main.async {
                    guard let url = provider as? URL else { placeHolder.deletePlaceholder(); return}
                    
                    placeHolder.commitInsertion(dataSourceUpdates: { insertionIndexPath in
                        self.imageGallery?.images[destinationIndexPath.item].cellURL = url
                    })
                }
        })
        
//        var dropURL: URL?
//        var dropImage: UIImage?
//
//        coordinator.session.loadObjects(ofClass: NSURL.self, completion: { nsurls in
//            if let url = nsurls.first as? URL {
//                dropURL = url
//            }
//        })
//
//        coordinator.session.loadObjects(ofClass: UIImage.self, completion: { images in
//            if let image = images.first as? UIImage {
//                dropImage = image
//            }
//        })
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

extension ImageGalleryViewController: UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        (collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell)?.setNeedsDisplay()
        guard let cellAspectRatio = imageGallery?.images[indexPath.item].cellAspectRatio else {
            fatalError("Could not get cellAspectRatio. imageGallery == nil")
        }
//        let cellAspectRatio = imageGallery!.images[indexPath.item].cellAspectRatio
        let scaledSize = CGSize(width: cellAspectRatio.width * scaleFactor, height: cellAspectRatio.height * scaleFactor)
        return scaledSize
    }
}

//MARK: - Navigation

extension ImageGalleryViewController {
    
    enum ImageGallerySegue: String {
        case ShowImageVC
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        guard let identifire = segue.identifier, let identifireCase = ImageGallerySegue(rawValue: identifire) else {
            fatalError("Could not map segue identifire to segue case")
        }
        
        switch identifireCase {
        case .ShowImageVC:
            let cell = sender as! ImageCollectionViewCell
            let imageVC = segue.destination as! ImageVC
            imageVC.galleryImage.image = cell.cellImageView.image
        }
    }
}


