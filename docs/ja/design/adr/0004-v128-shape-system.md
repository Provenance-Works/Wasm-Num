# ADR-0004: SIMD 用 V128 Shape システム

| | |
|---|---|
| **ステータス** | 承認済 |
| **日付** | 2025 |
| **決定者** | wasm-num メンテナー |

## コンテキスト

WebAssembly SIMD は128ビットベクター（`v128`）を操作し、異なるレーン構成で解釈できます：

- i8x16（16レーン × 8ビット整数）
- i16x8（8レーン × 16ビット整数）
- i32x4（4レーン × 32ビット整数）
- i64x2（2レーン × 64ビット整数）
- f32x4（4レーン × 32ビット浮動小数点数）
- f64x2（2レーン × 64ビット浮動小数点数）

多くの SIMD 演算（加算、減算、比較など）はシェイプ間で同一の動作をし、レーン幅のみが異なります。このロジックを共有する方法が必要です。

## 決定

`laneWidth × laneCount = 128` を制約とする `Shape` 構造体を定義します：

```lean
structure Shape where
  laneWidth : Nat
  laneCount : Nat
  laneType  : LaneType
  valid     : laneWidth * laneCount = 128
  widthPow2 : ∃ k, laneWidth = 2 ^ k ∧ 3 ≤ k ∧ k ≤ 6
```

SIMD 演算は `Shape` をパラメータとして取り、`mapLanes` / `zipLanes` でレーンワイズリフティングを行います：

```lean
def add (s : Shape) (a b : V128) : V128 := zipLanes s iadd a b
```

## 影響

### 肯定的
- 1演算1実装で全6シェイプに対応
- レーン幅制約が機械的にチェックされる（無効なシェイプの作成不可）
- `laneType` が型レベルで整数シェイプと浮動小数点シェイプを区別
- コンパクト — 6つの具象シェイプが定数として定義、6つの別実装は不要

### 否定的
- Shape パラメータが間接レベルを一つ追加
- 一部の演算はシェイプ固有（例：`popcnt_i8x16`）で汎用化不可

### 中立的
- `Shape.all : List Shape` がすべての有効なシェイプを列挙し、網羅的テストに利用可能
- Relaxed SIMD もレーンワイズ演算にシェイプを使用

## 検討した代替案

### シェイプごとの個別型
`I8x16`、`I16x8` などを個別の型として定義。却下：コードの大量重複（各レーンワイズ演算 × 6シェイプ）。

### Fin インデックスベクター
`Vector (BitVec laneWidth) laneCount` を使用。却下：`V128` と `Vector` 間の変換にオーバーヘッドがあり、Shape システムはすべてを `BitVec 128` のまま抽出関数で処理します。

### 型レベル Shape エンコーディング
依存型でシェイプ情報を型にエンコード。却下：不必要な複雑性であり、ランタイムの `Shape` パラメータのほうがシンプルで十分です。

---

*[English Version](../../../en/design/adr/0004-v128-shape-system.md)*
