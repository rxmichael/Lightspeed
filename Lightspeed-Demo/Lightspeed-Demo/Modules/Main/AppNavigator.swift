//
//  Navigator.swift
//  Lightspeed-Demo
//
//  Created by Michael Eid on 7/17/20.
//  Copyright © 2020 Michael Eid. All rights reserved.
//

import UIKit
import UIKit

protocol Navigator {
    func goBack()
    func showPersonList()
    func showPersonDetails(person: Person)
}

class AppNavigator: NSObject, Navigator {
    private let window: UIWindow
    let navigationController: UINavigationController
    
    init(window: UIWindow) {
        self.window = window
        self.navigationController = UINavigationController()
        window.rootViewController = navigationController
        
        navigationController.navigationBar.barTintColor = Palette.navigationBar
        navigationController.navigationBar.tintColor = .black
        navigationController.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
    }
    
    func start() {
        showPersonList()
    }
    
    func showPersonList() {
        let peopleListViewController = PeopleListViewController()
        peopleListViewController.delegate = self
        navigationController.pushViewController(peopleListViewController, animated: true)
        
    }
    
    func showPersonDetails(person: Person) {
        let personDetailViewController = PersonDetailViewController()
        personDetailViewController.delegate = self
        personDetailViewController.presenter.person = person
        navigationController.pushViewController(personDetailViewController, animated: true)
    }
    
    func goBack() {
        navigationController.popViewController(animated: true)
    }
}

extension AppNavigator: PeopleListViewControllerDelegate {
    func didPressPersonDetails(person: Person) {
        showPersonDetails(person: person)
    }
}

extension AppNavigator: PersonDetailViewControllerDelegate {
    func didPressBack() {
        goBack()
    }
}
