//
//  SticksServer.swift
//  MiniGamesApp
//
//  Created by Pavel Grigorev on 16.10.2024.
//

import Foundation
import FirebaseFirestore

final class SticksServer {

    func playerAction(_ count: Int) {
        Firestore.firestore()
            .collection(Resources.fbGamesCollection)
            .document(Resources.Games.sticks.rawValue)
            .updateData([Resources.fbSticksCount: count])
    }

    func gameListener(_ completion: @escaping IntClosure) {
        Firestore.firestore()
            .collection(Resources.fbGamesCollection)
            .document(Resources.Games.sticks.rawValue)
            .addSnapshotListener { snapshot, error in
                guard error == nil, let snapshot else { return }

                if let count = snapshot[Resources.fbSticksCount] as? Int {
                    completion(count)
                }
            }
    }

}
