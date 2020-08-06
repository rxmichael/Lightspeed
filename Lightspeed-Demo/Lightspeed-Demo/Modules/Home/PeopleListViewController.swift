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

struct CellInfo {
    var person: Person
    var planet: Planet
}

class PeopleListViewController: UIViewController, PeopleListView {
    
    let tableView = UITableView()
    let spinner = UIActivityIndicatorView(style: .medium)
    let refreshControl = UIRefreshControl()
    
     private var subscriptions: Set<AnyCancellable> = []
    
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
            tableView.reloadData()
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
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = PersonCell.estimatedHeight()
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = .zero
        tableView.register(PersonCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = false
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
        presenter.fetchInfo()
    }
}

extension PeopleListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: PersonCell.self, for: indexPath)
        cell.setup(withInfo: cellInfo[indexPath.row])
        return cell
    }
}

extension PeopleListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didPressPersonDetails(forPerson: cellInfo[indexPath.row].person)
    }
}
