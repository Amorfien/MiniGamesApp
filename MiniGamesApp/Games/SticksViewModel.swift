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
    
    private var gameModel = SticksGameModel() {
        didSet {
            guard oldValue != gameModel else { return }
            
            if isFirstPlayer == nil {
                isFirstPlayer = gameModel.firstPlayerID.isEmpty
            }

            server.playerAction(gameModel)

            if gameModel.firstPlayerID.isEmpty || gameModel.secondPlayerID.isEmpty {
                onStateChange?(.noSecondPlayer)
            } else {
                onStateChange?(.playerTurn(sticksCount: gameModel.sticksCount,
                                           isYourTurn: gameModel.isFirstPlayerTurn == isFirstPlayer))
            }

            if gameModel.sticksCount == 0 {
                onStateChange?(.gameOver(isWinner: gameModel.isFirstPlayerTurn == isFirstPlayer))
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

    // MARK: - Initialization

    init(user: User) {
        self.user = user
        binding()
    }

    // MARK: - Binding

    private func binding() {
        
        viewDidLoad = { [weak self] in
            guard let self else { return }
            server.readGameState { result in
                switch result {
                case .success(let model):
                    if model.firstPlayerID == self.user.uid {
                        self.isFirstPlayer = true
                    } else if model.secondPlayerID == self.user.uid {
                        self.isFirstPlayer = false
                    } else if model.firstPlayerID.isEmpty {
                        self.server.activatePlayer(self.user.uid, isFirstPlayer: true)
                        self.isFirstPlayer = true
                        self.onStateChange?(.noSecondPlayer)
                    } else if model.secondPlayerID.isEmpty {
                        self.server.activatePlayer(self.user.uid, isFirstPlayer: false)
                        self.isFirstPlayer = false
                    }
                    self.gameModel = model
                case .failure(let error):
                    print("Error reading game state")
                    self.onStateChange?(.error(error.localizedDescription))
                }
            }
        }
        
        onAppear = { [weak self] in
            guard let self else { return }

            server.gameListener { [weak self] model in  // LISTENER
                guard let self else { return }
                if gameModel != model {
                    gameModel = model
                }
            }
        }
        
        onButtonTapped = { [weak self] num in
            guard let self else { return }
            if gameModel.sticksCount >= num {
                let newValue = gameModel.sticksCount - num
                gameModel = .init(sticksCount: newValue, isFirstPlayerTurn: !(isFirstPlayer ?? false))
            }
        }
        
        onRestartTapped = { [weak self] in
            guard let self else { return }
            gameModel = SticksGameModel()
        }
        
        viewDidDisappear = { [weak self] in
            guard let self, let isFirstPlayer else { return }
            server.deletePlayer(isFirstPlayer: isFirstPlayer)
        }
    }
}
