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
import SwiftyJSON