//
//  SpeciesDetailViewController.swift
//  SwiftRest
//
//  Created by Christina Moulton on 2015-03-01.
//  Copyright (c) 2015 Teak Mobile Inc. All rights reserved.
//

import Foundation
import UIKit

class SpeciesDetailViewController: UIViewController {
  
  @IBOutlet var descriptionLabel: UILabel?
  
  var species:StarWarsSpecies?
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    self.displaySpeciesDetails()
  }
  
  func displaySpeciesDetails()
  {
    self.descriptionLabel!.text = ""
    if self.species == nil
    {
      return
    }
    
    if let name =  self.species!.name
    {
      self.title = name
      if let language = self.species!.language
      {
        self.descriptionLabel!.text! += "Members of the \(name) species speak \(language). "
      }
      
      if let height = self.species!.averageHeight
      {
        self.descriptionLabel!.text! += "The \(self.species!.name!) can be identified by their height, typically \(height)cm."
      }
      
      var eyeColors:String?
      if let colors = self.species!.eyeColors
      {
        eyeColors = colors.joinWithSeparator(" or ")
      }
      var skinColors:String?
      if let colors = self.species!.skinColors
      {
        skinColors = colors.joinWithSeparator(", ")
      }
      var hairColors:String?
      if let colors = self.species!.hairColors
      {
        hairColors = colors.joinWithSeparator(", ")
      }
      
      if eyeColors != nil && skinColors != nil && hairColors != nil
      {
        // if any of the colors, tack 'em on
        self.descriptionLabel!.text! += "\n\nTypical coloring includes eyes:\n\t\(eyeColors!)\nhair:\n\t\(hairColors!)\nand skin:\n\t\(skinColors!)"
      }
    }

    if self.species?.averageLifespan != nil
    {
      // some species have numeric lifespans (like 100) and some have lifespans like "indefinite", so we handle both by adding " years" to the numeric ones
      if let lifespan = self.species?.averageLifespan {
        self.descriptionLabel!.text! += "\n\nTheir average lifespan is \(lifespan)"
        let numericLifespan = Int(lifespan)
        if numericLifespan != nil {
          self.descriptionLabel!.text! += " years."
        }
        else
        {
          self.descriptionLabel!.text! += "."
        }
      }
    }
    self.descriptionLabel!.sizeToFit() // to top-align text
  }
  
}
