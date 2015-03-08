//
//  DuckDuckGoSearchController.swift
//  SwiftRest
//
//  Created by Christina Moulton on 2015-03-08.
//  Copyright (c) 2015 Teak Mobile Inc. All rights reserved.
//

/*
Duck Duck Go has an Instant Answers API that can be accessed like:
http://api.duckduckgo.com/?q=%22yoda%27s%20species%22&format=json&pretty=1
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
import SwiftyJSONextension Alamofire.Request {
import SwiftyJSON


class duckDuckGoSearchController
{

}

let IMAGE_KEY = "Image"
let SOURCE_KEY = "AbstractSource"
let ATTRIBUTION_KEY = "AbstractURL"

extension Alamofire.Request {
  // single species
  class func imageURLResponseSerializer() -> Serializer {
    return { request, response, data in
      // pull out the image element from the JSON, if there is one
      if data == nil {
        return (nil, nil)
      }
      
      var jsonError: NSError?
      let jsonData:AnyObject? = NSJSONSerialization.JSONObjectWithData(data!, options: nil, error: &jsonError)
      if jsonError != nil
      {
        println(jsonError)
        return (nil, jsonError)
      }
      let json = JSON(jsonData!)
      if json.error != nil
      {
        println(json.error)
        return (nil, json.error)
      }
      if json == nil
      {
        return (nil, nil)
      }
      let imageURL = json[IMAGE_KEY].string
      let source = json[SOURCE_KEY].string
      let attribution = json[ATTRIBUTION_KEY].string
      let result = ImageSearchResult(anImageURL: imageURL, aSource: source, anAttributionURL: attribution)
      return (result, nil)
    }
  }
  
  func responseDuckDuckGoImageURL(completionHandler: (NSURLRequest, NSHTTPURLResponse?, ImageSearchResult?, NSError?) -> Void) -> Self {
    return response(serializer: Request.imageURLResponseSerializer(), completionHandler: { (request, response, result, error) in
      completionHandler(request, response, result as? ImageSearchResult, error)
    })
  }
  
}