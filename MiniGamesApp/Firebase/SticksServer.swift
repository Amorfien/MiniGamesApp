//
//  SticksServer.swift
//  MiniGamesApp
//
//  Created by Pavel Grigorev on 16.10.2024.
//

import Foundation
import FirebaseFirestore

struct SticksGameState: Equatable {
    var sticksCount: Int = 21
    var isFirstPlayerTurn: Bool = true
    var firstPlayerExists = false
    var secondPlayerExists = false
}

final class SticksServer {

    func playerAction(_ state: SticksGameState) {
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

    func gameListener(_ completion: @escaping (SticksGameState) -> Void) {
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
                    let firstPlayerExists = snapshot[Resources.firstPlayerExists] as? Bool,
                    let secondPlayerExists = snapshot[Resources.secondPlayerExists] as? Bool
                {
                    let state = SticksGameState(sticksCount: count, isFirstPlayerTurn: isFirstPlayerTurn, firstPlayerExists: firstPlayerExists, secondPlayerExists: secondPlayerExists)
                    print("WoW ", state.sticksCount, " ", state.isFirstPlayerTurn)
                    completion(state)
                }
            }
    }

}
