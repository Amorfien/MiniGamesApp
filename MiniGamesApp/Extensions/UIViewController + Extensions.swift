//
//  UIViewController + Extensions.swift
//  MiniGamesApp
//
//  Created by Pavel Grigorev on 16.10.2024.
//

import UIKit

extension UIViewController {

    // Функция для скрытия клавиатуры по нажатию на область вне текстовых полей
    func hideKeyboardWhenTappedAround() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false // Жест не блокирует другие жесты
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true) // Скрываем клавиатуру
    }
}
