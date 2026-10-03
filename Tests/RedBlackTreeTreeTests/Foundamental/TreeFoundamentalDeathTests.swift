#if DEBUG && DEATH_TEST
  import Foundation
  import Testing

  @testable import RedBlackTreeCollections

  /// 原木のポインタ前提条件と、不正なtracking tagの停止契約を検証する。
  ///
  /// exit testの本体は別プロセスで実行されるため、外側で作った生ポインタを
  /// captureしない。各ケースは原木が提供するsingletonだけを子プロセス内で参照する。
  struct TreeFoundamentalDeathTests {

    private struct AlgorithmHarness: TreeAlgorithmBaseProtocol_ptr, TreeAlgorithmProtocol_ptr {
      var nullptr: UnsafeMutablePointer<UnsafeNode> { .nullptr }
    }

    enum NullPrecondition: String, CaseIterable, Codable, Sendable {
      case freeMinimum
      case freeMaximum
      case freeNext
      case freeNextIterator
      case freePreviousIterator
      case protocolMinimum
      case protocolMaximum
      case protocolNext
      case protocolNextIterator
      case protocolPreviousIterator
      case protocolLeaf
      case leftRotateNode
      case leftRotateMissingRightChild
      case rightRotateNode
      case rightRotateMissingLeftChild
      case balanceRoot
      case balanceInsertedNode
      case removeRoot
      case removeNode
      case removeMalformedTree
    }

    @Test
    func sealingNegativeTrackingTag_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = _TrackingTagSealing.seal(raw: .min, seal: 0)
      }
    }

    @Test
    func comparingMultiWithNullLeftPointer_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = ___ptr_comp_multi(.nullptr, UnsafeNode.template)
      }
    }

    @Test
    func comparingMultiWithNullRightPointer_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = ___ptr_comp_multi(UnsafeNode.template, .nullptr)
      }
    }

    @Test
    func measuringNullPointerHeight_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = ___ptr_height(.nullptr)
      }
    }

    @Test
    func creatingBitmapForNullPointer_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = UnsafeMutablePointer<UnsafeNode>.nullptr.___ptr_bitmap_64()
      }
    }

    @Test
    func comparingBitmapWithNullLeftPointer_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = ___ptr_comp_bitmap(.nullptr, UnsafeNode.template)
      }
    }

    @Test
    func comparingBitmapWithNullRightPointer_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = ___ptr_comp_bitmap(UnsafeNode.template, .nullptr)
      }
    }

    @Test
    func creating128BitBitmapForNullPointer_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = UnsafeMutablePointer<UnsafeNode>.nullptr.___ptr_bitmap_128()
      }
    }

    @Test(arguments: NullPrecondition.allCases)
    func nullAlgorithmPrecondition_terminatesProcess(_ operation: NullPrecondition) async {
      switch operation {
      case .freeMinimum:
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          _ = __tree_min(.nullptr)
        }
      case .freeMaximum:
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          _ = __tree_max(.nullptr)
        }
      case .freeNext:
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          _ = __tree_next(.nullptr)
        }
      case .freeNextIterator:
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          _ = __tree_next_iter(.nullptr)
        }
      case .freePreviousIterator:
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          _ = __tree_prev_iter(.nullptr)
        }
      case .protocolMinimum:
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          let harness = AlgorithmHarness()
          _ = harness.__tree_min(.nullptr)
        }
      case .protocolMaximum:
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          let harness = AlgorithmHarness()
          _ = harness.__tree_max(.nullptr)
        }
      case .protocolNext:
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          let harness = AlgorithmHarness()
          _ = harness.__tree_next(.nullptr)
        }
      case .protocolNextIterator:
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          let harness = AlgorithmHarness()
          _ = harness.__tree_next_iter(.nullptr)
        }
      case .protocolPreviousIterator:
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          let harness = AlgorithmHarness()
          _ = harness.__tree_prev_iter(.nullptr)
        }
      case .protocolLeaf:
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          let harness = AlgorithmHarness()
          _ = harness.__tree_leaf(.nullptr)
        }
      case .leftRotateNode:
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          let harness = AlgorithmHarness()
          harness.__tree_left_rotate(.nullptr)
        }
      case .leftRotateMissingRightChild:
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          let harness = AlgorithmHarness()
          let node = UnsafeMutablePointer<UnsafeNode>.allocate(capacity: 1)
          node.initialize(to: .create(tag: 0, nullptr: .nullptr))
          harness.__tree_left_rotate(node)
        }
      case .rightRotateNode:
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          let harness = AlgorithmHarness()
          harness.__tree_right_rotate(.nullptr)
        }
      case .rightRotateMissingLeftChild:
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          let harness = AlgorithmHarness()
          let node = UnsafeMutablePointer<UnsafeNode>.allocate(capacity: 1)
          node.initialize(to: .create(tag: 0, nullptr: .nullptr))
          harness.__tree_right_rotate(node)
        }
      case .balanceRoot:
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          let harness = AlgorithmHarness()
          harness._ptr__tree_balance_after_insert(.nullptr, .nullptr)
        }
      case .balanceInsertedNode:
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          let harness = AlgorithmHarness()
          harness._ptr__tree_balance_after_insert(UnsafeNode.template, .nullptr)
        }
      case .removeRoot:
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          let harness = AlgorithmHarness()
          harness._ptr__tree_remove(.nullptr, .nullptr)
        }
      case .removeNode:
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          let harness = AlgorithmHarness()
          harness._ptr__tree_remove(UnsafeNode.template, .nullptr)
        }
      case .removeMalformedTree:
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          let harness = AlgorithmHarness()
          harness._ptr__tree_remove(UnsafeNode.template, UnsafeNode.template)
        }
      }
    }
  }
#endif
