# Privacy Policy

**Effective: May 11, 2026**

This policy covers **Sanskrit Keyboards**, a free iOS app of custom keyboards for typing Sanskrit in IAST, Devanāgarī, Harvard-Kyoto, and Velthuis transliteration schemes.

## Summary

**The app collects nothing.** It makes no network calls, contains no analytics or third-party SDKs, and stores no user data anywhere — locally, remotely, or otherwise. The keyboards do not request "Allow Full Access" in iOS Settings, and iOS's sandbox actively prevents them from sending data anywhere, even if a future bug tried to.

## What this means for the text you type

When you type with one of the keyboards, iOS routes each keystroke to the keyboard extension. The extension does a transliteration lookup against a fixed in-memory table — for example, `R` → `ṛ` for Harvard-Kyoto, or `.r` → `ṛ` for Velthuis — and returns the result to the text field you were typing into.

That lookup happens entirely on your device. The result is never logged, saved to a file, sent to a server, or shared with any other app. The keyboard extensions have no persistent storage of their own and no network access at all.

## Data we collect, store, share, sell, or transfer

None. Zero personal data. Zero usage data. Zero identifiers. Zero diagnostics. We have no data about you to retain, no data to delete on request, and no third parties to share data with.

## Allow Full Access

iOS keyboards can optionally request the "Allow Full Access" entitlement to enable features like cloud sync, custom dictionaries, or other behavior that requires network access. **None of these keyboards request it.** iOS will not show the Full Access toggle for them in Settings.

If you ever see a Full Access prompt for any of these keyboards, treat it as a bug and file an issue.

## Third parties

There are none. The app contains no third-party libraries, frameworks, SDKs, or services beyond what ships with iOS itself.

## Children

The app is suitable for all ages and collects no data from anyone, regardless of age.

## Open source

Full source code is published at <https://github.com/jiacheng-thermetery/Sanskrit-iOS-Keyboard>. Every claim in this policy can be verified by reading the code.

## Changes

If this policy ever changes, the updated version will replace this file in the repository and the **Effective** date above will be updated. The git history preserves every prior version.

## Contact

- File an issue: <https://github.com/jiacheng-thermetery/Sanskrit-iOS-Keyboard/issues>
- Email: jiacheng@thermetery.com
