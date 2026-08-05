# AutoSpec Autoモード用 PreToolUse hook
#
# 役割:
#   .autospec_mode が "auto" / "auto_until_complete" のときのみ、
#   Claude Codeの確認プロンプトを一部スキップして自動実行させる。
#   ただし、バージョン管理(git/svn)の状態を変更する操作は
#   .autospec_mode の値に関わらず常にスキップし、ログに記録する。
#
# 入出力仕様:
#   標準入力から PreToolUse hookのJSON(tool_name, tool_input等)を受け取り、
#   標準出力に hookSpecificOutput.permissionDecision (allow/deny/ask なし=通常フロー)
#   を含むJSONを返す。

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = "Stop"

function Write-Decision {
    param(
        [string]$Decision,
        [string]$Reason
    )
    if (-not $Decision) {
        # 何も返さない = 通常の確認フローに委ねる
        exit 0
    }
    $obj = @{
        hookSpecificOutput = @{
            hookEventName = "PreToolUse"
            permissionDecision = $Decision
            permissionDecisionReason = $Reason
        }
    }
    $json = $obj | ConvertTo-Json -Depth 10 -Compress
    [Console]::Out.Write($json)
    exit 0
}

# --- プロジェクトルート(配置フォルダ)の特定 ---
# 本スクリプトは <配置フォルダ>\.claude\hooks\ に置かれている前提
$projectRoot = $env:CLAUDE_PROJECT_DIR
if (-not $projectRoot -or -not (Test-Path $projectRoot)) {
    $projectRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
}

$modePath = Join-Path $projectRoot ".autospec_mode"
$logPath = Join-Path $projectRoot "autospec_action_log.md"

$mode = "safety"
if (Test-Path $modePath) {
    $raw = (Get-Content -Path $modePath -Raw -Encoding UTF8)
    if ($raw) { $mode = $raw.Trim() }
}

# --- 標準入力のJSONを読み取る ---
$stdinRaw = [Console]::In.ReadToEnd()
if (-not $stdinRaw) { Write-Decision -Decision $null }

try {
    $payload = $stdinRaw | ConvertFrom-Json
} catch {
    Write-Decision -Decision $null
}

$toolName = $payload.tool_name
$toolInput = $payload.tool_input

