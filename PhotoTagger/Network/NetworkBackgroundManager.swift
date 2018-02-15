//
//  NetworkBackgroundManager.swift
//  PhotoTagger
//
//  Created by 2B on 2/14/18.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import UIKit
import Alamofire
import UserNotifications


fileprivate let backgroundIdentifier = "com.photoTagger.background.download"
fileprivate let notificationIdentifier = "com.photoTagger.background.noti"


class NetworkBackgroundManager {

  var alamoFireManager : Alamofire.SessionManager
  
  var backgroundCompletionHandler: (() -> ())? {
    get {
      return alamoFireManager.backgroundCompletionHandler
    }
    set {
      alamoFireManager.backgroundCompletionHandler = newValue
    }
  }
  
  static let shared = NetworkBackgroundManager()
  private init() {
    let configuration = URLSessionConfiguration
      .background(withIdentifier: backgroundIdentifier)
    configuration.timeoutIntervalForRequest = 60 // seconds
    configuration.timeoutIntervalForResource = 300
    alamoFireManager = Alamofire.SessionManager(configuration: configuration)
    
    // specify what to do when download is done
    alamoFireManager.delegate.downloadTaskDidFinishDownloadingToURL = { _, task, location in
      guard let originRequest = task.originalRequest, let originUrl = originRequest.url else {
        return
      }
      let filename = originUrl.lastPathComponent
      
      do {
        let destinationRoot = try FileManager
          .default
          .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
          .appendingPathComponent("VietnamWorks/images")
        try FileManager.default.createDirectory(at: destinationRoot, withIntermediateDirectories: true)
        
        let destination = destinationRoot.appendingPathComponent(filename)
        
        if FileManager.default.fileExists(atPath: destination.path) {
          try FileManager.default.removeItem(at: destination)
        }
        try FileManager.default.moveItem(at: location, to: destination)
        
        let defaults = UserDefaults.standard
        var imagesArr = defaults.stringArray(forKey: "VietnamWorksImages") ?? [String]()
        if !imagesArr.contains(filename) {
          imagesArr.append(filename)
        }
        defaults.set(imagesArr, forKey: "VietnamWorksImages")
        
      } catch {
        print(error.localizedDescription)
      }
    }
    
    // specify what to do when background session finishes; i.e. make sure to call saved completion handler
    // if you don't implement this, it will call the saved `backgroundCompletionHandler` for you
    alamoFireManager.delegate.sessionDidFinishEventsForBackgroundURLSession = { [weak self] _ in
      if let strongSelf = self {
        strongSelf.alamoFireManager.backgroundCompletionHandler?()
        strongSelf.alamoFireManager.backgroundCompletionHandler = nil
        
        // Noti Download is done
        let content = UNMutableNotificationContent()
        content.title = "All downloads done"
        content.body = "Whoo, hoo!"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let noti = UNNotificationRequest(identifier: notificationIdentifier,
                                         content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(noti)
      }
    }
    
    // specify what to do upon error
    alamoFireManager.delegate.taskDidComplete = { _, task, error in
      guard let originRequest = task.originalRequest, let originUrl = originRequest.url else {
        return
      }
      let filename = originUrl.lastPathComponent
      if let error = error {
        print("\(filename) error: \(error.localizedDescription)")
      } else {
        print("\(filename) done!")
      }
      
      // I might want to post some event to `NotificationCenter`
      // so app UI can be updated, if it's in foreground
    }
  }
  
  func download(_ url: URL) {
    alamoFireManager.download(url)
  }

}
