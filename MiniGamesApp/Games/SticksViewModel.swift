//
//  MainViewModel.swift
//  MiniGamesApp
//
//  Created by Pavel Grigorev on 16.10.2024.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

final class SticksViewModel {

    private let user: User

    private let server = SticksServer()

    private var isFirstPlayer: Bool?

    private var gameState = SticksGameState() {
        didSet {
            guard oldValue != gameState else { return }
            if isFirstPlayer == nil {
                isFirstPlayer = !gameState.secondPlayerExists
            }
            let count = gameState.sticksCount
            server.playerAction(gameState)
            if count < 3 {
                onDisableSegment?(Array(count...2))
            }
            onCountChanged?(count)
            isYourTurn?(gameState.isFirstPlayerTurn)
        }
    }

    private var lastCount = 21
    private var lastIsYourTurn = true

    // Input
    var onAppear: EmptyClosure?
    var onButtonTapped: ((Int) -> Void)?
    var onRestartTapped: EmptyClosure?

    // Output
    var isYourTurn: ((Bool) -> Void)?
    var onCountChanged: ((Int) -> Void)?
    var onDisableSegment: (([Int]) -> Void)?

    init(user: User) {
        self.user = user
        binding()
    }

    private func binding() {

        onAppear = { [weak self] in
            guard let self else { return }
            print("Did appear")
            server.gameListener { [weak self] state in
                guard let self else { return }
                if gameState != state {
                    gameState = state
                }
            }
            onCountChanged?(gameState.sticksCount)
            isYourTurn?(gameState.isFirstPlayerTurn)
        }

        onButtonTapped = { [weak self] num in
            guard let self else { return }
            if gameState.sticksCount >= num {
//                gameState.sticksCount -= num
//                gameState.isFirstPlayer = false
                let newValue = gameState.sticksCount - num
                gameState = .init(sticksCount: newValue, isFirstPlayerTurn: false)
            }
        }

        onRestartTapped = { [weak self] in
            guard let self else { return }
            print("Restart")
            gameState = SticksGameState()
//            server.playerAction(count)
            onDisableSegment?([])
        }
    }
}
