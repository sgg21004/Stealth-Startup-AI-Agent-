#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
swift package resolve
swift build
swift run GalaxyAgent status
swift run GalaxyAgent policy
swift run GalaxyAgent session
swift run GalaxyAgent session --live --confirm
swift run GalaxyAgent memory show
swift run GalaxyAgent audit show --limit 5
