import UIKit

final class KeyboardViewController: UIInputViewController {

    private var keyboardView: KeyboardView!
    private var heightConstraint: NSLayoutConstraint?
    private let transliterator = VelthuisToIASTTransliterator()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.clipsToBounds = false

        keyboardView = KeyboardView(reservesPopoverHeadroom: true)
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
        let isPortrait = view.bounds.height >= view.bounds.width
        let target: CGFloat = isPortrait ? 346 : 275
        if let c = heightConstraint {
            if abs(c.constant - target) > 0.5 { c.constant = target }
            return
        }
        let c = view.heightAnchor.constraint(equalToConstant: target)
        c.priority = .required - 1
        c.isActive = true
        heightConstraint = c
    }

    override func selectionWillChange(_ textInput: UITextInput?) {
        super.selectionWillChange(textInput)
        transliterator.reset()
    }

    private func apply(_ edit: VelthuisToIASTTransliterator.Edit) {
        for _ in 0..<edit.deleteCount {
            textDocumentProxy.deleteBackward()
        }
        if !edit.insert.isEmpty {
            textDocumentProxy.insertText(edit.insert)
        }
    }
}

extension KeyboardViewController: KeyboardViewDelegate {

    func keyboardView(_ view: KeyboardView, insertText text: String) {
        apply(transliterator.process(text))
    }

    func keyboardViewDeleteBackward(_ view: KeyboardView) {
        if let edit = transliterator.processBackspace() {
            apply(edit)
        } else {
            textDocumentProxy.deleteBackward()
        }
    }

    func keyboardViewAdvanceToNextInputMode(_ view: KeyboardView) {
        transliterator.reset()
        advanceToNextInputMode()
    }
}
