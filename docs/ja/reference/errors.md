# エラーリファレンス

> **対象読者**: 全員

wasm-num はエラー（トラップ）を `Option` 型としてモデル化します：`none` がトラップ条件を表します。このドキュメントはすべてのトラップ発生操作をカタログ化します。

## トラップモデル

WebAssembly はトラップ — 回復不能なランタイムエラー — を使用します。wasm-num では、トラップする可能性のある関数は `Option T` を返します：

```lean
-- none = トラップ、some v = 成功
def idiv_u (a b : BitVec N) : Option (BitVec N) := ...
```

エラーコードや例外型はありません。すべてのエラーは構造的です：関数は成功するか、しないかのどちらかです。

## 整数トラップ

| 操作 | 条件 | 仕様 |
|------|------|------|
| `idiv_u` | 除数がゼロ | `i32.div_u`, `i64.div_u` |
| `idiv_s` | 除数がゼロ | `i32.div_s`, `i64.div_s` |
| `idiv_s` | 被除数 = INT_MIN、除数 = -1（符号付きオーバーフロー） | `i32.div_s`, `i64.div_s` |
| `irem_u` | 除数がゼロ | `i32.rem_u`, `i64.rem_u` |
| `irem_s` | 除数がゼロ | `i32.rem_s`, `i64.rem_s` |

> **Note:** `irem_s` は `idiv_s` と異なり、INT_MIN / -1 ではトラップしません（結果は 0）。

## 変換トラップ

| 操作 | 条件 | 仕様 |
|------|------|------|
| `truncF32ToI32S` | NaN 入力 | `i32.trunc_f32_s` |
| `truncF32ToI32S` | ±∞ 入力 | `i32.trunc_f32_s` |
| `truncF32ToI32S` | 結果が i32 符号付き範囲外 | `i32.trunc_f32_s` |
| `truncF32ToI32U` | NaN、±∞、または符号なし範囲外 | `i32.trunc_f32_u` |
| `truncF64ToI32S` | 同様のパターン | `i32.trunc_f64_s` |
| `truncF64ToI32U` | 同様のパターン | `i32.trunc_f64_u` |
| `truncF32ToI64S` | 同様のパターン | `i64.trunc_f32_s` |
| `truncF32ToI64U` | 同様のパターン | `i64.trunc_f32_u` |
| `truncF64ToI64S` | 同様のパターン | `i64.trunc_f64_s` |
| `truncF64ToI64U` | 同様のパターン | `i64.trunc_f64_u` |

> **Note:** 飽和 trunc バリアント（`trunc_sat_*`）はトラップしません — NaN で 0、オーバーフローで min/max を返します。

## メモリトラップ

### ロードトラップ

| 操作 | 条件 | 仕様 |
|------|------|------|
| `i32Load` | `effective_address + 4 > memory.data.size` | `i32.load` |
| `i64Load` | `effective_address + 8 > memory.data.size` | `i64.load` |
| `f32Load` | `effective_address + 4 > memory.data.size` | `f32.load` |
| `f64Load` | `effective_address + 8 > memory.data.size` | `f64.load` |
| `v128Load` | `effective_address + 16 > memory.data.size` | `v128.load` |
| `i32Load8S` 等 | `effective_address + packed_size > memory.data.size` | packed loads |
| 全ロード | `base + offset` がアドレス幅をオーバーフロー | アドレスオーバーフロー |

### ストアトラップ

| 操作 | 条件 |
|------|------|
| `i32Store` | `effective_address + 4 > memory.data.size` |
| `i64Store` | `effective_address + 8 > memory.data.size` |
| `f32Store` / `f64Store` | 4/8 バイトの同様のパターン |
| `v128Store` | `effective_address + 16 > memory.data.size` |
| Packed stores | `effective_address + packed_size > memory.data.size` |

### メモリ操作トラップ

| 操作 | 条件 | 仕様 |
|------|------|------|
| `memory.fill` | `dst + len > memory.data.size`（アドレスオーバーフローまたは OOB） | `memory.fill` |
| `memory.copy` | `src + len > memory.data.size` または `dst + len > memory.data.size` | `memory.copy` |
| `memory.init` | ソースオフセット + len > セグメントサイズ、または dst + len > メモリサイズ、またはセグメントがドロップ済み | `memory.init` |

> **Note:** `memory.grow` はトラップしません。失敗時に -1 を返します。

## 非トラップエラー

これらはトラップとは異なる方法でモデル化されます：

| 状況 | モデル | 説明 |
|------|-------|------|
| `memory.grow` 失敗 | `GrowResult.failure` | -1 を返す（トラップではない）、メモリ不変 |
| Data segment ドロップ済み | `DataSegment.dropped` | ドロップ済みセグメントへの `memory.init` はトラップ；`data.drop` は no-op |

## 関連ドキュメント

- [Numerics API](api/numerics.md) — 整数と変換操作
- [Memory API](api/memory.md) — メモリ操作
- [トラブルシューティング](../guides/troubleshooting.md)
- [English Version](../../en/reference/errors.md)
