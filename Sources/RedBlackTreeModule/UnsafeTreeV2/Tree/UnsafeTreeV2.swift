// Copyright 2024-2026 narumij
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// This code is based on work originally distributed under the Apache License 2.0 with LLVM Exceptions:
//
// Copyright © 2003-2025 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.

public struct UnsafeTreeV2<Base: ___TreeBase> {

  @inlinable
  internal init(
    _buffer: ManagedBufferPointer<Header, UnsafeTreeV2Origin>,
    isReadOnly: Bool = false
  ) {
    self._buffer = _buffer
    self.isReadOnly = isReadOnly
    let origin = _buffer.withUnsafeMutablePointerToElements { $0 }
    self.nullptr = origin.pointee.nullptr
    self.end = origin.pointee.end_ptr
    self.origin = origin
  }

  public typealias Base = Base
  public typealias Tree = UnsafeTreeV2<Base>
  public typealias Header = UnsafeTreeV2Buffer<Base._Value>.Header
  public typealias Buffer = ManagedBuffer<Header, UnsafeTreeV2Origin>
  public typealias BufferPointer = ManagedBufferPointer<Header, UnsafeTreeV2Origin>
  public typealias _Key = Base._Key
  public typealias _Value = Base._Value
  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>
  public typealias _NodeRef = UnsafeMutablePointer<UnsafeMutablePointer<UnsafeNode>>

  @usableFromInline
  var _buffer: BufferPointer

  public let nullptr, end: _NodePtr

  @usableFromInline
  let isReadOnly: Bool

  @usableFromInline
  let origin: UnsafeMutablePointer<UnsafeTreeV2Origin>

  /// ノードプールの寿命延長オブジェクト
  ///
  /// 元々はデアロケータだったが、添字アクセスが追加されている
  ///
  /// ここを境に名前が変わる
  @usableFromInline
  var poolLifespan: Deallocator {
    withMutableHeader { $0.deallocator }
  }
}

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  public var count: Int { withMutableHeader { $0.count } }

  #if !DEBUG
    @inlinable
    @inline(__always)
    public var capacity: Int { withMutableHeader { $0.freshPoolCapacity } }

    @inlinable
    @inline(__always)
    public var initializedCount: Int { withMutableHeader { $0.freshPoolUsedCount } }
  #else
    @inlinable
    public var capacity: Int {
      get { _buffer.header.freshPoolCapacity }
      set {
        // TODO: setterが必要なテストをsetter不要にする
        _buffer.withUnsafeMutablePointerToHeader {
          $0.pointee.freshPoolCapacity = newValue
        }
      }
    }

    @inlinable
    public var initializedCount: Int {
      get { _buffer.header.freshPoolUsedCount }
      set {
        // TODO: setterが必要なテストをsetter不要にする
        _buffer.withUnsafeMutablePointerToHeader {
          $0.pointee.freshPoolUsedCount = newValue
        }
      }
    }
  #endif
}

extension UnsafeTreeV2 {

  // _NodePtrがIntだった頃の名残
  @nonobjc
  @inlinable
  internal subscript(_ pointer: _NodePtr) -> _Value {
    @inline(__always) _read {
      assert(___initialized_contains(pointer))
      yield UnsafeNode.valuePointer(pointer).pointee
    }
    @inline(__always) _modify {
      assert(___initialized_contains(pointer))
      yield &UnsafeNode.valuePointer(pointer).pointee
    }
  }
}

extension UnsafeTreeV2 {

  /// O(1)
  @inlinable
  @inline(__always)
  internal func deinitialize() {
    withMutables { header, origin in
      header.deinitialize()
      origin.clear()
    }
  }
}

// MARK: Refresh Pool Iterator

//#if USE_FRESH_POOL_V1
#if !USE_FRESH_POOL_V2
  extension UnsafeTreeV2 {

    @inlinable
    @inline(__always)
    func makeFreshPoolIterator() -> _UnsafeNodeFreshPoolIterator<_Value> {
      return _buffer.header.makeFreshPoolIterator()
    }
  }

  extension UnsafeTreeV2 {

    @inlinable
    @inline(__always)
    func makeFreshBucketIterator() -> _UnsafeNodeFreshBucketIterator<_Value> {
      return _UnsafeNodeFreshBucketIterator<_Value>(bucket: _buffer.header.freshBucketHead)
    }
  }
#else
  extension UnsafeTreeV2 {

    @inlinable
    @inline(__always)
    func makeFreshPoolIterator() -> UnsafeNodeFreshPoolV2Iterator<_Value> {
      return _buffer.header.makeFreshPoolIterator()
    }
  }
#endif

// MARK: Index Resolver

extension UnsafeTreeV2 {

  // TODO: 名前が安直すぎる。いつか変更する
  @inlinable
  @inline(__always)
  package func ___NodePtr(_ p: Int) -> _NodePtr {
    switch p {
    case .nullptr:
      return nullptr
    case .end:
      return end
    default:
      return _buffer.header[p]
    }
  }

  /// インデックスをポインタに解決する
  ///
  /// 木が同一の場合、インデックスが保持するポインタを返す。
  /// 木が異なる場合、インデックスが保持するノード番号に対応するポインタを返す。
  @inlinable
  @inline(__always)
  internal func ___node_ptr(_ index: Index) -> _NodePtr
  where Index.Tree == UnsafeTreeV2, Index._NodePtr == _NodePtr {
    #if true
    // .endが考慮されていないことがきになったが、テストが通ってしまっているので問題が見つかるまで保留
      // endはシングルトン的にしたい気持ちもある
//      return self.isTriviallyIdentical(to: index.__tree_) ? index.rawValue : ___NodePtr(index.___node_id_)
    return __end_node == index.__tree_.__end_node ? index.rawValue : ___NodePtr(index.___node_id_)
    #else
      self === index.__tree_ ? index.rawValue : (_header[index.___node_id_])
    #endif
  }
  
  @inlinable
  @inline(__always)
  internal func rawValue(_ index: Index) -> _NodePtr
  where Index.Tree == UnsafeTreeV2, Index._NodePtr == _NodePtr {
    ___node_ptr(index)
  }
}
