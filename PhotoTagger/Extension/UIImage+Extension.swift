//
//  UIImage+Extension.swift
//  PhotoTagger
//
//  Created by 2B on 2/10/18.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
  
  func compressBeforeUpload() -> Data? {
    let imgCompressOptions: [CGFloat] = [0.9, 0.5, 0.2, 0.01]
    for i in 0..<imgCompressOptions.count {
      guard let imageData = UIImageJPEGRepresentation(self, imgCompressOptions[i]) else {
        print("Could not get JPEG representation of UIImage")
        return nil
      }
      
      if imageData.getImageDataSizeInMB() < 4.5 {
        return imageData
      }
    }
    
    return nil
  }
  
}
