//
//  CurrentWeather.swift
//  Homework_4
//
//  Created by Sasha on 19/01/2021.
//

import Foundation

struct CurrentWeather: Codable, Hashable {
    let weather: [Weather]
    let id: Int
    let name: String
    let main: Main
    let wind: Wind
    let clouds: Clouds
}

extension CurrentWeather: CollectionPresentable {
    
    var minMaxTemp: String {
        return "Макс. \(Int(main.tempMax))º, мин. \(Int(main.tempMin))º"
    }
    
    var cityName: String {
        return name
    }
    
    var temp: String {
        return "\(Int(main.temp))º"
    }
    
}

// MARK: - Main
struct Main: Codable, Hashable {
    let temp, feelsLike, tempMin, tempMax: Double
    let pressure, humidity: Int

    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure, humidity
    }
}
