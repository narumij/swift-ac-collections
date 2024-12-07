import Foundation
@testable import RedBlackTreeModule

extension Collection where Element == RedBlackTree.Node, Index == Int {
    
    func graphviz() -> String {
        let header = """
        digraph {
        """
        let red = "node [shape = circle style=filled fillcolor=red];"
        let black = """
        node [shape = circle fillcolor=black fontcolor=white];
        """
        let hooter = """
        }
        """
        
        let reds: String = (startIndex ..< endIndex).filter{ !self[$0].__is_black_ }.map{"\($0)"}.joined(separator: " ")
        
        let lefts: String = (startIndex ..< endIndex).filter{ self[$0].__left_ != nil }.map{ "\($0) -> \(self[$0].__left_.offset ?? -1) [label = \"left\"];" }.joined(separator: "\n")
        
        let rights: String = (startIndex ..< endIndex).filter{ self[$0].__right_ != nil }.map{ "\($0) -> \(self[$0].__right_.offset ?? -1) [label = \"right\"];" }.joined(separator: "\n")
        
        return header +
        red + reds + "\n" +
        black + "\n" +
        lefts + "\n" +
        rights + "\n" +
        hooter
    }
}
