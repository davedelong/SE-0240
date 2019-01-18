//
//  WagnerFisher.swift
//  Diffing
//
//  Created by Dave DeLong on 1/17/19.
//  Copyright © 2019 Syzygy. All rights reserved.
//

import Foundation

public struct WagnerFisher<T>: DiffingStrategy {
    
    public typealias Element = T
    
    public enum Change {
        case insert(Int, Element)
        case delete(Int)
        case replace(Int, Element)
    }
    
    private let equal: (T, T) -> Bool
    
    public init(equatingBy: @escaping (T, T) -> Bool) {
        equal = equatingBy
    }
    
    public func compute<C1, C2>(source: C1, destination: C2) -> Array<WagnerFisher<T>.Change> where C1 : Collection, C2 : Collection, WagnerFisher<T>.Element == C1.Element, C1.Element == C2.Element {
        
        let s = Array(source)
        let d = Array(destination)
        
        var previousRow = Array<Changes>()
        var p = Changes()
        previousRow.append(p)
        for index in 0 ..< s.count {
            p.insert(.delete(index), at: 0)
            previousRow.append(p)
        }
        
        var inserts = Changes()
        for (destIndex, destElement) in d.enumerated() {
            var thisRow = Array<Changes>()
            inserts.append(.insert(destIndex, destElement))
            thisRow.append(inserts)
            
            for (sourceIndex, sourceElement) in s.enumerated() {
                if equal(sourceElement, destElement) {
                    // no operation
                    thisRow.append(previousRow[sourceIndex])
                } else {
                    let willInsert = previousRow[sourceIndex+1]
                    let willDelete = thisRow[sourceIndex]
                    let willReplace = previousRow[sourceIndex]
                    
                    if willInsert.count < willDelete.count && willInsert.count < willReplace.count {
                        thisRow.append(willInsert + [.insert(destIndex, destElement)])
                    } else if willDelete.count < willInsert.count && willDelete.count < willReplace.count {
                        thisRow.append(willDelete + [.delete(sourceIndex)])
                    } else  {
                        thisRow.append(willReplace + [.replace(destIndex, destElement)])
                    }
                }
            }
            
            previousRow = thisRow
        }
        
        return sortChanges(previousRow.last ?? [])
    }
    
    private func sortChanges(_ changes: Changes) -> Changes {
        return changes.sorted(by: { l, r -> Bool in
            switch (l, r) {
                case (.delete(let lD), .delete(let rD)): return lD > rD
                case (.delete(_), _): return true
                
                case (.insert(let lI, _), .insert(let rI, _)): return lI < rI
                case (.insert(_), _): return true
                
                case (.replace(let lR, _), .replace(let rR, _)): return lR < rR
                default: return true
            }
        })
    }
    
    public func apply<C>(changes: Array<WagnerFisher<T>.Change>, to collection: C) -> Array<T> where C : Collection, WagnerFisher<T>.Element == C.Element {
        var current = Array(collection)
        for change in changes {
            switch change {
                case .insert(let i, let e): current.insert(e, at: i)
                case .delete(let d): current.remove(at: d)
                case .replace(let r, let e): current[r] = e
            }
        }
        return current
    }
    
}

extension WagnerFisher where T: Equatable {
    
    public init() {
        self.init(equatingBy: { $0 == $1 })
    }
    
}
