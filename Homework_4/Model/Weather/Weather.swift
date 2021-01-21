//
//  Weather.swift
//  Homework_4
//
//  Created by Sasha on 20/01/2021.
//

import Foundation

struct Weather: Codable, Hashable {
    let id: Int
    let main, weatherDescription, icon: String

    enum CodingKeys: String, CodingKey {
        case id, main
        case weatherDescription = "description"
        case icon
    }
}
