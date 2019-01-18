//
//  DiffingStrategy.swift
//  Diffing
//
//  Created by Dave DeLong on 1/17/19.
//  Copyright © 2019 Syzygy. All rights reserved.
//

import Foundation

public protocol DiffingStrategy {
    associatedtype Change
    associatedtype Element
    associatedtype Changes = Array<Change>
    
    func apply<C: Collection>(changes: Changes, to collection: C) -> Array<Element> where C.Element == Element
    
    func compute<C1: Collection, C2: Collection>(source: C1, destination: C2) -> Changes where C1.Element == Element, C2.Element == Element
}
