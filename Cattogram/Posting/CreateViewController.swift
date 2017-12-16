//
//  CreateViewController.swift
//  Cattogram
//
//  Created by Siraj Zaneer on 12/9/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit
import Photos

class CreateViewController: UIViewController {
    
    @IBOutlet weak var currentImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var assets: PHFetchResult<PHAsset>?
    var whiteView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let background = UIImage(named: "background")!
        navigationController?.navigationBar.setBackgroundImage(background, for: .default)
        
        whiteView.backgroundColor = .white
        whiteView.alpha = 0.5
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            loadPhotos()
        } else {
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status == .authorized {
                    self.loadPhotos()
                }
            })
        }
    }
    
    func loadPhotos() {
        assets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
        
        PHImageManager.default().requestImage(for: assets![0] , targetSize: CGSize(width: currentImageView.frame.height, height:  currentImageView.frame.height), contentMode: .aspectFill, options: nil) { (image: UIImage?, info: [AnyHashable : Any]?) -> Void in
            DispatchQueue.main.async {
                
                self.currentImageView.image = image
                self.collectionView.reloadData()
            }
        }
        collectionView.reloadData()
    }
    
    @IBAction func onCancel(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let id = segue.identifier else {
            return
        }
        
        switch id {
        case "postSegue":
            let destination = segue.destination as! PostViewController
            destination.image = currentImageView.image
        default:
            break
        }
    }
}

extension CreateViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width / 4.0 - 0.75, height: view.frame.width / 4.0 - 0.75)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)! as! CreateCell
        currentImageView.image = cell.imageView.image
        
        whiteView.frame = cell.bounds
        cell.addSubview(whiteView)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "createCell", for: indexPath) as! CreateCell
        
        guard let assets = assets else {
            return cell
        }
        
        PHImageManager.default().requestImage(for: assets[indexPath.row] , targetSize: CGSize(width: currentImageView.frame.height, height:  currentImageView.frame.height), contentMode: .aspectFill, options: nil) { (image: UIImage?, info: [AnyHashable : Any]?) -> Void in
            cell.imageView.image = image
        }
        
        
        return cell
    }
}
