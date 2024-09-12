import Foundation
@testable import AcCollections

protocol Item: Equatable {
    var isBlack: Bool { get set }
    var parent: Int? { get set }
    var left: Int? { get set }
    var right: Int? { get set }
}

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

protocol BasePtrItem: Equatable {
    var isBlack: Bool { get set }
    var parent: BasePtr { get set }
    var left: BasePtr { get set }
    var right: BasePtr { get set }
}

extension Array where Element: BasePtrItem {
    
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
        
        let reds: String = (startIndex ..< endIndex).filter{ !self[$0].isBlack }.map{"\($0)"}.joined(separator: " ")
        
        let lefts: String = (startIndex ..< endIndex).filter{ self[$0].left != nil }.map{ "\($0) -> \(self[$0].left.index!) [label = \"left\"];" }.joined(separator: "\n")
        
        let rights: String = (startIndex ..< endIndex).filter{ self[$0].right != nil }.map{ "\($0) -> \(self[$0].right.index!) [label = \"right\"];" }.joined(separator: "\n")
        
        return header +
        red + reds + "\n" +
        black + lefts + rights + "\n" +
        hooter
    }
}

//extension Array where Element == BasePtrItem {
//    
//    func graphviz() -> String { "" }
//}

extension Storage.Item: BasePtrItem { }
