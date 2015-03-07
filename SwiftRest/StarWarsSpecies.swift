//
//  StarWarsSpecies.swift
//  SwiftRest
//
//  Created by Christina Moulton on 2015-02-22.
//  Copyright (c) 2015 Teak Mobile Inc. All rights reserved.
//

/* API Response to http http://swapi.co/api/species/3/ looks like:
{
  "name": "Wookiee",
  "classification": "mammal",
  "designation": "sentient",
  "average_height": "210",
  "skin_colors": "gray",
  "hair_colors": "black, brown",
  "eye_colors": "blue, green, yellow, brown, golden, red",
  "average_lifespan": "400",
  "homeworld": "http://swapi.co/api/planets/14/",
  "language": "Shyriiwook",
  "people": [
  "http://swapi.co/api/people/13/",
  "http://swapi.co/api/people/80/"
  ],
  "films": [
  "http://swapi.co/api/films/1/",
  "http://swapi.co/api/films/2/",
  "http://swapi.co/api/films/3/",
  "http://swapi.co/api/films/6/"
  ],
  "created": "2014-12-10T16:44:31.486000Z",
  "edited": "2015-01-30T21:23:03.074598Z",
  "url": "http://swapi.co/api/species/3/"
}
*/

import Foundation
import Alamofire
import SwiftyJSON

enum SpeciesFields: String {
  case Name = "name"
  case Classification = "classification"
  case Designation = "designation"
  case AverageHeight = "average_height"
  case SkinColors = "skin_colors"
  case HairColors = "hair_colors"
  case EyeColors = "eye_colors"
  case AverageLifespan = "average_lifespan"
  case Homeworld = "homeworld"
  case Language = "language"
  case People = "people"
  case Films = "films"
  case Created = "created"
  case Edited = "edited"
  case Url = "url"
}

class SpeciesWrapper {
  var species: Array<StarWarsSpecies>?
  var count: Int?
  private var next: String?
  private var previous: String?
}

class StarWarsSpecies {
  var idNumber: Int?
  var name: String?
  var classification: String?
  var designation: String?
  var averageHeight: Int?
  var skinColors: Array<String>?
  var hairColors: Array<String>?
  var eyeColors: Array<String>?
  var averageLifespan: String?
  var homeworld: String?
  var language: String?
  var people: Array<String>?
  var films: Array<String>?
  var created: NSDate?
  var edited: NSDate?
  var url: String?
  
  required init(json: JSON, id: Int?) {
    println(json)
    self.idNumber = id
    
    // strings
    self.name = json[SpeciesFields.Name.rawValue].stringValue
    self.classification = json[SpeciesFields.Classification.rawValue].stringValue
    self.designation = json[SpeciesFields.Designation.rawValue].stringValue
    // lifespan is sometimes "unknown" or "infinite", so we can't use an int
    self.averageLifespan = json[SpeciesFields.AverageLifespan.rawValue].stringValue
    self.homeworld = json[SpeciesFields.Homeworld.rawValue].stringValue
    self.url = json[SpeciesFields.Url.rawValue].stringValue
    
    // ints
    self.averageHeight = json[SpeciesFields.AverageHeight.rawValue].intValue
    
    // strings to arrays like "a, b, c"
    // SkinColors, HairColors, EyeColors
    if let string = json[SpeciesFields.SkinColors.rawValue].string
    {
      self.skinColors = string.splitStringToArray()
    }
    if let string = json[SpeciesFields.HairColors.rawValue].string
    {
      self.hairColors = string.splitStringToArray()
    }
    if let string = json[SpeciesFields.EyeColors.rawValue].string
    {
      self.eyeColors = string.splitStringToArray()
    }
    
    // arrays
    // People, Films
    
    // Dates
    // Created, Edited
  }
  
  
  // MARK: Value transformers
  class func dateFormatter() -> NSDateFormatter {
    // TODO: reuse date formatter, they're expensive!
    var sharedDateFormatter = NSDateFormatter()
    sharedDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SZ"
    sharedDateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
    sharedDateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    return sharedDateFormatter
  }
  

