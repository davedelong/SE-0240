//
//  Collection.swift
//  Diffing
//
//  Created by Dave DeLong on 1/17/19.
//  Copyright © 2019 Syzygy. All rights reserved.
//

import Foundation

public extension Collection {
    
    func computeChanges<C: Collection, D: DiffingStrategy>(to other: C, using strategy: D) -> D.Changes where C.Element == Element, D.Element == Element {
        return strategy.compute(source: self, destination: other)
    }
    
    func applyingChanges<D: DiffingStrategy>(_ changes: D.Changes, using strategy: D) -> Array<Element> where D.Element == Element {
        return strategy.apply(changes: changes, to: self)
    }
    
}

public extension Collection where Element: Equatable {
    
    public func computeChanges<C: Collection>(to other: C) -> WagnerFisher<Element>.Changes where C.Element == Element {
        return computeChanges(to: other, using: WagnerFisher())
    }
    
    public func computeChangesInferringMoves<C: Collection>(to other: C) -> WagnerFisherMoves<Element>.Changes where C.Element == Element {
        return computeChanges(to: other, using: WagnerFisherMoves())
    }
    
    public func applyingChanges(_ changes: WagnerFisher<Element>.Changes) -> Array<Element> {
        return applyingChanges(changes, using: WagnerFisher())
    }
    
    public func applyingChanges(_ changes: WagnerFisherMoves<Element>.Changes) -> Array<Element> {
        return applyingChanges(changes, using: WagnerFisherMoves())
    }
    
}
