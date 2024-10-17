//
//  AuthService.swift
//  MiniGamesApp
//
//  Created by Pavel Grigorev on 17.10.2024.
//

import Foundation
import FirebaseAuth

enum AuthError: Error {
    case unknownError
}

final class AuthService {

    func anonymousSignIn(_ completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signInAnonymously { result, error in
            guard let result, error == nil else {
                completion(.failure(error ?? AuthError.unknownError))
                return
            }
            completion(.success(result.user))
        }
    }

}
