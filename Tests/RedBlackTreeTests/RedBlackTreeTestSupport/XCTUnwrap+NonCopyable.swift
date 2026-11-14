//
//  XCTUnwrap+NonCopyable.swift
//  swift-ac-collections
//

import XCTest

/// XCTestのXCTUnwrapは~Copyableな型を受け取れないため、同じ形で使える版を用意する。
/// Copyableな型ではXCTest側のXCTUnwrapが選ばれる。
struct XCTUnwrapNonCopyableFailure: Error, CustomStringConvertible {
  let description: String
}

func XCTUnwrap<T: ~Copyable>(
  _ expression: @autoclosure () throws -> T?,
  _ message: @autoclosure () -> String = "",
  file: StaticString = #filePath,
  line: UInt = #line
) throws -> T {
  switch try expression() {
  case .some(let value):
    return value
  case .none:
    let userMessage = message()
    let failure =
      "XCTUnwrap failed: expected non-nil value of type \"\(T.self)\""
      + (userMessage.isEmpty ? "" : " - \(userMessage)")
    XCTFail(failure, file: file, line: line)
    throw XCTUnwrapNonCopyableFailure(description: failure)
  }
}
