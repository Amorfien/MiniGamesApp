//
//  MainViewModel.swift
//  MiniGamesApp
//
//  Created by Pavel Grigorev on 16.10.2024.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

enum SticksGameState {
    case noSecondPlayer
    case playerTurn(sticksCount: Int, isYourTurn: Bool?)
    case gameOver(isWinner: Bool?)
    case error(String)
}

protocol SticksViewModelProtocol {
    var viewDidLoad: EmptyClosure? { get }
    var onAppear: EmptyClosure? { get }
    var viewDidDisappear: EmptyClosure? { get }
    var onButtonTapped: IntClosure? { get }
    var onRestartTapped: EmptyClosure? { get }
    var onStateChange: ((SticksGameState) -> Void)? { get set }
}

final class SticksViewModel: SticksViewModelProtocol {
    
    private let user: User
    
    private let server = SticksServer()
    
    private var isFirstPlayer: Bool?
    
    private var gameState = SticksGameModel() {
        didSet {
            guard oldValue != gameState else { return }
            
            if isFirstPlayer == nil {
                isFirstPlayer = gameState.firstPlayerID.isEmpty
            }

            server.playerAction(gameState)

            if gameState.firstPlayerID.isEmpty || gameState.secondPlayerID.isEmpty {
                onStateChange?(.noSecondPlayer)
            } else {
                onStateChange?(.playerTurn(sticksCount: gameState.sticksCount,
                                           isYourTurn: gameState.isFirstPlayerTurn == isFirstPlayer))
            }

            if gameState.sticksCount == 0 {
                onStateChange?(.gameOver(isWinner: gameState.isFirstPlayerTurn == isFirstPlayer))
            }
        }
    }
    
    // Input
    var viewDidLoad: EmptyClosure?
    var onAppear: EmptyClosure?
    var viewDidDisappear: EmptyClosure?
    var onButtonTapped: IntClosure?
    var onRestartTapped: EmptyClosure?
    
    // Output
    var onStateChange: ((SticksGameState) -> Void)?

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
                    if state.firstPlayerID == self.user.uid {
                        self.isFirstPlayer = true
                    } else if state.secondPlayerID == self.user.uid {
                        self.isFirstPlayer = false
                    } else if state.firstPlayerID.isEmpty {
                        self.server.activatePlayer(self.user.uid, isFirstPlayer: true)
                        self.isFirstPlayer = true
                        self.onStateChange?(.noSecondPlayer)
                    } else if state.secondPlayerID.isEmpty {
                        self.server.activatePlayer(self.user.uid, isFirstPlayer: false)
                        self.isFirstPlayer = false
                    }
                case .failure(let error):
                    print("Error reading game state")
                    self.onStateChange?(.error(error.localizedDescription))
                }
            }
        }
        
        onAppear = { [weak self] in
            guard let self else { return }

            server.gameListener { [weak self] state in  // LISTENER
                guard let self else { return }
                if gameState != state {
                    gameState = state
                }
            }
            onStateChange?(.playerTurn(sticksCount: gameState.sticksCount,
                                       isYourTurn: gameState.isFirstPlayerTurn == isFirstPlayer))
        }
        
        onButtonTapped = { [weak self] num in
            guard let self else { return }
            if gameState.sticksCount >= num {
                let newValue = gameState.sticksCount - num
                gameState = .init(sticksCount: newValue, isFirstPlayerTurn: !(isFirstPlayer ?? false))
            }
        }
        
        onRestartTapped = { [weak self] in
            guard let self else { return }
            gameState = SticksGameModel()
        }
        
        viewDidDisappear = { [weak self] in
            guard let self, let isFirstPlayer else { return }
            server.deletePlayer(isFirstPlayer: isFirstPlayer)
        }
    }
}
