//
//  SticksTableViewCell.swift
//  MiniGamesApp
//
//  Created by Pavel Grigorev on 20.10.2024.
//

import UIKit

final class SticksTableViewCell: UITableViewCell {

    static let reuseIdentifier = "SticksTableViewCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .systemBrown
        layer.borderWidth = 2
        layer.borderColor = UIColor.systemBackground.cgColor
        layer.cornerRadius = 5
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
