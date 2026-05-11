import Foundation

/// Live Harvard-Kyoto → IAST transliterator.
///
/// On every keystroke, the transliterator re-runs greedy longest-match
/// substitution over the *full* pending Latin buffer and produces a new
/// IAST output. The keyboard controller then deletes the previously
/// inserted output and inserts the new one — the same live-update pattern
/// used by macOS's Tibetan-Wylie input.
///
/// The buffer is committed (state cleared) when a non-letter character
/// arrives (space, punctuation, return, digits…).
final class HKToIASTTransliterator {

    /// Static input → output rules. Greedy: longer matches win.
    private static let rules: [String: String] = [
        // Long vowels
        "A":   "ā",
        "I":   "ī",
        "U":   "ū",
        // Vocalic r/l
        "R":   "ṛ",
        "RR":  "ṝ",
        "lR":  "ḷ",
        "lRR": "ḹ",
        // Nasals
        "G":   "ṅ",
        "J":   "ñ",
        "N":   "ṇ",
        // Retroflex stops
        "T":   "ṭ",
        "D":   "ḍ",
        // Sibilants
        "z":   "ś",
        "S":   "ṣ",
        // Anusvāra / visarga
        "M":   "ṃ",
        "H":   "ḥ",
    ]

    private static let maxRuleLen: Int = rules.keys.map(\.count).max() ?? 0

    /// What the user has typed since the last commit (raw HK chars).
    private(set) var pendingInput: String = ""
    /// What we currently have inserted into the proxy from `pendingInput`.
    private(set) var displayedOutput: String = ""

    struct Edit {
        /// Number of Unicode scalars to delete from the proxy — one
        /// `deleteBackward()` call per scalar. (Not grapheme clusters: those
        /// can span multiple scalars and `deleteBackward` would under-delete.)
        let deleteCount: Int
        /// Text to insert after deletion.
        let insert: String
    }

    /// Process a single character of input.
    /// Returns the edit the controller should apply to `textDocumentProxy`.
    func process(_ input: String) -> Edit {
        // Treat anything that isn't an HK letter (a-z, A-Z) as a commit boundary.
        if input.isEmpty || !isHKLetter(input) {
            let edit = Edit(deleteCount: 0, insert: input)
            pendingInput = ""
            displayedOutput = ""
            return edit
        }

        let newPending = pendingInput + input
        let newOutput = HKToIASTTransliterator.transliterate(newPending)
        let edit = Edit(deleteCount: displayedOutput.unicodeScalars.count, insert: newOutput)
        pendingInput = newPending
        displayedOutput = newOutput
        return edit
    }

    /// Process a backspace. Returns nil if the controller should perform
    /// a regular `deleteBackward()` on the proxy (we have no pending state).
    func processBackspace() -> Edit? {
        guard !pendingInput.isEmpty else { return nil }
        let newPending = String(pendingInput.dropLast())
        let newOutput = HKToIASTTransliterator.transliterate(newPending)
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

    private func isHKLetter(_ s: String) -> Bool {
        guard s.count == 1, let scalar = s.unicodeScalars.first else { return false }
        let v = scalar.value
        return (v >= 0x41 && v <= 0x5A) || (v >= 0x61 && v <= 0x7A)
    }
}
