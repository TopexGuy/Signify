#!/bin/bash
# Patched make_key for automation

set -u
MAKE_KEY_TOOL="${ROM_ROOT}/development/tools/make_key"

if [[ ! -f "$MAKE_KEY_TOOL" ]]; then
    echo "Error: make_key tool not found at $MAKE_KEY_TOOL"
    exit 1
fi

bash <(sed "s/2048/${2:-2048}/;/Enter password/,+1d" "$MAKE_KEY_TOOL") \
    "$1" \
    "${SUBJECT_INFO:-'/C=US/ST=California/L=Mountain View/O=Android/OU=Android/CN=Android/emailAddress=android@android.com'}"
