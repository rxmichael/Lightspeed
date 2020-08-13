//
//  PeopleListPresenter.swift
//  Lightspeed-Demo
//
//  Created by Michael Eid on 7/17/20.
//  Copyright © 2020 Michael Eid. All rights reserved.
//

import Foundation
import Combine

protocol PeopleListPresenterType: Presenter {
    var cellInfo: [CellInfo] { get set }
    var currentPage: Int { get set }
    func didPressPersonDetails(forPerson person: Person)
}

class PeopleListPresenter: PeopleListPresenterType {
    
    private var subscriptions = Set<AnyCancellable>()
    
    func load() {
        fetchInfo(refresh: true)
    }
    
    func fetchInfo(refresh: Bool = false) {
        view?.isLoading = true
        if refresh {
            currentPage = 1
            cellInfo.removeAll()
        }
        else {
            currentPage += 1
        }
        Current.apiService.getPeopleAndPlanets(withPage: currentPage)
        .receive(on: DispatchQueue.main)

//        .timeout(.seconds(5), scheduler: RunLoop.main) { NetworkError.timeout }
        .sink(receiveCompletion: { [weak self] completion in
            self?.view?.isLoading = false
            if case let .failure(error) = completion {
                self?.view?.displayAlert(title: "Error", message: error.localizedDescription, handler: nil)
            }
            }, receiveValue: { [weak self] peopleResponse, planets in
                let sequence = zip(peopleResponse.results.sorted(by: \.name), planets)
                self?.cellInfo.append(contentsOf: sequence.compactMap { CellInfo(person: $0.0, planet: $0.1) })
        })
        .store(in: &self.subscriptions)
    }
    
    weak var view: PeopleListView?
    weak var delegate: PeopleListViewControllerDelegate?
    
    var cellInfo: [CellInfo] = [] {
        didSet {
            view?.cellInfo = cellInfo
        }
    }
    
    var currentPage: Int = 0
    
    init(view: PeopleListView) {
        self.view = view
    }
    
    func didPressPersonDetails(forPerson person: Person) {
        delegate?.didPressPersonDetails(person: person)
    }
}
