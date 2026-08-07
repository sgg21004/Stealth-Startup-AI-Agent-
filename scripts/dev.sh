#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
swift package resolve
swift build
swift run GalaxyLabs status
swift run GalaxyLabs policy
swift run GalaxyLabs session
swift run GalaxyLabs session --live --confirm
swift run GalaxyLabs memory show
swift run GalaxyLabs audit show --limit 5
