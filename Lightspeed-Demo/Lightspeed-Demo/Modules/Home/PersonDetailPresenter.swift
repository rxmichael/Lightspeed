//
//  PersonDetailPresenter.swift
//  Lightspeed-Demo
//
//  Created by Michael Eid on 7/17/20.
//  Copyright © 2020 Michael Eid. All rights reserved.
//

import Foundation
import Combine

protocol PersonDetailPresenterType: Presenter {
    var person: Person { get set }
    var films: [Film] { get set }
    func didPressBack()
}

class PersonDetailPresenter: PersonDetailPresenterType {
    
    private var subscriptions = Set<AnyCancellable>()
    
    func load() {
        fetchFilmsForUser()
    }
    
    func fetchFilmsForUser() {
        view?.isLoading = true
        Current.apiService.get(with: person.films)
            .receive(on: RunLoop.main)
            .timeout(.seconds(5), scheduler: RunLoop.main) { NetworkError.timeout }
            .sink(receiveCompletion: { [weak self] completion in
                self?.view?.isLoading = false
                if case let .failure(error) = completion {
                    self?.view?.displayAlert(title: "Error", message: error.localizedDescription, handler: nil)
                }
            }, receiveValue: { [weak self] films in
                self?.films = films
            })
            .store(in: &self.subscriptions)
    }
    
    weak var view: PersonDetailView?
    weak var delegate: PersonDetailViewControllerDelegate?
    
    var person: Person = Person.mock {
        didSet {
            view?.person = person
        }
    }
    
    var films: [Film] = [] {
        didSet {
            view?.films = films
        }
    }
    
    init(view: PersonDetailView) {
        self.view = view
    }
    
    func didPressBack() {
        delegate?.didPressBack()
    }
}

