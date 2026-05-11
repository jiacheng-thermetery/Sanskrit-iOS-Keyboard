import UIKit

/// QWERTY layout shared by Velthuis → IAST and Velthuis → Devanāgarī.
///
/// Long-press alternates expose the Velthuis bigrams (e.g. `.r` `.rr`, `~n`,
/// `"s`) as one-tap inserts. You can also type the prefix characters
/// `.` `"` `~` manually from the 123 layer — the transliterator does greedy
/// longest-match either way.
enum KeyboardLayouts {

    static func layout(for mode: KeyboardMode, shifted: Bool) -> [[KeyDefinition]] {
        switch mode {
        case .letters: return shifted ? lettersUpper : lettersLower
        case .numbers: return numbers
        }
    }

    // MARK: - Letters (lowercase)

    private static let lettersLower: [[KeyDefinition]] = [
        [
            ch("q"),
            ch("w"),
            ch("e"),
            ch("r", alts: [".r", ".rr"]),
            ch("t", alts: [".t"]),
            ch("y"),
            ch("u", alts: ["uu"]),
            ch("i", alts: ["ii"]),
            ch("o"),
            ch("p"),
        ],
        [
            ch("a", alts: ["aa"]),
            ch("s", alts: [".s", "\"s"]),
            ch("d", alts: [".d"]),
            ch("f"),
            ch("g"),
            ch("h", alts: [".h"]),
            ch("j"),
            ch("k"),
            ch("l", alts: [".l", ".ll"]),
        ],
        [
            shiftKey,
            ch("z"),
            ch("x"),
            ch("c"),
            ch("v"),
            ch("b"),
            ch("n", alts: [".n", "~n", "\"n"]),
            ch("m", alts: [".m"]),
            backspaceKey,
        ],
        bottomRow(modeLabel: "123"),
    ]

    // MARK: - Letters (uppercase)
    //
    // Velthuis is case-insensitive for the encoded letters — uppercase only
    // affects the rendered Latin character (e.g. proper-noun "Rāma"). The
    // popover alts stay lowercase since that's the canonical Velthuis form.

    private static let lettersUpper: [[KeyDefinition]] = [
        [
            ch("Q"),
            ch("W"),
            ch("E"),
            ch("R", alts: [".r", ".rr"]),
            ch("T", alts: [".t"]),
            ch("Y"),
            ch("U", alts: ["uu"]),
            ch("I", alts: ["ii"]),
            ch("O"),
            ch("P"),
        ],
        [
            ch("A", alts: ["aa"]),
            ch("S", alts: [".s", "\"s"]),
            ch("D", alts: [".d"]),
            ch("F"),
            ch("G"),
            ch("H", alts: [".h"]),
            ch("J"),
            ch("K"),
            ch("L", alts: [".l", ".ll"]),
        ],
        [
            shiftKey,
            ch("Z"),
            ch("X"),
            ch("C"),
            ch("V"),
            ch("B"),
            ch("N", alts: [".n", "~n", "\"n"]),
            ch("M", alts: [".m"]),
            backspaceKey,
        ],
        bottomRow(modeLabel: "123"),
    ]

    // MARK: - Numbers / symbols
    //
    // Surface `.` `"` `~` here so Velthuis can be typed manually when long-press
    // isn't desired (or for sequences the popover doesn't include).

    private static let numbers: [[KeyDefinition]] = [
        ["1","2","3","4","5","6","7","8","9","0"].map { ch($0) },
        ["-","/",":",";","(",")","$","&","@","\""].map { ch($0) },
        [
            ch("."),
            ch("~"),
            ch(","),
            ch("?"),
            ch("!"),
            ch("'"),
            ch("|", alts: ["।", "॥"]),
            backspaceKey,
        ],
        bottomRow(modeLabel: "ABC"),
    ]

    // MARK: - Helpers

    private static func ch(_ s: String, alts: [String] = []) -> KeyDefinition {
        KeyDefinition(kind: .character, primary: s, alternates: alts)
    }

    private static let shiftKey = KeyDefinition(
        kind: .shift, primary: "shift", widthUnits: 1.5, displayLabel: "⇧"
    )

    private static let backspaceKey = KeyDefinition(
        kind: .backspace, primary: "backspace", widthUnits: 1.5, displayLabel: "⌫"
    )

    private static func bottomRow(modeLabel: String) -> [KeyDefinition] {
        [
            KeyDefinition(kind: .modeSwitch, primary: modeLabel,
                          widthUnits: 1.5, displayLabel: modeLabel),
            KeyDefinition(kind: .nextKeyboard, primary: "globe",
                          widthUnits: 1.0, displayLabel: "🌐"),
            KeyDefinition(kind: .space, primary: " ",
                          widthUnits: 5.0, displayLabel: "space"),
            KeyDefinition(kind: .returnKey, primary: "\n",
                          widthUnits: 2.5, displayLabel: "return"),
        ]
    }
}
