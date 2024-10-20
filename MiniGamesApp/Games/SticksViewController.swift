//
//  MainViewController.swift
//  MiniGamesApp
//
//  Created by Pavel Grigorev on 16.10.2024.
//

import UIKit
import SnapKit

class SticksViewController: UIViewController {

    private var viewModel: SticksViewModelProtocol

    private let countLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 4
        return label
    }()

    private let segmentedControl: UISegmentedControl = {
        let segmented = UISegmentedControl(items: ["1️⃣", "2️⃣", "3️⃣"])
        segmented.selectedSegmentIndex = 0
        return segmented
    }()

    private lazy var okButton: UIButton = {
        let button = UIButton(primaryAction: okAction)
        button.setTitle("OK", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .tintColor
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 0.5
        return button
    }()

    private lazy var restartButton: UIButton = {
        let button = UIButton(primaryAction: restartAction)
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
        let stackView = UIStackView(arrangedSubviews: [
            countLabel,
            segmentedControl,
            okButton,
            restartButton,
            playerLabel
        ])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fill
        return stackView
    }()

    private lazy var okAction = UIAction { [weak self] action in
        guard let self else { return }
        viewModel.onButtonTapped?(segmentedControl.selectedSegmentIndex + 1)
    }

    private lazy var restartAction = UIAction { [weak self] action in
        guard let self else { return }
        viewModel.onRestartTapped?()
    }

    // MARK: - Initialization

    init(viewModel: SticksViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sticks Game Screen"
        view.backgroundColor = .systemBackground
        view.addSubviews(stackView)

        stackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-120)
            $0.width.equalToSuperview().inset(48)
        }

        viewModel.viewDidLoad?()

        binding()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.onAppear?()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.viewDidDisappear?()
    }

    // MARK: - Binding

    private func binding() {

        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                switch state {
                case .noSecondPlayer:
                    countLabel.text = ". . ."
                    playerLabel.text = "Waiting for second player..."
                    playerLabel.textColor  = .label
                    changeInteractive(enabled: false)
                    changeSegmentInteractive(0)
                case .playerTurn(sticksCount: let sticksCount, isYourTurn: let isYourTurn):
                    if sticksCount < 3 {
                        changeSegmentInteractive(3 - sticksCount)
                    } else if sticksCount == 21 {
                        changeSegmentInteractive(0)
                    }
                    countLabel.text = String(repeating: " 🥕 ", count: sticksCount)
                    changeInteractive(enabled: isYourTurn == true)
                    guard let isYourTurn else { changeInteractive(enabled: false); return }
                    playerLabel.text = isYourTurn ? "Your turn" : "Opponent's turn"
                    playerLabel.textColor  = isYourTurn ? .systemGreen : .systemRed
                case .gameOver(isWinner: let isWinner):
                    if let isWinner {
                        playerLabel.text = isWinner ? "You WIN!" : "You Fail!"
                        playerLabel.textColor  = isWinner ? .systemGreen : .systemRed

                        UIView.animate(
                            withDuration: 1,
                            delay: 0.3,
                            usingSpringWithDamping: 0.2,
                            initialSpringVelocity: 0
                        ) {
                            self.stackView.transform = CGAffineTransform(
                                translationX: 0,
                                y: isWinner ? -30 : 150
                            )
                        } completion: { _ in
                            UIView.animate(
                                withDuration: 2,
                                delay: 1,
                                options: .curveEaseInOut
                            ) {
                                self.stackView.transform = .identity
                            }
                        }
                    }
                    countLabel.text = "GAME OVER"
                    changeInteractive(enabled: false)
                    changeSegmentInteractive(0)
                case .error(let error):
                    showErrorAlert(message: error)
                }
            }
        }
    }
}

// MARK: - Private methods

private extension SticksViewController {

    func changeInteractive(enabled: Bool) {
        okButton.isEnabled = enabled
        okButton.alpha = enabled ? 1 : 0.6
        segmentedControl.isEnabled = enabled
    }

    func changeSegmentInteractive(_ count: Int) {
        if count == 0 {
            Array(0...2).forEach {
                segmentedControl.setEnabled(true, forSegmentAt: $0)
            }
        } else {
            Array(4 - (count + 1)...2).forEach {
                segmentedControl.setEnabled(false, forSegmentAt: $0)
            }
        }
        if count > 0 {
            segmentedControl.selectedSegmentIndex = 0
        }
    }
}
