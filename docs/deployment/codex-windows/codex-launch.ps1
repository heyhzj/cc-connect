$ErrorActionPreference = 'Stop'
$forward = [System.Collections.Generic.List[string]]::new()
for ($i = 0; $i -lt $args.Count; $i++) {
    $arg = [string]$args[$i]
    if ($arg -eq '--dangerously-bypass-approvals-and-sandbox') { throw 'This bot requires the feishu-sync permission profile.' }
    if ($arg -eq '--sandbox') { $i++; continue }
    if ($arg -eq '-c' -and $i + 1 -lt $args.Count -and $args[$i + 1] -match '^(sandbox_mode|approval_policy)=') { $i++; continue }
    $forward.Add($arg)
}
$cli = 'C:/Users/Admin/AppData/Local/OpenAI/Codex/bin/9691020b546a15b2/codex.exe'
$cliArgs = @('-p', 'feishu-sync') + $forward.ToArray()
$gitConfigCount = 0
if ($env:GIT_CONFIG_COUNT -match '^\d+$') { $gitConfigCount = [int]$env:GIT_CONFIG_COUNT }
[Environment]::SetEnvironmentVariable("GIT_CONFIG_KEY_$gitConfigCount", 'http.sslBackend', 'Process')
[Environment]::SetEnvironmentVariable("GIT_CONFIG_VALUE_$gitConfigCount", 'openssl', 'Process')
[Environment]::SetEnvironmentVariable('GIT_CONFIG_COUNT', ($gitConfigCount + 1).ToString(), 'Process')
if ($forward.Count -gt 0 -and $forward[$forward.Count - 1] -eq '-') {
    $promptText = [Console]::In.ReadToEnd()
    $promptText | & $cli @cliArgs
} else {
    & $cli @cliArgs
}
exit $LASTEXITCODE
