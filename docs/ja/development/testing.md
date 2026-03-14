# テスト

> **対象読者**: コントリビューター

## 概要

wasm-num は `WasmTest/` ディレクトリに 414 のテストを持ちます。テストは Lean 4 の `#guard` と `#eval` のアサーションを使用。

## テストの実行

```bash
lake build TestAll
```

テストはビルドの一部としてコンパイルされます。コンパイルが成功すれば、すべての `#guard` アサーションはパスしています。

## テスト構成

| モジュール | ソース | カバレッジ |
|----------|-------|---------|
| `WasmTest.Foundation` | `WasmTest/Foundation.lean` | BitVec 操作、バイト変換、型 |
| `WasmTest.Integer` | `WasmTest/Integer.lean` | すべての整数操作 |
| `WasmTest.Float` | `WasmTest/Float.lean` | 浮動小数点分類、符号操作、比較 |
| `WasmTest.Conversion` | `WasmTest/Conversion.lean` | 型変換 |
| `WasmTest.Integration` | `WasmTest/Integration.lean` | 統合ラッパー |
| `WasmTest.Memory.Core` | `WasmTest/Memory/Core.lean` | FlatMemory、ページ操作 |
| `WasmTest.Memory.LoadStore` | `WasmTest/Memory/LoadStore.lean` | スカラーロード/ストア |
| `WasmTest.Memory.Ops` | `WasmTest/Memory/Ops.lean` | Fill、Copy、Grow、Init、data.drop |
| `WasmTest.SIMD.Core` | `WasmTest/SIMD/Core.lean` | V128 レーン、シェイプ |
| `WasmTest.SIMD.IntOps` | `WasmTest/SIMD/IntOps.lean` | SIMD 整数操作 |
| `WasmTest.SIMD.Misc` | `WasmTest/SIMD/Misc.lean` | Shuffle、Swizzle、Convert |
| `WasmTest.Helpers` | `WasmTest/Helpers.lean` | テストユーティリティ |

## テストの記述

テストはコンパイル時アサーションに `#guard` を使用：

```lean
-- 単純な等値
#guard iadd (0x0001 : I32) (0x0002 : I32) == (0x0003 : I32)

-- Option 結果
#guard idiv_u (0x000A : I32) (0x0002 : I32) == some (0x0005 : I32)

-- トラップ条件
#guard idiv_u (0x0001 : I32) (0x0000 : I32) == none
```

`Set` 返却関数にはメンバーシップテストを使用：

```lean
#guard (someValue : BitVec 32) ∈ propagateNaN₂ WasmFloat.add a b
```

## テスト規約

- テストは `WasmTest/` にソース構造を反映して配置
- テスト名は説明的に — テストこそが仕様
- エッジケースを含む：ゼロ、最大値、オーバーフロー、NaN、±∞
- テストモジュールを `TestAll.lean` にインポート

## テスト vs 証明

wasm-num は実行可能テストと形式証明の両方を持ちます：

| | テスト（`WasmTest/`） | 証明（`WasmNum/Proofs/`、`Proofs/`） |
|---|---|---|
| **内容** | 具体値のアサーション | 全称量化 |
| **タイミング** | 毎ビルド | 毎証明ビルド |
| **保証** | 特定のケースの正しさ | **すべて**のケースの正しさ |
| **例** | `#guard iadd 1 2 == 3` | `theorem iadd_comm : iadd a b = iadd b a` |

## 関連ドキュメント

- [ビルド](build.md) — ビルドターゲット
- [開発環境セットアップ](setup.md) — 環境セットアップ
- [プロジェクト構成](project-structure.md) — テストの配置場所
- [English Version](../../en/development/testing.md)
