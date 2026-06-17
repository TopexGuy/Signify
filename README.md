# Signify

**Signify** is an advanced Android ROM signing key generator tailored for AOSP and LineageOS-based distributions. It automates the creation of standard certificates and APEX/CAPEX overrides, ensuring your build is securely and correctly signed with minimal effort.

---

## Quick Start

Run the following command from your **ROM root directory** to generate keys with default settings:

```bash
bash <(curl -s https://raw.githubusercontent.com/TopexGuy/Signify/main/signify.sh) --auto
```

---

## Features

- **Automated Generation:** Dynamic extraction and generation of all required certificates (Standard + APEX).
- **Smart Build System:** Automatically generates `Android.bp` and patches `keys.mk` with correct paths.
- **CI Ready:** Non-interactive mode with `--auto` flag and configurable timeouts.
- **Verification Tool:** Includes `check_keys.py` to verify the signing status of your build artifacts.
- **Safe Execution:** Does not overwrite existing keys and operates within a clean environment.

---

## Prerequisites

Before running Signify, ensure your environment meets these requirements:
- **Environment:** Must be run from the root of an Android ROM source tree.
- **Dependencies:** 
  - `git`, `bash`, `sed`, `grep` (Standard on most Linux distros).
  - `python3` with `cryptography` library (for verification).
  - `java` (for `apksigner`).

---

## Usage Guide

### 1. Key Generation

**Interactive Mode:**
Best for first-time setup or customization.
```bash
bash <(curl -s https://raw.githubusercontent.com/TopexGuy/Signify/main/signify.sh)
```

**Auto Mode (Defaults):**
Uses default values for all prompts.
```bash
bash <(curl -s https://raw.githubusercontent.com/TopexGuy/Signify/main/signify.sh) --auto
```

**Advanced Configuration:**
Pass environment variables to customize the process.
```bash
KEYS_DIR="vendor/lineage-priv/keys" KEY_SIZE=4096 SKIP_OTA=true bash <(curl -s https://raw.githubusercontent.com/TopexGuy/Signify/main/signify.sh) --auto
```

| Variable | Default | Description |
|:---|:---|:---|
| `KEYS_DIR` | `vendor/signify/keys` | Destination path relative to ROM root. |
| `KEY_SIZE` | `4096` | RSA key size (2048 or 4096). |
| `SKIP_OTA` | `false` | Set to `true` to skip generating `otakey`. |
| `TIMEOUT` | `20` | Duration (seconds) to wait for interactive prompts. |

### 2. Device Integration

To use the generated keys in your build, add this line to your `device.mk` or `common.mk`:

```makefile
$(call inherit-product-if-exists, vendor/signify/keys/keys.mk)
```
*(Adjust the path if you used a custom `KEYS_DIR`)*

---

## Verification (check_keys.py)

The included `check_keys.py` script checks whether all `.apk`, `.apex`, and `.capex` files in your build output are signed with the keys present in the keys directory.

### Running Verification:

1. **Install Dependencies:**
   ```bash
   pip install cryptography
   ```
2. **Execute Script:**
   ```bash
   # Navigate to the keys directory (e.g., vendor/signify/keys)
   cd vendor/signify/keys
   
   # Run the script pointing to your build output
   python3 check_keys.py $OUT
   ```

### Important Notes:
- **Unknown Keys:** The script will report if a file is signed with an unknown key.
- **Vendor Targets:** Be aware that some targets are expected to be signed with vendor keys rather than your own. For example, `com.android.apex.cts.shim.v1_prebuilt` is a known target that often reports as "unknown".
- **Path Dependency:** This tool expects to find `apksigner.jar` within your ROM tree's prebuilts.

---

## Output Structure

After execution, your `KEYS_DIR` will contain:
- `*.pk8` & `*.x509.pem`: Private keys and certificates.
- `Android.bp`: Soong modules for certificate overrides.
- `keys.mk`: Product configuration for the build system.
- `check_keys.py`: Build verification utility.
