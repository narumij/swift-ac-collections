
/// Swift 6.2 2026/01/11時点で赤黒木の性能の肝of肝となる部分
///
/// 何がもんだいなのかというと、Comparableの比較演算が特殊化されきらず動的ディスパッチがかすかに残ること
/// 設計をあれこれ組み替えて試してもどこかに必ず型判定が入り込んだり、ディスパッチが紛れてくる
/// 比較演算での動的ディスパッチは致命的すぎてつらい。
///
/// で、試しに強制返還を試したらインライン化された場合にとても良好だったので採用しました。
/// 本質的にダイナミックキャストを含むのでインライン化されないと素の状態より性能が悪化します。
///
/// しばらくこれで試してみます。
@usableFromInline
enum SpecializeMode {
  case asInt
  case generic

  @inlinable
  @inline(__always)
  func value_comp<_Key: Comparable>(_ __l: _Key,_ __r: _Key) -> Bool {
    switch self {
    case .asInt:
      return (__l as! Int) < (__r as! Int)
    case .generic:
      return __l < __r
    }
  }
  
  @inlinable
  @inline(__always)
  func value_equiv<_Key: Comparable>(_ __l: _Key,_ __r: _Key) -> Bool {
    switch self {
    case .asInt:
      return (__l as! Int) == (__r as! Int)
    case .generic:
      return __l == __r
    }
  }
  
  @inlinable
  @inline(__always)
  func synth_three_way<_Key: Comparable>(_ __l: _Key,_ __r: _Key) -> __eager_compare_result {
    switch self {
    case .asInt:
      return __eager_compare_result((__r as! Int) - (__l as! Int))
    case .generic:
      return __eager_compare_result(__default_three_way_comparator(__l, __r))
    }
  }
}
