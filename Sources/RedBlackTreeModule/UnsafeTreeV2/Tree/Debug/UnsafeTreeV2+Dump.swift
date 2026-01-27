//
//  UnsafeTreeV2+Debug.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/26.
//

#if DEBUG
extension UnsafeTreeV2 {

  @inlinable
  func dump(label: String = "") {
    let title = "==== UnsafeTreeV2 Dump \(label) ===="
    print(title)
    defer { print(String(repeating: "=", count: title.count)) }

    print(" valueType :", _PayloadValue.self)
    print(" count     :", count)
    print(" capacity  :", capacity)

    let layout = MemoryLayout<_PayloadValue>._memoryLayout

    _buffer.header.dumpHeader(label: "Header")
    _buffer.header.dumpFreshPool(label: "FreshPool", memoryLayout: layout)
    _buffer.header.dumpRecyclePool(label: "RecyclePool")
  }
}
#endif

// MARK: - Header Dump

#if DEBUG

extension UnsafeTreeV2BufferHeader {

  @usableFromInline
  func dumpHeader(label: String = "") {
    let title = "==== UnsafeTreeV2 Header Dump \(label) ===="
    print(title)
    defer { print(String(repeating: "-", count: title.count)) }

    print(" count                  :", count)

    print(" freshPoolCapacity      :", freshPoolCapacity)
    print(" freshPoolUsedCount     :", freshPoolUsedCount)
    print(" freshPoolActualCapacity:", freshPoolActualCapacity)
    print(" freshPoolActualCount   :", freshPoolActualCount)

    #if DEBUG
      print(" freshBucketCount       :", freshBucketCount)
    #endif

    let recycleDesc = (recycleHead == nullptr)
      ? "nullptr"
      : String(format: "%p", recycleHead)

    print(" recycleHead            :", recycleDesc)
    print(" recycleCount           :", recycleCount)

    print(" nullptr                :", String(format: "%p", nullptr))

    if begin_ptr.pointee != nullptr {
      print(" begin_ptr              :", begin_ptr.pointee,
            "tag:", begin_ptr.pointee.pointee.___tracking_tag)
    } else {
      print(" begin_ptr              : nullptr")
    }

    print(" root_ptr               :", __root,
          "tag:", __root.pointee.___tracking_tag)

    print(" end_ptr                :", end_ptr,
          "tag:", end_ptr.pointee.___tracking_tag)

    print(" tiedRawBuffer present  :", _tied != nil)
    print(" uniquelyOwned          :", isRawBufferUniquelyOwned)

    #if AC_COLLECTIONS_INTERNAL_CHECKS
      print(" copyCount              :", copyCount)
    #endif

    print(" valueStride            :", memoryLayout.stride)
    print(" valueAlignment         :", memoryLayout.alignment)
  }
}

#endif

// MARK: - FreshPool Dump

#if DEBUG

extension UnsafeTreeV2BufferHeader {

  @usableFromInline
  func dumpFreshPool<_RawValue>(
    _ t: _RawValue.Type,
    label: String = ""
  ) {
    dumpFreshPool(
      label: label,
      memoryLayout: MemoryLayout<_RawValue>._memoryLayout
    )
  }

  @usableFromInline
  func dumpFreshPool(
    label: String = "",
    memoryLayout: _MemoryLayout
  ) {
    let title = "==== FreshPool Dump \(label) ===="
    print(title)
    defer { print(String(repeating: "-", count: title.count)) }

    print(" bucketCount (debug):", freshBucketCount)
    print(" tracked capacity    :", freshPoolCapacity)
    print(" tracked usedCount   :", freshPoolUsedCount)
    print(" actual capacity     :", freshPoolActualCapacity)
    print(" actual usedCount    :", freshPoolActualCount)

    print(" nodeCount (tree)    :", count)
    print(" valueStride         :", memoryLayout.stride)
    print(" valueAlignment      :", memoryLayout.alignment)

    var bucketIndex = 0
    var p = freshBucketHead
    var isHead = true

    while let bucket = p {

      print(" ---- bucket[\(bucketIndex)] ----")
      print("  isHead   :", isHead)
      print("  capacity :", bucket.pointee.capacity)
      print("  count    :", bucket.pointee.count)
      print("  header   :", bucket)

      let nextDesc = bucket.pointee.next == nil
        ? "nullptr"
        : "\(bucket.pointee.next!)"
      print("  next     :", nextDesc)

      let start = bucket.start(
        isHead: isHead,
        valueAlignment: memoryLayout.alignment
      )
      let stride = MemoryLayout<UnsafeNode>.stride + memoryLayout.stride

      print("  start ptr:", start)
      print("  stride   :", stride)

      if isHead {
        let endNode = bucket.end_ptr
        print("  end node :", endNode, "tag:", endNode.pointee.___tracking_tag)
      }

      print("  ---- entries ----")

      var it = bucket._capacities(
        isHead: isHead,
        payload: memoryLayout
      )

      var i = 0
      while let node = it.pop() {

        let used = i < bucket.pointee.count
        let marker =
          (i == bucket.pointee.count)
          ? "<- current"
          : used ? "[used]" : "[free]"

        print(
          String(
            format: "   [%03d] node=%p tag=%lld %@",
            i,
            node,
            node.pointee.___tracking_tag,
            marker
          )
        )

        i &+= 1
      }

      bucketIndex &+= 1
      isHead = false
      p = bucket.pointee.next
    }
  }
}

