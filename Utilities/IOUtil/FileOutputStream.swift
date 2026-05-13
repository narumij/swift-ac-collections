@preconcurrency import Foundation

#if false
/// これが特別速い訳では無く、printと同程度の速度
public typealias FileOutputStream = FileOutputStream_putchar_unlockd

/// writeで定数倍の負担がかかる
public struct FileOutputStream_naive: TextOutputStream {

  @usableFromInline let fileHandle: FileHandle

  @inlinable
  @inline(__always)
  public func write(_ s: String) {
    if let d = s.data(using: .utf8) {
      try? fileHandle.write(contentsOf: d)
    }
  }

  nonisolated(unsafe)
    public static var standardOutput: FileOutputStream_naive = .init(
      fileHandle: FileHandle.standardOutput)
  
  nonisolated(unsafe)
    public static var standardError: FileOutputStream_naive = .init(
      fileHandle: FileHandle.standardError)
}

/// これが特別速い訳では無く、printと同程度の速度
public struct FileOutputStream_putchar_unlockd {
  
  public struct StandardOutput: TextOutputStream {
    
    @inlinable
    @inline(__always)
    public func write(_ s: String) {
      if let d = s.data(using: .utf8) {
        d.withUnsafeBytes {
          for i in 0..<$0.count {
            putchar_unlocked(Int32($0[i]))
          }
        }
      }
    }
  }
  
  nonisolated(unsafe)
    public static var standardOutput: StandardOutput = .init()
  
  public struct StandardError: TextOutputStream {
    
    @inlinable
    @inline(__always)
    public func write(_ s: String) {
      let backup = stdout
      stdout = stderr
      if let d = s.data(using: .utf8) {
        d.withUnsafeBytes {
          for i in 0..<$0.count {
            putchar_unlocked(Int32($0[i]))
          }
        }
      }
      stdout = backup
    }
  }

  nonisolated(unsafe)
    public static var standardError: StandardError = .init()
}
#endif
