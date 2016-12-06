//
//  SpeciesDetailViewController.swift
//  SwiftRest
//
//  Created by Christina Moulton on 2016-12-06.
//  Copyright © 2016 Teak Mobile Inc. All rights reserved.
//

import Foundation
import UIKit

class SpeciesDetailViewController: UIViewController {
  @IBOutlet var descriptionLabel: UILabel?
  var species: StarWarsSpecies?
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    // fill in the label with text from the species
    displaySpeciesDetails()
  }
  
  func displaySpeciesDetails() {
    // just in case we don't have a species due to some error, empty out the label's contents
    self.descriptionLabel?.text = ""
    if self.species == nil {
      return
    }
    
    var descriptionText = ""
    
    if let name = self.species?.name {
      self.title = name // set the title for the navigation bar
      // if they have a language, add that first
      if let language = self.species!.language {
        descriptionText += "Members of the \(name) species speak \(language). "
      }
      
      // Add their average height if we have one
      if let height = self.species?.averageHeight {
        descriptionText += "The \(name) can be identified by their height, typically \(height)cm."
      }
      
      var eyeColors:String?
      if let colors = self.species?.eyeColors {
        eyeColors = colors.joined(separator: ", ")
      }
      var skinColors:String?
      if let colors = self.species?.skinColors {
        skinColors = colors.joined(separator: ", ")
      }
      var hairColors:String?
      if let colors = self.species?.hairColors {
        hairColors = colors.joined(separator: ", ")
      }
      
      if let eyeColors = eyeColors,
        let skinColors = skinColors,
        let hairColors = hairColors {
        // if any of the colors, tack 'em on
        descriptionText += "\n\nTypical coloring includes eyes:\n\t\(eyeColors)\nhair:\n\t\(hairColors)\nand skin:\n\t\(skinColors)"
      }
    }
    
    if let lifespan = self.species?.averageLifespan {
      // some species have numeric lifespans (like 100) and some have lifespans like "indefinite", so we handle both by adding " years" to the numeric ones
      descriptionText += "\n\nTheir average lifespan is \(lifespan)"
      if let _ = Int(lifespan) {
        descriptionText += " years"
      }
    }
    
    descriptionText += "."
    
    self.descriptionLabel?.text = descriptionText
    self.descriptionLabel?.sizeToFit() // to top-align text
  }
}
