//
//  Array+Utils.swift
//  dailybibleverse
//
//  Created by Agustin Bivachi on 10/1/16.
//  Copyright © 2016 Emiliano Bivachi. All rights reserved.
//

import Foundation

extension Array {
    
    /// Performs closure with each element
    func each(_ each: (Element) -> ()) {
        for object: Element in self {
            each(object)
        }
    }
    
    /// Safe Object at index
    func safeIndex(_ index: Int) -> Element? {
        if index >= 0 && index < count {
            return Optional(self[index])
        } else {
            return nil
        }
    }
}
