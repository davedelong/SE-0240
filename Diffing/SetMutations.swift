//
//  SetMutations.swift
//  Diffing
//
//  Created by Dave DeLong on 1/17/19.
//  Copyright © 2019 Syzygy. All rights reserved.
//

import Foundation

public struct SetMutations<T: Hashable>: DiffingStrategy {
    
    public typealias Element = T
    
    public enum Change {
        case insert(T)
        case remove(T)
    }
    
    public func compute<C1, C2>(source: C1, destination: C2) -> Array<SetMutations<T>.Change> where C1 : Collection, C2 : Collection, SetMutations<T>.Element == C1.Element, C1.Element == C2.Element {
        
        let s = Set(source)
        let d = Set(destination)
        
        let insertions = d.subtracting(s)
        let removals = s.subtracting(d)
        
        var changes = Changes()
        changes.append(contentsOf: insertions.map { .insert($0) })
        changes.append(contentsOf: removals.map { .remove($0) })
        return changes
    }
    
    public func apply<C>(changes: Array<SetMutations<T>.Change>, to collection: C) -> Array<T> where C : Collection, T == C.Element {
        var current = Set(collection)
        
        for change in changes {
            switch change {
                case .insert(let e): current.insert(e)
                case .remove(let e): current.remove(e)
            }
        }
        return Array(current)
    }
    
}