function Add-ActionLog {
    param(
        [string]$Category,
        [string]$Summary,
        [string]$Reason
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "`r`n## $timestamp`r`n- Tool: $toolName`r`n- 区分: $Category`r`n- 内容: $Summary`r`n- 判定: スキップ(deny)`r`n- 理由: $Reason`r`n"
    if (-not (Test-Path $logPath)) {
        $header = "# AutoSpec 自動スキップログ`r`n`r`nAutoモード中に自動でスキップされた操作の記録です。`r`n" +
            "区分が「要確認(保留)」の項目は、後でユーザーへの確認が必要です。`r`n"
        [System.IO.File]::WriteAllText($logPath, $header, [System.Text.UTF8Encoding]::new($true))
    }
    Add-Content -Path $logPath -Value $entry -Encoding UTF8
}

# --- Safetyモードなら常に通常フロー ---
if ($mode -ne "auto" -and $mode -ne "auto_until_complete") {
    Write-Decision -Decision $null
}

# --- バージョン管理の状態を変更する操作は常に禁止(モード共通) ---
# CLAUDE.md「バージョン管理の状態を変更しない」ルールと同じ範囲。
$forbiddenPatterns = @(
    'git\s+add\b',
    'git\s+commit\b',
    'git\s+push\b',
    'git\s+mv\b',
    'git\s+rm\b',
    'git\s+checkout\b',
    'git\s+switch\b',
    'git\s+branch\b',
    'git\s+merge\b',
    'git\s+rebase\b',
    'git\s+reset\b',
    'git\s+clean\b',
    'git\s+stash\s+(drop|clear)\b',
    'git\s+remote\s+(set-url|add|remove|rm)\b',
    'git\s+tag\b',
    'git\s+cherry-pick\b',
    'git\s+revert\b',
    'git\s+submodule\b',
    'svn\s+(commit|ci|delete|del|remove|rm|move|mv|revert|switch|merge|update|up)\b'
)

# .gitディレクトリ自体を削除しようとするコマンド(rm -rf .git 等)の検出は、
# 削除系コマンド + ".git"パスの2条件AND判定で行う(単一の複雑な正規表現は避ける)
$deleteCommandPattern = '\b(rm|rmdir|del|erase|Remove-Item|ri)\b'
$dotGitPathPattern = '\.git\b'

if ($toolName -eq "Bash") {
    $command = [string]$toolInput.command
    $isForbidden = $false
    foreach ($pattern in $forbiddenPatterns) {
        if ($command -match $pattern) { $isForbidden = $true; break }
    }
    if (-not $isForbidden -and $command -match $deleteCommandPattern -and $command -match $dotGitPathPattern) {
        $isForbidden = $true
    }
    if ($isForbidden) {
        Add-ActionLog -Category "禁止操作(バージョン管理)" -Summary "Bashコマンド: $command" -Reason "バージョン管理の状態を変更する操作は常に禁止されています(CLAUDE.md参照)"
        Write-Decision -Decision "deny" -Reason "バージョン管理(git/svn)の状態を変更する操作のため自動実行をスキップしました。この操作は保留とし、他に進められるタスクがあれば先に進めてください。必要であればユーザーに手動実行を依頼してください。"
    }
    # 禁止パターンに該当しないBashコマンドはAutoモードでは自動許可する。
    # (個々のファイルパスのgit管理下判定までは行わない簡略実装。ver0時点の割り切り)
    Write-Decision -Decision "allow" -Reason "Autoモード: バージョン管理操作以外のコマンドのため自動許可"
}

# --- ファイル編集・作成系ツール ---
$fileEditTools = @("Edit", "Write", "NotebookEdit", "MultiEdit")
if ($fileEditTools -contains $toolName) {
    $filePath = $toolInput.file_path
    if (-not $filePath) { Write-Decision -Decision $null }

    $fileExisted = Test-Path -LiteralPath $filePath

    # 新規作成ファイル(Writeでこれまで存在しなかった)は無条件許可し、
    # このセッションでの新規作成ファイルとして記録する
    $sessionId = [string]$payload.session_id
    $sessionRecordDir = Join-Path $PSScriptRoot ".session_created_files"
    if (-not (Test-Path $sessionRecordDir)) {
        New-Item -ItemType Directory -Path $sessionRecordDir -Force | Out-Null
    }
    $sessionRecordPath = Join-Path $sessionRecordDir "$sessionId.txt"

    if (-not $fileExisted -and $toolName -eq "Write") {
        Add-Content -Path $sessionRecordPath -Value $filePath -Encoding UTF8
        Write-Decision -Decision "allow" -Reason "Autoモード: 新規作成ファイルのため自動許可"
    }

    $isSessionCreated = $false
    if (Test-Path $sessionRecordPath) {
        $createdFiles = Get-Content -Path $sessionRecordPath -Encoding UTF8
        if ($createdFiles -contains $filePath) { $isSessionCreated = $true }
    }
    if ($isSessionCreated) {
        Write-Decision -Decision "allow" -Reason "Autoモード: このセッションで新規作成したファイルのため自動許可"
    }

    # git管理下(追跡・未追跡問わず、.gitignore対象は除く)かどうかを判定
    $dir = [System.IO.Path]::GetDirectoryName($filePath)
    $isGitTracked = $false
    if ($dir -and (Test-Path $dir)) {
        try {
            & git -C $dir rev-parse --is-inside-work-tree *> $null
            if ($LASTEXITCODE -eq 0) {
                $result = & git -C $dir ls-files --others --exclude-standard --cached -- $filePath 2>$null
                if ($result) { $isGitTracked = $true }
            }
        } catch {
            $isGitTracked = $false
        }
    }

    if ($isGitTracked) {
        Write-Decision -Decision "allow" -Reason "Autoモード: git管理下のファイルのため自動許可"
    }

    # git管理外かつ新規作成でもない = ユーザー作成ファイルの可能性。
    # 無許可では編集・削除しないが、その場で確認を求めて処理を止めるのではなく、
    # 一旦スキップしてログに記録し、後回しにできるようにする。
    Add-ActionLog -Category "要確認(保留)" -Summary "${toolName}対象: $filePath" -Reason "git管理外かつこのセッションでの新規作成でもないファイルのため、ユーザーの確認が必要です"
    Write-Decision -Decision "deny" -Reason "このファイルはgit管理外かつ新規作成でもないため、ユーザーの確認が必要です。この操作は保留とし、autospec_action_log.mdに記録しました。他に進められるタスクがあれば先に進め、最後にまとめてユーザーに確認してください。"
}

# --- 上記以外のツールは通常フローに委ねる ---
Write-Decision -Decision $null
