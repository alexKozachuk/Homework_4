//
//  ListWeather.swift
//  Homework_4
//
//  Created by Sasha on 20/01/2021.
//

import Foundation

struct ListWeather: Codable {
    let cnt: Int
    let list: [CurrentWeather]
}
