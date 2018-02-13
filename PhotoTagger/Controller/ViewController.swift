/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import Alamofire

class ViewController: UIViewController {
  
  // MARK: - IBOutlets
  @IBOutlet var takePictureButton: UIButton!
  @IBOutlet var imageView: UIImageView!
  @IBOutlet var progressView: UIProgressView!
  @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
  
  // MARK: - Properties
  static let authorizationStr = "Basic YWNjXzk0MzMwNTNkODZmYWJiMzpmODI0OGZkNzlkNzBhYTViNGQ0M2FhN2MxODc1YWZlMg=="
  typealias PhotoTag = String
  fileprivate var tags: [PhotoTag]?
  fileprivate var colors: [PhotoColor]?
  
  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    guard !UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
    
    takePictureButton.setTitle("Select Photo", for: .normal)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    imageView.image = nil
  }
  
  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    if segue.identifier == "ShowResults" {
      let controller = segue.destination as! TagsColorsViewController
      controller.tags = tags
      controller.colors = colors
    }
  }
  
  // MARK: - IBActions
  @IBAction func takePicture(_ sender: UIButton) {
    let picker = UIImagePickerController()
    picker.delegate = self
    picker.allowsEditing = false
    
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      picker.sourceType = .camera
    } else {
      picker.sourceType = .photoLibrary
      picker.modalPresentationStyle = .fullScreen
    }
    
    present(picker, animated: true)
  }
}

// MARK: - UIImagePickerControllerDelegate
extension ViewController: UIImagePickerControllerDelegate {
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
    guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
      print("Info did not have the required UIImage for the Original Image")
      dismiss(animated: true)
      return
    }
    
    imageView.image = image
    dismiss(animated: true)
    
    takePictureButton.isHidden = true
    progressView.progress = 0.0
    progressView.isHidden = false
    activityIndicatorView.startAnimating()
    
    uploadWithURLRequestConvertible(image: image, progressCompletion: { [unowned self] percent in
      self.progressView.setProgress(percent, animated: true)
      }, completion: { [unowned self] (tags, colors) in
        self.takePictureButton.isHidden = false
        self.progressView.isHidden = true
        self.activityIndicatorView.stopAnimating()
        
        self.tags = tags
        self.colors = colors
        
        self.performSegue(withIdentifier: "ShowResults", sender: self)
    })
    
//    upload(image: image, progressCompletion: { [unowned self] percent in
//      self.progressView.setProgress(percent, animated: true)
//      }, completion: { [unowned self] (tags, colors) in
//        self.takePictureButton.isHidden = false
//        self.progressView.isHidden = true
//        self.activityIndicatorView.stopAnimating()
//
//        self.tags = tags
//        self.colors = colors
//
//        self.performSegue(withIdentifier: "ShowResults", sender: self)
//    })
  }
}

// MARK: - UINavigationControllerDelegate
extension ViewController: UINavigationControllerDelegate {
}

// MARK: - Network Calls
extension ViewController {
  
