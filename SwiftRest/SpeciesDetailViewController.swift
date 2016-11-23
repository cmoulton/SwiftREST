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
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.displaySpeciesDetails()
  }
  
  func displaySpeciesDetails()
  {
    self.descriptionLabel!.text = ""
    guard self.species != nil else {
      return
    }
    
    if let name = self.species!.name {
      self.title = name
      if let language = self.species!.language {
        self.descriptionLabel!.text! += "Members of the \(name) species speak \(language). "
      }
      
      if let height = self.species?.averageHeight {
        self.descriptionLabel!.text! += "The \(name) can be identified by their height, typically \(height)cm."
      }
      
      var eyeColors:String?
      if let colors = self.species!.eyeColors {
        eyeColors = colors.joined(separator: ", ")
      }
      var skinColors:String?
      if let colors = self.species!.skinColors {
        skinColors = colors.joined(separator: ", ")
      }
      var hairColors:String?
      if let colors = self.species!.hairColors {
        hairColors = colors.joined(separator: ", ")
      }
      
      if let eyeColors = eyeColors,
        let skinColors = skinColors,
        let hairColors = hairColors {
        // if any of the colors, tack 'em on
        self.descriptionLabel!.text! += "\n\nTypical coloring includes eyes:\n\t\(eyeColors)\nhair:\n\t\(hairColors)\nand skin:\n\t\(skinColors)"
      }
    }

    if self.species?.averageLifespan != nil
    {
      // some species have numeric lifespans (like 100) and some have lifespans like "indefinite", so we handle both by adding " years" to the numeric ones
      self.descriptionLabel!.text! += "\n\nTheir average lifespan is \(self.species!.averageLifespan!)"
      if let yearsString = species?.averageLifespan,
        let _ = Int(yearsString) {
        self.descriptionLabel!.text! += " years."
      } else {
        self.descriptionLabel!.text! += "."
      }
    }
    self.descriptionLabel!.sizeToFit() // to top-align text
  }
  
}
