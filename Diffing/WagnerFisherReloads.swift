//
//  WagnerFisherReloads.swift
//  Diffing
//
//  Created by Dave DeLong on 1/18/19.
//  Copyright © 2019 Syzygy. All rights reserved.
//

import Foundation

public struct WagnerFisherReloads<T>: DiffingStrategy {
    
    public typealias Element = T
    
    public enum Change {
        case insert(Int, Element)
        case delete(Int)
        case replace(Int, Element)
        case reload(Int, Element)
    }
    
    private enum Position {
        case located(Int)
        case removed
        case replaced
        
        var location: Int? {
            guard case .located(let l) = self else { return nil }
            return l
        }
        
        func shift(_ delta: Int) -> Position {
            guard case .located(let l) = self else { return self }
            return .located(l + delta)
        }
    }
    
    private let equal: (T, T) -> Bool
    private let identical: (T, T) -> Bool
    
    public init(equatingBy: @escaping (T, T) -> Bool, identifyingBy: @escaping (T, T) -> Bool) {
        equal = equatingBy
        identical = identifyingBy
    }
    
    public func apply<C>(changes: Array<WagnerFisherReloads<T>.Change>, to collection: C) -> Array<T> where C : Collection, WagnerFisherReloads<T>.Element == C.Element {
        var current = Array(collection)
        for change in changes {
            switch change {
                case .insert(let i, let e): current.insert(e, at: i)
                case .delete(let d): current.remove(at: d)
                case .replace(let r, let e): current[r] = e
                case .reload(let r, let e): current[r] = e
            }
        }
        return current
    }
    
    public func compute<C1, C2>(source: C1, destination: C2) -> Array<WagnerFisherReloads<T>.Change> where C1 : Collection, C2 : Collection, WagnerFisherReloads<T>.Element == C1.Element, C1.Element == C2.Element {
        let wfChanges = WagnerFisher(equatingBy: equal).compute(source: source, destination: destination)
        
        let s = Array(source)
        let d = Array(destination)
        
        var correspondingIndexes = s.indices.map { Position.located($0) }
        
        var finalChanges = Changes()
        for change in wfChanges {
            switch change {
                case .delete(let d):
                    finalChanges.append(.delete(d))
                    correspondingIndexes[d] = .removed
                    for p in (d+1) ..< correspondingIndexes.count {
                        correspondingIndexes[p] = correspondingIndexes[p].shift(-1)
                    }
                case .insert(let i, let e):
                    finalChanges.append(.insert(i, e))
                    for p in i ..< correspondingIndexes.count {
                        correspondingIndexes[p] = correspondingIndexes[p].shift(+1)
                    }
                case .replace(let r, let e):
                    finalChanges.append(.replace(r, e))
                    correspondingIndexes[r] = .replaced
            }
        }
        
        for (originalIndex, position) in correspondingIndexes.enumerated() {
            guard let newIndex = position.location else { continue }
            let oldValue = s[originalIndex]
            let newValue = d[newIndex]
            
            if identical(oldValue, newValue) == true { continue }
            finalChanges.append(.reload(newIndex, newValue))
        }
        
        return finalChanges
    }
    
    
}

extension WagnerFisherReloads where T: Equatable {
    
    public init(identifyingBy: @escaping (T, T) -> Bool) {
        self.init(equatingBy: { $0 == $1 }, identifyingBy: identifyingBy)
    }
    
}
