//
//  ViewController.swift
//  AlamofireDemo
//
//  Created by Christina Moulton on 2015-08-20.
//  Copyright (c) 2015 Teak Mobile Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  var species:[StarWarsSpecies]?
  var speciesWrapper:SpeciesWrapper? // holds the last wrapper that we've loaded
  var isLoadingSpecies = false
  
  @IBOutlet weak var tableview: UITableView?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // place tableview below status bar, cuz I think it's prettier that way
    self.tableview?.contentInset = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0);
    
    self.loadFirstSpecies()
  }
  
  func loadFirstSpecies()
  {
    isLoadingSpecies = true
    StarWarsSpecies.getSpecies({ (speciesWrapper, error) in
      guard error == nil else {
        // TODO: improved error handling
        self.isLoadingSpecies = false
        let alert = UIAlertController(title: "Error", message: "Could not load first species \(error?.localizedDescription)", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        return
      }
      self.addSpeciesFromWrapper(speciesWrapper)
      self.isLoadingSpecies = false
      self.tableview?.reloadData()
    })
  }
  
  func loadMoreSpecies()
  {
    self.isLoadingSpecies = true
    guard let species = self.species, let wrapper = self.speciesWrapper where species.count < wrapper.count else {
      // no more species to fetch
      return
    }
    // there are more species out there
    StarWarsSpecies.getMoreSpecies(self.speciesWrapper, completionHandler: { (moreWrapper, error) in
      guard error == nil else {
        // TODO: improved error handling
        self.isLoadingSpecies = false
        let alert = UIAlertController(title: "Error", message: "Could not load more species \(error?.localizedDescription)", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        return
      }
      print("got more species")
      self.addSpeciesFromWrapper(moreWrapper)
      self.isLoadingSpecies = false
      self.tableview?.reloadData()
    })
  }
  
  func addSpeciesFromWrapper(wrapper: SpeciesWrapper?) {
    self.speciesWrapper = wrapper
    if self.species == nil {
      self.species = self.speciesWrapper?.species
    } else if let newSpecies = self.speciesWrapper?.species, let currentSpecies = self.species {
      self.species = currentSpecies + newSpecies
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: Tableview Delegate / Data Source
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let species = self.species else {
      return 0
    }
    return species.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) 
    
    if let numberOfSpecies = self.species?.count where numberOfSpecies >= indexPath.row {
      if let species = self.species?[indexPath.row] {
        cell.textLabel?.text = species.name
        cell.detailTextLabel?.text = species.classification
      }
      
      // See if we need to load more species
      let rowsToLoadFromBottom = 5;
      if !self.isLoadingSpecies && indexPath.row >= (numberOfSpecies - rowsToLoadFromBottom) {
        if let totalSpeciesCount = self.speciesWrapper?.count where totalSpeciesCount - numberOfSpecies > 0 {
          self.loadMoreSpecies()
        }
      }
    }
    
    return cell
  }
  
  func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    if indexPath.row % 2 == 0
    {
      cell.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0) // very light gray
    }
    else
    {
      cell.backgroundColor = UIColor.whiteColor()
    }
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
  }
}

