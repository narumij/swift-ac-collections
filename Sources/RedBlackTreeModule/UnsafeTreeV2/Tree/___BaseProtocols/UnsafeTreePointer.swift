public protocol UnsafeTreePointer: _TreePointer
where
  _NodePtr == UnsafeMutablePointer<UnsafeNode>,
  _NodeRef == UnsafeMutablePointer<UnsafeMutablePointer<UnsafeNode>>
{}
