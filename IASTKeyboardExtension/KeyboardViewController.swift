import UIKit

final class KeyboardViewController: UIInputViewController {

    private var keyboardView: KeyboardView!
    private var heightConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.clipsToBounds = false

        keyboardView = KeyboardView()
        keyboardView.delegate = self
        keyboardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(keyboardView)
        NSLayoutConstraint.activate([
            keyboardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            keyboardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            keyboardView.topAnchor.constraint(equalTo: view.topAnchor),
            keyboardView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        applyKeyboardHeight()
    }

    private func applyKeyboardHeight() {
        // Pick a height that matches the iOS system keyboard reasonably well across devices.
        // System keyboard portrait is ~216–291pt depending on device; landscape is shorter.
        let isPortrait = view.bounds.height >= view.bounds.width
        let target: CGFloat = isPortrait ? 260 : 200

        if let c = heightConstraint {
            if abs(c.constant - target) > 0.5 { c.constant = target }
            return
        }
        let c = view.heightAnchor.constraint(equalToConstant: target)
        c.priority = .required - 1   // avoid fighting system constraints
        c.isActive = true
        heightConstraint = c
    }
}

extension KeyboardViewController: KeyboardViewDelegate {

    func keyboardView(_ view: KeyboardView, insertText text: String) {
        textDocumentProxy.insertText(text)
    }

    func keyboardViewDeleteBackward(_ view: KeyboardView) {
        textDocumentProxy.deleteBackward()
    }

    func keyboardViewAdvanceToNextInputMode(_ view: KeyboardView) {
        advanceToNextInputMode()
    }
}
