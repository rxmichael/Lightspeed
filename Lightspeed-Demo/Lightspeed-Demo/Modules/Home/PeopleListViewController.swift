//
//  PeopleListViewController.swift
//  Lightspeed-Demo
//
//  Created by Michael Eid on 7/17/20.
//  Copyright © 2020 Michael Eid. All rights reserved.
//

import UIKit
import Combine

protocol PeopleListViewControllerDelegate: AnyObject {
    func didPressPersonDetails(person: Person)
}

protocol PeopleListView: View {
    var isLoading: Bool { get set }
    var cellInfo: [CellInfo] { get set }
}

enum Section {
  case main
}

struct CellInfo {
    var person: Person
    var planet: Planet
}

extension CellInfo: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(person)
        hasher.combine(planet)
    }
}

class PeopleListViewController: UIViewController, PeopleListView {
    
    let tableView = UITableView()
    let spinner = UIActivityIndicatorView(style: .large)
    let refreshControl = UIRefreshControl()
    
    typealias DataSource                = UITableViewDiffableDataSource<Section, CellInfo>
    typealias Snapshot                  = NSDiffableDataSourceSnapshot<Section, CellInfo>
    
    private var subscriptions: Set<AnyCancellable> = []
    
    private var dataSource: DataSource!
    
    lazy var presenter = PeopleListPresenter(view: self)
    
    var isLoading: Bool = false {
        didSet {
            if isLoading {
                spinner.startAnimating()
            }
            else {
                refreshControl.endRefreshing()
                spinner.stopAnimating()
            }
        }
    }
    
    var cellInfo: [CellInfo] = [] {
        didSet {
            updateTable(with: cellInfo, animated: !cellInfo.isEmpty)
        }
    }
    
    weak var delegate: PeopleListViewControllerDelegate? {
        didSet {
            presenter.delegate = delegate
        }
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)
        view.addSubview(spinner)
        
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = Palette.personCell
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = PersonCell.estimatedHeight()
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = .zero
        tableView.register(PersonCell.self)
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = true
        tableView.contentInsetAdjustmentBehavior = .never
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.backgroundColor = Palette.pullToRefresh
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        refreshControl.publisher(for: .valueChanged)
            .sink { [weak self]  _ in
                self?.refresh()
            }.store(in: &subscriptions)
        
        tableView.refreshControl = refreshControl
        
        createConstraints()
        
        setUpDataSource()
        
        presenter.load()
    }
    
    func createConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            spinner.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
            ])
    }
    
    @objc func refresh() {
        presenter.fetchInfo(refresh: true)
    }
}

extension PeopleListViewController {
    func setUpDataSource() {
        dataSource = DataSource(tableView: tableView) { [weak self] (tableView, indexPath, _) -> UITableViewCell? in
            guard let cellInfoAtRow = self?.cellInfo[indexPath.row] else {
                return UITableViewCell()
            }
            let cell = tableView.dequeueReusableCell(ofType: PersonCell.self, for: indexPath)
            cell.setup(withInfo: cellInfoAtRow)
            return cell
        }
    }
    
    func updateTable(with info: [CellInfo], animated: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(info)
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
}

extension PeopleListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didPressPersonDetails(forPerson: cellInfo[indexPath.row].person)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == cellInfo.count-1 {
            presenter.fetchInfo()
        }
    }
}
