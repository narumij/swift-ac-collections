import Foundation

@usableFromInline
protocol CountProtocol: ValueProtocol & RootProtocol & EndNodeProtocol & DistanceProtocol {}

extension CountProtocol {

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
        __rt = __left_(__rt)
      } else if value_comp(__value_(__rt), __k) {
        __rt = __right_(__rt)
      } else {
        return 1
      }
    }
    return 0
  }

  @inlinable
  func __count_multi(_ __k: _Key) -> size_type {
    var __result: __iter_pointer = __end_node()
    var __rt: __node_pointer = __root()
    while __rt != .nullptr {
      if value_comp(__k, __value_(__rt)) {
        __result = __rt
        __rt = __left_(__rt)
      } else if value_comp(__value_(__rt), __k) {
        __rt = __right_(__rt)
      } else {
        return __distance(
          __lower_bound(__k, __left_(__rt), __rt),
          __upper_bound(__k, __right_(__rt), __result))
      }
    }
    return 0
  }
}
