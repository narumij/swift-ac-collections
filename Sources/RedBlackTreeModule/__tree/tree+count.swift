import Foundation

@usableFromInline
protocol CountProtocol: ValueProtocol & RootProtocol & EndNodeProtocol & DistanceProtocol { }

extension CountProtocol {
  
  @inlinable @inline(__always)
  func
  static_cast__node_pointer(_ p: _NodePtr) -> _NodePtr { p }

  @inlinable @inline(__always)
  func
  static_cast__iter_pointer(_ p: _NodePtr) -> _NodePtr { p }

  @usableFromInline
  typealias size_type = Int
  
  @usableFromInline
  typealias __node_pointer = _NodePtr
  
  @usableFromInline
  typealias __iter_pointer = _NodePtr

  @inlinable
  func __count_unique(_ __k: _Key) -> size_type {
    var __rt: __node_pointer = __root()
    while __rt != .nullptr {
      if value_comp(__k, __value_(__rt)) {
        __rt = static_cast__node_pointer(__left_(__rt))
      } else if value_comp(__value_(__rt), __k) {
        __rt = static_cast__node_pointer(__right_(__rt)) }
      else {
        return 1 }
    }
    return 0
  }

  @inlinable
  func __count_multi(__k: _Key) -> size_type {
    var __result: __iter_pointer = __end_node()
    var __rt: __node_pointer     = __root()
    while __rt != .nullptr {
      if value_comp(__k, __value_(__rt)) {
        __result = static_cast__iter_pointer(__rt)
        __rt     = static_cast__node_pointer(__left_(__rt))
      } else if value_comp(__value_(__rt), __k) {
        __rt = static_cast__node_pointer(__right_(__rt)) }
      else {
        return __distance(
          __lower_bound(__k, static_cast__node_pointer(__left_(__rt)), static_cast__iter_pointer(__rt)),
          __upper_bound(__k, static_cast__node_pointer(__right_(__rt)), __result))
      }
    }
    return 0;
  }
}

