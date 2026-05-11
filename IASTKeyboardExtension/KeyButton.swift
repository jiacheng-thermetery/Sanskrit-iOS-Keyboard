import UIKit

protocol KeyButtonDelegate: AnyObject {
    func keyButton(_ button: KeyButton, didActivate action: KeyAction)
    func keyButton(_ button: KeyButton, presentPopoverWith alternates: [String])
    func keyButton(_ button: KeyButton, updatePopoverHighlightAt pointInKeyboardView: CGPoint)
    func keyButton(_ button: KeyButton, dismissPopoverCommitting commit: Bool) -> String?
}

final class KeyButton: UIView {

    let definition: KeyDefinition
    weak var delegate: KeyButtonDelegate?

    var widthUnits: CGFloat { definition.widthUnits }

    var isActive: Bool = false {
        didSet { updateAppearance() }
    }

    private let label = UILabel()
    private var pressed = false { didSet { updateAppearance() } }
    private var popoverShowing = false
    private var longPressTimer: Timer?
    private var backspaceRepeatTimer: Timer?

    init(definition: KeyDefinition) {
        self.definition = definition
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Layout / appearance

    private func setupView() {
        clipsToBounds = false
        layer.cornerRadius = 5
        layer.cornerCurve = .continuous
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 0

        label.text = definition.label
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.6
        label.font = preferredFont()
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])

        isMultipleTouchEnabled = false
        updateAppearance()
    }

    private func preferredFont() -> UIFont {
        switch definition.kind {
        case .character:
            // Slightly smaller for digits & punctuation since they're already compact
            let size: CGFloat = definition.primary.count > 1 ? 16 : 22
            return .systemFont(ofSize: size)
        case .space, .returnKey, .modeSwitch:
            return .systemFont(ofSize: 15)
        case .shift, .backspace, .nextKeyboard:
            return .systemFont(ofSize: 18)
        }
    }

    private func baseBackgroundColor() -> UIColor {
        let isLetterLike = (definition.kind == .character) || definition.kind == .space
        if isLetterLike {
            return UIColor { trait in
                trait.userInterfaceStyle == .dark
                    ? UIColor(white: 0.42, alpha: 1.0)
                    : UIColor.white
            }
        }
        // Special keys (shift, backspace, mode, return, globe)
        return UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(white: 0.27, alpha: 1.0)
                : UIColor(white: 0.72, alpha: 1.0)
        }
    }

    private func pressedBackgroundColor() -> UIColor {
        UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(white: 0.55, alpha: 1.0)
                : UIColor(white: 0.85, alpha: 1.0)
        }
    }

    private func activeBackgroundColor() -> UIColor {
        UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor.white.withAlphaComponent(0.90)
                : UIColor.white
        }
    }

    private func updateAppearance() {
        if pressed {
            backgroundColor = pressedBackgroundColor()
        } else if isActive {
            backgroundColor = activeBackgroundColor()
        } else {
            backgroundColor = baseBackgroundColor()
        }
        label.textColor = (isActive && !pressed) ? .black : .label
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateAppearance()
    }

    // MARK: - Touch handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        pressed = true

        if definition.kind == .backspace {
            delegate?.keyButton(self, didActivate: .backspace)
            scheduleBackspaceRepeat()
        } else if !definition.alternates.isEmpty {
            scheduleLongPress()
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first else { return }
        if popoverShowing, let kbView = superview {
            let p = touch.location(in: kbView)
            delegate?.keyButton(self, updatePopoverHighlightAt: p)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        cancelLongPress()
        cancelBackspaceRepeat()
        pressed = false

        if popoverShowing {
            popoverShowing = false
            if let alt = delegate?.keyButton(self, dismissPopoverCommitting: true), !alt.isEmpty {
                delegate?.keyButton(self, didActivate: .insert(alt))
            }
            return
        }

        if definition.kind == .backspace {
            return  // already fired in touchesBegan
        }

        // Fire if the touch ended within (a forgiving extension of) our bounds
        guard let touch = touches.first else { return }
        let p = touch.location(in: self)
        let hitArea = bounds.insetBy(dx: -8, dy: -8)
        if hitArea.contains(p) {
            fireAction()
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        cancelLongPress()
        cancelBackspaceRepeat()
        pressed = false
        if popoverShowing {
            popoverShowing = false
            _ = delegate?.keyButton(self, dismissPopoverCommitting: false)
        }
    }

    // MARK: - Timers

    private func scheduleLongPress() {
        cancelLongPress()
        longPressTimer = Timer.scheduledTimer(withTimeInterval: 0.40, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.popoverShowing = true
            let allAlts = [self.definition.primary] + self.definition.alternates
            self.delegate?.keyButton(self, presentPopoverWith: allAlts)
        }
    }

    private func cancelLongPress() {
        longPressTimer?.invalidate()
        longPressTimer = nil
    }

    private func scheduleBackspaceRepeat() {
        cancelBackspaceRepeat()
        backspaceRepeatTimer = Timer.scheduledTimer(withTimeInterval: 0.45, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.backspaceRepeatTimer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                self.delegate?.keyButton(self, didActivate: .backspace)
            }
        }
    }

    private func cancelBackspaceRepeat() {
        backspaceRepeatTimer?.invalidate()
        backspaceRepeatTimer = nil
    }

    private func fireAction() {
        switch definition.kind {
        case .character:    delegate?.keyButton(self, didActivate: .insert(definition.primary))
        case .space:        delegate?.keyButton(self, didActivate: .space)
        case .returnKey:    delegate?.keyButton(self, didActivate: .returnKey)
        case .shift:        delegate?.keyButton(self, didActivate: .shift)
        case .nextKeyboard: delegate?.keyButton(self, didActivate: .nextKeyboard)
        case .modeSwitch:   delegate?.keyButton(self, didActivate: .modeSwitch)
        case .backspace:    delegate?.keyButton(self, didActivate: .backspace)
        }
    }
}
