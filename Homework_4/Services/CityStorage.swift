//
//  CityStorage.swift
//  Homework_4
//
//  Created by Sasha on 19/01/2021.
//

import Foundation

final class CityStorage {
    
    private let userDefaults = UserDefaults.standard
    private let key = "CityStorageKey"
    
    func getCities() -> [City] {
        guard let encodedData = UserDefaults.standard.array(forKey: key) as? [Data] else {
            return []
        }
        
        return encodedData.map { try! JSONDecoder().decode(City.self, from: $0) }
    }
    
    func getCity(by id: Int) -> City? {
        let cities = getCities()
        return cities.first { $0.id == id }
    }
    
    func save(_ cities: [City]) {
        let data = cities.map { try? JSONEncoder().encode($0) }
        UserDefaults.standard.set(data, forKey: key)
    }
    
    func append(_ city: City) {
        guard getCity(by: city.id) == nil else { return }
        var cities = getCities()
        cities.append(city)
        save(cities)
    }
    
    func delete(city: City) {
        var cities = getCities()
        cities.removeAll { $0.id == city.id }
        save(cities)
    }
    
}
