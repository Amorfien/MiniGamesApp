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

//    private var allPlayers: Bool {
//        !gameState.firstPlayerID.isEmpty && !gameState.secondPlayerID.isEmpty
//    }

    private var isFirstPlayer: Bool? {
        didSet {
            print(isFirstPlayer == true ? "FIRST PLAYER" : "Second player")
        }
    }

    private var gameState = SticksGameModel() {
        didSet {
            guard oldValue != gameState else { return }

            if isFirstPlayer == nil {
                isFirstPlayer = gameState.firstPlayerID.isEmpty
            }

            let count = gameState.sticksCount
            server.playerAction(gameState)
            if count < 3 {
                onDisableSegment?(Array(count...2))
            }
            onCountChanged?(count)
            isYourTurn?(gameState.isFirstPlayerTurn == isFirstPlayer)
        }
    }

//    private var lastCount = 21
//    private var lastIsYourTurn = true

    // Input
    var viewDidLoad: EmptyClosure?
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

        viewDidLoad = { [weak self] in
            guard let self else { return }
            server.readGameState { result in
                switch result {
                case .success(let state):
                    if state.firstPlayerID.isEmpty {
                        self.server.activatePlayer(self.user.uid, isFirstPlayer: true)
                        self.isFirstPlayer = true
                    } else if state.secondPlayerID.isEmpty {
                        self.server.activatePlayer(self.user.uid, isFirstPlayer: false)
                        self.isFirstPlayer = false
                    }
                case .failure:
                    print("Error reading game state")
                }
            }
        }

        onAppear = { [weak self] in
            guard let self else { return }
            print("Did appear")

            server.gameListener { [weak self] state in  // LISTENER
                guard let self else { return }
                if gameState != state {
                    gameState = state
                }
            }

            onCountChanged?(gameState.sticksCount)
            guard let isFirstPlayer else { return }
//            switch(gameState.isFirstPlayerTurn, isFirstPlayer) {
//            case(true, true):
//                isYourTurn?(true)
//            case(true, true):
//                isYourTurn?(true)
//
//            }
            isYourTurn?(gameState.isFirstPlayerTurn == isFirstPlayer)

        }

        onButtonTapped = { [weak self] num in
            guard let self else { return }
            if gameState.sticksCount >= num {
//                gameState.sticksCount -= num
//                gameState.isFirstPlayer = false
                let newValue = gameState.sticksCount - num
                gameState = .init(sticksCount: newValue, isFirstPlayerTurn: !(isFirstPlayer ?? false))
            }
        }

        onRestartTapped = { [weak self] in
            guard let self else { return }
            print("Restart")
            gameState = SticksGameModel()
//            server.playerAction(count)
            onDisableSegment?([])
        }
    }
}
