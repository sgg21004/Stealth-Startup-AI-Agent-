#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
swift package resolve
swift build
swift run FittsLabs status
swift run FittsLabs policy
swift run FittsLabs session
swift run FittsLabs session --live --confirm
swift run FittsLabs memory show
swift run FittsLabs audit show --limit 5
