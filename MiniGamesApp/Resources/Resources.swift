//
//  Resources.swift
//  MiniGamesApp
//
//  Created by Pavel Grigorev on 16.10.2024.
//

import Foundation

enum Resources {

    enum Games: String {
        case sticks
    }

    static let fbGamesCollection = "games"
    
    static let fbSticksCount = "count"
    static let fbPlayerTurn = "isFirstPlayerTurn"
    static let firstPlayerID = "firstPlayerID"
    static let secondPlayerID = "secondPlayerID"
}
