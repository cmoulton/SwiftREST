//
//  DuckDuckGoSearchController.swift
//  SwiftRest
//
//  Created by Christina Moulton on 2016-12-07.
//  Copyright © 2016 Teak Mobile Inc. All rights reserved.
//

import Foundation
import Alamofire

class ImageSearchResult {
  let imageURL: String
  let source: String?
  let attributionURL: String?
  var image: UIImage?
  
  required init(anImageURL: String, aSource: String?, anAttributionURL: String?) {
    imageURL = anImageURL
    source = aSource
    attributionURL = anAttributionURL
  }
  
  func fullAttribution() -> String {
    var result:String = ""
    if let attributionURL = attributionURL, !attributionURL.isEmpty {
      result += "Image from \(attributionURL)"
    }
    if let source = source, !source.isEmpty {
      if result.isEmpty {
        result += "Image from "
      }
      result += " \(source)"
    }
    return result
  }
}

class DuckDuckGoSearchController {
  static let IMAGE_KEY = "Image"
  static let SOURCE_KEY = "AbstractSource"
  static let ATTRIBUTION_KEY = "AbstractURL"
  
  private class func endpoint(for searchString: String) -> String? {
    // URL encode it, e.g., "Yoda's Species" -&gt; "Yoda%27s%20Species"
    // and add star wars to the search string so that we don't get random pictures of the Hutt valley or Droid phones
    guard let encoded = "\(searchString) star wars".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
      return nil
    }
    // create the search string
    // append &t=grokswift so DuckDuckGo knows who's using their services
    return "https://api.duckduckgo.com/?q=\(encoded)&format=json&t=grokswift"
  }
  
  class func image(for searchString: String, completionHandler: @escaping (Result<ImageSearchResult>) -> Void) {
    guard let searchURLString = endpoint(for: searchString) else {
      completionHandler(.failure(BackendError.urlError(reason: "Could not create a valid search URL to get an image")))
      return
    }
    Alamofire.request(searchURLString)
      .responseJSON { response in
        if let error = response.result.error {
          completionHandler(.failure(error))
          return
        }
        DuckDuckGoSearchController.imageSearchResult(from: response) { imageSearchResult in
          completionHandler(imageSearchResult)
        }
    }
  }
  
  private class func imageSearchResult(from response: DataResponse<Any>, completionHandler: @escaping (Result<ImageSearchResult>) -> Void) {
    guard response.result.error == nil else {
      // got an error in getting the data, need to handle it
      print(response.result.error!)
      completionHandler(.failure(response.result.error!))
      return
    }
    
    // make sure we got JSON and it's a dictionary
    guard let json = response.result.value as? [String: Any] else {
      print("didn't get image search result as JSON from API")
      completionHandler(.failure(BackendError.objectSerialization(reason:
        "Did not get JSON dictionary in response")))
      return
    }
    
    guard let imageURL = json[IMAGE_KEY] as? String else {
      print("didn't get URL for image from search results")
      completionHandler(.failure(BackendError.objectSerialization(reason:
        "Did not get URL for image from search results")))
      return
    }
    let source = json[SOURCE_KEY] as? String
    let attribution = json[ATTRIBUTION_KEY] as? String
    let result = ImageSearchResult(anImageURL: imageURL, aSource: source, anAttributionURL: attribution)
    
    // got the URL, now to load it
    Alamofire.request(imageURL)
      .response { response in
        guard let imageData = response.data else {
          print("Could not get image from image URL returned in search results")
          completionHandler(.failure(BackendError.objectSerialization(reason:
            "Could not get image from image URL returned in search results")))
          return
        }
        result.image = UIImage(data: imageData)
        completionHandler(.success(result))
    }
  }
}
