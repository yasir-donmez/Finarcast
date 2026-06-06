import os
import json

en_path = os.path.join("lib", "l10n", "app_en.arb")
with open(en_path, "r", encoding="utf-8") as f:
    en_data = json.load(f)

# Count only non-metadata keys
en_keys = [k for k in en_data.keys() if not k.startswith("@")]
print(f"Total English keys: {len(en_keys)}")

other_langs = ["de", "es", "fr", "it", "ja", "ko", "pt", "zh"]
for lang in other_langs:
    lang_path = os.path.join("lib", "l10n", f"app_{lang}.arb")
    if os.path.exists(lang_path):
        with open(lang_path, "r", encoding="utf-8") as f:
            lang_data = json.load(f)
        lang_keys = [k for k in lang_data.keys() if not k.startswith("@")]
        missing = len(en_keys) - len(lang_keys)
        print(f"[{lang}] present: {len(lang_keys)}, missing: {missing}")
    else:
        print(f"[{lang}] not found")
