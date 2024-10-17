//
//  SignInViewModel.swift
//  MiniGamesApp
//
//  Created by Pavel Grigorev on 17.10.2024.
//

import Foundation
import FirebaseAuth

final class SignInViewModel {

    private let authService = AuthService()

    // Input
    var onAppear: EmptyClosure?
    var onSignInTapped: EmptyClosure?

    // Output
    var onSuccessSignIn: ((User) -> Void)?
    var onErrorSignIn: ((String) -> Void)?

    init() {
        binding()
    }

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
                    self.onSuccessSignIn?(user)
                    print("SUCCESS SignIn ", user.uid)
                case .failure(let failure):
                    self.onErrorSignIn?(failure.localizedDescription)
                    print("ERROR SignIn ", failure.localizedDescription)
                }
            }
        }

    }
}
