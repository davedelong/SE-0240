//
//  main.swift
//  Diffing
//
//  Created by Dave DeLong on 1/17/19.
//  Copyright © 2019 Syzygy. All rights reserved.
//

import Foundation

let s = Array("kitten")
let d = Array("sitting")

let changes = s.computeChanges(to: d)

var progress = s

print("start: \(String(s))")
for change in changes {
    switch change {
        case .insert(let i, let e):
            print("insert character at \(i): \(e)")
            progress.insert(d[i], at: i)
        case .delete(let d):
            print("delete character at \(d): \(s[d])")
            progress.remove(at: d)
        case .replace(let r, let e):
            print("replace character at \(r): \(s[r]) -> \(e)")
            progress[r] = d[r]
    }
    
    let p = String(progress)
    print("change: \(p)")
}

let s1 = Array("abcdefg")
let d1 = Array("bcdfga")
let changes1 = s1.computeChangesInferringMoves(to: d1)
let changed1 = s1.applyingChanges(changes1)

print("start: \(String(s1))")
print("changes: \(changes1)")
print("expected: \(String(d1))")
print("actual: \(String(changed1))")

var current1 = s1

print("start: \(String(current1))")
for change in changes1 {
    switch change {
        case .insert(let i, let e):
            current1.insert(e, at: i)
        case .delete(let d):
            current1.remove(at: d)
        case .replace(let r, let e):
            current1[r] = e
        case .move(let o, let n):
            let e = current1.remove(at: o)
            current1.insert(e, at: n)
    }
    let p = String(current1)
    print("next: \(p)")
}

let set1 = Set(["a", "b", "c", "d"])
let set2 = Set(["b", "c", "e"])
let setChanges = set1.computeChanges(to: set2, using: SetMutations())
// insert("e"), remove("d"), remove("a")
print("set changes: \(setChanges)")

let dict1 = ["a": 1, "b": 2]
let dict2 = ["b": 3, "c": 4]
let dictChanges = dict1.computeChanges(to: dict2, using: DictionaryMutations<String, Int>())
// .add("c", 4), .remove("a"), .replace("b", 3)
print("dictionary changes: \(dictChanges)")

struct Identified {
    let id: String
    let value: Int
    
    func equals(_ other: Identified) -> Bool { return id == other.id }
    func identical(to other: Identified) -> Bool { return id == other.id && value == other.value }
}

let id1 = [Identified(id: "a", value: 1), Identified(id: "b", value: 2), Identified(id: "c", value: 3)]
let id2 = [Identified(id: "a", value: 0), Identified(id: "b", value: 2), Identified(id: "d", value: 4)]
let idChanges = id1.computeChanges(to: id2, using: WagnerFisherReloads(equatingBy: { $0.equals($1) }, identifyingBy: { $0.identical(to: $1) }))
print("\(idChanges)")
