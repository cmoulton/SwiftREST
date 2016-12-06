//
//  StringArrayConvertible.swift
//  SwiftRest
//
//  Created by Christina Moulton on 2016-12-06.
//  Copyright © 2016 Teak Mobile Inc. All rights reserved.
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
