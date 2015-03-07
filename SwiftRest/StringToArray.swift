//
//  StringToArray.swift
//  Pods
//
//  Created by Christina Moulton on 2015-03-07.
//
//

import Foundation

public protocol StringArrayConvertible {
  func splitStringToArray() -> Array<String>?
}

extension String: StringArrayConvertible {
  public func splitStringToArray() -> Array<String>?
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
