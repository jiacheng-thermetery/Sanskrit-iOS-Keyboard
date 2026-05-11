# Sanskrit Keyboards for iOS

Six custom iOS keyboards for typing Sanskrit. Pick whichever matches your habits — they coexist, you enable each one separately in Settings, and switch between them with the 🌐 globe key.

| Keyboard                  | Input                  | Output                  | When to use                                              |
|---------------------------|------------------------|-------------------------|----------------------------------------------------------|
| **IAST**                  | QWERTY + long-press    | IAST (`ā ī ṛ ñ ṣ ṃ ḥ`)  | Occasional Sanskrit; same gesture as accented letters.   |
| **HK → IAST**             | Harvard-Kyoto          | IAST                    | Fluent HK typists who want diacritics fast.              |
| **HK → Devanāgarī**       | Harvard-Kyoto          | Devanāgarī (`कृष्ण`)    | Devanāgarī output without an Indic keyboard.             |
| **IAST → Devanāgarī**     | QWERTY + long-press    | Devanāgarī              | Read in IAST while typing; render Devanāgarī.            |
| **Velthuis → IAST**       | Velthuis (`.r ~n "s`)  | IAST                    | Velthuis muscle memory from devnag / LaTeX.              |
| **Velthuis → Devanāgarī** | Velthuis               | Devanāgarī              | Same, with Devanāgarī output.                            |

The five transliterating keyboards (everything except plain IAST) do live, Wylie-style transliteration: each keystroke is buffered, the *whole* pending sequence is re-transliterated, and the on-screen text is updated by deleting the old render and inserting the new one. Type `R` in HK and you see `ṛ`; type another `R` and `ṛ` is replaced with `ṝ`. Space (or any non-buffer character) commits and resets the buffer. The Velthuis keyboards treat `.` `"` `~` as letter-like — `.` followed by `r` becomes `ṛ`/`ऋ`, not a period.

## IAST keyboard — long-press cheatsheet

The same long-press layout is used by **IAST → Devanāgarī** — only the output script differs.

| Base | Long-press variants  |
|------|----------------------|
| `a`  | `ā`                  |
| `i`  | `ī`                  |
| `u`  | `ū`                  |
| `r`  | `ṛ`, `ṝ`             |
| `l`  | `ḷ`, `ḹ`             |
| `n`  | `ñ`, `ṅ`, `ṇ`        |
| `t`  | `ṭ`                  |
| `d`  | `ḍ`                  |
| `s`  | `ś`, `ṣ`             |
| `m`  | `ṃ`, `ṁ`             |
| `h`  | `ḥ`                  |
| `\|` | `।`, `॥` (in 123 mode) |

Shift gives uppercase variants (`Ā Ī Ū Ṛ ...`).

## Harvard-Kyoto cheatsheet

Used by both HK keyboards. Capitals are reserved for long vowels and retroflex/palatal consonants.

| HK input        | IAST     | Devanāgarī (independent) |
|-----------------|----------|--------------------------|
| `a A`           | `a ā`    | `अ आ`                    |
| `i I`           | `i ī`    | `इ ई`                    |
| `u U`           | `u ū`    | `उ ऊ`                    |
| `R RR`          | `ṛ ṝ`    | `ऋ ॠ`                    |
| `lR lRR`        | `ḷ ḹ`    | `ऌ ॡ`                    |
| `e ai o au`     | `e ai o au` | `ए ऐ ओ औ`             |
| `k kh g gh G`   | `k kh g gh ṅ` | `क ख ग घ ङ`         |
| `c ch j jh J`   | `c ch j jh ñ` | `च छ ज झ ञ`         |
| `T Th D Dh N`   | `ṭ ṭh ḍ ḍh ṇ` | `ट ठ ड ढ ण`         |
| `t th d dh n`   | `t th d dh n` | `त थ द ध न`         |
| `p ph b bh m`   | `p ph b bh m` | `प फ ब भ म`         |
| `y r l v`       | `y r l v`     | `य र ल व`           |
| `z S s h`       | `ś ṣ s h`     | `श ष स ह`           |
| `M H`           | `ṃ ḥ`         | `ं ः`                |

