//
//  MainViewController.swift
//  MiniGamesApp
//
//  Created by Pavel Grigorev on 16.10.2024.
//

import UIKit
import SnapKit

class SticksViewController: UIViewController {

    private let viewModel: SticksViewModel

    private let countLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 3
        return label
    }()

    private let segmentedControl: UISegmentedControl = {
        let segmented = UISegmentedControl(items: ["1️⃣", "2️⃣", "3️⃣"])
        segmented.selectedSegmentIndex = 0
        return segmented
    }()

    private lazy var okButton: UIButton = {
        let button = UIButton(type: .roundedRect, primaryAction: UIAction.init(handler: { [weak self] action in
            guard let self else { return }
            let choise = segmentedControl.selectedSegmentIndex + 1
            if choise > 0 {
                viewModel.onButtonTapped?(choise)
            }
        }))
        button.setTitle("OK", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .tintColor
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 0.5
        return button
    }()

    private lazy var restartButton: UIButton = {
        let button = UIButton(type: .roundedRect, primaryAction: UIAction.init(handler: { [weak self] action in
            guard let self else { return }
            viewModel.onRestartTapped?()
        }))
        button.setTitle("Restart", for: .normal)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 0.5
        return button
    }()

    private lazy var playerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [countLabel, segmentedControl, okButton, restartButton, playerLabel])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fill
        return stackView
    }()

    init(viewModel: SticksViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Main Screen"
        view.backgroundColor = .systemBackground
        view.addSubviews(stackView)

        stackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-100)
            $0.width.equalToSuperview().inset(48)
        }

        viewModel.viewDidLoad?()

        binding()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.onAppear?()
    }

    private func binding() {

        viewModel.isYourTurn = { [weak self] isYourTurn in
            guard let self else { return }
            DispatchQueue.main.async {
                self.playerLabel.text = isYourTurn ? "Your turn" : "Opponent's turn"
                self.playerLabel.textColor  = isYourTurn ? .systemGreen : .systemRed
                self.okButton.isEnabled = isYourTurn
                self.okButton.alpha = isYourTurn ? 1 : 0.6
                self.segmentedControl.isEnabled = isYourTurn
            }
        }

        viewModel.onCountChanged = { [weak self] count in
            guard let self else { return }
            let text = count > 0 ? String(repeating: " 🥕 ", count: count) : "GAME OVER"
            DispatchQueue.main.async {
                self.countLabel.text = text
            }
        }

        viewModel.onDisableSegment = { [weak self] arr in
            guard let self else { return }
            print("@", arr)
            DispatchQueue.main.async {
                if arr.isEmpty {
                    Array(0...2).forEach {
                        self.segmentedControl.setEnabled(true, forSegmentAt: $0)
                    }
                } else {
                    arr.forEach {
                        self.segmentedControl.setEnabled(false, forSegmentAt: $0)
                    }
                    switch arr.count {
                    case 1:
                        self.segmentedControl.selectedSegmentIndex = 1
                    case 2:
                        self.segmentedControl.selectedSegmentIndex = 0
                    default: ()
                    }
                }
            }
        }
    }

}

