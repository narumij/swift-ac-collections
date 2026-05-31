@frozen
public struct RigidArray2D<Element>: ~Copyable {

  @usableFromInline let defaultValue: Element
  @usableFromInline let capacity: (width: Int, height: Int)
  @usableFromInline let __has_paylord_content: UnsafeMutablePointer<Bool>
  @usableFromInline let __payload: UnsafeMutablePointer<Element>

  @inlinable
  public init(defaultValue: Element, H: Int, W: Int) {
    self.capacity = (W, H)
    let totalCapacity = W * H
    self.__has_paylord_content = .allocate(capacity: totalCapacity)
    self.__has_paylord_content.initialize(repeating: false, count: totalCapacity)
    self.__payload = .allocate(capacity: totalCapacity)
    self.defaultValue = defaultValue
  }

  deinit {
    let totalCapacity = capacity.width * capacity.height
    for i in 0..<totalCapacity {
      if __has_paylord_content[i] {
        (__payload + i).deinitialize(count: 1)
      }
    }
    __has_paylord_content.deinitialize(count: totalCapacity)
    __payload.deallocate()
    __has_paylord_content.deallocate()
  }

  @inlinable
  public subscript(position: Int) -> SubArray {
    @inline(__always)
    get {
      .init(
        defaultValue: defaultValue,
        capacity: capacity.width,
        __has_paylord_content: __has_paylord_content + capacity.width * position,
        __payload: __payload + capacity.width * position)
    }

    @inline(__always)
    set {
      /* NOP */
    }
  }
}

extension RigidArray2D {

  public struct SubArray {
    @inlinable
    internal init(
      defaultValue: Element,
      capacity: Int,
      __has_paylord_content: UnsafeMutablePointer<Bool>,
      __payload: UnsafeMutablePointer<Element>
    ) {
      self.defaultValue = defaultValue
      self.capacity = capacity
      self.__has_paylord_content = __has_paylord_content
      self.__payload = __payload
    }

    @usableFromInline let defaultValue: Element
    @usableFromInline let capacity: Int
    @usableFromInline let __has_paylord_content: UnsafeMutablePointer<Bool>
    @usableFromInline let __payload: UnsafeMutablePointer<Element>

    @inlinable
    public subscript(position: Int) -> Element {
      @inline(__always)
      unsafeAddress {
        if !__has_paylord_content[position] {
          __payload[position] = defaultValue
        }
        return UnsafePointer(__payload + position)
      }
      @inline(__always)
      unsafeMutableAddress {
        if !__has_paylord_content[position] {
          __payload[position] = defaultValue
        }
        defer { __has_paylord_content[position] = true }
        return __payload + position
      }
    }

    func max() -> Element? where Element: FixedWidthInteger {
      var val: Element?
      for i in 0..<capacity {
        if __has_paylord_content[i] {
          switch val {
          case .some(let v):
            val = Swift.max(v, __payload[i])
          case .none:
            val = __payload[i]
          }
        }
      }
      return val
    }
  }
}
