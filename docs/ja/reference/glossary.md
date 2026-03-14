# 用語集

> **対象読者**: 全員

wasm-num 全体で使用されるドメイン用語、略語、および定義。

## WebAssembly 型

| 用語 | 定義 |
|------|------|
| **I32** | 32ビット整数型。`BitVec 32` として表現。 |
| **I64** | 64ビット整数型。`BitVec 64` として表現。 |
| **F32** | 32ビット浮動小数点型（IEEE 754 binary32）。`BitVec 32` として表現。 |
| **F64** | 64ビット浮動小数点型（IEEE 754 binary64）。`BitVec 64` として表現。 |
| **V128** | 128ビット SIMD ベクター型。`BitVec 128` として表現。 |
| **Byte** | 8ビット値。`BitVec 8` のエイリアス。 |

## IEEE 754 浮動小数点

| 用語 | 定義 |
|------|------|
| **NaN** | Not a Number。すべての指数ビットがセットされ、仮数部が非ゼロの特殊な浮動小数点値。 |
| **Canonical NaN** | 仮数部の MSB のみがセットされた NaN。仕様は canonical NaN に対して特定の動作を要求。 |
| **Arithmetic NaN** | quiet NaN（仮数部の MSB がセット）。signaling-suppressed NaN とも呼ばれる。 |
| **NaN Propagation** | 操作の入力が NaN の場合に NaN 結果を選択するプロセス。仕様は許容される出力のセットを定義。 |
| **nansN** | 仕様関数 `nans_N{z*}`：許容される NaN 結果のセットを定義。canonical NaN ∪ オーバーラップするペイロードの arithmetic NaN。 |
| **Payload** | NaN 値の仮数部ビット。異なる NaN は異なるペイロードを持つことができる。 |
| **Subnormal** | ゼロ指数で非ゼロ仮数部の浮動小数点数。ゼロ近傍の非常に小さな値を表す。 |
| **端数処理：偶数への丸め** | デフォルトの IEEE 754 丸めモード：正確な結果が2つの表現可能な値の等距離にある場合、偶数の最下位桁を持つ方を選択。 |

## SIMD

| 用語 | 定義 |
|------|------|
| **Shape** | V128 がレーンにどのように分割されるかを記述。レーン幅 × レーン数 = 128 で定義（例：i32x4）。 |
| **Lane** | V128 ベクター内の1つの要素。例：i32x4 は4レーン、各32ビット。 |
| **Lanewise** | SIMD ベクターの各レーンに独立して操作を適用すること。 |
| **Splat** | スカラー値を V128 のすべてのレーンに複製。 |
| **Swizzle** | 別のベクターのインデックス値に基づいてベクターのレーンを並べ替え。 |
| **Shuffle** | 静的インデックスに基づいて2つの入力ベクターからレーンを選択。 |
| **Bitmask** | 各レーンの最上位ビットをスカラー I32 に抽出。 |
| **Narrow** | 飽和付きで幅広レーンを狭めのレーンに変換。例：i16x8 → i8x16。 |
| **Extend** | 符号拡張またはゼロ拡張で狭いレーンを広いレーンに変換。例：i8x16 → i16x8。 |
| **Relaxed SIMD** | ハードウェアネイティブ動作を可能にするため、特定の SIMD 操作で実装定義の結果を許容する Wasm プロポーザル。 |
| **Q15** | 固定小数点格式で、15ビットの小数部が [-1, 1) の値を表す。`i16x8.q15mulr_sat_s` で使用。 |
| **FMA** | Fused multiply-add：`a * b + c` を単一の丸めステップで計算。 |

## メモリ

| 用語 | 定義 |
|------|------|
| **FlatMemory** | バイトアドレッサブルなリニアメモリモデル。アドレス幅（32または64）でパラメータ化。 |
| **Page** | メモリ割り当ての単位。常に 65536 バイト（64 KiB）。 |
| **Memory32** | `FlatMemory 32` — 32ビットアドレスのリニアメモリ。最大 65536 ページ（4 GiB）。 |
| **Memory64** | `FlatMemory 64` — 64ビットアドレスのリニアメモリ。最大 2^48 ページ。 |
| **Effective Address** | `base + offset` — load/store 命令でアクセスされる実際のバイトアドレス。 |
| **Bounds Check** | load/store 前に `effective_address + access_size ≤ memory.data.size` を検証。 |
| **Little-Endian** | 最下位バイトが先頭に来るバイト順。Wasm は LE のみを使用。 |
| **Packed Load** | ターゲット型幅より少ないバイトをロードし、拡張（符号またはゼロ）。例：`i32.load8_s`。 |
| **Packed Store** | 値の下位バイトのみをストア。例：`i32.store8` は下位バイトのみをストア。 |
| **Data Segment** | `memory.init` でリニアメモリにコピーできる読み取り専用バイト配列。ドロップ可能。 |
| **GrowthPolicy** | 決定論的な `memory.grow` 動作のための型クラス。実装は結果が `growSpec` に含まれることを証明する必要がある。 |
| **Multi-Memory** | モジュールごとに複数の独立したリニアメモリを許容する Wasm プロポーザル。 |

