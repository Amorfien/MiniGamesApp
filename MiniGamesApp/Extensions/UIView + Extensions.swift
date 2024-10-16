//
//  UIView + Extensions.swift
//  MiniGamesApp
//
//  Created by Pavel Grigorev on 16.10.2024.
//

import UIKit

extension UIView {

    func addSubviews(_ views: UIView...) {
        views.forEach(addSubview)
    }
}
