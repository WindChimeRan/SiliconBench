#!/bin/bash
# SiliconBench — platform dispatcher. Picks apple or dgxspark and execs the
# matching full script; all real logic lives in run_all_<platform>.sh.
# Usage: bash scripts/run_all.sh [--platform apple|dgxspark] [run_all_<platform>.sh args...]
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

PLATFORM="${APPLEBENCH_PLATFORM:-}"
ARGS=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        --platform)
            PLATFORM="$2"
            shift 2
            ;;
        *)
            ARGS+=("$1")
            shift
            ;;
    esac
done

if [ -z "$PLATFORM" ]; then
    if [ "$(uname -s)" = "Linux" ]; then
        PLATFORM="dgxspark"
    else
        PLATFORM="apple"
    fi
fi

TARGET="$SCRIPT_DIR/run_all_${PLATFORM}.sh"
if [ ! -f "$TARGET" ]; then
    echo "Error: unknown platform '$PLATFORM' (no $TARGET)"
    exit 1
fi

exec bash "$TARGET" "${ARGS[@]}"
