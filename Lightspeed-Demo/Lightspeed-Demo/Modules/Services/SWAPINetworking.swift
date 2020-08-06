//
//  SWAPINetworking.swift
//  Lightspeed-Demo
//
//  Created by Michael Eid on 7/18/20.
//  Copyright © 2020 Michael Eid. All rights reserved.
//

import Foundation
import Combine

extension SWAPIService {
    enum NetworkPaths {
        case people
        case peopleWithPage(page: Int)
        case film(id: String)
        
        var path: String {
          switch self {
          case .people, .peopleWithPage: return "/people"
          case .film(let id): return "/film/\(id)"
          }
        }
    }
    
    func getPeopleAndPlanets() -> AnyPublisher<(PeopleResponse,[Planet]), Error> {
        let peoplePublisher = getPeople()
        let planetPublisher = peoplePublisher.flatMap(maxPublishers: .max(1), { self.getPlanetsforPeople(person: $0.results) })
        return Publishers.Zip(peoplePublisher, planetPublisher).eraseToAnyPublisher()
    }
    
    func getPlanetsforPeople(person: [Person]) -> AnyPublisher<[Planet], Error> {
        let publisherOfPublishers = Publishers.Sequence<[AnyPublisher<Planet, Error>], Error>(sequence: person.map { getPlanet(atUrl: $0.homeworld) })
       return publisherOfPublishers.flatMap(maxPublishers: .max(1), { $0 }).collect().eraseToAnyPublisher()
    }
    
    func getPlanet(atUrl url: URL) -> AnyPublisher<Planet, Error> {
        return get(with: url)
    }
    
    func getFilms(atUrl urls: [URL]) -> AnyPublisher<[Film], Error> {
        return get(with: urls)
    }
    
    func contructGetPeopleRequest() throws -> URLRequest {
        return try URLRequest.constructRequest(
                fromComponents: SWAPI
                    .baseURLComponents(endpoint: currentEndpoint)
                    .appending(path: NetworkPaths.people.path))
    }
    
    func getPeoplePublisher() throws -> URLSession.DataTaskPublisher {
        let request = try contructGetPeopleRequest()
        return dataTaskPublisher(for: request)
    }
    
    func getPeople() -> AnyPublisher<PeopleResponse, Error> {
        do {
            return try getPeoplePublisher()
            .mapError { error -> NetworkError in
                return self.errorFromCode(from: error)
            }
            .tryMap { try self.validate($0.data, $0.response) }
            .map { $0.0 }
            .decode(type: PeopleResponse.self, decoder: decoder)
            .eraseToAnyPublisher()
        } catch {
            return Fail(error: error)
            .eraseToAnyPublisher()
        }
    }
}
