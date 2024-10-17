//
//  SticksGameModel.swift
//  MiniGamesApp
//
//  Created by Pavel Grigorev on 17.10.2024.
//

import Foundation

struct SticksGameModel: Equatable, Decodable {
    var sticksCount: Int = 21
    var isFirstPlayerTurn: Bool = true
    var firstPlayerID: String = ""
    var secondPlayerID: String = ""
}
