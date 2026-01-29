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

import Foundation

#if GRAPHVIZ_DEBUG
  extension UnsafeTreeV2 {

    /// グラフビズオブジェクトを生成します
    public func ___graphviz() -> Graphviz.Digraph {
      buildGraphviz()
    }
  }

#if true
  extension ___UnsafeBaseV2 {

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
      __tree_.___graphviz()
    }
  }
#endif

#endif

#if GRAPHVIZ_DEBUG
  public enum Graphviz {}

  extension Graphviz {

    public struct Digraph {
      var options: [Option] = []
      var nodes: [Node] = []
      var edges: [Edge] = []
    }

    typealias Node = ([NodeProperty], [String])

    enum Shape: String {
      case circle
      case note
    }

    enum Style: String {
      case filled
    }

    enum Color: String {
      case white
      case black
      case red
      case blue
      case lightYellow
    }

    enum LabelJust: String {
      case l
      case r
    }

    enum Port: String {
      case n
      case nw
      case w
      case sw
      case s
      case se
      case e
      case ne
      case none
    }

    enum Spline: String {
      case line
    }

    enum Option {
      case splines(Spline)
    }

    enum NodeProperty {
      case shape(Shape)
      case style(Style)
      case fillColor(Color)
      case fontColor(Color)
      case label(String)
      case labelJust(LabelJust)
    }

    struct Edge {
      var from: (String, Port)
      var to: (String, Port)
      var properties: [EdgeProperty]
    }

    enum EdgeProperty {
      case label(String)
      case labelAngle(Double)
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
    static var begin: [Graphviz.EdgeProperty] {
      [.label(""),.labelAngle(45)]
    }
    static var left: [Graphviz.EdgeProperty] {
      [.label("left"),.labelAngle(45)]
    }
    static var right: [Graphviz.EdgeProperty] {
      [.label("right"),.labelAngle(-45)]
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
      case .label(let s):
        return "label = \"\(s)\""
      case .labelJust(let l):
        return "labeljust = \(l)"
      }
    }
  }

  extension Graphviz.EdgeProperty {
    var description: String {
      switch self {
      case .label(let label):
        return "label = \"\(label)\""
      case .labelAngle(let angle):
        return "labelangle = \(angle)"
      }
    }
  }

  extension Graphviz.Option {
    var description: String {
      switch self {
      case .splines(let s):
        return "splines = \(s)"
      }
    }
  }

  extension Graphviz.Edge {

    func node(_ p: (String, Graphviz.Port)) -> String {
      if p.1 == .none {
        return p.0
      }
      return "\(p.0):\(p.1)"
    }

    var description: String {
      "\(node(from)) -> \(node(to)) [\(properties.map(\.description).joined(separator: " "))]"
    }
  }

  extension Graphviz.Digraph: CustomStringConvertible {
    public var description: String {
      func description(_ properties: [Graphviz.NodeProperty], _ nodes: [String]) -> String {
        "node \(properties.description); \(nodes.joined(separator: " "))"
      }
      return
        """
        digraph {
        \(options.map(\.description).joined(separator: ";\n"))
        \(nodes.map(description).joined(separator: "\n"))
        \(edges.map(\.description).joined(separator: "\n"))
        }
        """
    }
  }

  extension UnsafeTreeV2 {

    func buildGraphviz() -> Graphviz.Digraph {
      func isRed(_ i: _NodePtr) -> Bool {
        !__is_black_(i)
      }
      func isBlack(_ i: _NodePtr) -> Bool {
        __is_black_(i)
      }
      func hasLeft(_ i: _NodePtr) -> Bool {
        __left_(i) != nullptr
      }
      func hasRight(_ i: _NodePtr) -> Bool {
        __right_(i) != nullptr
      }
      func offset(_ i: _NodePtr) -> _NodePtr? {
        switch i {
        case end:
          return nil
        case nullptr:
          return nil
        default:
          return i
        }
      }
      func leftPair(_ i: _NodePtr) -> (_NodePtr, _NodePtr) {
        (i, offset(__left_(i)) ?? end)
      }
      func rightPair(_ i: _NodePtr) -> (_NodePtr, _NodePtr) {
        (i, offset(__right_(i)) ?? end)
      }
      func node(_ i: _NodePtr) -> String {
        switch i {
        case end:
          return "end"
        default:
          return "\(i.pointee.___tracking_tag)"
        }
      }
      func nodeN(_ i: _NodePtr) -> String {
        switch i {
        case nullptr:
          return "-"
        case end:
          return "end"
        default:
          return "#\(i.pointee.___tracking_tag)"
        }
      }
      func nodeV(_ i: _NodePtr) -> String {
        if i == end {
          return "end"
        } else {
          let c = String("\(i.__value_(as: _PayloadValue.self).pointee)".flatMap { $0 == "\n" ? ["\n", "n"] : [$0] })
          //          let l: String = "\\\"\(c)\\\"\\n#\(i)"
          let l: String = "\(c)\\n\\n#\(i.pointee.___tracking_tag)"
          return "\(i.pointee.___tracking_tag) [tag = \"\(l)\"];"
        }
      }
      func headerNote() -> [Graphviz.NodeProperty] {
        // let h = "\(_header)"
        // let l = "header\\n\(String(h.flatMap{ $0 == "\n" ? ["\\","n"] : [$0] }))"
        var ll: [String] = []
        ll.append(contentsOf: [
          "[Header]",
          "capacity: \(capacity)",
          "__left_: \(nodeN(__end_node.__left_))",
          "__begin_node: \(nodeN(__begin_node_))",
          "initializedCount: \(initializedCount)",
          "destroyCount: \(_buffer.header.recycleCount)",
          "destroyNode: \(nodeN(_buffer.header.recycleHead))",
          "[etc]",
          "__tree_invariant: \(__tree_invariant(__root))",
        ])
        #if AC_COLLECTIONS_INTERNAL_CHECKS
        ll.append("- copyCount: \(_buffer.header.copyCount)")
        #endif

        let l = ll.joined(separator: "\\n")
        return [
          .shape(.note),
          .label(l),
          .labelJust(.l),
          .style(.filled),
          .fillColor(.lightYellow),
          .fontColor(.black),
        ]
      }
      let initializedCount = _buffer.header.freshPoolUsedCount
      let destroyNode = _buffer.header.recycleHead
      let reds = (0..<initializedCount).map{ self[_unchecked_tag: $0] }.filter(isRed).map(nodeV)
      let blacks = (0..<initializedCount).map{ self[_unchecked_tag: $0] }.filter(isBlack).map(nodeV)
      let lefts: [(_NodePtr, _NodePtr)] = (0..<initializedCount).map{ self[_unchecked_tag: $0] }.filter(hasLeft).map(leftPair)
      let rights: [(_NodePtr, _NodePtr)] = (0..<initializedCount).map{ self[_unchecked_tag: $0] }.filter(hasRight).map(rightPair)
      var digraph = Graphviz.Digraph()
      digraph.options.append(.splines(.line))
      digraph.nodes.append((.red, reds))
      digraph.nodes.append((.blue, ["begin", "stack", "end"]))
      digraph.nodes.append((.black, blacks))
      digraph.nodes.append((headerNote(), ["header"]))
      if __root != nullptr {
        digraph.edges.append(
          .init(from: (node(end), .sw), to: (node(__root), .n), properties: .left))
      }
      if __begin_node_ != nullptr {
        digraph.edges.append(
          .init(from: ("begin", .s), to: (node(__begin_node_), .n), properties: .begin))
      }
      if destroyNode != nullptr {
        digraph.edges.append(
          .init(from: ("stack", .s), to: (node(destroyNode), .n), properties: .left))
      }
      digraph.edges.append(
        contentsOf: lefts.map {
          .init(from: (node($0), .sw), to: (node($1), .n), properties: .left)
        })
      digraph.edges.append(
        contentsOf: rights.map {
          .init(from: (node($0), .se), to: (node($1), .n), properties: .right)
        })
      return digraph
    }
  }
#endif
