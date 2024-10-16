//
//  MainViewModel.swift
//  MiniGamesApp
//
//  Created by Pavel Grigorev on 16.10.2024.
//

import Foundation
import FirebaseFirestore

final class MainViewModel {

    private var count = 21 {
        didSet {
            if count < 3 {
                onDisableSegment?(Array(count...2))
            }
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
            onDataReceived?(count)
        }

        onButtonTapped = { [weak self] num in
            guard let self else { return }
            if count >= num {
                count -= num
                onDataReceived?(count)
            }
        }

        onRestartTapped = { [weak self] in
            guard let self else { return }
            print("Restart")
            count = 21
            onDataReceived?(count)
            onDisableSegment?([])
        }
    }
}
