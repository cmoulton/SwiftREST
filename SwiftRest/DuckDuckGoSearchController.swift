//
//  DuckDuckGoSearchController.swift
//  SwiftRest
//
//  Created by Christina Moulton on 2015-10-17.
//  Copyright © 2015 Teak Mobile Inc. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class DuckDuckGoSearchController
{
  private class func endpointForSearchString(searchString: String) -> String {
    // URL encode it, e.g., "Yoda's Species" -&gt; "Yoda%27s%20Species"
    // and add star wars to the search string so that we don't get random pictures of the Hutt valley or Droid phones
    let encoded = "\(searchString) star wars".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
    // create the search string
    // append &t=grokswift so DuckDuckGo knows who's using their services
    return "https://api.duckduckgo.com/?q=\(encoded!)&format=json&t=grokswift"
  }
  
  class func imageFromSearchString(searchString: String, completionHandler: (ImageSearchResult?, NSError?) -> Void) {
    let searchURLString = endpointForSearchString(searchString)
    Alamofire.request(.GET, searchURLString)
      .responseDuckDuckGoImageURL { response in
        if let error = response.result.error
        {
          completionHandler(response.result.value, error)
          return
        }
        let imageURLResult = response.result.value
        guard let imageURL = imageURLResult?.imageURL where imageURL.isEmpty == false else {
          completionHandler(response.result.value, nil)
          return
        }
        // got the URL, now to load it
        Alamofire.request(.GET, imageURL)
          .response { (request, response, data, error) in
            guard let imageData = data else {
              completionHandler(imageURLResult, nil)
              return
            }
            imageURLResult?.image = UIImage(data: imageData)
            completionHandler(imageURLResult, nil)
        }
    }
  }
}

let IMAGE_KEY = "Image"
let SOURCE_KEY = "AbstractSource"
let ATTRIBUTION_KEY = "AbstractURL"

extension Alamofire.Request {
  func responseDuckDuckGoImageURL(completionHandler: Response<ImageSearchResult, NSError> -> Void) -> Self {
    let responseSerializer = ResponseSerializer<ImageSearchResult, NSError> { request, response, data, error in
      guard let responseData = data else {
        let failureReason = "Image URL could not be serialized because input data was nil."
        let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
        return .Failure(error)
      }
      
      let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
      let result = JSONResponseSerializer.serializeResponse(request, response, responseData, error)
      
      switch result {
      case .Success(let value):
        let json = SwiftyJSON.JSON(value)
        guard json.error == nil else {
          print(json.error!)
          return .Failure(json.error!)
        }
        let imageURL = json[IMAGE_KEY].string
        let source = json[SOURCE_KEY].string
        let attribution = json[ATTRIBUTION_KEY].string
        let result = ImageSearchResult(anImageURL: imageURL, aSource: source, anAttributionURL: attribution)
        
        return .Success(result)
      case .Failure(let error):
        return .Failure(error)
      }
    }
    
    return response(responseSerializer: responseSerializer,
      completionHandler: completionHandler)
  }
}
