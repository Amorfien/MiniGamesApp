//
//  SignInViewController.swift
//  MiniGamesApp
//
//  Created by Pavel Grigorev on 17.10.2024.
//

import UIKit
import SnapKit

final class SignInViewController: UIViewController {

    private let viewModel: SignInViewModel

    private lazy var signInButton: UIButton = {
        let button = UIButton(primaryAction: signInAction)
        button.setTitle("Sign In", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .tintColor
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 0.5
        return button
    }()

    private lazy var signInAction = UIAction { [weak self] action in
        guard let self else { return }
        viewModel.onSignInTapped?()
    }

    init(viewModel: SignInViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.onAppear?()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(resource: .app)
        view.addSubviews(signInButton)
        signInButton.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(200)
            $0.height.equalTo(50)
        }

        binding()
    }

    private func binding() {

        viewModel.onSuccessSignIn = { [weak self] user in
            guard let self else { return }

        }

        viewModel.onErrorSignIn = { [weak self] error in
            guard let self else { return }
            showErrorAlert(message: error)
        }
    }
}