Examples (HK → Devanāgarī):

- `namaste` → `नमस्ते`
- `saMskRtam` → `संस्कृतम्`
- `zrI` → `श्री`
- `kRSNa` → `कृष्ण`
- `dharma` → `धर्म`

## Velthuis cheatsheet

Used by both Velthuis keyboards. The prefix marks `.` (retroflex / vocalic / modifier), `"` (palatal sibilant & velar nasal), and `~` (palatal nasal) are letter-like — they go into the buffer instead of committing it. Case is cosmetic; `K` and `k` both give `क`/`k`. The on-screen popover exposes the common bigrams (`.r .rr`, `.t`, `.d`, `.n ~n "n`, `.s "s`, `.l .ll`, `.m`, `.h`, `aa ii uu`) as long-press shortcuts so you don't have to switch to the symbols layer for `.` `"` `~`.

| Velthuis input        | IAST          | Devanāgarī (independent) |
|-----------------------|---------------|--------------------------|
| `a aa`                | `a ā`         | `अ आ`                    |
| `i ii`                | `i ī`         | `इ ई`                    |
| `u uu`                | `u ū`         | `उ ऊ`                    |
| `.r .rr`              | `ṛ ṝ`         | `ऋ ॠ`                    |
| `.l .ll`              | `ḷ ḹ`         | `ऌ ॡ`                    |
| `e ai o au`           | `e ai o au`   | `ए ऐ ओ औ`                |
| `k kh g gh "n`        | `k kh g gh ṅ` | `क ख ग घ ङ`              |
| `c ch j jh ~n`        | `c ch j jh ñ` | `च छ ज झ ञ`              |
| `.t .th .d .dh .n`    | `ṭ ṭh ḍ ḍh ṇ` | `ट ठ ड ढ ण`              |
| `t th d dh n`         | `t th d dh n` | `त थ द ध न`              |
| `p ph b bh m`         | `p ph b bh m` | `प फ ब भ म`              |
| `y r l v`             | `y r l v`     | `य र ल व`                |
| `"s .s s h`           | `ś ṣ s h`     | `श ष स ह`                |
| `.m .h`               | `ṃ ḥ`         | `ं ः`                     |

Examples (Velthuis → Devanāgarī):

- `namaste` → `नमस्ते`
- `sa.msk.rtam` → `संस्कृतम्`
- `"srii` → `श्री`
- `k.r.s.na` → `कृष्ण`
- `j~naana` → `ज्ञान`
- `dharma` → `धर्म`

## Build

You need a Mac with Xcode 15+ (and an Apple Developer account for device installs).

1. **Install XcodeGen** (one-time):

   ```sh
   brew install xcodegen
   ```

2. **(For device installs) set your Apple Developer Team ID** in `project.yml`. The simulator builds fine with this blank.

   ```yaml
   settings:
     base:
       DEVELOPMENT_TEAM: "ABCDE12345"   # <-- your 10-char team ID
   ```

3. **Generate the Xcode project**:

   ```sh
   cd Sanskrit-iOS-Keyboard
   xcodegen
   open IASTKeyboard.xcodeproj
   ```

4. **(Optional) Change the bundle ID prefix** if `com.thermetery` isn't yours. Edit `project.yml` — change the prefix on the host app and on every extension (each extension's bundle ID must start with the host app's bundle ID).

5. **Build & install** to the simulator or your device: pick the **IASTKeyboard** scheme, choose your run target, ⌘R. With a free developer account, a device install lasts 7 days; with a paid account, 1 year.

## Enable the keyboards

After install, on the device or simulator:

1. Settings → General → Keyboard → Keyboards → **Add New Keyboard…**
2. Pick any of **IAST**, **HK → IAST**, **HK → Devanāgarī**, **IAST → Devanāgarī**, **Velthuis → IAST**, **Velthuis → Devanāgarī** (enable as many as you want).
3. In any text field, tap and hold the 🌐 globe key on the system keyboard, then choose the one you want.

