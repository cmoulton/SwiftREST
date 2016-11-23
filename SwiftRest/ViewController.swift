//
//  ViewController.swift
//  AlamofireDemo
//
//  Created by Christina Moulton on 2015-02-11.
//  Copyright (c) 2015 Teak Mobile Inc. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchResultsUpdating {
  var species: [StarWarsSpecies]?
  var speciesWrapper: SpeciesWrapper? // holds the last wrapper that we've loaded
  var isLoadingSpecies = false
  var imageCache: Dictionary<String, ImageSearchResult?>?
  
  var speciesSearchResults: [StarWarsSpecies]?
  
  @IBOutlet weak var tableview: UITableView?
  var searchController: UISearchController = UISearchController(searchResultsController: nil)
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    searchController.searchResultsUpdater = self
    searchController.dimsBackgroundDuringPresentation = false
    searchController.searchBar.scopeButtonTitles = ["Name", "Language", "Classification"]
    searchController.searchBar.delegate = self
    
    tableview?.tableHeaderView = searchController.searchBar
    definesPresentationContext = true

    imageCache = Dictionary<String, ImageSearchResult>()
    
    self.loadFirstSpecies()
  }
  
  // MARK: Loading Species from API
  
  func loadFirstSpecies() {
    isLoadingSpecies = true
    StarWarsSpecies.getSpecies({ result in
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
    })
  }
  
  func loadMoreSpecies() {
    self.isLoadingSpecies = true
    if let species = self.species,
      let wrapper = self.speciesWrapper,
      let totalSpeciesCount = wrapper.count,
      species.count < totalSpeciesCount {
      // there are more species out there!
      StarWarsSpecies.getMoreSpecies(speciesWrapper, completionHandler: { result in
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
      })
    }
  }
  
  func addSpeciesFromWrapper(_ wrapper: SpeciesWrapper?)
  {
    self.speciesWrapper = wrapper
    if self.species == nil {
      self.species = self.speciesWrapper?.species
    } else if self.speciesWrapper != nil && self.speciesWrapper!.species != nil {
      self.species = self.species! + self.speciesWrapper!.species!
    }
  }
  
  // MARK: TableViewDataSource
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if searchController.isActive {
      return self.speciesSearchResults?.count ?? 0
    } else {
      return self.species?.count ?? 0
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = self.tableview!.dequeueReusableCell(withIdentifier: "Cell")! as UITableViewCell
    
    var arrayOfSpecies: [StarWarsSpecies]?
    if searchController.isActive {
      arrayOfSpecies = self.speciesSearchResults
    } else {
      arrayOfSpecies = self.species
    }
    
    if arrayOfSpecies != nil && arrayOfSpecies!.count >= indexPath.row {
      let species = arrayOfSpecies![indexPath.row]
      cell.textLabel?.text = species.name
      cell.detailTextLabel?.text = " " // if it's empty or nil it won't update correctly in iOS 8, see http://stackoverflow.com/questions/25793074/subtitles-of-uitableviewcell-wont-update
      cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
      cell.imageView?.image = nil
      if let name = species.name {
        // check the cache first
        if let cachedImageResult = imageCache?[name] {
          // TODO: custom cell with class assigned for custom view?
          cell.imageView?.image = cachedImageResult?.image // will work fine even if image is nil
          if let attribution = cachedImageResult?.fullAttribution(), attribution.isEmpty == false {
            cell.detailTextLabel?.text = attribution
          }
        } else {
          // didn't find it, so pull it down from the web
          // this isn't ideal since it will keep running even if the cell scrolls off of the screen
          // if we had lots of cells we'd want to stop this process when the cell gets reused
          duckDuckGoSearchController.imageFromSearchString(name, completionHandler: {
            result in
            if let error = result.error {
              print(error)
            }
            // TODO: persist cache between runs
            let imageSearchResult = result.value
            self.imageCache![name] = imageSearchResult
            if let cellToUpdate = self.tableview?.cellForRow(at: indexPath) {
              if cellToUpdate.imageView?.image == nil {
                cellToUpdate.imageView?.image = imageSearchResult?.image // will work fine even if image is nil
                cellToUpdate.detailTextLabel?.text = imageSearchResult?.fullAttribution()
                cellToUpdate.setNeedsLayout() // need to reload the view, which won't happen otherwise since this is in an async call
              }
            }
          })
        }
      }

      if !searchController.isActive {
        // See if we need to load more species
        let rowsToLoadFromBottom = 5;
        let rowsLoaded = self.species!.count
        if (!self.isLoadingSpecies && (indexPath.row >= (rowsLoaded - rowsToLoadFromBottom))) {
          if let totalRows = self.speciesWrapper?.count {
            let remainingSpeciesToLoad = totalRows - rowsLoaded;
            if (remainingSpeciesToLoad > 0) {
              self.loadMoreSpecies()
            }
          }
        }
      }
    }
    
    return cell
  }
    
  // MARK: Segue
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)
    if let speciesDetailVC = segue.destination as? SpeciesDetailViewController {
        // gotta check if we're currently searching
      guard let indexPath = self.tableview?.indexPathForSelectedRow else {
        return
      }
      if searchController.isActive {
        speciesDetailVC.species = self.speciesSearchResults?[indexPath.row]
      } else {
        speciesDetailVC.species = self.species?[indexPath.row]
      }
    }
  }
  
  // MARK: Search
  func filterContentForSearchText(_ searchText: String, scope: Int) {
    // Filter the array using the filter method
    if self.species == nil {
      self.speciesSearchResults = nil
      return
    }
    self.speciesSearchResults = self.species!.filter({(aSpecies: StarWarsSpecies) -> Bool in
      // pick the field to search
      let fieldToSearch: String?
      switch (scope) {
        case (0):
          fieldToSearch = aSpecies.name
        case (1):
          fieldToSearch = aSpecies.language
        case (2):
          fieldToSearch = aSpecies.classification
        default:
          fieldToSearch = nil
      }
      guard let field = fieldToSearch else {
        self.speciesSearchResults = nil
        return false
      }
      return field.lowercased().range(of: searchText.lowercased()) != nil
    })
  }
  
  // NEW
  func updateSearchResults(for searchController: UISearchController) {
    let selectedIndex = searchController.searchBar.selectedScopeButtonIndex
    let searchString = searchController.searchBar.text ?? ""
    filterContentForSearchText(searchString, scope: selectedIndex)
    tableview?.reloadData()
  }
  
  func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
    let selectedIndex = searchBar.selectedScopeButtonIndex
    let searchString = searchBar.text ?? ""
    filterContentForSearchText(searchString, scope: selectedIndex)
    tableview?.reloadData()
  }
}
