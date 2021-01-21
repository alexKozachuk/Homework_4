//
//  WeatherForecast.swift
//  Homework_4
//
//  Created by Sasha on 20/01/2021.
//

import Foundation

struct WeatherForecast: Codable {
    let lat, lon: Double
    let daily: [Daily]
}

