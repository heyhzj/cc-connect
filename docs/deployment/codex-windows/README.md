# Windows Codex deployment recovery

This records the verified local recovery for cc-connect v1.3.3-fork2-codex on 2026-10-08. It is a deployment example, not a change to the Go agent implementation. Runtime config.toml, credentials, logs, and backups are deliberately excluded.

## Failure

The codex-feishu project used `pwsh.exe` as its configured command. PowerShell 7 was not available in the background service's persistent PATH, so agent creation failed and cc-connect exited before starting the projects. The npm-install suggestion in that error is generic; installing Codex does not provide pwsh.exe.

The wrapper also referenced a removed desktop Codex build, `247581e40ee272fb`. Fixing the shell alone would still fail when the wrapper tried to launch that executable.

## Applied configuration

Copy the adjacent codex-launch.ps1 to `C:/Users/Admin/.cc-connect/codex-feishu/codex-launch.ps1`. In the existing codex-feishu `[projects.agent.options]` section, replace only the cmd line with:

```toml
cmd = "C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -File C:/Users/Admin/.cc-connect/codex-feishu/codex-launch.ps1"
```

The wrapper uses the verified installed binary:

```text
C:/Users/Admin/AppData/Local/OpenAI/Codex/bin/9691020b546a15b2/codex.exe
```

These paths are specific to this machine. Verify and adjust them before using the example elsewhere. The existing feishu-sync Codex profile must be configured separately; it is not included here. Keep the wrapper because it applies that profile and filters conflicting sandbox/approval arguments.

The unversioned desktop `bin/codex.exe` was an older 0.130.0-alpha.5 binary and was not substituted. Desktop updates may remove the version-specific executable again; verify the wrapper path after updates.

## Validation

Under Windows PowerShell 5.1, the actual wrapper passed `--version` (0.162.0-alpha.2) and `exec --help`. After backing up both files, the service was restarted through the existing start-cc-connect.ps1 launcher with inherited Claude session variables cleared.

Startup logs reported `cc-connect is running` with `projects=6`. All three Feishu and all three Weixin platforms became ready, and no new ERROR appeared in the follow-up check. The user subsequently confirmed receiving a bot reply, completing the end-to-end check.

Backups were retained beside the original runtime files with suffix `.before-startup-fix-20261008-112820`. To roll back, stop the service, restore both backups, and restart using the existing launcher. No npm package or PowerShell installation was needed.
## Repository checks for this documentation snapshot

The copied wrapper exactly matches the runtime script verified above. A targeted secret scan passed. No Go source is changed.

Full repository validation did not pass in this existing Windows checkout: `go build ./...` requires absent `web/dist` assets; `go build -tags no_web ./...` fails on an unused `os` import in `agent/pi/proc_windows.go`; `go test -tags no_web ./...` also reports existing assumptions about POSIX commands (`true`, `sh`), paths, and file modes. These failures are outside this deployment snapshot and were not repaired as part of the startup recovery.