#!/usr/bin/env python3
"""Generate AppStrings delegate from app_localizations.dart."""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "lib/core/localization/app_localizations.dart"
OUT = ROOT / "lib/shared/constants/app_strings.dart"

src = SRC.read_text(encoding="utf-8")

lines = [
    "import 'package:veil_mobile/core/localization/app_localizations.dart';",
    "import 'package:veil_mobile/core/localization/app_localizations_holder.dart';",
    "",
    "/// Backward-compatible access to localized strings.",
    "abstract final class AppStrings {",
    "  static AppLocalizations get _l => AppLocalizationsHolder.current;",
    "",
]

for m in re.finditer(r"^\s*String get (\w+)", src, re.MULTILINE):
    name = m.group(1)
    lines.append(f"  static String get {name} => _l.{name};")

for m in re.finditer(
    r"^\s*String (\w+)\(([^)]*)\)(?:\s*=>|\s*\{)", src, re.MULTILINE
):
    name, params = m.group(1), m.group(2).strip()
    if name == "get":
        continue
    if not params:
        continue
    if params.startswith("{"):
        names = re.findall(r"required \w+ (\w+)", params)
        call = ", ".join(f"{n}: {n}" for n in names)
        lines.append(f"  static String {name}({params}) => _l.{name}({call});")
    else:
        param_names = [p.strip().split()[-1] for p in params.split(",") if p.strip()]
        call = ", ".join(param_names)
        lines.append(f"  static String {name}({params}) => _l.{name}({call});")

lines.append("}")
OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
print(f"Wrote {OUT}")
