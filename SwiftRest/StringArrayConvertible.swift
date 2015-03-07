//
//  StringArrayConvertible.swift
//  Pods
//
//  Created by Christina Moulton on 2015-03-07.
//
//

import Foundation

extension String {
  func splitStringToArray() -> Array<String>
  {
    var outputArray = Array<String>()
    
    let components = self.componentsSeparatedByString(",")
    for component in components
    {
      let trimmedComponent = component.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
      outputArray.append(trimmedComponent)
    }
    
    return outputArray
  }
}
