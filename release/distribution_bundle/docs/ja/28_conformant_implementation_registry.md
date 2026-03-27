# 適合実装レジストリ

この文書は、静的サイトとして公開する ACP 適合実装レジストリの運用を説明します。

## 目的

認定 claim と証跡リンクを、公開かつ追跡可能な形で提示します。

## レジストリ成果物

- 機械可読ソース: `docs/registry/implementations.json`
- 公開ページ: `docs/registry/index.html`
- 生成スクリプト: `scripts/render_conformance_registry.sh`

## 生成コマンド

```bash
./scripts/render_conformance_registry.sh
```

入力/出力パスは引数で上書きできます。

```bash
./scripts/render_conformance_registry.sh /path/to/implementations.json /path/to/index.html
```

## エントリ項目

各エントリには次を含めます。

- implementation ID と表示名
- maintainer
- 認定レベル（`L1` / `L2` / `L3`）
- 状態（`active` / `revoked` / `suspended` / `expired`）
- self-authored フラグ
- 対応 profile
- 証跡リンク（report / suite manifest）
- 発行日 / 更新期限

## KPI 注記

self-authored のエントリは透明性のために掲載しますが、外部適合実装数の KPI には算入しません。

