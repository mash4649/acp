# ACP 統合パターン集

この文書は、ACP を周辺システムと実務的に組み合わせるときの定石をまとめたものです。ACP をオーケストレーション、トランスポート、精算レールに吸収しないことを前提にします。

## 1. MCP + ACP

### 境界
- MCP は tool discovery とメッセージ交換を担当する。
- ACP は agreement, revision, evidence, verification, settlement の境界を記録する。
- MCP メッセージを契約レコードとして扱わない。

### Artifact の流れ
- MCP セッションで作業を開始する。
- ACP `agreement_v1` で委任範囲を固定する。
- ACP `revision_v1` でスコープ変更を記録する。
- ACP `event_v1` で因果順の重要マイルストーンを残す。
- ACP `evidence_pack_v1` と `verification_report_v1` で claim を evidence に結び付ける。

### 障害時の扱い
- MCP セッションが切れても ACP の履歴は保持し、再開時は新しい revision か dispute を追加する。
- tool output に evidence が足りない場合は、accepted に書き換えず verification incomplete とする。
- tool graph が変わった場合、既存 ACP artifact を上書きしない。

### 最小導入
- まず 1 つの MCP tool call を 1 つの ACP agreement で包む。
- scope や tool set が変わる時だけ revision を追加する。
- release や settlement に効く結果にだけ evidence / verification を付ける。

## 2. A2A + ACP

### 境界
- A2A は agent-to-agent の交換を担当する。
- ACP は何が合意され、何が変わり、何が検証され、何が精算されるかを記録する。
- A2A envelope を authorization の証拠として扱わない。

### Artifact の流れ
- A2A message で intent を交渉する。
- ACP `agreement_v1` で委任境界を固定する。
- ACP `delegation_edge_v1` で parent/child の責任を表す。
- ACP `time_fact_v1` と `effective_policy_projection_v1` で replay 可能な判断を明示する。
- ACP `settlement_intent_v1` は verification と分離する。

### 障害時の扱い
- child agent が委任範囲外で動いたら、dispute を開き、該当境界を freeze する。
- 時刻依存ポリシーが曖昧なら、`time_fact_v1` が明示されるまで projection を拒否する。
- 複数 agent が同じ authority を主張したら、transport metadata ではなく ACP 側で解決する。

### 最小導入
- parent agreement 1 件と child delegation edge 1 件から始める。
- schedule や observation time が必要なときだけ time fact を足す。
- settlement intent は verification 完了後に追加する。

## 3. Workflow Engine + ACP

### 境界
- workflow engine は step を制御する。
- ACP は監査可能な境界と evidence trail を保持する。
- workflow state を唯一の責務記録にしない。

### Artifact の流れ
- workflow engine が job を開始する。
- ACP `agreement_v1` が委任作業を定義する。
- ACP `revision_v1` が workflow の変更や再計画を記録する。
- ACP `event_v1` がレビュー対象の state transition を残す。
- ACP `freeze_record_v1` が blocked / disputed の経路を記録する。

### 障害時の扱い
- retry は workflow state に残し、ACP event は意味のある境界変更だけに出す。
- step が失敗しても evidence があるなら失敗を記録し、evidence pack は保持する。
- engine が rollback しても ACP history を巻き戻さず、代わりに補償 artifact を積む。

### 最小導入
- 1 つの重要 workflow を 1 つの ACP agreement で包む。
- authorization, evidence, settlement に影響する transition だけ event 化する。
- happy path を外れたときだけ freeze / dispute を追加する。

## 4. Payment Rail + ACP

### 境界
- payment rail は value movement を担当する。
- ACP は settlement を許可する条件を記録する。
- ACP を money movement layer として使わない。

### Artifact の流れ
- ACP `verification_report_v1` が outcome を確認する。
- ACP `settlement_intent_v1` が rail で何を起こすかを表す。
- rail が transfer / release を実行する。
- ACP `event_v1` と `freeze_record_v1` が判断と block を記録する。

### 障害時の扱い
- settlement が失敗しても verification は残し、settlement は別管理にする。
- rail が partial success を返したら、古い intent を書き換えず新しい settlement intent を出す。
- dispute が開いたら、境界解決まで future settlement を freeze する。

### 最小導入
- まず 1 回の verification の後に 1 つの settlement intent を出す。
- rail 実行は idempotent かつ外部から観測可能にする。
- partial release や dispute 対応は、必要になってから導入する。

## 反パターン
- ACP を message bus や task runner として使う。
- transport envelope に settlement 状態を埋め込む。
- append ではなく上書きで履歴を変える。
- verification 成功を自動的な settlement 承認とみなす。
- platform 固有メタデータで agreement や evidence を置き換える。

## 相互運用ガードレール
- contract / evidence / settlement artifact は分離する。
- mutable state より append-only history を優先する。
- relative path と timestamp は明示的に解決する。
- 高位 flow に使う前に、それぞれの artifact を schema で検証する。
- ACP 境界を保てないシステムには、ACP の意味を弱めるのではなく薄い adapter を足す。
