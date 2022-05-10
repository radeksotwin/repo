//
//  WeatherModel.swift
//  WeatherP2
//
//  Created by Rdm on 17/11/2020.
//

import Foundation

class Forecast {
    
    var weather: Weather!
    var place: Place!
    
    init(weather: Weather, place: Place) {
        self.weather = weather
        self.place = place
    }
    
}
