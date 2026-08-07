# Eng setup

## Requirements

- macOS 14+
- Swift 6 toolchain (`swift --version`)
- **Full Xcode** (not just Command Line Tools) for the real macOS `.app`, Accessibility permissions, and overlay UI
- Today’s stub runs with Command Line Tools via SwiftPM

## Bootstrap

```bash
cd ~/Projects/galaxy-labs
swift package resolve
swift build
swift run GalaxyLabs status
swift run GalaxyLabs session --confirm
```

`swift test` needs **full Xcode** (Command Line Tools lack XCTest). Test sources live in `Tests/` ready to enable in `Package.swift` after Xcode install.

## Layout

| Path | Role |
| --- | --- |
| `apps/desktop` | Host entrypoint (CLI stub → future `.app`) |
| `packages/Sensor` | Cursor / focus sensing |
| `packages/Context` | Context pack + redaction |
| `packages/Agent` | Propose plans |
| `packages/Actions` | Execute / record playbooks |
| `packages/Behavior` | Prefs + playbook store |
| `docs/` | Company / product / eng truth |

## Permissions (when `.app` lands)

- Accessibility
- Screen Recording (OCR fallback)
- Automation (if driving Safari/System Events)
