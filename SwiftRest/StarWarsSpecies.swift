//
//  StarWarsSpecies.swift
//  SwiftRest
//
//  Created by Christina Moulton on 2015-08-20.
//  Copyright (c) 2015 Teak Mobile Inc. All rights reserved.
//

/* API response to http://swapi.co/api/species/3 looks like:

{
"average_height": "2.1",
"average_lifespan": "400",
"classification": "Mammal",
"created": "2014-12-10T16:44:31.486000Z",
"designation": "Sentient",
"edited": "2014-12-10T16:44:31.486000Z",
"eye_colors": "blue, green, yellow, brown, golden, red",
"hair_colors": "black, brown",
"homeworld": "http://swapi.co/api/planets/14/",
"language": "Shyriiwook",
"name": "Wookie",
"people": [
"http://swapi.co/api/people/13/"
],
"films": [
"http://swapi.co/api/films/1/",
"http://swapi.co/api/films/2/"
],
"skin_colors": "gray",
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
  var species: [StarWarsSpecies]?
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
  var skinColors: String?
  var hairColors: String? // TODO: parse into array
  var eyeColors: String? // TODO: array
  var averageLifespan: Int?
  var homeworld: String?
  var language: String?
  var people: [String]?
  var films: [String]?
  var created: NSDate?
  var edited: NSDate?
  var url: String?
  
  required init(json: JSON, id: Int?) {
    print(json)
    self.idNumber = id
    self.name = json[SpeciesFields.Name.rawValue].stringValue
    self.classification = json[SpeciesFields.Classification.rawValue].stringValue
    self.designation = json[SpeciesFields.Designation.rawValue].stringValue
    self.averageHeight = json[SpeciesFields.AverageHeight.rawValue].int
    // TODO: add all the fields
  }
  
  // MARK: Endpoints
  class func endpointForSpecies() -> String {
    return "https://swapi.co/api/species/"
  }
  
  private class func getSpeciesAtPath(path: String, completionHandler: (SpeciesWrapper?, NSError?) -> Void) {
    // iOS 9: Replace HTTP with HTTPS
    let securePath = path.stringByReplacingOccurrencesOfString("http://", withString: "https://", options: .AnchoredSearch)
    
    Alamofire.request(.GET, securePath)
      .responseSpeciesArray { response in
        if let error = response.result.error
        {
          completionHandler(nil, error)
          return
        }
        completionHandler(response.result.value, nil)
    }
  }
  
  class func getSpecies(completionHandler: (SpeciesWrapper?, NSError?) -> Void) {
    getSpeciesAtPath(StarWarsSpecies.endpointForSpecies(), completionHandler: completionHandler)
  }
  
  class func getMoreSpecies(wrapper: SpeciesWrapper?, completionHandler: (SpeciesWrapper?, NSError?) -> Void) {
    guard let nextPath = wrapper?.next else {
      completionHandler(nil, nil)
      return
    }
    getSpeciesAtPath(nextPath, completionHandler: completionHandler)
  }
}

extension Alamofire.Request {
  func responseSpeciesArray(completionHandler: Response<SpeciesWrapper, NSError> -> Void) -> Self {
    let responseSerializer = ResponseSerializer<SpeciesWrapper, NSError> { request, response, data, error in
      guard error == nil else {
        return .Failure(error!)
      }
      guard let responseData = data else {
        let failureReason = "Array could not be serialized because input data was nil."
        let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
        return .Failure(error)
      }
      
      let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
      let result = JSONResponseSerializer.serializeResponse(request, response, responseData, error)
      
      switch result {
      case .Success(let value):
        let json = SwiftyJSON.JSON(value)
        let wrapper = SpeciesWrapper()
        wrapper.next = json["next"].stringValue
        wrapper.previous = json["previous"].stringValue
        wrapper.count = json["count"].intValue
        
        var allSpecies = [StarWarsSpecies]()
        print(json)
        let results = json["results"]
        print(results)
        for jsonSpecies in results
        {
          print(jsonSpecies.1)
          let species = StarWarsSpecies(json: jsonSpecies.1, id: Int(jsonSpecies.0))
          allSpecies.append(species)
        }
        wrapper.species = allSpecies
        return .Success(wrapper)
      case .Failure(let error):
        return .Failure(error)
      }
    }
    
    return response(responseSerializer: responseSerializer,
      completionHandler: completionHandler)
  }
}