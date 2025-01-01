//
//  ___RedBlackTree+Debug.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/01/01.
//

import Foundation

#if GRAPHVIZ_DEBUG
extension ___RedBlackTree.___Tree {

  /// グラフビズオブジェクトを生成します
  func ___graphviz() -> Graphviz.Digraph {
    buildGraphviz()
  }
}

extension ___RedBlackTreeBase {
  
  /// グラフビズオブジェクトを生成します
  ///
  /// デバッガで、以下のようにすると、Graphvizのソースをコンソールに出力できます。
  ///
  /// ```
  /// p print(set.___graphviz())
  /// ```
  ///
  /// ```
  /// digraph {
  /// node [shape = circle style = filled fillcolor = red]; 1 4
  /// node [shape = circle style = filled fillcolor = blue fontcolor = white]; begin stack
  /// node [shape = circle style = filled fillcolor = black fontcolor = white];
  /// end -> 2 [label = "left"]
  /// begin -> 0 [label = "left"]
  /// stack -> 1 [label = "left"]
  /// 2 -> 0 [label = "left"]
  /// 1 -> 1 [label = "right"]
  /// 2 -> 3 [label = "right"]
  /// 3 -> 4 [label = "right"]
  /// }
  /// ```
  ///
  /// 上のソースは、以下のような操作をした直後のものです。
  /// ```
  /// var set = RedBlackTreeSet<Int>([0, 1, 2, 3, 4])
  /// set.remove(1)
  /// ```
  /// 
  public func ___graphviz() -> Graphviz.Digraph {
    _tree.___graphviz()
  }
}
#endif

#if GRAPHVIZ_DEBUG
enum Graphviz {}

extension Graphviz {

  struct Digraph {
    var nodes: [Node] = []
    var edges: [Edge] = []
  }

  typealias Node = ([NodeProperty], [String])

  enum Shape: String {
    case circle
  }

  enum Style: String {
    case filled
  }

  enum Color: String {
    case white
    case black
    case red
    case blue
  }

  enum NodeProperty {
    case shape(Shape)
    case style(Style)
    case fillColor(Color)
    case fontColor(Color)
  }

  struct Edge {
    var from: String
    var to: String
    var properties: [EdgeProperty]
  }

  enum EdgeProperty {
    case label(String)
  }
}

extension Array where Element == Graphviz.NodeProperty {
  static var red: [Graphviz.NodeProperty] {
    [.shape(.circle), .style(.filled), .fillColor(.red)]
  }
  static var black: Self {
    [.shape(.circle), .style(.filled), .fillColor(.black), .fontColor(.white)]
  }
  static var blue: Self {
    [.shape(.circle), .style(.filled), .fillColor(.blue), .fontColor(.white)]
  }
  var description: String {
    "[\(map(\.description).joined(separator: " "))]"
  }
}

extension Array where Element == Graphviz.EdgeProperty {
  static var left: [Graphviz.EdgeProperty] {
    [.label("left")]
  }
  static var right: [Graphviz.EdgeProperty] {
    [.label("right")]
  }
}

extension Graphviz.NodeProperty {
  var description: String {
    switch self {
    case .shape(let shape):
      return "shape = \(shape.rawValue)"
    case .style(let style):
      return "style = \(style.rawValue)"
    case .fillColor(let color):
      return "fillcolor = \(color.rawValue)"
    case .fontColor(let color):
      return "fontcolor = \(color.rawValue)"
    }
  }
}

extension Graphviz.EdgeProperty {
  var description: String {
    switch self {
    case .label(let label):
      return "label = \"\(label)\""
    }
  }
}

extension Graphviz.Edge {
  var description: String {
    "\(from) -> \(to) [\(properties.map(\.description).joined(separator: " "))]"
  }
}

extension Graphviz.Digraph: CustomStringConvertible {
  var description: String {
    func description(_ properties: [Graphviz.NodeProperty], _ nodes: [String]) -> String {
      "node \(properties.description); \(nodes.joined(separator: " "))"
    }
    return
      """
      digraph {
      \(nodes.map(description).joined(separator: "\n"))
      \(edges.map(\.description).joined(separator: "\n"))
      }
      """
  }
}

extension ___RedBlackTree.___Tree {
  
  func buildGraphviz() -> Graphviz.Digraph {
    func isRed(_ i: Int) -> Bool {
      !self[node: i].__is_black_
    }
    func hasLeft(_ i: Int) -> Bool {
      self[node: i].__left_ != .nullptr
    }
    func hasRight(_ i: Int) -> Bool {
      self[node: i].__right_ != .nullptr
    }
    func offset(_ i: Int) -> Int? {
      switch i {
      case .end:
        return nil
      case .nullptr:
        return nil
      default:
        return i
      }
    }
    func leftPair(_ i: Int) -> (Int, Int) {
      (i, offset(self[node: i].__left_) ?? -1)
    }
    func rightPair(_ i: Int) -> (Int, Int) {
      (i, offset(self[node: i].__right_) ?? -1)
    }
    func node(_ i: Int) -> String {
      if i == .end {
        return "end"
      } else {
        return "\(i)"
      }
    }
    let reds = (0..<header.initializedCount).filter { !self[node: $0].__is_black_ }.map { "\($0)" }
    let lefts: [(Int, Int)] = (0..<header.initializedCount).filter(hasLeft).map(leftPair)
    let rights: [(Int, Int)] = (0..<header.initializedCount).filter(hasRight).map(rightPair)
    var digraph = Graphviz.Digraph()
    digraph.nodes.append((.red, reds))
    digraph.nodes.append((.blue, ["begin","stack","end"]))
    digraph.nodes.append((.black, []))
    if __root() != .nullptr {
      digraph.edges.append(.init(from: node(.end), to: node(__root()), properties: .left))
    }
    if __begin_node != .nullptr {
      digraph.edges.append(.init(from: "begin", to: node(__begin_node), properties: .left))
    }
    if header.destroyNode != .nullptr {
      digraph.edges.append(.init(from: "stack", to: node(header.destroyNode), properties: .left))
    }
    digraph.edges.append(
      contentsOf: lefts.map { .init(from: node($0), to: node($1), properties: .left) })
    digraph.edges.append(
      contentsOf: rights.map { .init(from: node($0), to: node($1), properties: .right) })
    return digraph
  }
}
#endif
