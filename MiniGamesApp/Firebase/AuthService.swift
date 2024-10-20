//
//  AuthService.swift
//  MiniGamesApp
//
//  Created by Pavel Grigorev on 17.10.2024.
//

import Foundation
import FirebaseAuth

protocol AuthServiceProtocol {

    func anonymousSignIn(_ completion: @escaping (Result<User, Error>) -> Void)
}

enum AuthError: Error {
    case unknownError
}

final class AuthService: AuthServiceProtocol {

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
