# Sanskrit Keyboards for iOS

Three custom iOS keyboards for typing Sanskrit. Pick whichever matches your habits — they coexist, you enable each one separately in Settings, and switch between them with the 🌐 globe key.

| Keyboard           | Input          | Output                | When to use                                            |
|--------------------|----------------|-----------------------|--------------------------------------------------------|
| **IAST**           | QWERTY + long-press | IAST (`ā ī ṛ ñ ṣ ṃ ḥ`) | Occasional Sanskrit; same gesture as accented letters. |
| **HK → IAST**      | Harvard-Kyoto  | IAST                  | Fluent typists who want diacritics fast.               |
| **HK → Devanāgarī**| Harvard-Kyoto  | Devanāgarī (`कृष्ण`)  | Devanāgarī output without an Indic keyboard.           |

The HK keyboards do live, Wylie-style transliteration: each keystroke is buffered, the *whole* pending sequence is re-transliterated, and the on-screen text is updated by deleting the old render and inserting the new one. Type `R` and you see `ṛ`; type another `R` and `ṛ` is replaced with `ṝ`. Space (or any non-letter) commits and resets the buffer.

## IAST keyboard — long-press cheatsheet

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

## Build

You need a Mac with Xcode 15+ and an Apple Developer account.

1. **Install XcodeGen** (one-time):

   ```sh
   brew install xcodegen
   ```

2. **Set your Apple Developer Team ID** in `project.yml`:

   ```yaml
   settings:
     base:
       DEVELOPMENT_TEAM: "ABCDE12345"   # <-- your 10-char team ID
   ```

3. **Generate the Xcode project**:

   ```sh
   cd IASTKeyboard
   xcodegen
   open IASTKeyboard.xcodeproj
   ```

4. **(Optional) Change the bundle ID prefix** if `com.thermetery` isn't yours. Edit `project.yml` — change the prefix on the host app and on all three extensions (each extension's bundle ID must start with the host app's bundle ID).

5. **Build & install** to your device: select your iPhone in Xcode's run target dropdown and hit ⌘R. With a free developer account, the install lasts 7 days; with a paid account, 1 year.

## Enable the keyboards

After install, on your iPhone:

1. Settings → General → Keyboard → Keyboards → **Add New Keyboard…**
2. Pick any of **IAST**, **HK → IAST**, **HK → Devanāgarī** (you can enable as many as you want).
3. In any text field, tap and hold the 🌐 globe key on the system keyboard, then choose the one you want.

You don't need to grant "Allow Full Access" — these keyboards do no networking and store nothing.

## Project layout

```
IASTKeyboard/
├── project.yml                          # XcodeGen spec
├── IASTKeyboard/                        # Host app (SwiftUI)
├── IASTKeyboardExtension/               # IAST popover keyboard
│   ├── KeyDefinition.swift              ┐
│   ├── KeyButton.swift                  │ shared UI primitives — also
│   ├── KeyboardView.swift               │ compiled into the HK targets
│   ├── PopoverView.swift                ┘
│   ├── KeyboardLayouts.swift            # popover-specific layout
│   ├── KeyboardViewController.swift
│   └── Info.plist
├── HKShared/                            # Shared by both HK keyboards
│   └── KeyboardLayouts.swift            # plain QWERTY, no popovers
├── HKIASTKeyboardExtension/
│   ├── HKToIASTTransliterator.swift     # greedy longest-match
│   ├── KeyboardViewController.swift
│   └── Info.plist
└── HKDevanagariKeyboardExtension/
    ├── HKToDevanagariTransliterator.swift  # syllable composer
    ├── KeyboardViewController.swift
    └── Info.plist
```

## Customizing

- **IAST popover alternates**: edit `IASTKeyboardExtension/KeyboardLayouts.swift` — change the `alts:` parameter on any key.
- **HK rules**: edit `HKIASTKeyboardExtension/HKToIASTTransliterator.swift` (flat dictionary) or `HKDevanagariKeyboardExtension/HKToDevanagariTransliterator.swift` (consonants/vowels/modifiers tables).
- **HK QWERTY layout**: edit `HKShared/KeyboardLayouts.swift` — affects both HK keyboards.

## Notes

- All three extensions have `RequestsOpenAccess = false`. No network, no shared containers.
- iOS deployment target is 16.0.
- Backspace in the HK keyboards removes one *Latin* character at a time (re-running the transliteration), matching the macOS Tibetan-Wylie behaviour. Hit space (or any non-letter) to commit and "lock in" the current rendering.
- Cursor moves and selection changes reset the HK transliteration buffer — so if you tap to a different position mid-word, the next keystroke starts fresh.
