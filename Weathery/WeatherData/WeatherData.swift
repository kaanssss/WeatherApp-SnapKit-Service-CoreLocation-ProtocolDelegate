//
//  WeatherData.swift
//  Weathery
//
//  Created by Kaan Yalçınkaya on 20.01.2023.
//

import Foundation

struct WeatherData: Codable {
    let name: String
    let main: Main
    let weather: [Weather]
}

struct Main: Codable {
    let temp: Double
}

struct Weather: Codable {
    let description: String
    let id: Int
}
