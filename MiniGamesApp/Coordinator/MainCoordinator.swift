//
//  MainCoordinator.swift
//  MiniGamesApp
//
//  Created by Pavel Grigorev on 19.10.2024.
//

import UIKit
import FirebaseAuth

protocol CoordinatorProtocol: AnyObject {

    var navigationController: UINavigationController { get }

    func start()

    func showSticksScreen(for user: User)
}

final class MainCoordinator: CoordinatorProtocol {

    var navigationController: UINavigationController

    private let authService = AuthService()

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let viewModel = SignInViewModel(authService: authService)
        let firstVC = SignInViewController(viewModel: viewModel)
        viewModel.coordinator = self
        navigationController.pushViewController(firstVC, animated: true)
    }

    func showSticksScreen(for user: User) {
        let vm = SticksViewModel(user: user)
        let vc = SticksTableViewController(viewModel: vm)
//        let vc = SticksViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }
}
