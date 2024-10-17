//
//  SticksServer.swift
//  MiniGamesApp
//
//  Created by Pavel Grigorev on 16.10.2024.
//

import Foundation
import FirebaseFirestore

final class SticksServer {

    func readGameState(_ completion: @escaping (Result<SticksGameModel, Error>) -> Void) {
        Firestore.firestore()
            .collection(Resources.fbGamesCollection)
            .document(Resources.Games.sticks.rawValue)
            .getDocument() { snapshot, error in
                guard error == nil, let snapshot else {
                    print("ALARM!!! ", error?.localizedDescription ?? "")
                    return
                }

                if
                    let count = snapshot[Resources.fbSticksCount] as? Int,
                    let isFirstPlayerTurn = snapshot[Resources.fbPlayerTurn] as? Bool,
                    let firstPlayerID = snapshot[Resources.firstPlayerID] as? String,
                    let secondPlayerID = snapshot[Resources.secondPlayerID] as? String
                {
                    let state = SticksGameModel(
                        sticksCount: count,
                        isFirstPlayerTurn: isFirstPlayerTurn,
                        firstPlayerID: firstPlayerID,
                        secondPlayerID: secondPlayerID
                    )
                    print("WoW ", state.sticksCount, " ", state.isFirstPlayerTurn)
                    completion(.success(state))
                }
            }
    }

    func activatePlayer(_ player: String, isFirstPlayer: Bool) {
        Firestore.firestore()
            .collection(Resources.fbGamesCollection)
            .document(Resources.Games.sticks.rawValue)
            .updateData([
                isFirstPlayer ? Resources.firstPlayerID : Resources.secondPlayerID: player
            ]) { err in
                print("Register ", player, " ", isFirstPlayer ? "1st" : "2nd")
            }
    }

    func playerAction(_ state: SticksGameModel) {
        Firestore.firestore()
            .collection(Resources.fbGamesCollection)
            .document(Resources.Games.sticks.rawValue)
            .updateData([
                Resources.fbSticksCount: state.sticksCount,
                Resources.fbPlayerTurn: state.isFirstPlayerTurn
            ]) { err in
                print("UPDATE ", state.sticksCount, " ", state.isFirstPlayerTurn, " error: ", err?.localizedDescription ?? "")
            }
    }

    func gameListener(_ completion: @escaping (SticksGameModel) -> Void) {
        Firestore.firestore()
            .collection(Resources.fbGamesCollection)
            .document(Resources.Games.sticks.rawValue)
            .addSnapshotListener(includeMetadataChanges: false) { snapshot, error in
                guard error == nil, let snapshot else {
                    print("ALARM!!! ", error?.localizedDescription ?? "")
                    return
                }

                if
                    let count = snapshot[Resources.fbSticksCount] as? Int,
                    let isFirstPlayerTurn = snapshot[Resources.fbPlayerTurn] as? Bool,
                    let firstPlayerID = snapshot[Resources.firstPlayerID] as? String,
                    let secondPlayerID = snapshot[Resources.secondPlayerID] as? String
                {
                    let state = SticksGameModel(
                        sticksCount: count,
                        isFirstPlayerTurn: isFirstPlayerTurn,
                        firstPlayerID: firstPlayerID,
                        secondPlayerID: secondPlayerID
                    )
                    print("WoW ", state.sticksCount, " ", state.isFirstPlayerTurn)
                    completion(state)
                }
            }
    }

}
