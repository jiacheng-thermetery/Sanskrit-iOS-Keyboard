import Foundation

/// Live IAST → Devanāgarī transliterator.
///
/// Same buffered live-update model as `HKToDevanagariTransliterator`: every
/// keystroke is appended to a pending Latin buffer (case-folded — Devanāgarī
/// has no case), the whole buffer is re-tokenized with greedy longest-match,
/// and the on-screen Devanāgarī is replaced with the new rendering.
///
/// Input alphabet is IAST with precomposed diacritic letters:
///   ā ī ū ṛ ṝ ḷ ḹ ṅ ñ ṭ ḍ ṇ ś ṣ ṃ ḥ
/// (matching what the IAST popover keyboard emits.)
final class IASTToDevanagariTransliterator {

    // MARK: - Token tables

    /// Independent vowels (no consonant pending).
    private static let independentVowels: [String: String] = [
        "a":  "अ", "ā":  "आ",
        "i":  "इ", "ī":  "ई",
        "u":  "उ", "ū":  "ऊ",
        "ṛ":  "ऋ", "ṝ":  "ॠ",
        "ḷ":  "ऌ", "ḹ":  "ॡ",
        "e":  "ए", "ai": "ऐ",
        "o":  "ओ", "au": "औ",
    ]

    /// Dependent vowel signs (after a consonant). `a` is empty — short-a is
    /// the consonant's implicit vowel and needs no visible mark.
    private static let vowelSigns: [String: String] = [
        "a":  "",   "ā":  "ा",
        "i":  "ि", "ī":  "ी",
        "u":  "ु", "ū":  "ू",
        "ṛ":  "ृ", "ṝ":  "ॄ",
        "ḷ":  "ॢ", "ḹ":  "ॣ",
        "e":  "े", "ai": "ै",
        "o":  "ो", "au": "ौ",
    ]

    private static let consonants: [String: String] = [
        "k":  "क", "kh": "ख", "g":  "ग", "gh": "घ", "ṅ":  "ङ",
        "c":  "च", "ch": "छ", "j":  "ज", "jh": "झ", "ñ":  "ञ",
        "ṭ":  "ट", "ṭh": "ठ", "ḍ":  "ड", "ḍh": "ढ", "ṇ":  "ण",
        "t":  "त", "th": "थ", "d":  "द", "dh": "ध", "n":  "न",
        "p":  "प", "ph": "फ", "b":  "ब", "bh": "भ", "m":  "म",
        "y":  "य", "r":  "र", "l":  "ल", "v":  "व",
        "ś":  "श", "ṣ":  "ष", "s":  "स", "h":  "ह",
    ]

    /// Anusvāra and visarga. Both ṃ and ṁ are accepted as anusvāra — the
    /// dot-above form is common in older scholarly transcriptions.
    private static let modifiers: [String: String] = [
        "ṃ": "ं",
        "ṁ": "ं",
        "ḥ": "ः",
    ]

    private static let virama = "\u{094D}"   // ्

    private static let allTokens: Set<String> = {
        var s = Set<String>()
        s.formUnion(independentVowels.keys)
        s.formUnion(consonants.keys)
        s.formUnion(modifiers.keys)
        return s
    }()

    private static let maxTokenLen: Int = allTokens.map(\.count).max() ?? 0

    /// Characters we treat as belonging to an IAST word — anything else
    /// (space, punctuation, digits, return) commits the pending buffer.
    private static let iastLowerLetters: Set<Character> = {
        var s = Set<Character>()
        for c in "abcdefghijklmnopqrstuvwxyz" { s.insert(c) }
        for c in "āīūṛṝḷḹṅñṭḍṇśṣṃṁḥ" { s.insert(c) }
        return s
    }()

    // MARK: - Live state

    private(set) var pendingInput: String = ""
    private(set) var displayedOutput: String = ""

    struct Edit {
        /// Number of Unicode scalars to delete from the proxy — one
        /// `deleteBackward()` call per scalar. (See HKToDevanagari for why.)
        let deleteCount: Int
        let insert: String
    }

    func process(_ input: String) -> Edit {
        if input.isEmpty || !isIASTLetter(input) {
            let edit = Edit(deleteCount: 0, insert: input)
            pendingInput = ""
            displayedOutput = ""
            return edit
        }
        let newPending = pendingInput + input.lowercased()
        let newOutput = IASTToDevanagariTransliterator.transliterate(newPending)
        let edit = Edit(deleteCount: displayedOutput.unicodeScalars.count, insert: newOutput)
        pendingInput = newPending
        displayedOutput = newOutput
        return edit
    }

    func processBackspace() -> Edit? {
        guard !pendingInput.isEmpty else { return nil }
        let newPending = String(pendingInput.dropLast())
        let newOutput = IASTToDevanagariTransliterator.transliterate(newPending)
        let edit = Edit(deleteCount: displayedOutput.unicodeScalars.count, insert: newOutput)
        pendingInput = newPending
        displayedOutput = newOutput
        return edit
    }

    func reset() {
        pendingInput = ""
        displayedOutput = ""
    }

    // MARK: - Core algorithm

    static func transliterate(_ s: String) -> String {
        let tokens = tokenize(s)
        var out = ""
        var pending: String? = nil

        for token in tokens {
            if let cons = consonants[token] {
                if let prev = pending { out += prev + virama }
                pending = cons
            } else if let sign = vowelSigns[token] {
                if let prev = pending {
                    out += prev + sign
                    pending = nil
                } else {
                    out += independentVowels[token] ?? token
                }
            } else if let mod = modifiers[token] {
                if let prev = pending {
                    out += prev      // implicit short-a, then attach modifier
                    pending = nil
                }
                out += mod
            } else {
                if let prev = pending { out += prev + virama; pending = nil }
                out += token
            }
        }
        if let prev = pending { out += prev + virama }
        return out
    }

    static func tokenize(_ s: String) -> [String] {
        var tokens: [String] = []
        let chars = Array(s)
        var i = 0
        while i < chars.count {
            var matched = false
            let upper = min(maxTokenLen, chars.count - i)
            for length in stride(from: upper, through: 1, by: -1) {
                let candidate = String(chars[i..<(i + length)])
                if allTokens.contains(candidate) {
                    tokens.append(candidate)
                    i += length
                    matched = true
                    break
                }
            }
            if !matched {
                tokens.append(String(chars[i]))
                i += 1
            }
        }
        return tokens
    }

    private func isIASTLetter(_ s: String) -> Bool {
        guard s.count == 1, let c = s.first else { return false }
        guard let lc = String(c).lowercased().first else { return false }
        return IASTToDevanagariTransliterator.iastLowerLetters.contains(lc)
    }
}