You don't need to grant "Allow Full Access" — these keyboards do no networking and store nothing.

## Project layout

```
.
├── project.yml                          # XcodeGen spec
├── IASTKeyboard/                        # Host app (SwiftUI)
├── IASTKeyboardExtension/               # IAST popover keyboard
│   ├── KeyDefinition.swift              ┐
│   ├── KeyButton.swift                  │ shared UI primitives — compiled
│   ├── KeyboardView.swift               │ into every other extension target
│   ├── PopoverView.swift                ┘
│   ├── KeyboardLayouts.swift            # popover layout — also reused
│   │                                    # by IAST → Devanāgarī
│   ├── KeyboardViewController.swift
│   └── Info.plist
├── HKShared/
│   └── KeyboardLayouts.swift            # plain QWERTY, shared by both HK keyboards
├── HKIASTKeyboardExtension/
│   ├── HKToIASTTransliterator.swift     # greedy longest-match
│   ├── KeyboardViewController.swift
│   └── Info.plist
├── HKDevanagariKeyboardExtension/
│   ├── HKToDevanagariTransliterator.swift  # syllable composer
│   ├── KeyboardViewController.swift
│   └── Info.plist
├── IASTDevanagariKeyboardExtension/
│   ├── IASTToDevanagariTransliterator.swift  # syllable composer (IAST input)
│   ├── KeyboardViewController.swift
│   └── Info.plist
├── VelthuisShared/
│   └── KeyboardLayouts.swift            # popover layout with Velthuis bigrams
│                                        # (.r .t ~n "s aa …) as long-press alts
├── VelthuisIASTKeyboardExtension/
│   ├── VelthuisToIASTTransliterator.swift  # greedy longest-match
│   ├── KeyboardViewController.swift
│   └── Info.plist
└── VelthuisDevanagariKeyboardExtension/
    ├── VelthuisToDevanagariTransliterator.swift  # syllable composer
    ├── KeyboardViewController.swift
    └── Info.plist
```

## Customizing

- **IAST popover alternates** (also affects IAST → Devanāgarī): edit `IASTKeyboardExtension/KeyboardLayouts.swift` — change the `alts:` parameter on any key.
- **HK rules**: edit `HKIASTKeyboardExtension/HKToIASTTransliterator.swift` (flat dictionary) or `HKDevanagariKeyboardExtension/HKToDevanagariTransliterator.swift` (consonants/vowels/modifiers tables).
- **HK QWERTY layout**: edit `HKShared/KeyboardLayouts.swift` — affects both HK keyboards.
- **IAST → Devanāgarī rules**: edit `IASTDevanagariKeyboardExtension/IASTToDevanagariTransliterator.swift`.
- **Velthuis popover bigrams**: edit `VelthuisShared/KeyboardLayouts.swift` — the long-press alts on `r`, `t`, `n`, `s`, etc. that emit `.r`, `.t`, `~n`, `"s`, … in one gesture.
- **Velthuis rules**: edit `VelthuisIASTKeyboardExtension/VelthuisToIASTTransliterator.swift` or `VelthuisDevanagariKeyboardExtension/VelthuisToDevanagariTransliterator.swift`.

## Notes

- All six extensions have `RequestsOpenAccess = false`. No network, no shared containers.
- iOS deployment target is 16.0.
- Backspace in any transliterating keyboard removes one *input* character at a time (re-running the transliteration), matching the macOS Tibetan-Wylie behaviour. Hit space to commit and "lock in" the current rendering.
- For Devanāgarī output, the controller deletes one Unicode *scalar* per `deleteBackward()` call — consonant + virama (+ conjunct consonant) forms a single grapheme cluster but multiple scalars, so counting graphemes would under-delete and corrupt the live update.
- Cursor moves and selection changes reset the transliteration buffer — so if you tap to a different position mid-word, the next keystroke starts fresh.
