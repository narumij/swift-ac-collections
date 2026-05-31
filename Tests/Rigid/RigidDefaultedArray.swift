@frozen
public struct RigidDefaultedArray<Element>: ~Copyable {

  @usableFromInline let defaultValue: Element
  @usableFromInline let capacity: Int
  @usableFromInline let __has_paylord_content: UnsafeMutablePointer<Bool>
  @usableFromInline let __payload: UnsafeMutablePointer<Element>

  @inlinable
  public init(defaultValue: Element, capacity: Int) {
    self.capacity = capacity
    self.__has_paylord_content = .allocate(capacity: capacity)
    self.__has_paylord_content.initialize(repeating: false, count: capacity)
    self.__payload = .allocate(capacity: capacity)
    self.defaultValue = defaultValue
  }

  deinit {
    for i in 0..<capacity {
      if __has_paylord_content[i] {
        (__payload + i).deinitialize(count: 1)
      }
    }
    __payload.deallocate()
    __has_paylord_content.deinitialize(count: capacity)
    __has_paylord_content.deallocate()
  }

  @inlinable
  public subscript(position: Int) -> Element {
    @inline(__always)
    get {
      precondition(position < capacity)
      guard __has_paylord_content[position] else {
        return defaultValue
      }
      return __payload[position]
    }

    @inline(__always)
    _modify {
      precondition(position < capacity)
      var value = __has_paylord_content[position] ? (__payload + position).move() : defaultValue
      defer {
        __has_paylord_content[position] = true
        (__payload + position).initialize(to: value)
      }
      yield &value
    }
  }
}

extension RigidDefaultedArray {

  @inlinable
  var description: String {
    var result = [(Int, Element)]()
    for i in 0..<capacity {
      if __has_paylord_content[i] {
        result.append((i, __payload[i]))
      }
    }
    return result.description
  }
}
