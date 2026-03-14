# コードスタイル

> **対象読者**: コントリビューター

wasm-num のコーディング規約。

## Lean オプション

```toml
# lakefile.toml
[[lean_lib]]
leanOptions = [
  { name = "autoImplicit",        value = false },
  { name = "relaxedAutoImplicit", value = false }
]
```

すべてのユニバース変数、型変数、暗黙引数を明示的に宣言する必要があります。

## 命名規約

### 関数

| パターン | 規約 | 例 |
|---------|------|-----|
| 整数操作 | `i` プレフィックス + 操作名 | `iadd`, `isub`, `imul`, `idiv_u`, `idiv_s` |
| 浮動小数点操作 | `f` プレフィックス + 操作名 | `fmin`, `fmax`, `fabs`, `fneg`, `fcopysign` |
| 符号付き/なしバリアント | `_s` / `_u` サフィックス | `idiv_s`, `idiv_u`, `ilt_s`, `ilt_u` |
| SIMD 整数操作 | 説明的な名前 | `add`, `sub`, `shl`, `shrS`, `shrU`（SIMD 名前空間） |
| SIMD 浮動小数点操作 | `f` プレフィックス + Lane サフィックス | `fadd`, `fminLane`, `fpminLane` |
| 変換 | `<from>To<To><kind>` | `truncF32ToI32S`, `convertI32SToF64` |
| メモリ操作 | 説明的 | `i32Load`, `f64Store`, `fill`, `copy`, `growSpec` |

### 型

| パターン | 規約 | 例 |
|---------|------|-----|
| 型エイリアス | PascalCase 略称 | `I32`, `I64`, `F32`, `F64`, `V128`, `Byte` |
| 構造体 | PascalCase | `FlatMemory`, `WasmProfile`, `Shape`, `GrowResult` |
| 型クラス | PascalCase | `WasmFloat`, `GrowthPolicy` |
| 帰納型 | PascalCase | `LaneType`, `DataSegment`, `MemoryInstance` |

### 証明

| パターン | 規約 | 例 |
|---------|------|-----|
| 性質定理 | `property_subject` | `iadd_comm`, `readByte_writeByte_same` |
| メンバーシップ証明 | `_mem` サフィックス | `selectNaN_mem`, `growSpec_failure_mem` |
| 境界証明 | 説明的 | `effectiveAddr_toNat`, `pageSize_pos` |

## モジュール構成

- 1ファイルにつき1概念（例：`Arithmetic.lean` は整数算術用）
- サブディレクトリでグループ化：`Integer/`、`Float/`、`NaN/`、`Conversion/`
- 証明は `WasmNum/Proofs/` または `Proofs/` に定義構造をミラーリング
- テストは `WasmTest/` に定義構造をミラーリング

## インポート順序

1. Mathlib インポート（必要に応じて）
2. Foundation インポート
3. 同一レイヤーインポート
4. クロスレイヤー下方向インポート禁止（アーキテクチャにより強制）

## コード内ドキュメント

- パブリック定義にドキュメントコメント：`/-- ... -/`
- 非自明なロジックには簡潔なインラインコメント
- 自明な定義にはボイラープレートコメントなし

## 関連ドキュメント

- [プロジェクト構成](project-structure.md)
- [アーキテクチャ](../architecture/) — レイヤールール
- [コントリビューティング](../../CONTRIBUTING.md)
- [English Version](../../en/development/code-style.md)
