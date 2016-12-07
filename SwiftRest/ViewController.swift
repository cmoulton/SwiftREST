//
//  ViewController.swift
//  AlamofireDemo
//
//  Created by Christina Moulton on 2015-02-11.
//  Copyright (c) 2015 Teak Mobile Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  var species: [StarWarsSpecies]?
  var speciesWrapper: SpeciesWrapper? // holds the last wrapper that we've loaded
  var isLoadingSpecies = false
  
  @IBOutlet weak var tableview: UITableView?
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // place tableview below status bar, cuz I think it's prettier that way
    self.tableview?.contentInset = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0);
    
    self.loadFirstSpecies()
  }
  
  // MARK: Loading Species from API
  func loadFirstSpecies() {
    isLoadingSpecies = true
    StarWarsSpecies.getSpecies { result in
      if let error = result.error {
        // TODO: improved error handling
        self.isLoadingSpecies = false
        let alert = UIAlertController(title: "Error", message: "Could not load first species :( \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
      }
      let speciesWrapper = result.value
      self.addSpeciesFromWrapper(speciesWrapper)
      self.isLoadingSpecies = false
      self.tableview?.reloadData()
    }
  }
  
  func loadMoreSpecies() {
    self.isLoadingSpecies = true
    if let species = self.species,
      let wrapper = self.speciesWrapper,
      let totalSpeciesCount = wrapper.count,
      species.count < totalSpeciesCount {
      // there are more species out there!
      StarWarsSpecies.getMoreSpecies(speciesWrapper) { result in
        if let error = result.error {
          self.isLoadingSpecies = false
          let alert = UIAlertController(title: "Error", message: "Could not load more species :( \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
          alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
          self.present(alert, animated: true, completion: nil)
        }
        let moreWrapper = result.value
        self.addSpeciesFromWrapper(moreWrapper)
        self.isLoadingSpecies = false
        self.tableview?.reloadData()
      }
    }
  }
  
  func addSpeciesFromWrapper(_ wrapper: SpeciesWrapper?) {
    self.speciesWrapper = wrapper
    if self.species == nil {
      self.species = self.speciesWrapper?.species
    } else if self.speciesWrapper != nil && self.speciesWrapper!.species != nil {
      self.species = self.species! + self.speciesWrapper!.species!
    }
  }
  // MARK: TableViewDataSource
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if self.species == nil {
      return 0
    }
    return self.species!.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    
    if let species = species, species.count >= indexPath.row {
      let speciesToShow = species[indexPath.row]
      cell.textLabel?.text = speciesToShow.name
      cell.detailTextLabel?.text = " "
      cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
      cell.imageView?.image = nil
      if let name = speciesToShow.name {
        // this isn't ideal since it will keep running even if the cell scrolls off of the screen
        // if we had lots of cells we'd want to stop this process when the cell gets reused
        DuckDuckGoSearchController.image(for: name) {
          result in
          if let error = result.error {
            print(error)
          }
          let imageSearchResult = result.value
          if let cellToUpdate = self.tableview?.cellForRow(at: indexPath),
            cellToUpdate.imageView?.image == nil {
            cellToUpdate.imageView?.image = imageSearchResult?.image // will work fine even if image is nil
            cellToUpdate.detailTextLabel?.text = imageSearchResult?.fullAttribution()
            cellToUpdate.setNeedsLayout() // need to reload the view, which won't happen otherwise since this is in an async call
          }
        }
      }
      
      // See if we need to load more species
      let rowsToLoadFromBottom = 5;
      let rowsLoaded = species.count
      if (!self.isLoadingSpecies && (indexPath.row >= (rowsLoaded - rowsToLoadFromBottom))) {
        let totalRows = self.speciesWrapper?.count ?? 0
        let remainingSpeciesToLoad = totalRows - rowsLoaded;
        if (remainingSpeciesToLoad > 0) {
          self.loadMoreSpecies()
        }
      }
    }
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
  }
  
  // alternate row colors
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if indexPath.row % 2 == 0 {
      cell.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0) // very light gray
    } else {
      cell.backgroundColor = UIColor.white
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)
    
    if let speciesDetailVC = segue.destination as? SpeciesDetailViewController {
      if let indexPath = self.tableview?.indexPathForSelectedRow {
        speciesDetailVC.species = self.species?[indexPath.row]
      }
    }
  }
  
}
