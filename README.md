# Signify

A simple shell tool to auto-generate and integrate Android ROM signing keys (including APEX).

---

## 🔧 Usage

> **Note:** Always run these commands from your ROM's root directory.

**For VoltageOS just run this:**
```bash
echo "no" | bash <(curl -s https://raw.githubusercontent.com/TopexGuy/Signify/voltageos/Signify.sh)
```

---

## 📁 Output
- Keys saved in `vendor/voltage-priv/keys`
- Auto-generated:
  - `Android.bp`
  - `keys.mk`
  - Standard + APEX keys  
  - `releasekey` symlinks

---

## 🚀 Features
- Auto key & APEX cert generation  
- Release-keys ready signing  
- Skip existing keys  
- Configurable key path  