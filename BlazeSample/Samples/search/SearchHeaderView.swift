import UIKit
import Combine

///
/// `SearchHeaderView` provides a custom search header matching the SDK's built-in design.
///
/// It consists of a back button, a rounded search container (with search icon, text field,
/// and animated clear button), and a bottom separator line.
///
/// Use `textPublisher` to observe text changes via Combine instead of implementing
/// `UISearchBarDelegate`. Connect `backButton` actions from the owning view controller.
///
final class SearchHeaderView: UIView {

    // MARK: - Subviews

    let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        button.setImage(UIImage(systemName: "chevron.backward", withConfiguration: config), for: .normal)
        button.tintColor = .label
        return button
    }()

    private let searchContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .secondarySystemFill
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()

    private let searchIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .regular)
        imageView.image = UIImage(systemName: "magnifyingglass", withConfiguration: config)
        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .center
        return imageView
    }()

    let searchTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Search"
        textField.returnKeyType = .search
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.borderStyle = .none
        textField.backgroundColor = .clear
        textField.clearButtonMode = .never
        textField.enablesReturnKeyAutomatically = true
        return textField
    }()

    private lazy var clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 13, weight: .regular)
        button.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: config), for: .normal)
        button.tintColor = .secondaryLabel
        button.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        button.isHidden = true
        return button
    }()

    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .separator
        return view
    }()

    // MARK: - Publishers

    /// Emits every text change, including clears triggered by the clear button.
    var textPublisher: AnyPublisher<String, Never> {
        Publishers.Merge(
            NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: searchTextField)
                .compactMap { ($0.object as? UITextField)?.text },
            clearTextSubject
        )
        .eraseToAnyPublisher()
    }

    private let clearTextSubject = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBackground
        setupLayout()
        setupTextObservation()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Methods

    private func setupTextObservation() {
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: searchTextField)
            .compactMap { ($0.object as? UITextField)?.text }
            .sink { [weak self] text in
                self?.updateClearButtonVisibility(text: text)
            }
            .store(in: &cancellables)
    }

    private func updateClearButtonVisibility(text: String) {
        clearButton.isHidden = text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func setupLayout() {
        addSubview(backButton)
        addSubview(searchContainerView)
        searchContainerView.addSubview(searchIconImageView)
        searchContainerView.addSubview(searchTextField)
        searchContainerView.addSubview(clearButton)
        addSubview(separatorView)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 32),
            backButton.heightAnchor.constraint(equalToConstant: 32),

            searchContainerView.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 8),
            searchContainerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            searchContainerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            searchContainerView.heightAnchor.constraint(equalToConstant: 36),

            searchIconImageView.leadingAnchor.constraint(equalTo: searchContainerView.leadingAnchor, constant: 9),
            searchIconImageView.centerYAnchor.constraint(equalTo: searchContainerView.centerYAnchor),
            searchIconImageView.widthAnchor.constraint(equalToConstant: 16),
            searchIconImageView.heightAnchor.constraint(equalToConstant: 16),

            searchTextField.leadingAnchor.constraint(equalTo: searchIconImageView.trailingAnchor, constant: 6),
            searchTextField.trailingAnchor.constraint(equalTo: clearButton.leadingAnchor, constant: -4),
            searchTextField.topAnchor.constraint(equalTo: searchContainerView.topAnchor),
            searchTextField.bottomAnchor.constraint(equalTo: searchContainerView.bottomAnchor),

            clearButton.trailingAnchor.constraint(equalTo: searchContainerView.trailingAnchor, constant: -8),
            clearButton.centerYAnchor.constraint(equalTo: searchContainerView.centerYAnchor),
            clearButton.widthAnchor.constraint(equalToConstant: 18),
            clearButton.heightAnchor.constraint(equalToConstant: 18),

            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }

    @objc private func clearButtonTapped() {
        searchTextField.text = ""
        clearButton.isHidden = true
        clearTextSubject.send("")
    }
}
