# 認定テストスイートのパッケージ化

この文書は、外部で conformance を実行できる配布用ベースラインを出力する `scripts/export_certification_suite.sh` を説明します。

## レベル対応

| レベル | 対応する phase profile | Profile ID |
| --- | --- | --- |
| `level1` | `conformance/profiles/phase1.profile.json` | `phase1-accountability-minimum` |
| `level2` | `conformance/profiles/phase2.profile.json` | `phase2-delegation-policy-safety` |
| `level3` | `conformance/profiles/phase3.profile.json` | `phase3-proof-surface-bindings` |

選択したレベルは、パッケージ内の README と manifest で参照される中心プロフィールになります。

## 使い方

```bash
./scripts/export_certification_suite.sh --level level1
./scripts/export_certification_suite.sh --level level2 --out-root .tmp/certification-suite
./scripts/export_certification_suite.sh --level level3 --out-root /tmp/acp-suite-export
```

このスクリプトはレベルを検証し、パッケージディレクトリを作成し、同時に gzip 形式の tarball も出力します。

## 出力

`--level level1` の既定出力名は次の通りです。

- `ACP-certification-suite-level1/`
- `ACP-certification-suite-level1.tar.gz`

出力ディレクトリには次が含まれます。

- パッケージ固有の使い方を記載した `README.md`
- 機械可読な一覧メタデータを持つ `manifest.json`
- 契約、profile、vector、case、template、ローカルメタデータを含む `conformance/`
- スキーマカタログと vector fixture を含む `schemas/`
- conformance 実行用の runner と補助スクリプトを含む `scripts/`
- `LICENSE`
- `requirements-conformance.lock`
- ソースツリーに存在する場合の `requirements-conformance.txt`

`conformance/out/` は意図的に除外されています。実際に conformance を実行したときに生成されます。

## 証跡の期待値

このパッケージが実用的であるためには、次の証跡が取れることが必要です。

- export スクリプトに対して `bash -n` が成功する
- `./scripts/conformance.sh doctor --profile <選択した profile>` が `doctor: ok` を返す
- `./scripts/conformance.sh run --reference --profile <選択した profile>` または外部ハーネス実行で `conformance/report.schema.json` に一致する report が生成される
- パスする実行では `profile_id`、`status`、`failed = 0` が期待通りである
- 実行リクエスト、report、stdout/stderr ログを証跡として保持する

## パッケージ注記

生成される `manifest.json` には次が記録されます。

- 選択した level と phase
- 選択した profile のパスと profile ID
- schema / vector / case の件数
- エクスポートに含めたパス一覧

この実用ベースラインは、ソースリポジトリ外でも conformance を実行できることを優先して、十分な資材をまとめて出力します。
