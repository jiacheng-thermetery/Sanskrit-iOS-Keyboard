import UIKit

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
            ch("r", alts: ["ṛ", "ṝ"]),
            ch("t", alts: ["ṭ"]),
            ch("y"),
            ch("u", alts: ["ū"]),
            ch("i", alts: ["ī"]),
            ch("o"),
            ch("p"),
        ],
        [
            ch("a", alts: ["ā"]),
            ch("s", alts: ["ś", "ṣ"]),
            ch("d", alts: ["ḍ"]),
            ch("f"),
            ch("g"),
            ch("h", alts: ["ḥ"]),
            ch("j"),
            ch("k"),
            ch("l", alts: ["ḷ", "ḹ"]),
        ],
        [
            shiftKey,
            ch("z"),
            ch("x"),
            ch("c"),
            ch("v"),
            ch("b"),
            ch("n", alts: ["ñ", "ṅ", "ṇ"]),
            ch("m", alts: ["ṃ", "ṁ"]),
            backspaceKey,
        ],
        bottomRow(modeLabel: "123"),
    ]

    // MARK: - Letters (uppercase)

    private static let lettersUpper: [[KeyDefinition]] = [
        [
            ch("Q"),
            ch("W"),
            ch("E"),
            ch("R", alts: ["Ṛ", "Ṝ"]),
            ch("T", alts: ["Ṭ"]),
            ch("Y"),
            ch("U", alts: ["Ū"]),
            ch("I", alts: ["Ī"]),
            ch("O"),
            ch("P"),
        ],
        [
            ch("A", alts: ["Ā"]),
            ch("S", alts: ["Ś", "Ṣ"]),
            ch("D", alts: ["Ḍ"]),
            ch("F"),
            ch("G"),
            ch("H", alts: ["Ḥ"]),
            ch("J"),
            ch("K"),
            ch("L", alts: ["Ḷ", "Ḹ"]),
        ],
        [
            shiftKey,
            ch("Z"),
            ch("X"),
            ch("C"),
            ch("V"),
            ch("B"),
            ch("N", alts: ["Ñ", "Ṅ", "Ṇ"]),
            ch("M", alts: ["Ṃ", "Ṁ"]),
            backspaceKey,
        ],
        bottomRow(modeLabel: "123"),
    ]

    // MARK: - Numbers

    private static let numbers: [[KeyDefinition]] = [
        [
            ch("1"), ch("2"), ch("3"), ch("4"), ch("5"),
            ch("6"), ch("7"), ch("8"), ch("9"), ch("0"),
        ],
        [
            ch("-"), ch("/"), ch(":"), ch(";"), ch("("),
            ch(")"), ch("$"), ch("&"), ch("@"), ch("\""),
        ],
        [
            ch("|", alts: ["।", "॥"]),
            ch("."),
            ch(","),
            ch("?"),
            ch("!"),
            ch("'"),
            ch("*"),
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
