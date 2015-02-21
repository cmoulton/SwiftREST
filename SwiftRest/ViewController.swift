//
//  ViewController.swift
//  AlamofireDemo
//
//  Created by Christina Moulton on 2015-02-11.
//  Copyright (c) 2015 Teak Mobile Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  var posts:Array<Post>?
  @IBOutlet weak var tableview: UITableView?
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    Post.getPosts({ (postsFromAPI, error) in
      self.posts = postsFromAPI
      self.tableview?.reloadData()
    })
  }
  
  // MARK: TableViewDataSource
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if self.posts == nil
    {
      return 0
    }
    return self.posts!.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
    
    if self.posts != nil && self.posts!.count > 0
    {
      let post = self.posts![indexPath.row]
      cell.textLabel?.text = post.title
      cell.detailTextLabel?.text = post.body
    }
    
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
  }
  
}
