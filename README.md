# Signify

A simple shell tool to auto-generate and integrate Android ROM signing keys (including APEX).

---

## 🔧 Usage

> **Note:** Always run these commands from your ROM's root directory.

**Manual mode (confirm prompts manually):**
```bash
bash <(curl -s https://raw.githubusercontent.com/TopexGuy/Signify/main/Signify.sh)
```

**Auto mode (skip all prompts):**
```bash
echo "no" | bash <(curl -s https://raw.githubusercontent.com/TopexGuy/Signify/main/Signify.sh)
```

---

## 📁 Output
- Keys saved in `vendor/signify/keys`
- Auto-generated:
  - `Android.bp`
  - `keys.mk`
  - Standard + APEX keys  
  - `releasekey` symlinks

---

## ⚙️ Device Integration
Add to your `device.mk` or `common.mk`:
```makefile
$(call inherit-product, vendor/signify/keys/keys.mk)
```

Build normally:
```bash
. build/envsetup.sh
lunch <device>-user
mka bacon
```

---

## 🚀 Features
- Auto key & APEX cert generation  
- Release-keys ready signing  
- Skip existing keys  
- Configurable key path  
- Works with all AOSP/Lineage-based ROMs