## アーキテクチャと設計

| 用語 | 定義 |
|------|------|
| **BitVec N** | Lean 4 / Mathlib の N ビットビットベクターを表す型。すべての Wasm 数値型の普遍的な表現。 |
| **WasmFloat** | IEEE 754 操作を提供する型クラス。数値セマンティクスを特定の浮動小数点実装から分離。 |
| **WasmProfile** | `NaNProfile` + `RelaxedProfile` をバンドルした構造体。非決定論的操作のランタイム動作を決定。 |
| **DeterministicWasmProfile** | `WasmProfile` を拡張し、各決定論的選択が仕様許容セットに含まれることの証明付き。 |
| **NaNProfile** | NaN 選択の設定。`selectNaN` 関数と結果が有効な NaN であることの証明を含む。 |
| **RelaxedProfile** | すべての relaxed SIMD 操作の設定。決定論的実装を提供。 |
| **Set α** | Lean 4 の型 `α → Prop`。非決定性をモデル化 — すべての有効な結果のセット。 |
| **Non-determinism** | 仕様が複数の有効な動作を許容する場合。`Set (BitVec N)` としてモデル化 — 関数は許容される出力の完全なセットを返す。 |
| **Trap** | 実行を終了するランタイムエラー。wasm-num では `Option` 型としてモデル化（none = trap）。 |
| **ADR** | Architecture Decision Record — 重要な設計決定、そのコンテキスト、および結果を記録するドキュメント。 |

## Lean 4 / Mathlib

| 用語 | 定義 |
|------|------|
| **Lean 4** | wasm-num の実装に使用される証明支援系兼プログラミング言語。 |
| **Mathlib** | Lean 4 のコミュニティ数学ライブラリ。`BitVec`、`Finset`、代数的構造、証明タクティクスを提供。 |
| **Lake** | Lean 4 のビルドシステム兼パッケージマネージャー。`lakefile.toml` で設定。 |
| **Typeclass** | アドホック多相性のための Lean メカニズム（Haskell の型クラスや Rust のトレイトに類似）。 |
| **Structure** | Lean 4 の名前付き直積型（レコードや構造体に類似）。 |
| **Inductive** | Lean 4 の代数的データ型（タグ付きユニオン / 直和型）。 |
| **abbrev** | Lean 4 の透過的定義で型エイリアスを作成。`abbrev I32 := BitVec 32`。 |
| **Prop** | Lean 4 の命題の型。値が証明である型。 |
| **omega** | 自然数と整数の線形算術を決定する Lean 4 タクティク。 |
| **simp** | 書き換えルールを使った簡約のための Lean 4 タクティク。 |
| **decide** | 決定可能な命題のための Lean 4 タクティク — ブルートフォース評価。 |

## 略語

| 略語 | 正式名称 |
|------|---------|
| **Wasm** | WebAssembly |
| **IEEE 754** | IEEE Standard for Floating-Point Arithmetic |
| **SIMD** | Single Instruction, Multiple Data |
| **LE** | Little-Endian |
| **MSB** | Most Significant Bit |
| **LSB** | Least Significant Bit |
| **OOB** | Out Of Bounds |
| **FMA** | Fused Multiply-Add |
| **SAT** | Saturating（表現可能な範囲にクランプ） |
| **FFI** | Foreign Function Interface |
| **CI/CD** | Continuous Integration / Continuous Deployment |
| **ADR** | Architecture Decision Record |

## 関連ドキュメント

- [アーキテクチャ概要](../architecture/)
- [Foundation API](api/foundation.md)
- [設計原則](../design/principles.md)
- [English Version](../../en/reference/glossary.md)