  func uploadWithURLRequestConvertible(image: UIImage,
                                       progressCompletion: @escaping (_ percent: Float) -> (),
                                       completion: @escaping (_ tags: [PhotoTag], _ colors: [PhotoColor]) -> ()) {
    
    guard let imageDataPNG = UIImagePNGRepresentation(image) else {
      print("Could not get PNG representation of UIImage")
      return
    }
    print("Original size of image: \(imageDataPNG.getImageDataSizeInMB()) MB")
    
    guard let imageDataJPG = image.compressBeforeUpload() else {
      print("Could not compress image to JPEG")
      return
    }
    print("size of image: \(imageDataJPG.getImageDataSizeInMB()) MB")
    
    if ImaggaRouter.content.isReachableViaCellular() {
      print("Currently using cellular")
      completion([String](), [PhotoColor]())
      return
    }
    print("Not using cellular")
    
    if !ImaggaRouter.content.isReachableViaWifi() {
      print("Not connect to Wifi")
      completion([String](), [PhotoColor]())
      return
    }
    
    Alamofire.upload(
      multipartFormData: { multipartFormData in
        multipartFormData.append(imageDataJPG,
                                 withName: "imagefile",
                                 fileName: "image.jpg",
                                 mimeType: "image/jpeg")
    },
      with: ImaggaRouter.content,
      encodingCompletion: { [weak self] encodingResult in
        
        guard let strongSelf = self else { return }
        
        switch encodingResult {
        case .success(let request, _, _):
          request.uploadProgress(closure: { (progress) in
            progressCompletion(Float(progress.fractionCompleted))
          })
          request.validate()
          request.responseJSON(completionHandler: { (response) in
            guard response.result.isSuccess else {
              print("Error while uploading file: \(response.result.error?.localizedDescription ?? "")")
              completion([String](), [PhotoColor]())
              return
            }
            
            guard let json = response.result.value as? [String: Any],
              let uploadedFiles = json["uploaded"] as? [[String: Any]],
              let firstFile = uploadedFiles.first,
              let firstFileID = firstFile["id"] as? String else {
                
                print("Invalid information received from service")
                completion([String](), [PhotoColor]())
                return
            }
            
            print("Content uploaded with ID: \(firstFileID)")
//            strongSelf.downloadTags(contentID: firstFileID) { tags in
//              strongSelf.downloadColors(contentID: firstFileID) { colors in
//                completion(tags, colors)
//              }
//            }
            
            strongSelf.downloadTagsWithURLRequestConvertible(contentID: firstFileID) { tags in
              strongSelf.downloadColorsWithURLRequestConvertible(contentID: firstFileID) { colors in
                completion(tags, colors)
              }
            }
          })
          
        case .failure(let encodingErr):
          print(encodingErr)
        }
    })
  }
  
  func upload(image: UIImage,
              progressCompletion: @escaping (_ percent: Float) -> (),
              completion: @escaping (_ tags: [PhotoTag], _ colors: [PhotoColor]) -> ()) {
    
    guard let imageData = UIImageJPEGRepresentation(image, 0.5) else {
      print("Could not get JPEG representation of UIImage")
      return
    }
    
    //    Alamofire.request("https://httpbin.org/get", parameters: ["foo": "bar"])
    //      .validate(statusCode: 200..<300)
    //      .validate(contentType: ["application/json"])
    //      .response { response in
    //        // response handling code
    //    }
    
    Alamofire.upload(
      multipartFormData: { multipartFormData in
        multipartFormData.append(imageData,
                                 withName: "imagefile",
                                 fileName: "image.jpg",
                                 mimeType: "image/jpeg")
    }, to: "http://api.imagga.com/v1/content",
       headers: ["Authorization": ViewController.authorizationStr],
       encodingCompletion: { [weak self] encodingResult in
        
        switch encodingResult {
        case .success(let request, _, _):
          request.uploadProgress(closure: { (progress) in
            progressCompletion(Float(progress.fractionCompleted))
          })
          request.validate()
          request.responseJSON(completionHandler: { (response) in
            guard response.result.isSuccess else {
              print("Error while uploading file: \(response.result.error?.localizedDescription ?? "")")
              completion([String](), [PhotoColor]())
              return
            }
            
            guard let json = response.result.value as? [String: Any],
              let uploadedFiles = json["uploaded"] as? [[String: Any]],
              let firstFile = uploadedFiles.first,
              let firstFileID = firstFile["id"] as? String else {
                
                print("Invalid information received from service")
                completion([PhotoTag](), [PhotoColor]())
                return
            }
            
            print("Content uploaded with ID: \(firstFileID)")
            self?.downloadTags(contentID: firstFileID) { tags in
              self?.downloadColors(contentID: firstFileID) { colors in
                completion(tags, colors)
              }
            }
          })
          
        case .failure(let encodingErr):
          print(encodingErr)
        }
    })
  }
  
