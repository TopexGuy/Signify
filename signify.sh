#!/bin/bash
# Signify - Advanced ROM Signing Wrapper

export DEFAULT_KEY_SIZE="${DEFAULT_KEY_SIZE:-4096}"
export DEFAULT_SUBJECT="${DEFAULT_SUBJECT:-/C=US/ST=California/L=Mountain View/O=Android/OU=Android/CN=Android/emailAddress=android@android.com}"
export KEYS_DIR="${KEYS_DIR:-vendor/signify/keys}"
export SKIP_OTA="${SKIP_OTA:-false}"
export TIMEOUT="${TIMEOUT:-20}"

export REPO_URL="https://github.com/TopexGuy/Signify.git"
export REPO_BRANCH="main"

if [[ ! -f "build/envsetup.sh" ]]; then
    echo "Error: Run from ROM root"
    exit 1
fi

export ROM_ROOT="$(pwd)"

if [[ "$SIGNIFY_TMP_ACTIVE" != "true" ]]; then
    export TEMP_DIR="/tmp/.signify_$(date +%s)"
    mkdir -p "$TEMP_DIR"
    git clone --depth=1 --single-branch -b "$REPO_BRANCH" "$REPO_URL" "$TEMP_DIR" > /dev/null 2>&1
    export SIGNIFY_TMP_ACTIVE="true"
    export SIGNIFY_REAL_ROOT="$ROM_ROOT"
    
    # Export current env to subshell
    KEYS_DIR="$KEYS_DIR" SKIP_OTA="$SKIP_OTA" bash "$TEMP_DIR/signify.sh" "$@"
    
    rm -rf "$TEMP_DIR"
    unset SIGNIFY_TMP_ACTIVE SIGNIFY_REAL_ROOT TEMP_DIR DEFAULT_KEY_SIZE DEFAULT_SUBJECT KEYS_DIR SKIP_OTA KEY_SIZE SUBJECT_INFO AUTO_MODE TIMEOUT
    exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/core/ui/colors.sh"
source "$SCRIPT_DIR/core/utils/helpers.sh"
source "$SCRIPT_DIR/core/logic/config.sh"
source "$SCRIPT_DIR/core/logic/signing.sh"

main() {
    print_banner
    detect_mode "$@"
    setup_paths

    if [[ "$AUTO_MODE" == "false" ]]; then
        if [[ $(confirm "Generate OTA keys?" "yes") == "no" ]]; then
            export SKIP_OTA="true"
        else
            export SKIP_OTA="false"
        fi

        if [[ $(confirm "Customize configuration?" "no") == "yes" ]]; then
            export KEY_SIZE=$(prompt_default "Key Size" "$DEFAULT_KEY_SIZE")
            export KEYS_DIR=$(prompt_default "Keys Directory" "$KEYS_DIR")
            export SUBJECT_INFO=$(prompt_default "Subject Info" "$DEFAULT_SUBJECT")
        fi
    fi

    export KEY_SIZE="${KEY_SIZE:-$DEFAULT_KEY_SIZE}"
    export SUBJECT_INFO="${SUBJECT_INFO:-$DEFAULT_SUBJECT}"
    export KEYS_DIR="${KEYS_DIR}"
    export SKIP_OTA="${SKIP_OTA}"
    
    run_signing
}

main "$@"
