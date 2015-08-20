//
//  ViewController.swift
//  AlamofireDemo
//
//  Created by Christina Moulton on 2015-08-20.
//  Copyright (c) 2015 Teak Mobile Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  var species:Array<StarWarsSpecies>?
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
      if error != nil
      {
        // TODO: improved error handling
        self.isLoadingSpecies = false
        var alert = UIAlertController(title: "Error", message: "Could not load first species \(error?.localizedDescription)", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
      }
      self.addSpeciesFromWrapper(speciesWrapper)
      self.isLoadingSpecies = false
      self.tableview?.reloadData()
    })
  }
  
  func loadMoreSpecies()
  {
    self.isLoadingSpecies = true
    if self.species != nil && self.speciesWrapper != nil && self.species!.count < self.speciesWrapper!.count
    {
      // there are more species out there!
      StarWarsSpecies.getMoreSpecies(self.speciesWrapper, completionHandler: { (moreWrapper, error) in
        if error != nil
        {
          // TODO: improved error handling
          self.isLoadingSpecies = false
          var alert = UIAlertController(title: "Error", message: "Could not load more species \(error?.localizedDescription)", preferredStyle: UIAlertControllerStyle.Alert)
          alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
          self.presentViewController(alert, animated: true, completion: nil)
        }
        println("got more!")
        self.addSpeciesFromWrapper(moreWrapper)
        self.isLoadingSpecies = false
        self.tableview?.reloadData()
      })
    }
  }
  
  func addSpeciesFromWrapper(wrapper: SpeciesWrapper?)
  {
    self.speciesWrapper = wrapper
    if self.species == nil
    {
      self.species = self.speciesWrapper?.species
    }
    else if self.speciesWrapper != nil && self.speciesWrapper!.species != nil
    {
      self.species = self.species! + self.speciesWrapper!.species!
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: Tableview Delegate / Data Source
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if self.species == nil
    {
      return 0
    }
    return self.species!.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
    
    if self.species != nil && self.species!.count >= indexPath.row
    {
      let species = self.species![indexPath.row]
      cell.textLabel?.text = species.name
      cell.detailTextLabel?.text = species.classification
      
      // See if we need to load more species
      let rowsToLoadFromBottom = 5;
      let rowsLoaded = self.species!.count
      if (!self.isLoadingSpecies && (indexPath.row >= (rowsLoaded - rowsToLoadFromBottom)))
      {
        let totalRows = self.speciesWrapper!.count!
        let remainingSpeciesToLoad = totalRows - rowsLoaded;
        if (remainingSpeciesToLoad > 0)
        {
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

