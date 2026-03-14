# ADR-0005: FlatMemory のアドレス幅パラメータ化

| | |
|---|---|
| **ステータス** | 承認済 |
| **日付** | 2025 |
| **決定者** | wasm-num メンテナー |

## コンテキスト

WebAssembly には2つのメモリプロポーザルがあります：
- **Memory32**: 32ビットアドレス、最大 4 GiB（65536ページ）
- **Memory64**: 64ビットアドレス、最大 〜16 EiB

すべてのメモリ操作（load、store、grow、copy、fill、init）はアドレス幅に関係なく同一の動作をし、アドレスサイズと最大ページ数のみが異なります。

## 決定

`FlatMemory` とすべての操作を `addrWidth : Nat` でパラメータ化します：

```lean
structure FlatMemory (addrWidth : Nat) where
  data      : ByteArray
  pageCount : Nat
  maxLimit  : Option Nat
  inv_dataSize : data.size = pageCount * pageSize
  inv_addrFits : pageCount * pageSize ≤ 2 ^ addrWidth
  ...

abbrev Memory32 := FlatMemory 32
abbrev Memory64 := FlatMemory 64
```

アドレスは `BitVec addrWidth` です。`i32Load`、`fill`、`copy` などの操作はすべて `addrWidth` に対してジェネリックです。

## 影響

### 肯定的
- Memory32 と Memory64 を一つの実装で対応
- アドレスオーバーフローチェックが `addrWidth` を自然に使用
- 最大ページ数が `2 ^ addrWidth / pageSize` から導出
- 証明が両方のアドレス幅で統一的に動作
- マルチメモリサポートが容易（Memory32 と Memory64 インスタンスの混在）

### 否定的
- 一部の操作に `addrWidth` の制約が必要（例：`addrWidth ≤ 64`）
- 固定32ビットよりもやや複雑な型シグネチャ

### 中立的
- `Addr32 = BitVec 32`、`Addr64 = BitVec 64` が利便性エイリアスとして提供
- `MultiMemory` モジュールが異なるアドレス幅を直和型でラップ

## 検討した代替案

### Memory32 / Memory64 の個別実装
完全に独立した2つのモジュール。却下：load、store、grow、copy、fill、init、境界チェックなどの大量のコード重複。

### GADT / インデックスファミリ
アドレス幅でインデックスされた帰納型を使用。却下：Lean 4 ではパラメータ化のほうがシンプルで十分です。

### 常に64ビット、32ビットはマスク
内部的に64ビットを使用し、Memory32 ではアドレスをマスク。却下：アドレス幅の型レベルでの追跡が失われます。

---

*[English Version](../../../en/design/adr/0005-flatmemory-parameterized-address-width.md)*
