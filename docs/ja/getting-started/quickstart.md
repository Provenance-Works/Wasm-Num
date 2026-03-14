# クイックスタート

> **対象読者**: ユーザー

wasm-num を5分以内にビルド・検証します。

## 1. クローンとビルド

```bash
git clone https://github.com/Provenance-Works/wasm-num.git
cd wasm-num
lake exe cache get
lake build
```

## 2. 検証

```bash
# テストスイートを実行（12モジュール・414テスト）
lake build TestAll
```

## 3. 探索

VS Code で lean4 拡張機能を使って任意のファイルを開き、インタラクティブな型チェックと定義ジャンプを利用できます。

### 例：整数演算

```lean
import WasmNum.Foundation.Types
import WasmNum.Numerics.Integer.Arithmetic

open WasmNumerics

-- 32ビット剰余加算
#eval iadd (3 : I32) (4 : I32)        -- 7
#eval iadd (0xFFFFFFFF : I32) (1 : I32) -- 0（ラップ）

-- 除算（Option を返す — ゼロ除算で None）
#eval idiv_u (10 : I32) (3 : I32)     -- some 3
#eval idiv_u (10 : I32) (0 : I32)     -- none
```

### 例：メモリ操作

```lean
import WasmNum.Memory.Core.FlatMemory
import WasmNum.Memory.Load.Scalar
import WasmNum.Memory.Store.Scalar

open WasmMemory

-- 1ページメモリを作成（64 KiB）
#eval do
  let mem := FlatMemory.empty 32 (some 10)  -- 32ビット、最大10ページ
  -- アドレス0に32ビット値をストア
  let some mem' := i32Store mem (0 : Addr32) (0x42 : I32) | return "store failed"
  -- それをロードバック
  let some val := i32Load mem' (0 : Addr32) | return "load failed"
  return s!"Loaded: {val}"  -- "Loaded: 66"
```

### 例：SIMD レーン

```lean
import WasmNum.SIMD.V128.Lanes
import WasmNum.SIMD.Ops.IntLanewise

open WasmSIMD

-- 値をすべてのi32レーンにスプラットしてV128を作成
#eval
  let v := splat Shape.i32x4 (42 : BitVec 32)
  lane Shape.i32x4 v ⟨0, by omega⟩  -- 42
```

## ビルドターゲット

| コマンド | ビルド内容 | 所要時間（キャッシュ済み） |
|---------|-----------|:------------------------:|
| `lake build WasmNum` | 定義のみ | 約30秒 |
| `lake build WasmNumProofs` | 定義 + 証明 | 約2分 |
| `lake build TestAll` | テストスイート | 約30秒 |
| `lake build` | デフォルトターゲット（WasmNum + WasmNumProofs） | 約2分 |

## 次のステップ

- [アーキテクチャ](../architecture/) — レイヤード設計を理解する
- [APIリファレンス](../reference/api/) — すべての操作を閲覧
- [設計決定](../design/adr/) — そうである理由を理解する

## 関連ドキュメント

- [インストール](installation.md) — 詳細なインストール手順
- [トラブルシューティング](../guides/troubleshooting.md) — よくある問題
- [English Version](../../en/getting-started/quickstart.md)
