#!/usr/bin/env swift

import Foundation

let packageRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let sourcePaths = [
  "Sources/PermutationModule/Compatibility/AtCoder2025/NextPermutationProtocol.swift",
  "Sources/PermutationModule/Compatibility/AtCoder2025/PermutationsAtCoder2025.swift",
]
let opening = "#if COMPATIBLE_ATCODER_2025\n"
let closing = "#endif\n"

func fail(_ message: String) -> Never {
  FileHandle.standardError.write(Data("error: \(message)\n".utf8))
  exit(1)
}

func unwrappedSource(at relativePath: String) -> String {
  let url = packageRoot.appendingPathComponent(relativePath)
  guard var source = try? String(contentsOf: url, encoding: .utf8) else {
    fail("cannot read \(relativePath)")
  }
  guard source.hasPrefix(opening), source.hasSuffix(closing) else {
    fail("\(relativePath) is not enclosed by the expected compatibility condition")
  }

  source.removeFirst(opening.count)
  source.removeLast(closing.count)
  source = source.replacingOccurrences(of: "import Foundation\n", with: "")
  return source
}

var output = """
// Generated from the AtCoder 2025 compatibility sources.
// Do not edit this generated file; edit the package sources and regenerate it.

"""

for path in sourcePaths {
  output += unwrappedSource(at: path)
  if !output.hasSuffix("\n") {
    output += "\n"
  }
}

FileHandle.standardOutput.write(Data(output.utf8))
