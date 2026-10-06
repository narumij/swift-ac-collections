//
//  _LazyTieWrappedPtr+Retired.swift
//  swift-ac-collections
//
//  PR #158以前のIndex（`_LazyTieWrappedPtr`）向けに本体にあった宣言の待避先。
//  2026-10-06時点で本体・テストのどちらからも使われていないことを確認し、削除の判断を保留して
//  ここへ移した。性能上の属性（`@inlinable`等）は外している。
//

#if DEBUG
  @testable import RedBlackTreeCollections

  extension Result where Success == _LazyTieWrap<_NodePtrSealing>, Failure == SealError {

    // ポインタを利用する際に用いる
    #if USE_LAZY_DETACH
      package var purified: Result { flatMap { $0.purified } }
    #else
      package var purified: Result {
        flatMap {
          $0.lazyDetach.isDetached ? .failure(.detached) : $0.purified
        }
      }
    #endif

    package var isValid: Bool {
      switch purified {
      case .success: true
      default: false
      }
    }

    package var sealed: _SealedPtr {
      map(\.rawValue)
    }
  }

  extension Result where Success == _LazyTieWrap<_NodePtrSealing>, Failure == SealError {

    package static func unsafe<Base: ___TreeBase>(tree: UnsafeTreeV2<Base>, rawTag: _TrackingTag)
      -> Self
    {
      if rawTag == .nullptr {
        return .failure(.null)
      }

      return tree.__retrieve_(rawTag)
        .flatMap(\.uncheckedSeal)
        .flatMap { $0.band(tree) }
    }
  }

  extension Result where Success == _LazyTieWrap<_NodePtrSealing>, Failure == SealError {

    package var lazyDetach: _LazyTie? {
      try? map(\.lazyDetach).get()
    }

    func __isSameLazyDetach(_ rhs: _LazyTie?) -> Bool {
      switch self {
      case .success(let handle):
        handle.lazyDetach === rhs
      case .failure:
        false
      }
    }
  }

  extension UnsafeTreeV2 {

    #if ALLOW_CROSS_TREE_INDEX
      // TODO: デタッチ判定が分裂してることについて確認すること
      // インデックスをポインタに解決する
      //
      // 木が同一の場合、インデックスが保持するポインタを返す。
      // 木が異なる場合、インデックスが保持するノード番号に対応するポインタを返す。
      package func __purified_(_ index: _LazyTieWrappedPtr) -> _SealedPtr {
        #if USE_LAZY_DETACH
          // 同一木判定
          withMutableHeader { index.__isSameLazyDetach($0._lazyDetach) }
            // 木が同一のケース
            // 中身を取り出し、生存確認を行って返している
            ? index.sealed.purified
            // 木が異なるケース
            // 中身を取り出し、元の木に対して生存確認を行ってからタグを取得
            // タグで該当ポインタを取得
            // 該当ポインタの生存確認を行う（解放確認で十分なところ、実装サボりで生存確認になっていそう）
            // 要は、元の木と現在の木のどちらかで失効している場合、失効ポインタを返す動作
            : __retrieve_(index.sealed.purified.tag).deepPurified
        #else
          // 同一木判定
          withMutableHeader { index.__isSameLazyDetach($0._lazyDetach) }
            // 木が同一のケース
            ? index.sealed.purified
            // 木が異なるケース
            // Indexに保存した世代を、利用対象の木にある対応ノードへ照合する
            // CoWで分岐した別の木の変更は、このIndexの有効性へ影響させない
            : __retrieve_(index.sealed.tag).deepPurified
        #endif
      }
    #else
      package func __purified_(_ index: _LazyTieWrappedPtr) -> _SealedPtr {
        // 同一木判定
        withMutableHeader { index.__isSameLazyDetach($0._lazyDetach) }
          // 木が同一のケース
          ? index.sealed.purified
          // 木が異なるケース
          : .failure(.crossTree)
      }
    #endif

    internal func __purified_safe_(_ index: _LazyTieWrappedPtr) -> _SafePtr {
      __purified_(index).map(\.pointer)
    }
  }
#endif
