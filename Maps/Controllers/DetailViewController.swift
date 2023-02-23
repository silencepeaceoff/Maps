//
//  DetailViewController.swift
//  Maps
//
//  Created by Dmitrii Tikhomirov on 2/23/23.
//

import UIKit

class DetailViewController: UIViewController {

    let place: Places
    private let space: CGFloat = 16.0
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .left
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        return label
    }()
    
    lazy var addressLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.alpha = 0.5
        return label
    }()
    
    var directionButton: UIButton = {
        let config = UIButton.Configuration.bordered()
        let button = UIButton(configuration: config)
        button.setTitle("Direction", for: .normal)
        return button
    }()
    
    var callButton: UIButton = {
        let config = UIButton.Configuration.bordered()
        let button = UIButton(configuration: config)
        button.setTitle("Call", for: .normal)
        return button
    }()
    
    let contactStackView = UIStackView()
    
    init(place: Places) {
        self.place = place
        super.init(nibName: nil, bundle: nil)
        setupUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func directionButtonTapped(_ sender: UIButton) {
        let coordinate = place.location.coordinate
        guard let url = URL(string: "https://maps.apple.com/?daddr=\(coordinate.latitude),\(coordinate.longitude)") else { return }
        UIApplication.shared.open(url)
    }
    
    @objc func callButtonTapped(_ sender: UIButton) {
        guard let url = URL(string: "tel://\(place.phone.formatPhoneNumber)") else { return }
        UIApplication.shared.open(url)
    }
    
    private func setupUI() {
        setupNameLabel()
        setupAddressLabel()
        setupDirectionButton()
        setupCallButton()
        setupContactStackView()
        setupStackView()
    }
    
    private func setupNameLabel() {
        nameLabel.text = place.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.widthAnchor.constraint(equalToConstant: view.bounds.width - space)
        ])
    }
    
    private func setupAddressLabel() {
        addressLabel.text = place.address
    }
    
    private func setupDirectionButton() {
        directionButton.addTarget(self, action: #selector(directionButtonTapped), for: .touchUpInside)
    }
    
    private func setupCallButton() {
        callButton.addTarget(self, action: #selector(callButtonTapped), for: .touchUpInside)
    }
    
    private func setupContactStackView() {
        contactStackView.translatesAutoresizingMaskIntoConstraints = false
        contactStackView.axis = .horizontal
        contactStackView.spacing = UIStackView.spacingUseSystem
        contactStackView.addArrangedSubview(directionButton)
        contactStackView.addArrangedSubview(callButton)
    }
    
    private func setupStackView() {
        let stackView = UIStackView()
        stackView.alignment = .leading
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = UIStackView.spacingUseSystem
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: space, leading: space, bottom: space, trailing: space)
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(addressLabel)
        stackView.addArrangedSubview(contactStackView)
        view.addSubview(stackView)
    }

}
