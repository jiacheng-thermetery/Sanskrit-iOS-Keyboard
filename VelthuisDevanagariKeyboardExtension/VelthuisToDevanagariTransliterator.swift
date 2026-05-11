import Foundation

/// Live Velthuis → Devanāgarī transliterator.
///
/// Same syllable-composer model as `HKToDevanagariTransliterator`: greedy
/// longest-match tokenization, then build akṣaras one at a time —
///   - bare consonant + virama until a vowel arrives
///   - a vowel attaches the dependent vowel sign to the pending consonant
///   - another consonant flushes the pending one with virama (conjunct)
///   - `.m` (anusvāra) and `.h` (visarga) flush with implicit a, then attach
///   - end-of-buffer flushes any pending consonant with virama
///
/// Input is case-folded — Velthuis treats case as cosmetic, and Devanāgarī
/// has no case anyway.
final class VelthuisToDevanagariTransliterator {

    // MARK: - Token tables

    /// Independent vowels (no consonant pending).
    private static let independentVowels: [String: String] = [
        "a":   "अ", "aa":  "आ",
        "i":   "इ", "ii":  "ई",
        "u":   "उ", "uu":  "ऊ",
        ".r":  "ऋ", ".rr": "ॠ",
        ".l":  "ऌ", ".ll": "ॡ",
        "e":   "ए", "ai":  "ऐ",
        "o":   "ओ", "au":  "औ",
    ]

    /// Dependent vowel signs (after a consonant). `a` is empty — short-a is
    /// the consonant's implicit vowel.
    private static let vowelSigns: [String: String] = [
        "a":   "",   "aa":  "ा",
        "i":   "ि", "ii":  "ी",
        "u":   "ु", "uu":  "ू",
        ".r":  "ृ", ".rr": "ॄ",
        ".l":  "ॢ", ".ll": "ॣ",
        "e":   "े", "ai":  "ै",
        "o":   "ो", "au":  "ौ",
    ]

    private static let consonants: [String: String] = [
        "k":   "क", "kh":  "ख", "g":   "ग", "gh":  "घ", "\"n": "ङ",
        "c":   "च", "ch":  "छ", "j":   "ज", "jh":  "झ", "~n":  "ञ",
        ".t":  "ट", ".th": "ठ", ".d":  "ड", ".dh": "ढ", ".n":  "ण",
        "t":   "त", "th":  "थ", "d":   "द", "dh":  "ध", "n":   "न",
        "p":   "प", "ph":  "फ", "b":   "ब", "bh":  "भ", "m":   "म",
        "y":   "य", "r":   "र", "l":   "ल", "v":   "व",
        "\"s": "श", ".s":  "ष", "s":   "स", "h":   "ह",
    ]

    private static let modifiers: [String: String] = [
        ".m": "ं",   // anusvāra
        ".h": "ः",   // visarga
    ]

    private static let virama = "\u{094D}"

    private static let allTokens: Set<String> = {
        var s = Set<String>()
        s.formUnion(independentVowels.keys)
        s.formUnion(consonants.keys)
        s.formUnion(modifiers.keys)
        return s
    }()

    private static let maxTokenLen: Int = allTokens.map(\.count).max() ?? 0

    // MARK: - Live state

    private(set) var pendingInput: String = ""
    private(set) var displayedOutput: String = ""

    struct Edit {
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
        let newOutput = VelthuisToDevanagariTransliterator.transliterate(newPending)
        let edit = Edit(deleteCount: displayedOutput.unicodeScalars.count, insert: newOutput)
        pendingInput = newPending
        displayedOutput = newOutput
        return edit
    }

    func processBackspace() -> Edit? {
        guard !pendingInput.isEmpty else { return nil }
        let newPending = String(pendingInput.dropLast())
        let newOutput = VelthuisToDevanagariTransliterator.transliterate(newPending)
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

    /// ASCII letters plus the three Velthuis prefix marks `.` `"` `~` belong
    /// to the buffer. Multi-character inputs are allowed (popover-committed
    /// bigrams like `.r`, `~n` come in as one insert).
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
