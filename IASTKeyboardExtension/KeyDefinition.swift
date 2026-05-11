import UIKit

enum KeyKind {
    case character
    case shift
    case backspace
    case nextKeyboard
    case space
    case returnKey
    case modeSwitch
}

struct KeyDefinition {
    let kind: KeyKind
    let primary: String
    let alternates: [String]
    let widthUnits: CGFloat
    let displayLabel: String?

    init(kind: KeyKind = .character,
         primary: String,
         alternates: [String] = [],
         widthUnits: CGFloat = 1.0,
         displayLabel: String? = nil) {
        self.kind = kind
        self.primary = primary
        self.alternates = alternates
        self.widthUnits = widthUnits
        self.displayLabel = displayLabel
    }

    var label: String { displayLabel ?? primary }
}

enum KeyAction {
    case insert(String)
    case backspace
    case returnKey
    case space
    case nextKeyboard
    case shift
    case modeSwitch
}

enum KeyboardMode {
    case letters
    case numbers
}

enum ShiftState {
    case off
    case on
    case capsLock
}
