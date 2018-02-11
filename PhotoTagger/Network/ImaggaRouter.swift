//
//  ImaggaRouter.swift
//  PhotoTagger
//
//  Created by 2B on 12/8/17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import Foundation
import Alamofire
import CoreTelephony

public enum ImaggaRouter: URLRequestConvertible {
  
  static let baseURLPath = "http://api.imagga.com/v1"
  static let authenticationToken = "Basic YWNjXzk0MzMwNTNkODZmYWJiMzpmODI0OGZkNzlkNzBhYTViNGQ0M2FhN2MxODc1YWZlMg=="
  
  case content
  case tags(String)
  case colors(String)
  
  var method: HTTPMethod {
    switch self {
    case .content:
      return .post
    case .tags, .colors:
      return .get
    }
  }
  
  var path: String {
    switch self {
    case .content:
      return "/content"
    case .tags:
      return "/tagging"
    case .colors:
      return "/colors"
    }
  }
  
  // MARK: - If using Wifi then we can upload images
  
  func isReachableViaCellular() -> Bool {
    let networkInfo = CTTelephonyNetworkInfo()
    let networkString = networkInfo.currentRadioAccessTechnology
    // Access Tech wiki:
    // https://stackoverflow.com/questions/25405566/mapping-ios-7-constants-to-2g-3g-4g-lte-etc
    
    
    // ReachableViaWWAN
    if
      /* LTE (4G) */
      networkString == CTRadioAccessTechnologyLTE ||
        
        /* 3G */
        networkString == CTRadioAccessTechnologyWCDMA ||
        networkString == CTRadioAccessTechnologyHSDPA ||
        networkString == CTRadioAccessTechnologyHSUPA ||
        networkString == CTRadioAccessTechnologyCDMAEVDORev0 ||
        networkString == CTRadioAccessTechnologyCDMAEVDORevA ||
        networkString == CTRadioAccessTechnologyCDMAEVDORevB ||
        networkString == CTRadioAccessTechnologyeHRPD ||
        
        /* EDGE (2G) */
        networkString == CTRadioAccessTechnologyGPRS ||
        networkString == CTRadioAccessTechnologyEdge ||
        networkString == CTRadioAccessTechnologyCDMA1x {
      return true
    }
    return false
  }
  
  func isReachableViaWifi() -> Bool {
    var url: URL?
    do {
      url = try ImaggaRouter.baseURLPath.asURL()
    } catch {
      print("Unexpected error: \(error).")
    }
    guard let notNilUrl = url else {
      return false
    }
    let request = URLRequest(url: notNilUrl.appendingPathComponent(path))
    
    guard let fullURL = request.url,
      let connectionState = NetworkReachabilityManager(host: fullURL.absoluteString) else {
        print("Fail to create connection manager")
        return false
    }
    
    print("Is reachable via Wifi? \(connectionState.isReachableOnEthernetOrWiFi)")
    return connectionState.isReachableOnEthernetOrWiFi
  }
  
  public func asURLRequest() throws -> URLRequest {
    let parameters: [String: Any] = {
      switch self {
      case .tags(let contentID):
        return ["content": contentID]
      case .colors(let contentID):
        return ["content": contentID, "extract_object_colors": 0]
      default:
        return [:]
      }
    }()
    
    let url = try ImaggaRouter.baseURLPath.asURL()
    
    var request = URLRequest(url: url.appendingPathComponent(path))
    request.httpMethod = method.rawValue
    request.setValue(ImaggaRouter.authenticationToken, forHTTPHeaderField: "Authorization")
    request.timeoutInterval = TimeInterval(10 * 1000)
    
    return try URLEncoding.default.encode(request, with: parameters)
  }
  
}
