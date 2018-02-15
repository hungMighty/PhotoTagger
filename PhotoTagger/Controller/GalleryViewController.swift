//
//  GalleryViewController.swift
//  PhotoTagger
//
//  Created by 2B on 2/15/18.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import UIKit

class GalleryViewController: UIViewController {
  
  static let id = String(describing: GalleryViewController.self)
  
  @IBOutlet weak var collectionView: UICollectionView!
  
  fileprivate var imageUrls = [URL]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let defaults = UserDefaults.standard
    let imagesArr = defaults.stringArray(forKey: "VietnamWorksImages") ?? [String]()
    
    for i in 0..<imagesArr.count {
      do {
        let fileUrl = try FileManager
          .default
          .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
          .appendingPathComponent("VietnamWorks/images")
          .appendingPathComponent(imagesArr[i])
        imageUrls.append(fileUrl)
        
      } catch {
        print(error.localizedDescription)
      }
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Buttons
  
  @IBAction func touchBackButton(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
}

extension GalleryViewController: UICollectionViewDataSource {
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return imageUrls.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView
      .dequeueReusableCell(withReuseIdentifier: ImageItem.id, for: indexPath)
      as? ImageItem else {
        return UICollectionViewCell()
    }
    let image = UIImage.init(contentsOfFile: imageUrls[indexPath.row].path)
    cell.thumbnail.image = image
    
    return cell
  }
  
}

extension GalleryViewController: UICollectionViewDelegate {
  
}
