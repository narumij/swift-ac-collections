//
//  UnsafeTreeV2+Testing.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/06/01.
//

#if DEBUG
  @testable import RedBlackTreeCollections

  extension UnsafeTreeV2 {

    @usableFromInline
    package func ___ptr_(_ p: _NodePtr) -> _TrackingTag {
      p.pointee.___tracking_tag
    }

    @usableFromInline
    package func __left_(_ p: _TrackingTag) -> _TrackingTag {
      try! __retrieve_(p).get().pointee.__left_.trackingTag
    }

    @usableFromInline
    package func __left_(_ p: _TrackingTag, _ l: _TrackingTag) {
      try! __retrieve_(p).get().pointee.__left_ = try! __retrieve_(l).get()
    }

    @usableFromInline
    package func __right_(_ p: _TrackingTag) -> _TrackingTag {
      try! __retrieve_(p).get().pointee.__right_.trackingTag
    }

    @usableFromInline
    package func __right_(_ p: _TrackingTag, _ l: _TrackingTag) {
      try! __retrieve_(p).get().pointee.__right_ = try! __retrieve_(l).get()
    }

    @usableFromInline
    package func __parent_(_ p: _TrackingTag) -> _TrackingTag {
      try! __retrieve_(p).get().pointee.__parent_.trackingTag
    }

    @usableFromInline
    package func __parent_(_ p: _TrackingTag, _ l: _TrackingTag) {
      try! __retrieve_(p).get().pointee.__parent_ = try! __retrieve_(l).get()
    }

    @usableFromInline
    package func __is_black_(_ p: _TrackingTag) -> Bool {
      try! __retrieve_(p).get().pointee.__is_black_
    }

    @usableFromInline
    package func __is_black_(_ p: _TrackingTag, _ b: Bool) {
      try! __retrieve_(p).get().pointee.__is_black_ = b
    }

    @usableFromInline
    package func __value_(_ p: _TrackingTag) -> _PayloadValue {
      __value_(try! __retrieve_(p).get())
    }

    @usableFromInline
    package func ___element(_ p: _TrackingTag, _ __v: _PayloadValue) {
      //      ___element(try! __retrieve_(p).get(), __v)
      try! __retrieve_(p).get().__value_().pointee = __v
    }
  }

  extension UnsafeTreeV2 {

    @usableFromInline
    package func destroy(_ p: _TrackingTag) {
      _buffer.withUnsafeMutablePointerToHeader { header in
        header.pointee.___pushRecycle(_buffer.header[p])
      }
    }
  }
#endif
