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
        self.descriptionLabel!.text! += "Members of the \(name) species speak \(language)."
      }
      
    }
  }
  
}
