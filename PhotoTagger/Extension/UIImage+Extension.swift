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
    guard let originImageData = UIImageJPEGRepresentation(self, 1) else {
      print("Could not get JPEG representation of UIImage")
      return nil
    }
    
    let originalSize = originImageData.getImageDataSizeInMB()
    var imgCompressOption: CGFloat
    
    if originalSize > 500 {
      imgCompressOption = 0.001
    } else if originalSize > 400 {
      imgCompressOption = 0.0015
    } else if originalSize > 300 {
      imgCompressOption = 0.003
    } else if originalSize > 200 {
      imgCompressOption = 0.007
    } else if originalSize > 100 {
      imgCompressOption = 0.01
    } else if originalSize > 50 {
      imgCompressOption = 0.03
    } else if originalSize > 20 {
      imgCompressOption = 0.05
    } else if originalSize > 10 {
      imgCompressOption = 0.2
    } else if originalSize > 4 {
      imgCompressOption = 0.8
    } else {
      imgCompressOption = 1
    }
    
    guard let imageData = UIImageJPEGRepresentation(self, imgCompressOption) else {
      print("Could not get JPEG representation of UIImage")
      return nil
    }
    return imageData
    
  }
  
}
