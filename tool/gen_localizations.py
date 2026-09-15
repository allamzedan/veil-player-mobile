#!/usr/bin/env python3
"""Generate app_localizations.dart and app_strings delegate from app_strings source."""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "lib/shared/constants/app_strings.dart"
OUT_L10N = ROOT / "lib/core/localization/app_localizations.dart"
OUT_STR = ROOT / "lib/shared/constants/app_strings.dart"

src = SRC.read_text(encoding="utf-8")
body_match = re.search(
    r"abstract final class AppStrings \{(.*)\}\s*$", src, re.DOTALL
)
if not body_match:
    raise SystemExit("Could not parse AppStrings")
body = body_match.group(1)

l10n_lines = [
    "import 'package:veil_mobile/core/localization/app_locale.dart';",
    "",
    "/// Locale-aware user-facing strings for VEIL Mobile.",
    "///",
    "/// Arabic currently reuses English copy until translations are added.",
    "class AppLocalizations {",
    "  const AppLocalizations._(this.languageCode);",
    "",
    "  final String languageCode;",
    "",
    "  bool get isRtl => languageCode == AppLanguageCode.ar;",
    "",
    "  static const AppLocalizations en =",
    "      AppLocalizations._(AppLanguageCode.en);",
    "  static const AppLocalizations ar =",
    "      AppLocalizations._(AppLanguageCode.ar);",
    "",
    "  factory AppLocalizations.forLanguageCode(String code) {",
    "    if (code == AppLanguageCode.ar) {",
    "      return ar;",
    "    }",
    "    return en;",
    "  }",
    "",
]

str_lines = [
    "import 'package:veil_mobile/core/localization/app_localizations.dart';",
    "import 'package:veil_mobile/core/localization/app_localizations_holder.dart';",
    "",
    "/// Backward-compatible access to localized strings.",
    "///",
    "/// Prefer [AppLocalizations] via [AppLocalizationsHolder] or Riverpod",
    "/// [appLocalizationsProvider] in new code.",
    "abstract final class AppStrings {",
    "  static AppLocalizations get _l => AppLocalizationsHolder.current;",
    "",
]

i = 0
body_lines = body.splitlines()
while i < len(body_lines):
    line = body_lines[i]
    stripped = line.strip()

    if not stripped:
        l10n_lines.append("")
        i += 1
        continue

    if stripped.startswith("//"):
        l10n_lines.append(line)
        i += 1
        continue

  # static const String name = value;
    const_match = re.match(r"static const String (\w+) = (.*);", stripped)
    if const_match:
        name, value = const_match.groups()
        l10n_lines.append(f"  String get {name} => {value};")
        str_lines.append(f"  static String get {name} => _l.{name};")
        i += 1
        continue

    # static String name(...) { or =>
    method_start = re.match(r"static String (\w+)\(([^)]*)\)", stripped)
    if method_start:
        name, params = method_start.groups()
        block = [line]
        i += 1
        while i < len(body_lines):
            block.append(body_lines[i])
            if body_lines[i].strip().endswith("}") and "static " not in body_lines[i]:
                break
            if body_lines[i].strip().endswith(";") and "=>" in "".join(block):
                break
            i += 1
        method_body = "\n".join(block)
        method_body = method_body.replace("static ", "  ", 1)
        l10n_lines.extend(method_body.splitlines())
        str_lines.append(
            f"  static String {name}({params}) => _l.{name}({params});"
        )
        i += 1
        continue

    # static String playerRuntimeEffectsLabel({...}) { multiline
    void_start = re.match(r"static String (\w+)\(\{", stripped)
    if void_start:
        name = void_start.group(1)
        block = [line]
        i += 1
        while i < len(body_lines):
            block.append(body_lines[i])
            if body_lines[i].strip() == "}":
                break
            i += 1
        method_body = "\n".join(block).replace("static ", "  ", 1)
        l10n_lines.extend(method_body.splitlines())
        # extract params for delegate
        param_block = "".join(block)
        params = re.search(r"\((\{.*?\})\)", param_block, re.DOTALL)
        if params:
            inner = params.group(1)
            names = re.findall(r"required \w+ (\w+)", inner)
            call = ", ".join(f"{n}: {n}" for n in names)
            str_lines.append(
                f"  static String {name}({inner}) => _l.{name}({call});"
            )
        i += 1
        continue

    i += 1

# Add settings language strings
lang_block = """
  // Language
  String get settingsLanguageSection => 'Language';
  String get settingsLanguageSystem => 'System Default';
  String get settingsLanguageEnglish => 'English';
  String get settingsLanguageArabic => 'Arabic';
"""
l10n_lines.append(lang_block)
str_lines.extend(
    [
        "  static String get settingsLanguageSection =>",
        "      _l.settingsLanguageSection;",
        "  static String get settingsLanguageSystem => _l.settingsLanguageSystem;",
        "  static String get settingsLanguageEnglish => _l.settingsLanguageEnglish;",
        "  static String get settingsLanguageArabic => _l.settingsLanguageArabic;",
    ]
)

l10n_lines.append("}")
str_lines.append("}")

OUT_L10N.write_text("\n".join(l10n_lines) + "\n", encoding="utf-8")
# Write delegate to temp first - we'll overwrite app_strings
OUT_STR.write_text("\n".join(str_lines) + "\n", encoding="utf-8")
print(f"Wrote {OUT_L10N} and {OUT_STR}")
