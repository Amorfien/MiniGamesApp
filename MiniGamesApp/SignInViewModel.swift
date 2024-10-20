//
//  SignInViewModel.swift
//  MiniGamesApp
//
//  Created by Pavel Grigorev on 17.10.2024.
//

import Foundation
import FirebaseAuth

protocol SignInViewModelProtocol {

    var onAppear: EmptyClosure? { get }
    var onSignInTapped: EmptyClosure? { get }
    var onSignInResult: ((Result<User, Error>) -> Void)? { get set }
}

final class SignInViewModel: SignInViewModelProtocol {

    weak var coordinator: CoordinatorProtocol?

    private let authService: AuthServiceProtocol

    // Input
    var onAppear: EmptyClosure?
    var onSignInTapped: EmptyClosure?

    // Output
    var onSignInResult: ((Result<User, Error>) -> Void)?

    // MARK: - Initialization
    
    init(authService: AuthServiceProtocol) {
        self.authService = authService
        binding()
    }

    // MARK: - Binding

    private func binding() {

        onAppear = { [weak self] in
            guard let self else { return }
            print("Did appear")
        }

        onSignInTapped = { [weak self]  in
            guard let self else { return }

            authService.anonymousSignIn { result in
                switch result {
                case .success(let user):
                    self.onSignInResult?(.success(user))
                    print("SUCCESS SignIn ", user.uid)

                    self.coordinator?.showSticksScreen(for: user)

                case .failure(let error):
                    self.onSignInResult?(.failure(error))
                    print("ERROR SignIn ", error.localizedDescription)
                }
            }
        }
    }
}