  func downloadTagsWithURLRequestConvertible(contentID: String, completion: @escaping ([PhotoTag]) -> ()) {
    Alamofire.request(ImaggaRouter.tags(contentID))
      .responseJSON { response in
        guard response.result.isSuccess else {
          print("Error while fetching tags: \(response.result.error?.localizedDescription ?? "")")
          completion([String]())
          return
        }
        
        guard let responseJSON = response.result.value as? [String: Any],
          let results = responseJSON["results"] as? [[String: Any]],
          let firstObj = results.first,
          let tagsAndConfidences = firstObj["tags"] as? [[String: Any]] else {
            
            print("Invalid tag information received from the service")
            completion([String]())
            return
        }
        
        let tags = tagsAndConfidences.flatMap { dict in
          return dict["tag"] as? PhotoTag
        }
        completion(tags)
    }
  }
  
  func downloadTags(contentID: String, completion: @escaping ([String]) -> ()) {
    Alamofire.request("http://api.imagga.com/v1/tagging", method: .get,
                      parameters: ["content": contentID],
                      headers: ["Authorization": ViewController.authorizationStr])
      .responseJSON { response in
        guard response.result.isSuccess else {
          print("Error while fetching tags: \(response.result.error?.localizedDescription ?? "")")
          completion([String]())
          return
        }
        
        guard let responseJSON = response.result.value as? [String: Any],
          let results = responseJSON["results"] as? [[String: Any]],
          let firstObj = results.first,
          let tagsAndConfidences = firstObj["tags"] as? [[String: Any]] else {
            
            print("Invalid tag information received from the service")
            completion([String]())
            return
        }
        
        let tags = tagsAndConfidences.flatMap { dict in
          return dict["tag"] as? String
        }
        completion(tags)
    }
  }
  
  func downloadColorsWithURLRequestConvertible(contentID: String,
                                               completion: @escaping ([PhotoColor]) -> ()) {
    Alamofire.request(ImaggaRouter.colors(contentID))
      .responseJSON { (response) in
        guard response.result.isSuccess else {
          print("Error while fetching colors: \(response.result.error?.localizedDescription ?? "")")
          completion([PhotoColor]())
          return
        }
        
        guard let responseJSON = response.result.value as? [String: Any],
          let results = responseJSON["results"] as? [[String: Any]],
          let firstResult = results.first,
          let info = firstResult["info"] as? [String: Any],
          let imageColors = info["image_colors"] as? [[String: Any]] else {
            
            print("Invalid color information received from service")
            completion([PhotoColor]())
            return
        }
        
        let photoColors = imageColors.flatMap { dict -> PhotoColor? in
          guard let r = dict["r"] as? String,
            let g = dict["g"] as? String,
            let b = dict["b"] as? String,
            let closestPaletteColor = dict["closest_palette_color"] as? String else {
              return nil
          }
          
          return PhotoColor(red: Int(r),
                            green: Int(g),
                            blue: Int(b),
                            colorName: closestPaletteColor)
        }
        
        completion(photoColors)
    }
  }
  
  func downloadColors (contentID: String, completion: @escaping ([PhotoColor]) -> ()) {
    Alamofire.request("http://api.imagga.com/v1/colors",
                      method: .get,
                      parameters: ["content": contentID],
                      headers: ["Authorization": ViewController.authorizationStr])
      .responseJSON { (response) in
        guard response.result.isSuccess else {
          print("Error while fetching colors: \(response.result.error?.localizedDescription ?? "")")
          completion([PhotoColor]())
          return
        }
        
        guard let responseJSON = response.result.value as? [String: Any],
          let results = responseJSON["results"] as? [[String: Any]],
          let firstResult = results.first,
          let info = firstResult["info"] as? [String: Any],
          let imageColors = info["image_colors"] as? [[String: Any]] else {
            print("Invalid color information received from service")
            completion([PhotoColor]())
            return
        }
        
        let photoColors = imageColors.flatMap { dict -> PhotoColor? in
          guard let r = dict["r"] as? String,
            let g = dict["g"] as? String,
            let b = dict["b"] as? String,
            let closestPaletteColor = dict["closest_palette_color"] as? String else {
              return nil
          }
          
          return PhotoColor(red: Int(r),
                            green: Int(g),
                            blue: Int(b),
                            colorName: closestPaletteColor)
        }
        
        completion(photoColors)
    }
  }
  
}


