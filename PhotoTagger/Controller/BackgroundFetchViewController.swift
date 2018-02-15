//
//  BackgroundFetchViewController.swift
//  PhotoTagger
//
//  Created by 2B on 2/14/18.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import UIKit
import Alamofire

class BackgroundFetchViewController: UIViewController {
  
  @IBOutlet weak var galleryButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    let defaults = UserDefaults.standard
    let imagesArr = defaults.stringArray(forKey: "VietnamWorksImages") ?? [String]()
    if imagesArr.count == 0 {
      self.galleryButton.isHidden = true
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func touchBackgroundFetch(_ sender: Any) {
    let urlStrings = [
      "http://spaceflight.nasa.gov/gallery/images/apollo/apollo17/hires/s72-55482.jpg",
      "http://spaceflight.nasa.gov/gallery/images/apollo/apollo10/hires/as10-34-5162.jpg",
      "http://spaceflight.nasa.gov/gallery/images/apollo-soyuz/apollo-soyuz/hires/s75-33375.jpg",
      "http://spaceflight.nasa.gov/gallery/images/apollo/apollo17/hires/as17-134-20380.jpg",
      "http://spaceflight.nasa.gov/gallery/images/apollo/apollo17/hires/as17-140-21497.jpg",
      "http://spaceflight.nasa.gov/gallery/images/apollo/apollo17/hires/as17-148-22727.jpg"
    ]
    let urls = urlStrings.flatMap { URL(string: $0) }
    
    for url in urls {
      NetworkBackgroundManager.shared.download(url)
//      Alamofire.download(url)
    }
  }
  
  @IBAction func showGalleryView(_ sender: Any) {
    if let view = UIStoryboard(name: "Main", bundle: nil)
      .instantiateViewController(withIdentifier: GalleryViewController.id)
      as? GalleryViewController {
      self.present(view, animated: true, completion: nil)
    }
  }
  
}
