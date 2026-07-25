[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Claude Code 初期セットアップ" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "このツールは以下を自動設定します。"
Write-Host "  1. Claude Code CLI のインストール"
Write-Host "  2. マイク(音声入力)・応答の日本語化"
Write-Host "  3. ファイル削除・commit・push・mergeなど、元に戻しにくい操作、あるいは"
Write-Host "     元に戻せない操作の確認ルールの追加"
Write-Host "  4. CLAUDE.md への言語設定・上記項目3の確認ルールの追加"
Write-Host ""
Write-Host "すでに設定済みの項目は自動でスキップされます。" -ForegroundColor DarkGray
Write-Host ""
Write-Host "前提条件:"
Write-Host "  - Visual Studio Code がインストール済みであること"
Write-Host "  - Claude Pro / Max / Team いずれかのプランを契約していること"
Write-Host "  - インターネットに接続されていること"
Write-Host ""
Read-Host "続行する場合は Enter キーを押してください(中止する場合はウィンドウを閉じてください)"

Write-Host ""
Write-Host "[1/4] Claude Code CLI を確認しています..." -ForegroundColor Cyan

if (Get-Command claude -ErrorAction SilentlyContinue) {
    Write-Host "  -> 既にインストールされています。スキップします。"
} else {
    Write-Host "  -> インストールします(公式インストーラーを使用)..."
    try {
        Invoke-RestMethod https://claude.ai/install.ps1 | Invoke-Expression
        Write-Host "  -> インストールが完了しました。"
    } catch {
        Write-Host "  -> インストールに失敗しました: $_" -ForegroundColor Red
        Write-Host "  -> 手動でのインストール方法: https://code.claude.com/docs/en/quickstart" -ForegroundColor Yellow
    }
}

$localBin = Join-Path $HOME ".local\bin"
if (Test-Path $localBin) {
    $userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    $pathEntries = @()
    if ($userPath) { $pathEntries = $userPath -split ";" | Where-Object { $_ -ne "" } }
    if ($pathEntries -notcontains $localBin) {
        $newPath = if ($userPath) { "$userPath;$localBin" } else { $localBin }
        [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
        $env:PATH = "$env:PATH;$localBin"
        Write-Host "  -> PATHに $localBin を追加しました(新しいターミナルから 'claude' が使えます)。"
    }
}

Write-Host ""
Write-Host "[2/4] ユーザー設定(settings.json)を確認しています..." -ForegroundColor Cyan

$claudeDir = Join-Path $HOME ".claude"
if (-not (Test-Path $claudeDir)) {
    New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null
}

$settingsPath = Join-Path $claudeDir "settings.json"

$settings = [ordered]@{}
if (Test-Path $settingsPath) {
    $raw = Get-Content -Path $settingsPath -Raw -Encoding UTF8
    if ($raw -and $raw.Trim().Length -gt 0) {
        $parsed = $raw | ConvertFrom-Json
        foreach ($prop in $parsed.PSObject.Properties) {
            $settings[$prop.Name] = $prop.Value
        }
    }
}

$settings["language"] = "japanese"
Write-Host "  -> マイク(音声入力)・応答の言語を日本語に設定しました。"

Write-Host ""
Write-Host "[3/4] 元に戻しにくい・元に戻せない操作(削除・commit・push等)の確認ルールを追加しています..." -ForegroundColor Cyan

$deleteAskRules = @(
    "Bash(rm *)",
    "Bash(rmdir *)",
    "Bash(unlink *)",
    "Bash(git rm *)",
    "Bash(git clean *)",
    "Bash(git commit *)",
    "Bash(git push *)",
    "Bash(git rebase *)",
    "Bash(git merge *)",
    "Bash(git branch -D *)",
    "Bash(git reset --hard*)",
    "Bash(git stash drop*)",
    "Bash(git stash clear*)",
    "Bash(git remote set-url*)",
    "PowerShell(Remove-Item *)",
    "PowerShell(ri *)",
    "PowerShell(rm *)",
    "PowerShell(rmdir *)",
    "PowerShell(del *)",
    "PowerShell(erase *)",
    "PowerShell(git commit *)",
    "PowerShell(git push *)",
    "PowerShell(git rebase *)",
    "PowerShell(git merge *)",
    "PowerShell(git branch -D *)",
    "PowerShell(git reset --hard*)",
    "PowerShell(git stash drop*)",
    "PowerShell(git stash clear*)",
    "PowerShell(git remote set-url*)"
)

$permissions = [ordered]@{}
if ($settings.Contains("permissions") -and $settings["permissions"]) {
    if ($settings["permissions"] -is [System.Collections.IDictionary]) {
        $permissions = $settings["permissions"]
    } else {
        foreach ($prop in $settings["permissions"].PSObject.Properties) {
            $permissions[$prop.Name] = $prop.Value
        }
    }
}

$existingAsk = @()
if ($permissions.Contains("ask") -and $permissions["ask"]) {
    $existingAsk = @($permissions["ask"])
}
foreach ($rule in $deleteAskRules) {
    if ($existingAsk -notcontains $rule) {
        $existingAsk += $rule
    }
}
$permissions["ask"] = $existingAsk
$settings["permissions"] = $permissions

$json = $settings | ConvertTo-Json -Depth 10
[System.IO.File]::WriteAllText($settingsPath, $json, [System.Text.UTF8Encoding]::new($false))

Write-Host "  -> 削除・commit・push・rebase・merge等の実行前に確認を求める設定を追加しました。"
Write-Host ""
Write-Host "設定ファイルの場所: $settingsPath"

Write-Host ""
Write-Host "[4/4] CLAUDE.md の言語設定・元に戻しにくい操作の確認ルールを確認しています..." -ForegroundColor Cyan

$claudeMdPath = Join-Path $claudeDir "CLAUDE.md"

$languageSettingsBlock = @'
# 言語設定

- 思考過程（Plan Mode、Extended Thinkingの説明も含む）を日本語で行う
- すべての応答・説明・計画は日本語で行う
- コード内のコメントは日本語で記述する
- 変数名・関数名・クラス名は英語を使用する
- コミットメッセージは日本語で記述する
- エラーメッセージの解説は日本語で行う（エラー文自体の原文は英語のまま引用してよい）
- 技術用語は初出時のみ英語を併記する（例：依存関係（dependency））
- ドキュメント・README・仕様書の生成も日本語を基本とする
- ユーザーへの確認・質問も日本語で行う
- 英語表現が混ざった場合は、その場で日本語に言い換えて説明し直す
'@

$destructiveOpsBlock = @'
## 元に戻しにくい・元に戻せない操作の確認ルール

以下の操作を実行する前は、必ずユーザーに確認を取ること。
確認なしで実行してはいけない。

### ファイル・ディレクトリ
- ファイル/ディレクトリの削除
- `git clean -fd`(untrackedファイルの一括削除)

### Git操作
- `git commit`
- `git push`
- `git push --force` / `--force-with-lease`
- `git rebase`
- `git branch -D`(ブランチの強制削除)
- `git merge`(特にmain/masterブランチへのマージ)
- `git reset --hard`
- `git stash drop` / `git stash clear`
- リポジトリの削除(`.git`ディレクトリの削除、GitHub上でのリポジトリ削除操作)
- `git remote set-url`などリモート設定の変更

### データベース操作
- `DROP TABLE` / `DROP DATABASE`
- `TRUNCATE`
- `WHERE`句のない`DELETE` / `UPDATE`
- マイグレーションの実行(スキーマ変更を伴う場合は特に注意)

### 確認時のフォーマット
実行前に、以下を明示してから確認を取ること:
1. これから実行するコマンド(全文)
2. その操作が何を変更・削除するか(対象ファイル/テーブル/ブランチ名など具体的に)
3. 取り消せるか、取り消せないか

ユーザーが明確に「はい」「OK」「実行して」等の同意を示すまで、実行してはいけない。
'@

$existingMd = ""
if (Test-Path $claudeMdPath) {
    $existingMd = Get-Content -Path $claudeMdPath -Raw -Encoding UTF8
    if (-not $existingMd) { $existingMd = "" }
}

$blocksToAdd = @()
if ($existingMd.Contains("# 言語設定")) {
    Write-Host "  -> 言語設定は既に含まれています。スキップします。"
} else {
    $blocksToAdd += $languageSettingsBlock
    Write-Host "  -> 言語設定を追加します。"
}

if ($existingMd.Contains("## 元に戻しにくい・元に戻せない操作の確認ルール")) {
    Write-Host "  -> 元に戻しにくい・元に戻せない操作の確認ルールは既に含まれています。スキップします。"
} else {
    $blocksToAdd += $destructiveOpsBlock
    Write-Host "  -> 元に戻しにくい・元に戻せない操作の確認ルールを追加します。"
}

if ($blocksToAdd.Count -gt 0) {
    $newContent = $existingMd
    foreach ($block in $blocksToAdd) {
        if ($newContent.Trim().Length -eq 0) {
            $newContent = $block
        } else {
            $newContent = $newContent.TrimEnd() + "`r`n`r`n" + $block
        }
    }
    [System.IO.File]::WriteAllText($claudeMdPath, $newContent, [System.Text.UTF8Encoding]::new($false))
    Write-Host "  -> CLAUDE.mdを更新しました。"
} else {
    Write-Host "  -> CLAUDE.mdは変更ありません。"
}

Write-Host ""
Write-Host "CLAUDE.mdの場所: $claudeMdPath"

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "セットアップ処理が終了しました。"
Write-Host "上記のログにエラーが表示されていないか確認してください。"
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "次の手順:"
Write-Host "  1. このウィンドウを閉じて、新しいターミナル(またはVS Code)を開いてください。"
Write-Host "  2. ターミナルで 'claude' と入力してください。"
Write-Host "  3. ブラウザでの認証画面が出たら、Claudeアカウントでログインしてください。"
