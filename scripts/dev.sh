#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
swift package resolve
swift build
swift run StealthDesktop status
swift run StealthDesktop policy
swift run StealthDesktop session
swift run StealthDesktop session --live --confirm
swift run StealthDesktop memory show
