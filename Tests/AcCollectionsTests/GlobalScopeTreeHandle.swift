//
//  File.swift
//  
//
//  Created by narumij on 2024/09/11.
//

import Foundation
@testable import AcCollections

struct GlobalScopeTreeHandle: TreeHandleProtocol {
    var __begin: BasePtr {
        fatalError("not implemented")
    }
    var __end_left_: BasePtr {
        get { _left }
        nonmutating set { _left = newValue }
    }
    var __data: [NodeItem] {
        get { _data }
        nonmutating set { _data = newValue }
    }
    subscript(index: Int) -> NodeItem {
        get { __data[index] }
        nonmutating set { __data[index] = newValue }
    }
}