#endif

// MARK: - Bucket Dump

#if DEBUG

extension UnsafeMutablePointer where Pointee == _Bucket {

  @usableFromInline
  func dump<_RawValue>(
    _ t: _RawValue.Type,
    label: String = "",
    isHead: Bool = true
  ) {
    dump(
      label: label,
      memoryLayout: MemoryLayout<_RawValue>._memoryLayout,
      isHead: isHead
    )
  }

  @usableFromInline
  func dump(
    label: String = "",
    memoryLayout: _MemoryLayout,
    isHead: Bool = true
  ) {
    print("---- Bucket Dump \(label) ----")
    print(" isHead     :", isHead)
    print(" capacity   :", pointee.capacity)
    print(" count      :", pointee.count)
    print(" alignment  :", memoryLayout.alignment)
    print(" valueStride:", memoryLayout.stride)

    let start = start(isHead: isHead, valueAlignment: memoryLayout.alignment)
    let stride = MemoryLayout<UnsafeNode>.stride + memoryLayout.stride

    print(" header ptr :", self)
    print(" start ptr  :", start)
    print(" stride     :", stride)

    if isHead {
      let endNode = end_ptr
      print(" end node   :", endNode, "tag:", endNode.pointee.___tracking_tag)
    }

    print(" ---- entries ----")

    var it = _capacities(isHead: isHead, payload: memoryLayout)
    var i = 0

    while let node = it.pop() {

      let used = i < pointee.count
      let marker =
        (i == pointee.count)
        ? "<- current"
        : used ? "[used]" : "[free]"

      print(
        String(
          format: " [%03d] node=%p tag=%lld %@",
          i,
          node,
          node.pointee.___tracking_tag,
          marker
        )
      )

      i &+= 1
    }

    print("------------------------------")
  }
}

#endif

// MARK: - RecyclePool Dump

#if DEBUG

extension _RecyclePool {

  @usableFromInline
  func dumpRecyclePool(label: String = "") {
    let title = "---- RecyclePool Dump \(label) ----"
    print(title)
    defer { print(String(repeating: "-", count: title.count)) }

    let headDesc = (recycleHead == nullptr)
      ? "nullptr"
      : String(format: "%p", recycleHead)

    print(" count (tree)        :", count)
    print(" freshPoolUsedCount  :", freshPoolUsedCount)
    print(" recycleCount        :", recycleCount)
    print(" recycleHead         :", headDesc)

    print(" ---- recycle chain ----")

    var i = 0
    var p = recycleHead

    while p != nullptr {
      let node = p.pointee

      let nextDesc = (node.__left_ == nullptr)
        ? "nullptr"
        : String(format: "%p", node.__left_)

      print(
        String(
          format: " [%03d] node=%p id=%lld recycle_count=%lld needs_deinit=%@ next=%@",
          i,
          p,
          node.___tracking_tag,
          node.___recycle_count,
          node.___has_payload_content ? "true" : "false",
          nextDesc
        )
      )

      p = node.__left_
      i &+= 1

      if i > 1_000_000 {
        print(" ⚠️ possible recycle chain loop detected")
        break
      }
    }
  }
}

#endif

// MARK: - TiedRawBuffer Dump

#if DEBUG

extension _TiedRawBuffer {

  @usableFromInline
  func dump(label: String = "") {
    let title = "==== _TiedRawBuffer Dump \(label) ===="
    print(title)
    defer { print(String(repeating: "-", count: title.count)) }

    withUnsafeMutablePointerToHeader { header in
      let h = header.pointee

      print(" bucketHead            :", h.bucketHead == nil ? "nullptr" : "\(h.bucketHead!)")
      print(" valueAccessAllowed    :", h.isValueAccessAllowed)
      print(" valueStride           :", h.deallocator.memoryLayout.stride)
      print(" valueAlignment        :", h.deallocator.memoryLayout.alignment)

      var bucketCount = 0
      var totalCapacity = 0
      var totalUsed = 0

      var p = h.bucketHead
      var isHead = true

      while let bucket = p {
        bucketCount &+= 1
        totalCapacity &+= bucket.pointee.capacity
        totalUsed &+= bucket.pointee.count

        print(" ---- bucket[\(bucketCount - 1)] ----")
        print("  isHead   :", isHead)
        print("  capacity :", bucket.pointee.capacity)
        print("  count    :", bucket.pointee.count)
        print("  header   :", bucket)

        let nextDesc = bucket.pointee.next == nil
          ? "nullptr"
          : "\(bucket.pointee.next!)"
        print("  next     :", nextDesc)

        if isHead {
          let endNode = bucket.end_ptr
          print("  end node :", endNode, "tag:", endNode.pointee.___tracking_tag)
        }

        p = bucket.pointee.next
        isHead = false
      }

      print(" bucketCount (actual)  :", bucketCount)
      print(" totalCapacity         :", totalCapacity)
      print(" totalUsed             :", totalUsed)

      if let begin = self.begin_ptr?.pointee {
        print(" begin_ptr             :", begin, "tag:", begin.pointee.___tracking_tag)
      } else {
        print(" begin_ptr             : nullptr")
      }

      if let end = self.end_ptr {
        print(" end_ptr               :", end, "tag:", end.pointee.___tracking_tag)
      } else {
        print(" end_ptr               : nullptr")
      }
    }
  }
}

#endif
