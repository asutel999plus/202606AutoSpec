# Claude Code スラッシュコマンド一覧

作成日: 2026-06-27
出典: [code.claude.com/docs/en/commands.md](https://code.claude.com/docs/en/commands.md) / [code.claude.com/docs/en/cli-reference.md](https://code.claude.com/docs/en/cli-reference.md)(2026-06-25時点)

## 分類の凡例

| 区分 | 説明 |
|---|---|
| 組み込み | CLI本体に実装されているコマンド |
| スキル | スキルとして同梱され、スラッシュコマンド形式で呼び出せるもの |
| ワークフロー | 複数のサブエージェントに作業を分散する動的ワークフロー |

---

## ヘルプ・ドキュメント

| コマンド | 説明 | 備考 |
|---|---|---|
| `/help` | ヘルプと利用可能なコマンドを表示 | 組み込み |
| `/feedback` | フィードバック送信・バグ報告・会話の共有 | 別名: `/bug`, `/share`。組み込み |
| `/release-notes` | 変更履歴をバージョン選択式で表示 | 組み込み |
| `/powerup` | アニメーション付きの対話レッスンでClaude Codeの機能を学べる | 組み込み |

## セッション管理

| コマンド | 説明 | 備考 |
|---|---|---|
| `/clear [name]` | コンテキストを空にして新しい会話を開始 | 別名: `/reset`, `/new`。組み込み |
| `/resume [session]` | IDや名前を指定して会話を再開、または選択画面を開く | 別名: `/continue`。バックグラウンドセッションは`bg`表示。組み込み |
| `/branch [name]` | 現在の会話をこの時点で分岐(ブランチ)させる | 組み込み |
| `/fork <directive>` | 現在の会話全体を引き継ぐフォーク済みサブエージェントを起動 | バックグラウンドサブエージェント。v2.1.161+。組み込み |
| `/exit` | CLIを終了 | 別名: `/quit`。組み込み |
| `/recap` | 現在のセッションの一行要約をその場で生成 | 組み込み |
| `/export [filename]` | 現在の会話をプレーンテキストでエクスポート | 組み込み |
| `/rename [name]` | 現在のセッション名を変更し、プロンプトバーに表示 | 組み込み |
| `/teleport` | claude.ai上のセッションをこの端末に引き込む | 別名: `/tp`。claude.aiサブスクリプションが必要。組み込み |
| `/remote-control` | このセッションをclaude.aiからリモート操作可能にする | 別名: `/rc`。組み込み |

## 設定・環境設定

| コマンド | 説明 | 備考 |
|---|---|---|
| `/config [key=value ...]` | 設定画面を開く、または設定を直接変更 | 別名: `/settings`。v2.1.181+。組み込み |
| `/model [model]` | AIモデルを切り替え、新規セッションのデフォルトとして保存 | 組み込み |
| `/effort [level\|auto]` | モデルのEffortレベルを設定 | レベル: low, medium, high, xhigh, max, ultracode。組み込み |
| `/advisor [model\|off]` | アドバイザー機能(補助モデル)の有効・無効化 | v2.1.98+。組み込み |
| `/theme [color\|default]` | カラーテーマを変更 | 組み込み |
| `/color [color\|default]` | 現在のセッションのプロンプトバーの色を設定 | red, blue, green, yellow, purple, orange, pink, cyan。組み込み |
| `/tui [default\|fullscreen]` | ターミナルUIのレンダリング方式を設定 | 組み込み |
| `/scroll-speed` | マウスホイールのスクロール速度を調整 | フルスクリーン表示時のみ。組み込み |
| `/fast [on\|off]` | Fastモードの有効・無効を切り替え | 組み込み |
| `/voice [hold\|tap\|off]` | 音声入力(ディクテーション)の切り替え・モード指定 | claude.aiアカウントが必要。組み込み |
| `/keybindings` | キーボードショートカットの設定ファイルを開く | 組み込み |
| `/statusline` | ステータスラインの表示設定 | 組み込み |
| `/terminal-setup` | Shift+Enterなどのターミナル用キーバインドを設定 | v2.1.181+。組み込み |

## コンテキスト・メモリ管理

| コマンド | 説明 | 備考 |
|---|---|---|
| `/context [all]` | 現在のコンテキスト使用量を色分けグリッドで可視化 | 組み込み |
| `/compact [instructions]` | 会話を要約してコンテキストを解放 | 組み込み |
| `/btw <question>` | 会話に追加せずに簡単な質問だけする | 組み込み |
| `/memory` | CLAUDE.mdメモリファイルの編集、または自動メモリの有効化 | 組み込み |
| `/init` | CLAUDE.mdガイドを生成してプロジェクトを初期化 | 組み込み |

## コードレビュー・検証

| コマンド | 説明 | 備考 |
|---|---|---|
| `/code-review [low\|medium\|high\|xhigh\|max\|ultra] [--fix] [--comment] [target]` | 差分をレビューし、不具合や改善点を検出 | スキル。`ultra`はクラウドでの多段レビュー。`--fix`で自動修正、`--comment`でPRコメント投稿。組み込み |
| `/simplify [target]` | 変更箇所のコードを整理・簡素化して適用 | スキル。v2.1.154+。バグ検出は対象外。組み込み |
| `/review [PR]` | `/code-review`と同じエンジンでGitHubのPRをレビュー | 組み込み |
| `/security-review` | 現在のブランチの変更をセキュリティ観点で分析 | 組み込み |
| `/diff` | 未コミットの変更やターン単位の差分を表示する対話的ビューア | 組み込み |

## Git・プロジェクトワークフロー

| コマンド | 説明 | 備考 |
|---|---|---|
| `/plan [description]` | プロンプトから直接プランモードに入る | 組み込み |
| `/goal [condition\|clear]` | 目標を設定し、条件を満たすまで作業を継続 | 組み込み |

## 並列作業・自動化

| コマンド | 説明 | 備考 |
|---|---|---|
| `/batch <instruction>` | 大規模な変更を並列処理で実行 | スキル。コードベースを調査し5〜30個の単位に分解、各単位にサブエージェントを起動。gitリポジトリが必要。組み込み |
| `/background [prompt]` | 現在のセッションを切り離してバックグラウンドエージェントとして実行 | 別名: `/bg`。ターミナルが解放される。組み込み |
| `/loop [interval] [prompt]` | プロンプトを一定間隔、またはペースを自動調整しながら繰り返し実行 | スキル。intervalを省略すると自動ペース調整。別名: `/proactive`。組み込み |
| `/schedule [description]` | クラウド上で動くルーティン(定期実行エージェント)を作成・更新・一覧・実行 | 別名: `/routines`。組み込み |
| `/tasks` | バックグラウンドで実行中の処理を一覧・管理 | 別名: `/bashes`。組み込み |
| `/agents` | エージェント設定を管理 | 組み込み |
| `/workflows` | ワークフローの進行状況を表示し、一時停止・再開・保存 | 組み込み |

## デバッグ・診断

| コマンド | 説明 | 備考 |
|---|---|---|
| `/debug [description]` | 現在のセッションでデバッグログを有効化し問題を調査 | スキル。組み込み |
| `/doctor` | Claude Codeのインストール状態と設定を診断 | 組み込み |
| `/hooks` | フックの設定状況を表示 | 組み込み |
| `/heapdump` | メモリ使用量調査用にJavaScriptのヒープスナップショットを出力 | 組み込み |

## ファイル・ディレクトリ管理

| コマンド | 説明 | 備考 |
|---|---|---|
| `/add-dir <path>` | 現在のセッションでファイルアクセス可能な作業ディレクトリを追加 | 組み込み |
| `/cd <path>` | セッションの作業ディレクトリを変更 | v2.1.169+。プロンプトキャッシュは維持される。組み込み |
| `/copy [N]` | 直前のアシスタント応答をクリップボードにコピー | コードブロック選択用の対話式ピッカーあり。組み込み |

## 権限・許可設定

| コマンド | 説明 | 備考 |
|---|---|---|
| `/permissions` | ツール実行のallow/ask/denyルールを管理 | 別名: `/allowed-tools`。組み込み |
| `/fewer-permission-prompts` | 過去のログから頻出操作を検出し許可リストに追加 | スキル。組み込み |

## IDE・デスクトップ連携

| コマンド | 説明 | 備考 |
|---|---|---|
| `/ide` | IDE連携の管理と状態表示 | 組み込み |
| `/desktop` | Claude Code Desktopアプリでセッションを継続 | 別名: `/app`。macOS/WindowsとClaudeサブスクリプションが必要。組み込み |
| `/chrome` | Claude in Chromeの設定 | 組み込み |

## MCP・連携管理

| コマンド | 説明 | 備考 |
|---|---|---|
| `/mcp [reconnect <server>\|enable\|disable [<server>\|all]]` | MCPサーバーの接続とOAuth認証を管理 | 組み込み |

## スキル・プラグイン

| コマンド | 説明 | 備考 |
|---|---|---|
| `/skills` | 利用可能なスキルを一覧表示 | `t`キーでトークン数順に並べ替え可能。組み込み |
| `/plugin [subcommand]` | Claude Codeのプラグインを管理 | サブコマンド: list, install, enable, disable。組み込み |
| `/reload-plugins [--force]` | 有効化中のプラグインを再読み込みし変更を反映 | 組み込み |
| `/reload-skills` | スキルディレクトリを再スキャンし新しいスキルを反映 | v2.1.152+。組み込み |

## アカウント・認証

| コマンド | 説明 | 備考 |
|---|---|---|
| `/login` | Anthropicアカウントにログイン | 組み込み |
| `/logout` | Anthropicアカウントからログアウト | 組み込み |
| `/mobile` | Claudeモバイルアプリのダウンロード用QRコードを表示 | 別名: `/ios`, `/android`。組み込み |
| `/passes` | 友人にClaude Codeの無料1週間利用を共有 | 対象者のみ表示。組み込み |
| `/upgrade` | より上位プランへのアップグレードページを開く | Pro/Maxプランのみ表示。組み込み |
| `/privacy-settings` | プライバシー設定の表示・変更 | Pro/Max会員限定。組み込み |
| `/usage` | セッションコスト・プラン利用状況・利用統計を表示 | 別名: `/cost`, `/stats`。組み込み |
| `/usage-credits` | 上限到達時も作業を続けるための利用クレジット設定 | 旧`/extra-usage`。組み込み |

## 専用連携・外部アプリ

| コマンド | 説明 | 備考 |
|---|---|---|
| `/setup-bedrock` | Amazon Bedrock認証・設定の構成 | `CLAUDE_CODE_USE_BEDROCK=1`設定時のみ表示。組み込み |
| `/setup-vertex` | Google Vertex AI認証・設定の構成 | `CLAUDE_CODE_USE_VERTEX=1`設定時のみ表示。組み込み |
| `/install-github-app` | Claude GitHub Appをインストール(Actions設定含む) | 組み込み |
| `/install-slack-app` | Claude Slackアプリをインストール | 組み込み |
| `/web-setup` | GitHubアカウントをClaude Code on the webに接続 | 組み込み |
| `/remote-env` | クラウドエージェントのデフォルト実行環境を選択 | 組み込み |

## 高度なワークフロー・リファレンス

| コマンド | 説明 | 備考 |
|---|---|---|
| `/claude-api [migrate\|managed-agents-onboard]` | Claude APIリファレンス資料の読み込みとオンボーディング管理 | スキル。`anthropic`や`@anthropic-ai/sdk`のimportで自動起動。組み込み |
| `/deep-research <question>` | Web検索を多数並行実行し、出典を確認しながら引用付きレポートを生成 | ワークフロー。組み込み |
| `/ultraplan <prompt>` | ultraplanセッションで計画を作成し、ブラウザでレビューしてリモート実行 | 組み込み |
| `/ultrareview [PR]` | クラウドサンドボックスで多段エージェントによる深いコードレビューを実行 | 別名: `/code-review ultra`。Pro/Maxは無料3回。組み込み |
| `/autofix-pr [prompt]` | PRを監視しCI失敗時に自動修正をプッシュするWebセッションを起動 | 組み込み |
| `/run` | プロジェクトのアプリを起動して動作を確認 | スキル。v2.1.145+。組み込み |
| `/verify` | アプリをビルド・起動して動作を観察し、変更を検証 | スキル。v2.1.145+。組み込み |
| `/run-skill-generator` | `/run`と`/verify`にアプリの起動方法を学習させる | スキル。v2.1.145+。組み込み |
| `/rewind` | 会話やコードを以前の時点に巻き戻す | 別名: `/checkpoint`, `/undo`。組み込み |
| `/team-onboarding` | 利用履歴からオンボーディングガイドを生成 | 過去30日分を分析。組み込み |
| `/insights` | Claude Codeのセッションを分析したレポートを生成 | 組み込み |

## エンタメ・その他

| コマンド | 説明 | 備考 |
|---|---|---|
| `/radio` | Claude FM(ローファイラジオ)をブラウザで開く | Bedrock/Vertex/Foundryでは利用不可。組み込み |
| `/stickers` | Claude Codeステッカーを注文 | 組み込み |
| `/status` | 設定画面(ステータスタブ)を開き、バージョン・モデル・アカウント情報を表示 | 応答中でも実行可能。組み込み |

## 廃止・削除されたコマンド

| コマンド | 状態 | 備考 |
|---|---|---|
| `/pr-comments [PR]` | v2.1.91で削除 | 代わりに直接プロンプトで依頼 |
| `/vim` | v2.1.92で削除 | `/config` → Editor modeを使用 |
| `/enable-auto-mode` | v2.1.111で削除 | `--permission-mode auto`を使用 |

---

## 補足

- 一部のコマンドはOS・契約プラン・認証方式によって表示されるかどうかが変わります(例: `/desktop`はmacOS/Windows + サブスクリプション、`/upgrade`はPro/Maxプランのみ、`/setup-bedrock`は環境変数設定時のみ)。
- MCPサーバーがプロンプトを公開している場合、`/mcp__<サーバー名>__<プロンプト名>` の形式で動的に追加されることがあります。
- バージョン番号(例: v2.1.181+)は導入されたClaude Codeのバージョンです。お使いの環境のバージョンによっては未対応の場合があります。
