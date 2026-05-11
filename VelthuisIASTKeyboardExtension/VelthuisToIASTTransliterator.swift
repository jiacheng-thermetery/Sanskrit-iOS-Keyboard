import Foundation

/// Live Velthuis → IAST transliterator.
///
/// Greedy longest-match substitution over a case-folded Latin buffer.
/// (Velthuis treats case as cosmetic — the encoding is in the prefix
/// characters `.` `"` `~`, not in capitals.)
///
/// Buffer commits when a non-Velthuis character arrives (space, digit,
/// punctuation other than `.` `"` `~`, return). Backspace shortens the
/// buffer by one input character and re-renders.
final class VelthuisToIASTTransliterator {

    /// Velthuis → IAST substitution rules. Everything not listed passes
    /// through unchanged.
    private static let rules: [String: String] = [
        // Long vowels
        "aa":  "ā",
        "ii":  "ī",
        "uu":  "ū",
        // Vocalic r/l
        ".r":  "ṛ",
        ".rr": "ṝ",
        ".l":  "ḷ",
        ".ll": "ḹ",
        // Nasals
        "\"n": "ṅ",
        "~n":  "ñ",
        ".n":  "ṇ",
        // Retroflex stops
        ".t":  "ṭ",
        ".d":  "ḍ",
        // Sibilants
        "\"s": "ś",
        ".s":  "ṣ",
        // Anusvāra / visarga
        ".m":  "ṃ",
        ".h":  "ḥ",
    ]

    private static let maxRuleLen: Int = rules.keys.map(\.count).max() ?? 0

    private(set) var pendingInput: String = ""
    private(set) var displayedOutput: String = ""

    struct Edit {
        /// Scalars to delete via `deleteBackward()` (one call per scalar).
        let deleteCount: Int
        let insert: String
    }

    func process(_ input: String) -> Edit {
        if input.isEmpty || !isVelthuisInput(input) {
            let edit = Edit(deleteCount: 0, insert: input)
            pendingInput = ""
            displayedOutput = ""
            return edit
        }
        let newPending = pendingInput + input.lowercased()
        let newOutput = VelthuisToIASTTransliterator.transliterate(newPending)
        let edit = Edit(deleteCount: displayedOutput.unicodeScalars.count, insert: newOutput)
        pendingInput = newPending
        displayedOutput = newOutput
        return edit
    }

    func processBackspace() -> Edit? {
        guard !pendingInput.isEmpty else { return nil }
        let newPending = String(pendingInput.dropLast())
        let newOutput = VelthuisToIASTTransliterator.transliterate(newPending)
        let edit = Edit(deleteCount: displayedOutput.unicodeScalars.count, insert: newOutput)
        pendingInput = newPending
        displayedOutput = newOutput
        return edit
    }

    func reset() {
        pendingInput = ""
        displayedOutput = ""
    }

    // MARK: - Greedy longest-match transliteration

    static func transliterate(_ s: String) -> String {
        var out = ""
        let chars = Array(s)
        var i = 0
        while i < chars.count {
            var matched = false
            let upper = min(maxRuleLen, chars.count - i)
            for length in stride(from: upper, through: 1, by: -1) {
                let candidate = String(chars[i..<(i + length)])
                if let replacement = rules[candidate] {
                    out += replacement
                    i += length
                    matched = true
                    break
                }
            }
            if !matched {
                out.append(chars[i])
                i += 1
            }
        }
        return out
    }

    /// Whether the entire input belongs to the buffer. Velthuis-extending
    /// characters are ASCII letters plus the three prefix marks `.` `"` `~`.
    /// Anything else (space, digit, return, punctuation) commits.
    ///
    /// Multi-character inputs are allowed — long-press popovers commit whole
    /// Velthuis bigrams like `.r` or `~n` as a single insert.
    private func isVelthuisInput(_ s: String) -> Bool {
        guard !s.isEmpty else { return false }
        for scalar in s.unicodeScalars {
            let v = scalar.value
            let isAsciiLetter = (v >= 0x41 && v <= 0x5A) || (v >= 0x61 && v <= 0x7A)
            let isPrefix = scalar == "." || scalar == "\"" || scalar == "~"
            if !isAsciiLetter && !isPrefix { return false }
        }
        return true
    }
}
