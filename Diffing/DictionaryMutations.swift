//
//  DictionaryMutations.swift
//  Diffing
//
//  Created by Dave DeLong on 1/17/19.
//  Copyright © 2019 Syzygy. All rights reserved.
//

import Foundation

public struct DictionaryMutations<Key: Hashable, Value>: DiffingStrategy {
    
    public typealias Element = Dictionary<Key, Value>.Element
    
    public enum Change {
        case remove(Key)
        case add(Key, Value)
        case replace(Key, Value)
    }
    
    private let equalValues: (Value, Value) -> Bool
    
    public init(equatingValuesBy: @escaping (Value, Value) -> Bool) {
        equalValues = equatingValuesBy
    }
    
    private func makeDictionary<C: Collection>(from collection: C) -> Dictionary<Key, Value> where C.Element == Element {
        var d = Dictionary<Key, Value>()
        for (key, value) in collection {
            d[key] = value
        }
        return d
    }
    
    public func compute<C1, C2>(source: C1, destination: C2) -> Array<Change> where C1 : Collection, C2 : Collection, C1.Element == Element, C1.Element == C2.Element {
        let s = makeDictionary(from: source)
        let d = makeDictionary(from: destination)
    
        let sKeys = Set(s.keys)
        let dKeys = Set(d.keys)
        
        let addedKeys = dKeys.subtracting(sKeys)
        let removedKeys = sKeys.subtracting(dKeys)
        
        let potentiallyChangedValues = sKeys.intersection(dKeys)
        
        var changes = Array<Change>()
        
        changes.append(contentsOf: removedKeys.map { .remove($0) })
        changes.append(contentsOf: addedKeys.map { .add($0, d[$0]!) })
        
        for key in potentiallyChangedValues {
            guard let oldValue = s[key], let newValue = d[key] else { continue }
            if equalValues(oldValue, newValue) == false {
                changes.append(.replace(key, newValue))
            }
        }
        
        return changes
    }
    
    public func apply<C>(changes: Array<Change>, to collection: C) -> Array<Element> where C : Collection, Element == C.Element {
        var final = makeDictionary(from: collection)
        for change in changes {
            switch change {
                case .remove(let k): final.removeValue(forKey: k)
                case .add(let k, let v): final[k] = v
                case .replace(let k, let v): final[k] = v
            }
        }
        return Array(final)
    }
    
}

extension DictionaryMutations where Value: Equatable {
    
    public init() {
        self.init(equatingValuesBy: { $0 == $1 })
    }
    
}
