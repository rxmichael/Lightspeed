//
//  PersonDetailViewController.swift
//  Lightspeed-Demo
//
//  Created by Michael Eid on 7/17/20.
//  Copyright © 2020 Michael Eid. All rights reserved.
//

import UIKit

protocol PersonDetailViewControllerDelegate: AnyObject {
    func didPressBack()
}

protocol PersonDetailView: View {
    var isLoading: Bool { get set }
    var person: Person { get set }
    var films: [Film] { get set }
}

class PersonDetailViewController: UIViewController, PersonDetailView {
    
    let tableView = UITableView()
    let spinner = UIActivityIndicatorView(style: .medium)
    
    lazy var presenter = PersonDetailPresenter(view: self)
    
    var isLoading: Bool = false {
        didSet {
            if isLoading {
                spinner.startAnimating()
            }
            else {
                spinner.stopAnimating()
            }
        }
    }
    
    var person: Person = Person.mock {
        didSet {
            tableView.reloadData()
        }
    }
    
    var films: [Film] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    weak var delegate: PersonDetailViewControllerDelegate? {
        didSet {
            presenter.delegate = delegate
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItem.Style.plain, target: self, action: #selector(backButtonTapped))
        self.navigationItem.leftBarButtonItem = newBackButton

        view.addSubview(tableView)
        view.addSubview(spinner)
        
        tableView.tableFooterView = UIView() // Hide extra separators
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = FilmCell.estimatedHeight()
        tableView.estimatedSectionHeaderHeight = PersonHeaderCell.estimatedHeight()
        tableView.sectionHeaderHeight = PersonHeaderCell.estimatedHeight()
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = .zero
        tableView.bounces = false
        tableView.register(FilmCell.self)
        tableView.register(PersonHeaderCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInsetAdjustmentBehavior = .never
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        
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
    
    @objc private func backButtonTapped() {
        delegate?.didPressBack()
    }
}

extension PersonDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return films.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: FilmCell.self, for: indexPath)
        cell.setup(withFilm: films[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(ofType: PersonHeaderCell.self)
        headerView?.setup(withPerson: person)
       
        return headerView
    }
}

extension PersonDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        false
    }
}
