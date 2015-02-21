//
//  Post.swift
//  AlamofireDemo
//
//  Created by Christina Moulton on 2015-02-18.
//  Copyright (c) 2015 Teak Mobile Inc. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

// need to be outside class, otherwise convenience initializer can't access them
let TITLE = "title"
let BODY = "body"
let ID = "id"
let USERID = "userId"

class Post {
  
  var title:String?
  var body:String?
  var id:Int?
  var userId:Int?
  
  required init(aTitle: String?, aBody: String?, anId: Int?, aUserId: Int?) {
    self.title = aTitle
    self.body = aBody
    self.id = anId
    self.userId = aUserId
  }

  convenience init(fields: NSDictionary) {
    self.init(aTitle: fields[TITLE] as? String, aBody: fields[BODY] as? String, anId: fields[ID] as? Int, aUserId: fields[USERID] as? Int)
  }
  
  func toJSON() -> Dictionary<String, AnyObject> {
    var json = Dictionary<String, AnyObject>()
    if let aTitle = title
    {
      json["title"] = title
    }
    if let aBody = body
    {
      json["body"] = body
    }
    if let anID = id
    {
      json["id"] = id
    }
    if let aUserID = userId
    {
      json["userId"] = userId
    }
    return json
  }
  
  func description() -> String {
    return "ID: \(self.id)\n" +
           "User ID: \(self.userId)\n" +
           "Title: \(self.title)\n" +
           "Body: \(self.body)\n"
  }
  
  // MARK: URLs
  class func endpointForID(id: Int) -> String {
    return "http://jsonplaceholder.typicode.com/posts/\(id)"
  }
  class func endpointForPosts() -> String {
    return "http://jsonplaceholder.typicode.com/posts/"
  }
  
  // MARK: CRUD
  // GET / Read
  class func postByID(id: Int, completionHandler: (Post?, NSError?) -> Void) {
    Alamofire.request(.GET, Post.endpointForID(id))
      .responsePost { (request, response, post, error) in
        if let anError = error
        {
          completionHandler(nil, error)
          return
        }
        completionHandler(post, nil)
    }
  }
  
  // GET all / Read
  class func getPosts(completionHandler: (Array<Post>?, NSError?) -> Void) {
    Alamofire.request(.GET, Post.endpointForPosts())
      .responsePosts { (request, response, posts, error) in
        if let anError = error
        {
          completionHandler(nil, error)
          return
        }
        completionHandler(posts, nil)
    }
  }
  
  // POST / Create
  func save(completionHandler: (Post?, NSError?) -> Void) {
    let fields:Dictionary<String, AnyObject>? = self.toJSON()
    if fields == nil
    {
      println("error: error converting newPost fields to JSON")
      return
    }
    Alamofire.request(.POST, Post.endpointForPosts(), parameters:fields, encoding: .JSON)
      .responsePost { (request, response, post, error) in
        completionHandler(post, error)
    }
  }
}

extension Alamofire.Request {
  class func postResponseSerializer() -> Serializer {
    return { request, response, data in
      println(data)
      if data == nil {
        return (nil, nil)
      }
      
      var jsonError: NSError?
      let json:AnyObject? = NSJSONSerialization.JSONObjectWithData(data!, options: nil, error: &jsonError)
      if let aJSONError = jsonError
      {
        return (nil, jsonError)
      }
      if json == nil
      {
        return (nil, nil)
      }
      if let dictionary = json as? NSDictionary
      {
        if dictionary.allKeys.count == 0
        {
          return (nil, nil)
        }
        let post = Post(fields: dictionary)
        return (post, nil)
      }
      return (nil, nil)
    }
  }
  
  func responsePost(completionHandler: (NSURLRequest, NSHTTPURLResponse?, Post?, NSError?) -> Void) -> Self {
    return response(serializer: Request.postResponseSerializer(), completionHandler: { (request, response, post, error) in
      completionHandler(request, response, post as? Post, error)
    })
  }
  
  class func postsResponseSerializer() -> Serializer {
    return { request, response, data in
      println(data)
      if data == nil {
        return (nil, nil)
      }
      
      var jsonError: NSError?
      let json:AnyObject? = NSJSONSerialization.JSONObjectWithData(data!, options: nil, error: &jsonError)
      if let aJSONError = jsonError
      {
        return (nil, jsonError)
      }
      if json == nil
      {
        return (nil, nil)
      }
      var posts:Array = Array<Post>()
      if let array = json as? Array<AnyObject>
      {
        for jsonPost in array
        {
          if let fields:NSDictionary = jsonPost as? NSDictionary
          {
            if fields.allKeys.count > 0
            {
              let post = Post(fields: fields)
              posts.append(post)
            }
          }
        }
      }
      return (posts, nil)
    }
  }
  
  func responsePosts(completionHandler: (NSURLRequest, NSHTTPURLResponse?, [Post]?, NSError?) -> Void) -> Self {
    return response(serializer: Request.postsResponseSerializer(), completionHandler: { (request, response, posts, error) in
      completionHandler(request, response, posts as? [Post], error)
    })
  }

}