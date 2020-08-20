//
//  ServiceModels.swift
//  Lightspeed-Demo
//
//  Created by Michael Eid on 7/18/20.
//  Copyright © 2020 Michael Eid. All rights reserved.
//

import Foundation

struct PeopleResponse: Codable {
    let count: Int
    let next: String
    let previous: String?
    let results: [Person]
}

struct Person: Codable {
    let name, height, mass, hairColor: String
    let skinColor, eyeColor, birthYear: String
    let gender: Gender
    let homeworld: URL
    let films, species, vehicles, starships: [URL]
    let created, edited: String
    let url: URL
}

extension Person: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(height)
        hasher.combine(mass)
        hasher.combine(hairColor)
        hasher.combine(skinColor)
        hasher.combine(eyeColor)
        hasher.combine(birthYear)
        hasher.combine(name)
        hasher.combine(gender)
        hasher.combine(homeworld)
        hasher.combine(species)
        hasher.combine(vehicles)
        hasher.combine(starships)
        hasher.combine(created)
        hasher.combine(edited)
        hasher.combine(url)
    }
}

enum Gender: String, Codable {
    case female = "female"
    case male = "male"
    case hermaphrodite = "hermaphrodite"
    case none = "none"
    case notAvailable = "n/a"
}

struct Film: Codable {
    var title: String
    var episodeId: Int
    var openingCrawl, director, producer, releaseDate: String
    var characters, planets, starships, vehicles, species: [URL]
    var created, edited: String
    var url: URL
    
    var openingCrawlWordCount: Int {
        return openingCrawl.split { !$0.isLetter }.count
    }
}

struct Planet: Codable {
    let name, rotationPeriod, orbitalPeriod, diameter: String
    let climate, gravity, terrain, surfaceWater: String
    let population: String
    let residents: [URL]
    let films: [URL]
    let created, edited: String
    let url: URL
}

extension Planet: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(rotationPeriod)
        hasher.combine(orbitalPeriod)
        hasher.combine(climate)
        hasher.combine(gravity)
        hasher.combine(terrain)
        hasher.combine(surfaceWater)
        hasher.combine(population)
        hasher.combine(residents)
        hasher.combine(films)
        hasher.combine(created)
        hasher.combine(edited)
        hasher.combine(url)
    }
}

extension Person {
    static let mock = Person(name: "", height: "", mass: "", hairColor: "", skinColor: "", eyeColor: "", birthYear: "", gender: .notAvailable, homeworld: URL(string: "www.google.com")!, films: [], species: [], vehicles: [], starships: [], created: "", edited: "",  url: URL(string: "www.google.com")!)
}
