# トラブルシューティング

> **対象読者**: 全員

## ビルドの問題

### `lake exe cache get` が失敗またはハングする

**原因**: ネットワークの問題、または Mathlib キャッシュサーバーが利用不可。

**解決策**:
1. リトライ — 一時的なネットワークエラーはよくあります。
2. [leanprover-community/mathlib4](https://github.com/leanprover-community/mathlib4) で Mathlib キャッシュの状態を確認。
3. プロキシの背後にいる場合は `HTTPS_PROXY` を設定：
   ```bash
   export HTTPS_PROXY=http://proxy:port
   lake exe cache get
   ```
4. 最終手段として、Mathlib をソースからビルド（30〜60分かかります）：
   ```bash
   lake build
   ```

### `lake build` でメモリ不足

**原因**: Mathlib や大規模な証明ファイルのビルドには十分な RAM（8 GB以上推奨）が必要。

**解決策**:
1. 並列度を下げる：`lake build -j 1`
2. 他のアプリケーションを閉じてメモリを解放。
3. `lake exe cache get` を使って Mathlib のソースビルドを回避。

### ビルド中に `sorry` 警告

**原因**: 証明ファイルに不完全な証明がある。

**備考**: メインライブラリ（`WasmNum` ターゲット）と証明（`WasmNumProofs` ターゲット）には `sorry` が含まれないはずです。`sorry` 警告が表示された場合：
1. 開発ブランチではなく、リリースタグにいることを確認。
2. 実行：`grep -rn '\bsorry\b' WasmNum/ --include="*.lean" | grep -v '^\s*--'`

### Lean バージョンが不正

**原因**: elan が未インストール、または `lean-toolchain` が読み取られていない。

**解決策**:
```bash
# 現在のバージョンを確認
lean --version

# lean-toolchain の内容と一致するはず
cat lean-toolchain
# leanprover/lean4:v4.29.0-rc6

# 不一致の場合、elan がインストールされ PATH にあることを確認
elan show
```

## エディタの問題

### Lean 4 言語サーバーが起動しない

1. プロジェクトルートに `lean-toolchain` が存在することを確認。
2. VS Code でサブフォルダではなく、ワークスペースのルートフォルダを開く。
3. Lean 4 拡張機能の出力パネルでエラーを確認。
4. `lake env printPaths` を実行して Lake が環境を解決できるか確認。

### 型チェックが遅い

Mathlib を多用するファイルは初回チェックに10〜30秒かかることがあります。これは想定通りです。同じファイル内のその後の編集はインクリメンタルで高速になります。

## テストの問題

### テスト失敗

```bash
# テストを実行して出力を確認
lake build TestAll
```

テストは `#eval` を使用し、合格/不合格のカウントを表示します。テストが失敗した場合：
1. 出力で具体的なテスト名を確認。
2. まずフルライブラリがビルドされることを確認：`lake build WasmNum`
3. コードベースに `sorry` がないか確認。

## 証明の問題

### 意図しない公理を使用する証明

公理監査を実行：
```bash
# WasmNumProofs で使用される公理を確認
lake env lean --run WasmNumProofs.lean 2>&1 | grep "axiom"
```

期待される公理（Lean/Mathlib 標準）：
- `propext`
- `Quot.sound`
- `Classical.choice`

## 関連ドキュメント

- [インストール](../getting-started/installation.md) — セットアップ手順
- [設定](configuration.md) — ビルドオプション
- [開発環境セットアップ](../development/setup.md) — コントリビューター環境
- [English Version](../../en/guides/troubleshooting.md)
