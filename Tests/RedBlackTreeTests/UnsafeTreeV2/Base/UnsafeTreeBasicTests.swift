//
//  MemoryTests.swift
//  TrailingArrayTest
//
//  Created by narumij on 2025/12/28.
//

import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections

  final class UnsafeTreeBasicTests: RedBlackTreeTestCase {

    enum Base: ScalarValueTrait & UniqueMultiplicity & IntThreeWayComparator
        & _ScalarBasePayloadValue_KeyProtocol, _UnsafeNodePtrType
    {
      static func __get_value(_ p: UnsafeMutablePointer<UnsafeNode>) -> Int {
        p.__value_(as: _PayloadValue.self).pointee
      }
      static func __value_(_ p: UnsafeMutablePointer<RedBlackTreeCollections.UnsafeNode>) -> Int {
        fatalError()
      }
      typealias _Key = Int
      typealias Element = Int
    }

    /// `.create()`(容量0)が、空の木として正しい初期状態(capacity/count/root/begin_node)になること。
    func testCreateZero() async throws {
      let storage = UnsafeTreeV2<Base>.create()
      XCTAssertEqual(storage.capacity, 0)
      XCTAssertEqual(storage.count, 0)
      XCTAssertEqual(storage.__root, storage.nullptr)
      XCTAssertEqual(storage.__begin_node_, storage.end)
    }

    /// `.create(minimumCapacity:)`が指定容量以上を確保し、空の木として正しい初期状態になること。
    func testCreate() async throws {
      let storage = UnsafeTreeV2<Base>.create(minimumCapacity: 4)
      XCTAssertGreaterThanOrEqual(storage.capacity, 4)
      XCTAssertEqual(storage.count, 0)
      XCTAssertEqual(storage.__root, storage.nullptr)
      XCTAssertEqual(storage.__begin_node_, storage.end)
    }

    /// `__construct_node(_:)`で生成したノードから、`__value_`で元の値を読み出せること。
    func testConstruct() async throws {
      let storage = UnsafeTreeV2<Base>.create(minimumCapacity: 4)
      XCTAssertGreaterThanOrEqual(storage.capacity, 4)
      let ptr = storage.__construct_node(100)
      XCTAssertEqual(storage.__value_(ptr), 100)
      //      storage.___element(ptr, 20)
      //      XCTAssertEqual(storage.__value_(ptr), 20)
      //      storage.___element(ptr, 50)
      //      XCTAssertEqual(storage.__value_(ptr), 50)
    }

    /// `makeUsedNodeIterator()`が、構築済みノードを`___tracking_tag`の昇順(=挿入順)で
    /// 列挙し、未使用分に到達したら`nil`を返すこと。
    func testPoolIterator() async throws {
      let storage = UnsafeTreeV2<Base>.create(minimumCapacity: 4)
      XCTAssertGreaterThanOrEqual(storage.capacity, 4)
      _ = storage.__construct_node(100)
      _ = storage.__construct_node(200)
      _ = storage.__construct_node(300)
      _ = storage.__construct_node(400)

      do {
        var it = storage.makeUsedNodeIterator()
        XCTAssertEqual(it.next().map(\.pointee.___tracking_tag), 0)
        XCTAssertEqual(it.next().map(\.pointee.___tracking_tag), 1)
        XCTAssertEqual(it.next().map(\.pointee.___tracking_tag), 2)
        XCTAssertEqual(it.next().map(\.pointee.___tracking_tag), 3)
        XCTAssertEqual(it.next().map(\.pointee.___tracking_tag), nil)
        XCTAssertEqual(it.next().map(\.pointee.___tracking_tag), nil)
      }

      XCTAssertEqual(
        storage.makeUsedNodeIterator().map(\.pointee.___tracking_tag),
        [0, 1, 2, 3])

      XCTAssertEqual(
        storage.makeUsedNodeIterator().map { $0.__value_().pointee },
        [100, 200, 300, 400])
    }

    /// `destroy(_:)`で破棄した直後も、メモリ上の値自体はまだ読めること
    /// (破棄は即座にゼロクリアするのではなく、recycle pool管理上の状態を変えるだけ)。
    func testDestroy0() async throws {
      let storage = UnsafeTreeV2<Base>.create(minimumCapacity: 4)
      let ptr = storage.__construct_node(100)
      XCTAssertEqual(storage.__value_(ptr), 100)
      storage.destroy(ptr)
      XCTAssertEqual(storage.__value_(ptr), 100)
    }

    /// `___pushRecycle`/`___popRecycle`が、破棄したノードをLIFO(スタック)順に
    /// 積み下ろしし、その都度`recycleCount`とpayloadの初期化/破棄カウントが整合すること。
    func testDestroyStack() async throws {
      var storage = UnsafeTreeV2<Base>.create(minimumCapacity: 4)
      //    storage.initializedCount = 4
      _ = storage.__construct_node(0)
      _ = storage.__construct_node(2)
      _ = storage.__construct_node(4)
      _ = storage.__construct_node(8)
      XCTAssertEqual(storage._buffer.header[0].index, 0)
      XCTAssertEqual(storage._buffer.header[1].index, 1)
      XCTAssertEqual(storage._buffer.header[2].index, 2)
      XCTAssertEqual(storage._buffer.header[3].index, 3)
      XCTAssertEqual(storage._buffer.header.recycleHead, storage.nullptr)
      XCTAssertEqual(storage._buffer.header.___recycleNodes, [])
      XCTAssertEqual(storage._buffer.header.recycleCount, 0)
      XCTAssertEqual(payloadInitializedCount, 4)
      XCTAssertEqual(payloadDeinitializedCount, 0)
      storage._buffer.header.___pushRecycle(storage._buffer.header[0])
      XCTAssertEqual(storage._buffer.header.recycleHead, storage._buffer.header[0])
      XCTAssertEqual(storage._buffer.header[0].__left_, storage.nullptr)
      XCTAssertEqual(storage._buffer.header.___recycleNodes, [0])
      XCTAssertEqual(storage._buffer.header.recycleCount, 1)
      XCTAssertEqual(payloadInitializedCount, 4)
      XCTAssertEqual(payloadDeinitializedCount, 1)
      storage._buffer.header.___pushRecycle(storage._buffer.header[1])
      XCTAssertEqual(storage._buffer.header.___recycleNodes, [1, 0])
      XCTAssertEqual(storage._buffer.header.recycleCount, 2)
      XCTAssertEqual(payloadInitializedCount, 4)
      XCTAssertEqual(payloadDeinitializedCount, 2)
      storage._buffer.header.___pushRecycle(storage._buffer.header[2])
      XCTAssertEqual(storage._buffer.header.___recycleNodes, [2, 1, 0])
      XCTAssertEqual(storage._buffer.header.recycleCount, 3)
      XCTAssertEqual(payloadInitializedCount, 4)
      XCTAssertEqual(payloadDeinitializedCount, 3)
      storage._buffer.header.___pushRecycle(storage._buffer.header[3])
      XCTAssertEqual(storage._buffer.header.___recycleNodes, [3, 2, 1, 0])
      XCTAssertEqual(storage._buffer.header.recycleCount, 4)
      XCTAssertEqual(payloadInitializedCount, 4)
      XCTAssertEqual(payloadDeinitializedCount, 4)
      XCTAssertEqual(storage._buffer.header.___popRecycle(), storage._buffer.header[3])
      XCTAssertEqual(storage._buffer.header.___recycleNodes, [2, 1, 0])
      XCTAssertEqual(storage._buffer.header.recycleCount, 3)
      XCTAssertEqual(payloadInitializedCount, 4)
      XCTAssertEqual(payloadDeinitializedCount, 4)
      XCTAssertEqual(storage._buffer.header.___popRecycle(), storage._buffer.header[2])
      XCTAssertEqual(storage._buffer.header.___recycleNodes, [1, 0])
      XCTAssertEqual(storage._buffer.header.recycleCount, 2)
      XCTAssertEqual(payloadInitializedCount, 4)
      XCTAssertEqual(payloadDeinitializedCount, 4)
      XCTAssertEqual(storage._buffer.header.___popRecycle(), storage._buffer.header[1])
      XCTAssertEqual(storage._buffer.header.___recycleNodes, [0])
      XCTAssertEqual(storage._buffer.header.recycleCount, 1)
      XCTAssertEqual(payloadInitializedCount, 4)
      XCTAssertEqual(payloadDeinitializedCount, 4)
      XCTAssertEqual(storage._buffer.header.___popRecycle(), storage._buffer.header[0])
      XCTAssertEqual(storage._buffer.header.___recycleNodes, [])
      XCTAssertEqual(storage._buffer.header.recycleCount, 0)
      XCTAssertEqual(payloadInitializedCount, 4)
      XCTAssertEqual(payloadDeinitializedCount, 4)
      
      for i in 0..<4 {
        // pop時にtrueにする仕様なため
        XCTAssertTrue(storage._buffer.header[i].pointee.___has_payload_content)
        storage._buffer.header[i].pointee.___has_payload_content = false
      }
    }

    /// recycle pool(破棄済みノードの連結リスト)の構造が、`.copy()`後も
    /// 元の木と同じ形(連結順・左右の子のindex)を保つこと。
    func testDestroyStack2() async throws {
      var storage = UnsafeTreeV2<Base>.create(minimumCapacity: 4)
      _ = storage.__construct_node(0)
      _ = storage.__construct_node(2)
      _ = storage.__construct_node(4)
      _ = storage.__construct_node(8)
      storage._buffer.header.___pushRecycle(storage._buffer.header[0])
      storage._buffer.header.___pushRecycle(storage._buffer.header[1])
      storage._buffer.header.___pushRecycle(storage._buffer.header[2])
      storage._buffer.header.___pushRecycle(storage._buffer.header[3])
      XCTAssertTrue(storage.check())
      storage.withMutableHeader { $0.count = 4 }
      let copy = storage.copy(minimumCapacity: 100)
      XCTAssertEqual(storage._buffer.header.___recycleNodes, copy._buffer.header.___recycleNodes)
      var (s, c) = (storage._buffer.header.recycleHead, copy._buffer.header.recycleHead)
      while s != storage.nullptr, c != storage.nullptr {
        XCTAssertEqual(s.index, s.index)
        XCTAssertEqual(
          s.pointee.__right_.index, c.pointee.__right_.index)
        XCTAssertEqual(
          s.pointee.__left_.index, c.pointee.__left_.index)
        (s, c) = (s.__left_, c.__left_)
      }
    }

    /// 入れ子の`do`ブロックで構築→破棄を繰り返した場合でも、recycle poolが
    /// 正しいLIFO順でノードを積み重ねること(ネストしたスコープでも整合する)。
    func testConstructDestroy() async throws {
      #if AC_COLLECTIONS_INTERNAL_CHECKS
        let storage = UnsafeTreeV2<Base>.create(minimumCapacity: 4)
        do {
          let p = storage.__construct_node(-1)
          XCTAssertEqual(storage.count, 1)
          XCTAssertEqual(p.index, 0)
          storage.destroy(p)
          XCTAssertEqual(storage.count, 0)
          XCTAssertEqual(storage._buffer.header.recycleHead.index, 0)
          XCTAssertEqual(storage._buffer.header.___recycleNodes, [0])
          XCTAssertEqual(storage._buffer.header.recycleCount, 1)
          XCTAssertEqual(storage.__left_(0), .nullptr)
        }
        do {
          let p = storage.__construct_node(-1)
          XCTAssertEqual(storage.count, 1)
          XCTAssertEqual(p.index, 0)
          do {
            let p = storage.__construct_node(-1)
            XCTAssertEqual(storage.count, 2)
            XCTAssertEqual(p.index, 1)
            storage.destroy(p)
            XCTAssertEqual(storage.count, 1)
            XCTAssertEqual(storage._buffer.header.recycleHead.index, 1)
            XCTAssertEqual(storage._buffer.header.___recycleNodes, [1])
            XCTAssertEqual(storage._buffer.header.recycleCount, 1)
          }
          storage.destroy(p)
          XCTAssertEqual(storage.count, 0)
          XCTAssertEqual(storage._buffer.header.recycleHead.index, 0)
          XCTAssertEqual(storage._buffer.header.___recycleNodes, [0, 1])
          XCTAssertEqual(storage._buffer.header.recycleCount, 2)
          XCTAssertEqual(storage.__left_(1), .nullptr)
        }
        do {
          let p = storage.__construct_node(-1)
          XCTAssertEqual(storage.count, 1)
          XCTAssertEqual(p.index, 0)
          do {
            let p = storage.__construct_node(-1)
            XCTAssertEqual(storage.count, 2)
            XCTAssertEqual(p.index, 1)
            do {
              let p = storage.__construct_node(-1)
              XCTAssertEqual(storage.count, 3)
              XCTAssertEqual(p.index, 2)
              storage.destroy(p)
              XCTAssertEqual(storage.count, 2)
              XCTAssertEqual(storage._buffer.header.recycleHead.index, 2)
              XCTAssertEqual(storage._buffer.header.___recycleNodes, [2])
              XCTAssertEqual(storage._buffer.header.recycleCount, 1)
              XCTAssertEqual(storage.__left_(2), .nullptr)
            }
            storage.destroy(p)
            XCTAssertEqual(storage.count, 1)
            XCTAssertEqual(storage._buffer.header.recycleHead.index, 1)
            XCTAssertEqual(storage._buffer.header.___recycleNodes, [1, 2])
            XCTAssertEqual(storage._buffer.header.recycleCount, 2)
            XCTAssertEqual(storage.__left_(2), .nullptr)
          }
          storage.destroy(p)
          XCTAssertEqual(storage._buffer.header.recycleHead.index, 0)
          XCTAssertEqual(storage._buffer.header.___recycleNodes, [0, 1, 2])
          XCTAssertEqual(storage._buffer.header.recycleCount, 3)
          XCTAssertEqual(storage.__left_(2), .nullptr)
        }
      #endif
    }

    /// `__insert_unique`で0..<5を挿入した木が`__tree_invariant`を満たし、
    /// `lower_bound`と前進走査(`__tree_next_iter`)で昇順に正しく値を返すこと。
    func testInsert() async throws {
      let storage = UnsafeTreeV2<Base>.create(minimumCapacity: 5)
      for i in 0..<5 {
        _ = storage.__insert_unique(i)
        XCTAssertTrue(storage.__tree_invariant(storage.__root))
      }
      XCTAssertEqual(storage.lower_bound(3).index, 3)
      var begin = storage.__begin_node_
      XCTAssertEqual(begin.__value_().pointee, 0)
      begin = storage.__tree_next_iter(begin)
      XCTAssertEqual(begin.__value_().pointee, 1)
      begin = storage.__tree_next_iter(begin)
      XCTAssertEqual(begin.__value_().pointee, 2)
      begin = storage.__tree_next_iter(begin)
      XCTAssertEqual(begin.__value_().pointee, 3)
      begin = storage.__tree_next_iter(begin)
      XCTAssertEqual(begin.__value_().pointee, 4)
      begin = storage.__tree_next_iter(begin)
      XCTAssertEqual(begin, storage.end)
    }

    /// `.copy()`した木が、元の木と同じ構造(root/begin_nodeのindexと左右の子)を持ち、
    /// 走査結果も一致すること(CoWコピーの構造的忠実性)。
    func testInsert2() async throws {
      let storage = UnsafeTreeV2<Base>.create(minimumCapacity: 5)
      for i in 0..<5 {
        _ = storage.__insert_unique(i)
        XCTAssertTrue(storage.__tree_invariant(storage.__root))
      }
      let copy = storage.copy()
      XCTAssertTrue(copy.__tree_invariant(copy.__root))
      XCTAssertEqual(
        copy.__root.index,
        storage.__root.index)
      XCTAssertEqual(
        copy.__root.pointee.__left_.index,
        storage.__root.pointee.__left_.index)
      XCTAssertEqual(
        copy.__root.pointee.__right_.index,
        storage.__root.pointee.__right_.index)
      XCTAssertEqual(
        copy.__begin_node_.index, storage.__begin_node_.index)
      XCTAssertEqual(
        copy.__begin_node_.pointee.__parent_.index,
        storage.__begin_node_.pointee.__parent_.index)
      XCTAssertEqual(
        copy.__begin_node_.pointee.__right_.index,
        storage.__begin_node_.pointee.__right_.index)

      XCTAssertEqual(copy.lower_bound(3).index, 3)
      var begin = copy.__begin_node_
      XCTAssertEqual(begin.__value_().pointee, 0)
      begin = copy.__tree_next_iter(begin)
      XCTAssertEqual(begin.__value_().pointee, 1)
      begin = copy.__tree_next_iter(begin)
      XCTAssertEqual(begin.__value_().pointee, 2)
      begin = copy.__tree_next_iter(begin)
      XCTAssertEqual(begin.__value_().pointee, 3)
      begin = copy.__tree_next_iter(begin)
      XCTAssertEqual(begin.__value_().pointee, 4)
      begin = copy.__tree_next_iter(begin)
      XCTAssertEqual(begin, copy.end)
      XCTAssertTrue(__tree_invariant(storage.__root))
    }

    /// `__retrieve_(.nullptr)`が`.failure(.null)`になること。
    func testRetrieveEtc() throws {
      let storage = UnsafeTreeV2<Base>.create(minimumCapacity: 5)
      XCTAssertEqual(storage.__retrieve_(.nullptr), .failure(.null))
    }

    /// 未知の(存在しない)タグを`___retrieve(tag:)`に渡すと`.failure(.unknown)`になること。
    func testRetrieveUnknown() throws {
      let storage = UnsafeTreeV2<Base>.create(minimumCapacity: 5)
      XCTAssertEqual(
        storage.___retrieve(tag: .tag(raw: 6, seal: 0)),
        .failure(.unknown))
    }
    
    /// `description`に型名`"UnsafeTreeV2"`が含まれること。
    func testDescription() throws {
      let storage = UnsafeTreeV2<Base>.create(minimumCapacity: 5)
      XCTAssertTrue(storage.description.contains("UnsafeTreeV2"))
    }
  }
#endif
