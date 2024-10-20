//
//  SticksTableViewController.swift
//  MiniGamesApp
//
//  Created by Pavel Grigorev on 20.10.2024.
//

import UIKit
import SnapKit

final class SticksTableViewController: UIViewController {

    private var viewModel: SticksViewModelProtocol

    private var safeAreaHeight: CGFloat = 0

    private var selectedCount = 0 {
        didSet {
            okButton.isEnabled = selectedCount != 0
        }
    }

    private var count = 21 {
        didSet {
            sticksTableView.reloadData()
        }
    }

    private lazy var sticksTableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.register(SticksTableViewCell.self, forCellReuseIdentifier: SticksTableViewCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
//        tableView.allowsMultipleSelection = true
        tableView.layer.borderWidth = 0.5
        return tableView
    }()

    private lazy var okButton: UIButton = {
        let button = UIButton(primaryAction: okAction)
        button.setTitle("OK", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .tintColor
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 0.5
        return button
    }()

    private lazy var okAction = UIAction { [weak self] action in
        guard let self else { return }
        viewModel.onButtonTapped?(selectedCount)
    }

    // MARK: - Initialization

    init(viewModel: SticksViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sticks Game Screen"
        view.backgroundColor = .systemBackground

        let restartAction = UIAction { [weak self] _ in
            guard let self else { return }
            viewModel.onRestartTapped?()
            print("Restart")
        }

        let rightButton = UIBarButtonItem(image: .init(systemName: "arrow.clockwise"), primaryAction: restartAction)
        navigationItem.rightBarButtonItem = rightButton

        view.addSubviews(sticksTableView, okButton)

        sticksTableView.snp.makeConstraints {
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(60)
        }
        okButton.snp.makeConstraints {
            $0.top.equalTo(sticksTableView.snp.bottom)
            $0.width.equalTo(250)
        }

        viewModel.viewDidLoad?()

        binding()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.onAppear?()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.viewDidDisappear?()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Вычисляем высоту safe area
        if let windowScene = view.window?.windowScene {
            if let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
                let topPadding = window.safeAreaInsets.top
                let bottomPadding = window.safeAreaInsets.bottom
                safeAreaHeight = view.frame.height - topPadding - bottomPadding
            }
        }

        // Перезагружаем таблицу для применения новой высоты
        sticksTableView.reloadData()
    }

    // MARK: - Binding

    private func binding() {
        
    }
}

extension SticksTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SticksTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? SticksTableViewCell else { return UITableViewCell() }
        return cell
    }
}

extension SticksTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Используем safe area height для вычисления высоты ячейки
        return (safeAreaHeight - 68) / 22
    }
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        UISwipeActionsConfiguration.init(actions: [UIContextualAction(style: .normal, title: nil, handler: { action, view, closure in
            self.count -= 1
            self.selectedCount += 1
        })])
    }
}

private extension SticksTableViewController {}
