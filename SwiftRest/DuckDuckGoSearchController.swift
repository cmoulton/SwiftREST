//
//  DuckDuckGoSearchController.swift
//  SwiftRest
//
//  Created by Christina Moulton on 2015-03-08.
//  Copyright (c) 2015 Teak Mobile Inc. All rights reserved.
//

/*
Duck Duck Go has an Instant Answers API that can be accessed like:
https://api.duckduckgo.com/?q=%22yoda%27s%20species%22&format=json&pretty=1
(&pretty=1 is optional but nice if you're calling it in a web browser)
Documentation is at https://api.duckduckgo.com/api

The results look like the following and includes an image:
{
  "DefinitionSource" : "",
  "Heading" : "Yoda's species (Star Wars)",
  "ImageWidth" : 109,
  "RelatedTopics" : [
    {
      "Result" : "<a href=\"https://duckduckgo.com/2/c/Members_of_Yoda's_species\">Members of Yoda's species</a>",
      "Icon" : {
      "URL" : "",
      "Height" : "",
      "Width" : ""
    },
    "FirstURL" : "https://duckduckgo.com/2/c/Members_of_Yoda's_species",
    "Text" : "Members of Yoda's species"
    },
    {
      "Result" : "<a href=\"https://duckduckgo.com/2/c/Unidentified_sentient_species\">Unidentified sentient species</a>",
      "Icon" : {
      "URL" : "",
      "Height" : "",
      "Width" : ""
    },
    "FirstURL" : "https://duckduckgo.com/2/c/Unidentified_sentient_species",
    "Text" : "Unidentified sentient species"
    }
  ],
  "Entity" : "",
  "Type" : "A",
  "Redirect" : "",
  "DefinitionURL" : "",
  "AbstractURL" : "http://starwars.wikia.com/wiki/Yoda's_species",
  "Definition" : "",
  "AbstractSource" : "Wookieepedia",
  "Infobox" : "",
  "Image" : "https://duckduckgo.com/i/fd2dabcf.jpg",
  "ImageIsLogo" : 0,
  "Abstract" : "The Jedi Master Yoda was the best-known member of a species whose true name is not recorded. Known in some sources simply as Yoda's species, this species of small carnivorous humanoids produced several well-known members of the Jedi Order during the time of the Galactic Republic.",
  "AbstractText" : "The Jedi Master Yoda was the best-known member of a species whose true name is not recorded. Known in some sources simply as Yoda's species, this species of small carnivorous humanoids produced several well-known members of the Jedi Order during the time of the Galactic Republic.",
  "AnswerType" : "",
  "ImageHeight" : 200,
  "Results" : [],
  "Answer" : ""
}
*/

import Foundation
import Alamofire

enum BackendError: Error {
  case urlError(reason: String)
  case objectSerialization(reason: String)
}

class ImageSearchResult {
  let imageURL:String?
  let source:String?
  let attributionURL:String?
  var image:UIImage?
  
  required init(anImageURL: String?, aSource: String?, anAttributionURL: String?) {
    imageURL = anImageURL
    source = aSource
    attributionURL = anAttributionURL
  }
  
  func fullAttribution() -> String {
    var result:String = ""
    if attributionURL != nil && attributionURL!.isEmpty == false {
      result += "Image from \(attributionURL!)"
    }
    if source != nil && source!.isEmpty == false  {
      if result.isEmpty {
        result += "Image from "
      }
      result += " \(source!)"
    }
    return result
  }
}

class duckDuckGoSearchController {
  static let IMAGE_KEY = "Image"
  static let SOURCE_KEY = "AbstractSource"
  static let ATTRIBUTION_KEY = "AbstractURL"
  
  fileprivate class func endpointForSearchString(_ searchString: String) -> String {
    // URL encode it, e.g., "Yoda's Species" -> "Yoda%27s%20Species"
    // and add star wars to the search string so that we don't get random pictures of the Hutt valley or Droid phones
    let encoded = "\(searchString) star wars".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    // create the search string
    // append &t=grokswift so DuckDuckGo knows who's using their services
    return "https://api.duckduckgo.com/?q=\(encoded!)&format=json&t=grokswift"
  }
  
  class func imageFromSearchString(_ searchString: String, completionHandler: @escaping (Result<ImageSearchResult>) -> Void) {
    let searchURLString = endpointForSearchString(searchString)
    Alamofire.request(searchURLString)
      .responseJSON { response in
        if let error = response.result.error {
          completionHandler(.failure(error))
          return
        }
        
        let imageURLResult = imageFromResponse(response)
        
        guard imageURLResult.isSuccess,
          let result = imageURLResult.value else {
          completionHandler(.failure(imageURLResult.error!))
          return
        }
        
        guard let imageURL = result.imageURL,
          !imageURL.isEmpty else {
            completionHandler(.failure(BackendError.objectSerialization(reason:
              "Could not get image URL from JSON")))
            return
        }
        
        // got the URL, now to load it
        Alamofire.request(imageURL)
          .response { response in
            if response.data == nil {
              completionHandler(.failure(BackendError.objectSerialization(reason:
                "Could not get image data from URL")))
              return
            }
            result.image = UIImage(data: response.data!)
            completionHandler(.success(result))
        }
    }
  }
  
  private class func imageFromResponse(_ response: DataResponse<Any>) -> Result<ImageSearchResult> {
    guard response.result.error == nil else {
      // got an error in getting the data, need to handle it
      print(response.result.error!)
      return .failure(response.result.error!)
    }
    
    // make sure we got JSON and it's a dictionary
    guard let json = response.result.value as? [String: Any] else {
      print("didn't get image info as JSON from API")
      return .failure(BackendError.objectSerialization(reason:
        "Did not get JSON dictionary in response"))
    }
    
    // turn JSON in to Image object
    guard let imageURL = json[IMAGE_KEY] as? String,
      let source = json[SOURCE_KEY] as? String,
      let attribution = json[ATTRIBUTION_KEY] as? String else {
        return .failure(BackendError.objectSerialization(reason:
          "Could not get image from JSON"))
    }
    
    let result = ImageSearchResult(anImageURL: imageURL, aSource: source, anAttributionURL: attribution)
    return .success(result)
  }
}
