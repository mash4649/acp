# ACP（AI Contract Protocol）

ACP は、委任された AI 作業に対するアカウンタビリティ層です。

ACP は実行フレームワークでも、トランスポートプロトコルでも、決済レールでもありません。

## まずここから（非エンジニア/エンジニア共通）

- **1枚ベースライン（適用範囲 / Core-15 / 分離原則）**: `docs/ja/00_package_baseline.md`
- **v1 成立宣言と証跡パス**: `docs/ja/19_v1_declaration.md`
- **v1 全ゲートの再現実行（証跡更新）**: `./scripts/verify_v1_bundle.sh`

## 覚えておく3行

- プロンプトは契約ではありません。
- 主張は証拠ではありません。
- 検証は精算ではありません。

## ACP がすること（短縮）

ACP は、**合意/改訂**・**追記専用の因果イベント**・**証拠連動の検証**・**明示的な精算意図**・**異議/凍結**を「後から再現検証できる形」でつなぐ、狭い相互運用境界です。ランタイム/トランスポート/ペイメントを置き換えず、それらをまたいだアカウンタビリティ意味論を提供します。

## Conformance ステータス
現在の状態: この `public_bundle` において ACP v1 は成立済みです。

現時点で提供済み:
- リポジトリ内 conformance adapter 契約（`/conformance`）
- Phase 1/2/3 プロファイル、schema vectors、不変条件ケース
- リポジトリ内 reference harness（`/scripts/reference_harness.py`）
- mock/reference/external に分離した CI ゲート
- external harness runner ラッパ（`/scripts/conformance.sh`）

この bundle には、non-mock の ACP harness adapter エントリポイントが含まれます:
- `ACP_HARNESS_RUNNER=./scripts/acp_harness_runner.sh`

## リポジトリ構成
- `/schemas/core` Core-15 をカバーするコアスキーマ
- `/schemas/companion` バインディング/コンパニオンスキーマ
- `/schemas/meta` reason codes と status registers
- `/schemas/vectors` valid/invalid のスターターベクタ
- `/examples` minimal-task と delegated-research バンドル
- `/conformance` 薄い harness 契約/プロファイル/レポートスキーマ
- `/scripts` conformance adapter のエントリポイント

## 互換性の立場
ACP は MCP、A2A、ワークフローエンジン、決済システムを置き換えず、それらをまたいだアカウンタビリティ意味論を提供します。

## 公開ドキュメント
- `docs/README.md`（日英統合インデックス）
- `docs/en/README.md`（英語インデックス）
- `docs/ja/README.md`（日本語インデックス）

## Launch Surface
- `docs/en/01_message_map.md`
- `docs/en/02_launch_copy_bank.md`
- `docs/en/03_demo_script_90s.md`
- `docs/en/04_share_faq.md`
- `docs/en/07_channel_playbook.md`
- `docs/en/08_demo_script_30s.md`
- `docs/en/09_demo_script_3min.md`
- `docs/en/13_objection_memo.md`
- `./scripts/public_release_check.sh` は公開メッセージのガードレールを検証します（**ripgrep** `rg` が必要。macOS: `brew install ripgrep`）
- `./scripts/verify_v1_bundle.sh` は依存導入と v1 全ゲートを実行し、`conformance/out/` の監査用証跡を更新します（`docs/ja/19_v1_declaration.md` 参照）
- **別途フル ACP チェックアウト**を持つ場合のみ、そのツリーの `project/scripts/prepare_public_bundle.sh` が `release/distribution_bundle/` を配布用ディレクトリへコピーします（このリポジトリには同梱されません）

## Conformance Adapter クイックスタート
- `./scripts/install_conformance_deps.sh`（Python 依存を versioned な `.tmp/conformance-deps-pyXY` ディレクトリに導入します）
- `./scripts/verify_v1_bundle.sh`（依存導入後に公開チェック・selftest・required-external・security minimum を実行し、`conformance/out/v1-evidence.*` を更新します）
- `ACP_AUTO_INSTALL_CONFORMANCE_DEPS=1 ./scripts/conformance_selftest.sh`（クリーン環境で selftest のみを通す省略形）
- `./scripts/conformance.sh doctor`
- `./scripts/conformance.sh prepare`
- `./scripts/conformance.sh run --mock`
- `./scripts/conformance.sh run --reference`
- `ACP_HARNESS_RUNNER=./scripts/acp_harness_runner.sh ./scripts/conformance.sh run`
- `ACP_HARNESS_RUNNER=/path/to/runner ./scripts/conformance.sh run`
- `ACP_HARNESS_RUNNER=./scripts/mock_external_runner.sh ./scripts/conformance.sh run`

## Conformance CI ゲート
- `ACP_CONFORMANCE_MODE=mock ./scripts/conformance_ci.sh`
- `ACP_CONFORMANCE_MODE=reference ACP_CONFORMANCE_PROFILE=conformance/profiles/phase2.profile.json ./scripts/conformance_ci.sh`
- `ACP_CONFORMANCE_MODE=external ACP_HARNESS_RUNNER=/path/to/runner ./scripts/conformance_ci.sh`
- `ACP_CONFORMANCE_MODE=required-external ACP_HARNESS_RUNNER=/path/to/runner ./scripts/conformance_ci.sh`
- `ACP_HARNESS_RUNNER=/path/to/runner ./scripts/external_release_gate.sh`（required-external のリリース証跡を生成）
- `.github/workflows/conformance.yml` は push/PR/manual のエントリポイントを含みます
- `./scripts/conformance_selftest.sh` は mock/reference/contract-smoke/negative-path に加え、`[7/7]` で reference と bundled runner の parity（ゼロ差分期待）を実行します
- `./scripts/conformance_parity.sh` は同一プロファイルで reference と `ACP_HARNESS_RUNNER` のレポートを比較し、`conformance/out/parity/parity-report.<profile>.json` を出力します（不一致で非ゼロ終了）
- `ACP_HARNESS_RUNNER=... ACP_HARNESS_RUNNER_2=... ./scripts/production_runner_compare.sh` は2つの本番 runner の required-external 結果を突き合わせます（内部は `conformance_parity.sh` の `runner-runner` モード）

## Security/Ops Minimum（v1）
- `./scripts/security_ops_minimum.sh doctor`
- `./scripts/security_ops_minimum.sh all`
- 出力先: `conformance/out/security/`
- 運用手順: `docs/ja/18_security_ops_minimum_runbook.md`

## External Runner に関する注意
- `scripts/mock_external_runner.sh` は契約テスト用ユーティリティです。
- これはプロトコル検証器ではなく、フル external harness の代替にはなりません。
- `scripts/reference_harness.py` はリポジトリ内ベースラインであり、下記 bundled adapter の実装にも使われます。
- `scripts/acp_harness_runner.sh` は **bundled non-mock harness adapter** です。harness CLI 契約を満たし、`docs/ja/19_v1_declaration.md` と `conformance/out/` の required-external 証跡で使われます。

## ACP external harness と agent runtime の違い
- `ACP_HARNESS_RUNNER` には、`/conformance` で定義された harness CLI 契約（例: `--contract`、`--profile`、`--request`、`--report`）を満たす実行ファイルを指定する必要があります。
- agent runtime は別製品です。契約アダプタなしにその CLI を `ACP_HARNESS_RUNNER` へ直接渡すことはできません（この bundle は契約適合 adapter として `acp_harness_runner.sh` を同梱しています）。
