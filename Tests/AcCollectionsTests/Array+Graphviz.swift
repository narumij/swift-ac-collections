import Foundation
@testable import AcCollections

extension Array where Element: Item {
    
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
        return header +
        red + (startIndex ..< endIndex).filter{ !self[$0].isBlack }.map{"\($0)"}.joined(separator: " ") + "\n" +
        black +
        (startIndex ..< endIndex).filter{ self[$0].left != nil }.map{ "\($0) -> \(self[$0].left!) [label = \"left\"];" }.joined(separator: "\n") +
        black +
        (startIndex ..< endIndex).filter{ self[$0].right != nil }.map{ "\($0) -> \(self[$0].right!) [label = \"right\"];" }.joined(separator: "\n") + "\n" +
        hooter
    }
}

extension Array where Element == NodeItem {
    
    func graphviz() -> String { "" }
}
