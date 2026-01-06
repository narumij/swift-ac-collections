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

extension UnsafeNode {

  @inlinable
  func debugDescription(resolve: (Pointer?) -> Int?) -> String {
    let id = ___node_id_
    let l = resolve(__left_)
    let r = resolve(__right_)
    let p = resolve(__parent_)
    let color = __is_black_ ? "B" : "R"
    #if DEBUG
      let rc = ___recycle_count
    #else
      let rc = -1
    #endif

    return """
      - node[\(id)] \(color)
        L: \(l.map(String.init) ?? "nil")
        R: \(r.map(String.init) ?? "nil")
        P: \(p.map(String.init) ?? "nil")
        needsDeinit: \(___needs_deinitialize)
        recycleCount: \(rc)
      """
  }
}
