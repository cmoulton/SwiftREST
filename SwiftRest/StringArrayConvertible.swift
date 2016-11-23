//
//  StringArrayConvertible.swift
//  Pods
//
//  Created by Christina Moulton on 2015-03-07.
//
//

import Foundation

extension String {
  func splitStringToArray() -> [String] {
    var outputArray = [String]()
    
    let components = self.components(separatedBy: ",")
    for component in components {
      let trimmedComponent = component.trimmingCharacters(in: CharacterSet.whitespaces)
      outputArray.append(trimmedComponent)
    }
    
    return outputArray
  }
}
