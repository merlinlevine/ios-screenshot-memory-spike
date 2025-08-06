import UIKit


class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addCenterPinnedSubview(createButton(layer: 1))
    }
}


class PresentedContainerVC: UIViewController {
    lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins = .init(top: 16, leading: 16, bottom: 0, trailing: 16)
        stack.spacing = 8
        return stack
    }()

    lazy var spacer: UIView = {
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacer.setContentHuggingPriority(.defaultLow, for: .vertical)
        return spacer
    }()

    let layer: Int

    init(_ layer: Int) {
        self.layer = layer
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            primaryAction: UIAction(handler: { [weak self] _ in
                guard let self else { return }
                dismiss(animated: true)
            })
        )
        title = "Layer \(layer)"

        view.backgroundColor = .systemBackground
        view.addFilledSubview(stack, respectSafeArea: true)
        stack.addArrangedSubview(createButton(layer: layer + 1))

        // MARK: - Adjust branch or level to manipluate view tree structure
        constructTree(branch: 5, level: 5)
        stack.addArrangedSubview(spacer)
    }

    func constructTree(branch: Int, level: Int) {
        (0..<branch).forEach { _ in
            nest(level)
        }
    }

    func nest(_ level: Int) {
        let root = LabelContainerVC()
        var leaf = root

        (0..<level).forEach { _ in
            let next = LabelContainerVC()
            leaf.embed(next)
            leaf = next
        }

        root.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(root)
        stack.addArrangedSubview(root.view)
        root.didMove(toParent: self)
    }

    override func didReceiveMemoryWarning() {
        print("didReceiveMemoryWarning on presentatoin layer: \(layer)")
    }
}


class LabelContainerVC: UIViewController {
    lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 2
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins = .init(top: 0, leading: 8, bottom: 0, trailing: 0)
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGreen
        view.addFilledSubview(stack)
        embed(LabelVC())
    }

    func embed(_ child: UIViewController) {
        child.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(child)
        stack.addArrangedSubview(child.view)
        child.didMove(toParent: self)
    }
}


class LabelVC: UIViewController {
    lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Sample text"
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addFilledSubview(label)
    }
}


extension UIView {
    func addFilledSubview(_ subview: UIView, respectSafeArea: Bool = false) {
        addSubview(subview)

        NSLayoutConstraint.activate([
            subview.leadingAnchor.constraint(equalTo: respectSafeArea ? safeAreaLayoutGuide.leadingAnchor : leadingAnchor),
            subview.trailingAnchor.constraint(equalTo: respectSafeArea ? safeAreaLayoutGuide.trailingAnchor: trailingAnchor),
            subview.topAnchor.constraint(equalTo: respectSafeArea ? safeAreaLayoutGuide.topAnchor : topAnchor),
            subview.bottomAnchor.constraint(equalTo: respectSafeArea ? safeAreaLayoutGuide.bottomAnchor : bottomAnchor)
        ])
    }

    func addCenterPinnedSubview(_ subview: UIView) {
        addSubview(subview)

        NSLayoutConstraint.activate([
            subview.centerXAnchor.constraint(equalTo: centerXAnchor),
            subview.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}


extension UIViewController {
    func createButton(layer: Int) -> UIButton {
        let action = UIAction(title: "Present") { [weak self] _ in
            guard let self else { return }
            let presented = UINavigationController(rootViewController: PresentedContainerVC(layer))
            presented.modalPresentationStyle = .fullScreen
            present(presented, animated: true)
        }
        let button = UIButton(configuration: .filled(), primaryAction: action)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return button
    }
}
