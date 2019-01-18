//
//  WagnerFisherMoves.swift
//  Diffing
//
//  Created by Dave DeLong on 1/17/19.
//  Copyright © 2019 Syzygy. All rights reserved.
//

import Foundation

public struct WagnerFisherMoves<T>: DiffingStrategy {
    
    public typealias Element = T
    
    public enum Change {
        case insert(Int, Element)
        case delete(Int)
        case replace(Int, Element)
        case move(Int, Int)
    }
    
    private let equal: (T, T) -> Bool
    
    public init(equatingBy: @escaping (T, T) -> Bool) {
        equal = equatingBy
    }
    
    public func compute<C1, C2>(source: C1, destination: C2) -> Array<WagnerFisherMoves<T>.Change> where C1 : Collection, C2 : Collection, T == C1.Element, C1.Element == C2.Element {
        
        let wfChanges = WagnerFisher<T>(equatingBy: equal).compute(source: source, destination: destination)
        
        let s = Array(source)
        
        // now that we have these edits, we can see if we delete+insert the same item
        var finalChanges = Changes()
        var handledIndexes = Set<Int>()
        
        for (index, change) in wfChanges.enumerated() {
            if handledIndexes.contains(index) { continue }
            
            var newChange: Change
            switch change {
                case .insert(let i, let e): newChange = .insert(i, e)
                case .delete(let d): newChange = .delete(d)
                case .replace(let r, let e): newChange = .replace(r, e)
            }
            
            for (otherIndex, otherChange) in wfChanges.enumerated() {
                if index == otherIndex { continue }
                switch (change, otherChange) {
                    case let (.insert(newIndex, newElement), .delete(oldIndex)) where equal(newElement, s[oldIndex]) == true:
                        newChange = .move(oldIndex, newIndex)
                        handledIndexes.insert(otherIndex)
                        break
                    case let (.delete(oldIndex), .insert(newIndex, newElemenet)) where equal(newElemenet, s[oldIndex]) == true:
                        newChange = .move(oldIndex, newIndex)
                        handledIndexes.insert(otherIndex)
                        break
                    default:
                        break
                }
            }
            finalChanges.append(newChange)
        }
        
        return sortChanges(finalChanges)
    }
    
    private func sortChanges(_ changes: Changes) -> Changes {
        return changes.sorted(by: { l, r -> Bool in
            switch (l, r) {
                case (.delete(let lD), .delete(let rD)): return lD > rD
                case (.delete(_), _): return true
                
                case (.insert(let lI, _), .insert(let rI, _)): return lI < rI
                case (.insert(_), _): return true
                
                case (.move(let lO, let lN), .move(let rO, let rN)):
                    if lO < rO { return true }
                    if rO < lO { return false }
                    if lN < rN { return true }
                    return false
                case (.move(_), _): return true
                
                case (.replace(let lR, _), .replace(let rR, _)): return lR < rR
                default: return true
            }
        })
    }
    
    public func apply<C>(changes: Array<WagnerFisherMoves<T>.Change>, to collection: C) -> Array<T> where C : Collection, T == C.Element {
        var current = Array(collection)
        
        for change in changes {
            switch change {
                case .insert(let i, let e): current.insert(e, at: i)
                case .delete(let d): current.remove(at: d)
                case .replace(let r, let e): current[r] = e
                case .move(let o, let n):
                    let e = current[o]
                    current.remove(at: o)
                    current.insert(e, at: n)
            }
        }
        
        return current
    }
    
}

extension WagnerFisherMoves where T: Equatable {
    
    public init() {
        self.init(equatingBy: { $0 == $1 })
    }
    
}
