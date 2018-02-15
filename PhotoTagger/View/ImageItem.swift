//
//  ImageItemCell.swift
//  PhotoTagger
//
//  Created by Ahri on 2/15/18.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import UIKit

class ImageItem: UICollectionViewCell {
  
  static let id = String(describing: ImageItem.self)
    
  @IBOutlet weak var thumbnail: UIImageView!
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    thumbnail.image = nil
  }
  
}
