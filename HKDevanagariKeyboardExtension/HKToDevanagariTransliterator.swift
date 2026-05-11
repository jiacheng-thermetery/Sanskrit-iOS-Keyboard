import Foundation

/// Live Harvard-Kyoto → Devanāgarī transliterator.
///
/// On every keystroke, re-tokenizes and re-renders the entire pending HK
/// buffer, then the controller diff-applies the result to the proxy
/// (delete previous render, insert new render). Wylie-style live update.
///
/// Devanāgarī rendering is built one akṣara at a time:
///   - bare consonant + virama is shown until a vowel arrives
///   - a vowel attaches the dependent vowel sign to the pending consonant
///     (a → no sign, A → ा, i → ि, …)
///   - another consonant flushes the pending one with virama (conjunct)
///   - M (anusvāra ं) and H (visarga ः) flush with implicit a, then attach
///   - end-of-buffer flushes any pending consonant with virama
final class HKToDevanagariTransliterator {

    // MARK: - Token tables

    /// Independent vowels (used when no consonant is pending).
    private static let independentVowels: [String: String] = [
        "a":   "अ", "A":  "आ",
        "i":   "इ", "I":  "ई",
        "u":   "उ", "U":  "ऊ",
        "R":   "ऋ", "RR": "ॠ",
        "lR":  "ऌ", "lRR":"ॡ",
        "e":   "ए", "ai": "ऐ",
        "o":   "ओ", "au": "औ",
    ]

    /// Dependent vowel signs (used after a consonant). `a` is empty
    /// because Devanāgarī treats short-a as the consonant's implicit vowel.
    private static let vowelSigns: [String: String] = [
        "a":   "",   "A":  "ा",
        "i":   "ि", "I":  "ी",
        "u":   "ु", "U":  "ू",
        "R":   "ृ", "RR": "ॄ",
        "lR":  "ॢ", "lRR":"ॣ",
        "e":   "े", "ai": "ै",
        "o":   "ो", "au": "ौ",
    ]

    private static let consonants: [String: String] = [
        "k":  "क", "kh": "ख", "g":  "ग", "gh": "घ", "G":  "ङ",
        "c":  "च", "ch": "छ", "j":  "ज", "jh": "झ", "J":  "ञ",
        "T":  "ट", "Th": "ठ", "D":  "ड", "Dh": "ढ", "N":  "ण",
        "t":  "त", "th": "थ", "d":  "द", "dh": "ध", "n":  "न",
        "p":  "प", "ph": "फ", "b":  "ब", "bh": "भ", "m":  "म",
        "y":  "य", "r":  "र", "l":  "ल", "v":  "व",
        "z":  "श", "S":  "ष", "s":  "स", "h":  "ह",
    ]

    private static let modifiers: [String: String] = [
        "M": "ं",   // anusvāra
        "H": "ः",   // visarga
    ]

    private static let virama = "\u{094D}"   // ्

    /// Union of all input tokens used by the tokenizer.
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
        if input.isEmpty || !isHKLetter(input) {
            let edit = Edit(deleteCount: 0, insert: input)
            pendingInput = ""
            displayedOutput = ""
            return edit
        }
        let newPending = pendingInput + input
        let newOutput = HKToDevanagariTransliterator.transliterate(newPending)
        // `deleteBackward()` on the proxy removes one Unicode scalar per call,
        // not one grapheme cluster — Devanāgarī aksaras combine consonant+virama
        // (and conjuncts) into a single grapheme, so `String.count` under-deletes.
        let edit = Edit(deleteCount: displayedOutput.unicodeScalars.count, insert: newOutput)
        pendingInput = newPending
        displayedOutput = newOutput
        return edit
    }

    func processBackspace() -> Edit? {
        guard !pendingInput.isEmpty else { return nil }
        let newPending = String(pendingInput.dropLast())
        let newOutput = HKToDevanagariTransliterator.transliterate(newPending)
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
        // The pending consonant is stored as its already-translated Devanāgarī
        // character (so we don't have to re-look-up when flushing).
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
                // Unknown token (e.g. embedded digit) — flush with virama and pass through.
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

    private func isHKLetter(_ s: String) -> Bool {
        guard s.count == 1, let scalar = s.unicodeScalars.first else { return false }
        let v = scalar.value
        return (v >= 0x41 && v <= 0x5A) || (v >= 0x61 && v <= 0x7A)
    }
}
