//
//  MainViewModel.swift
//  MiniGamesApp
//
//  Created by Pavel Grigorev on 16.10.2024.
//

import Foundation
import FirebaseFirestore

final class MainViewModel {

    private let server = SticksServer()

    private var count = 21 {
        didSet {
            server.playerAction(count)
            if count < 3 {
                onDisableSegment?(Array(count...2))
            }
            onDataReceived?(count)
        }
    }

    // Input
    var onAppear: EmptyClosure?
    var onButtonTapped: ((Int) -> Void)?
    var onRestartTapped: EmptyClosure?

    // Output
    var onDataReceived: ((Int) -> Void)?
    var onDisableSegment: (([Int]) -> Void)?

    init() {
        binding()
    }

    private func binding() {

        onAppear = { [weak self] in
            guard let self else { return }
            print("Did appear")
            server.gameListener { [weak self] count in
                if self?.count != count {
                    self?.count = count
                }
            }
        }

        onButtonTapped = { [weak self] num in
            guard let self else { return }
            if count >= num {
                count -= num
//                server.playerAction(count)
            }
        }

        onRestartTapped = { [weak self] in
            guard let self else { return }
            print("Restart")
            count = 21
//            server.playerAction(count)
            onDisableSegment?([])
        }
    }
}