  // MARK: Endpoints
  class func endpointForID(id: Int) -> String {
    return "http://swapi.co/api/species/\(id)"
  }
  class func endpointForSpecies() -> String {
    return "http://swapi.co/api/species/"
  }
  
  // MARK: CRUD
  // GET / Read single species
  class func speciesByID(id: Int, completionHandler: (StarWarsSpecies?, NSError?) -> Void) {
    Alamofire.request(.GET, StarWarsSpecies.endpointForID(id))
      .responseSpecies { (request, response, species, error) in
        if let anError = error
        {
          completionHandler(nil, error)
          return
        }
        completionHandler(species, nil)
    }
  }
  
  // GET / Read all species
  private class func getSpeciesAtPath(path: String, completionHandler: (SpeciesWrapper?, NSError?) -> Void) {
    Alamofire.request(.GET, path)
      .responseSpeciesArray { (request, response, speciesWrapper, error) in
        if let anError = error
        {
          completionHandler(nil, error)
          return
        }
        completionHandler(speciesWrapper, nil)
    }
  }
  
  class func getSpecies(completionHandler: (SpeciesWrapper?, NSError?) -> Void) {
    getSpeciesAtPath(StarWarsSpecies.endpointForSpecies(), completionHandler: completionHandler)
  }
  
  class func getMoreSpecies(wrapper: SpeciesWrapper?, completionHandler: (SpeciesWrapper?, NSError?) -> Void) {
    if wrapper == nil || wrapper?.next == nil
    {
      completionHandler(nil, nil)
      return
    }
    getSpeciesAtPath(wrapper!.next!, completionHandler: completionHandler)
  }
  
}

extension Alamofire.Request {
  // single species
  class func speciesResponseSerializer() -> Serializer {
    return { request, response, data in
      println(data)
      if data == nil {
        return (nil, nil)
      }
      
      var jsonError: NSError?
      let jsonData:AnyObject? = NSJSONSerialization.JSONObjectWithData(data!, options: nil, error: &jsonError)
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
      let species = StarWarsSpecies(json: json, id: nil)
      return (species, nil)
    }
  }
  
  func responseSpecies(completionHandler: (NSURLRequest, NSHTTPURLResponse?, StarWarsSpecies?, NSError?) -> Void) -> Self {
    return response(serializer: Request.speciesResponseSerializer(), completionHandler: { (request, response, species, error) in
      completionHandler(request, response, species as? StarWarsSpecies, error)
    })
  }
  
  // all species
  class func speciesArrayResponseSerializer() -> Serializer {
    return { request, response, data in
      if data == nil {
        return (nil, nil)
      }

      var jsonError: NSError?
      let jsonData:AnyObject? = NSJSONSerialization.JSONObjectWithData(data!, options: nil, error: &jsonError)
      if jsonData == nil || jsonError != nil
      {
        return (nil, jsonError)
      }
      let json = JSON(jsonData!)
      if json.error != nil || json == nil
      {
        return (nil, json.error)
      }
      
      var wrapper:SpeciesWrapper = SpeciesWrapper()
      wrapper.next = json["next"].stringValue
      wrapper.previous = json["previous"].stringValue
      wrapper.count = json["count"].intValue
      
      var allSpecies:Array = Array<StarWarsSpecies>()
      println(json)
      let results = json["results"]
      println(results)
      for jsonSpecies in results
      {
        println(jsonSpecies.1)
        let species = StarWarsSpecies(json: jsonSpecies.1, id: jsonSpecies.0.toInt())
        allSpecies.append(species)
      }
      wrapper.species = allSpecies
      return (wrapper, nil)
    }
  }
  
  func responseSpeciesArray(completionHandler: (NSURLRequest, NSHTTPURLResponse?, SpeciesWrapper?, NSError?) -> Void) -> Self {
    return response(serializer: Request.speciesArrayResponseSerializer(), completionHandler: { (request, response, speciesWrapper, error) in
      completionHandler(request, response, speciesWrapper as? SpeciesWrapper, error)
    })
  }
  
}