#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
#
# Script Name : Signify.sh
# Author      : TopexGuy
# Description : ROM signing key generator & manager
# Key Folder  : Default = vendor/signify/keys (configurable via KEYS_DIR)

# ====== CONFIGURATION ======
KEYS_DIR="vendor/signify/keys"
mkdir -p "$KEYS_DIR"
# ===========================

# ====== KEY LISTS ======
certificates=(
    bluetooth
    cts_uicc_2021
    cyngn-app
    media
    networkstack
    nfc
    platform
    sdk_sandbox
    shared
    testcert
    testkey
    verity
    gmscompat_lib
    otakey
)

apex_certificates=(
    com.android.adbd
    com.android.adservices.api
    com.android.adservices
    com.android.appsearch
    com.android.art
    com.android.bluetooth
    com.android.btservices
    com.android.cellbroadcast
    com.android.compos
    com.android.configinfrastructure
    com.android.connectivity.resources
    com.android.conscrypt
    com.android.devicelock
    com.android.extservices
    com.android.graphics.pdf
    com.android.hardware.biometrics.face.virtual
    com.android.hardware.biometrics.fingerprint.virtual
    com.android.hardware.boot
    com.android.hardware.cas
    com.android.hardware.wifi
    com.android.healthfitness
    com.android.hotspot2.osulogin
    com.android.i18n
    com.android.ipsec
    com.android.media
    com.android.mediaprovider
    com.android.media.swcodec
    com.android.nearby.halfsheet
    com.android.networkstack.tethering
    com.android.neuralnetworks
    com.android.ondevicepersonalization
    com.android.os.statsd
    com.android.permission
    com.android.resolv
    com.android.rkpd
    com.android.runtime
    com.android.safetycenter.resources
    com.android.scheduling
    com.android.sdkext
    com.android.support.apexer
    com.android.telephony
    com.android.telephonymodules
    com.android.tethering
    com.android.tzdata
    com.android.uwb
    com.android.uwb.resources
    com.android.virt
    com.android.vndk.current
    com.android.wifi
    com.android.wifi.dialog
    com.android.wifi.resources
    com.google.pixel.camera.hal
    com.google.pixel.vibrator.hal
    com.qorvo.uwb
)
# =======================

# ====== HELPER FUNCTIONS ======
green() { echo -e "\e[1;32m$1\e[0m"; }
yellow() { echo -e "\e[1;33m$1\e[0m"; }

confirm() {
    while true; do
        read -r -p "$1 (yes/no): " input
        case "$input" in
            [yY][eE][sS]|[yY]) echo "yes"; return ;;
            [nN][oO]|[nN]) echo "no"; return ;;
        esac
    done
}

prompt() {
    while true; do
        read -p "$1" input
        [[ -n "$input" ]] && echo "$input" && return
    done
}

prompt_key_size() {
    while true; do
        read -p "$1" input
        [[ "$input" == "2048" || "$input" == "4096" ]] && echo "$input" && return
    done
}
# ==============================

# ====== MAIN FUNCTIONS ======
user_input() {
    echo ""
    yellow "── Key Configuration ──"

    if [[ $(confirm "Do you want to customize key size and subject info?") == "yes" ]]; then
        key_size=$(prompt_key_size "Enter key size (2048 or 4096): ")
        country_code=$(prompt "Country code (e.g. US): ")
        state=$(prompt "State/Province: ")
        city=$(prompt "City/Locality: ")
        org=$(prompt "Organization: ")
        ou=$(prompt "Organizational Unit: ")
        cn=$(prompt "Common Name: ")
        email=$(prompt "Email: ")

        echo ""
        yellow "Subject Preview:"
        echo "  Key Size: $key_size"
        echo "  C=$country_code, ST=$state, L=$city"
        echo "  O=$org, OU=$ou, CN=$cn, email=$email"

        [[ $(confirm "Is this correct?") != "yes" ]] && echo "Aborted." && exit 0
    else
        key_size=2048
        country_code=US
        state=California
        city="Mountain View"
        org=Android
        ou=Android
        cn=Android
        email="android@android.com"
    fi

    subject="/C=$country_code/ST=$state/L=$city/O=$org/OU=$ou/CN=$cn/emailAddress=$email"
    generate_certificates
}

generate_certificates() {

    if [ ! -x ./development/tools/make_key ]; then
        echo "Error: make_key not found at ./development/tools/make_key"
        exit 1
    fi

    green "\n→ Generating certificates inside $KEYS_DIR..."

    for certificate in "${certificates[@]}" "${apex_certificates[@]}"; do

        if [[ " ${certificates[*]} " == *" $certificate "* ]]; then
            cert_name="$certificate"
        else
            safe="${certificate//./_}"
            cert_name="${safe}.certificate.override"
        fi

        if [[ -f "$KEYS_DIR/$cert_name.pk8" || -f "$KEYS_DIR/$cert_name.x509.pem" ]]; then
            echo "• $cert_name already exists → skipped"
            continue
        fi

        echo "• Generating $cert_name ..."
        bash ./development/tools/make_key "$KEYS_DIR/$cert_name" "$subject"
    done

    create_releasekey
    generate_android_bp
    generate_keys_mk
}

create_releasekey() {
    if [[ -f "$KEYS_DIR/releasekey.pk8" && -f "$KEYS_DIR/releasekey.x509.pem" ]]; then
        yellow "→ releasekey already exists — skipping"
        return
    fi

    green "\n→ Generating releasekey..."
    bash ./development/tools/make_key "$KEYS_DIR/releasekey" "$subject"
}

generate_android_bp() {
    green "→ Writing Android.bp..."
    {
        for apex in "${apex_certificates[@]}"; do
            safe="${apex//./_}"
            echo "android_app_certificate {"
            echo "    name: \"$safe.certificate.override\","
            echo "    certificate: \"$safe.certificate.override\","
            echo "}"
            echo ""
        done
    } > "$KEYS_DIR/Android.bp"
}

generate_keys_mk() {
    green "→ Writing keys.mk..."
    {
        echo "PRODUCT_CERTIFICATE_OVERRIDES := \\"
        for apex in "${apex_certificates[@]}"; do
            safe="${apex//./_}"
            echo "    $apex:$safe.certificate.override \\"
        done
        echo ""
        echo "PRODUCT_DEFAULT_DEV_CERTIFICATE := $KEYS_DIR/releasekey"
        echo "PRODUCT_OTA_PUBLIC_KEYS := $KEYS_DIR/otakey.x509.pem"
        echo "PRODUCT_EXTRA_RECOVERY_KEYS :="
    } > "$KEYS_DIR/keys.mk"
}

# ==============================

# ====== EXECUTION START ======
user_input
green "\n✓ All tasks completed successfully!"
echo "Keys saved at: $KEYS_DIR"
echo -e "🔏 Generated with Signify by TopexGuy"
# ==============================
