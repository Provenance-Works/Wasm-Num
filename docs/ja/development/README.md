# 開発ガイド

> **対象読者**: コントリビューター

wasm-num の開発環境セットアップ、ビルド、テスト、コントリビューションに関するガイド。

## ドキュメント一覧

| ドキュメント | 説明 |
|-----------|------|
| [開発環境セットアップ](setup.md) | 全依存関係・ツールのセットアップ |
| [ビルド](build.md) | ビルドシステム、ターゲット、オプション |
| [テスト](testing.md) | テスト戦略、実行・記述方法 |
| [CI/CD](ci-cd.md) | パイプラインドキュメント |
| [リリース](release.md) | リリースプロセスとバージョニング |
| [プロジェクト構成](project-structure.md) | コードベースナビゲーション — 全フォルダ解説 |
| [コードスタイル](code-style.md) | コーディング規約 |

## クイックスタート

```bash
# クローン
git clone https://github.com/Provenance-Works/wasm-num.git
cd wasm-num

# 定義をビルド
lake build WasmNum

# 証明をビルド
lake build WasmNumProofs

# テスト実行
lake build TestAll
```

## 関連ドキュメント

- [はじめに](../getting-started/) — ユーザーレベルのオンボーディング
- [コントリビューティング](../../CONTRIBUTING.md) — コントリビューションガイドライン
- [アーキテクチャ](../architecture/) — システム設計
- [English Version](../../en/development/)
