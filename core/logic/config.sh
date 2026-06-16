#!/bin/bash
# Configuration and Environment Logic

detect_mode() {
    # Enhanced CI detection: flag, pipe, or env var
    if [[ ! -t 0 ]] || [[ "$1" == "--auto" ]] || [[ "$SIGNIFY_AUTO" == "true" ]]; then
        export AUTO_MODE="true"
    else
        export AUTO_MODE="false"
    fi
}

setup_paths() {
    # Use user-defined KEYS_DIR or default
    export KEYS_DIR="${KEYS_DIR:-vendor/signify/keys}"
    mkdir -p "$KEYS_DIR"
}
