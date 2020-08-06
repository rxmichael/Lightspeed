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
    func didPressPersonDetails(forPerson person: Person)
}

class PeopleListPresenter: PeopleListPresenterType {
    
    private var subscriptions = Set<AnyCancellable>()
    
    func load() {
        fetchInfo()
    }
    
    func fetchInfo() {
        view?.isLoading = true
        Current.apiService.getPeopleAndPlanets()
        .receive(on: RunLoop.main)
//        .timeout(.seconds(5), scheduler: RunLoop.main) { NetworkError.timeout }
        .sink(receiveCompletion: { [weak self] completion in
            self?.view?.isLoading = false
            if case let .failure(error) = completion {
                self?.view?.displayAlert(title: "Error", message: error.localizedDescription, handler: nil)
            }
            }, receiveValue: { [weak self] peopleResponse, planets in
                let sequence = zip(peopleResponse.results, planets)
                self?.view?.cellInfo =  sequence.compactMap { CellInfo(person: $0.0, planet: $0.1) }
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
    
    init(view: PeopleListView) {
        self.view = view
    }
    
    func didPressPersonDetails(forPerson person: Person) {
        delegate?.didPressPersonDetails(person: person)
    }
}
