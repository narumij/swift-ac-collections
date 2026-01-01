
// NOTE: 性能過敏なので修正する場合は必ず計測しながら行うこと
@usableFromInline
protocol UnsafeNodeFreshPool {
  
  /*
   Design invariant:
   - FreshPool may consist of multiple buckets in general.
   - Immediately after CoW, the pool must be constrained to a single bucket
     because index-based access is performed.
  */
  
  associatedtype _Value
  var freshBucketHead: ReserverHeaderPointer? { get set }
  var freshBucketCurrent: ReserverHeaderPointer? { get set }
  var freshBucketLast: ReserverHeaderPointer? { get set }
  var freshBucketCount: Int { get set }
  var freshPoolCapacity: Int { get set }
  var freshBucketDispose: (ReserverHeaderPointer?) -> Void { get }
}

extension UnsafeNodeFreshPool {
  public typealias ReserverHeader = UnsafeNodeFreshBucket<_Value>
  public typealias ReserverHeaderPointer = UnsafeMutablePointer<ReserverHeader>
  public typealias NodePointer = UnsafeMutablePointer<UnsafeNode>
}

extension UnsafeNodeFreshPool {
  
  /*
   NOTE:
   Normally, FreshPool may grow by adding multiple buckets.
   However, immediately after CoW, callers MUST ensure that
   only a single bucket exists to support index-based access.
   */
  @inlinable
  @inline(__always)
  mutating func pushBucket(capacity: Int) {
    assert(capacity != 0)
    let pointer = ReserverHeader.create(capacity: capacity)
    if freshBucketHead == nil {
      freshBucketHead = pointer
    }
    if freshBucketCurrent == nil {
      freshBucketCurrent = pointer
    }
    if let freshBucketLast {
      freshBucketLast.pointee.next = pointer
    }
    freshBucketLast = pointer
    self.freshPoolCapacity += capacity
    freshBucketCount += 1
  }
  
  @inlinable
  @inline(__always)
  mutating func popFresh() -> NodePointer? {
    if let p = freshBucketCurrent?.pointee.pop() {
      return p
    }
    nextBucket()
    return freshBucketCurrent?.pointee.pop()
  }
  
  @inlinable
  @inline(__always)
  mutating func nextBucket() {
    freshBucketCurrent = freshBucketCurrent?.pointee.next
  }
  
  @inlinable
  @inline(__always)
  func ___clearFresh() {
    var reserverHead = freshBucketHead
    while let h = reserverHead {
      h.pointee.clear()
      reserverHead = h.pointee.next
    }
  }
  
  @inlinable
//  @inline(__always)
  static func ___disposeBucketFunc(_ pointer: ReserverHeaderPointer?) {
    pointer!.pointee.dispose()
    pointer!.deinitialize(count: 1)
    UnsafeRawPointer(pointer!).deallocate()
  }
  
  @inlinable
  @inline(__always)
  func ___disposeBucket(_ pointer: ReserverHeaderPointer) {
    // ここで__swift_instantiateGenericMetadataが生じていて、出来ればこれをキャンセルしたい
    // TODO: Value の deinit 専用 thunkというのをChatGPTがおすすめしてくる。再度検討すること
//    pointer.pointee.dispose()
//    pointer.deinitialize(count: 1)
//    UnsafeRawPointer(pointer).deallocate()
    // クロージャ化することで型情報を維持している。型情報を維持することでペナルティを避けられる。
    freshBucketDispose(pointer)
  }
  
  @inlinable
  @inline(__always)
  func ___disposeFreshPool() {
    var reserverHead = freshBucketHead
    while let h = reserverHead {
      reserverHead = h.pointee.next
      ___disposeBucket(h)
    }
  }
}

extension UnsafeNodeFreshPool {
  
  @inlinable
  @inline(__always)
  func makeInitializedIterator() -> UnsafeInitializedNodeIterator<_Value> {
    return UnsafeInitializedNodeIterator<_Value>(pointer: freshBucketHead)
  }
}

extension UnsafeNodeFreshPool {

  /*
   IMPORTANT:
   After a Copy-on-Write operation, node access is performed via index-based
   lookup. To guarantee O(1) address resolution and avoid bucket traversal,
   the FreshPool must contain exactly ONE bucket at this point.

   Invariant:
     - During and immediately after CoW, `reserverBucketCount == 1`
     - Index-based access relies on a single contiguous bucket

   Violating this invariant may cause excessive traversal or undefined behavior.
  */
  @inlinable
  @inline(__always)
  subscript(___node_id_: Int) -> NodePointer? {
    assert(___node_id_ >= 0)
    var remaining = ___node_id_
    var p = freshBucketHead
    while let h = p {
      let cap = h.pointee.capacity
      if remaining < cap {
        return h.pointee[remaining]
      }
      remaining -= cap
      p = h.pointee.next
    }
    return nil
  }
}

extension UnsafeNodeFreshPool {

  @inlinable
  @inline(__always)
  var freshPoolUsedCount: Int {
    var count = 0
    var p = freshBucketHead
    while let h = p {
      count += h.pointee.count
      p = h.pointee.next
    }
    return count
  }
}

#if DEBUG
extension UnsafeNodeFreshPool {

  func dumpFreshPool(label: String = "") {
    print("==== FreshPool \(label) ====")
    print(" bucketCount:", freshBucketCount)
    print(" capacity:", freshPoolCapacity)
    print(" usedCount:", freshPoolUsedCount)

    var i = 0
    var p = freshBucketHead
    while let h = p {
      h.pointee.dump(label: "bucket[\(i)]")
      p = h.pointee.next
      i += 1
    }
    print("===========================")
  }
}
#endif
