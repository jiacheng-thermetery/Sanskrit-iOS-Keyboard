import UIKit

final class PopoverView: UIView {

    let alternates: [String]
    private(set) var highlightedIndex: Int = 0
    private var labels: [UILabel] = []

    init(alternates: [String], initialIndex: Int) {
        self.alternates = alternates
        self.highlightedIndex = max(0, min(alternates.count - 1, initialIndex))
        super.init(frame: .zero)
        clipsToBounds = false
        backgroundColor = UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(white: 0.30, alpha: 1.0)
                : UIColor(white: 0.98, alpha: 1.0)
        }
        layer.cornerRadius = 8
        layer.cornerCurve = .continuous
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.18
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 6

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        for alt in alternates {
            let container = UIView()
            container.backgroundColor = .clear
            let label = UILabel()
            label.text = alt
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 26)
            label.textColor = .label
            label.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(label)
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            ])
            container.layer.cornerRadius = 6
            container.layer.cornerCurve = .continuous
            labels.append(label)
            stack.addArrangedSubview(container)
        }

        applyHighlight()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func updateHighlight(forParentSpacePoint point: CGPoint) {
        guard !alternates.isEmpty else { return }
        let local = convert(point, from: superview)
        let segmentWidth = bounds.width / CGFloat(alternates.count)
        let raw = Int(local.x / segmentWidth)
        let clamped = max(0, min(alternates.count - 1, raw))
        if clamped != highlightedIndex {
            highlightedIndex = clamped
            applyHighlight()
        }
    }

    var selectedAlternate: String {
        guard alternates.indices.contains(highlightedIndex) else { return alternates.first ?? "" }
        return alternates[highlightedIndex]
    }

    private func applyHighlight() {
        for (i, label) in labels.enumerated() {
            let isOn = i == highlightedIndex
            label.superview?.backgroundColor = isOn ? .systemBlue : .clear
            label.textColor = isOn ? .white : .label
        }
    }
}
