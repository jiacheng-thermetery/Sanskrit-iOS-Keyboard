import UIKit

protocol KeyboardViewDelegate: AnyObject {
    func keyboardView(_ view: KeyboardView, insertText text: String)
    func keyboardViewDeleteBackward(_ view: KeyboardView)
    func keyboardViewAdvanceToNextInputMode(_ view: KeyboardView)
}

final class KeyboardView: UIView {

    weak var delegate: KeyboardViewDelegate?

    private var mode: KeyboardMode = .letters
    private var shiftState: ShiftState = .off

    private var keyButtons: [[KeyButton]] = []
    private var popover: PopoverView?
    private weak var popoverOriginKey: KeyButton?

    private let keySpacing: CGFloat = 6
    private let rowSpacing: CGFloat = 9
    private let edgeInset: CGFloat = 4
    private let topInset: CGFloat = 8
    private let bottomInset: CGFloat = 6

    init() {
        super.init(frame: .zero)
        clipsToBounds = false
        backgroundColor = UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(white: 0.13, alpha: 1.0)
                : UIColor(white: 0.82, alpha: 1.0)
        }
        rebuildKeys()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutKeys()
    }

    private func layoutKeys() {
        guard !keyButtons.isEmpty else { return }
        let availableWidth = bounds.width - 2 * edgeInset
        let availableHeight = bounds.height - topInset - bottomInset
        let totalRows = keyButtons.count
        let totalRowSpacing = rowSpacing * CGFloat(totalRows - 1)
        let rowHeight = (availableHeight - totalRowSpacing) / CGFloat(totalRows)

        // Letter rows use a shared unit-width so all letters look the same size.
        // The bottom row (mode/space/return) scales independently to fill width,
        // matching iOS where space/return are wider than letter keys.
        let firstRow = keyButtons[0]
        let firstRowSpacings = keySpacing * CGFloat(max(firstRow.count - 1, 0))
        let firstRowUnits = firstRow.reduce(CGFloat(0)) { $0 + $1.widthUnits }
        guard firstRowUnits > 0 else { return }
        let letterUnitWidth = (availableWidth - firstRowSpacings) / firstRowUnits

        let lastRowIdx = keyButtons.count - 1
        for (rowIdx, row) in keyButtons.enumerated() {
            let totalUnits = row.reduce(CGFloat(0)) { $0 + $1.widthUnits }
            let totalSpacings = keySpacing * CGFloat(max(row.count - 1, 0))
            let unitWidth: CGFloat = (rowIdx == lastRowIdx)
                ? (availableWidth - totalSpacings) / totalUnits
                : letterUnitWidth
            let rowWidth = totalUnits * unitWidth + totalSpacings
            let leadingX = edgeInset + max(0, (availableWidth - rowWidth) / 2)
            let y = topInset + CGFloat(rowIdx) * (rowHeight + rowSpacing)

            var x = leadingX
            for key in row {
                let w = key.widthUnits * unitWidth
                key.frame = CGRect(x: x, y: y, width: w, height: rowHeight)
                x += w + keySpacing
            }
        }

        // Re-anchor popover if it's showing (e.g., after rotation mid-press — rare but cheap)
        if let originKey = popoverOriginKey, let popover = popover {
            let anchorRight = originKey.frame.midX > bounds.width / 2
            popover.frame = popoverFrame(for: originKey,
                                         alternateCount: popover.alternates.count,
                                         anchorRight: anchorRight)
        }
    }

    // MARK: - Key construction

    private func rebuildKeys() {
        keyButtons.flatMap { $0 }.forEach { $0.removeFromSuperview() }
        keyButtons.removeAll()

        let layout = KeyboardLayouts.layout(for: mode, shifted: shiftState != .off)
        for row in layout {
            var rowButtons: [KeyButton] = []
            for def in row {
                let button = KeyButton(definition: def)
                button.delegate = self
                if def.kind == .shift {
                    button.isActive = (shiftState != .off)
                }
                addSubview(button)
                rowButtons.append(button)
            }
            keyButtons.append(rowButtons)
        }
        setNeedsLayout()
    }

    // MARK: - State changes

    private func toggleShift() {
        switch shiftState {
        case .off: shiftState = .on
        case .on: shiftState = .off
        case .capsLock: shiftState = .off
        }
        rebuildKeys()
    }

    private func toggleMode() {
        mode = (mode == .letters) ? .numbers : .letters
        // Reset shift when switching out of letters
        if mode == .numbers { shiftState = .off }
        rebuildKeys()
    }

    private func handleInsertion(_ text: String) {
        delegate?.keyboardView(self, insertText: text)
        if shiftState == .on {
            shiftState = .off
            rebuildKeys()
        }
    }

    // MARK: - Popover

    private func popoverFrame(for key: KeyButton, alternateCount: Int, anchorRight: Bool) -> CGRect {
        let keyFrame = key.frame
        let segWidth = keyFrame.width
        let popWidth = segWidth * CGFloat(alternateCount)
        let popHeight = keyFrame.height * 1.35

        var x = anchorRight ? keyFrame.maxX - popWidth : keyFrame.minX
        let maxX = bounds.width - popWidth - edgeInset
        let minX = edgeInset
        if maxX >= minX {
            x = max(minX, min(maxX, x))
        }
        let y = keyFrame.minY - popHeight - 4
        return CGRect(x: x, y: y, width: popWidth, height: popHeight)
    }

    private func presentPopover(for key: KeyButton, alternates: [String]) {
        dismissPopover(commit: false)
        // Mirror visually for right-side keys so the primary stays under the finger.
        let anchorRight = key.frame.midX > bounds.width / 2
        let displayAlts: [String] = anchorRight ? alternates.reversed() : alternates

        let frame = popoverFrame(for: key, alternateCount: displayAlts.count, anchorRight: anchorRight)
        let segWidth = frame.width / CGFloat(displayAlts.count)
        let initialIdx = max(0, min(displayAlts.count - 1,
                                    Int((key.frame.midX - frame.minX) / segWidth)))
        let view = PopoverView(alternates: displayAlts, initialIndex: initialIdx)
        view.frame = frame
        addSubview(view)
        popover = view
        popoverOriginKey = key
    }

    @discardableResult
    private func dismissPopover(commit: Bool) -> String? {
        guard let popover = popover else { return nil }
        let selected = commit ? popover.selectedAlternate : nil
        popover.removeFromSuperview()
        self.popover = nil
        self.popoverOriginKey = nil
        return selected
    }
}

extension KeyboardView: KeyButtonDelegate {

    func keyButton(_ button: KeyButton, didActivate action: KeyAction) {
        switch action {
        case .insert(let text):
            handleInsertion(text)
        case .backspace:
            delegate?.keyboardViewDeleteBackward(self)
        case .returnKey:
            handleInsertion("\n")
        case .space:
            handleInsertion(" ")
        case .nextKeyboard:
            delegate?.keyboardViewAdvanceToNextInputMode(self)
        case .shift:
            toggleShift()
        case .modeSwitch:
            toggleMode()
        }
    }

    func keyButton(_ button: KeyButton, presentPopoverWith alternates: [String]) {
        presentPopover(for: button, alternates: alternates)
    }

    func keyButton(_ button: KeyButton, updatePopoverHighlightAt pointInKeyboardView: CGPoint) {
        popover?.updateHighlight(forParentSpacePoint: pointInKeyboardView)
    }

    func keyButton(_ button: KeyButton, dismissPopoverCommitting commit: Bool) -> String? {
        return dismissPopover(commit: commit)
    }
}
