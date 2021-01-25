//
//  NetworkService.swift
//  Homework_4
//
//  Created by Sasha on 18/01/2021.
//

import Foundation

enum GetCitiesError: Error {
    case getCitiesError
}

enum GetCityError: Error {
    case simpleError(_ error: Error)
    case errorWithResponse(_ respnse: Response)
}

final class NetworkService {
    
    enum Lang: String {
        case en, ru, ua
    }
    
    enum Units: String {
        case metric, standard, imperial
    }
    
    private let sheme = "https"
    private let host = "api.openweathermap.org"
    private let apiKey = "b710e479e41ce8035985e931be593d5c"
    private var lang: Lang
    private var units: Units
    
    init(lang: Lang = .en, units: Units = .metric) {
        self.lang = lang
        self.units = units
    }
    
    func getCurrentWeather(in city: City,completion: @escaping (Result<CurrentWeather, Error>) -> Void, error: @escaping (Error) -> Void) {
        var components = URLComponents()
        let id = "\(city.id)"
        
        components.scheme = sheme
        components.host = host
        components.path = "/data/2.5/weather"
        components.queryItems = [
            URLQueryItem(name: "id", value: id),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: units.rawValue),
            URLQueryItem(name: "lang", value: lang.rawValue)
        ]
        
        guard let url = components.url else { return }
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data, let currentWeather = try? JSONDecoder().decode(CurrentWeather.self, from: data) {
                DispatchQueue.main.async {
                    completion(.success(currentWeather))
                }
            } else {
                guard let error = error else { return }
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
        
    }
    
    func getCurrentWeather(in cities: [City],completion: @escaping (Result<[CurrentWeather], Error>) -> Void) {
        if cities == [] {
            completion(.success([]))
        }
        
        var components = URLComponents()
        
        let ids = cities.map { "\($0.id)" }.joined(separator: ",")
        components.scheme = sheme
        components.host = host
        components.path = "/data/2.5/group"
        components.queryItems = [
            URLQueryItem(name: "id", value: ids),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: units.rawValue),
            URLQueryItem(name: "lang", value: lang.rawValue)
        ]
        
        
        
        guard let url = components.url else { return }
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data, let listWeather = try? JSONDecoder().decode(ListWeather.self, from: data) {
                DispatchQueue.main.async {
                    completion(.success(listWeather.list))
                }
            } else {
                guard let error = error else { return }
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
        
    }
    
    func getCities(by names: [String], completion: @escaping (Result<[City], GetCitiesError>) -> Void) {
        guard names != [] else {
            return
        }
        
        var cities: [City] = []
        
        names.forEach {
            getCity(by: $0) { result in
                
                switch result {
                case .success(let city):
                    cities.append(city)
                case .failure:
                    DispatchQueue.main.async {
                        completion(.failure(.getCitiesError))
                    }
                }
                
                if cities.count == names.count {
                    DispatchQueue.main.async {
                        completion(.success(cities))
                    }
                }
            }
        }
        
    }
    
    func getCity(by name: String, completion: @escaping (Result<City, GetCityError>) -> Void) {
        var components = URLComponents()
        components.scheme = sheme
        components.host = host
        components.path = "/data/2.5/weather"
        components.queryItems = [
            URLQueryItem(name: "q", value: name),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "lang", value: lang.rawValue)
        ]
        
        guard let url = components.url else { return }
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                if let city = try? JSONDecoder().decode(City.self, from: data) {
                    DispatchQueue.main.async {
                        completion(.success(city))
                    }
                } else if let resp = try? JSONDecoder().decode(Response.self, from: data) {
                    DispatchQueue.main.async {
                        completion(.failure(.errorWithResponse(resp)))
                    }
                }
            } else if let error = error  {
                DispatchQueue.main.async {
                    completion(.failure(.simpleError(error)))
                }
            }
        }.resume()
        
    }
    
    func getForecast(by city: City, completion: @escaping (Result<WeatherForecast, Error>) -> Void) {
        
        var components = URLComponents()
        components.scheme = sheme
        components.host = host
        components.path = "/data/2.5/onecall"
        components.queryItems = [
            URLQueryItem(name: "lat", value: "\(city.coord.lat)"),
            URLQueryItem(name: "lon", value: "\(city.coord.lon)"),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "lang", value: lang.rawValue),
            URLQueryItem(name: "units", value: units.rawValue)
        ]
        
        guard let url = components.url else { return }
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data, let weatherForecast = try? JSONDecoder().decode(WeatherForecast.self, from: data) {
                DispatchQueue.main.async {
                    completion(.success(weatherForecast))
                }
            } else {
                guard let error = error else { return }
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
        
    }
    
}
