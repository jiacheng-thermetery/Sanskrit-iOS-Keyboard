import UIKit

/// QWERTY layout shared by HK→IAST and HK→Devanāgarī keyboards.
/// No long-press alternates — diacritics are produced by the transliterator
/// (e.g. typing `A` produces `ā` or `आ` depending on the keyboard).
enum KeyboardLayouts {

    static func layout(for mode: KeyboardMode, shifted: Bool) -> [[KeyDefinition]] {
        switch mode {
        case .letters: return shifted ? lettersUpper : lettersLower
        case .numbers: return numbers
        }
    }

    private static let lettersLower: [[KeyDefinition]] = [
        ["q","w","e","r","t","y","u","i","o","p"].map(ch),
        ["a","s","d","f","g","h","j","k","l"].map(ch),
        [shiftKey] + ["z","x","c","v","b","n","m"].map(ch) + [backspaceKey],
        bottomRow(modeLabel: "123"),
    ]

    private static let lettersUpper: [[KeyDefinition]] = [
        ["Q","W","E","R","T","Y","U","I","O","P"].map(ch),
        ["A","S","D","F","G","H","J","K","L"].map(ch),
        [shiftKey] + ["Z","X","C","V","B","N","M"].map(ch) + [backspaceKey],
        bottomRow(modeLabel: "123"),
    ]

    private static let numbers: [[KeyDefinition]] = [
        ["1","2","3","4","5","6","7","8","9","0"].map(ch),
        ["-","/",":",";","(",")","$","&","@","\""].map(ch),
        [
            ch("|"),
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

    private static func ch(_ s: String) -> KeyDefinition {
        KeyDefinition(kind: .character, primary: s)
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
