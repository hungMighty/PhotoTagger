//
//  Data+Extension.swift
//  PhotoTagger
//
//  Created by 2B on 2/10/18.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import Foundation

extension Data {
  
  func getImageDataSizeInMB() -> Double {
    let imgData = NSData(data: self)
    let imgSize = imgData.length
    let imgSizeInMB = Double(imgSize) / 1024.0 / 1024.0
    let imgSizeInMBRoundUp = Double(round(100 * imgSizeInMB) / 100)
    
    return imgSizeInMBRoundUp
  }
  
}
